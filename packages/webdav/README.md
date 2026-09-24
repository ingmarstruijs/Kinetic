# Kinetic WebDAV

Shared sync, crypto, and serialization logic for Kinetic Link and Kinetic Kids.

## Family / server model

One Kinetic family lives on **one WebDAV base URL**. Personal trees are `/kinetic/{username}/`; shared trees are `/kinetic/shared/`. Logins may differ per person; the **server URL must match** for every Link and Kids device. Family QR / BLE invites include `url` — Link rejects a join when that URL does not match the device’s configured WebDAV URL. Manual 12-word entry has no URL; the matching server must already be configured.

Empty collections and non-`.ics` noise are ignored when detecting “existing data” during migration / first connect (PROPFIND is parsed per `<response>` block).

## Features

- **WebDAV client**: HTTP operations (PROPFIND, PUT, GET, DELETE) for file sync; `probeConnection()` distinguishes `ok` / `authFailed` / `noWebDav` / `unreachable`
- **Folder probe**: `KineticFolderProbe` lists other `/kinetic/{user}/` folders and checks shared roster/presence so Link can offer a fast family join after save
- **iCal serialization**: Parse and serialize tasks/notes as `.ics` files (RFC 5545) with custom properties
- **AES-256-GCM encryption**: End-to-end encryption of remote `.ics` / JSON with a random 32-byte key (PBKDF2 exists only as a legacy family-key helper)
- **Secure storage**: Hardware-backed secure storage abstraction
- **Sync orchestration**: Last-Write-Wins (LWW) merge strategy for multi-device sync

## Custom iCal Properties

Tasks and notes store metadata in escaped iCal DESCRIPTION field:
- `xKineticLinkTaskId` — ID of the Kinetic Link personal task this kids mission was created from
- `xKineticCategory` — Task category (for compatibility)
- `xKineticTargetKidId` — UUID of the child this task is assigned to. **Omitted / empty** means Everyone (all enrolled kids see it)
- `xKineticXpReward` — XP reward value

## QR Payload Formats

### Family Key Sharing (FamilyKeyShareScreen)
```javascript
{
  "v": 2,
  "type": "family",
  "url": "https://nextcloud.example.com/remote.php/webdav/",
  "user": "link@example.com",
  "ent": "<base64 16-byte BIP-39 entropy>"
}
```

The family-key payload does **not** include the WebDAV password. Each link device keeps their own WebDAV login. The scanner reconstructs the 12-word mnemonic from `ent` and derives the same 32-byte AES key. Family members can also type the words instead of scanning. The invite `url` must match the joiner’s configured WebDAV base URL (hard block on mismatch for QR / BLE).

### Kids Enrollment (KidsEnrollmentQrScreen)
```javascript
{
  "v": 2,
  "type": "kids",
  "url": "https://nextcloud.example.com/remote.php/webdav/",
  "user": "link@example.com",
  "key": "<base64-family-key>",
  "kid": "<uuid-for-this-child-device>"
}
```

v2 has **no** `pw`. The kids app asks for the WebDAV password after the scan. Import still accepts v1 payloads that include `pw`.

## Exports

### Classes

- `KineticEncryption`: AES-256-GCM, random keys, QR payloads
- `KineticVault`: BIP-39 mnemonic → 32-byte AES key, quiz helpers, `.kvault` wrap/unwrap, `vault.meta` canary
- `KineticVaultRemote`: GET/PUT `/kinetic/{user}/vault.meta`
- `WebDavClient`: HTTP client for WebDAV operations
- `SyncConfig`: Holds WebDAV credentials and encryption keys (personal/family)
- `SecureKeyValueStore`: Abstract base for secure storage implementations
- `PersonalTask` / `PersonalNote`: Domain models
- `LinkMemberProposal`: Domain model for family-member proposals
- `KidsTask`: Domain model for child-assigned tasks
- `KidGoal`: Per-kid XP goal document under `/kinetic/shared/goals/{kidId}.json`
- `KineticFolderProbe` / `KineticFolderProbeResult`: Discover peer Kinetic folders / shared family markers on a server
- `WebDavConnectionStatus`: Result of `probeConnection()` (`ok`, `authFailed`, `noWebDav`, `unreachable`)

