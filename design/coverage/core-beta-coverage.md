# Core Beta product × design coverage

Status: **first reconciliation pass, 2026-08-28**. V5 Warm Authority remains locked. “New” means a genuinely different primary question; “state family” means the same surface with different domain/platform state.

| Product family | Requirements / flow | Current design | Decision | Required visual work |
|---|---|---|---|---|
| Private entry / auth | `REQ-AUTH-001`, `REQ-TRUST-001` | `SCR-04–06` | retain and align | Magic-link sent/callback, expired session, validation and recovery states. |
| Goal selection | `REQ-ACT-001`, `FLOW-ACTIVATE-001` | missing | **new screen `SCR-31`** | Outcome-first design before role/configuration. |
| Minimal setup | `REQ-ACT-002` | `SCR-07`, `SCR-08` | **rev-2 candidates complete** | Mode/role and structure/context primary candidates exist; still require state, Web adaptation and approval. |
| Starter Rhythm | `REQ-ACT-003` | `SCR-12` | **rev-2 candidate complete** | 1 Ritual + 1 Expectation + 1 Check-in candidate exists; still requires replace/edit interaction states and approval. |
| Invite creator | `REQ-INVITE-001` | `SCR-09` | retain + state family | Pending, accepted, expired, revoked, share/copy recovery; Android/Web share differences. |
| Web Join trust | `REQ-JOIN-001` | `SCR-10`, `SCR-11` | merge/redesign | Inviter, intention, shared/private boundary, leave right, auth return and safe expired/revoked/stale states. |
| First shared interaction | `REQ-FIRST-001` | partial in `SCR-01/02` | add activation state | Small check-in or starter ritual; no empty success page. |
| Receiving Today | `REQ-TODAY-001`, `FLOW-RECEIVE-001` | `SCR-01`, `SCR-19` | combine as one page family | Ritual-focus state plus prioritized 1–3 item list, partner context, recent response, check-in and later/optional. |
| Direction-giving Attention | `REQ-ATTN-001`, `FLOW-ATTENTION-001` | missing | **new screen `SCR-32`** | Priority queue with meaningful inline responses; no Proposal inbox. |
| Expectation / Ritual detail | `REQ-EXPECT-001`, `REQ-ADJUST-001` | `SCR-14` | retain and align | Complete, Discuss, Request New Time, Can't Do and role/state variants; remove Proof. |
| Complete / Waiting | `REQ-COMPLETE-001` | `SCR-02` | retain and align | Completion note visibility, idempotent retry and explicit Waiting for Human Response. |
| Acknowledgement composer | `REQ-ACK-001` | missing; `SCR-03` is received state | **new screen/overlay `SCR-33`** | Acknowledge/Praise/Comment/Review; human send is explicit; ≤2 taps for basic Ack. |
| Acknowledgement received | `REQ-ACK-001` | `SCR-03` | retain | Distinguish partner-authored text from system labels. |
| Daily Check-in | `REQ-CHECKIN-001` | `SCR-22` is advanced reflection | replace | Mood, energy, need, optional note, Private/Shared choice; remove essay-first hierarchy. |
| Adjustment request / resolution | `REQ-ADJUST-001`, `REQ-REVIEW-001`, `FLOW-ADJUST-001` | partial `SCR-14`, `SCR-21` | add state families; do not restore Agreement flow | Request, partner resolution, Needs Review, Excuse/Cancel and error/retry variants. |
| Dynamic | `REQ-EXPECT-001`, `REQ-PAUSE-001` | `SCR-13` | simplify | Current rhythm, partner context, pause/resume and basic settings; remove Agreement prominence. |
| Pause / Resume | `REQ-PAUSE-001`, `FLOW-PAUSE-001` | `SCR-24` | retain + state family | Pause confirmation, paused state and Resume same/lighter/adjust. |
| Us / D7 | `REQ-HISTORY-001`, `REQ-WEEKLY-001` | `SCR-17`, `SCR-23` | reframe/simplify | Recent real events plus one Keep/Adjust/Pause card; no performance comparison. |
| Notifications / Quiet Hours | `REQ-NOTIFY-001` | `SCR-25`, `SCR-29` | retain and align | Separate event history from Attention; neutral preview, aggregation and platform permission states. |
| Privacy | `REQ-PRIVACY-001` | `SCR-26` | simplify Core | Explicit Private/Shared basics; advanced presence/activity and App Lock remain P1/feature-gated. |
| Timezone / day boundary | `REQ-TIME-001` | absent from `SCR-28` | **new subpage `SCR-34`** | Auto-detected timezone, relationship timezone, day boundary, DST explanation and device-change confirmation. |
| Leave / Block / ended | `REQ-LEAVE-001`, `REQ-BLOCK-001`, `FLOW-EXIT-001` | `SCR-30` | retain + state family | Neutral first step, final confirmation, blocked/left/ended/stale-link safe landing; product Block semantics still open. |
| Loading / empty / offline / auth loss | `REQ-RECOVERY-001` | missing across inventory | cross-screen state system | Build state templates, then apply to every Core Beta Screen Package before build gate opens. |
| Agreement / advanced reflection / Explore / paywall | Public MVP/P1 | `SCR-15/16/18/21/27` | future reference | Preserve visual evidence; exclude from Core Beta navigation and implementation. |

## Net new primary surfaces

Only four primary surfaces are currently justified: Goal (`SCR-31`), Attention (`SCR-32`), Acknowledgement Composer (`SCR-33`) and Timezone/Day Boundary (`SCR-34`). Most other gaps are redesigns or state/platform variants of existing Screen Packages.

## Visual production order

1. First Connected Vertical Slice: Goal → Minimal Setup → Starter Rhythm → Invite/Join → Complete/Waiting → Acknowledgement.
2. Daily Loop: Today list → Attention → Check-in.
3. Reality Fit: adjustment → Needs Review → Pause/Resume → timezone/day boundary.
4. Privacy/Async: Invite/auth failures → notification permissions → Leave/Block/stale states.
5. Recent Us + D7 and global loading/empty/offline/recovery coverage.

## Cross-source corrections

- **Typography resolved for the GitHub handoff:** Notion 05 still names Rovel Display with Lora as a placeholder. The approved visual inventory and bundled implementation source use **Cormorant Garamond** for editorial/ritual display and **Inter** for operational UI. GitHub typography/tokens are canonical; the stale Notion wording must be retired during final migration.
- **Figma/Library wording is obsolete:** historical Notion pages describe Figma and Library as design sources. The current product decision is GitHub-only; Figma must not be reintroduced as a dependency.
- **Unreconciled HTML source:** Developer Handoff v2 mentions `ds_relationship_warm_authority_v51.html`. It is not present in this design repository and must be imported for comparison or explicitly deprecated before the final Claude Code handoff.
