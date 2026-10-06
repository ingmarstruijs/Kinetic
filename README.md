<p align="center">
  <img src="brand/logo-link.svg" alt="Kinetic Link" width="88" height="88" />
  &nbsp;&nbsp;
  <img src="brand/logo-kids.svg" alt="Kinetic Kids" width="88" height="88" />
</p>

<h1 align="center">Kinetic Link</h1>

<p align="center">
  <strong>Tasks. Notes. Family.</strong><br>
  Local-first personal tasks — encrypted on your device. Family features need your own WebDAV server.
</p>

<p align="center">
  <em>Kinetic Link</em> · <em>Kinetic Kids</em><br>
  Flutter · AES-256-GCM · Offline-first · No account · No telemetry
</p>

---

Kinetic helps families run household tasks without accounts, telemetry, or cloud
lock-in. Alone on one device you get encrypted personal tasks, notes, themes,
and vault backup. Connect your **own** WebDAV server to unlock family linking,
kids assignments, shared notes, and multi-device sync.

## Features

**On device (no server)** — personal tasks and notes, categories, reminders,
offline suggestions, themes, encrypted vault and `.kvault` backup.

**With WebDAV** — family pairing (QR / BLE / phrase), task proposals, kids
enrollment and XP, shared notes, presence/load awareness, multi-device sync.
Same WebDAV base URL for every family device. Details:
[`docs/FAMILY_SETUP.md`](docs/FAMILY_SETUP.md).

## Apps & stack

| | |
| --- | --- |
| **Kinetic Link** (`apps/link`) | Android, iOS — tasks, notes, family, WebDAV |
| **Kinetic Kids** (`apps/kids`) | Android — assigned chores + XP |
| **Shared** | `packages/webdav` (AES-256-GCM, iCal, WebDAV), Melos monorepo, Drift/SQLite |
| **Tests** | `melos run test`; multi-device protocol in CI — [`docs/SYNC_PROTOCOL_TESTING.md`](docs/SYNC_PROTOCOL_TESTING.md) |

## Getting started

```bash
dart pub global activate melos
melos bootstrap
melos run test
cd apps/link && flutter run
```

No server needed for personal use. Family extras need **Settings → Sync**
(WebDAV) first.

### Issues

- Search existing issues first; use the **Bug** or **Feature** templates.
- Include: expected vs actual, steps, app (Link / Kids), OS/version, and
  whether WebDAV/family is involved.
- Security-sensitive reports: describe impact; do not paste vault phrases or
  WebDAV passwords (prefer a private security advisory).

### Pull requests

- Branch from up-to-date `main` (never push directly to `main`).
- Keep PRs focused; fill in the PR template; include tests when behaviour
  changes.
- Wait for CI (`analyze-and-test`) to pass before merge.
- Match existing style; update EN + NL ARB strings together when changing copy.
- After editing ARB files: `cd apps/link && flutter gen-l10n` (same for kids).

## Localization

English and Dutch via Flutter `gen-l10n` (`apps/*/lib/l10n`). English is the
template locale.

## Heuristics

On-device suggestions on the Tasks screen — **no cloud AI**. Detectors cover
habits, calendar prompts, overdue/stale tasks, seasonal repeats, and (with a
family link) privacy-preserving family hints. Nothing is auto-sent to a family
member; **Send** always confirms what they will see.

More detail: [`apps/link/docs/SMART_FEATURES.md`](apps/link/docs/SMART_FEATURES.md).

## Encryption

Everything sensitive is encrypted with keys derived from **12 English recovery
words** (BIP-39). Write them on paper — that paper is the only off-device backup
of your vault.

- **Personal vault** — your words unlock personal tasks, notes, and `.kvault`
  backups. The same phrase works for WebDAV restore after reinstall.
- **Family key** — a separate 12-word phrase shared by the household. Used for
  proposals, kids tasks, and shared notes. Optional **rotation** after removing
  a member re-encrypts shared data so the old key cannot read new content.
- **Kids** — each child device has its own id for targeting; the WebDAV password
  is typed on the kids device (never embedded in the enrollment QR).

First launch: **New vault** or **Restore** (file + words, or WebDAV + words).
Export never includes the recovery words, raw keys, or WebDAV password.
Settings can verify or reveal the phrase behind the device lock.

## Releases

Every version has **two** publish steps:

1. **GitHub** — bump PR → merge to `main` → annotated tag `vX.Y.Z` → CI publishes
   separate Link and Kids releases (APKs + checksums).
2. **F-Droid** — manual: full commit SHA in `metadata/*.yml`, then fdroiddata MR
   (Fastlane/screenshots stay in this repo). Tagging alone does not update
   f-droid.org.

Changelogs (Keep a Changelog; `### Store` syncs to Fastlane):

- [Kinetic Link](apps/link/CHANGELOG.md)
- [Kinetic Kids](apps/kids/CHANGELOG.md)

Full maintainer/agent checklist:
[`docs/RELEASING.md`](docs/RELEASING.md) · F-Droid details:
[`metadata/FDROID_SUBMISSION.md`](metadata/FDROID_SUBMISSION.md).

### Quick APK check

```bash
sha256sum kinetic-link-X.Y.Z.apk          # must match sha256.txt
keytool -printcert -jarfile kinetic-link-X.Y.Z.apk   # certificate fingerprint
```

Those are two different values — file hash ≠ signing certificate fingerprint.

## License

Kinetic is free software: you can redistribute it and/or modify it under the
terms of the GNU Affero General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option) any
later version. See [LICENSE](LICENSE).
