"""AI 데일리 편집국: RSS 수집 → (선택) Claude 재작성 → 정적 사이트 렌더링.

사용법:
    py newsroom.py            # API 키가 있으면 AI 모드, 없으면 무료 모드
    py newsroom.py --free     # 강제로 무료 모드 (AI 호출 0회)
    py newsroom.py --render   # 수집 없이 사이트만 다시 그림
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
import urllib.request
import xml.etree.ElementTree as ET
from pathlib import Path

ROOT = Path(__file__).parent
DATA = ROOT / "data" / "articles.json"
USAGE_LOG = ROOT / "data" / "usage.log"
OUT = ROOT / "docs"
KST = dt.timezone(dt.timedelta(hours=9))
CFG = json.loads((ROOT / "config.json").read_text(encoding="utf-8"))
SLUGS = {"정치": "politics", "경제": "economy", "사회": "society", "국제": "world",
         "IT·과학": "tech", "문화·연예": "culture", "스포츠": "sports"}
# 백만 토큰당 (입력, 출력) 달러. 비용 추적용 추정치.
PRICES = {"claude-opus-5-5": (4.0, 20.0), "claude-sonnet-5-5": (2.0, 10.0),
          "claude-haiku-5-5": (0.10, 0.50)}
FALLBACK_MODELS = {"claude-opus-5-5", "claude-sonnet-5-5", "claude-fable-5-2"}


# ───────────────────────── 수집 ─────────────────────────
def strip_tags(s):
    return html.unescape(re.sub(r"<[^>]+>", " ", s or "")).replace("\xa0", " ").strip()


def split_source(title):
    """'헤드라인 - 매체' → ('헤드라인', '매체')"""
    if " - " in title:
        head, src = title.rsplit(" - ", 1)
        return head.strip(), src.strip()
    return title.strip(), ""


def fetch_feed(feed):
    req = urllib.request.Request(feed["url"], headers={"User-Agent": "Mozilla/5.0 (AI-Daily RSS reader)"})
    with urllib.request.urlopen(req, timeout=20) as r:
        root = ET.fromstring(r.read())
    items = []
    for it in root.iter("item"):
        title, source = split_source(it.findtext("title", ""))
        desc = it.findtext("description", "")
        related = []
        for a, f in re.findall(r"<a [^>]*>(.*?)</a>.*?<font[^>]*>(.*?)</font>", desc, re.S):
            t = strip_tags(a)
            if t and t != title:
                related.append(f"{t} ({strip_tags(f)})")
        if not related and desc and "<a " not in desc:
            related.append(strip_tags(desc)[:500])
        pub = it.findtext("pubDate")
        try:
            pub = email.utils.parsedate_to_datetime(pub).astimezone(KST).isoformat()
        except Exception:
            pub = dt.datetime.now(KST).isoformat()
        guid = it.findtext("guid") or it.findtext("link", "")
        items.append({
            "id": hashlib.sha1(guid.encode()).hexdigest()[:12],
            "orig_title": title, "source": source, "source_url": it.findtext("link", ""),
            "related": related[:5], "published": pub, "section_hint": feed["section"],
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
        out.append({**it, "headline": it["orig_title"], "summary": "",
                    "body": body, "section": it["section_hint"], "tags": [], "ai": False})
    return out


def write_ai(items):
    import anthropic

    model = CFG["model"]
    system = (ROOT / "prompts" / "editor.md").read_text(encoding="utf-8")
    payload = [{"id": it["id"], "title": it["orig_title"], "source": it["source"],
                "related": it["related"], "section_hint": it["section_hint"]} for it in items]
    schema = {
        "type": "object", "additionalProperties": False, "required": ["articles"],
        "properties": {"articles": {"type": "array", "items": {
            "type": "object", "additionalProperties": False,
            "required": ["id", "headline", "summary", "body", "section", "tags"],
            "properties": {
                "id": {"type": "string"}, "headline": {"type": "string"},
                "summary": {"type": "string"}, "body": {"type": "string"},
                "section": {"type": "string", "enum": CFG["sections"]},
                "tags": {"type": "array", "items": {"type": "string"}},
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

    u = resp.usage
    pin, pout = PRICES.get(model, (0, 0))
    cost = (u.input_tokens * pin + u.output_tokens * pout) / 1e6
    line = (f"{dt.datetime.now(KST):%Y-%m-%d %H:%M} model={model} items={len(items)} "
            f"in={u.input_tokens} out={u.output_tokens} ≈${cost:.4f}")
    print("[사용량]", line)
    with USAGE_LOG.open("a", encoding="utf-8") as f:
        f.write(line + "\n")

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
        out.append({**it, **{k: a[k] for k in ("headline", "summary", "body", "section", "tags")}, "ai": True})
    return out


# ───────────────────────── 렌더링 ─────────────────────────
def esc(s):
    return html.escape(s or "")


def kst(iso):
    return dt.datetime.fromisoformat(iso).astimezone(KST)


def page(title, body, depth=0, desc=""):
    up = "../" * depth
    nav = "".join(f'<a href="{up}section/{SLUGS[s]}.html">{esc(s)}</a>' for s in CFG["sections"])
    now = dt.datetime.now(KST)
    wd = "월화수목금토일"[now.weekday()]
    return f"""<!doctype html>
