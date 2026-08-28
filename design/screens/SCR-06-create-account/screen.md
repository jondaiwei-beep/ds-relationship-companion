# SCR-06 — Create Account

## Metadata

| Field | Value |
|---|---|
| Screen ID | `SCR-06` |
| Revision | `1` |
| Release tier | Core Beta |
| Platforms | Android |
| Disposition | `retain_and_align` |
| Build gate | `blocked_alignment_required` |
| Visual reference | [`preview.webp`](preview.webp) |
| Preserved source | `01 Access and Authentication/06-create-account.webp` |

## 1. Product contract

- Requirement IDs: `REQ-AUTH-001`, `REQ-TRUST-001`, `REQ-RECOVERY-001`
- Flow IDs: `FLOW-ACTIVATE-001`
- Job to be done: Create an adult account with minimal trust and privacy friction.
- Entry and preconditions: Signed-out user chooses Create Account.
- Roles and permissions: New adult user; account creation grants no Dynamic membership or consent.
- Business logic and state transitions: Confirm 18+/Terms/Privacy and enter the current authentication flow; preserve invite context when applicable.
- Acceptance criteria: Validation and recovery are clear; no duplicate account/session action on retry.

Product references now point to the migrated CURRENT v2 contracts. This package remains blocked until its visual/state family is reconciled and approved; the preview does not authorize additional assumptions.

### Known alignment work

- confirm age gate, terms, and magic-link flow

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
| `mark.authority` | Resolve purpose from the approved visual and asset registry | `manifests/assets.json` | approved — SVG Freeze v1 |

Bundled fonts are under `design/assets/fonts/`. Do not trace, redraw, or embed one-off SVG paths from the preview.

## 5. Implementation and QA gate

- [ ] Requirement and flow IDs approved
- [ ] Product logic and permissions approved
- [ ] Default, loading, empty, error, offline and authorization states approved
- [ ] Copy and platform differences approved
- [ ] All required Asset IDs resolve to approved source files
- [ ] Build gate changed to `ready_for_build`
- [ ] Reference-size implementation render stored under `design/qa/implementation/SCR-06/`
- [ ] Android comparison recorded

Current result: **blocked_alignment_required**.
