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
  <em>Kinetic Link</em> · <em>Kinetic Kids</em>
</p>

<p align="center">
  Flutter · AES-256-GCM · Offline-first · No account · No telemetry
</p>

---

Kinetic Link helps families run household tasks without accounts, without telemetry, and without cloud lock-in. Without a server you get encrypted personal tasks, notes, themes, and vault backup on one device. Connect your own WebDAV server to unlock family extras: family-member proposals, kids assignments, shared notes, presence, load awareness, and multi-device sync.

Two Flutter apps share crypto and sync logic in `packages/webdav` (AES-256-GCM, iCal, WebDAV client).

## Features



### Always available (local / vault)

- **Personal tasks** — quick-add, swipe-to-complete, priorities, categories, due dates, recurrence, and **smart reminder chips** that propose contextual times from title and history. Enabling a reminder defaults to **one hour from now, rounded up to the next half hour**; the time dialog focuses the hour field so you can type immediately
- **Notes** — fullscreen markdown editor (edit/preview, GFM checkboxes, formatting shortcuts); list shows last modified (+ shared audience); optional **require unlock** (open with biometrics/PIN); **local-only** notes never leave the device; templates and note ↔ task links
- **AI suggestions (for you)** — fully offline heuristic engine (habits, calendar, stale open tasks, seasonal history) with human-readable explanations
- **Themes** — Default (light blue brand), Calm (warm sand/terracotta), Night (OLED); header logo keeps brand blue on Default and follows the accent on Calm/Night
- **Encryption** — 12-word BIP-39 vault; derived AES-256-GCM key in device secure storage. Same phrase for WebDAV and `.kvault` backup
- **Backup & restore** — encrypted `.kvault` (no key in the file). Restore with the 12 words from a file (WebDAV restore also needs a configured server)



### Requires WebDAV

Family features are **not** available offline-only. Configure WebDAV in **Settings → Sync** first. The **Family** section (including **Start family**) appears only after WebDAV is connected.

**Same server for the whole family.** All Link and Kids devices in one family must use the **same WebDAV base URL** (same folder root — e.g. a Nextcloud group folder, not two separate personal homes like `…/dav/files/alice/` vs `…/bob/`). Logins (username/password) may differ per person when the server grants both access to that root; personal data lives under `/kinetic/{username}/`, shared data under `/kinetic/shared/`. Linking with a different server URL is **blocked** (QR / BLE). Manual phrase entry does not carry a URL — configure the matching server first.

- **WebDAV sync** — bring your own server, no vendor backend; connection test distinguishes wrong password vs no WebDAV vs network errors
- **Turn off sync** — on the WebDAV setup screen; stops sync and clears family/kids linkage on this device, keeps the personal vault and private local data
- **Family coordination** — QR / BLE / 12-word pairing, encrypted task proposals, accept/decline flow; family-member-targeted suggestions require an explicit **Send** after a **What {name} sees** preview (nothing is auto-sent)
- **Kids tasks** — assign to one child or **Everyone**; configurable XP, goals, and routines; draft enrollment becomes **active** when the kids app reports presence; the kids app syncs assignments and awards XP on completion
- **Family key rotation** — optional wizard after removing a member; shared blobs are re-encrypted so the old key cannot read new data
- **Shared notes** — share notes with other link members (needs pairing); local-only notes stay off the server
- **Connection-aware send** — family members listed with WebDAV presence status before forwarding
- **Ambient presence & load** — shared load metrics (`/kinetic/shared/load/…`) feed household awareness and suggestions without becoming chat
- **Family-member / load-balance suggestions** — privacy-preserving hints that only make sense once a family link exists



## Apps


| App                      | Platforms    | Description                                                                 |
| ------------------------ | ------------ | --------------------------------------------------------------------------- |
| `[apps/link](apps/link)` | Android, iOS | Task manager, family-member proposals, notes, kids overview, WebDAV config  |
| `[apps/kids](apps/kids)` | Android      | Assigned tasks synced from Kinetic Link; children mark complete and earn XP |




## Tech Stack


| Layer         | Choice                                               |
| ------------- | ---------------------------------------------------- |
| Apps          | Flutter (Kinetic Link + Kinetic Kids)                |
| Local DB      | Drift (SQLite)                                       |
| Crypto & sync | `packages/webdav` — AES-256-GCM, iCal, WebDAV client |
| Link Web bridge | `packages/link_bridge` + `apps/link_web` (LAN phone proxy) — [`docs/LINK_WEB.md`](docs/LINK_WEB.md) |
| Monorepo      | Melos                                                |
| Tests         | `flutter test` per package; multi-device protocol in CI — see [`docs/MULTI_DEVICE_TESTING.md`](docs/MULTI_DEVICE_TESTING.md) |




