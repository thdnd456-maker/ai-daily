"""AI 데일리 편집국: RSS 수집 → (선택) Claude 재작성 → 무료 라이선스 사진 → 정적 사이트 렌더링.

사용법:
    py newsroom.py            # API 키가 있으면 AI 모드, 없으면 무료 모드
    py newsroom.py --free     # 강제로 무료 모드 (AI 호출 0회)
    py newsroom.py --render   # 수집 없이 사진 보강 + 사이트만 다시 그림
"""
import datetime as dt
import email.utils
import hashlib
import html
import json
import os
import re
import shutil
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
import xml.etree.ElementTree as ET
from pathlib import Path

ROOT = Path(__file__).parent
DATA = ROOT / "data" / "articles.json"
USAGE_LOG = ROOT / "data" / "usage.log"
OUT = ROOT / "docs"
MEDIA = ROOT / "media"  # AI 생성 이미지 원본 보관 (docs는 매번 새로 그리므로 분리)
KST = dt.timezone(dt.timedelta(hours=9))
CFG = json.loads((ROOT / "config.json").read_text(encoding="utf-8"))
SLUGS = {"정치": "politics", "경제": "economy", "사회": "society", "국제": "world",
         "IT·과학": "tech", "문화·연예": "culture", "스포츠": "sports"}
FOUNDED = dt.date(2026, 11, 13)
UA = "AI-Daily-Bot/1.0 (static news site generator)"
# 백만 토큰당 (입력, 출력) 달러. 비용 추적용 추정치.
PRICES = {"claude-opus-5-5": (4.0, 20.0), "claude-sonnet-5-5": (2.0, 10.0),
          "claude-haiku-5-5": (0.10, 0.50)}
FALLBACK_MODELS = {"claude-opus-5-5", "claude-sonnet-5-5", "claude-fable-5-2"}


def get(url, timeout=20):
    req = urllib.request.Request(url, headers={"User-Agent": UA})
    with urllib.request.urlopen(req, timeout=timeout) as r:
        return r.read()


# ───────────────────────── 수집 ─────────────────────────
def strip_tags(s):
    return re.sub(r"\s+", " ", html.unescape(re.sub(r"<[^>]+>", " ", s or "")).replace("\xa0", " ")).strip()


def split_source(title):
    """'헤드라인 - 매체' → ('헤드라인', '매체')"""
    if " - " in title:
        head, src = title.rsplit(" - ", 1)
        return head.strip(), src.strip()
    return title.strip(), ""


def fetch_feed(feed):
    root = ET.fromstring(get(feed["url"]))
    items = []
    for it in root.iter("item"):
        title, source = split_source(it.findtext("title", ""))
        desc = it.findtext("description", "")
        related, coverage = [], []
        for href, a, f in re.findall(r'<a [^>]*?href="([^"]+)"[^>]*>(.*?)</a>.*?<font[^>]*>(.*?)</font>', desc, re.S):
            t, src = strip_tags(a), strip_tags(f)
            coverage.append({"title": t, "source": src, "url": html.unescape(href)})
            if t and t != title:
                related.append(f"{t} ({src})")
        if not related and desc and "<a " not in desc:
            related.append(strip_tags(desc)[:500])
        try:
            pub = email.utils.parsedate_to_datetime(it.findtext("pubDate")).astimezone(KST).isoformat()
        except Exception:
            pub = dt.datetime.now(KST).isoformat()
        guid = it.findtext("guid") or it.findtext("link", "")
        items.append({
            "id": hashlib.sha1(guid.encode()).hexdigest()[:12],
            "orig_title": title, "source": source, "source_url": it.findtext("link", ""),
            "related": related[:5], "coverage": coverage[:6], "published": pub, "section_hint": feed["section"],
        })
    return items


def norm(t):
    return re.sub(r"[^0-9a-z가-힣]", "", t.lower())[:40]


def collect(archive):
    seen_ids = {a["id"] for a in archive}
    seen_titles = {norm(a["orig_title"]) for a in archive}
    per_feed = []
    for feed in CFG["feeds"]:
        try:
            per_feed.append(fetch_feed(feed))
        except Exception as e:
            print(f"[경고] 피드 실패 {feed['url'][:60]}…: {e}")
    picked, n = [], CFG["max_new_per_run"]
    # 섹션이 골고루 나오도록 피드별로 한 개씩 돌아가며 뽑는다
    while len(picked) < n and any(per_feed):
        for items in per_feed:
            while items:
                it = items.pop(0)
                key = norm(it["orig_title"])
                if it["id"] in seen_ids or key in seen_titles:
                    continue
                seen_ids.add(it["id"]); seen_titles.add(key)
                picked.append(it)
                break
            if len(picked) >= n:
                break
    return picked


