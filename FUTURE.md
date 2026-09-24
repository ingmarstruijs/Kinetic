# Future directions

Kinetic is a **local-first family protocol** (encrypted WebDAV, roster, kids loop, notes) — not a SaaS todo app.

**Keep:** no Kinetic account, no telemetry, BYO WebDAV.

Roadmap below is the single source of priority. Phase 1 is in flight on `feature/near-term-and-link-web`.

---

## Phase 1 — Setup, sync trust, tap-to-link

Ship first: make family setup usable and pairing feel modern without a Kinetic cloud.

### Sync status
- Richer sync model: phase + last user-facing error + last success time
- Tap sync icon → status / error / Retry; Settings shows sync health
- Kids: visible syncing / error (not silent)

### Start-family wizard
- Guided flow: WebDAV → create/join family → invite member → enroll kid → first success (shared task or note) — **shipped** (Settings → Family → Start family; section hidden without WebDAV)
- Same WebDAV base URL required for the whole family; QR/BLE URL mismatch blocked — **shipped**
- Day-1 family nudge (Ignore / Remind 7d / Start) + post-save peer-folder “Link now” — **shipped**
- Turn off WebDAV sync (clears family/kids linkage on device; keeps vault) — **shipped**
- Clearer kids WebDAV-password step beside QR (password stays out of QR)

### Tap-to-link (Nearby / BLE)
- Hold phones close to share family key or kids enrollment — **same payloads as QR**, over BLE
- Host advertises, guest scans (RSSI), host confirms, then import as after QR
- QR remains fallback
- Not NFC P2P (broken cross-platform)

**Done when:** wizard works end-to-end; sync errors are visible and retryable; two Links can pair via BLE; QR still works.

---

## Phase 2 — Kids depth + trust

- Lighter kids enrollment (password UX, orphan kid-id)
- Kids on **iOS** + offline / local cache
- Deeper XP, goals, routines; Link week overview
- **Family key rotation** after removing a member
- F-Droid / reproducible builds ship

---

## Phase 3 — Household smarts + notes

- Drive shared load metrics (`/kinetic/shared/load/…`) into Suggestions / Tasks
- Stronger EN/NL heuristics (e.g. stop short keywords like `test` matching Health → bogus “Add N tasks to Health?”)
- Shared note templates, note ↔ task linking, clearer unlock vs sync privacy UX
- Ambient presence and load — household awareness **without** becoming chat

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
- Org / multi-tenant features before Phase 1–2 are deep
- Cloud LLM “AI” that undercuts the privacy story
- NFC phone-to-phone P2P