<html lang="ko"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>{esc(title)}</title><meta name="description" content="{esc(desc or CFG['tagline'])}">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Noto+Serif+KR:wght@400;700;900&family=Noto+Sans+KR:wght@400;500;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="{up}style.css"><link rel="alternate" type="application/rss+xml" href="{up}feed.xml">
</head><body>
<header class="mast"><div class="wrap">
<div class="meta"><span>{now:%Y년 %m월 %d일} ({wd})</span><span>최종 업데이트 {now:%H:%M} KST</span></div>
<a class="logo" href="{up}index.html">{esc(CFG['site_name'])}</a>
<div class="tag">{esc(CFG['tagline'])}</div>
<nav>{nav}</nav></div></header>
<main class="wrap">{body}</main>
<footer class="wrap"><p>「{esc(CFG['site_name'])}」의 기사는 공개 보도의 헤드라인을 AI가 종합·재작성한 자동 브리핑입니다.
사실관계는 각 기사의 원문 링크에서 확인하세요. AI가 작성한 기사에는 오류가 있을 수 있습니다.</p></footer>
</body></html>"""


def card(a, depth, cls="card"):
    up = "../" * depth
    t = kst(a["published"])
    sm = f'<p class="sum">{esc(a["summary"])}</p>' if a.get("summary") else ""
    return (f'<article class="{cls}"><span class="sec">{esc(a["section"])}</span>'
            f'<h3><a href="{up}a/{a["id"]}.html">{esc(a["headline"])}</a></h3>{sm}'
            f'<span class="time">{t:%m.%d %H:%M}{" · " + esc(a["source"]) if a["source"] else ""}</span></article>')


def render(archive):
    if OUT.exists():
        shutil.rmtree(OUT)
    (OUT / "a").mkdir(parents=True); (OUT / "section").mkdir()
    shutil.copy(ROOT / "templates" / "style.css", OUT / "style.css")
    (OUT / ".nojekyll").write_text("")
    arts = sorted(archive, key=lambda a: a["published"], reverse=True)

    # 1면
    if arts:
        lead, rest = arts[0], arts[1:]
        body = f'<section class="lead">{card(lead, 0, "card big")}<div class="side">'
        body += "".join(card(a, 0, "card small") for a in rest[:4]) + "</div></section>"
        for s in CFG["sections"]:
            items = [a for a in arts if a["section"] == s][:6]
            if items:
                body += (f'<section class="block"><h2><a href="section/{SLUGS[s]}.html">{esc(s)}</a></h2>'
                         f'<div class="grid">{"".join(card(a, 0) for a in items)}</div></section>')
    else:
        body = "<p>아직 기사가 없습니다.</p>"
    (OUT / "index.html").write_text(page(CFG["site_name"], body), encoding="utf-8")

    # 섹션
    for s in CFG["sections"]:
        items = [a for a in arts if a["section"] == s]
        b = f'<h1 class="ptitle">{esc(s)}</h1><div class="list">' + \
            ("".join(card(a, 1, "card row") for a in items) or "<p>기사가 없습니다.</p>") + "</div>"
        (OUT / "section" / f"{SLUGS[s]}.html").write_text(page(f"{s} - {CFG['site_name']}", b, 1), encoding="utf-8")

    # 기사
    for a in arts:
        paras = "".join(f"<p>{esc(p)}</p>" for p in a["body"].split("\n\n") if p.strip())
        tags = "".join(f'<span class="tg">#{esc(t)}</span>' for t in a.get("tags", []))
        more = [x for x in arts if x["section"] == a["section"] and x["id"] != a["id"]][:4]
        badge = "AI 작성" if a.get("ai") else "자동 수집"
        b = (f'<article class="story"><a class="sec" href="../section/{SLUGS[a["section"]]}.html">{esc(a["section"])}</a>'
             f'<h1>{esc(a["headline"])}</h1>'
             + (f'<p class="dek">{esc(a["summary"])}</p>' if a.get("summary") else "") +
             f'<div class="byline"><span class="badge">{badge}</span> {kst(a["published"]):%Y.%m.%d %H:%M} KST</div>'
             f'<div class="text">{paras}</div><div class="tags">{tags}</div>'
             f'<div class="src">원문: <a href="{esc(a["source_url"])}" rel="noopener nofollow" target="_blank">'
             f'{esc(a["orig_title"])}{" — " + esc(a["source"]) if a["source"] else ""}</a></div></article>'
             + (f'<section class="block"><h2>{esc(a["section"])} 다른 기사</h2><div class="grid">'
                f'{"".join(card(x, 1) for x in more)}</div></section>' if more else ""))
        (OUT / "a" / f"{a['id']}.html").write_text(page(f"{a['headline']} - {CFG['site_name']}", b, 1, a.get("summary", "")),
                                                    encoding="utf-8")

    # RSS
    base = CFG.get("base_url", "").rstrip("/")
    items = "".join(
        f"<item><title>{esc(a['headline'])}</title><link>{base}/a/{a['id']}.html</link>"
        f"<guid>{a['id']}</guid><pubDate>{email.utils.format_datetime(kst(a['published']))}</pubDate>"
        f"<description>{esc(a.get('summary') or a['headline'])}</description></item>" for a in arts[:50])
    (OUT / "feed.xml").write_text(
        f'<?xml version="1.0" encoding="UTF-8"?><rss version="2.0"><channel><title>{esc(CFG["site_name"])}</title>'
        f'<link>{base}/</link><description>{esc(CFG["tagline"])}</description>{items}</channel></rss>', encoding="utf-8")
    print(f"[렌더링] 기사 {len(arts)}건 → {OUT}")


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
        if new:
            use_ai = "--free" not in sys.argv and os.environ.get("ANTHROPIC_API_KEY")
            if use_ai:
                try:
                    new = write_ai(new)
                except Exception as e:
                    print(f"[경고] AI 작성 실패 → 무료 모드: {e}")
                    new = write_free(new)
            else:
                print("[모드] 무료 모드 (ANTHROPIC_API_KEY 없음 또는 --free)")
                new = write_free(new)
            archive = sorted(new + archive, key=lambda a: a["published"], reverse=True)[:CFG["max_archive"]]
            DATA.write_text(json.dumps(archive, ensure_ascii=False, indent=1), encoding="utf-8")
    render(archive)


if __name__ == "__main__":
    main()
