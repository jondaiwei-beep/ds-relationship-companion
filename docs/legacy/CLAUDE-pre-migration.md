# CLAUDE.md — D/s Relationship Companion

Permanent execution rules for this repository. Read before any task.

---

## 1. Source of Truth

| Domain | Authority |
|---|---|
| Product goal, scope, user journeys, domain state, business rules, privacy, architecture, QA | **Notion CURRENT — Developer Handoff v2** |
| Visual direction, design system, page hierarchy, components, layout, typography, color, interaction presentation | **`docs/design/warm_authority_v5.html`** — extracted into **`docs/DESIGN_SYSTEM.md`** (Figma is currently unreachable; see IMPLEMENTATION_STATUS B-001) |

**Conflict rules**
- Design vs Notion on **business logic / scope / state** → **Notion CURRENT v2 wins.**
- Design vs Notion on **visual expression only** → **the current design (Warm Authority V5) wins.**
- Known conflicts are tracked in `docs/DESIGN_SYSTEM.md` §7. **Do not implement D-4 (Proposal), D-5 (Proof) or D-6 (Partner invitation card)** — these appear in the design but are out of Core Beta scope.
- Old Notion docs `01–42` and `ARCHIVE — Research, Previous Specs & Design History` are **evidence and history only**. They explain *why*. They can never override v2's *how*.
- **Never restore a feature from Archive that Core Beta explicitly removed.**

**Canonical documents (the only 7 read for execution)**

- `CURRENT — Developer Handoff v2 · Start Here` — https://app.notion.com/p/3c8f73841f3d81f4ae0ac63bb8767993
- `01 — Product Requirements v2` — https://app.notion.com/p/3c8f73841f3d816d88c0ce627fca963a
- `02 — User Journeys & Screen Contracts v2` — https://app.notion.com/p/3c8f73841f3d81a9910cfd2237909152
- `03 — Domain Model & State Contracts v2` — https://app.notion.com/p/3c8f73841f3d81edbbb7e6e47183b32c
- `04 — Platform, Privacy & Async Contract v2` — https://app.notion.com/p/3c8f73841f3d81efb5d1eb1b8ee8d328
- `05 — Content, Copy & Design System v2` — https://app.notion.com/p/3c8f73841f3d81d3817fec00ad34bdf1
- `06 — Engineering Build Plan v2` — https://app.notion.com/p/3c8f73841f3d81219aaacd38a4d6a931
- `07 — Metrics, QA & Release Gates v2` — https://app.notion.com/p/3c8f73841f3d8131b79cf3158f108d4d

Design reference: `docs/design/warm_authority_v5.html` · tokens and components in `docs/DESIGN_SYSTEM.md`
Figma file (blocked): https://www.figma.com/design/vM2rHvnJEsmDRfxxrqMku2

---

## 2. The Product Red Lines (never cross)

1. **Automation prepares; the partner responds.** The system may recommend, order, remind, generate a Starter Rhythm, and lower the Dom's maintenance cost. The system may **never** impersonate Partner praise, auto-punish, auto-judge a Miss as disobedience, replace a real Dom/sub with an AI persona, or confirm consent on either party's behalf.
2. **Completion ≠ Acknowledgement.** Only an explicit human `Send` creates an `Acknowledgement`. System suggestions must be visually distinguishable from human-authored content. Partner quotes may only render human-authored, human-sent content.
3. **Adjustment is a normal path, not a failure.** `Need to Discuss` / `Request a new time` / `Can't do right now` are never a Miss. Past due → `Needs Review` only — never automatic punishment or consequence.
4. **Agency is inviolable.** No role, at any time, may disable: Need to Discuss, Reschedule, Can't do, Pause, Leave, Block, or a member's own private-data controls. Role belongs to **Membership**, never to User as a permanent identity.
5. **Privacy is explicit and never widens implicitly.** Private / Shared-with-Dynamic / System-only must be explicit. Solo → Couple never auto-shares anything private. Neutral surfaces on lockscreen, email subject, and browser title by default.

**Server is the single business-state authority.** The client must never derive `missed`, `acknowledged`, `blocked`, `entitlement`, or relationship state from timestamps or local cache.

---

