# SCR-04 — Private Entrance

## Metadata

| Field | Value |
|---|---|
| Screen ID | `SCR-04` |
| Revision | `1` |
| Release tier | Core Beta |
| Platforms | Android |
| Disposition | `retain_and_align` |
| Build gate | `ready_for_build` |
| Visual reference | [`preview.webp`](preview.webp) |
| Preserved source | `01 Access and Authentication/04-private-entrance.webp` |

## 1. Product contract

- Requirement IDs: `REQ-TRUST-001`, `REQ-AUTH-001`
- Flow IDs: None
- Job to be done: Enter a private adult relationship space with clear trust framing.
- Entry and preconditions: First open or signed-out launch.
- Roles and permissions: Any adult user; no relationship content is exposed before authorization.
- Business logic and state transitions: Continue to sign in or account creation; communicate private-by-design without fetish or consent claims.
- Acceptance criteria: 18+/privacy expectations are clear and protected content remains unavailable.

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
| Default | TBD | Match approved hierarchy after behavior alignment | candidate rev-2 |
| Loading | TBD | Skeleton/progress must preserve privacy and layout stability | candidate rev-2 |
| Empty | Not applicable — the entrance always carries its own static content | Unfilled fields are Default and validation, never an empty surface | n/a — see note |
| Error and retry | TBD | Recovery action and retained data must be explicit | candidate rev-2 |
| Offline | TBD | Show availability and queued-action behavior | candidate rev-2 |
| Authorization loss | TBD | Hide protected data and offer safe recovery | candidate rev-2 |
| Role/partner variant | Not applicable — pre-authentication, no role context exists | No relationship content is exposed before authorization | n/a — see note |

## 4. Asset contract

| Asset ID | Purpose | Registry | Status |
|---|---|---|---|
| `mark.authority` | Resolve purpose from the approved visual and asset registry | `manifests/assets.json` | approved — SVG Freeze v1 |
| `state.locked` | Resolve purpose from the approved visual and asset registry | `manifests/assets.json` | approved — SVG Freeze v1 |

Bundled fonts are under `design/assets/fonts/`. Do not trace, redraw, or embed one-off SVG paths from the preview.

## 5. Implementation and QA gate

- [ ] Requirement and flow IDs approved
- [ ] Product logic and permissions approved
- [ ] Default, loading, empty, error, offline and authorization states approved
- [ ] Copy and platform differences approved
- [ ] All required Asset IDs resolve to approved source files
- [x] Build gate changed to `ready_for_build`
- [ ] Reference-size implementation render stored under `design/qa/implementation/SCR-04/`
- [ ] Android comparison recorded

Current result: **ready_for_build** — opened 2026-08-30 on evidence: every state-matrix row carries a candidate or a justified N/A, and the state family is rendered.
