# SCR-07 — Role Orientation

## Metadata

| Field | Value |
|---|---|
| Screen ID | `SCR-07` |
| Revision | `1` |
| Release tier | Core Beta |
| Platforms | Android |
| Disposition | `replace_or_merge` |
| Build gate | `blocked_alignment_required` |
| Visual reference | [`preview.webp`](preview.webp) |
| Preserved source | `02 Role and Pairing Setup/07-role-orientation.webp` |

## 1. Product contract

- Requirement IDs: `REQ-ACT-002`, `REQ-PRIVACY-001`
- Flow IDs: `FLOW-ACTIVATE-001`
- Job to be done: Choose a starting role preset as one part of minimal setup.
- Entry and preconditions: After Goal; before Starter Rhythm.
- Roles and permissions: Creator or Solo member; preset is editable and never removes agency.
- Business logic and state transitions: This screen must be merged/resequenced so Goal precedes role and role remains a lightweight starting context.
- Acceptance criteria: User understands the preset is not consent or permanent identity and can continue without a permission matrix.

Product references now point to the migrated CURRENT v2 contracts. This package remains blocked until its visual/state family is reconciled and approved; the preview does not authorize additional assumptions.

### Known alignment work

- Goal must precede role
- merge into Minimal Setup where possible

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
| `mark.guidance` | Resolve purpose from the approved visual and asset registry | `manifests/assets.json` | planned — SVG master required |

Bundled fonts are under `design/assets/fonts/`. Do not trace, redraw, or embed one-off SVG paths from the preview.

## 5. Implementation and QA gate

- [ ] Requirement and flow IDs approved
- [ ] Product logic and permissions approved
- [ ] Default, loading, empty, error, offline and authorization states approved
- [ ] Copy and platform differences approved
- [ ] All required Asset IDs resolve to approved source files
- [ ] Build gate changed to `ready_for_build`
- [ ] Reference-size implementation render stored under `design/qa/implementation/SCR-07/`
- [ ] Android comparison recorded

Current result: **blocked_alignment_required**.
