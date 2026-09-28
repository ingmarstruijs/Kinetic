# Sync protocol testing

Advanced guide for **protocol tests** across Link↔Link and Link↔Kids on one
shared WebDAV family root. These tests run in CI. They are not UI screenshot
flows and not a substitute for a real Nextcloud smoke when debugging HTTP/etag
quirks.

## Idea

Spin up two (or more) sync stacks that share an in-memory blob store
(`SharedStorage` + `FakeHttpClient`). Each stack has its own DB, personal key,
and username — same family key — then alternate `syncWithService` and assert
wire state + local repos.

```dart
import 'package:kinetic_webdav/testing.dart'; // SharedStorage, FakeHttpClient

final storage = SharedStorage();
final alice = await makeLinkOrchestrator(dbA, storage, ...);
final bob = await makeLinkOrchestrator(dbB, storage, ...);
await alice.orchestrator.syncWithService(alice.service);
await bob.orchestrator.syncWithService(bob.service);
```

## Harness locations

| Piece | Path |
| --- | --- |
| Shared fakes | `package:kinetic_webdav/testing.dart` |
| Link helper | `apps/link/test/helpers/sync_test_harness.dart` → `makeLinkOrchestrator` |
| Kids helper | `apps/kids/test/helpers/sync_test_harness.dart` |
| Family key bytes | `syncTestFamilyKey` / `kidsSyncTestFamilyKey` (must match across apps) |
| Personal keys | `syncTestPersonalKeyA` / `B` (different per “device”) |

Typical Link setup:

- One `SharedStorage` per test (`setUp`).
- Separate `AppDatabase` + `WebDavConfigRepository` per participant.
- Pass `configRepo` when the flow needs roster sync; save the family key on
  that repo (the helper can do this).
- Distinct `username` / `linkId` per device; same `familyKeyBytes`.

## Patterns that work

1. **Push then pull** — Alice mutates local state → Alice sync → Bob sync →
   assert Bob’s repo / cached roster.
2. **Dirty queue** — Kids (or Link) completes offline → mark dirty → sync →
   peer sees pending / completed on next pull.
3. **Wire + local** — Prefer asserting both shared blobs (roster, presence,
   tasks under `/kinetic/shared/…`) and the local Drift view when the UX
   depends on both.
4. **Key isolation** — After rotation, prove the old family key cannot decrypt
   new shared ciphertext (see webdav package tests).
5. **Negative paths** — Local-only notes must never PUT; leave/wipe must clear
   local kids cache.

## Writing a new scenario

1. Prefer extending an existing `*roundtrip_test.dart` over a new file.
2. `setUp`: fresh `SharedStorage`; enable
   `driftRuntimeOptions.dontWarnAboutMultipleDatabases` in `setUpAll` when
   opening several DBs.
3. Build participants with the harness; sync in the order the product would
   (writer first, then readers).
4. Assert concrete ids, names, `isActive`, syncState, or decrypted payloads —
   not just “no throw”.
5. Add the file to the inventory below.

Run:

```bash
# from repo root
melos run test

# targeted
cd apps/link && flutter test test/sync/roster_roundtrip_test.dart
cd apps/kids && flutter test test/sync/
cd packages/webdav && dart test
```

## Inventory

| Flow | Package | File |
| --- | --- | --- |
| Draft kid → presence → active; peer sees kid | link | `test/sync/roster_roundtrip_test.dart` |
| Alice enrolls draft → Bob sees draft | link | same |
| Kids offline complete → dirty → Link pending | kids | `test/sync/kids_sync_roundtrip_test.dart` |
| Kids leave / wipe local tasks + XP | kids | `test/sync/leave_family_wipe_test.dart` |
| LoadMetrics Alice → Bob | link | `test/sync/load_metrics_roundtrip_test.dart` |
| Local-only note never PUT | link | `test/sync/local_only_notes_sync_test.dart` |
| Family key rotation (old key cannot read new shared) | webdav | `test/webdav_sync_service_test.dart` |
| Recurring kids accept → next due + RRULE | link | `test/sync/kids_shared_tasks_roundtrip_test.dart` |

## What stays outside this harness

| Kind | Role |
| --- | --- |
| **Debug → UI scenarios** | Look-and-feel / screenshots only — not sync proof |
| **Real WebDAV (optional)** | Docker Nextcloud when fakes miss etag/auth/locking bugs |
| **Manual smoke** | Camera QR, password dialog, iOS enroll — once per release, keep short |

Do not try to prove multi-device sync with one phone + one emulator for every
route; put the protocol assertion in a roundtrip test instead.
