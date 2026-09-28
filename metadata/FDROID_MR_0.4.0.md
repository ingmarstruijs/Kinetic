# First F-Droid listing — Kinetic 0.4.0

Copy these from Kinetic `main` at tag `v0.4.0` into your
[fdroiddata](https://gitlab.com/fdroid/fdroiddata) fork:

```text
metadata/net.moonbaseone.kinetic.link.yml
metadata/net.moonbaseone.kinetic.kids.yml
metadata/net.moonbaseone.kinetic.link/en-US/   # icon + phoneScreenshots
metadata/net.moonbaseone.kinetic.kids/en-US/   # icon + phoneScreenshots
```

Suggested GitLab MR title: `New apps: Kinetic Link and Kinetic Kids (0.4.0)`

## MR description (paste into GitLab)

```markdown
## New apps

Add **Kinetic Link** (`net.moonbaseone.kinetic.link`) and **Kinetic Kids**
(`net.moonbaseone.kinetic.kids`) at version **0.4.0** (versionCode **10**).

- Source: https://github.com/ingmarstruijs/Kinetic
- Annotated tag on `main`: `v0.4.0`
- License: Apache-2.0
- Privacy: https://raw.githubusercontent.com/ingmarstruijs/Kinetic/main/PRIVACY.md
- Flutter srclibs pin: `flutter@3.44.1` (matches repo `.flutter-version`)
- Kids is **Android-only** (companion to Link); separate application IDs
- Sync is user-configured HTTPS WebDAV only; no proprietary network service
- Local verification: `./tool/fdroid_build.sh link` and `./tool/fdroid_build.sh kids`
  (recipe mirrors metadata `prebuild` / `build`)

### Checklist

- [x] `commit:` points at annotated tag `v0.4.0` on `main`
- [x] `versionName` / `versionCode` / `CurrentVersion*` match pubspec `0.4.0+10`
- [x] Fastlane-style icons + phone screenshots for both apps
- [x] No telemetry / accounts; encrypted local SQLite (+ optional WebDAV)
```

## Local copy helper (Git Bash / WSL)

After cloning your fdroiddata fork next to Kinetic:

```bash
KINETIC=/path/to/Kinetic
FDROIDDATA=/path/to/fdroiddata
git -C "$KINETIC" fetch --tags
git -C "$KINETIC" checkout v0.4.0

cp "$KINETIC/metadata/net.moonbaseone.kinetic.link.yml" "$FDROIDDATA/metadata/"
cp "$KINETIC/metadata/net.moonbaseone.kinetic.kids.yml" "$FDROIDDATA/metadata/"
rm -rf "$FDROIDDATA/metadata/net.moonbaseone.kinetic.link" \
       "$FDROIDDATA/metadata/net.moonbaseone.kinetic.kids"
cp -a "$KINETIC/metadata/net.moonbaseone.kinetic.link" "$FDROIDDATA/metadata/"
cp -a "$KINETIC/metadata/net.moonbaseone.kinetic.kids" "$FDROIDDATA/metadata/"
```

## GitLab HTTPS / SSO

If GitLab shows *authenticated with SSO or SAML*, create a
[Personal Access Token](https://gitlab.com/-/user_settings/personal_access_tokens)
(with `write_repository`) and use that instead of your account password when
`git push` asks for credentials.
