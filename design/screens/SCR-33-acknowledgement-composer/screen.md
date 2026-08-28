# SCR-33 — Acknowledgement Composer

## Metadata

| Field | Value |
|---|---|
| Screen ID | `SCR-33` |
| Revision | `0 — design pending` |
| Release tier | Core Beta |
| Platforms | Android, Web |
| Build gate | `blocked_alignment_required` |
| Visual status | **missing required design** |
| Coverage | `manifests/design-coverage.json` |

## 1. Product contract

- Requirement IDs: `REQ-ACK-001`, `REQ-IDEMP-001`, `REQ-RECOVERY-001`
- Flow IDs: `FLOW-ATTENTION-001`
- Job to be done: Respond quickly but genuinely to a partner's completed action or shared context.
- Entry/preconditions: From Attention, Completion detail or a Check-in requiring response.
- Logic and transitions: Choose Acknowledge, Praise, Comment or Review; suggested language is visibly system-provided until the human explicitly sends. Retry must not duplicate the acknowledgement.
- Acceptance criteria: Basic Acknowledge ≤2 taps; typed content is preserved through recoverable failure; success returns current state.
- Agency/privacy: Role never removes Discuss, Reschedule, Can't Do, Pause, Leave, Block or own-private-data control.

## 2. UI design brief

Use a focused bottom sheet or compact response surface rather than a full ceremonial page. Give partner content emotional priority and keep system suggestions visually subordinate.

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
| `state.acknowledged` | Required visual identity/state role | `manifests/assets.json` | planned |
| `mark.presence` | Required visual identity/state role | `manifests/assets.json` | planned |

## 5. Build gate

- [ ] Primary high-fidelity preview approved
- [ ] Product owner confirms product contract
- [ ] State and platform variants approved
- [ ] Copy approved
- [ ] SVG masters approved and registered
- [ ] Screen revision incremented to 1
- [ ] Gate changed to `ready_for_build`

Current result: **missing design; do not implement**.

