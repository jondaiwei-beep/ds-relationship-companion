# Core Beta domain and state contracts

Status: migrated from Notion CURRENT v2. UI labels may differ; state meaning may not.

## Objects and primary states

| Object | Contract |
|---|---|
| User | Account, display name, age gate, IANA timezone, notification/privacy preferences, account state. Role is not a User property. |
| Dynamic | Solo/Couple, desired outcome, structure, reference timezone/day boundary and pause information. `Draft → PendingPartner → Active ↔ Paused → Ended`. |
| Membership | User + Dynamic + role context + basic permissions + state. Discuss, Reschedule, Can't Do, Leave, Block and own-private-data control cannot be disabled by a partner. |
| Invite | `Pending → Accepted / Expired / Revoked`. Token identifies context but does not grant long-term access. |
| ExpectationDefinition | Shared engineering model with `task|ritual`; product UI keeps Task and Ritual distinct. |
| Occurrence | `Scheduled → Active → WaitingAck → Acknowledged / Reviewed`, plus Discuss, RescheduleRequested, ExcuseRequested, NeedsReview, Excused and Cancelled side paths. |
| Completion | Occurrence + actor + time + optional note. No Proof in Core Beta. |
| Acknowledgement | Explicit human Acknowledge/Praise/Comment/Review send. |
| CheckIn | Mood/energy/need/note + explicit visibility. |
| AdjustmentRequest | Discuss/Reschedule/Can't Do request, status, resolution, reviewer and timestamps. |
| RelationshipEvent | Immutable history/analytics fact, separate from operational state. |
| DeliveryIntent | Asynchronous delivery intent with privacy, delay, state and dedupe key. |

## Invariants

- Join is not consent to future expectations.
- Role cannot remove agency.
- Completion is not acknowledgement.
- Discuss/refusal is not a miss.
- Past due is not punishment.
- Pause stops future generation but preserves history.
- Leave/Block revokes future shared access and delivery.
- Editing a Definition does not rewrite historical occurrences.
- Private data never becomes shared automatically when Solo becomes Couple.
- Server authorization is required on every sensitive read/write.

## Time and retry

Timestamps use UTC; schedules retain IANA timezone + local wall-clock + relationship-day boundary. Client mutations use an idempotency key and return current resource/version. Stale deep links must resolve server current truth.

## Resolved specification decisions

The four gaps previously listed here as development blockers are resolved. Each
was already implemented and tested in `backend/`; the reasoning and the exact
source locations are in
[`g1-g4-implemented-answers.md`](g1-g4-implemented-answers.md).

### G-1 · Delivery cut-off after Leave/Block

"Future delivery = 0" is not physically achievable once bytes are with a
provider. The binding contract is:

> After the Leave/Block transaction commits, the system initiates **no new**
> relationship-delivery provider calls for that Dynamic. Every intent not
> already handed off is cancelled. A call initiated before the cut-off may still
> arrive and cannot be recalled.

Enforced by a per-Dynamic advisory lock held exclusively by Leave/Block and
shared by the dispatcher around its final authorization check, which closes the
check-then-send race. Product copy must not promise more than this.

### G-2 · Block semantics

A Block is recorded directionally and takes effect as a **mutual separation**:
it ends the Dynamic, seals shared history from both people, prevents rejoin, and
**never discloses who blocked whom**. A one-way block would create a
surveillance asymmetry; naming the blocker hands an unsafe person a fact to react
to.

### G-3 · Occurrence transition graph

| From | May go to |
|---|---|
| `SCHEDULED` | `ACTIVE`, `NEEDS_REVIEW`, `CANCELLED` |
| `ACTIVE` | `WAITING_ACK`, `NEEDS_REVIEW`, `NEED_TO_DISCUSS`, `RESCHEDULE_REQUESTED`, `EXCUSE_REQUESTED`, `CANCELLED` |
| `NEED_TO_DISCUSS` / `RESCHEDULE_REQUESTED` / `EXCUSE_REQUESTED` | `ACTIVE`, `EXCUSED`, `CANCELLED` |
| `NEEDS_REVIEW` | `WAITING_ACK`, `ACTIVE`, `EXCUSED`, `REVIEWED`, `CANCELLED` |
| `WAITING_ACK` | `ACKNOWLEDGED` — and nothing else |

Terminal states: `ACKNOWLEDGED`, `REVIEWED`, `EXCUSED`, `CANCELLED`.

Three edges are refused because each would let the system assert something that
did not happen:

- `NEED_TO_DISCUSS → WAITING_ACK` would manufacture a Completion. A resolved
  discussion returns to `ACTIVE`; the person then completes for real.
- `NEEDS_REVIEW → ACKNOWLEDGED` would do the same for a late item.
- `WAITING_ACK → REVIEWED` would let "reviewed" masquerade as "a person
  responded to you".

No path is a miss, a failure, or a punishment. Past due leads to `NEEDS_REVIEW`
and nowhere worse.

**UI requirement.** Reschedule stores the original occurrence as `CANCELLED`
because no `RESCHEDULED` state exists. Any surface showing it must render
"Rescheduled to …" from the adjustment resolution, never "Cancelled" — which
would read as a failure the person caused.

### G-4 · Authentication and invites

An authenticated identity is **mandatory** to accept an invite. The split is:

| Endpoint | Auth | Effect |
|---|---|---|
| `POST /v1/invites/resolve` | anonymous | Previews inviter name, state, intended role. Grants nothing. |
| `POST /v1/invites/join` | authenticated | Creates the Membership. |

An invite token identifies a context so someone can see who is inviting them
before deciding. A token alone never grants membership, signing in is not
joining, and opening an invitation never joins by itself.

Source: [Domain Model v2](https://app.notion.com/p/3c8f73841f3d81edbbb7e6e47183b32c), [Developer Handoff v2](https://app.notion.com/p/3c8f73841f3d81f4ae0ac63bb8767993).
