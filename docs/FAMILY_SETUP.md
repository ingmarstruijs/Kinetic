# Family setup

**Prerequisite:** WebDAV configured and reachable — **same base URL** for every
family device. Without it there is no shared folder, no pairing, and no kids
sync. The **Family** settings section stays hidden until WebDAV is connected.

One Kinetic family = **one** shared folder tree (`/kinetic/shared/…`) encrypted
with **one** family key. Multiple usernames on that server are members of the
same family; any member’s invite joins the whole family.

Logins (username/password) may differ when the server grants everyone access to
that root. Personal data lives under `/kinetic/{username}/`, shared data under
`/kinetic/shared/`. Linking with a different server URL is **blocked** (QR /
BLE). Manual phrase entry does not carry a URL — configure the matching server
first.

## Family hub

After WebDAV is on, **Settings → Family** is the hub: status, invite/join,
members, kids link, and kids-task participation.

- **Day-1 nudge:** about a day after WebDAV without a family → Ignore / Remind
  in 7 days / Start guide.
- **Existing data on the folder:** after saving WebDAV, if another Kinetic user
  folder or shared roster is present → **Link now** or **Not now**. If
  `family.key.enc` exists for your username, the family key is restored
  automatically.

**Turn off sync** (WebDAV setup screen) stops sync and clears family/kids
linkage on this device; the personal vault and private local data stay.

## Family linking

1. **Settings → Family** → invite or join → share QR (12 family words + entropy)
   or tap-to-link (BLE); QR remains the fallback.
2. The other member scans, uses BLE, **or** types the 12 words and confirms the
   fingerprint — **server URL in the invite must match** their configured
   WebDAV URL.
3. Proposals and shared data sync via that same WebDAV server.

## Kids enrollment

1. **Settings → Family → Link kids** → generate QR with family key + kid UUID
   (no WebDAV password).
2. Child device scans the QR and types the WebDAV password once (same server).
3. The kid appears as **draft** until the kids app reports **presence**, then
   **active**.
4. Link forwards tasks to that child’s UUID, or to **Everyone** (no target id).

Ship Link **and** Kids at the same minor version when enrollment/QR formats
change.

After removing a member you can optionally **rotate the family key** so their
old key cannot decrypt new shared data.

## Sync protocol testing

How to write dual-device protocol tests:
[`SYNC_PROTOCOL_TESTING.md`](SYNC_PROTOCOL_TESTING.md).