# ───────────────────────── 작성 ─────────────────────────
def write_free(items):
    out = []
    for it in items:
        body = "\n\n".join(["관련 보도:"] + [f"· {r}" for r in it["related"]]) if it["related"] else ""
        out.append({**it, "headline": it["orig_title"], "summary": "", "body": body,
                    "section": it["section_hint"], "tags": [], "image_keyword": "", "ai": False})
    return out


def log_usage(model, n, u, extra=""):
    pin, pout = PRICES.get(model, (0, 0))
    searches = getattr(getattr(u, "server_tool_use", None), "web_search_requests", 0) or 0
    cost = (u.input_tokens * pin + u.output_tokens * pout) / 1e6 + searches * 0.01
    line = (f"{dt.datetime.now(KST):%Y-%m-%d %H:%M} model={model} items={n} {extra}"
            f"in={u.input_tokens} out={u.output_tokens} search={searches} ≈${cost:.4f}")
    print("[사용량]", line)
    with USAGE_LOG.open("a", encoding="utf-8") as f:
        f.write(line + "\n")


RESEARCH_PROMPT = """당신은 신문사 취재 보조입니다. 각 뉴스 항목마다 web_search를 한 번씩 실행해 관련 보도를 찾고, 기사 작성에 쓸 사실 메모를 만듭니다.
- 검색 결과에서 확인된 사실만: 누가, 언제, 어디서, 무엇을, 수치, 배경, 각 당사자의 입장·반응, 향후 일정.
- 원문 문장을 베끼지 말고 짧은 메모체로 다시 씁니다. 직접 인용문은 옮기지 않습니다.
- 항목당 8~15줄. 확인되지 않은 내용은 쓰지 않습니다.
- 출력 형식(다른 말 없이):
### <id>
- 사실 메모
- ...
"""


def research(items):
    """기사별로 웹 검색 1회 → 사실 메모. 헤드라인만으로는 본문이 빈약해서 추가했다 (검색 1회 약 $0.01)."""
    import anthropic

    model = CFG["model"]
    client = anthropic.Anthropic()
    payload = [{"id": it["id"], "title": it["orig_title"], "related": it["related"][:3]} for it in items]
    messages = [{"role": "user", "content": RESEARCH_PROMPT + "\n항목:\n"
                 + json.dumps(payload, ensure_ascii=False, separators=(",", ":"))}]
    text = ""
    for _ in range(3):  # 서버 도구가 길어지면 pause_turn으로 멈추므로 이어서 진행
        resp = client.messages.create(
            model=model, max_tokens=12000, system="한국어로 답합니다.", messages=messages,
            output_config={"effort": CFG.get("effort", "low")},
            tools=[{"type": "web_search_20250305", "name": "web_search", "max_uses": len(items) + 1,
                    "user_location": {"type": "approximate", "country": "KR", "timezone": "Asia/Seoul"}}])
        log_usage(model, len(items), resp.usage, "research ")
        text += "".join(b.text for b in resp.content if b.type == "text")
        if resp.stop_reason != "pause_turn":
            break
        messages.append({"role": "assistant", "content": resp.content})
    notes = {}
    for part in re.split(r"^###\s*", text, flags=re.M):
        head, _, rest = part.partition("\n")
        if head.strip() and rest.strip():
            notes[head.strip()] = rest.strip()[:2500]
    return notes


def write_ai(items, chunk=8):
    """한 번에 너무 많이 쓰면 출력이 잘리므로 8건씩 나눠 호출한다."""
    out = []
    for i in range(0, len(items), chunk):
        part = items[i:i + chunk]
        if CFG.get("research", True):
            want = [it for it in part if not it.get("researched")][:6]
            for j in range(0, len(want), 3):  # 검색 결과가 길어 3건씩
                try:
                    notes = research(want[j:j + 3])
                except Exception as e:
                    print(f"[경고] 취재(웹 검색) 실패: {e}"); notes = {}
                for it in want[j:j + 3]:
                    if notes.get(it["id"]):
                        it["notes"] = notes[it["id"]]
        out += write_ai_batch(part)
    return out


