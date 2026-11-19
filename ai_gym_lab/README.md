# AI GYM LAB — 운동과학 기반 개인 맞춤형 AI 헬스 트레이너

헬스장에서 앱을 열면 **오늘 할 운동·중량·반복·세트**를 바로 확인하고 기록할 수 있으며,
기록이 쌓일수록 **다음 운동이 자동으로 조정**되는 Flutter 앱(Android / iOS)입니다.

- 핵심 운동 처방(프로그램 생성, 중량·반복·세트 조정)은 **검증 가능한 규칙 기반 엔진**이 담당합니다.
- AI 언어모델은 설명·질의응답·프로그램 변경 *제안*에만 쓰이며, 변경은 **사용자가 승인해야** 적용됩니다.
- **인터넷·AI 없이도** 기록, 자동 중량 추천, 통계, 오프라인 트레이너가 모두 동작합니다.
- 모든 데이터는 기기 로컬 SQLite(Drift)에 저장되며 앱을 종료해도 유지됩니다.

## 실행 / 빌드

```bash
flutter pub get
dart run build_runner build      # Drift 코드 생성 (database.g.dart는 커밋되어 있어 생략 가능)
flutter test                     # 엔진·저장소·위젯 테스트 47개
flutter run                      # 기기/에뮬레이터 실행
flutter build apk --release      # build/app/outputs/flutter-apk/app-release.apk
```

검증 환경: Flutter 3.50.0 / Dart 3.14. 이 버전에서 Material 위젯은 `package:material_ui`로 분리되어 있어 앱 코드도 이를 사용합니다.
릴리스 APK는 현재 디버그 키로 서명됩니다. 스토어 배포 전 `android/app/build.gradle.kts`에 서명 설정을 추가하세요.

## 기술 스택

| 영역 | 사용 |
|---|---|
| UI | Flutter + Dart (`material_ui`), 다크모드 기본 |
| 상태 관리 | Riverpod 3 |
| 로컬 DB | SQLite + Drift (`drift_flutter`) |
| 그래프 | fl_chart |
| 알림/진동 | flutter_local_notifications + timezone, HapticFeedback |
| AI | 추상화된 제공자 계층: 오프라인(규칙) / 백엔드 프록시 / Anthropic / OpenAI 호환 |

## 프로젝트 구조

```
lib/
├─ domain/                    # 순수 Dart 비즈니스 로직 (Flutter·DB 의존 없음 → 독립 테스트)
│  ├─ models.dart             # 도메인 타입 (프로필, 운동, 프로그램 계획, 세트 기록 …)
│  ├─ catalog/
│  │  ├─ exercise_catalog.dart  # 운동 160개 시드 (근육·기구·패턴·난이도·자세·실수·주의·관절부담·대체)
│  │  └─ research.dart          # 연구 근거 23건 (연도·유형·대상·결과·한계·앱 적용)
│  └─ engines/
│     ├─ program_generator.dart   # ① 프로그램 생성
│     ├─ volume_engine.dart       # ② 근육별 주간 운동량 (+ 주간 세트 목표)
│     ├─ progression_engine.dart  # ③ 점진적 과부하 (Double Progression + RIR + 안전장치)
│     ├─ substitution_engine.dart # ④ 운동 대체 추천
│     ├─ recovery_engine.dart     # ⑤ 회복 상태 분석
│     ├─ schedule_engine.dart     # ⑥ 일정 재조정 (순환 방식)
│     ├─ stats_engine.dart        # ⑦ 통계·정체 분석 (추정 1RM, 주간 리뷰)
│     └─ program_modifier.dart    # AI/트레이너 변경 제안 → 승인 시 적용
├─ data/
│  ├─ db/database.dart        # Drift 스키마 (22개 테이블)
│  └─ repository.dart         # DB ↔ 도메인 변환, 세션 저장/복원, 내보내기/삭제
├─ ai/
│  ├─ ai_providers.dart       # AiProvider 인터페이스 + Anthropic / OpenAI / 백엔드 프록시
│  └─ trainer_service.dart    # 컨텍스트 구성, 오프라인 트레이너, 제안 파싱·승인 적용, 사용량 제한
├─ app/                       # 테마, Provider, 공통 위젯, 휴식 타이머/알림
└─ features/                  # 화면 (온보딩, 홈, 운동, 세션 기록, 기록, 통계, AI 트레이너, 설정 …)
test/
├─ engines_test.dart          # 엔진 단위 테스트 (37개)
├─ repository_test.dart       # 실제 SQLite 파일로 저장·복원·중복방지·대체·내보내기 (6개)
├─ app_smoke_test.dart        # 앱 부팅 → 오늘의 운동 시작 → 세트 완료 → 휴식 타이머 (2개)
└─ ui_tour_test.dart          # 360pt 폭에서 전체 탭·온보딩·AI 제안 승인 흐름 (2개)
```

