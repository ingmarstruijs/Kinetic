#!/usr/bin/env bash
# Sync Fastlane store changelogs from each app's CHANGELOG.md ### Store section.
#
# Usage:
#   ./tool/sync_fastlane_changelogs.sh              # both apps (current pubspec)
#   ./tool/sync_fastlane_changelogs.sh link|kids    # one app
#   ./tool/sync_fastlane_changelogs.sh --check      # verify committed files match (CI)
#   ./tool/sync_fastlane_changelogs.sh --version X.Y.Z --code N [link|kids]
#       Backfill Fastlane files for a historical release.
#   ./tool/sync_fastlane_changelogs.sh --extract-section APP VERSION
#       Print the full ## [VERSION] block from apps/APP/CHANGELOG.md (for release notes).
#
# For pubspec version X.Y.Z+N writes the Store text to:
#   changelogs/N.txt
#   # F-Droid / Gradle ABI split: versionCode = N*10 + abiSlot
#   # abiSlot: armeabi-v7a=1, arm64-v8a=2, x86_64=3
#   changelogs/$((N*10 + 1)).txt  # armeabi-v7a
#   changelogs/$((N*10 + 2)).txt  # arm64-v8a
#   changelogs/$((N*10 + 3)).txt  # x86_64
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

CHECK=0
EXTRACT_APP=""
EXTRACT_VERSION=""
FORCE_VERSION=""
FORCE_CODE=""
APPS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --check) CHECK=1; shift ;;
    --version) FORCE_VERSION="${2:-}"; shift 2 ;;
    --code) FORCE_CODE="${2:-}"; shift 2 ;;
    --extract-section)
      EXTRACT_APP="${2:-}"
      EXTRACT_VERSION="${3:-}"
      shift 3 || true
      ;;
    link|kids) APPS+=("$1"); shift ;;
    -h|--help)
      sed -n '2,18p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *)
      echo "Usage: $0 [--check] [link|kids]" >&2
      echo "       $0 --version X.Y.Z --code N [link|kids]  # backfill one release" >&2
      echo "       $0 --extract-section link|kids VERSION" >&2
      exit 1
      ;;
  esac
done

if [[ -n "$FORCE_VERSION" || -n "$FORCE_CODE" ]]; then
  if [[ -z "$FORCE_VERSION" || -z "$FORCE_CODE" ]]; then
    echo "--version and --code must be used together" >&2
    exit 1
  fi
fi

# Print body of ## [version] ... until next ## [ (exclusive).
changelog_section() {
  local changelog="$1"
  local version="$2"
  awk -v ver="$version" '
    BEGIN { hdr = "## [" ver "]" }
    index($0, hdr) == 1 && $0 ~ /^## \[/ { grab=1; print; next }
    grab && /^## \[/ { exit }
    grab { print }
  ' "$changelog"
}

# Print ### Store body within a section (stdin = section).
store_body() {
  awk '
    /^### Store/ { grab=1; next }
    grab && /^### / { exit }
    grab { print }
  ' | sed -e 's/[[:space:]]*$//' | awk '
    NF { seen=1 }
    seen { lines[++n]=$0 }
    END {
      # trim trailing blank lines
      while (n > 0 && lines[n] == "") n--
      if (n < 1) exit 1
      for (i = 1; i <= n; i++) print lines[i]
    }
  '
}

extract_store() {
  local changelog="$1"
  local version="$2"
  local section store
  section="$(changelog_section "$changelog" "$version")"
  if [[ -z "$section" ]]; then
    echo "Missing ## [$version] in $changelog" >&2
    return 1
  fi
  if ! store="$(printf '%s\n' "$section" | store_body)"; then
    echo "Missing or empty ### Store under ## [$version] in $changelog" >&2
    return 1
  fi
  store="${store}"$'\n'
  local bytes
  bytes="$(printf '%s' "$store" | wc -c | tr -d ' ')"
  if [[ "$bytes" -gt 500 ]]; then
    echo "### Store under ## [$version] in $changelog exceeds 500 bytes ($bytes)" >&2
    return 1
  fi
  printf '%s' "$store"
}

