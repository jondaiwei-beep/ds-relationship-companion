# PROJECT_CONTEXT.md

Concise orientation for anyone (human or agent) joining this project.

---

## What the product is

**A private companion that helps consensual adult D/s couples keep their dynamic present, responsive, and easier to maintain — especially when life or distance gets in the way.**

Internal framing: *lower the work of maintaining a Dynamic, without automating away the real human attention that makes the Dynamic meaningful.*

This is **not** a BDSM task tracker, and not a todo/habit app.

---

## Who the users are

**Primary** — adult couples already in, or actively trying, a consensual D/s dynamic.

**Design pressure case** — Android direction-giving member + iPhone Safari receiving member + long distance + different timezones. Not a target segment; the test baseline that exposes activation, async, timezone, privacy and human-response problems fastest.

**Secondary** — Solo users may establish a private rhythm first, but the **couple is the value unit**. Solo must never pull the MVP toward a personal habit tracker.

### Roles
Role belongs to **Dynamic Membership** — it is never a permanent User identity. Presets (Dominant / submissive / Switch / Custom) are a starting point only; Core Beta ships no permission matrix UI.

---

## Core value

Five research facts that stayed stable:
1. **Completion is not Connection.** Emotional value closes on Partner response, not on task completion.
2. **Dom mental load is the long-term pain.** Routine maintenance must approach tens of seconds, not become management work.
3. **LDR is the high-value stress case.** Async, timezones and absent physical presence amplify the value of ritual, response, notification and the Web companion.
4. **Blank Canvas is an industry-wide problem.** Guided setup / starter rhythm addresses "I don't know how to begin."
5. **Reliability is relationship trust, not an ordinary bug.** Wrong day, duplicate reminder, state confusion or privacy leak destroys the product's reason to exist.

### Differentiators
Human Acknowledgement · low Dom mental load · Web-first Partner Invite · LDR / async presence · reality fit · privacy & reliability.

---

## The core loop

```
Expectation → Action → Human Response → Adjustment / Next Expectation
```