## 화면

하단 메뉴 **홈 | 운동 | 기록 | 통계 | AI 트레이너**

1. 시작 화면 → 2. 기본 정보 → 3. 운동 목표(복수 선택 + 우선순위) → 경험 → 운동 가능 시간 → 환경·기구 → 신체 상태(부위·강도·발생 시점)
4. 운동 프로그램 추천(근육별 주간 세트, **구성 이유: 연구 근거 / 앱 기본값 구분 표시**) → 그대로 시작 또는 직접 수정
5. 주간 운동 일정(운동 탭) · 6. 오늘의 운동(홈: 운동별 오늘 추천 미리보기, 예상 시간, 주간 진행, 최근 성과)
7. 실시간 운동 기록: 지난 기록 / 오늘 추천(+ "왜?" 근거) / 세트별 중량·반복·RIR 큰 +/- 버튼 / 완료 시 휴식 타이머 자동 시작 / 통증·자세 불안정 표시 / 세트 추가·삭제
8. 운동 상세(자세·흔한 실수·주의·관절 부담·대체 운동·관련 연구) · 9. 운동 대체 선택
10. 통계(8종 그래프 + 최근 4주 분석) · 11. 신체 변화 기록 · 12. AI 트레이너 · 13. 설정(프로필, 증가 단위, AI 연결·사용량 제한, 연구 라이브러리, 내보내기, 전체 삭제)

## 데이터베이스 (Drift / SQLite)

요구된 18개 테이블 + 운영 테이블 4개.

| 테이블 | 내용 |
|---|---|
| `users` | 로컬 사용자 (향후 계정/동기화 대비 user_id 유지) |
| `user_profiles` | 성별·나이·키·체중·목표 체중·체지방·골격근·경험·주당 일수·1회 시간·환경 |
| `user_goals` | 목표 + 우선순위 |
| `user_equipment` | 사용 가능 기구 |
| `user_limitations` | 통증 부위·강도(0~10)·발생 시점·메모 |
| `exercises` / `exercise_muscles` / `exercise_alternatives` | 운동 DB (주요/보조 근육, 대체 운동 순위) |
| `workout_programs` / `workout_days` / `workout_exercises` | 프로그램(source: `ai` \| `user`, 원본 보존), 운동일(순서·선호 요일), 처방 |
| `workout_sessions` | 세션 (`in_progress` \| `completed`), 준비 상태 점수 |
| `workout_session_exercises` | 세션 내 운동 (대체 원본, 통증/자세 플래그, 당일 추천 링크) |
| `workout_sets` | 세트 (target/actual weight·reps, RIR, completed, completed_at). **UNIQUE(session_exercise_id, set_number)** 로 중복 저장 방지 |
| `body_measurements` | 체중·체지방·골격근·허리둘레 |
| `recovery_logs` | 수면·피로·근육통·의욕·관절 통증·점수 |
| `progression_recommendations` | 이전/추천 중량, 추천 반복·세트, 액션, 이유(JSON), 신뢰도, accepted |
| `ai_recommendations` | AI/트레이너 변경 제안 (pending / accepted / rejected) |
| `research_references` | 연구 근거 |
| `app_settings`, `chat_messages`, `ai_usage_logs` | 설정, 대화, AI 사용량(일일 한도) |

**앱 종료 후 복원**: 세션 시작 시 모든 세트가 추천값으로 미리 채워져 저장되고, 이후 모든 입력이 즉시 DB에 기록됩니다. 휴식 타이머도 종료 시각을 저장해 재실행 시 이어집니다.

## 핵심 알고리즘

### 점진적 과부하 (progression_engine.dart)

| 실제 결과 (목표 3세트 × 6~8회, 40kg) | 다음 추천 |
|---|---|
| 기록 없음 | 중량을 단정하지 않음 → "기준 중량 찾기" (RIR 2~3) |
| 8/8/8, RIR ≥ 1 | **42.5kg** 도전, 반복은 하단(6회)부터 |
| 8/8/8, 어떤 세트가 RIR 0 | 40kg 유지 (여유 있게 달성하면 증가) |
| 8/8/7 | 40kg 유지 + 미달 세트 반복 +1 |
| 7/6/5 (1회 미달) | 40kg 유지, 피로·난이도 확인 (회복 낮으면 세트 −1) |
| 2회 연속 미달 / 큰 폭 미달 | 약 5~10% 감량 |
| 8/8/8 + 통증 | 증가 보류 (2회 연속이면 감량 + 대체 권장) |
| 자세 불안정 / 세트 미완료 | 유지 |
| 14일↑ 공백 / 28일↑ 공백 | 약 10% / 20% 감량해 복귀 강도 재평가 |
| 오늘 회복 상태 낮음 | 증가 보류 |

