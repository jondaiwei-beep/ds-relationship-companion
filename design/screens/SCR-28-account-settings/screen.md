# SCR-28 — Account and Settings

## Metadata

| Field | Value |
|---|---|
| Screen ID | `SCR-28` |
| Revision | `1` |
| Release tier | Core Beta |
| Platforms | Android |
| Disposition | `retain_and_align` |
| Build gate | `blocked_alignment_required` |
| Visual reference | [`preview.webp`](preview.webp) |
| Preserved source | `09 Account Notification and Pairing/28-account-settings.webp` |

## 1. Product contract

- Requirement IDs: `REQ-AUTH-001`, `REQ-TIME-001`, `REQ-PRIVACY-001`
- Flow IDs: None
- Job to be done: Manage account, privacy, time and enabled support settings.
- Entry and preconditions: Authenticated member opens Settings from avatar.
- Roles and permissions: Account owner controls own account/device preferences.
- Business logic and state transitions: Add timezone/day-boundary entry; hide Subscription/App Lock when feature-gated; preserve sign out and privacy.
- Acceptance criteria: Settings expose only current-release capabilities and no raw backend state names.

Product references now point to the migrated CURRENT v2 contracts. This package remains blocked until its visual/state family is reconciled and approved; the preview does not authorize additional assumptions.

### Known alignment work

- add timezone and custom day boundary
- hide Subscription and App Lock when feature-gated

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
- [ ] Reference-size implementation render stored under `design/qa/implementation/SCR-28/`
- [ ] Android comparison recorded

Current result: **blocked_alignment_required**.
