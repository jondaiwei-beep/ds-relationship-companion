# SCR-16 — Advanced Reflections

## Metadata

| Field | Value |
|---|---|
| Screen ID | `SCR-16` |
| Revision | `1` |
| Release tier | Public MVP/P1 |
| Platforms | Android |
| Disposition | `future_reference` |
| Build gate | `future_reference` |
| Visual reference | [`preview.webp`](preview.webp) |
| Preserved source | `05 Reflection Us Explore/16-reflections.webp` |

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
| Default | TBD | Match approved hierarchy after behavior alignment | future scope |
| Loading | TBD | Skeleton/progress must preserve privacy and layout stability | future scope |
| Empty | TBD | Explain next safe action without invented urgency | future scope |
| Error and retry | TBD | Recovery action and retained data must be explicit | future scope |
| Offline | TBD | Show availability and queued-action behavior | future scope |
| Authorization loss | TBD | Hide protected data and offer safe recovery | future scope |
| Role/partner variant | TBD | Preserve consent, privacy and agency invariants | future scope |

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
- [ ] Reference-size implementation render stored under `design/qa/implementation/SCR-16/`
- [ ] Android comparison recorded

Current result: **future_reference**.

