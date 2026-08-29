# G-1 … G-4 · what the backend already enforces

`core-beta-state-contracts.md` lists four gaps as development blockers. Each one
already has a working, tested answer in `backend/`, written when the behavior was
built. This file extracts those answers so they can be **approved or corrected**
rather than re-derived.

Nothing here is a new product decision. It is a readout of running code, with the
source cited so any line can be checked. Where an answer looks wrong, the fix is a
product decision and the code should change to match — not the reverse.

Status: **awaiting product owner approval.** Until then the gaps stay open in
`core-beta-state-contracts.md`.

---

## G-3 · The Occurrence transition graph

Source: `backend/src/main/kotlin/com/dsapp/backend/expectation/domain/OccurrenceTransition.kt`
Tests: `backend/src/test/kotlin/com/dsapp/backend/expectation/OccurrenceTransitionTest.kt`

| From | May go to |
|---|---|
| `SCHEDULED` | `ACTIVE`, `NEEDS_REVIEW` (overdue sweep), `CANCELLED` |
| `ACTIVE` | `WAITING_ACK`, `NEEDS_REVIEW`, `NEED_TO_DISCUSS`, `RESCHEDULE_REQUESTED`, `EXCUSE_REQUESTED`, `CANCELLED` |
| `NEED_TO_DISCUSS` | `ACTIVE`, `EXCUSED`, `CANCELLED` |
| `RESCHEDULE_REQUESTED` | `ACTIVE`, `EXCUSED`, `CANCELLED` |
| `EXCUSE_REQUESTED` | `ACTIVE`, `EXCUSED`, `CANCELLED` |
| `NEEDS_REVIEW` | `WAITING_ACK`, `ACTIVE`, `EXCUSED`, `REVIEWED`, `CANCELLED` |
| `WAITING_ACK` | `ACKNOWLEDGED` — and nothing else |

Terminal: `ACKNOWLEDGED`, `REVIEWED`, `EXCUSED`, `CANCELLED`.

**The refusals carry the product meaning:**

- `NEED_TO_DISCUSS → WAITING_ACK` is forbidden. `WAITING_ACK` asserts a Completion
  exists; allowing this edge would manufacture a completion that never happened.
  A resolved discussion returns to `ACTIVE` and the person completes for real.
- `NEEDS_REVIEW → ACKNOWLEDGED` is forbidden for the same reason. A late
  completion goes `NEEDS_REVIEW → WAITING_ACK`, then a human acknowledges.
- `WAITING_ACK → REVIEWED` is forbidden. `REVIEWED` means something overdue was
  looked at; `ACKNOWLEDGED` means a person responded to you. Collapsing them would
  let "reviewed" masquerade as a partner response.
- Overdue leads to `NEEDS_REVIEW` and nowhere worse. No path in this graph is a
  miss, a failure, or a punishment.

**One UI consequence the design must honor.** Reschedule stores the original
occurrence as `CANCELLED` because no `RESCHEDULED` state exists. The UI must render
it as "Rescheduled to …" from the adjustment's resolution. Showing "Cancelled"
would read as a failure the person caused.

**Open question for the owner:** `NEEDS_REVIEW → REVIEWED` currently lets the
direction-giving side close an overdue item without the receiving side completing
it. That is deliberate — it prevents an old item hanging forever — but it is the
one edge that decides something on a person's behalf. Confirm it is wanted.

---

## G-1 · The delivery cut-off after Leave/Block

Source: `backend/src/main/kotlin/com/dsapp/backend/dynamic/application/LeaveBlockService.kt`

Notion 04 §8 asks for "future delivery = 0", which is not physically achievable
once bytes are with a provider. The implemented guarantee is:

> After the Leave/Block transaction commits, the system initiates **no new**
> relationship-delivery provider calls for that Dynamic. Every intent not already
> handed off is cancelled. A call initiated before the cut-off may still arrive and
> cannot be recalled.

The mechanism is a per-Dynamic Postgres advisory lock. Leave/Block takes it
exclusively; the delivery dispatcher takes it shared around its final authorization
check and provider call. Cancelling outbox rows alone would not close the
check-then-send race — the dispatcher may already have decided to send.

**For the owner:** this is weaker than the Notion wording and stronger than
anything achievable otherwise. If a stricter promise is needed, it has to be made
in the product copy ("may still receive one already-sent message"), not in code.

---

## G-2 · Block directionality, termination, visibility, rejoin

Source: `backend/src/main/kotlin/com/dsapp/backend/dynamic/application/LeaveBlockService.kt`

A Block is **recorded directionally but takes effect as a mutual separation**:

| Question | Implemented answer |
|---|---|
| Directionality | Recorded with an actor; enforced both ways |
| Dynamic termination | Yes — the Dynamic ends |
| Historical visibility | Shared history is sealed from both people |
| Rejoin | Prevented |
| Is the blocked person told who blocked them | **No, never** |

Two reasons, both safety: a one-way block that let the blocker keep browsing the
other person's history would be a surveillance asymmetry; and naming the blocker
hands a potentially unsafe person a fact to react to.

**For the owner:** sealing history from *both* sides is the strongest reading. If
the person who blocked should retain their own copy, that is a product decision and
the code must change.

---

## G-4 · Is an authenticated identity required to accept an invite

Source: `backend/src/main/kotlin/com/dsapp/backend/dynamic/application/InviteService.kt`,
`backend/src/main/kotlin/com/dsapp/backend/dynamic/api/DynamicController.kt`

**Yes — and the split is already built:**

| Endpoint | Auth | What it does |
|---|---|---|
| `POST /v1/invites/resolve` | **anonymous** | Previews the invitation: inviter's display name, state, intended role. Grants nothing. |
| `POST /v1/invites/join` | **authenticated** | Requires `actorUserId`; creates the Membership. |

So an invite token identifies a context and lets someone see who is inviting them
before deciding — but a token alone never grants membership. The guarded consume
(`WHERE state = 'PENDING' AND expires_at > now()`) makes concurrent joins resolve to
exactly one winner, and self-join is rejected.

This matches the design: `SCR-10 invitation-received` shows the invitation to an
unauthenticated visitor, and `client/test/features/join_threshold_test.dart` asserts
that signing in is not joining and that opening an invitation never joins by itself.

---

## If these are approved

Replace the "Open specification gaps" section of `core-beta-state-contracts.md`
with the resolutions above, and the four gaps stop blocking implementation of
adjustment, pause/resume and leave/block.

If any answer is wrong, say which one and what it should be. The code changes to
match the decision.
