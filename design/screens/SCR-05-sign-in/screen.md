# SCR-05 — Sign In

## Metadata

| Field | Value |
|---|---|
| Screen ID | `SCR-05` |
| Revision | `1` |
| Release tier | Core Beta |
| Platforms | Android |
| Disposition | `retain_and_align` |
| Build gate | `ready_for_build` |
| Visual reference | [`preview.webp`](preview.webp) |
| Preserved source | `01 Access and Authentication/05-sign-in.webp` |

## 1. Product contract

- Requirement IDs: `REQ-AUTH-001`, `REQ-RECOVERY-001`
- Flow IDs: `FLOW-ACTIVATE-001`
- Job to be done: Authenticate and return to the intended product or invite context.
- Entry and preconditions: Signed-out user chooses Enter or reaches an auth-protected deep link.
- Roles and permissions: Account owner only; shared-device sign-out/session expiry must be recoverable.
- Business logic and state transitions: Use the approved magic-link/session contract rather than treating the pictured password form as final behavior.
- Acceptance criteria: Magic-link callback, expiry, retry and return-to-invite resolve correctly on Android and Web.

Product references now point to the migrated CURRENT v2 contracts. This package remains blocked until its visual/state family is reconciled and approved; the preview does not authorize additional assumptions.

### Known alignment work

- align with magic-link authentication contract

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
| Empty | Not applicable — a form is unfilled, never empty | Unfilled fields are Default and validation, never an empty surface | n/a — see note |
| Error and retry | TBD | Recovery action and retained data must be explicit | candidate rev-2 |
| Offline | TBD | Show availability and queued-action behavior | candidate rev-2 |
| Authorization loss | TBD | Hide protected data and offer safe recovery | candidate rev-2 |
| Role/partner variant | Not applicable — pre-authentication, no role context exists | A preserved invite is a context variant, not a role variant | n/a — see note |

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
- [ ] Reference-size implementation render stored under `design/qa/implementation/SCR-05/`
- [ ] Android comparison recorded

Current result: **ready_for_build** — opened 2026-08-30 on evidence: every state-matrix row carries a candidate or a justified N/A, and the state family is rendered.
