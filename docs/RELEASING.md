# Releasing Kinetic (for maintainers / agents)

`main` is protected: no direct pushes. Every version ships on **two
channels** that do not auto-sync:

| Channel | What publishes it | Signing |
| --- | --- | --- |
| **GitHub Releases** | Annotated `v*` tag whose commit is on `main` | Project keystore (CI) |
| **F-Droid** | Manual fdroiddata MR after the tag | F-Droid key (re-signed) |

Agents: follow this file end-to-end. Cursor rules:
[`.cursor/rules/releasing.mdc`](../.cursor/rules/releasing.mdc) and
[`.cursor/rules/fdroid-mr.mdc`](../.cursor/rules/fdroid-mr.mdc). F-Droid paste
kits and MR status:
[`metadata/FDROID_SUBMISSION.md`](../metadata/FDROID_SUBMISSION.md).

## Recurring failures (read before any release)

These have broken **multiple** releases. Treat them as hard gates.

### 1. Fastlane check fails on the GitHub `release` job

Symptom: Build jobs green; `release` fails with
`changelogs/N.txt does not match ### Store`.

Cause: Fastlane files not synced from `### Store`, or CRLF/LF mismatch, or
hand-edited changelog `.txt` files.

**Required:**

```bash
# Git Bash / WSL / Linux — after editing apps/*/CHANGELOG.md ### Store
./tool/sync_fastlane_changelogs.sh
./tool/sync_fastlane_changelogs.sh --check   # must exit 0 before tagging
```

- Do **not** hand-edit `apps/*/fastlane/.../changelogs/*.txt`
- Commit the generated `{N,N*10+1,N*10+2,N*10+3}.txt` files in the bump PR
- Keep `CHANGELOG.md` and Fastlane changelog files **LF** in git

### 2. F-Droid `fdroid rewritemeta` fails

Symptom: pipeline diff removes a blank line after `CurrentVersionCode`.

**Required:** each `metadata/*.yml` ends with the last key then **exactly one**
`\n`. No trailing blank line. LF only (no CRLF).

### 3. F-Droid `checkupdates` fails / wrong vercode

Symptom: `old=163, new=153` (or similar); CI checked out an older `v*-link`
tag.

Cause: recipes use `UpdateCheckMode: Tags ^v[0-9.]+-link$` / `-kids$`. Those
tags are created only when the GitHub **`release` job succeeds** (it publishes
`vX.Y.Z-link` and `vX.Y.Z-kids`). Pushing `vX.Y.Z` alone is not enough.

**Required:** wait until both app Releases exist on GitHub **before** pushing
bumped `CurrentVersionCode` to fdroiddata (or expect `checkupdates` red).

### 4. Do not update GitLab while GitHub release is red

Do not push fdroiddata, refresh MR descriptions, or tell reviewers “0.4.x is
ready” until the tag’s Build & Sign **`release`** job is green.

## Dual-channel checklist (every version)

1. **Bump PR** (`release/X.Y.Z`) → merge to `main` after CI
   - `apps/link/pubspec.yaml` + `apps/kids/pubspec.yaml` → `version: X.Y.Z+N`
   - Move `## [Unreleased]` notes into `## [X.Y.Z] - YYYY-MM-DD` in both
     [`apps/link/CHANGELOG.md`](../apps/link/CHANGELOG.md) and
     [`apps/kids/CHANGELOG.md`](../apps/kids/CHANGELOG.md) (include `### Store`)
   - Run `./tool/sync_fastlane_changelogs.sh` **and** `--check`; commit generated
     `apps/*/fastlane/.../changelogs/{N,N*10+1,N*10+2,N*10+3}.txt`
   - Keep `dependenciesInfo { includeInApk = false }` in both
     `android/app/build.gradle.kts` (F-Droid `check apk`)
   - Draft `metadata/*.yml` updates (version fields; `commit:` filled **after**
     tag; **no** trailing blank line at EOF)
2. **Tag** the merge commit on `main` → wait for Build & Sign **`release`** green
   (creates `vX.Y.Z-kids` + `vX.Y.Z-link` Releases)
3. Put the **full SHA** of `vX.Y.Z` into both `metadata/*.yml` `commit:` fields
   (never a bare tag name for F-Droid); confirm LF + single trailing newline