## 3. Core Beta Scope

**In scope**: Auth/session · Goal + minimal Dynamic setup · Starter Rhythm · Web-first Invite/Join · Today · Attention · basic Expectation · Ritual · Occurrence · Completion · Waiting for Human Response · Acknowledge/Praise/Comment · Check-in · Need to Discuss · Reschedule · Can't do · Needs Review · Pause/Resume · Leave/Block · Timezone/DST/day boundary · Android Push · Quiet Hours · neutral notification privacy · Recent Relationship Events · very light D7 Reflection · domain analytics + reliability observability.

**Explicitly OUT of Core Beta** (Public MVP / P1 / Later — do not add on your own initiative):
Full Agreement system · full Rules governance · Proposal system · complex permissions · full Explore library · complex Experience system · Proof · Points · Rewards · Consequences · Subscription/Paywall · advanced scheduling · 30/90-day analytics · AI Dom / AI Sub.

**Never build at all**: dating/partner discovery · community marketplace or feed · AI Dom/Sub persona · automated Partner praise · automatic punishment · compliance score · mandatory streak · explicit porn discovery · emergency safety alert service · "contract = consent certification".

### Feature Entry Rule
Before any new feature enters a Sprint, answer:
1. Does it affect **First Connected Dynamic Day**?
2. Does it affect the **Human Response Loop**?
3. Does it affect **Privacy / Reliability**?

If all three are **No** → Backlog by default. Do not insert into Core Beta.

---

## 4. Vertical Slice Discipline

The first link that must actually run end-to-end:

```
Flutter Android Creator → create minimal Dynamic → generate Invite
→ iPhone Safari opens Flutter Web → Join → one basic Expectation
→ Complete → Android Creator human Acknowledge → Web Partner sees response
```

During this slice: **do not** implement full Ritual / Check-in / Explore / Push / Rules. Starter Rhythm may *display* structure, but only **one basic Expectation** becomes a live Domain Event.

**Until the vertical slice is stable, do not expand 20 pages in parallel.**

---

## 5. Flutter Engineering Rules

One Flutter workspace produces both Android and Web.

```
app/            routing, bootstrap, environment, platform composition
features/       activation/ today/ attention/ dynamic/ us/   (feature-first, vertical)
domain_client/  API models, repositories, commands, current-state contracts
design_system/  tokens, typography, icons, shared components
platform/       push, deep link, secure storage, browser/session, lifecycle adapters
```

- **Never** organize the project long-term as `screens/ widgets/ services/ models/`.
- Share: API models, domain client, repositories, validation, feature state, design tokens, shared business UI, components.
- Isolate behind adapters: Android Push, secure storage, deep link, browser URL/back/refresh, magic-link callback, session persistence, app lifecycle, browser title/privacy, Web Push.
- **Never sacrifice correct Web or Android experience for 100% code sharing.**
- **One** state management solution. Never two in parallel.
- Web build requires its own responsive / browser-back / refresh / direct-URL QA. Never just scale the Android UI into a browser.

**Default stack (frozen at M0)**: Riverpod · go_router · Dio · freezed · json_serializable.
To change any of these: **write a short ADR first** (current approach / new approach / why / cost / risk) and wait for confirmation. Never swap directly.

---

## 6. Backend Engineering Rules

Modular monolith + one primary relational database + background worker + transactional outbox / DeliveryIntent.

Module boundaries (same deployment): Identity/Auth · Dynamic/Membership · Expectation/Occurrence · Response/Adjustment · Timeline/History · Delivery · Analytics.

- Server is the only business-state authority. Authorization is always server-side — never assume a hidden client button means the endpoint won't be called.
- Every state-changing command supports **idempotency key / unique transition protection**: Join invite, Complete occurrence, Send acknowledgement, resolve adjustment, Pause/Resume, Leave/Block. Retry never produces a second valid business action.
- Must be predictable: concurrent Android/Web Complete, Acknowledge then stale push tap, Leave while notification queued, Block while Partner page open, Invite revoke during auth, session expiry mid-mutation. **At most one valid state transition.**
- **Operational state and RelationshipEvent are separate tables.** RelationshipEvent is immutable history; it never replaces operational state.
- DB timestamps are **UTC**. Recurring schedules store **IANA timezone + local wall-clock semantics + day boundary** — never a bare UTC offset. Use a mature timezone library; never hand-maintain DST tables.
- Domain transaction writes operational change + RelationshipEvent + outbox atomically. Worker sends after commit, re-checking recipient access + current state + Quiet Hours + dedupe before send.
- Provider success/failure never changes business truth.
- API shape: resource + explicit command (`POST /occurrences/{id}/complete`), not a generic PATCH letting clients assemble state. `allowed_actions` is a UX convenience only — the command endpoint still authorizes.