### Key Methods

**KineticEncryption**:
- `generatePersonalKey()` / `generateFamilyKey()` → random 32-byte keys
- `deriveFamilyKey(password)` → PBKDF2-HMAC-SHA-256 (legacy / migration only)
- `exportFamilyKeyQrPayload(key, serverUrl, username)` → JSON string for QR
- `importFamilyKeyQrPayload(payload)` → `{familyKey, serverUrl, username}`
- `exportKidsEnrollmentQrPayload(familyKey, serverUrl, username, {password, kidId})` → kids enrollment QR (omit `password` for v2)
- `importKidsEnrollmentQrPayload(payload)` → `{familyKey, serverUrl, username, password, kidId}` (`password` empty on v2)
- `exportRecoveryJson(keyBytes, usernameHint)` → JSON with **plaintext** base64 `personalKey`
- `importRecoveryJson(jsonString)` → 32-byte key (no password)
- `encrypt(plaintext, keyBytes)` → AES-256-GCM ciphertext
- `decrypt(ciphertext, keyBytes)` → plaintext or throws on auth failure

**KineticVault**:
- `deriveAesKey(phrase)` → 32-byte AES key (BIP-39 PBKDF2-HMAC-SHA512, empty passphrase, first 32 bytes of seed)
- `generateMnemonic()` / `parseMnemonic()` / `isValidMnemonic()`
- `wrapBackup` / `unwrapBackup` → `.kvault`
- `sealCanary` / `openCanary` / `KineticVaultRemote.probe` / `ensureMeta`

**WebDavClient**:
- `propfind(path)` → `List<WebDavEntry>` for a collection (direct children only); empty dirs are collections, not “files”
- `probeConnection()` → `WebDavConnectionStatus` via authenticated Depth-0 PROPFIND (auth vs no WebDAV vs unreachable)
- `supportsWebDav()` → `true` when `probeConnection()` is `ok`
- `put(path, bytes)` → Upload file; optional `etag` for conditional PUT
- `get(path)` → Download raw bytes
- `delete(path)` → Delete file (404 treated as success)

**KineticFolderProbe**:
- `probe(client, username)` → other user folders under `/kinetic/` plus shared roster/presence flags (`suggestsExistingFamily`)

**SyncConfig**:
- Stores `serverUrl`, `username`, `password`, `linkId`
- Stores `personalKeyBytes` and optional `familyKeyBytes`
- Accessor: `baseUrl` (normalized WebDAV path)

## Secure Storage Keys

Each app's `WebDavConfigRepository.load()` reads these keys from secure storage:

```
kinetic_webdav_server_url        — WebDAV server URL
kinetic_webdav_personal_key       — Personal AES key (base64)
kinetic_webdav_personal_entropy   — leftover from older builds; wiped once the vault is ready
kinetic_webdav_username           — WebDAV username
kinetic_webdav_password           — WebDAV password
kinetic_vault_ready              — '1' after personal vault create/restore
kinetic_webdav_family_key         — Family AES key (base64, optional)
kinetic_webdav_family_entropy     — 16-byte BIP-39 entropy for family QR (optional)
kinetic_webdav_link_id          — Link device ID (optional)
kinetic_has_other_link_members            — '1' if another link member is linked, '0' otherwise
kinetic_enrolled_kids             — JSON list of enrolled kids (Kinetic Link)
kinetic_kid_id                    — This device's child UUID (kids only)
kinetic_family_setup_eligible_at  — ISO time when day-1 family nudge becomes eligible (Link)
kinetic_family_setup_prompt_skipped — '1' after Ignore on the family nudge (Link)
kinetic_family_setup_prompt_snoozed_until — ISO time until Remind-in-7-days expires (Link)
```