- 증가 단위는 기구별(바벨 2.5, 덤벨 2, 머신 5kg 등) 기본값이며 설정에서 변경 가능. 감량은 단위로 내림.
- 어시스트 운동은 보조 중량 감소가 진행. 맨몸·시간 운동은 반복/시간 증가.
- 한 번에 1단계만 증가하며, 증가 폭이 현재 중량의 15%를 넘으면 신뢰도를 낮추고 안내.
- 대체 운동으로 바꾸면 기존 중량을 쓰지 않고 해당 운동의 기록(없으면 기준 찾기)으로 재계산.

### 프로그램 생성 (program_generator.dart)
주 2일 전신×2 · 3일 전신×3 · 4일 상/하체(요구사항의 기본 템플릿) · 5일 상/하체+전신 · 6일 PPL×2.
초보자(3개월 미만)는 주 4일 이하로 시작. 기구 없음·숙련도 초과·통증 부위 부담 운동은 대체 엔진으로 교체 →
목표별 반복/휴식/RIR 조정 → 근육별 주간 직접 세트를 경험별 시작 범위로 조정 → 1회 운동 시간에 맞춰 세트/운동 수 축소.

### 근거 표시 원칙
모든 근거는 `연구 근거` / `앱 기본값(개발자 실용 권장값)` / `내 운동 기록`으로 구분해 표시합니다.
간접 세트 가중치(0.5), 회복 점수, 공백 감량 비율, 초보자 세트 범위 등은 **연구로 확정된 값이 아닌 앱 기본값**이며 화면에도 그렇게 표기합니다.
연구 요약은 개발팀 요약이며 원문 확인을 권장합니다(`lib/domain/catalog/research.dart`).

## AI 트레이너

- 제공자: **오프라인(기본, 규칙 기반)** / 백엔드 프록시(배포 권장) / Anthropic Messages API(기본 모델 `claude-opus-5-5`, 거절 시 서버 측 fallback 사용) / OpenAI 호환.
- 컨텍스트: 프로필, 현재 프로그램, **엔진 추천값**, 최근 기록, 주간 근육별 세트. 시스템 프롬프트로 진단 금지·무리한 증량 금지·제공된 연구만 인용·변경 시 이유 설명을 지시합니다.
- 변경 제안은 ```` ```gymlab-action {json}``` ```` 블록으로 받아 검증 후 카드로 표시하고 **[적용]을 눌러야** 반영됩니다.
  지원: `set_session_minutes`, `replace_exercise`, `set_days_per_week`, `adjust_sets`. AI 원본 프로그램은 보존되고 수정본이 저장됩니다.
- API 실패·미설정·일일 한도 초과 시 자동으로 오프라인 트레이너가 답변합니다.

### 보안
- API 키는 소스코드에 없습니다. 개발/개인용으로 설정에서 입력하면 기기 로컬 DB에만 저장되며 내보내기에서 제외됩니다.
- 배포 시에는 키를 서버에 두는 **백엔드 프록시** 모드를 사용하세요. 계약:
  `POST {url}` `{"system": "...", "messages": [{"role","content"}], "model": "..."}` → `200 {"text": "...", "model": "...", "usage": {"input_tokens", "output_tokens"}}`.
  서버에서 사용자 인증과 요금/사용량 제한을 함께 처리하세요.
- 데이터 내보내기(JSON 파일 + 클립보드)와 전체 삭제를 제공합니다.

## 알려진 한계
- 운동 사진: [Free Exercise DB](https://github.com/yuhonas/free-exercise-db)(퍼블릭 도메인, Unlicense)의 시작/끝 자세 사진을 160개 중 148개 운동에 넣었습니다(`assets/exercises/`, 약 6MB, 오프라인 사용).
  같은 운동 사진이 없는 일부는 비슷한 동작 사진을 쓰고 화면에 "유사 동작 사진"으로 표시하며, 사진이 없는 12개 운동(랜드마인 프레스, 펜듈럼/벨트 스쿼트, 밴드 운동 일부 등)은 기구 아이콘으로 표시합니다.
  매칭 목록: `lib/domain/catalog/exercise_photos.dart`. 운동 영상은 넣지 않았습니다.
- 자세·흔한 실수 설명은 주요 운동은 개별 작성, 나머지는 움직임 패턴 공통 안내입니다.
- Android 13+에서는 정확한 알람 권한을 요청하지 않으므로 백그라운드 휴식 알림이 OS에 의해 다소 늦을 수 있습니다(앱이 화면에 있을 때는 정확히 진동/알림).
- iOS는 코드상 지원하지만 이 저장소에서는 Android APK만 빌드·검증했습니다(iOS 빌드는 macOS/Xcode 필요).
- 4단계(성과 예측, 클라우드 동기화, 웨어러블 연동)는 미구현입니다. user_id·제공자 추상화로 확장 지점을 마련해 두었습니다.