def write_ai_batch(items):
    import anthropic

    model = CFG["model"]
    system = (ROOT / "prompts" / "editor.md").read_text(encoding="utf-8")
    payload = [{"id": it["id"], "title": it["orig_title"], "source": it["source"],
                "related": it["related"], "section_hint": it["section_hint"],
                **({"notes": it["notes"]} if it.get("notes") else {})} for it in items]
    fields = ["id", "headline", "summary", "key_points", "body", "section", "tags", "image_keyword", "image_prompt"]
    schema = {
        "type": "object", "additionalProperties": False, "required": ["articles"],
        "properties": {"articles": {"type": "array", "items": {
            "type": "object", "additionalProperties": False, "required": fields,
            "properties": {
                "id": {"type": "string"}, "headline": {"type": "string"},
                "summary": {"type": "string"}, "body": {"type": "string"},
                "key_points": {"type": "array", "items": {"type": "string"}},
                "section": {"type": "string", "enum": CFG["sections"]},
                "tags": {"type": "array", "items": {"type": "string"}},
                "image_keyword": {"type": "string"}, "image_prompt": {"type": "string"},
            }}}},
    }
    kwargs = dict(
        model=model, max_tokens=16000, system=system,
        output_config={"effort": CFG.get("effort", "low"),
                       "format": {"type": "json_schema", "schema": schema}},
        messages=[{"role": "user", "content": "다음 뉴스 항목들로 기사를 작성하세요.\n"
                   + json.dumps(payload, ensure_ascii=False, separators=(",", ":"))}],
    )
    client = anthropic.Anthropic()
    if model in FALLBACK_MODELS:  # 안전 분류기가 거절하면 서버가 다른 모델로 재시도
        resp = client.beta.messages.create(betas=["server-side-fallback-2026-07-01"],
                                           fallbacks="default", **kwargs)
    else:
        resp = client.messages.create(**kwargs)

    log_usage(model, len(items), resp.usage)

    if resp.stop_reason != "end_turn":
        print(f"[경고] stop_reason={resp.stop_reason} → 무료 모드로 대체")
        return write_free(items)
    text = next(b.text for b in resp.content if b.type == "text")
    written = {a["id"]: a for a in json.loads(text)["articles"]}
    out = []
    for it in items:
        a = written.get(it["id"])
        if not a:
            out += write_free([it]); continue
        done = {k: v for k, v in it.items() if k != "notes"}
        out.append({**done, **{k: a[k] for k in fields[1:]}, "ai": True,
                    **({"researched": True} if it.get("notes") else {})})
    return out


# ───────────────────────── 사진 (위키백과·위키미디어 공용, 자유 라이선스) ─────────────────────────
def wiki_get(url):
    for wait in (1, 5, 15):  # 위키미디어 요청 제한(429) 대응
        time.sleep(wait)
        try:
            return json.loads(get(url, 10))
        except urllib.error.HTTPError as e:
            if e.code != 429:
                raise
    raise RuntimeError("429 반복")


def wiki_image(query, used):
    """한국어 위키백과에서 query와 제목이 일치하는 문서의 대표 사진(자유 라이선스, 공용 저장소)."""
    base = {"action": "query", "format": "json", "prop": "pageimages", "piprop": "thumbnail|name",
            "pithumbsize": 1000, "pilicense": "free"}
    # 1) 정확한 제목(넘겨주기 포함) 2) 검색 결과 중 제목에 검색어가 들어간 문서만 — 엉뚱한 사진 방지
    exact = wiki_get("https://ko.wikipedia.org/w/api.php?" + urllib.parse.urlencode(
        {**base, "titles": query, "redirects": 1})).get("query", {}).get("pages", {})
    pages = [p for p in exact.values() if "missing" not in p]
    if not pages or not pages[0].get("thumbnail"):
        found = wiki_get("https://ko.wikipedia.org/w/api.php?" + urllib.parse.urlencode(
            {**base, "generator": "search", "gsrsearch": query, "gsrlimit": 3})).get("query", {}).get("pages", {})
        key = query.replace(" ", "")
        pages = [p for p in sorted(found.values(), key=lambda p: p.get("index", 99))
                 if key in p["title"].replace(" ", "")]
    for p in pages:
        th, name = p.get("thumbnail"), p.get("pageimage")
        if not th or not name or "/wikipedia/commons/" not in th["source"] or file_key(name) in used:
            continue
        # 로고·국기·지도·문장(SVG 그래픽)은 썸네일로 어색해서 제외 → AI 이미지로 대체
        if name.lower().endswith(".svg") or re.search(r"logo|flag|seal|emblem|icon|map|symbol", name, re.I):
            continue
        meta_q = urllib.parse.urlencode({
            "action": "query", "format": "json", "titles": "File:" + name, "prop": "imageinfo",
            "iiprop": "extmetadata|url", "iiextmetadatafilter": "Artist|LicenseShortName"})
        info = next(iter(wiki_get("https://commons.wikimedia.org/w/api.php?" + meta_q)
                         ["query"]["pages"].values())).get("imageinfo", [{}])[0]
        meta = info.get("extmetadata", {})
        used.add(file_key(name))
        return {"url": th["source"].split("?")[0], "w": th["width"], "h": th["height"],
                "page": info.get("descriptionurl", ""), "subject": p["title"],
                "artist": strip_tags(meta.get("Artist", {}).get("value", ""))[:60] or "작자 미상",
                "license": meta.get("LicenseShortName", {}).get("value", "")}
    return None


