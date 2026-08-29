# Open Specification Gaps

Raised by adversarial review (Codex, 2026-08-27) against the Notion v2 contracts.
These are **genuine under-specifications**, not implementation bugs. Each must be
resolved before the feature it governs is built — not before M0 completes.

---

## G-1 · Leave/Block delivery guarantee — ✅ CLOSED 2026-08-27

**Contract** (Notion 04 §8): after Leave/Block, future delivery must be zero, and must
not depend on client refresh.

**Problem**: once bytes have left the process to a push/email provider, no database
transaction can recall them. A send already in flight cannot be un-sent.

**Proposed resolution** — restate the guarantee as:
> After the leave/block transaction commits, **no new provider call may begin.**
> A send already in flight may complete.

Implementation: the dispatcher re-reads access state inside the claim transaction
immediately before sending. Blocks the entire class except a send already past that check.

**RESOLVED and implemented.** The canonical wording should become:

> After the Leave/Block transaction commits, the system initiates **no new**
> relationship-delivery provider calls for that Dynamic. Every intent not
> already handed off is cancelled. A call initiated before the cut-off may
> still arrive and cannot be recalled.

**Mechanism** (the part that actually closes it): cancelling outbox rows is not
enough, because a dispatcher may have already passed its access check and be
about to call the provider. A per-Dynamic Postgres advisory lock fences it —
Leave/Block takes it EXCLUSIVELY, the dispatcher takes it SHARED around its
final authorization check and provider call. `FAILED` rows are cancelled too,
so none can be retried past the cut-off.

---

## G-2 · Block semantics — ✅ CLOSED 2026-08-27

Unanswered: Is block directional or mutual? Does it end the Dynamic? Can the blocker
still read shared history? Can either party ever rejoin?

**RESOLVED and implemented.** A block is recorded **directionally** ("A blocked B")
but takes effect as a **mutual separation**:

| Question | Decision |
|---|---|
| Directional or mutual? | Recorded directionally, **mutual in effect** |
| Does it end the Dynamic? | **Yes, permanently.** Blocking is not a pause |
| Can the blocker read shared history? | **No** — a one-way block would be a surveillance asymmetry |
| Can the blocked person read shared history? | **No** |
| Can either rejoin? | **No** — invites are revoked |
| What is the blocked person told? | **Nothing naming the blocker.** Telling someone "X blocked you" hands an unsafe person a fact to react to |

History itself is never deleted: `relationship_events` stays append-only, so a
safety action does not destroy the record of what happened.

---

## G-3 · Occurrence side-path transition graph — ✅ CLOSED 2026-08-27

Notion 03 §2 lists the states and side paths but never defines the **full legal
transition graph**. Specifically undefined:
- Can `NeedToDiscuss` → `WaitingAck`, or must it return to `Active` first?
- Can `NeedsReview` → `Acknowledged`, or only → `Reviewed`?
- Can `RescheduleRequested` / `ExcuseRequested` resolve back to `Active`?
- Which states are terminal?

V1 currently treats `ACKNOWLEDGED, REVIEWED, NEED_TO_DISCUSS, EXCUSED, CANCELLED`
as terminal for the "one non-terminal occurrence per definition per day" index. **The
inclusion of `NEED_TO_DISCUSS` as terminal is an assumption and is likely wrong** —
discussion should probably return to an active path.

**RESOLVED.** The complete graph is now encoded in
`backend/.../expectation/domain/OccurrenceTransition.kt` with 8 unit tests.
The refusals are the substantive decisions:

- `NEED_TO_DISCUSS → WAITING_ACK` **forbidden** — WAITING_ACK means a Completion
  exists, so this edge would manufacture a completion that never happened.
  Resolving a discussion returns to `ACTIVE`; the person then completes for real.
- `NEEDS_REVIEW → ACKNOWLEDGED` **forbidden** — same reason. A late completion
  goes `NEEDS_REVIEW → WAITING_ACK`, then a human acknowledges.
- `WAITING_ACK → REVIEWED` **forbidden** — otherwise "reviewed" could masquerade
  as "someone responded to you".
- Terminal: `ACKNOWLEDGED, REVIEWED, EXCUSED, CANCELLED`. `NEED_TO_DISCUSS` is
  deliberately NOT terminal, so an open discussion still blocks a duplicate
  occurrence for the same definition and day.
- Reschedule stores the original as `CANCELLED` linked to a replacement; the UI
  must render that as "Rescheduled to …", never "Cancelled".

---

## G-4 · Invite trust model unspecified

Notion 04 §2 says the token "locates Invite context, does not grant long-term access",
but does not state whether **possession of the link alone** is sufficient to join, or
whether joining requires an authenticated identity.

**Recommendation** (adopted in V1 pending confirmation): authenticated identity required,
plus a one-time, expiring, revocable 256-bit token of which **only the SHA-256 hash is
stored**. V1 stores `token_hash bytea` and never the token itself.

**Owner decision needed before**: M1 (this is in the vertical slice).

---

## G-5 · Idempotency key lifetime

"Retry is always safe" and short retention are incompatible. If a key row is deleted,
a late retry executes the command a second time.

**Recommendation**: retain a permanent `(actor, key, request_hash, outcome)` tombstone
even after the stored response body is archived.

**Owner decision needed before**: M1.

---

## G-6 · Immutable history vs. deletion/privacy

`relationship_events` is append-only (enforced by trigger). This can conflict with
account deletion and privacy obligations.

**Mitigation adopted**: keep identifying or intimate free text **out of event payloads**.
Events carry opaque IDs; redactable content lives in operational tables which can be
deleted.

**Owner decision needed before**: Public MVP (Account Delete).

---

## G-7 · Outbox scope

"Every domain transaction writes an outbox record" needs bounding — a display-name edit
does not warrant one.

**Interpretation adopted**: every **relationship** business event gets exactly one outbox
envelope. Profile/settings edits do not.
