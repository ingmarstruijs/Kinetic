#!/usr/bin/env bash
# Copy F-Droid graphics into Fastlane paths (run from repo root).
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"

copy_app() {
  local app="$1"
  local src="$root/metadata/net.moonbaseone.kinetic.${app}/en-US/images"
  local dst="$root/apps/${app}/fastlane/metadata/android/en-US/images"
  mkdir -p "$dst/icon" "$dst/phoneScreenshots"
  cp -f "$src/icon/icon.png" "$dst/icon/icon.png"
  cp -f "$src/phoneScreenshots/"*.png "$dst/phoneScreenshots/"
  echo "Copied Fastlane images for $app"
}

copy_app link
copy_app kids