def file_key(name):
    return urllib.parse.unquote(name).replace(" ", "_").lower()


def image_file(url):
    """위키미디어 썸네일 URL → 원본 파일명 (…/thumb/a/ab/파일명/1280px-파일명)."""
    parts = url.split("/")
    return file_key(parts[parts.index("thumb") + 3] if "thumb" in parts else parts[-1])


def dedupe_images(archive):
    """같은 위키 사진이 여러 기사에 반복되지 않게: 최신 기사 하나만 남기고 나머지는 AI 이미지 대상으로."""
    seen, n = set(), 0
    for a in sorted(archive, key=lambda a: a["published"], reverse=True):
        im = a.get("image")
        if not im or im.get("generated"):
            continue
        k = image_file(im["url"])
        if k in seen or re.search(r"\.svg|logo|flag|seal|emblem|icon|map|symbol", k):
            a["image"] = None; n += 1
        seen.add(k)
    if n:
        print(f"[사진] 중복·그래픽 사진 {n}건 정리")


def add_images(archive, limit=40):
    used = {image_file(a["image"]["url"]) for a in archive if a.get("image") and not a["image"].get("generated")}
    n = 0
    for a in archive:
        if not a.get("ai") or "image" in a or n >= limit:
            continue
        n += 1
        a["image"] = None
        # AI가 image_keyword를 비워 두면(범죄·사고 등) 사진을 넣지 않는다. 구형 기사만 태그로 대체 검색.
        queries = [a["image_keyword"]] if "image_keyword" in a else a.get("tags", [])[:2]
        for q in queries:
            if not q:
                continue
            try:
                img = wiki_image(q, used)
            except Exception as e:
                print(f"[경고] 사진 검색 실패 {q}: {e}")
                a.pop("image", None)  # 다음 실행 때 다시 시도
                break
            if img:
                a["image"] = img; break
    if n:
        print(f"[사진] {n}건 검색, {sum(1 for a in archive if a.get('image'))}건 보유")


def add_about(archive, limit=30):
    """기사 핵심 대상의 위키백과 첫 문단을 '알아보기' 배경 정보로 붙인다 (무료, CC BY-SA)."""
    n = 0
    for a in archive:
        kw = a.get("image_keyword")
        if not a.get("ai") or not kw or "about" in a or n >= limit:
            continue
        n += 1
        try:
            pages = wiki_get("https://ko.wikipedia.org/w/api.php?" + urllib.parse.urlencode({
                "action": "query", "format": "json", "prop": "extracts|info", "exintro": 1,
                "explaintext": 1, "exsentences": 3, "inprop": "url", "titles": kw, "redirects": 1,
            })).get("query", {}).get("pages", {})
        except Exception as e:
            print(f"[경고] 배경 정보 실패 {kw}: {e}"); continue
        p = next(iter(pages.values()), {})
        text = re.sub(r"\s+", " ", p.get("extract", "")).strip()
        a["about"] = ({"title": p["title"], "text": text[:420], "url": p.get("fullurl", "")}
                      if "missing" not in p and len(text) > 40 and "동음이의" not in text else None)
    if n:
        print(f"[배경] {n}건 조회")


# ───────────────────────── AI 생성 이미지 (Cloudflare Workers AI, FLUX) ─────────────────────────
STYLE = ("realistic documentary news photograph, natural light, shot on 35mm, shallow depth of field, "
         "photojournalism, no text, no letters, no logos, no watermark")
STYLE_VER = 2  # 화풍을 바꾸면 올린다 → 예전 그림을 조금씩 새로 그림


