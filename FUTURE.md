# Future directions

Kinetic is a **local-first family protocol** (encrypted WebDAV, roster, kids loop, notes) — not a SaaS todo app.

**Keep:** no Kinetic account, no telemetry, BYO WebDAV.

Roadmap below is the single source of priority. **Phase 1–3 shipped on `main`.** Phase 4 is next.

---

## Phase 1 — Setup, sync trust, tap-to-link — **shipped**

Family setup usable without a Kinetic cloud: sync status, Start-family wizard, same-server WebDAV rules, peer join prompts, turn-off sync, BLE tap-to-link (QR fallback).

---

## Phase 2 — Kids depth + trust — **shipped**

- [x] Lighter kids enrollment (draft vs active, password probe, orphan purge)
- [x] Kids offline / local cache UX (iOS target still pending — Kids ships Android today)
- [x] Deeper XP, goals, routines; Link kids overview
- [x] **Family key rotation** after removing a member (optional wizard)
- [x] F-Droid / reproducible builds path documented

**Done when:** kids enroll and sync reliably; Link can rotate family key after a kick; F-Droid path is clear.

---

## Phase 3 — Household smarts + notes — **shipped**

- [x] Drive shared load metrics (`/kinetic/shared/load/…`) into Suggestions / Tasks
- [x] Stronger EN/NL heuristics (whole-word / min-length; `test` no longer → Health)
- [x] Note templates, note ↔ task linking, clearer unlock vs sync / local-only privacy UX
- [x] Ambient presence and load — household awareness **without** becoming chat

**Done when:** categorize/load-balance suggestions are trustworthy; notes have a clear shared/privacy story; load metrics feed the UI.

### Multi-device test coverage

Protocol routes are covered in CI (fake dual-device harness), not by hand with phone+emulator. See [`docs/MULTI_DEVICE_TESTING.md`](docs/MULTI_DEVICE_TESTING.md).

---

## Phase 4 — Platform leaps

- **Kinetic Link Web** (phone bridge, WhatsApp Web style): browser UI; phone holds vault keys; QR + short-lived session
- Cross-device sessions on one vault + revoke from primary phone
- Family board (wall / tablet / TV) — read-mostly WebDAV + presence
- Protocol: incremental sync, guest access, federation
- Kids as a game loop: streaks, seasonal challenges, collaborative quests
- Kids on **iOS**

---

## Do not chase

- Kinetic-owned cloud or accounts
- Generic chat / calendar clones
- Org / multi-tenant features before Phase 4 depth
- Cloud LLM “AI” that undercuts the privacy story
- NFC phone-to-phone P2P
