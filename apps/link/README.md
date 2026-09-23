# Kinetic Link

Adult-facing Flutter app (`apps/link`). Manage personal tasks and notes locally with an encrypted vault. **Family features** (family-member proposals, kids overview, shared notes, multi-device sync) require a configured WebDAV connection — without WebDAV those extras are unavailable.

## Screens

| Screen | Description |
|---|---|
| **Tasks** | Personal task manager — quick-add, swipe-to-complete, priorities, categories, due dates with separate date/time controls, recurrence. Enabling a reminder defaults to one hour from now rounded up to the next half hour; the time dialog focuses hours. **Smart reminder chips** propose contextual times based on title and history. **With WebDAV + family:** forward tasks to a link member, one kid, or **Everyone**; collapsible **suggestions** (self, family-targeted, incoming proposals) and **kids** section (assignments, XP, goals). Reminder notifications offer **Done** and **Snooze**. Task row icons: person+ = accepted family proposal. |
| **Notes** | Fullscreen markdown editor (edit/preview, GitHub-flavored checkboxes, formatting toolbar). Local private notes always; **Shared** section and share-with-family need WebDAV + pairing. List rows show title, last modified, and (for shared) audience — not body preview. Optional **require unlock**: opening needs device biometrics/PIN (flag is local; body still syncs as VJOURNAL DESCRIPTION when WebDAV is on). |
| **Settings** | Vault, themes, **Backup & Restore** (`.kvault`). **WebDAV** config and connection test unlock sync. **Family** (family-member QR, kids enrollment, presence) is only useful once WebDAV is connected. Debug builds also have **UI scenarios** for screenshots and manual QA. |

## Family Setup

**Requires WebDAV.** Pairing, proposals, kids enrollment, and shared folders all go through your server. Configure WebDAV in Settings before using Family.

### Family Member Linking
1. Settings → Family → Family members → "Share family key via QR"
2. Write down the 12 family words (quiz), then show the QR (entropy only)
3. The other family member scans **or** types the same 12 words and checks the fingerprint
4. Linking activated; `family.key.enc` is stored in the personal WebDAV folder

### Kids Enrollment
Each child device enrolls independently:
1. Settings → Family → Kids → "Link kids app"
2. Generate QR with family key + unique kid UUID (no WebDAV password)
3. Child device scans QR and types the WebDAV password once
4. Child receives tasks targeted to their UUID (or Everyone tasks with no target id)
5. Enrollment count shown in Settings

## Themes

Three Material 3 themes, chosen in **Settings**:

| Id | Label | Description |
|---|---|---|
| `light` | Default | Brand blue (original app icon in the header) |
| `calm` | Calm | Warm sand surfaces with terracotta accents (header logo tints to match) |
| `night` | Night | OLED black |

Legacy ids `sand` → `calm`, and `dusk` / `dark` → `night`.

## WebDAV Setup & Encryption Keys

First launch is a **vault gate**: create a 12-word BIP-39 phrase (with a 3-word quiz) or restore from a `.kvault` file **or** from WebDAV with the same phrase.

When enabling WebDAV later, the app uses the already-unlocked vault key. It writes `/kinetic/{user}/vault.meta` if missing, or checks that the canary decrypts. A mismatch means that server already has a different vault.

The personal key is **derived from the 12 words**, not from the WebDAV password. Export is always `.kvault` (encrypted, no key, no WebDAV password).

## Data Model

### Tasks
- `xpReward` (integer, default 10): XP the child earns when completing a task sent via "Send to kids". Configurable per task before sending.
- `targetKidId` (nullable): When set, task is encrypted as shared task with this UUID in `xKineticTargetKidId` iCal property. When **null**, the assignment is for **Everyone** — each kids device shows it (`xKineticTargetKidId` missing or empty). When set, only that child's UUID matches.
- `isContentHidden` (notes, local): When true, opening the note requires device unlock. Not synced to WebDAV; the body still syncs as usual. List rows never show body preview.

