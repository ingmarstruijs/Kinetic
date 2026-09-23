# Kinetic Link — Kids App

Child-facing Flutter app. Children see tasks assigned from Kinetic Link via a unique QR enrollment code, mark them done, and earn XP toward optional goals.

**WebDAV is required** — Kinetic Kids has no offline-only mode. Enrollment and every sync go through the same WebDAV server as Kinetic Link.

Kinetic Link themes, reminder picker, notes list, and the suggestion engine do **not** apply here. Enrollment uses a family-key QR **without** the WebDAV password; you type that password once on the kids device.

## Setup

1. Kinetic Link generates enrollment QR in Settings → Family → Kids → "Link kids app"
2. Show the QR to the child
3. Child opens Kinetic Kids app → scans QR → types the WebDAV password
4. Kid device is enrolled with:
   - WebDAV credentials (server, username, password typed on device)
   - Family key (for decryption)
   - Kid UUID (stored in secure storage as `kinetic_kid_id`)
5. Tasks are synced from `/kinetic/shared/tasks/` and filtered by this UUID (plus **Everyone** tasks with no target id)

## Screens

| Screen | Description |
|---|---|
| **Home** | Pending and completed task lists, XP progress / goal when Kinetic Link set one. Tap to open detail. Sync in the app bar. Confirm before completing. |
| **Task detail** | Category, priority, due date, XP reward, notes. **Done!** completes the task and queues a sync push. |
| **Settings** | Language, verify connection / presence, leave family. |

## How sync works

On startup and every app resume:
1. WebDAV credentials + kid UUID read from secure storage (set during enrollment)
2. `KidsSyncOrchestrator` pulls all files from `/kinetic/shared/tasks/` (family-key encrypted)
3. Each task's `xKineticTargetKidId` iCal property is checked; tasks matching this kid's UUID **or** with no target id (**Everyone**) are imported
4. Optional goal JSON is pulled from `/kinetic/shared/goals/{kidId}.json`
5. Tasks are merged into local SQLite (Last-Write-Wins on `updatedAt`)
6. Locally-completed tasks are pushed back to WebDAV

**First-time sync**: If the local database is empty and remote files exist, matching tasks are imported. Any subsequent local/remote changes use Last-Write-Wins merge.

## Development

```bash
cd apps/kids
flutter run        # run on device/emulator
flutter test       # run all tests
flutter build apk --release
```

Debug builds: **UI scenarios** on the enrollment screen, home menu, or Settings load named states (empty / chores / awaiting verification / XP goal / full) so you can use the app as if enrolled without WebDAV.

## Architecture

```
lib/
├── db/            — Drift schema (KidsTask model, XP/goal fields)
├── enrollment/    — QR scan screen, language picker, confirmation dialog
├── notifications/ — local completion / reminder notifications
├── settings/      — in-app settings
├── sync/          — KidsSyncOrchestrator (pulls shared tasks + goals), WebDavConfigRepository
├── task/          — home / detail screens, local repository
├── theme/         — Material 3 color schemes + header
└── main.dart      — root shell with enrollment flow
```

## Secure Storage Keys
- `kinetic_webdav_server_url` — WebDAV server URL
- `kinetic_webdav_username` — WebDAV username
- `kinetic_webdav_password` — WebDAV password
- `kinetic_webdav_personal_key` — Personal key (unused on kids device; set to dummy)
- `kinetic_webdav_family_key` — Family key (decrypts assigned tasks)
- `kinetic_kid_id` — This device's child UUID (for filtering xKineticTargetKidId)