def gen_images(archive):
    acct, token = os.environ.get("CLOUDFLARE_ACCOUNT_ID"), os.environ.get("CLOUDFLARE_API_TOKEN")
    if not (acct and token):
        return
    from io import BytesIO
    import base64
    from PIL import Image

    MEDIA.mkdir(exist_ok=True)
    url = f"https://api.cloudflare.com/client/v4/accounts/{acct}/ai/run/{CFG.get('image_model', '@cf/black-forest-labs/flux-1-schnell')}"
    # 기사별 장면 묘사(image_prompt)가 있는 기사만 — 섹션 공용 장면은 비슷한 그림이 반복돼서 쓰지 않는다
    fresh = [a for a in archive if a.get("ai") and not a.get("image") and a.get("image_prompt")]
    redo = [a for a in archive if (a.get("image") or {}).get("generated")
            and a["image"].get("style", 1) < STYLE_VER and a.get("image_prompt")]
    todo = (fresh + redo)[:CFG.get("max_images_per_run", 10)]
    made = 0
    for a in todo:
        scene = a["image_prompt"]
        body = json.dumps({"prompt": f"{scene}. {STYLE}", "steps": 4}).encode()
        req = urllib.request.Request(url, data=body, method="POST", headers={
            "Authorization": f"Bearer {token}", "Content-Type": "application/json", "User-Agent": UA})
        try:
            with urllib.request.urlopen(req, timeout=60) as r:
                raw, ctype = r.read(), r.headers.get("Content-Type", "")
            data = raw if ctype.startswith("image/") else base64.b64decode(json.loads(raw)["result"]["image"])
            im = Image.open(BytesIO(data)).convert("RGB")
            im.thumbnail((960, 960))
            name = f"{a['id']}.webp"
            im.save(MEDIA / name, "WEBP", quality=72)  # 용량 절약 (보통 40~80KB)
        except urllib.error.HTTPError as e:
            print(f"[경고] 이미지 생성 실패 {a['id']}: {e}")
            if e.code == 429:  # 무료 일일 한도 소진 → 이번 실행은 중단, 다음 날 재개
                break
            continue
        except Exception as e:
            print(f"[경고] 이미지 생성 실패 {a['id']}: {e}")
            continue
        a["image"] = {"url": f"media/{name}", "w": im.width, "h": im.height, "generated": True,
                      "subject": a["headline"], "artist": "AI 생성", "license": "", "page": "",
                      "style": STYLE_VER}
        made += 1
    if todo:
        print(f"[AI 이미지] {made}/{len(todo)}장 생성")


# ───────────────────────── 렌더링 ─────────────────────────
def esc(s):
    return html.escape(s or "")


def kst(iso):
    return dt.datetime.fromisoformat(iso).astimezone(KST)


