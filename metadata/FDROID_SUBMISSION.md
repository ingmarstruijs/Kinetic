# F-Droid submission guide

This repo ships draft metadata for both apps under `metadata/`. Listing on
f-droid.org requires a merge request against
[fdroiddata](https://gitlab.com/fdroid/fdroiddata).

## STATUS

**Local recipe:** `tool/fdroid_build.sh` matches the YAML `prebuild` / `build`
steps and reads `version:` from each app’s `pubspec.yaml` (aligned with
`CurrentVersion` / `CurrentVersionCode` in the metadata files). Flutter
**3.44.1** is pinned in `.flutter-version`, `.fvmrc`, CI, and `srclibs`.
Prebuild uses `dart pub global run melos bootstrap` (same as both YAML files).
Ready to copy metadata into an fdroiddata fork and open an MR (not submitted
from this environment — no fdroiddata credentials).

**Windows check (Git Bash):** `./tool/fdroid_build.sh link` completed successfully (exit 0, ~23 min Gradle on first run); output `apps/link/build/app/outputs/flutter-apk/app-release.apk`. Run `./tool/fdroid_build.sh kids` the same way before MR.

## Scope

| App | Application ID | F-Droid |
| --- | --- | --- |
| Kinetic Link | `net.moonbaseone.kinetic.link` | Android APK |
| Kinetic Kids | `net.moonbaseone.kinetic.kids` | **Android APK only** (no desktop/iOS listing) |

Kinetic Kids is shipped on F-Droid as an Android companion to Link; other
platform builds in the monorepo are out of scope for fdroiddata.

## Reproducible build path

F-Droid builders run the recipe in each app’s YAML (`subdir`, `prebuild`,
`build`). To reproduce locally on Linux, macOS, Git Bash, or WSL:

```bash
# From repo root — requires Flutter 3.44.1 on PATH (FVM: fvm use && fvm flutter ...)
./tool/fdroid_build.sh link
./tool/fdroid_build.sh kids
```

Expected APK:

- `apps/link/build/app/outputs/flutter-apk/app-release.apk`
- `apps/kids/build/app/outputs/flutter-apk/app-release.apk`

**Windows:** run the same commands in **Git Bash** or **WSL** (the script is
`bash`; PowerShell cannot run it natively). Install Flutter **3.44.1** on PATH.
The script reads `.flutter-version` and each app’s `pubspec.yaml` (no Python
required).

### Toolchain pins

| Pin | Value | Where |
| --- | --- | --- |
| Flutter | **3.44.1** | `.flutter-version`, `.fvmrc`, `.github/workflows/*.yml`, metadata `srclibs: flutter@3.44.1` |
| Android NDK | **Flutter-bundled** (`flutter.ndkVersion` in `apps/*/android/app/build.gradle.kts`) | No separate NDK pin in fdroiddata; F-Droid’s Flutter srclib supplies the NDK version Flutter 3.44.1 expects |
| Melos | Latest compatible at build time | `dart pub global activate melos` in `prebuild` / `fdroid_build.sh` |
| Native SQLite | sqlite3mc via workspace hooks | `hooks.user_defines.sqlite3.source: sqlite3mc` (pub workspace) |

Version **name** and **code** for releases must match across:

- `apps/link/pubspec.yaml` and `apps/kids/pubspec.yaml` (`version: X.Y.Z+N`)
- Metadata `versionName` / `versionCode` / `CurrentVersion*` / `commit:` tag
- Git annotated tag `vX.Y.Z` on `main`

Current draft metadata targets **0.3.9** / **8** / tag **`v0.3.9`**.

### Reproducibility notes

- Workspace Melos bootstrap is part of `prebuild` (monorepo packages must resolve).
- F-Droid rebuilds and **re-signs** APKs with the F-Droid key; GitHub Release
  signing is independent.
- Local DB encryption uses SQLite3MultipleCiphers via pub workspace hooks.

## Before opening the GitLab MR

1. Merge screenshots / metadata PR to `main` (icons already on main).
2. After the version bump is on `main`, create an annotated release tag
   matching the metadata `commit:` field:
   ```bash
   git checkout main && git pull
   git tag -a v0.3.9 -m "Kinetic 0.3.9 for F-Droid"
   git push origin v0.3.9
   ```
   GitHub Releases are created only for tags whose commit is already on `main`.
3. Confirm Flutter **3.44.1** builds both APKs locally:
   ```bash
   ./tool/fdroid_build.sh link
   ./tool/fdroid_build.sh kids
   ```
4. Phone screenshots live under
   `metadata/*/en-US/images/phoneScreenshots/` (`01.png`, `02.png`, …).
5. Copy into an fdroiddata fork (paths under fdroiddata `metadata/`):
   - `net.moonbaseone.kinetic.link.yml`
   - `net.moonbaseone.kinetic.kids.yml`
   - `net.moonbaseone.kinetic.link/en-US/` (screenshots + icon)
   - `net.moonbaseone.kinetic.kids/en-US/` (screenshots + icon)

## MR checklist (fdroiddata)

Use this when opening the GitLab MR against `fdroid/fdroiddata` `master`:

- [ ] YAML `commit:` points at an **annotated tag** on `main` (`v0.3.9`).
- [ ] `versionName` / `versionCode` match pubspec and `CurrentVersion*`.
- [ ] `srclibs: flutter@3.44.1` (same as repo pins).
- [ ] `License: Apache-2.0`, `Repo` / `SourceCode` URLs correct.
- [ ] `PrivacyPolicy:` → `PRIVACY.md` on `main`.
- [ ] Fastlane-style assets present: icons + phone screenshots for both apps.
- [ ] Build verified locally with `./tool/fdroid_build.sh` for **link** and **kids**.
- [ ] MR description notes **Kids is Android-only**; Link + Kids are separate application IDs.
- [ ] No proprietary blobs; WebDAV sync is user-configured HTTPS only.
- [ ] After merge, watch F-Droid build logs for first publish; fix recipe if bootstrap/native hooks fail on builders.

## Privacy

`PrivacyPolicy:` points at
https://raw.githubusercontent.com/ingmarstruijs/Kinetic/main/PRIVACY.md
