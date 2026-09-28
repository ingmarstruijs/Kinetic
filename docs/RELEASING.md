# Releasing Kinetic (for maintainers / agents)

`main` is protected: no direct pushes. GitHub Releases publish only for
annotated `v*` tags whose commit is already on `main`.

## Version bump → tag

1. Open a PR (`release/x.y.z`) that bumps:
   - `apps/link/pubspec.yaml` and `apps/kids/pubspec.yaml` (`version: X.Y.Z+N`)
   - `metadata/*.yml` (`versionName`, `versionCode`, `commit: vX.Y.Z`,
     `CurrentVersion*`)
2. Wait for required CI (`analyze-and-test`), merge to `main`.
3. Tag **that** merge commit:

```bash
git checkout main && git pull
git tag -a vX.Y.Z -m "Kinetic X.Y.Z"
git push origin vX.Y.Z
```

CI builds and signs both APKs on `main`/`develop`, any `v*` tag, or workflow
dispatch (see `.github/workflows/build-release.yml`). A `v*` tag **not** on
`main` builds APKs but does **not** create GitHub Releases.

## GitHub release artifacts

Each tag yields two releases:

- `vX.Y.Z-kids` — `kinetic-kids-X.Y.Z.apk`
- `vX.Y.Z-link` — `kinetic-link-X.Y.Z.apk`

Each includes `sha256.txt`.

## F-Droid

Tagging does **not** update f-droid.org. After each bump follow
[`metadata/FDROID_SUBMISSION.md`](../metadata/FDROID_SUBMISSION.md)
(`./tool/fdroid_build.sh`, then fdroiddata MR).

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
**Certificate Fingerprint.**

```bash
keytool -printcert -jarfile kinetic-link-X.Y.Z.apk
# use the SHA256: line
```

## Local unsigned build

```bash
cd apps/link   # or apps/kids
flutter build apk --release
```
