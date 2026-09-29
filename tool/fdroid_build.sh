#!/usr/bin/env bash
# Mirrors the F-Droid metadata build recipe for local verification.
# Usage: ./tool/fdroid_build.sh link|kids [arm|arm64|x64|all]
# Default ABI: arm64 (matches the primary phone APK).
set -euo pipefail

APP="${1:-}"
ABI="${2:-arm64}"
if [[ "$APP" != "link" && "$APP" != "kids" ]]; then
  echo "Usage: $0 link|kids [arm|arm64|x64|all]" >&2
  exit 1
fi

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

EXPECTED_FLUTTER="$(tr -d '\r\n' < .flutter-version)"
ACTUAL="$(flutter --version 2>/dev/null | sed -n '1s/^Flutter \([^ ]*\).*/\1/p')"
if [[ "$ACTUAL" != "$EXPECTED_FLUTTER" ]]; then
  echo "Flutter $EXPECTED_FLUTTER required (found ${ACTUAL:-unknown}). Pin with FVM or flutter version." >&2
  exit 1
fi

dart pub global activate melos
# Same as F-Droid prebuild; `dart pub global run` avoids PATH issues on Windows Git Bash.
dart pub global run melos bootstrap

PUBSPEC="apps/$APP/pubspec.yaml"
if [[ ! -f "$PUBSPEC" ]]; then
  echo "Missing $PUBSPEC" >&2
  exit 1
fi
# version: 0.4.2+12 → build-name; F-Droid uses ABI-specific versionCodes (121/122/123).
VERSION_LINE="$(grep -E '^version:' "$PUBSPEC" | head -1 | sed 's/^version:[[:space:]]*//')"
if [[ ! "$VERSION_LINE" =~ ^([^+]+)\+([0-9]+)$ ]]; then
  echo "Could not parse version from $PUBSPEC (got: ${VERSION_LINE:-empty})" >&2
  exit 1
fi
BUILD_NAME="${BASH_REMATCH[1]}"
BASE_CODE="${BASH_REMATCH[2]}"

build_one() {
  local platform="$1"
  local vercode="$2"
  local out_name="$3"
  (
    cd "apps/$APP"
    flutter build apk --release --split-per-abi --target-platform="$platform" \
      --build-name="$BUILD_NAME" --build-number="$vercode"
  )
  echo "APK: apps/$APP/build/app/outputs/flutter-apk/$out_name"
}

case "$ABI" in
  arm)
    build_one android-arm "$((BASE_CODE * 10 + 1))" app-armeabi-v7a-release.apk
    ;;
  arm64)
    build_one android-arm64 "$((BASE_CODE * 10 + 2))" app-arm64-v8a-release.apk
    ;;
  x64)
    build_one android-x64 "$((BASE_CODE * 10 + 3))" app-x86_64-release.apk
    ;;
  all)
    build_one android-arm "$((BASE_CODE * 10 + 1))" app-armeabi-v7a-release.apk
    build_one android-arm64 "$((BASE_CODE * 10 + 2))" app-arm64-v8a-release.apk
    build_one android-x64 "$((BASE_CODE * 10 + 3))" app-x86_64-release.apk
    ;;
  *)
    echo "Unknown ABI '$ABI' (use arm|arm64|x64|all)" >&2
    exit 1
    ;;
esac
