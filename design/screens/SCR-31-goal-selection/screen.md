# SCR-31 — Goal Selection

## Metadata

| Field | Value |
|---|---|
| Screen ID | `SCR-31` |
| Revision | `1 — candidate for approval` |
| Release tier | Core Beta |
| Platforms | Android, Web |
| Build gate | `blocked_alignment_required` |
| Visual status | **high-fidelity candidate available** |
| Visual reference | [`preview.webp`](preview.webp) |
| Lossless source | [`source.png`](source.png) |
| Coverage | `manifests/design-coverage.json` |

## 1. Product contract

- Requirement IDs: `REQ-ACT-001`
- Flow IDs: `FLOW-ACTIVATE-001`
- Job to be done: Choose the relationship outcome before being asked to define a role or configure the product.
- Entry/preconditions: First open after the private entrance/account trust step.
- Logic and transitions: Select exactly one starting outcome: Closer, Structure, Service & devotion, Accountability, or Explore together. Continue to Minimal Setup; selection remains editable.
- Acceptance criteria: The primary question is understood immediately; Continue is disabled until a choice exists; Android/Web store the same choice.
- Agency/privacy: Role never removes Discuss, Reschedule, Can't Do, Pause, Leave, Block or own-private-data control.

## 2. UI contract

Use a lighter life-layer composition within Warm Authority. Five choices must feel editorial and intentional, not like generic radio cards. Authority comes from hierarchy and pacing, not fetish symbols.

- Visual direction remains V5 Warm Authority / Quiet Authority.
- Reference viewport: 390 × 844 logical pixels.
- Android and Web share meaning; Web presentation must respect browser navigation, direct URL and session behavior.
- The approved candidate uses a vertical relational axis instead of generic cards. `Closer` is selected with one Terracotta node and underline; the other four outcomes remain quiet.
- Botanical line work is decorative and low contrast; it may not compete with the choice labels.
- Primary spacing, text, color and CTA geometry are defined by `preview.webp`; implementation still waits for state variants and approved assets.

## 3. Required state matrix

| State | Status |
|---|---|
| Default | candidate available; approval pending |
| Loading | design missing |
| Empty/not applicable | design decision required |
| Error/retry | design missing |
| Offline | design missing |
| Authorization/session loss | design missing |
| Current-state/stale recovery | design missing |

## 4. Asset contract

| Asset ID | Purpose | Registry | Status |
|---|---|---|---|
| `mark.guidance` | Top-right guidance/emblem role | `manifests/assets.json` | approved — SVG Freeze v1 |
| `mark.authority` | Quiet authority identity | `manifests/assets.json` | approved — SVG Freeze v1 |
| `motif.botanical.goal-branch` | Low-contrast botanical decorative layer | `manifests/assets.json` | approved — SVG Freeze v1 |

## 5. Build gate

- [ ] Primary high-fidelity candidate approved by product owner
- [ ] Product owner confirms product contract
- [ ] State and platform variants approved
- [ ] Copy approved
- [ ] SVG masters approved and registered
- [ ] Screen revision incremented to 1
- [ ] Gate changed to `ready_for_build`

Current result: **candidate for approval; do not implement yet**.
