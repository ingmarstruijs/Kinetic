# F-Droid

Metadata drafts live under `metadata/` in this repo. Listing on f-droid.org
needs merge requests against [fdroiddata](https://gitlab.com/fdroid/fdroiddata).
Maintainer/agent release order (GitHub **and** F-Droid):
[`docs/RELEASING.md`](../docs/RELEASING.md).

## Status

| App | Application ID | Listing |
| --- | --- | --- |
| Kinetic Link | `net.moonbaseone.kinetic.link` | **MR open** — [!50470](https://gitlab.com/fdroid/fdroiddata/-/merge_requests/50470) (`v0.4.1`, App inclusion template) |
| Kinetic Kids | `net.moonbaseone.kinetic.kids` | **MR open** — [!50471](https://gitlab.com/fdroid/fdroiddata/-/merge_requests/50471) (`v0.4.1`, App inclusion template) |

Kids on F-Droid is the Android companion to Link; other Kids platforms in the
monorepo are out of scope for fdroiddata.

When both are live on f-droid.org, change the table to **Live** and drop the
first-listing paste kits (`FDROID_MR_0.4.*.md`).

## Release flow (every version after first listing)

GitHub Releases and F-Droid are **separate**. Tagging `main` publishes GitHub
APKs automatically; F-Droid stays on the previous version until you open an
fdroiddata MR.

Metadata uses `AutoUpdateMode: None` / `UpdateCheckMode: None`, so **every**
Kinetic release needs a manual fdroiddata update.

1. **Version bump PR** on this repo (`release/X.Y.Z`):
   - Bump `apps/link/pubspec.yaml` and `apps/kids/pubspec.yaml` to `X.Y.Z+N`
   - Add Fastlane `changelogs/N.txt` (and refresh screenshots/copy if needed)
     under `apps/*/fastlane/metadata/android/en-US/`
   - Update both `metadata/*.yml`: `versionName`, `versionCode`,
     `CurrentVersion`, `CurrentVersionCode` (set `commit:` to the **full SHA**
     after the tag exists)
   - Merge to `main` after CI
2. **Tag** the merge commit on `main` (see [`docs/RELEASING.md`](../docs/RELEASING.md)) → GitHub APKs
3. **Verify** the F-Droid recipe locally (Git Bash / WSL / Linux / macOS):

   ```bash
   ./tool/fdroid_build.sh link
   ./tool/fdroid_build.sh kids
   ```

   Expected APKs:
   - `apps/link/build/app/outputs/flutter-apk/app-release.apk`
   - `apps/kids/build/app/outputs/flutter-apk/app-release.apk`

4. **Update fdroiddata**: add a new `Builds:` entry (full SHA in `commit:`) and
   bump `CurrentVersion` / `CurrentVersionCode` in both YAML copies. Prefer
   **one update MR** for both apps unless a maintainer asks to split. Do **not**
   copy Fastlane/screenshot dirs into fdroiddata.
5. After merge, watch [F-Droid build logs](https://f-droid.org/wiki/page/Build)
   for both application IDs; fix the recipe if bootstrap/native hooks fail

### Version alignment checklist

These must match for each release:

- [ ] `apps/*/pubspec.yaml` → `version: X.Y.Z+N`
- [ ] Fastlane `changelogs/N.txt` present for that versionCode
- [ ] Metadata `versionName` / `versionCode` / `CurrentVersion*` / `commit: <full SHA>`
- [ ] Annotated git tag `vX.Y.Z` on `main`
- [ ] Flutter pin in metadata `srclibs` matches `.flutter-version` (and CI / FVM)
- [ ] `dependenciesInfo.includeInApk = false` still set (no Dependency metadata block)

## First-time submission (done for 0.4.1 — keep for reference)

Paste kit: [`FDROID_MR_0.4.1.md`](FDROID_MR_0.4.1.md). Obsolete kit:
[`FDROID_MR_0.4.0.md`](FDROID_MR_0.4.0.md) (do not reuse).

Rules that rejected the first attempt — still required for any new app MR:

1. Fastlane under `apps/*/fastlane/metadata/android/en-US/` (title, short + full
   description, changelogs, icon, phoneScreenshots)
2. Tag on `main`; `commit:` = **full SHA** of that tag (not `vX.Y.Z`)
3. fdroiddata gets **yml only** — no asset directories
4. **One new app per MR**, titles `New app: …`, App inclusion template
5. Leave Reproducible Builds off until Flutter/Melos RB is deliberate work
6. No `PrivacyPolicy:` metadata field; no JetBrains `cache-redirector` Maven URLs

### MR checklist (first listing)

- [x] YAML `commit:` is the full SHA of `v0.4.1` (`73c877299d2c5f0cc17fa0a93804621949d3a960`)
- [x] `versionName` / `versionCode` match pubspec `0.4.1+11`
- [x] `srclibs: flutter@3.44.1` matches `.flutter-version`
- [x] Fastlane in upstream; no graphics in fdroiddata
- [x] Separate Link + Kids MRs; pipelines green on fork CI
- [ ] Merged upstream + live on f-droid.org

## Local build notes

`tool/fdroid_build.sh` mirrors each YAML `prebuild` / `build` recipe and reads
`version:` from the app `pubspec.yaml`.

**Windows:** use **Git Bash** or **WSL** (the script is bash; PowerShell cannot
run it natively). Flutter on `PATH` must match `.flutter-version` (FVM:
`fvm use`).

### Toolchain pins

| Pin | Source |
| --- | --- |
| Flutter | `.flutter-version`, `.fvmrc`, CI workflows, metadata `srclibs: flutter@…` |
| Android NDK | Flutter-bundled (`flutter.ndkVersion` in `apps/*/android/app/build.gradle.kts`); no separate fdroiddata NDK pin |
| Melos | `dart pub global activate melos` in `prebuild` / `fdroid_build.sh` |
| Native SQLite | sqlite3mc via workspace hooks |

### Reproducibility

- Melos bootstrap is required in `prebuild` (monorepo packages must resolve)
- F-Droid rebuilds and **re-signs** APKs with the F-Droid key; GitHub Release
  signing is independent (different certificate fingerprint)
- Local DB encryption uses SQLite3MultipleCiphers via pub workspace hooks
- AGP `dependenciesInfo` must stay disabled or `check apk` fails

## Privacy

Link to the policy from the app Description / Fastlane full description and keep
https://raw.githubusercontent.com/ingmarstruijs/Kinetic/main/PRIVACY.md on `main`.
Current fdroidserver rejects a top-level `PrivacyPolicy:` metadata field.
