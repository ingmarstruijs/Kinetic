# F-Droid

Draft metadata for both apps lives under `metadata/` in this repo. Listing on
f-droid.org requires a merge request against
[fdroiddata](https://gitlab.com/fdroid/fdroiddata).

## Status

| App | Application ID | Listing |
| --- | --- | --- |
| Kinetic Link | `net.moonbaseone.kinetic.link` | **Ready to submit** — `v0.4.0` tagged; see [`FDROID_MR_0.4.0.md`](FDROID_MR_0.4.0.md) |
| Kinetic Kids | `net.moonbaseone.kinetic.kids` | **Ready to submit** — Android APK only (no desktop/iOS) |

Kids on F-Droid is the Android companion to Link; other Kids platforms in the
monorepo are out of scope for fdroiddata.

Update this table when the first MR is opened / merged / live on f-droid.org.

## Release flow (every version)

GitHub Releases and F-Droid are **separate**. Tagging `main` publishes GitHub
APKs automatically; F-Droid stays on the previous version until you open an
fdroiddata MR.

Metadata uses `AutoUpdateMode: None` / `UpdateCheckMode: None`, so **every**
Kinetic release needs a manual fdroiddata update (not only the first listing).

1. **Version bump PR** on this repo (`release/X.Y.Z`):
   - Bump `apps/link/pubspec.yaml` and `apps/kids/pubspec.yaml` to `X.Y.Z+N`
   - Update both `metadata/*.yml`: `versionName`, `versionCode`, `commit: vX.Y.Z`,
     `CurrentVersion`, `CurrentVersionCode`
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

4. **Update fdroiddata** (after first listing exists): add a new `Builds:` entry
   and bump `CurrentVersion` / `CurrentVersionCode` in the upstream YAML copies,
   then open an MR against `fdroid/fdroiddata` `master`

5. After merge, watch [F-Droid build logs](https://f-droid.org/wiki/page/Build)
   for both application IDs; fix the recipe if bootstrap/native hooks fail

### Version alignment checklist

These must match for each release:

- [ ] `apps/*/pubspec.yaml` → `version: X.Y.Z+N`
- [ ] Metadata `versionName` / `versionCode` / `CurrentVersion*` / `commit: vX.Y.Z`
- [ ] Annotated git tag `vX.Y.Z` on `main`
- [ ] Flutter pin in metadata `srclibs` matches `.flutter-version` (and CI / FVM)

## First-time submission

Do this once, before any “every version” fdroiddata bump:

1. Ensure screenshots and icons are on `main` under
   `metadata/*/en-US/images/` (phone screenshots + icon)
2. Tag the target version on `main` and verify both APKs with
   `./tool/fdroid_build.sh`
3. Fork [fdroiddata](https://gitlab.com/fdroid/fdroiddata) and copy:

   - `net.moonbaseone.kinetic.link.yml`
   - `net.moonbaseone.kinetic.kids.yml`
   - `net.moonbaseone.kinetic.link/en-US/` (screenshots + icon)
   - `net.moonbaseone.kinetic.kids/en-US/` (screenshots + icon)

4. Open a GitLab MR against `fdroid/fdroiddata` `master` with the checklist below
5. When live, update the **Status** table above

### MR checklist (first listing)

- [ ] YAML `commit:` points at an **annotated tag** on `main` (`vX.Y.Z`)
- [ ] `versionName` / `versionCode` match pubspec and `CurrentVersion*`
- [ ] `srclibs: flutter@…` matches `.flutter-version`
- [ ] `License: Apache-2.0`, `Repo` / `SourceCode` URLs correct
- [ ] `PrivacyPolicy:` → `PRIVACY.md` on `main`
- [ ] Fastlane-style assets present: icons + phone screenshots for both apps
- [ ] Build verified locally with `./tool/fdroid_build.sh` for **link** and **kids**
- [ ] MR description notes **Kids is Android-only**; Link + Kids are separate application IDs
- [ ] No proprietary blobs; WebDAV sync is user-configured HTTPS only

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
  signing is independent
- Local DB encryption uses SQLite3MultipleCiphers via pub workspace hooks

## Privacy

`PrivacyPolicy:` points at
https://raw.githubusercontent.com/ingmarstruijs/Kinetic/main/PRIVACY.md
