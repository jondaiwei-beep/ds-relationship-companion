# SCR-32 — Attention

## Metadata

| Field | Value |
|---|---|
| Screen ID | `SCR-32` |
| Revision | `0 — design pending` |
| Release tier | Core Beta |
| Platforms | Android, Web |
| Build gate | `ready_for_build` |
| Visual status | **missing required design** |
| Coverage | `manifests/design-coverage.json` |

## 1. Product contract

- Requirement IDs: `REQ-ATTN-001`, `REQ-ACK-001`, `REQ-ADJUST-001`, `REQ-REVIEW-001`, `REQ-RECOVERY-001`
- Flow IDs: `FLOW-ATTENTION-001`, `FLOW-ADJUST-001`
- Job to be done: See what requires a real human response and clear meaningful work with minimal mental load.
- Entry/preconditions: Direction-giving member opens Attention or follows a neutral deep link.
- Logic and transitions: Order Discuss/support first, then Waiting Acknowledgement, Needs Review and low priority. Support inline Acknowledge, Praise, Comment, Adjust, Excuse, Reschedule and Review. Exclude Proposal.
- Acceptance criteria: Priority is clear in seconds; basic acknowledgement is ≤2 taps; human send is explicit; stale items resolve current server state.
- Agency/privacy: Role never removes Discuss, Reschedule, Can't Do, Pause, Leave, Block or own-private-data control.

## 2. UI design brief

This is an operational authority surface, not the same centered ritual structure as Today. Use a disciplined vertical queue with Terracotta reserved for human relational urgency/response.

- Visual direction remains V5 Warm Authority / Quiet Authority.
- Reference viewport: 390 × 844 logical pixels.
- Android and Web share meaning; Web presentation must respect browser navigation, direct URL and session behavior.
- Required design output: `preview.webp`, then domain/recovery variants under `states/` and any true platform variants under `platforms/`.

## 3. Required state matrix

| State | Status |
|---|---|
| Default | design missing |
| Loading | design missing |
| Empty/not applicable | design decision required |
| Error/retry | design missing |
| Offline | design missing |
| Authorization/session loss | design missing |
| Current-state/stale recovery | design missing |

## 4. Asset contract

| Asset ID | Purpose | Registry | Status |
|---|---|---|---|
| `mark.presence` | Required visual identity/state role | `manifests/assets.json` | approved — SVG Freeze v1 |
| `state.acknowledged` | Required visual identity/state role | `manifests/assets.json` | approved — SVG Freeze v1 |
| `mark.guidance` | Required visual identity/state role | `manifests/assets.json` | approved — SVG Freeze v1 |

## 5. Build gate

- [ ] Primary high-fidelity preview approved
- [ ] Product owner confirms product contract
- [ ] State and platform variants approved
- [ ] Copy approved
- [ ] SVG masters approved and registered
- [ ] Screen revision incremented to 1
- [ ] Gate changed to `ready_for_build`

Current result: **missing design; do not implement**.

