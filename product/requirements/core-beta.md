# Core Beta requirements

Status: **migrated draft**. IDs are stable GitHub identifiers. Requirement meaning must be reconciled with the cited Notion CURRENT v2 sources before a screen can become `ready_for_build`.

## Foundation

| ID | Requirement | Core acceptance |
|---|---|---|
| `REQ-AUTH-001` | Android and Web support magic-link authentication, session recovery and sign out. | Invite context survives authentication; expired/shared-device sessions land safely. |
| `REQ-TRUST-001` | Entry surfaces communicate 18+, Terms, Privacy and private-by-default behavior in neutral language. | No role or invite silently grants consent or visibility. |
| `REQ-TIME-001` | Store IANA timezone, local wall-clock schedule and one custom relationship-day boundary. | DST and device timezone changes do not silently move a relationship day. |

## Activation

| ID | Requirement | Core acceptance |
|---|---|---|
| `REQ-ACT-001` | Ask the desired outcome before role or configuration. | Goal options: Closer, Structure, Service & devotion, Accountability, Explore together. |
| `REQ-ACT-002` | Minimal setup collects Couple/Solo, starting role preset, structure level and boundaries lite. | Timezone is detected; LDR/Together is a lightweight choice; role never removes agency. |
| `REQ-ACT-003` | Starter Rhythm begins with one Ritual, one core Expectation and one Check-in. | User can keep/replace items and start without filling a complex builder. |
| `REQ-INVITE-001` | Creator can share a private Web invite and see Pending/Accepted/Expired/Revoked state. | Retry/reopen resolves server current truth; no opaque 404. |
| `REQ-JOIN-001` | Web Join explains inviter, shared intention, shared/private boundary and leave right. | Invitee confirms explicitly and does not repeat the creator's full onboarding. |
| `REQ-FIRST-001` | Activation ends in a small shared interaction, not an empty success page. | First interaction can enter the Human Response loop. |

## Daily relationship loop

| ID | Requirement | Core acceptance |
|---|---|---|
| `REQ-TODAY-001` | Receiving Today shows what matters in 10 seconds. | Priority: partner/context → 1–3 expectations → ritual → recent response → check-in → later/optional. |
| `REQ-ATTN-001` | Direction-giving Attention prioritizes meaningful human work. | Discuss/support → Waiting Acknowledgement → Needs Review → low priority; common responses work inline. |
| `REQ-EXPECT-001` | UI distinguishes Task and Ritual while engineering may share one Definition model. | Cards show title, sender, time/due context and meaning without requiring detail. |
| `REQ-COMPLETE-001` | Completion creates a separate Waiting for Human Response moment. | UI says completed and waiting; Completion is never presented as acknowledgement. |
| `REQ-ACK-001` | Acknowledge, Praise, Comment and Review are explicit human sends. | Basic acknowledgement is at most two taps; partner-authored content is visually distinct from system copy. |
| `REQ-CHECKIN-001` | A member can share mood, energy, need and optional note, or keep it private. | Visibility is explicit and never expands automatically from Solo to Couple. |
| `REQ-ADJUST-001` | Active occurrences allow Discuss, Request New Time and Can't Do. | These are normal paths, not misses; partner may Continue, Adjust, Reschedule, Excuse or Cancel. |
| `REQ-REVIEW-001` | Past-due active work becomes Needs Review. | The software does not assign punishment or consequence. |

## Reality, privacy and retention

| ID | Requirement | Core acceptance |
|---|---|---|
| `REQ-PAUSE-001` | Either member can Pause and later Resume same/lighter/adjusted. | Pause creates no recurring backlog and Resume does not require old completion. |
| `REQ-LEAVE-001` | A member can leave without partner approval. | Future shared access and newly initiated delivery stop; history policy is explicit. |
| `REQ-BLOCK-001` | Block immediately cuts future access, invite/reconnect paths and delivery. | Stale pages/links land neutrally and do not reveal sensitive relationship content. |
| `REQ-PRIVACY-001` | Every sensitive object is Private, Shared with current Dynamic, or system-only metadata. | Server checks membership, visibility and current access relation on every sensitive read. |
| `REQ-NOTIFY-001` | Notifications are neutral, event-driven, deduplicated and Quiet-Hours aware. | Payload contains locator data, not sensitive text; stale reminders resolve current state. |
| `REQ-HISTORY-001` | Us shows recent real relationship events. | System reminders are not presented as connected moments. |
| `REQ-WEEKLY-001` | D7 Reflection is one light Keep/Adjust/Pause surface. | No performance score, saved-moment system or complex private reflection in Core Beta. |

## Reliability

| ID | Requirement | Core acceptance |
|---|---|---|
| `REQ-STATE-001` | Server is the only business-state authority across Android and Web. | Clients do not derive missed, acknowledged, blocked or entitlement from local timestamps/cache. |
| `REQ-IDEMP-001` | Join, Complete, Acknowledge, adjustment resolution, Pause/Resume and Leave/Block are idempotent. | Retry produces at most one effective business transition. |
| `REQ-RECOVERY-001` | Every buildable screen defines loading, empty, error/retry, offline, stale and authorization-loss behavior. | No dead end; recovery preserves privacy and current server truth. |

## Explicitly outside Core Beta

Shared Agreement UI, full Rules governance, Proposal workflow, advanced permission matrix, full Explore/Experience, advanced memory/private reflection, subscription/paywall, Proof, points/rewards/consequences and advanced travel scheduling remain Public MVP/P1 references.

Sources: [Product Requirements v2](https://app.notion.com/p/3c8f73841f3d816d88c0ce627fca963a), [User Journeys v2](https://app.notion.com/p/3c8f73841f3d81a9910cfd2237909152), [Platform Contract v2](https://app.notion.com/p/3c8f73841f3d81efb5d1eb1b8ee8d328).
