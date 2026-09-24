# Future directions

Kinetic is a **local-first family protocol** (encrypted WebDAV, roster, kids loop, notes) — not a SaaS todo app.

**Keep:** no Kinetic account, no telemetry, BYO WebDAV.

Roadmap below is the single source of priority. Phase 1 shipped on `main`. **Phase 2 + 3** are in flight on `feature/phase-2-and-3`.

---

## Phase 1 — Setup, sync trust, tap-to-link — **shipped**

Family setup usable without a Kinetic cloud: sync status, Start-family wizard, same-server WebDAV rules, peer join prompts, turn-off sync, BLE tap-to-link (QR fallback).

---

## Phase 2 — Kids depth + trust

Ship next: make kids enrollment and ongoing kids loops trustworthy on more devices.

- Lighter kids enrollment (password UX, orphan kid-id)
- Kids on **iOS** + offline / local cache
- Deeper XP, goals, routines; Link week overview
- **Family key rotation** after removing a member
- F-Droid / reproducible builds ship

**Done when:** kids enroll and sync reliably on Android + iOS; Link can rotate family key after a kick; F-Droid path is clear.

---

## Phase 3 — Household smarts + notes

Ship alongside / right after Phase 2 depth: suggestions and notes that feel intentional, not noisy.

- Drive shared load metrics (`/kinetic/shared/load/…`) into Suggestions / Tasks
- Stronger EN/NL heuristics (e.g. stop short keywords like `test` matching Health → bogus categorize prompts)
- Shared note templates, note ↔ task linking, clearer unlock vs sync privacy UX
- Ambient presence and load — household awareness **without** becoming chat

**Done when:** categorize/load-balance suggestions are trustworthy; notes have a clear shared/privacy story; load metrics feed the UI.

---

## Phase 4 — Platform leaps

- **Kinetic Link Web** (phone bridge, WhatsApp Web style): browser UI; phone holds vault keys; QR + short-lived session
- Cross-device sessions on one vault + revoke from primary phone
- Family board (wall / tablet / TV) — read-mostly WebDAV + presence
- Protocol: incremental sync, guest access, federation
- Kids as a game loop: streaks, seasonal challenges, collaborative quests

---

## Do not chase

- Kinetic-owned cloud or accounts
- Generic chat / calendar clones
- Org / multi-tenant features before Phase 2–3 are deep
- Cloud LLM “AI” that undercuts the privacy story
- NFC phone-to-phone P2P
