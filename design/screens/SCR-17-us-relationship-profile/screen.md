# SCR-17 — Us Relationship Profile

## Metadata

| Field | Value |
|---|---|
| Screen ID | `SCR-17` |
| Revision | `1` |
| Release tier | Core Beta |
| Platforms | Android |
| Disposition | `replace_or_merge` |
| Build gate | `blocked_alignment_required` |
| Visual reference | [`preview.webp`](preview.webp) |
| Preserved source | `05 Reflection Us Explore/17-us-relationship-profile.webp` |

## 1. Product contract

- Requirement IDs: `REQ-HISTORY-001`, `REQ-WEEKLY-001`
- Flow IDs: `FLOW-WEEKLY-001`
- Job to be done: See what recently happened between us and reach the light weekly reflection.
- Entry and preconditions: Authorized member opens Us/Me.
- Roles and permissions: Current Dynamic member; Solo uses Me; visibility follows each event.
- Business logic and state transitions: Reframe around recent real RelationshipEvents plus one D7 card; remove complex relationship scoring/profile emphasis.
- Acceptance criteria: System reminders do not count as connected moments and user can reach Keep/Adjust/Pause.

Product references now point to the migrated CURRENT v2 contracts. This package remains blocked until its visual/state family is reconciled and approved; the preview does not authorize additional assumptions.

### Known alignment work

- reframe around recent relationship events
- add one light D7 Keep/Adjust/Pause card

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
| `mark.partner-bond` | Resolve purpose from the approved visual and asset registry | `manifests/assets.json` | planned — SVG master required |
| `nav.today` | Resolve purpose from the approved visual and asset registry | `manifests/assets.json` | planned — SVG master required |
| `nav.dynamic` | Resolve purpose from the approved visual and asset registry | `manifests/assets.json` | planned — SVG master required |
| `nav.explore` | Resolve purpose from the approved visual and asset registry | `manifests/assets.json` | planned — SVG master required |
| `nav.us` | Resolve purpose from the approved visual and asset registry | `manifests/assets.json` | planned — SVG master required |

Bundled fonts are under `design/assets/fonts/`. Do not trace, redraw, or embed one-off SVG paths from the preview.

## 5. Implementation and QA gate

- [ ] Requirement and flow IDs approved
- [ ] Product logic and permissions approved
- [ ] Default, loading, empty, error, offline and authorization states approved
- [ ] Copy and platform differences approved
- [ ] All required Asset IDs resolve to approved source files
- [ ] Build gate changed to `ready_for_build`
- [ ] Reference-size implementation render stored under `design/qa/implementation/SCR-17/`
- [ ] Android comparison recorded

Current result: **blocked_alignment_required**.
