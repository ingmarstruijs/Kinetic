#!/usr/bin/env bash
# Mirrors the F-Droid metadata build recipe for local verification.
# Usage: ./tool/fdroid_build.sh link|kids
set -euo pipefail

APP="${1:-}"
if [[ "$APP" != "link" && "$APP" != "kids" ]]; then
  echo "Usage: $0 link|kids" >&2
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
# version: 0.3.8+7 → build-name / build-number (matches metadata CurrentVersion*)
VERSION_LINE="$(grep -E '^version:' "$PUBSPEC" | head -1 | sed 's/^version:[[:space:]]*//')"
if [[ ! "$VERSION_LINE" =~ ^([^+]+)\+([0-9]+)$ ]]; then
  echo "Could not parse version from $PUBSPEC (got: ${VERSION_LINE:-empty})" >&2
  exit 1
fi
BUILD_NAME="${BASH_REMATCH[1]}"
BUILD_NUMBER="${BASH_REMATCH[2]}"

cd "apps/$APP"
flutter build apk --release --build-name="$BUILD_NAME" --build-number="$BUILD_NUMBER"

echo "APK: apps/$APP/build/app/outputs/flutter-apk/app-release.apk"
