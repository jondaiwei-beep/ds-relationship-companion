# SCR-01 — Today

## Metadata

| Field | Value |
|---|---|
| Screen ID | `SCR-01` |
| Revision | `2` candidate |
| Release tier | Core Beta |
| Platforms | Android |
| Disposition | `retain_and_align` |
| Build gate | `blocked_alignment_required` |
| Visual reference | [`candidates/rev-2/preview.webp`](candidates/rev-2/preview.webp) — prioritized-list candidate |
| Preserved source | `00 Visual Baseline/01-today.webp` |

## 1. Product contract

- Requirement IDs: `REQ-TODAY-001`, `REQ-ACK-001`, `REQ-RECOVERY-001`
- Flow IDs: `FLOW-RECEIVE-001`
- Job to be done: Know what matters today and enter the next meaningful action.
- Entry and preconditions: Active Dynamic; receiving member opens Today.
- Roles and permissions: Receiving member sees only authorized current-Dynamic content and own/private context.
- Business logic and state transitions: Show partner/context first, then 1–3 expectations, ritual, recent response, check-in and later/optional. The original [`preview.webp`](preview.webp) remains the preserved ritual-focus state; it is not the default list.
- Acceptance criteria: The most important action is understood within 10 seconds and all stale content resolves server current state.

Product references point to the migrated CURRENT v2 contracts. Revision 2 resolves the missing Today visual/state family as a review candidate. This package remains blocked until product/copy/platform approval; candidate art does not open the build gate by itself.

### B-3 alignment result

- Default shows exactly 1–3 priority items; the first item receives the full editorial hierarchy and all four agency actions.
- `Later / Optional` discloses up to seven additional items. The body scrolls while the Today header and navigation remain stable; total server order is capped at ten for this surface.
- The preserved ritual-focus composition remains a dedicated item-focus state.
- Loading, empty, error/retry, offline/read-only, authorization-loss, role-neutral and solo/private variants are rendered under `candidates/rev-2/states/`.

## 2. UI contract

- Reference viewport: **390 × 844 logical pixels**; Revision 2 lossless sources are **1170 × 2532 pixels**.
- Visual direction: **V5 Warm Authority / Quiet Authority**.
- Palette, type, spacing and component values must resolve through `design/tokens/` and `design/system/`.
- Preserve the specific information hierarchy and function-specific page structures shown in Revision 2 and the ritual-focus reference; do not force the family into a generic card template.
- Terracotta is relational/human emphasis, not a general action color.
- Cormorant Garamond is selective editorial/ritual typography; Inter is operational UI typography.
- Default read order: partner/current context → 1–3 priority items → recent human response → check-in/ritual → later/optional.
- First priority uses the editorial rail and full actions: `Complete`, `Discuss`, `New time`, `Can't do`. Compact rows do not suppress these rights; opening a row restores the same action set.
- The first priority action treatment binds to B-2 geometry: 56dp for the primary action and separate 48dp minimum touch targets for each quiet secondary action.
- Expanded state is an inline disclosure, not a new route. Server order is preserved; client time and cache never infer completion, missed or acknowledged status.
- Offline content is explicitly last-confirmed and read-only. Authorization loss removes all protected content before recovery is offered.
- Responsive and platform differences: **Android candidate complete; Web adaptation remains TBD before build**.
- Copy status: **candidate only — visual copy is not automatically product-approved**.

## 3. State matrix

| State | Product rule | UI requirement | Status |
|---|---|---|---|
| Default | Server supplies current partner/context and ordered items | Show 1–3 priorities, recent human response and collapsed later count | rev-2 candidate |
| Expanded 8–10 | Preserve server order; maximum ten items on Today | Scroll body, keep header/navigation stable, show `Show less` | rev-2 candidate |
| Ritual focus | One selected ritual becomes the present action | Preserve original editorial composition and partner acknowledgement | preserved reference |
| Loading | Membership and relationship day are not yet confirmed | Hide partner/item details; use stable private skeleton | rev-2 candidate |
| Empty | No current item requires attention | Calm optional check-in/rhythm exits; no score or invented urgency | rev-2 candidate |
| Error and retry | Current server truth cannot be confirmed | Hide relationship details; retry or return to private entrance | rev-2 candidate |
| Offline | Only last-confirmed cache is available | Label timestamp, make list read-only, pause all mutations | rev-2 candidate |
| Authorization loss | Session or membership is no longer current | Remove protected content; sign in again or leave device | rev-2 candidate |
| Role/partner variant | Custom roles may alter wording, never rights | Keep identical geometry and all four agency actions | rev-2 candidate |
| Solo/private | No active partner context | Replace presence/response with explicit private rhythm; sharing is opt-in | rev-2 candidate |

## 4. Asset contract

| Asset ID | Purpose | Registry | Status |
|---|---|---|---|
| `mark.presence` | Partner/current-context presence | `manifests/assets.json` | approved — SVG Freeze v1 |
| `mark.authority` | Priority/expectation identity | `manifests/assets.json` | approved — SVG Freeze v1 |
| `mark.check-in` | Daily check-in identity | `manifests/assets.json` | approved — SVG Freeze v1 |
| `emblem.ritual.evening` | Evening ritual identity | `manifests/assets.json` | approved — SVG Freeze v1 |
| `icon.private-space` | Solo/private context | `manifests/assets.json` | approved — SVG Freeze v1 |
| `nav.today` | Today navigation | `manifests/assets.json` | approved — SVG Freeze v1 |
| `nav.dynamic` | Dynamic navigation | `manifests/assets.json` | approved — SVG Freeze v1 |
| `nav.explore` | Explore navigation | `manifests/assets.json` | approved — SVG Freeze v1 |
| `nav.us` | Us navigation | `manifests/assets.json` | approved — SVG Freeze v1 |
| `state.acknowledged` | Human response signal | `manifests/assets.json` | approved — SVG Freeze v1 |
| `state.locked` | Authorization/private-session state | `manifests/assets.json` | approved — SVG Freeze v1 |

Bundled fonts are under `design/assets/fonts/`. Do not trace, redraw, or embed one-off SVG paths from the preview.

## 5. Implementation and QA gate

- [ ] Requirement and flow IDs approved
- [ ] Product logic and permissions approved
- [ ] Revision 2 default, expanded and recovery/role state family approved by product/design owner
- [ ] Copy and platform differences approved
- [x] All required Asset IDs resolve to approved source files
- [ ] Build gate changed to `ready_for_build`
- [ ] Reference-size implementation render stored under `design/qa/implementation/SCR-01/`
- [ ] Android comparison recorded

Candidate evidence: [`candidates/rev-2/today-b3-spec.json`](candidates/rev-2/today-b3-spec.json), [`../../qa/reference/today-b3-state-family-board.png`](../../qa/reference/today-b3-state-family-board.png) and [`../../qa/reference/today-b3-state-family-validation.json`](../../qa/reference/today-b3-state-family-validation.json).

Current result: **candidate_for_approval**; build gate remains **blocked_alignment_required**.
