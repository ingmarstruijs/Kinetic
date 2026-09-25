# Multi-device testing

Kinetic is multi-device by design (Link↔Link, Link↔Kids over one WebDAV family
root). Manual QA with one phone + one emulator cannot cover every sync route.
**Protocol behaviour belongs in CI** via the fake dual-device harness.

## Layers

| Layer | What | Where |
|-------|------|--------|
| **1 — Fake dual-device** | Two+ orchestrators on one `SharedStorage` | `package:kinetic_webdav/testing.dart` + `*roundtrip_test.dart` |
| **2 — Scenario matrix** | Named flows (enroll, kick, rotate, leave, offline) | See checklist below |
| **3 — Real server (optional)** | Docker Nextcloud smoke | Only if fake HTTP misses etag/auth bugs |
| **UI scenarios** | Look-and-feel / screenshots | Debug “UI scenarios” — **not** sync proof |

## Harness

```dart
import 'package:kinetic_webdav/testing.dart'; // SharedStorage, FakeHttpClient

final storage = SharedStorage();
final alice = await makeLinkOrchestrator(dbA, storage, ...);
final bob = await makeLinkOrchestrator(dbB, storage, ...);
await alice.orchestrator.syncWithService(alice.service);
await bob.orchestrator.syncWithService(bob.service);
```

- Link: `apps/link/test/helpers/sync_test_harness.dart`
- Kids: `apps/kids/test/helpers/sync_test_harness.dart`
- Family key for fakes: `syncTestFamilyKey` / `kidsSyncTestFamilyKey` (same bytes)

## Scenario matrix (CI)

| ID | Flow | Status | Test file |
|----|------|--------|-----------|
| B1 | Draft kid → kid presence → **active**; peer sees kid | ✅ | `apps/link/test/sync/roster_roundtrip_test.dart` |
| B1b | Alice enrolls draft → Bob sees draft on roster | ✅ | same |
| B3 | Kids offline complete → dirty → sync → Link pending | ⏳ | kids + link shared tasks |
| B4 | Kids leave/wipe local tasks+XP | ✅ | `apps/kids/test/sync/leave_family_wipe_test.dart` |
| B5 | LoadMetrics Alice push → Bob pull | ✅ | `apps/link/test/sync/load_metrics_roundtrip_test.dart` |
| B6 | Local-only note never PUT | ✅ | `apps/link/test/sync/local_only_notes_sync_test.dart` |
| B7 | Family key rotation: old key cannot read new shared | ⏳ | vault + `reencryptSharedTree` |
| B8 | Recurring kids accept → next due + RRULE | partial | `kids_shared_tasks_roundtrip_test.dart` |

## Manual (keep short)

1. QR / camera + password dialog (once per release)
2. Ambient chips / notes editor UX
3. iOS TestFlight enroll
4. F-Droid build path

## Do not chase yet

- Device farm / Patrol multi-APK BLE
- Full UI integration_test for every Tasks screen
- 3+ Link devices until A/B matrix is green

## Adding a scenario

1. Prefer extending an existing `*roundtrip_test.dart`.
2. One `SharedStorage` in `setUp`; alternate `syncWithService`.
3. Assert **wire state** (roster / presence / blobs) and **local repo** where needed.
4. Update the matrix table above.
