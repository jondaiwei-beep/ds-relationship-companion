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

## Open specification gaps — development blockers

1. `G-3` — complete legal Occurrence side-path transition graph and terminal states.
2. `G-1` — replace physically impossible “future delivery = 0” language with a precise cutoff for newly initiated provider calls after the membership transaction.
3. `G-2` — decide Block directionality, Dynamic termination, historical visibility and rejoin policy.
4. `G-4` — confirm whether an authenticated identity is mandatory to accept an invite; an invite token alone currently does not grant membership.

Source: [Domain Model v2](https://app.notion.com/p/3c8f73841f3d81edbbb7e6e47183b32c), [Developer Handoff v2](https://app.notion.com/p/3c8f73841f3d81f4ae0ac63bb8767993).
