# SCR-00 — Selected Style Reference

## Metadata

| Field | Value |
|---|---|
| Screen ID | `SCR-00` |
| Revision | `1` |
| Release tier | Design System |
| Platforms | Android |
| Disposition | `retain` |
| Build gate | `reference_only` |
| Visual reference | [`preview.webp`](preview.webp) |
| Preserved source | `00 Visual Baseline/00-selected-style-reference.webp` |

## 1. Product contract

- Requirement IDs: None — design-system reference only
- Flow IDs: None
- Job to be done: Define the approved V5 Warm Authority visual baseline.
- Entry and preconditions: Design and QA reference; not a product route.
- Roles and permissions: Not applicable.
- Business logic and state transitions: No business logic. It cannot be implemented as an application screen.
- Acceptance criteria: Used only to compare visual direction, hierarchy, type, color and emblem treatment.

Product references now point to the migrated CURRENT v2 contracts. This package remains blocked until its visual/state family is reconciled and approved; the preview does not authorize additional assumptions.

### Known alignment work

- No legacy alignment note recorded; product/state verification is still required.

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
| Default | TBD | Match approved hierarchy after behavior alignment | reference only |
| Loading | TBD | Skeleton/progress must preserve privacy and layout stability | reference only |
| Empty | TBD | Explain next safe action without invented urgency | reference only |
| Error and retry | TBD | Recovery action and retained data must be explicit | reference only |
| Offline | TBD | Show availability and queued-action behavior | reference only |
| Authorization loss | TBD | Hide protected data and offer safe recovery | reference only |
| Role/partner variant | TBD | Preserve consent, privacy and agency invariants | reference only |

## 4. Asset contract

| Asset ID | Purpose | Registry | Status |
|---|---|---|---|
| `mark.authority` | Resolve purpose from the approved visual and asset registry | `manifests/assets.json` | approved — SVG Freeze v1 |
| `mark.presence` | Resolve purpose from the approved visual and asset registry | `manifests/assets.json` | approved — SVG Freeze v1 |
| `mark.partner-bond` | Resolve purpose from the approved visual and asset registry | `manifests/assets.json` | approved — SVG Freeze v1 |
| `mark.guidance` | Resolve purpose from the approved visual and asset registry | `manifests/assets.json` | approved — SVG Freeze v1 |
| `emblem.ritual.evening` | Resolve purpose from the approved visual and asset registry | `manifests/assets.json` | approved — SVG Freeze v1 |
| `nav.today` | Resolve purpose from the approved visual and asset registry | `manifests/assets.json` | approved — SVG Freeze v1 |
| `nav.dynamic` | Resolve purpose from the approved visual and asset registry | `manifests/assets.json` | approved — SVG Freeze v1 |
| `nav.explore` | Resolve purpose from the approved visual and asset registry | `manifests/assets.json` | approved — SVG Freeze v1 |
| `nav.us` | Resolve purpose from the approved visual and asset registry | `manifests/assets.json` | approved — SVG Freeze v1 |
| `state.acknowledged` | Resolve purpose from the approved visual and asset registry | `manifests/assets.json` | approved — SVG Freeze v1 |
| `state.completed` | Resolve purpose from the approved visual and asset registry | `manifests/assets.json` | approved — SVG Freeze v1 |
| `state.locked` | Resolve purpose from the approved visual and asset registry | `manifests/assets.json` | approved — SVG Freeze v1 |

Bundled fonts are under `design/assets/fonts/`. Do not trace, redraw, or embed one-off SVG paths from the preview.

## 5. Implementation and QA gate

- [ ] Requirement and flow IDs approved
- [ ] Product logic and permissions approved
- [ ] Default, loading, empty, error, offline and authorization states approved
- [ ] Copy and platform differences approved
- [ ] All required Asset IDs resolve to approved source files
- [ ] Build gate changed to `ready_for_build`
- [ ] Reference-size implementation render stored under `design/qa/implementation/SCR-00/`
- [ ] Android comparison recorded

Current result: **reference_only**.