### Security
- **Personal vault**: 12 BIP-39 words → derived AES key stored on-device. The words and BIP-39 entropy are **not** stored; paper from onboarding is the only recovery. Settings can verify a typed phrase against the derived key.
- **Family Key**: 12 BIP-39 words (quiz on create); QR v2 entropy; fingerprint; `family.key.enc` on personal WebDAV. A 0.2.x random family key is kept (no words).
- **Has Other Link Members Flag**: Stored as `kinetic_has_other_link_members` secure storage key; set when QR pairing succeeds
- **Enrolled Kids List**: Stored as JSON in `kinetic_enrolled_kids` secure storage key; persisted on the Kinetic Link device (and shared via roster)

## Development

```bash
cd apps/link
flutter run        # run on device/emulator
flutter test       # run all tests
flutter build apk --release
```

All secrets are stored at runtime via secure storage — no `--dart-define` flags needed.

## Architecture

```
lib/
├── db/            — Drift schema (PersonalTasks with targetKidId column, PersonalNotes, LinkMemberProposals, AiSuggestions)
├── family/        — FamilyConnectionService + proposals (presence-based send gating)
├── l10n/          — ARB localizations (English template + Dutch)
├── notifications/ — local notification scheduling
├── secure/        — secure storage wrappers
├── settings/      — WebDAV config, theme, family key share/scan screens
├── sync/          — SyncOrchestrator (WebDAV pull/push, LWW merge, xKineticTargetKidId embedding)
├── theme/         — Material 3 themes (Default, Calm, Night) + KineticLogo tinting
├── todo/          — task & note models, repositories, screens (fullscreen note editor), reminder time helper, suggestion engine
├── vault/         — BIP-39 onboarding gate, restore (file / WebDAV), verify
└── main.dart      — root shell (Tasks, Notes, Settings)
```

## AI Suggestion Engine

A fully **offline, heuristic-based** engine that surfaces task suggestions in the **Tasks** screen. No API calls or external models are used.

See also: [docs/SMART_FEATURES.md](docs/SMART_FEATURES.md) for reminder chips, send gating, and suggestion UI details.

### How it works

The engine runs on start and resume. A path is throttled for 24 hours **only after it created at least one suggestion**. Empty runs do not block later hits.

Family-member-targeted detectors create suggestions — they do not auto-send proposals. Sending always goes through **What your family member sees**.

| Detector | Trigger | Action |
|---|---|---|
| **Habit** | Same non-recurring task ≥ 2× overdue vs median interval, or one strong-keyword completion after ≥ 14 days | Suggests re-doing the task (→ you) |
| **Calendar** | Month prompt (Dutch keyword examples: belasting / schoolspullen / kerst) with no prior-year history required | Suggests a seasonal chore (→ you) |
| **Stale** | Open task > 7 days with no due date or reminder | Suggests setting a reminder on that task (→ you) |
| **Seasonal** | Completed in the same calendar month last year | Suggests re-doing it (→ you) |
| **Family complement** | Keywords in **your** open tasks, including private | Generic family-member hint — never copies the private title (→ family member) |
| **Load balance** | ≥ 3 open tasks in the same category (private counted) | Generic “help with this category?” hint (→ family member) |

Each suggestion stores an `explanation` field. Template titles and reasons (load balance, family-member hints, calendar) are localized in the UI from the app language. Heuristic tables live in `lib/todo/services/suggestion_heuristics.dart`.

### Suggestion UI

- **Tasks screen**: `SuggestionsPanel` is a collapsible card above the list. Hidden when there is nothing pending.
- Sections: **For you**, **For family member** (when linked), **From family member** (inbox)
- **For you**: tap accepts (creates the task, applies a stale reminder, or assigns a category); swipe dismisses
- **For family member**: **Send** opens **What your family member sees**; **Decline** dismisses
- **From family member**: **Accept** / **Decline** on the incoming proposal
- Family-member-targeted proposals are marked `autoGenerated` in the database

Suggestions are stored in the local `AiSuggestions` table and never synced to WebDAV.

## Smart Reminder Chips