4. Verify recipe: `./tool/fdroid_build.sh link` and `./tool/fdroid_build.sh kids`
5. **fdroiddata MR(s)** — copy YAML only onto fork branches; see
   [`.cursor/rules/fdroid-mr.mdc`](../.cursor/rules/fdroid-mr.mdc). First listing
   still uses separate Link/Kids MRs (!50470 / !50471); later bumps can update
   both YAMLs in one update MR unless a maintainer asks otherwise.
6. Watch fork pipelines (`rewritemeta`, `checkupdates`, `fdroid build`) and
   [F-Droid build logs](https://f-droid.org/wiki/page/Build) after upstream merge

## Version bump → tag

1. Open a PR (`release/x.y.z`) that bumps:
   - `apps/link/pubspec.yaml` and `apps/kids/pubspec.yaml` (`version: X.Y.Z+N`)
   - Per-app changelogs: `apps/link/CHANGELOG.md` and `apps/kids/CHANGELOG.md`
     (`### Store` = Fastlane source; Added/Changed/Fixed for GitHub)
   - Run `./tool/sync_fastlane_changelogs.sh` (do not hand-edit Fastlane
     `changelogs/*.txt`); run `--check` before merge
   - `metadata/*.yml` (`versionName`, `versionCode`, `CurrentVersion*`; leave
     `commit:` as a placeholder until the tag exists, or update in a tiny
     follow-up commit on `main`)
2. Wait for required CI (`analyze-and-test`), merge to `main`.
3. Tag **that** merge commit:

```bash
git checkout main && git pull
git tag -a vX.Y.Z -m "Kinetic X.Y.Z"
git push origin vX.Y.Z
git rev-parse vX.Y.Z^{}   # full commit SHA → metadata commit: + fdroiddata
```

4. Wait for workflow **Build & Sign Flutter Apps** on `vX.Y.Z`:
   - `build-*-app` green is not enough
   - `release` must be green (runs `./tool/sync_fastlane_changelogs.sh --check`,
     then creates `vX.Y.Z-kids` and `vX.Y.Z-link`)

CI builds and signs both APKs on `main`/`develop`, any `v*` tag, or workflow
dispatch (see `.github/workflows/build-release.yml`). A `v*` tag **not** on
`main` builds APKs but does **not** create GitHub Releases.

## GitHub release artifacts

Each successful `release` job yields two releases:

- `vX.Y.Z-kids` — `kinetic-kids-X.Y.Z.apk`
- `vX.Y.Z-link` — `kinetic-link-X.Y.Z.apk`

Each includes `sha256.txt`. Release notes are the matching `## [X.Y.Z]` section
from that app’s `CHANGELOG.md`, plus checksum and signing fingerprint. The
release job fails if the section, `### Store`, or synced Fastlane files are
missing.

## F-Droid

Tagging does **not** update f-droid.org. After each **successful** GitHub
release:

1. Set `commit:` in repo `metadata/*.yml` to the full SHA of `vX.Y.Z`
2. Ensure YAML is LF and has no trailing blank line (rewritemeta)
3. Copy those YAMLs into your [fdroiddata](https://gitlab.com/fdroid/fdroiddata)
   fork (yml only — Fastlane/screenshots stay in this repo under
   `apps/*/fastlane/...`)
4. Open/update the GitLab MR(s); see
   [`metadata/FDROID_SUBMISSION.md`](../metadata/FDROID_SUBMISSION.md) and
   [`.cursor/rules/fdroid-mr.mdc`](../.cursor/rules/fdroid-mr.mdc)

Do not put store graphics in fdroiddata. Do not re-enable AGP
`dependenciesInfo` in APKs.

## Verify release APKs

Two different checks — do not mix them up.

### 1. File integrity (SHA-256 of the APK bytes)

Matches `sha256.txt` / release notes (lowercase hex, no colons):

```bash
sha256sum kinetic-link-X.Y.Z.apk
# or: echo "<digest>  kinetic-link-X.Y.Z.apk" | sha256sum --check
```

### 2. Signing certificate fingerprint

What AppVerifier shows (`AA:BB:CC:…`). Listed in the GitHub Release under
**Certificate Fingerprint.** F-Droid APKs use a **different** certificate.

```bash
keytool -printcert -jarfile kinetic-link-X.Y.Z.apk
# use the SHA256: line
```

## Local unsigned build

```bash
cd apps/link   # or apps/kids
flutter build apk --release
```

F-Droid-shaped local build (Melos + same flags as metadata):

```bash
./tool/fdroid_build.sh link
./tool/fdroid_build.sh kids
```