def ago(iso):
    m = int((dt.datetime.now(KST) - kst(iso)).total_seconds() // 60)
    if m < 1: return "방금"
    if m < 60: return f"{m}분 전"
    if m < 1440: return f"{m // 60}시간 전"
    return f"{kst(iso):%m.%d}"


def link(a, up):
    return f'{up}a/{a["id"]}.html'


def src(im, up):
    return up + im["url"] if im.get("generated") else im["url"]


def img_tag(a, up, cls="ph", size=""):
    im = a.get("image")
    if im:
        pos = "center 20%" if im["h"] > im["w"] else "center"
        label = '<i class="ailabel">AI 이미지</i>' if im.get("generated") else ""
        return (f'<div class="{cls}"><img src="{esc(src(im, up))}" alt="{esc(im["subject"])}" '
                f'loading="lazy" style="object-position:{pos}">{label}</div>')
    return f'<div class="{cls} noimg s-{SLUGS[a["section"]]}"><span>{esc(a["section"])}</span></div>'


def page(title, body, depth=0, desc="", active=""):
    up = "../" * depth
    nav = f'<a href="{up}index.html" class="{"on" if active == "home" else ""}">홈</a>' + "".join(
        f'<a href="{up}section/{SLUGS[s]}.html" class="{"on" if active == s else ""}">{esc(s)}</a>'
        for s in CFG["sections"])
    now = dt.datetime.now(KST)
    wd = "월화수목금토일"[now.weekday()]
    no = (now.date() - FOUNDED).days + 1
    return f"""<!doctype html>
<html lang="ko"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>{esc(title)}</title><meta name="description" content="{esc(desc or CFG['tagline'])}">
<link rel="preconnect" href="https://fonts.googleapis.com"><link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Noto+Serif+KR:wght@500;700;900&family=Noto+Sans+KR:wght@400;500;700&display=swap" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Yuji+Syuku&display=swap&text={urllib.parse.quote(CFG.get('site_hanja', ''))}" rel="stylesheet">
<link rel="stylesheet" href="{up}style.css"><link rel="alternate" type="application/rss+xml" href="{up}feed.xml">
</head><body>
<div class="util"><div class="wrap"><span>{now:%Y년 %m월 %d일} {wd}요일</span><span class="hide-m">제{no}호 · 매일 24시간 자동 발행</span><a href="{up}feed.xml">RSS</a></div></div>
<header class="mast"><div class="wrap">
<a class="logo" href="{up}index.html" aria-label="{esc(CFG['site_name'])}">{esc(CFG.get('site_hanja') or CFG['site_name'])}</a>
<p class="tag"><b>{esc(CFG['site_name'])}</b> · {esc(CFG['tagline'])}</p></div></header>
<nav class="gnb"><div class="wrap">{nav}</div></nav>
{body}
<footer class="foot"><div class="wrap">
<div class="flogo">{esc(CFG.get('site_hanja') or CFG['site_name'])}</div>
<nav>{"".join(f'<a href="{up}section/{SLUGS[s]}.html">{esc(s)}</a>' for s in CFG["sections"])}</nav>
<p>「{esc(CFG['site_name'])}」의 기사는 공개 보도의 헤드라인을 AI가 종합·재작성한 자동 브리핑입니다. 사실관계는 각 기사의 원문 링크에서 확인하세요.
AI가 작성한 기사에는 오류가 있을 수 있습니다. 사진은 위키미디어 공용의 자유 라이선스 참고 이미지이거나, "AI 이미지"로 표시된 AI 생성 일러스트이며 기사 현장 사진이 아닙니다.</p>
<p class="copy">최종 업데이트 {now:%Y.%m.%d %H:%M} KST</p></div></footer>
</body></html>"""


def ticker(arts, up):
    items = "".join(f'<a href="{link(a, up)}">{esc(a["headline"])}</a>' for a in arts[:10])
    return (f'<div class="ticker"><div class="wrap"><b>실시간</b><div class="tk"><div class="tk-in">'
            f'{items}{items}</div></div></div></div>')


def meta(a):
    return f'<span class="meta">{esc(a["section"])} · {ago(a["published"])}</span>'


def render(archive):
    if OUT.exists():
        shutil.rmtree(OUT)
    (OUT / "a").mkdir(parents=True); (OUT / "section").mkdir()
    shutil.copy(ROOT / "templates" / "style.css", OUT / "style.css")
    (OUT / ".nojekyll").write_text("")
    arts = sorted(archive, key=lambda a: a["published"], reverse=True)
    # 보관 기사에 쓰이는 AI 이미지만 발행하고, 밀려난 기사의 이미지는 지운다
    keep = {a["image"]["url"].split("/")[-1] for a in arts if (a.get("image") or {}).get("generated")}
    if MEDIA.exists():
        (OUT / "media").mkdir()
        for f in MEDIA.iterdir():
            if f.name in keep:
                shutil.copy(f, OUT / "media" / f.name)
            else:
                f.unlink()
    # 1면 톱은 사진 있는 AI 기사 우선
    pics = [a for a in arts if a.get("image")]
    # 국기·로고(SVG) 같은 그래픽보다 실제 사진을 톱에
    pics.sort(key=lambda a: (".svg" in a["image"]["url"]) * 4 + (a["image"]["h"] > a["image"]["w"]) * 2
              + bool(a["image"].get("generated")))  # 가로 사진 우선, 세로 인물 사진은 뒤로

    # ── 1면
    if arts:
        lead = pics[0] if pics else arts[0]
        rest = [a for a in arts if a is not lead]
        subs = [a for a in rest if a.get("image")][:2] or rest[:2]
        others = [a for a in rest if a not in subs]
        body = ticker(arts, "") + '<main class="wrap">'
        body += (f'<section class="front"><a class="hero" href="{link(lead, "")}">{img_tag(lead, "", "hero-img")}'
                 f'<div class="hero-txt"><span class="kicker">{esc(lead["section"])}</span>'
                 f'<h1>{esc(lead["headline"])}</h1><p>{esc(lead.get("summary"))}</p>'
                 f'<span class="meta">{ago(lead["published"])}</span></div></a>'
                 '<div class="subs">' + "".join(
                     f'<a class="sub" href="{link(a, "")}">{img_tag(a, "")}<span class="kicker">{esc(a["section"])}</span>'
                     f'<h3>{esc(a["headline"])}</h3></a>' for a in subs) + '</div>'
                 '<aside class="rail"><h2 class="rh">최신 뉴스</h2><ol>' + "".join(
                     f'<li><a href="{link(a, "")}">{esc(a["headline"])}</a><span class="meta">{ago(a["published"])}</span></li>'
                     for a in others[:8]) + '</ol></aside></section>')
        # 섹션 3단 카드
        body += '<section class="secgrid">'
        for s in CFG["sections"]:
            items = [a for a in arts if a["section"] == s]
            if not items:
                continue
            top = next((a for a in items if a.get("image")), items[0])
            lst = [a for a in items if a is not top][:4]
            body += (f'<div class="sbox"><div class="sbh"><h2>{esc(s)}</h2>'
                     f'<a href="section/{SLUGS[s]}.html">더보기 →</a></div>'
                     f'<a class="stop" href="{link(top, "")}">{img_tag(top, "")}<h3>{esc(top["headline"])}</h3>'
                     f'<p>{esc(top.get("summary"))}</p></a><ul>' + "".join(
                         f'<li><a href="{link(a, "")}">{esc(a["headline"])}</a></li>' for a in lst) + '</ul></div>')
        body += '</section></main>'
    else:
        body = '<main class="wrap"><p>아직 기사가 없습니다.</p></main>'
    (OUT / "index.html").write_text(page(CFG["site_name"], body, active="home"), encoding="utf-8")

    # ── 섹션
    for s in CFG["sections"]:
        items = [a for a in arts if a["section"] == s]
        rows = "".join(
            f'<a class="row{"" if a.get("image") else " noph"}" href="{link(a, "../")}">{img_tag(a, "../") if a.get("image") else ""}<div><h3>{esc(a["headline"])}</h3>'
            f'<p>{esc(a.get("summary"))}</p><span class="meta">{kst(a["published"]):%Y.%m.%d %H:%M}</span></div></a>'
            for a in items) or "<p>기사가 없습니다.</p>"
        b = (ticker(arts, "../") + f'<main class="wrap"><h1 class="ptitle">{esc(s)}</h1>'
             f'<div class="cols"><div class="list">{rows}</div>{rail(arts, "../")}</div></main>')
        (OUT / "section" / f"{SLUGS[s]}.html").write_text(
            page(f"{s} - {CFG['site_name']}", b, 1, active=s), encoding="utf-8")

    # ── 기사
    for a in arts:
        paras = "".join(f"<p>{esc(p)}</p>" for p in a["body"].split("\n\n") if p.strip())
        tags = "".join(f'<span class="tg">#{esc(t)}</span>' for t in a.get("tags", []))
        more = [x for x in arts if x["section"] == a["section"] and x["id"] != a["id"]][:3]
        badge = "AI 기자" if a.get("ai") else "자동 수집"
        im = a.get("image")
        if im and im.get("generated"):
            fig = (f'<figure class="fig"><img src="{esc(src(im, "../"))}" alt="기사 내용을 표현한 AI 생성 이미지">'
                   f'<figcaption>AI 생성 이미지 · 실제 현장 사진이 아닙니다 (Cloudflare Workers AI · FLUX)</figcaption></figure>')
        elif im:
            fig = (f'<figure class="fig{" logo" if ".svg" in im["url"] else ""}"><img src="{esc(im["url"])}" alt="{esc(im["subject"])}">'
                   f'<figcaption>{esc(im["subject"])} (참고 이미지) · 사진: {esc(im["artist"])} / '
                   f'<a href="{esc(im["page"])}" target="_blank" rel="noopener">{esc(im["license"]) or "위키미디어 공용"}</a>'
                   f'</figcaption></figure>')
        else:
            fig = ""
        kp = "".join(f"<li>{esc(k)}</li>" for k in a.get("key_points", []))
        kp = f'<div class="kp"><b>핵심 정리</b><ul>{kp}</ul></div>' if kp else ""
        ab = a.get("about")
        ab = (f'<aside class="about"><b>알아보기 · {esc(ab["title"])}</b><p>{esc(ab["text"])}</p>'
              f'<a href="{esc(ab["url"])}" target="_blank" rel="noopener">출처: 위키백과 (CC BY-SA 4.0) ↗</a></aside>') if ab else ""
        cov = a.get("coverage") or [{"title": a["orig_title"], "source": a["source"], "url": a["source_url"]}]
        cov = "".join(
            f'<li><a href="{esc(c["url"])}" rel="noopener nofollow" target="_blank">{esc(c["title"])}</a>'
            f'<span>{esc(c["source"])}</span></li>' for c in cov)
        b = (f'<main class="wrap"><div class="cols"><article class="story">'
             f'<a class="kicker" href="../section/{SLUGS[a["section"]]}.html">{esc(a["section"])}</a>'
             f'<h1>{esc(a["headline"])}</h1>'
             + (f'<p class="dek">{esc(a["summary"])}</p>' if a.get("summary") else "") +
             f'<div class="byline"><span class="badge">{badge}</span>입력 {kst(a["published"]):%Y.%m.%d %H:%M}</div>'
             f'{fig}{kp}<div class="text">{paras}</div>{ab}<div class="tags">{tags}</div>'
             f'<div class="src"><b>이 소식을 다룬 보도</b><ul>{cov}</ul></div>'
             + (f'<section class="more"><h2 class="rh">{esc(a["section"])} 다른 기사</h2><div class="mgrid">' + "".join(
                 f'<a class="sub" href="{x["id"]}.html">{img_tag(x, "../") if x.get("image") else ""}<h3>{esc(x["headline"])}</h3></a>'
                 for x in more) + '</div></section>' if more else "")
             + f'</article>{rail(arts, "../", exclude=a["id"])}</div></main>')
        (OUT / "a" / f"{a['id']}.html").write_text(
            page(f"{a['headline']} - {CFG['site_name']}", b, 1, a.get("summary", ""), active=a["section"]),
            encoding="utf-8")

    # ── RSS
    base = CFG.get("base_url", "").rstrip("/")
    items = "".join(
        f"<item><title>{esc(a['headline'])}</title><link>{base}/a/{a['id']}.html</link>"
        f"<guid>{a['id']}</guid><pubDate>{email.utils.format_datetime(kst(a['published']))}</pubDate>"
        f"<description>{esc(a.get('summary') or a['headline'])}</description></item>" for a in arts[:50])
    (OUT / "feed.xml").write_text(
        f'<?xml version="1.0" encoding="UTF-8"?><rss version="2.0"><channel><title>{esc(CFG["site_name"])}</title>'
        f'<link>{base}/</link><description>{esc(CFG["tagline"])}</description>{items}</channel></rss>', encoding="utf-8")
    print(f"[렌더링] 기사 {len(arts)}건 → {OUT}")


def rail(arts, up, exclude=None):
    lst = [a for a in arts if a["id"] != exclude][:8]
    return ('<aside class="rail"><h2 class="rh">최신 뉴스</h2><ol>' + "".join(
        f'<li><a href="{link(a, up)}">{esc(a["headline"])}</a>{meta(a)}</li>' for a in lst) + '</ol></aside>')


# ───────────────────────── 실행 ─────────────────────────
def main():
    try:
        sys.stdout.reconfigure(encoding="utf-8")  # Windows 콘솔 한글 깨짐 방지
    except Exception:
        pass
    DATA.parent.mkdir(exist_ok=True)
    archive = json.loads(DATA.read_text(encoding="utf-8")) if DATA.exists() else []
    if "--render" not in sys.argv:
        new = collect(archive)
        print(f"[수집] 새 기사 {len(new)}건")
        use_ai = "--free" not in sys.argv and os.environ.get("ANTHROPIC_API_KEY")
        # 예전에 짧게 쓰였거나 무료 모드로 올라간 기사를 실행마다 조금씩 새 형식으로 다시 쓴다
        backlog = [a for a in archive if not (a.get("ai") and a.get("key_points"))][:CFG.get("max_backlog_per_run", 16)] if use_ai else []
        # 웹 검색 취재 없이 쓰인 최근 기사도 조금씩 보강 (1면에 걸리는 최신 기사 위주)
        cutoff = (dt.datetime.now(KST) - dt.timedelta(hours=CFG.get("research_backlog_hours", 36))).isoformat()
        if use_ai and CFG.get("research", True):
            backlog += [a for a in archive if a.get("ai") and not a.get("researched") and a not in backlog
                        and a["published"] > cutoff][:CFG.get("research_backlog_per_run", 4)]
        todo = new + backlog
        if todo:
            if use_ai:
                try:
                    done = write_ai(todo)
                except Exception as e:
                    print(f"[경고] AI 작성 실패 → 무료 모드: {e}")
                    done = write_free(new) + backlog
            else:
                print("[모드] 무료 모드 (ANTHROPIC_API_KEY 없음 또는 --free)")
                done = write_free(new)
            by_id = {a["id"]: a for a in done}
            archive = [by_id.pop(a["id"], a) for a in archive] + list(by_id.values())
            archive = sorted(archive, key=lambda a: a["published"], reverse=True)[:CFG["max_archive"]]
    dedupe_images(archive)
    add_images(archive)
    add_about(archive)
    if "--render" not in sys.argv:
        gen_images(archive)
    for a in archive:
        a.pop("notes", None)
    DATA.write_text(json.dumps(archive, ensure_ascii=False, indent=1), encoding="utf-8")
    render(archive)


if __name__ == "__main__":
    main()