`ReminderProposalEngine` proposes contextual reminder chips when the Reminder row has no date set. Signals include habit time-of-day, habit interval, title keywords, category defaults, and time-of-day fallbacks. The best chip is marked with ✨; long-press shows why it was suggested.

## Connection-Aware Send

`FamilyConnectionService` evaluates link-member / kid connectivity from WebDAV presence (7-day connected / 14-day offline thresholds). The send sheet lists each family member individually with status, plus **Everyone** when more than one kid is enrolled. The send button is disabled when nobody is connected.

### WebDAV layout

```
/kinetic/{username}/
├── tasks/{uid}.ics        — personal tasks (personal key)
└── notes/{uid}.ics        — personal notes (personal key)

/kinetic/shared/
├── notes/{uid}.ics        — shared notes (family key)
├── proposals/{id}.json    — link-member proposals (family key)
├── load/{linkId}.json   — workload metrics (family key)
├── tasks/{uid}.ics        — tasks assigned to children (family key, with optional xKineticTargetKidId)
├── goals/{kidId}.json     — per-kid XP goals (family key)
├── presence/{deviceId}.json — heartbeat presence (family key, written every sync)
└── disconnect/{deviceId}.json — disconnect tombstone (family key, written on leave/remove)
```

### Backup Format
- **`.kvault` (current)**: JSON wrapper `{version, format: kvault, ciphertext}`. Ciphertext is AES-256-GCM with the derived vault key. Inner payload has the encrypted database blob and theme — **not** the mnemonic, raw key, or WebDAV password. Import requires the 12 words.
- Legacy `.kbak2` (plaintext `personalKey` in JSON) is **not** imported anymore. Use an in-app upgrade path on the old install, or restore from `.kvault` / WebDAV + phrase.

### Presence & Heartbeat Protocol
Every sync cycle each device writes an encrypted **presence file** to `/kinetic/shared/presence/{deviceId}.json` (family key). The file contains `deviceId`, `deviceType` (`'link'` or `'kid'`), `displayName`, and `lastSeen` (UTC ISO-8601).

- **Family members settings** reads presence files for other Link devices and displays a relative last-seen timestamp ("just now", "X minutes ago", etc.).
- **Kids settings** reads presence files for each enrolled kid, showing last-seen per kid in the list.
- Entries older than **14 days** are shown as a stale warning with error styling.

### Disconnect Tombstone Protocol
When a device explicitly leaves the family, it writes an encrypted **tombstone** to `/kinetic/shared/disconnect/{deviceId}.json` (family key) containing `deviceId`, `deviceType`, and `disconnectedAt`.

- **Link device leaves** (`_leaveFamily`): writes a link-device tombstone + deletes own presence file.
- **Link member removed** (`removeLinkMember`): another Link device writes a tombstone for the target id, updates the shared roster, and deletes their presence. On sync, the target clears its family key (same local cleanup as leave).
- **Kid removed** (`_confirmRemoveKid`): Kinetic Link writes a kid tombstone + deletes that kid's presence file.
- **Kids app**: on each sync, checks for its own tombstone; if found, invokes `onDisconnected` callback so the app can prompt the user.
- **link app**: on each sync, `_processDisconnects` runs before roster sync, reads all tombstones, invokes `onDisconnectsDetected` (self-id → leave cleanup), then deletes the tombstone files it processed.

## Conditional UI

Without WebDAV, Tasks stays a personal list (plus local “for you” suggestions). Family-member send, kids panel, incoming proposals, and shared notes only appear after WebDAV is connected and family is set up.

**Kids panel** on Tasks is only visible when:

- This Link device has **Kids tasks on this device** enabled (Settings → Family)
- At least one child is enrolled (`enrolledKidsCount > 0`)
- WebDAV config and sync are available so assignments can be loaded

With participation off, this device cannot see the kids panel, assign to kids, or verify completions. Enrollment (Settings → Kids) stays available. Other Link members keep their own setting; the roster stores each member’s `kidsParticipation` flag.

**Suggestions panel** on Tasks is hidden when there are no pending self suggestions, family-member-targeted hints, or incoming proposals.