## Getting Started

```bash
dart pub global activate melos
melos bootstrap
melos run test        # run all tests
cd apps/link && flutter run
```

No server required for personal use — Kinetic Link works fully offline for tasks, notes, vault, and themes. **Family extras** (family linking, proposals, kids enrollment/overview, shared notes, presence, multi-device sync) need WebDAV in **Settings → Sync** (same base URL for every family device).

**Link Web (experimental):** on the same Wi‑Fi, **Settings → Link Web** starts a phone bridge; open the HTTP URL on your computer. Keys stay on the phone. Details: [`docs/LINK_WEB.md`](docs/LINK_WEB.md). The static SPA is also published to GitHub Pages on `main` (still pair via the phone URL for LAN).

### Build a release APK

```bash
cd apps/link   # or apps/kids
flutter build apk --release
```

PRs and pushes to `main`/`develop` run analyze + tests (`[.github/workflows/ci.yml](.github/workflows/ci.yml)`). CI builds and signs both APKs on push to `main`/`develop`, on any `v*` tag, or via workflow dispatch (`[.github/workflows/build-release.yml](.github/workflows/build-release.yml)`). GitHub Releases are published only when that tag’s commit is already on `main`.

## Localization

Both apps ship **English** and **Dutch** UI via Flutter `gen-l10n` (ARB files under `apps/*/lib/l10n`). English is the template locale; Dutch lives in `app_nl.arb`. After editing ARB files, run `flutter gen-l10n` (or `flutter pub get`) in the app directory.

Tasks/notes suggestion copy in the link app is still being migrated; nav, settings, vault, family pairing, and the kids app are localized.

## Family Setup

**Prerequisite:** WebDAV configured and reachable (same base URL for every family member). Without it there is no shared folder, no pairing, and no kids sync — the **Family** settings section is hidden until WebDAV is connected.

One Kinetic family = **one** shared folder tree (`/kinetic/shared/…`) encrypted with **one** family key. Multiple user folders on that server (e.g. `alex`, `bob`) are members of that same family — you do not pick a person to link to; any member’s invite (QR / BLE / 12 words) joins the whole family.

### Start-family guide

After WebDAV is on and you still have no family key:

- **Settings → Family → Start family** (small link next to the section title) opens a guided wizard: WebDAV (if needed) → create/join family → invite → kids → done. The link disappears once a family key exists.
- **Day-1 nudge:** about a day after WebDAV is configured without a family, Kinetic may prompt with **Ignore** (never again until reconnect), **Remind in 7 days**, or **Start guide**.
- **Existing data on the folder:** after saving WebDAV, if another Kinetic user folder and/or shared roster/presence is already present, Kinetic offers **Link now** (opens QR / BLE / phrase import immediately) or **Not now**. If `family.key.enc` exists for your username, the family key is restored automatically.

### Family linking

1. **Settings → Family → Family members** → share QR (12 family words + entropy) or tap-to-link (BLE); QR remains the fallback
2. The other family member scans, uses BLE, **or** types the 12 words and confirms the fingerprint — **server URL in the invite must match** their configured WebDAV URL or linking is blocked
3. Proposals and shared data sync via that same WebDAV server

### Kids enrollment

1. **Settings → Family → Kids** → generate QR with family key + kid UUID (no WebDAV password)
2. Child device scans the QR and types the WebDAV password once (same server as Link)
3. The kid appears as **draft** on the roster until the kids app syncs **presence**, then becomes **active**
4. Kinetic Link forwards tasks to that child's UUID, or to **Everyone** (no target id — visible to all enrolled kids)

Ship Kinetic Link **and** Kinetic Kids at the same minor version when enrollment/QR formats change.

Proposals and kids panels on Tasks appear after pairing or enrollment. Shared notes require family linking. After removing a family member you can optionally **rotate the family key** so their old key cannot decrypt new shared data.

### Multi-device sync testing

Protocol behaviour (roster, kids complete, load metrics, leave wipe, key rotation, …) is covered in CI with a fake dual-device harness — not by running phone + emulator for every route. See [`docs/MULTI_DEVICE_TESTING.md`](docs/MULTI_DEVICE_TESTING.md). Roadmap: [`FUTURE.md`](FUTURE.md).

## AI Suggestion Engine

A fully offline, heuristic-based engine surfaces task suggestions in the Kinetic Link **Tasks** screen. No API calls — runs entirely on-device.

An empty run does **not** start the 24-hour throttle, so creating tasks can surface hints on the next open. After at least one suggestion is created, that path waits 24 hours.


