# F-Droid first listing — Kinetic 0.4.1 (split MRs)

F-Droid requires **one app per MR**, Fastlane metadata **in the upstream
repo** (not screenshots in fdroiddata), and a **full commit SHA** (not a tag
name). Reproducible Builds: leave unchecked for now (Flutter/Melos monorepo).

## Before opening MRs

1. On Kinetic `main` (or `release/0.4.1`):
   - Fastlane under `apps/link/fastlane/...` and `apps/kids/fastlane/...`
   - Run `bash tool/copy_fastlane_images.sh` so icons + screenshots are present
   - Version `0.4.1+11` in both pubspecs
2. Merge, annotate-tag `v0.4.1`, note the **full SHA**:
   `git rev-parse v0.4.1`
3. Put that SHA in both `metadata/*.yml` `commit:` fields (replace
   `REPLACE_WITH_V0_4_1_FULL_SHA`), then sync those two yml files into
   fdroiddata (yml only — no `metadata/net.moonbaseone.kinetic.*/` asset dirs).

## Kinetic Link MR

**Title:** `New app: Kinetic Link`

Paste into GitLab (App inclusion template):

```markdown
### Description of the app

Kinetic Link — local-first encrypted family tasks and notes with optional
HTTPS WebDAV sync. No accounts, no telemetry. Companion: Kinetic Kids
(separate MR).

### License

Apache-2.0 — LICENSE in https://github.com/ingmarstruijs/Kinetic

### Online repositories / source code

- Source: https://github.com/ingmarstruijs/Kinetic
- Tag: `v0.4.1` (commit SHA in metadata `commit:`)
- Privacy: https://raw.githubusercontent.com/ingmarstruijs/Kinetic/main/PRIVACY.md

### Application ID

`net.moonbaseone.kinetic.link`

### Category / summary

Note, Task — short description + screenshots via Fastlane at
`apps/link/fastlane/metadata/android/en-US/`

### Build

Flutter srclib `flutter@3.44.1`, Melos bootstrap in `prebuild`, APK from
`apps/link`. Local check: `./tool/fdroid_build.sh link`

### Reproducible Builds

Not enabled yet. Flutter + Melos monorepo (workspace packages, native
sqlite3mc/NDK) makes bit-identical APKs a follow-up; F-Droid signing is fine
for the first listing.
```

## Kinetic Kids MR

**Title:** `New app: Kinetic Kids`

```markdown
### Description of the app

Kinetic Kids — Android companion that shows chores from Kinetic Link and
awards XP. No accounts, no telemetry. Separate application ID from Link.

### License

Apache-2.0 — LICENSE in https://github.com/ingmarstruijs/Kinetic

### Online repositories / source code

- Source: https://github.com/ingmarstruijs/Kinetic
- Tag: `v0.4.1` (commit SHA in metadata `commit:`)
- Privacy: https://raw.githubusercontent.com/ingmarstruijs/Kinetic/main/PRIVACY.md

### Application ID

`net.moonbaseone.kinetic.kids`

### Category / summary

Habit Tracker, Task — Fastlane at
`apps/kids/fastlane/metadata/android/en-US/`

### Build

Same monorepo recipe as Link; `subdir: apps/kids`. Local check:
`./tool/fdroid_build.sh kids`. Kids is Android-only for F-Droid.

### Reproducible Builds

Not enabled yet (same Flutter/Melos reasons as Link).
```

## fdroiddata sync (yml only)

```bash
KINETIC=/path/to/Kinetic
FDROIDDATA=/path/to/fdroiddata
HASH=$(git -C "$KINETIC" rev-parse v0.4.1)

# Ensure ymls already contain $HASH, then:
cp "$KINETIC/metadata/net.moonbaseone.kinetic.link.yml" "$FDROIDDATA/metadata/"
cp "$KINETIC/metadata/net.moonbaseone.kinetic.kids.yml" "$FDROIDDATA/metadata/"

# Do NOT copy metadata/net.moonbaseone.kinetic.link/ or .../kids/ into fdroiddata.
```

Open **two** branches / MRs against `fdroid/fdroiddata` `master`, each with
exactly one yml change.