Four relationship signals: **Expectation** (what we hope happens) · **Presence** (the dynamic is running even when we're not in sync) · **Response** (action was seen and answered by a real person) · **Adjustment** (reality changed, so we negotiate).

**The boundary that defines the product: _Automation prepares; the partner responds._**

### The two questions the product optimizes first
- **Receiving side:** "What is actually expected of me today?"
- **Direction-giving side:** "What actually needs my attention right now?"

### Success definition
**First Connected Dynamic Day** — two members in one Dynamic complete at least one meaningful bilateral event (completion + human acknowledgement, or shared check-in + partner response).

**North Star: Connected Dynamic Days / Active Couple / Week.** Many tasks and long sessions with weak partner response is **not** success.

---

## Flutter architecture

One Flutter workspace produces **Android (launch platform)** and **Web Companion (how iPhone users participate)**. Web is a full companion, not a landing page.

```
app/            routing, bootstrap, environment, platform composition
features/       activation/ today/ attention/ dynamic/ us/   (feature-first, vertical)
domain_client/  API models, repositories, commands, current-state contracts
design_system/  tokens, typography, icons, shared components
platform/       push, deep link, secure storage, browser/session, lifecycle adapters
```

**Shared**: API models, domain client, repositories, validation, feature state, design tokens, shared business UI.
**Adapter-isolated**: Android Push, secure storage, deep link, browser URL/back/refresh, magic-link callback, session persistence, app lifecycle, browser title/privacy, Web Push.

Shared code does not mean identical platform behavior. Web usability, privacy, and Android platform feel are never sacrificed for a single-codebase ideal.

**Stack (frozen at M0)**: Riverpod · go_router · Dio · freezed · json_serializable. Changing any of these requires an ADR first.

Practices: declarative routing supporting `/invite/{token}`, auth callback and current-state deep links · immutable DTO/state with generated serialization · repository/use-case boundary between UI and API · one state management solution only · idempotency key + retry policy on every mutation · Web gets its own responsive/back/refresh/direct-URL QA.

---

## Backend architecture

**Modular monolith + one primary relational database + background worker + transactional outbox / DeliveryIntent.**

Chosen because current complexity comes from business state, permissions, timezones and async consistency — not from traffic scale. Splitting into microservices early would add distributed transaction, debugging and schema-coordination cost.

Module boundaries within one deployment: Identity/Auth · Dynamic/Membership · Expectation/Occurrence · Response/Adjustment · Timeline/History · Delivery · Analytics.

### Non-negotiable backend contracts
- **Server is the sole business-state authority.** Clients never derive miss / acknowledged / block / entitlement from timestamps or cache.
- Authorization is server-side on every sensitive read and write.
- Every state-changing command is idempotent; retry yields at most one valid business action.
- **Operational state and RelationshipEvent are separate.** RelationshipEvent is immutable history.
- DB timestamps UTC; recurring schedules store IANA timezone + local wall-clock semantics + day boundary, never a bare UTC offset.
- Domain transaction writes operational change + RelationshipEvent + outbox atomically; the worker re-checks access, current state, Quiet Hours and dedupe before sending. Provider failure never alters business truth.
- API is resource + explicit command (`POST /occurrences/{id}/complete`), not generic PATCH.

### Core domain objects (Core Beta P0)
`User` · `Dynamic` (Draft → PendingPartner → Active ↔ Paused → Ended) · `Membership` · `Invite` (Pending → Accepted/Expired/Revoked) · `ExpectationDefinition` (kind = task | ritual — unified engineering definition, distinct product UI) · `Occurrence` (Scheduled → Active → WaitingAck → Acknowledged/Reviewed, with side paths NeedToDiscuss / RescheduleRequested / ExcuseRequested / NeedsReview / Excused / Cancelled) · `Completion` · `Acknowledgement` · `CheckIn` · `AdjustmentRequest` · `RelationshipEvent` · `DeliveryIntent`.

### State invariants
Join ≠ consent to future expectations · Role ≠ permission to remove agency · Completion ≠ acknowledgement · Discuss/refusal ≠ miss · Past due ≠ punishment · Pause stops future generation but never deletes history · Leave/Block cuts future shared access and delivery · template edits never rewrite historical occurrences · private visibility never widens on Solo → Couple.

---

## Core Beta scope

Auth/session · Goal + minimal Dynamic setup · Starter Rhythm · Web-first Invite/Join · Today · Attention · basic Expectation · Ritual · Occurrence · Completion · Waiting for Human Response · Acknowledge/Praise/Comment · Check-in · Need to Discuss · Reschedule · Can't do · Needs Review · Pause/Resume · Leave/Block · Timezone/DST/day boundary · Android Push · Quiet Hours · neutral notification privacy · Recent Relationship Events · very light D7 Reflection · domain analytics + reliability observability.

**Starter Rhythm default**: 1 Ritual + 1 core Expectation + 1 Check-in. A second Expectation is an optional suggestion, never a default.

**Information architecture**: bottom nav = Today · Dynamic · Explore (placeholder in Core Beta) · Us. Settings/Profile from the avatar. Solo: `Us = Me`.

---

## Non-goals

**Deferred to Public MVP / P1 / Later** — full Agreement system · full Rules governance · Proposal system · complex permissions · full Explore library · complex Experience system · Proof · Points · Rewards · Consequences · Subscription/Paywall · advanced scheduling · 30/90-day relationship analytics · AI Dom / AI Sub.

**Never built** — dating/partner discovery · community marketplace or feed · AI Dom/Sub persona · automated Partner praise · automatic punishment · compliance score · mandatory streak · explicit porn discovery · emergency safety alert service · "contract = consent certification".

The reason these are out: none of them block First Connected Dynamic Day or the Daily Human Response loop, and building them early turns the product back into the **D/s ERP** the research explicitly warned against.

---

## Source of Truth

| Domain | Authority |
|---|---|
| Product goal, scope, journeys, domain state, business rules, privacy, architecture, QA/metrics | Notion **CURRENT — Developer Handoff v2** + its 7 canonical documents |
| Visual direction, design system, hierarchy, components, layout, typography, color, interaction presentation | Figma **D/s Relationship Companion — Product Design** |

Conflict on **business logic / scope / state** → Notion CURRENT v2 wins.
Conflict on **visual expression** → current Figma wins.
Old docs `01–42` and the ARCHIVE are research evidence and decision history only — never an execution spec, and never grounds for restoring a feature Core Beta removed.

---

## Visual and copy direction

Quiet Authority · Warm Authority · Human Warmth · Ritual Identity · Discreet Maturity.
Palette: Bone `#F4F1EB` · Stone `#E7E3DA` · Warm Gray `#BAB6AC` · Deep Olive `#2F3A2E` · Dark Moss `#1E241F` · Terracotta `#B5533B` — *Light Life, Dark Structure*.
Type: Rovel Display (fallback Lora) for display, Inter for UI/body.

Voice: calm · private · intentional · warm · controlled · emotionally aware. The system voice stays low-emotion; the Partner-generated voice carries the emotional peak.

Avoid: generic AI luxury · card overload · pill overload · 3D/gloss · handcuff/whip/chain/flame BDSM-shop iconography · AI-generated people · KPI dashboard feel · default points/trophies/streaks.
