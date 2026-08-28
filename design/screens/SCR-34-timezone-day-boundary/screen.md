# SCR-34 — Timezone and Day Boundary

## Metadata

| Field | Value |
|---|---|
| Screen ID | `SCR-34` |
| Revision | `0 — design pending` |
| Release tier | Core Beta |
| Platforms | Android, Web |
| Build gate | `blocked_alignment_required` |
| Visual status | **missing required design** |
| Coverage | `manifests/design-coverage.json` |

## 1. Product contract

- Requirement IDs: `REQ-TIME-001`, `REQ-RECOVERY-001`
- Flow IDs: None
- Job to be done: Understand which timezone and relationship-day boundary control rituals and expectations.
- Entry/preconditions: Minimal setup auto-detection confirmation or Account & Settings.
- Logic and transitions: Show detected device timezone, chosen relationship timezone and one custom day boundary. A device-timezone change requires confirmation before changing schedules. DST uses local wall-clock semantics.
- Acceptance criteria: 00:00 and 04:00 boundaries are understandable; changing device timezone never silently rewrites the relationship schedule.
- Agency/privacy: Role never removes Discuss, Reschedule, Can't Do, Pause, Leave, Block or own-private-data control.

## 2. UI design brief

A calm settings tool with a restrained circular time motif is appropriate, but avoid the dense decorative dial used by Notification Rhythm when it reduces comprehension.

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
| `mark.guidance` | Required visual identity/state role | `manifests/assets.json` | planned |

## 5. Build gate

- [ ] Primary high-fidelity preview approved
- [ ] Product owner confirms product contract
- [ ] State and platform variants approved
- [ ] Copy approved
- [ ] SVG masters approved and registered
- [ ] Screen revision incremented to 1
- [ ] Gate changed to `ready_for_build`

Current result: **missing design; do not implement**.

