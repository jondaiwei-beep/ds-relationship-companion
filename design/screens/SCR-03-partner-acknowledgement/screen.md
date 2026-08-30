# SCR-03 — Partner Acknowledgement Received

## Metadata

| Field | Value |
|---|---|
| Screen ID | `SCR-03` |
| Revision | `1` |
| Release tier | Core Beta |
| Platforms | Android |
| Disposition | `retain_and_align` |
| Build gate | `blocked_alignment_required` |
| Visual reference | [`preview.webp`](preview.webp) |
| Preserved source | `00 Visual Baseline/03-partner-acknowledgement.webp` |

## 1. Product contract

- Requirement IDs: `REQ-ACK-001`, `REQ-RECOVERY-001`
- Flow IDs: `FLOW-RECEIVE-001`
- Job to be done: Receive and recognize a genuine partner response.
- Entry and preconditions: An explicit human Acknowledgement exists for the member's completion or check-in.
- Roles and permissions: Only current authorized members see the response; human author identity must be accurate.
- Business logic and state transitions: Render partner-authored content as the emotional focus while system labels remain subordinate.
- Acceptance criteria: The user can tell who wrote the response and never mistakes a system suggestion for partner language.

Product references now point to the migrated CURRENT v2 contracts. This package remains blocked until its visual/state family is reconciled and approved; the preview does not authorize additional assumptions.

### Known alignment work

- separate human-authored response from system copy
- add acknowledgement composer family

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
| Default | TBD | Match approved hierarchy after behavior alignment | candidate rev-3 |
| Loading | TBD | Skeleton/progress must preserve privacy and layout stability | candidate rev-3 |
| Empty | Not applicable — a detail screen opens on one acknowledgement; a missing one is Error, not Empty | An acknowledgement that is gone resolves through error, never a blank surface | n/a — see note |
| Error and retry | TBD | Recovery action and retained data must be explicit | candidate rev-3 |
| Offline | TBD | Show availability and queued-action behavior | candidate rev-3 |
| Authorization loss | TBD | Hide protected data and offer safe recovery | candidate rev-3 |
| Role/partner variant | Not applicable to this surface — `role_preset` is never used for authorization and carries no free-text label, so it alters no word here | The author's display name is the only variable; authorship, access and agency are identical for every preset | n/a — see note |

## 4. Asset contract

| Asset ID | Purpose | Registry | Status |
|---|---|---|---|
| `mark.presence` | Resolve purpose from the approved visual and asset registry | `manifests/assets.json` | approved — SVG Freeze v1 |
| `state.acknowledged` | Resolve purpose from the approved visual and asset registry | `manifests/assets.json` | approved — SVG Freeze v1 |
| `nav.today` | Resolve purpose from the approved visual and asset registry | `manifests/assets.json` | approved — SVG Freeze v1 |
| `nav.dynamic` | Resolve purpose from the approved visual and asset registry | `manifests/assets.json` | approved — SVG Freeze v1 |
| `nav.explore` | Resolve purpose from the approved visual and asset registry | `manifests/assets.json` | approved — SVG Freeze v1 |
| `nav.us` | Resolve purpose from the approved visual and asset registry | `manifests/assets.json` | approved — SVG Freeze v1 |

Bundled fonts are under `design/assets/fonts/`. Do not trace, redraw, or embed one-off SVG paths from the preview.

## 5. Implementation and QA gate

- [ ] Requirement and flow IDs approved
- [ ] Product logic and permissions approved
- [ ] Default, loading, empty, error, offline and authorization states approved
- [ ] Copy and platform differences approved
- [ ] All required Asset IDs resolve to approved source files
- [ ] Build gate changed to `ready_for_build`
- [ ] Reference-size implementation render stored under `design/qa/implementation/SCR-03/`
- [ ] Android comparison recorded

Current result: **blocked_alignment_required**.
