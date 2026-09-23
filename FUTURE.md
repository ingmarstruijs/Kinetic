# Future directions

Kinetic is already more than a todo app with sync: it is a **local-first family protocol** (encrypted WebDAV, roster, kids loop, notes). Expansion should deepen that protocol — not add a Kinetic cloud, accounts, or generic SaaS features.

**Constraints to keep:** no Kinetic account, no telemetry, BYO WebDAV. That is the sharpest product position.

---

## 1. Setup as a product (highest ROI)

Family features sit behind Settings + vault + QR + kids WebDAV password. That is the largest conversion drop-off.

- Guided **Start family** wizard: WebDAV → vault → family members → kids
- Less friction on kids enrollment (password-on-child is a heavy UX hit)
- First success moment: shared task / note / kid assignment

Without this, newer work (notes WYSIWYG, roster remove, kids visibility) stays underused.

## 2. Kids as a core product, not a plugin

Kids + Link verify is the differentiator vs generic todo apps.

- Deeper XP/goals, routines, Link week overview
- **Kids on iOS** (today Android-only) for Apple households
- Offline / local cache for kids where possible (today strongly online-dependent)

## 3. Household intelligence without cloud AI

Heuristics, proposals, and presence already exist. Shared **load metrics** are sketched on the wire (`/kinetic/shared/load/…`) but not fully driven from the apps.

- Push/pull load metrics and surface them in Suggestions / Tasks (“a family member has a lot open”)
- Stronger EN/NL heuristics (detectors are still NL-heavy)
- Templates: shopping, weekly menu, holiday checklists as note↔task bridges

Privacy-friendly “AI” here means on-device product value, not a buzzword.

## 4. Notes as a shared knowledge layer

Tasks and kids are strong; notes can make the tagline (“Tasks. Notes. Family.”) real.

- Shared templates and checklists
- Note ↔ task linking
- Clear privacy UX: what “require unlock” means vs what actually syncs

## Parallel: trust and distribution

- **Sync transparency** — surface errors and conflict/recovery state (many failures are silent today)
- **F-Droid / reproducible builds** — metadata playbook already exists; fits privacy-conscious parents
- **Family key rotation** — needed for full exclusion after removing a member (today roster remove does not rotate the shared key)

---

## What not to do first

- Kinetic-owned cloud or accounts (breaks the story)
- Generic chat or calendar clones
- Heavy multi-tenant / org features before setup and kids are deep
- Cloud LLM “AI” that undermines the privacy position

---

## Suggested order (6–12 months)

1. **Setup wizard + sync status** — makes everything more usable  
2. **Kids depth (+ iOS)** — product moat  
3. **Load metrics + smart household** — unique value on existing infra  
4. **Shared notes templates / note↔task** — breadth  
5. **F-Droid + key rotation** — trust and maturity  

---

## Strategic read

Treat Kinetic as a **family sync OS** with two clients (Link + Kids). Recent work (WYSIWYG notes, family management, kids visibility) is foundation. The large leap is removing **setup friction**, deepening **Kids**, and turning existing shared-folder primitives (roster, presence, load, proposals) into visible household features.