| Detector              | Trigger                                                                                                                                                                       | Target                                     | What the family member sees                                    |
| --------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------ | -------------------------------------------------------------- |
| **Habit**             | Same non-recurring title completed ≥ 2× and the median interval is overdue, **or** one completion of a strong keyword (e.g. Dutch `boodschappen` / groceries) after ≥ 14 days | You                                        | —                                                              |
| **Calendar**          | Month-based prompts with no history required (Dutch examples: `belasting` in March, `schoolspullen` in August, `kerst` in December)                                           | You                                        | —                                                              |
| **Stale**             | Open task older than 7 days with no due date or reminder                                                                                                                      | You (sets a reminder on the existing task) | —                                                              |
| **Seasonal**          | Task completed in the same calendar month in a prior year                                                                                                                     | You                                        | —                                                              |
| **Family complement** | Keywords in **your** open tasks (including private)                                                                                                                           | Family-member suggestion                   | A **generic** template only — never the private title or notes |
| **Load balance**      | ≥ 3 open tasks in the same category (private included; `other` needs ≥ 5)                                                                                                     | Family-member suggestion                   | A generic “can you pick something up in [category]?” line      |


Family-member hints are capped at one per keyword-family per 14 days. **Send to family member** always shows **What your family member sees** before anything is sent. Nothing is auto-sent.

Suggestions appear in a banner on the **Private** tab and in structured sections on **Proposals** (**For you** / **For family member** / **From family member**). See `[apps/link/docs/SMART_FEATURES.md](apps/link/docs/SMART_FEATURES.md)` for reminder chips and send-sheet details.

## Encryption


| Key                | Scope                                                                                                                                                                                                                                                                                |
| ------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Personal vault** | 12 English BIP-39 words → PBKDF2 seed → 32-byte AES-256-GCM key. Encrypts personal tasks, notes, `.kvault` backups, and `vault.meta`. 16-byte entropy may be stored on-device so Settings can show the words again behind the device lock. Paper remains the only off-device backup. |
| **Family key**     | 12 BIP-39 words → derived AES-256-GCM key. QR carries 16-byte entropy (no WebDAV password). Fingerprint in settings. Recovered via `family.key.enc` after a personal vault restore. Optional **rotation** after removing a member re-encrypts `/kinetic/shared/**`. A 0.2.x random family key is kept as-is (no words until you create a new family vault). |
| **Kid UUID**       | Per enrolled child device for task targeting. Omitting `xKineticTargetKidId` assigns to **Everyone**                                                                                                                                                                                 |


On first launch the link app asks **New vault** or **Restore vault**. Restore is either a `.kvault` file plus the 12 words (offline) **or** WebDAV login plus the same 12 words (no file). After reinstall, the same phrase unlocks the server copy via `/kinetic/{user}/vault.meta`.

Export never includes the mnemonic, the raw key, or the WebDAV password. Settings can **verify** the phrase without showing the words, or **show** them after Face ID / fingerprint / PIN.

## Releases

`main` is **protected**: no direct pushes. Ship a version bump through a pull request (`release/x.y.z`), wait for required CI (`analyze-and-test`), merge to `main`, then tag **that** merge commit. A `v`* tag whose commit is not on `main` builds APKs but does **not** publish GitHub Releases.

```bash
# 1. Version bump PR (pubspecs + F-Droid metadata), merge to main
git checkout -b release/0.3.9
# bump apps/link + apps/kids to e.g. 0.3.9+8; update metadata/*.yml
git push -u origin HEAD
gh pr create --base main --title "Bump Kinetic to 0.3.9"

# 2. After the PR is merged:
git checkout main && git pull
git tag -a v0.3.9 -m "Kinetic 0.3.9"
git push origin v0.3.9
```

This creates **two separate releases**:

- `v0.3.9-kids` — `kinetic-kids-0.3.9.apk`
- `v0.3.9-link` — `kinetic-link-0.3.9.apk`

Each release includes a `sha256.txt` checksum file.

### Verifying release APKs



#### 1. APK file integrity (SHA-256 file hash)

`sha256sum` outputs a continuous lowercase hex string. This matches the value in `sha256.txt` and in the release notes.

```bash
echo "<digest>  kinetic-link-0.3.9.apk" | sha256sum --check
```

Or manually compare:

```bash
sha256sum kinetic-link-0.3.9.apk
# compare with the digest listed in sha256.txt
```



#### 2. Signing certificate fingerprint

AppVerifier shows the SHA-256 fingerprint of the **signing certificate** in `AA:BB:CC:DD:...` format (uppercase colon-separated pairs). This differs from the APK file hash above.

The certificate fingerprint is listed in the GitHub Release notes under **Certificate Fingerprint.**

```bash
keytool -printcert -jarfile kinetic-link-0.3.9.apk
# look for the SHA256: line — format is AA:BB:CC:DD:...
```

