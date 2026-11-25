#!/bin/zsh
# AI GYM LAB 안드로이드 배포 스크립트
# 사용법: tool/release.sh <바뀐-내용.md>
#   1) pubspec.yaml 의 version 을 먼저 올리고 커밋·푸시해 둘 것
#   2) 테스트 → APK 빌드 → 서명 확인 → GitHub 릴리스(gym-v버전) 생성
# 폰의 앱은 켤 때 이 릴리스를 보고 「새 버전이 있어요」를 띄웁니다.
set -euo pipefail

NOTES_FILE=${1:?바뀐 내용을 적은 마크다운 파일을 지정하세요 (## 바뀐 것 섹션 포함)}
cd "$(dirname "$0")/.."
export PATH="$HOME/development/flutter/bin:$HOME/development/gh/bin:$PATH"
export JAVA_HOME="$HOME/development/jdk/Contents/Home"
APKSIGNER="$HOME/Library/Android/sdk/build-tools/36.0.0/apksigner"
# 폰에 설치된 앱과 같은 서명이어야 덮어 설치(업데이트)됩니다. 이 값이 바뀌면 배포 중단.
EXPECTED_CERT=44ec832486d95995463ccce055632760498a39a783790c89313e1c0199dfd990
REPO=thdnd456-maker/ai-daily
BRANCH=claude/ai-gym-lab-health-app-7razs0

VERSION=$(grep '^version:' pubspec.yaml | sed 's/version: *//; s/+.*//')
TAG="gym-v$VERSION"
echo "▶ 배포 버전: $VERSION ($TAG)"

if gh release view "$TAG" --repo "$REPO" >/dev/null 2>&1; then
  echo "✗ $TAG 릴리스가 이미 있습니다. pubspec.yaml 버전을 올리세요."; exit 1
fi
if [ -n "$(git status --porcelain -- .)" ]; then
  echo "✗ 커밋하지 않은 변경이 있습니다. 먼저 커밋·푸시하세요."; exit 1
fi
git fetch -q origin "$BRANCH"
if [ "$(git rev-parse HEAD)" != "$(git rev-parse "origin/$BRANCH")" ]; then
  echo "✗ GitHub에 푸시되지 않았습니다. 먼저 git push 하세요."; exit 1
fi

echo "▶ 테스트"
flutter test --reporter=expanded | tail -1
flutter analyze | tail -1

echo "▶ APK 빌드"
flutter build apk --release --split-per-abi | grep -E '✓.*arm64'
OUT="$(cd ../.. && pwd)/AI_GYM_LAB_v$VERSION.apk"
cp build/app/outputs/flutter-apk/app-arm64-v8a-release.apk "$OUT"
# 용량 절약: 폴더에는 최신 설치 파일 하나만 두고, 옛 버전은 휴지통으로 (GitHub에는 모두 남아 있음)
for old in "$(dirname "$OUT")"/AI_GYM_LAB_v*.apk; do
  [ "$old" != "$OUT" ] && [ -f "$old" ] && mv "$old" ~/.Trash/ && echo "  옛 설치 파일 휴지통으로: $(basename "$old")"
done

CERT=$("$APKSIGNER" verify --print-certs "$OUT" | sed -n 's/.*SHA-256 digest: //p' | head -1)
if [ "$CERT" != "$EXPECTED_CERT" ]; then
  echo "✗ 서명이 다릅니다($CERT). 이대로 올리면 폰에서 업데이트가 안 됩니다."; exit 1
fi
echo "✓ 서명 일치"

TMP=$(mktemp -d)
cp "$OUT" "$TMP/AI_GYM_LAB_v$VERSION.apk"
gh release create "$TAG" "$TMP/AI_GYM_LAB_v$VERSION.apk" --repo "$REPO" --target "$BRANCH" \
  --title "AI GYM LAB v$VERSION (안드로이드)" --latest=false --notes-file "$NOTES_FILE"
rm -rf "$TMP"

URL="https://github.com/$REPO/releases/download/$TAG/AI_GYM_LAB_v$VERSION.apk"
SIZE=$(curl -sL -o /dev/null -w '%{http_code} %{size_download}' "$URL")
echo "✓ 배포 완료: $URL ($SIZE)"