`disconnectWebDav` (Link) clears server URL / username / password and family/kids linkage keys, and resets the family-setup prompt keys. It does **not** wipe the personal vault key.

## Encryption Architecture

Remote files (`.ics`, proposal JSON, presence) are AES-256-GCM. Local SQLite is **not** encrypted.

### Personal Key
- 12 English BIP-39 words, shown at vault creation (3-word quiz, no skip)
- Derived with PBKDF2-HMAC-SHA512 (2048 rounds, salt `mnemonic`); first 32 bytes of the 64-byte seed are the AES-256-GCM key
- The derived key is stored in Flutter Secure Storage after unlock. Personal BIP-39 entropy is **not** stored, so the 12 words cannot be shown again. Paper (written during onboarding) is the only recovery.
- Encrypts: personal tasks, personal notes, `.kvault` backups, `/kinetic/{user}/vault.meta`
- **Not** derived from the WebDAV password. The same phrase unlocks a file restore and a WebDAV restore

### Family Key
- Same 12-word BIP-39 model as the personal vault; derived AES-256-GCM key
- QR v2 carries **16 bytes of entropy**, never the WebDAV password
- Fingerprint: first 4 hex chars of SHA-256(family key) for visual confirmation
- Encrypted copy at `/kinetic/{user}/family.key.enc` (wrapped with the personal key) so a personal-phrase restore also recovers the family key
- Kids enrollment QR v2 carries the family key **without** the WebDAV password; the kids app prompts for it. v1 payloads with `pw` still import.

### Kid-Specific Filtering
- Each kids device stores its unique `kinetic_kid_id` UUID during enrollment
- On sync pull, tasks with `xKineticTargetKidId != myKidId` and `xKineticTargetKidId != null` are filtered out
- Link can target tasks to specific kids by setting `targetKidId` in the DB column

## Backup Format

App-level combined backup lives in the link app (`FullBackupService.exportVaultToBytes`).

### `.kvault`
```javascript
{
  "version": 1,
  "format": "kvault",
  "exportedAt": "2026-08-20T12:34:56Z",
  "usernameHint": "link@example.com",
  "ciphertext": "<base64 AES-256-GCM>"
}
```

The ciphertext is the database snapshot (and theme) encrypted with the derived vault key. No mnemonic, no raw key, no WebDAV password.

### `vault.meta`
Small AES-GCM canary at `/kinetic/{username}/vault.meta`. Decrypt OK → right phrase. 404 → no vault on that server. MAC failure → wrong phrase.

Legacy `.kbak2` is neither written nor imported. `exportRecoveryJson` remains on `KineticEncryption` for tests only.

## iCal Format

Tasks and notes are serialized as iCalendar (RFC 5545) with custom properties:

**Task properties**:
- `SUMMARY`: task title
- `DESCRIPTION`: task notes
- `DTSTART` / `DUE`: dates
- `CATEGORIES`: category tag
- `X-KINETIC-PRIORITY`: priority level
- `X-KINETIC-ASSIGNED-TO`: child assignment
- `X-KINETIC-REPEAT`: recurrence rule (daily/weekly/monthly)
- `RRULE`: standard iCal recurrence

**Note properties**:
- `SUMMARY`: note title
- `DESCRIPTION`: markdown body
- `DTSTART`: creation date
- `X-KINETIC-SHARED`: true/false

## Testing

```bash
flutter test
```

Tests cover:
- Encryption/decryption round-trips
- iCal serialization/parsing
- WebDAV client with mocked HTTP (`probeConnection` auth / ok paths, PROPFIND response-block parsing)
- `KineticFolderProbe` peer / shared-marker detection
- Random key generation vs legacy `deriveFamilyKey`
- BIP-39 mnemonic checksum, seed prefix, `.kvault` wrap/unwrap, `vault.meta` probe

## Development

This package is pure Dart (Flutter-agnostic for serialization logic, but uses Flutter Secure Storage for key persistence).

```bash
dart analyze
dart format --set-exit-if-changed .
```
