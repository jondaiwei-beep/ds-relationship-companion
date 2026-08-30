# SCR-08 — Minimal Setup · Structure and Context

## Metadata

| Field | Value |
|---|---|
| Screen ID | `SCR-08` |
| Revision | `1` |
| Candidate revision | `2 — approval pending` |
| Release tier | Core Beta |
| Platforms | Android |
| Disposition | `retain_and_align` |
| Build gate | `blocked_alignment_required` |
| Released legacy reference | [`preview.webp`](preview.webp) |
| Candidate preview | [`candidates/rev-2/preview.webp`](candidates/rev-2/preview.webp) |
| Candidate lossless source | [`candidates/rev-2/source.png`](candidates/rev-2/source.png) |
| Preserved source | `02 Role and Pairing Setup/08-relationship-structure.webp` |

## 1. Product contract

- Requirement IDs: `REQ-ACT-002`, `REQ-PRIVACY-001`
- Flow IDs: `FLOW-ACTIVATE-001`
- Job to be done: Choose Couple/Solo and enough structure to prepare a Starter Rhythm.
- Entry and preconditions: After Goal during minimal setup.
- Roles and permissions: Creator or Solo member; private data remains private by default.
- Business logic and state transitions: Collect Couple/Solo, structure, boundaries lite and optional LDR/Together without a long settings workflow.
- Acceptance criteria: Setup stays short, preserves agency and leads directly to Starter Rhythm.

Product references now point to the migrated CURRENT v2 contracts. This package remains blocked until its visual/state family is reconciled and approved; the preview does not authorize additional assumptions.

### Known alignment work

- combine couple/solo, structure level, boundaries lite, LDR/together

## 2. UI contract

- Candidate revision 2 makes Light / Steady / Defined a single open-arc control with Steady selected.
- Long-distance/Together is a secondary context line; timezone and optional boundaries use quieter editorial rows.
- The candidate intentionally avoids inventing unapproved boundary choices and avoids a settings-card stack.

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
| Default | Use candidate revision 2 after approval | Structure + context hierarchy | candidate |
| Loading | TBD | Skeleton/progress must preserve privacy and layout stability | candidate rev-3 |
| Empty | TBD | Explain next safe action without invented urgency | blocked |
| Error and retry | TBD | Recovery action and retained data must be explicit | candidate rev-3 |
| Offline | TBD | Show availability and queued-action behavior | candidate rev-3 |
| Authorization loss | TBD | Hide protected data and offer safe recovery | blocked |
| Role/partner variant | TBD | Preserve consent, privacy and agency invariants | blocked |

## 4. Asset contract

| Asset ID | Purpose | Registry | Status |
|---|---|---|---|
| `mark.partner-bond` | Resolve purpose from the approved visual and asset registry | `manifests/assets.json` | approved — SVG Freeze v1 |
| `icon.timezone` | Detected timezone row | `manifests/assets.json` | approved — SVG Freeze v1 |
| `icon.boundaries` | Optional boundaries/preferences row | `manifests/assets.json` | approved — SVG Freeze v1 |

Bundled fonts are under `design/assets/fonts/`. Do not trace, redraw, or embed one-off SVG paths from the preview.

## 5. Implementation and QA gate

- [ ] Requirement and flow IDs approved
- [ ] Product logic and permissions approved
- [ ] Default, loading, empty, error, offline and authorization states approved
- [ ] Copy and platform differences approved
- [ ] All required Asset IDs resolve to approved source files
- [ ] Build gate changed to `ready_for_build`
- [ ] Reference-size implementation render stored under `design/qa/implementation/SCR-08/`
- [ ] Android comparison recorded

Current result: **blocked_alignment_required**.