**Do not build early**: microservices · generic workflow engine · universal rule DSL · AI orchestration · event sourcing as sole state store · complex permission framework · full CMS.

---

## 7. Design System Rules

### 7.0 What the structure must encode — 2026-08-28

Owner rules, stated after rejecting the previous design as generic. These
bind every visual direction and override anything below that conflicts.

**Four prohibitions**
1. *(reserved)*
2. No descriptive text elements. Do not fill space with explanatory prose.
3. No blue/purple dark mode. No cream ground + warm orange accent + retro
   serif headings — that combination is the current house style of
   AI-generated design and reads as exactly that.
4. No large-radius cards, no purposeless nested borders, restrained shadows.

**And the harder requirement: the design must be about D/s, structurally.**
A direction that would suit any private two-person collaboration app has not
done its job. This is not achieved with iconography — handcuffs, chains,
collars, crowns, leather, blackletter are forbidden (§7 Forbidden) and are
what a shop sells to a fantasy. It is achieved by encoding what is actually
true of the relationship:

1. **Asymmetry is the point, and it is chosen.** The two people are not
   interchangeable. Treating them as symmetrical peers describes a different
   relationship. But the asymmetry is negotiated — the software never
   assigns or enforces it.
2. **Authority is held by a person, never exercised by the system.** The
   direction-giving side's presence should be felt when they are absent; the
   app must still never speak for them.
3. **Consent is continuous and revocable.** Discuss, reschedule, can't-do,
   pause, leave, block are permanent rights. In most products "cancel" is a
   small grey link; here it is structural furniture.
4. **Ritual is repetition, not a streak.** The same small act done again is
   the substance. Never a counter to maintain.
5. **Waiting is part of the experience.** The gap between doing something
   and being answered is where the relationship lives — not dead time to
   minimise.
6. **Discretion is physical.** Over a shoulder, on a lockscreen, in a
   browser tab: nothing legible as D/s at a glance.
7. **Care underneath control.** Warmth and exactness at once. No scoring, no
   punishment language, no automatic consequence.

**Visual direction**: Quiet Authority · Warm Authority · Human Warmth · Ritual Identity · Discreet Maturity.

**Palette**: Bone `#F4F1EB` · Stone `#E7E3DA` · Warm Gray `#BAB6AC` · Deep Olive `#2F3A2E` · Dark Moss `#1E241F` · Terracotta `#B5533B`.
*Light Life, Dark Structure* — light living layer, dark authority/response moments.

**Type**: display serif (Notion 05 names Rovel Display / Lora; V5 uses a system serif stack — unresolved, see DESIGN_SYSTEM D-1). UI/body Inter.
**Shape**: mobile horizontal padding 20dp · card radius 10 · **primary CTA 48dp** (Notion 05 says 48–52dp; V5 renders 42px — use 48dp, see DESIGN_SYSTEM D-2) · few shadows · few pills · do not cardify everything.

**Full token set, component specs and screen inventory: `docs/DESIGN_SYSTEM.md`.** Read it before any UI task.

**Emotional emphasis hierarchy**: 1) Waiting for human response 2) Dom Attention priority 3) Acknowledgement Received 4) Partner Invite/Join trust. Settings and forms stay restrained.

**Allowed marks**: Authority Mark, Ritual Emblem, Partner Bond, Presence Mark, Guidance Mark, botanical line motif.

**Forbidden**: generic AI luxury · excess cards · excess pills · 3D/gloss · handcuff / whip / chain / flame / crown / demon / leather-panel BDSM-shop visuals · AI-generated people · KPI dashboard feel · default points / trophies / streaks.

