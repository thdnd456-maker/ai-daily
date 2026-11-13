# 綜合日報 종합일보 — 자동 발행 AI 신문사

RSS 헤드라인 수집 → Claude가 브리핑 기사로 재작성 → 정적 사이트(`docs/`) → GitHub Pages 자동 발행.
설계 의도와 프롬프트는 [PROMPT.md](PROMPT.md), 기자 문체는 [prompts/editor.md](prompts/editor.md)에 있습니다.

## 로컬 실행
```
py newsroom.py --free      # 무료 모드 (AI 호출 없음)
py newsroom.py             # ANTHROPIC_API_KEY 환경변수가 있으면 AI 모드
py -m http.server 8765 -d docs   # http://localhost:8765 에서 확인
```

## 배포 (GitHub Pages, 무료)
1. GitHub에 저장소를 만들고 이 폴더를 push
2. Settings → Secrets and variables → Actions → `ANTHROPIC_API_KEY` 등록 (없으면 무료 모드로 계속 발행)
3. Settings → Pages → Source: *Deploy from a branch*, Branch: `main` / `/docs`
4. Actions 탭 → "신문 발행" → Run workflow (이후 2시간마다 자동)

## 비용 조절 (`config.json`)
| 항목 | 효과 |
|---|---|
| `model` | `claude-haiku-5-5`로 바꾸면 Opus 5.5 대비 토큰 단가가 약 1/40 |
| `max_new_per_run` | 1회 실행당 AI로 쓰는 기사 수 상한 |
| `effort` | `low` 유지 권장 |
| 워크플로 `cron` | 실행 간격 (2시간 → 하루 12회) |

실제 사용량과 추정 비용은 실행할 때마다 `data/usage.log`에 기록됩니다.

## 소스 선택 주의
기본 소스는 Google News 토픽 RSS(헤드라인 + 원문 링크)입니다. 연합뉴스 RSS는 "AI 학습 및 활용 금지"를 명시하고 있어 넣지 않았습니다.
피드를 추가할 때는 해당 매체의 이용 조건을 확인하세요.