if [[ -n "$EXTRACT_APP" ]]; then
  if [[ "$EXTRACT_APP" != "link" && "$EXTRACT_APP" != "kids" ]]; then
    echo "APP must be link or kids" >&2
    exit 1
  fi
  if [[ -z "$EXTRACT_VERSION" ]]; then
    echo "VERSION required with --extract-section" >&2
    exit 1
  fi
  changelog="apps/$EXTRACT_APP/CHANGELOG.md"
  section="$(changelog_section "$changelog" "$EXTRACT_VERSION")"
  if [[ -z "$section" ]]; then
    echo "Missing ## [$EXTRACT_VERSION] in $changelog" >&2
    exit 1
  fi
  if ! printf '%s\n' "$section" | grep -q '^### Store'; then
    echo "Missing ### Store under ## [$EXTRACT_VERSION] in $changelog" >&2
    exit 1
  fi
  printf '%s\n' "$section"
  exit 0
fi

if [[ ${#APPS[@]} -eq 0 ]]; then
  APPS=(link kids)
fi

sync_app() {
  local app="$1"
  local pubspec="apps/$app/pubspec.yaml"
  local changelog="apps/$app/CHANGELOG.md"
  local out_dir="apps/$app/fastlane/metadata/android/en-US/changelogs"

  if [[ ! -f "$pubspec" ]]; then
    echo "Missing $pubspec" >&2
    return 1
  fi
  if [[ ! -f "$changelog" ]]; then
    echo "Missing $changelog" >&2
    return 1
  fi

  local version base
  if [[ -n "$FORCE_VERSION" ]]; then
    version="$FORCE_VERSION"
    base="$FORCE_CODE"
  else
    local version_line
    version_line="$(grep -E '^version:' "$pubspec" | head -1 | sed 's/^version:[[:space:]]*//')"
    if [[ ! "$version_line" =~ ^([^+]+)\+([0-9]+)$ ]]; then
      echo "Could not parse version from $pubspec (got: ${version_line:-empty})" >&2
      return 1
    fi
    version="${BASH_REMATCH[1]}"
    base="${BASH_REMATCH[2]}"
  fi

  local store
  store="$(extract_store "$changelog" "$version")"

  mkdir -p "$out_dir"
  # Base pubspec code + F-Droid ABI versionCodes (see header).
  local codes=(
    "$base"
    "$((base * 10 + 1))"
    "$((base * 10 + 2))"
    "$((base * 10 + 3))"
  )
  local dirty=0
  local code dest
  for code in "${codes[@]}"; do
    dest="$out_dir/$code.txt"
    if [[ "$CHECK" -eq 1 ]]; then
      if [[ ! -f "$dest" ]]; then
        echo "::error::Missing $dest (run ./tool/sync_fastlane_changelogs.sh)"
        dirty=1
        continue
      fi
      if ! printf '%s' "$store" | cmp -s - "$dest"; then
        echo "::error::$dest does not match ### Store in $changelog for $version"
        dirty=1
      fi
    else
      printf '%s' "$store" > "$dest"
      echo "Wrote $dest"
    fi
  done
  return "$dirty"
}

failed=0
for app in "${APPS[@]}"; do
  if ! sync_app "$app"; then
    failed=1
  fi
done

if [[ "$CHECK" -eq 1 && "$failed" -ne 0 ]]; then
  echo "Fastlane changelogs out of sync. Run ./tool/sync_fastlane_changelogs.sh and commit." >&2
  exit 1
fi

if [[ "$failed" -ne 0 ]]; then
  exit 1
fi

if [[ "$CHECK" -eq 1 ]]; then
  echo "Fastlane changelogs match CHANGELOG ### Store."
fi