**Copy**: voice is calm · private · intentional · warm · controlled · emotionally aware. System voice is low-emotion; Partner-generated voice carries the emotional peak.
**Forbidden terms**: Obey · Failure · Disobedient · Good slave · Bad sub · Compliance score · automatic punishment language.
**Backend state names never leak to users**: `NeedsReview` → "Needs review", never "FAILED". Copy mapping is centrally maintained.

---

## 8. Per-Task Execution Procedure

1. Find the matching Canonical Document.
2. Confirm: user problem · business state · UI state · platform difference · acceptance criteria.
3. **Inspect the actual repository.** Never assume a feature does or doesn't exist.
4. Implement the smallest complete vertical slice.
5. Run: lint · unit tests · state transition tests · integration tests · Flutter Android build · Flutter Web build · browser tests where applicable.
6. Produce a Review Package.

**No UI/UX task may auto-expand into adjacent pages before Review.**

### Definition of Done (every Epic)
Android + Web same business result · loading/empty/error/retry states · authorization + visibility · timezone semantics · analytics domain event · basic accessibility · no dead end · correct copy mapping · state transition automated tests · integration test covering one happy + one retry + one unauthorized path.

---

## 9. Review Queue Protocol

Every task needing product/UI/UX review gets an entry in Notion under `AI Implementation Review Queue`, titled:

```
[REVIEW] Milestone · Feature · YYYY-MM-DD
```

Required sections: **TASK · WHY · SOURCE · IMPLEMENTATION · ARTIFACTS · TEST RESULTS · STATE CHANGES · DEVIATIONS · OPEN QUESTIONS · REVIEW REQUEST**.

**ARTIFACTS rules**
- Never provide only a `localhost` URL — the reviewer cannot reach the developer machine.
- UI work must attach **PNG/JPG screenshots** even when a Figma URL or Web URL already exists.
- Include: design reference (Figma URL/node URL, or the V5 screen name) · Flutter Web staging URL · Android screenshot · iPhone Safari / Flutter Web screenshot · necessary state screenshots · commit hash / PR · changed-files summary.

**DEVIATIONS must be written proactively**: anything inconsistent with Figma, anything inconsistent with Notion, temporary implementations, technical limits, and assumptions made independently.

**REVIEW REQUEST** ends with exactly:
> Please review this implementation against product intent, UX, visual system, Flutter/Web behavior and Core Beta scope.

### Review Gate
Review returns one of: `APPROVED` · `APPROVED WITH MINOR FIXES` · `CHANGES REQUIRED` · `PRODUCT DECISION NEEDED`.

A product task may be marked **Done** only on `APPROVED`, or on `APPROVED WITH MINOR FIXES` once the minor fixes are complete.

On `CHANGES REQUIRED`: read the feedback → **do not re-explain the original requirement** → modify the original implementation → update the **same** Review Entry → mark Revision 2 / Revision 3 → update screenshots/URLs/commit → request review again.
**Never create a separate parallel implementation to bypass the original Review.**

If review feedback conflicts with a Canonical Document: **do not decide who is right.** Mark the entry `PRODUCT DECISION NEEDED` and list the two specific conflicting statements.

### UI Review Checklist (beyond "does it match Figma")
- Can the user understand the next step within seconds?
- Any unnecessary card / dashboard added?
- Is it starting to become a Task Manager?
- Does Human Response still visibly come from a real person?
- Does D/s power come from hierarchy / ritual / presence — not erotic iconography?
- Any points / streak / gamification stealing the core emotion?
- Does the receiving side feel Partner Presence?
- Does the direction-giving side gain mental load?
- Are Discuss / Reschedule / Can't do easy to find?
- Do Android and Web express the same Business Truth?
- Does Web support refresh / back / direct URL?
- Is privacy safe on lockscreen / browser / email?

---

## 10. Working Principle

The goal is not to implement every requirement. It is to use the smallest, most reliable, most testable implementation — without drifting from the product core — to validate as quickly as possible whether real couples will keep using:

**Expectation → Action → Human Response → Continue / Adjust**

> Build the smallest system that makes two real people feel a real, reliable partner response — then expand only where users prove they need more.
