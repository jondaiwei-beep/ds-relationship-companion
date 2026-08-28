# SCR-24 — Pause Check-in

## Metadata

| Field | Value |
|---|---|
| Screen ID | `SCR-24` |
| Revision | `1` |
| Release tier | Core Beta |
| Platforms | Android |
| Disposition | `retain_and_align` |
| Build gate | `blocked_alignment_required` |
| Visual reference | [`preview.webp`](preview.webp) |
| Preserved source | `07 Reflection Check-in and Consent/24-pause-consent-check-in.webp` |

## 1. Product contract

- Requirement IDs: `REQ-PAUSE-001`, `REQ-IDEMP-001`, `REQ-RECOVERY-001`
- Flow IDs: `FLOW-PAUSE-001`
- Job to be done: Pause safely or return without backlog pressure.
- Entry and preconditions: Either member opens Pause/Resume from Dynamic or a relevant context.
- Roles and permissions: Either member can pause without approval; both retain exit/privacy rights.
- Business logic and state transitions: Confirm Pause, show Paused state, then Resume same/lighter/adjust; do not generate paused-period backlog.
- Acceptance criteria: Retry is idempotent and return never requires old completion.

Product references now point to the migrated CURRENT v2 contracts. This package remains blocked until its visual/state family is reconciled and approved; the preview does not authorize additional assumptions.

### Known alignment work

- add pause confirmation and resume choices
- pause must not require partner approval

## 2. UI contract

- Reference viewport: **390 × 844 logical pixels**; source preview is 853 × 1844 pixels.
- Visual direction: **V5 Warm Authority / Quiet Authority**.
- Palette, type, spacing and component values must resolve through `design/tokens/` and `design/system/`.
- Preserve the specific information hierarchy and function-specific page structure shown in `preview.webp`; do not force it into a generic card template.
- Terracotta is relational/human emphasis, not a general action color.
- Cormorant Garamond is selective editorial/ritual typography; Inter is operational UI typography.
- Responsive and platform differences: **TBD — must be specified before build**.
- Copy status: **TBD — visual copy is not automatically product-approved**.

## 3. State matrix

| State | Product rule | UI requirement | Status |
|---|---|---|---|
| Default | TBD | Match approved hierarchy after behavior alignment | blocked |
| Loading | TBD | Skeleton/progress must preserve privacy and layout stability | blocked |
| Empty | TBD | Explain next safe action without invented urgency | blocked |
| Error and retry | TBD | Recovery action and retained data must be explicit | blocked |
| Offline | TBD | Show availability and queued-action behavior | blocked |
| Authorization loss | TBD | Hide protected data and offer safe recovery | blocked |
| Role/partner variant | TBD | Preserve consent, privacy and agency invariants | blocked |

## 4. Asset contract

| Asset ID | Purpose | Registry | Status |
|---|---|---|---|
| `mark.partner-bond` | Resolve purpose from the approved visual and asset registry | `manifests/assets.json` | approved — SVG Freeze v1 |

Bundled fonts are under `design/assets/fonts/`. Do not trace, redraw, or embed one-off SVG paths from the preview.

## 5. Implementation and QA gate

- [ ] Requirement and flow IDs approved
- [ ] Product logic and permissions approved
- [ ] Default, loading, empty, error, offline and authorization states approved
- [ ] Copy and platform differences approved
- [ ] All required Asset IDs resolve to approved source files
- [ ] Build gate changed to `ready_for_build`
- [ ] Reference-size implementation render stored under `design/qa/implementation/SCR-24/`
- [ ] Android comparison recorded

Current result: **blocked_alignment_required**.
