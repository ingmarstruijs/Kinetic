# Releasing Kinetic (for maintainers / agents)

`main` is protected: no direct pushes. Every version ships on **two
channels** that do not auto-sync:

| Channel | What publishes it | Signing |
| --- | --- | --- |
| **GitHub Releases** | Annotated `v*` tag whose commit is on `main` | Project keystore (CI) |
| **F-Droid** | Manual fdroiddata MR after the tag | F-Droid key (re-signed) |

Agents: follow this file end-to-end. F-Droid details live in
[`metadata/FDROID_SUBMISSION.md`](../metadata/FDROID_SUBMISSION.md).

## Dual-channel checklist (every version)

1. **Bump PR** (`release/X.Y.Z`) → merge to `main` after CI  
   - `apps/link/pubspec.yaml` + `apps/kids/pubspec.yaml` → `version: X.Y.Z+N`  
   - Move `## [Unreleased]` notes into `## [X.Y.Z] - YYYY-MM-DD` in both  
     [`apps/link/CHANGELOG.md`](../apps/link/CHANGELOG.md) and  
     [`apps/kids/CHANGELOG.md`](../apps/kids/CHANGELOG.md) (include `### Store`)  
   - Run `./tool/sync_fastlane_changelogs.sh` and commit generated  
     `apps/*/fastlane/.../changelogs/{N,N*10+1,N*10+2,N*10+3}.txt`  
   - Keep `dependenciesInfo { includeInApk = false }` in both
     `android/app/build.gradle.kts` (F-Droid `check apk`)  
   - Draft `metadata/*.yml` updates (version fields; `commit:` filled **after** tag)
2. **Tag** the merge commit on `main` → GitHub APKs appear automatically  
3. Put the **full SHA** of `vX.Y.Z` into both `metadata/*.yml` `commit:` fields
   (never a bare tag name for F-Droid)  
4. Verify recipe: `./tool/fdroid_build.sh link` and `./tool/fdroid_build.sh kids`  
5. **fdroiddata MR(s)** — update existing app YAMLs (new `Builds:` entry +
   `CurrentVersion*`). First listing required two “New app” MRs; later bumps
   can update both YAMLs in one update MR unless a maintainer asks otherwise.  
6. Watch [F-Droid build logs](https://f-droid.org/wiki/page/Build) after merge

## Version bump → tag

1. Open a PR (`release/x.y.z`) that bumps:
   - `apps/link/pubspec.yaml` and `apps/kids/pubspec.yaml` (`version: X.Y.Z+N`)
   - Per-app changelogs: `apps/link/CHANGELOG.md` and `apps/kids/CHANGELOG.md`
     (`### Store` = Fastlane source; Added/Changed/Fixed for GitHub)
   - Run `./tool/sync_fastlane_changelogs.sh` (do not hand-edit Fastlane
     `changelogs/*.txt`)
   - `metadata/*.yml` (`versionName`, `versionCode`, `CurrentVersion*`; leave
     `commit:` as a placeholder until the tag exists, or update in a tiny
     follow-up commit on `main`)
2. Wait for required CI (`analyze-and-test`), merge to `main`.
3. Tag **that** merge commit:

```bash
git checkout main && git pull
git tag -a vX.Y.Z -m "Kinetic X.Y.Z"
git push origin vX.Y.Z
git rev-parse vX.Y.Z   # full SHA → metadata commit: + fdroiddata
```

CI builds and signs both APKs on `main`/`develop`, any `v*` tag, or workflow
dispatch (see `.github/workflows/build-release.yml`). A `v*` tag **not** on
`main` builds APKs but does **not** create GitHub Releases.

## GitHub release artifacts

Each tag yields two releases:

- `vX.Y.Z-kids` — `kinetic-kids-X.Y.Z.apk`
- `vX.Y.Z-link` — `kinetic-link-X.Y.Z.apk`

Each includes `sha256.txt`. Release notes are the matching `## [X.Y.Z]` section
from that app’s `CHANGELOG.md`, plus checksum and signing fingerprint. The
release job fails if the section, `### Store`, or synced Fastlane files are
missing.

## F-Droid

Tagging does **not** update f-droid.org. After each tag:

1. Set `commit:` in repo `metadata/*.yml` to `git rev-parse vX.Y.Z`
2. Copy those YAMLs into your [fdroiddata](https://gitlab.com/fdroid/fdroiddata)
   fork (yml only — Fastlane/screenshots stay in this repo under
   `apps/*/fastlane/...`)
3. Open the GitLab MR(s); see [`metadata/FDROID_SUBMISSION.md`](../metadata/FDROID_SUBMISSION.md)

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
