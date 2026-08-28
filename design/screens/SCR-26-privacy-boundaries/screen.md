# SCR-26 — Privacy and Boundaries

## Metadata

| Field | Value |
|---|---|
| Screen ID | `SCR-26` |
| Revision | `1` |
| Release tier | Core Beta/P1 |
| Platforms | Android |
| Disposition | `replace_or_merge` |
| Build gate | `blocked_alignment_required` |
| Visual reference | [`preview.webp`](preview.webp) |
| Preserved source | `08 Notifications Privacy and Subscription/26-privacy-boundaries.webp` |

## 1. Product contract

- Requirement IDs: **TBD — pending Notion migration and reconciliation**
- Flow IDs: **TBD — pending Notion migration and reconciliation**
- Job to be done: **TBD**
- Entry and preconditions: **TBD**
- Roles and permissions: **TBD**
- Business logic and state transitions: **TBD**
- Acceptance criteria: **TBD**

The preview does not authorize assumptions about behavior. This package stays blocked until these fields link to approved files under `product/`.

### Known alignment work

- Core Beta keeps explicit private/shared basics
- advanced presence and activity controls move to P1

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
| `TBD — asset inventory required` | Complete visual asset audit before build | `manifests/assets.json` | missing |

Bundled fonts are under `design/assets/fonts/`. Do not trace, redraw, or embed one-off SVG paths from the preview.

## 5. Implementation and QA gate

- [ ] Requirement and flow IDs approved
- [ ] Product logic and permissions approved
- [ ] Default, loading, empty, error, offline and authorization states approved
- [ ] Copy and platform differences approved
- [ ] All required Asset IDs resolve to approved source files
- [ ] Build gate changed to `ready_for_build`
- [ ] Reference-size implementation render stored under `design/qa/implementation/SCR-26/`
- [ ] Android comparison recorded

Current result: **blocked_alignment_required**.

