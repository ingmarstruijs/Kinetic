# Future directions

Kinetic is a **local-first family protocol** (encrypted WebDAV, roster, kids loop, notes) — not a SaaS todo app.

**Keep:** no Kinetic account, no telemetry, BYO WebDAV.

---

## Near term

Practical product steps on the current two apps (Link + Kids). Ship these before chasing platform leaps.

### Setup & trust
- Guided **Start family** wizard: WebDAV → vault → members → kids
- Lighter kids enrollment (password-on-child is a heavy drop-off)
- First success moment: shared task / note / kid assignment
- Sync status UI — surface errors and conflict/recovery (many failures are silent)
- Family key rotation after removing a member (roster remove alone is not enough)

### Kids
- Deeper XP, goals, routines; Link week overview
- Kids on **iOS**
- Offline / local cache so kids are less WebDAV-dependent

### Household smarts (on-device)
- Drive shared load metrics (`/kinetic/shared/load/…`) into Suggestions / Tasks
- Stronger EN/NL heuristics (detectors still NL-heavy)
- Templates: shopping, weekly menu, holiday checklists

### Notes
- Shared templates and checklists
- Note ↔ task linking
- Clearer unlock vs sync privacy UX

### Distribution
- F-Droid / reproducible builds (metadata playbook already exists)

---

## Next level

Bigger bets that change how people *use* Kinetic — still without a Kinetic cloud.

### Kinetic Link Web (phone bridge)
Desktop/browser client that pairs to a phone Link session — **WhatsApp Web style**. Phone holds vault keys and WebDAV credentials; the browser is a thin encrypted UI over a local relay (QR + short-lived session), not a second full vault. Closes the “I want a big screen without retyping 12 words” gap while keeping keys on the phone.

### Shared family surfaces beyond phone lists
A wall / tablet / TV **family board**: who’s online, open kids tasks, shared notes — read-mostly from WebDAV + presence. Same protocol, new form factor (kitchen counter, not another personal inbox).

### Protocol costs and federation
Make the wire more than “files in a folder”: conflict-aware versioning, cheaper incremental sync, optional multi-server / guest access for babysitters without full family key. Kinetic as a **family sync protocol** others could implement — not only our Flutter clients.

### Kids as a game loop, not a task dump
Streaks, seasonal challenges, collaborative family quests (everyone completes → shared reward), parent “verify” as a social beat. Differentiator vs “chore checklist with XP sticker.”

### Ambient presence and load, not chat
No generic messenger. Instead: rich presence, load balance, “who’s drowning this week,” soft handoffs of proposals — household awareness without becoming Signal-with-todos.

### Cross-device continuity without accounts
Link Web + second phone + tablet all as **sessions on one vault**, not separate Kinetic identities. Session revoke from the primary phone. Closest thing to multi-device SaaS UX while staying local-first.

---

## Do not chase first

- Kinetic-owned cloud or accounts
- Generic chat / calendar clones
- Org / multi-tenant features before setup and kids are deep
- Cloud LLM “AI” that undercuts the privacy story
