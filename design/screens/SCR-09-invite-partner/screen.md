# SCR-09 — Invite Partner

## Metadata

| Field | Value |
|---|---|
| Screen ID | `SCR-09` |
| Revision | `1` |
| Release tier | Core Beta |
| Platforms | Android, Web |
| Disposition | `retain_and_align` |
| Build gate | `blocked_alignment_required` |
| Visual reference | [`preview.webp`](preview.webp) |
| Candidate revision | [`candidates/rev-2/preview.webp`](candidates/rev-2/preview.webp) |
| Preserved source | `02 Role and Pairing Setup/09-invite-partner.webp` |

## 1. Product contract

- Requirement IDs: `REQ-INVITE-001`, `REQ-IDEMP-001`, `REQ-RECOVERY-001`
- Flow IDs: `FLOW-ACTIVATE-001`
- Job to be done: Share a private Web invite and understand its current lifecycle state.
- Entry and preconditions: Couple-mode creator has a minimal Dynamic/Starter context.
- Roles and permissions: Authorized inviter; invite token does not itself grant long-term access.
- Business logic and state transitions: Create/share one invite and resolve Pending, Accepted, Expired or Revoked from server truth.
- Acceptance criteria: Share/copy/retry is recoverable on Android/Web and stale links never enter the wrong Dynamic.

Product references now point to the migrated CURRENT v2 contracts. This package remains blocked until its visual/state family is reconciled and approved; the preview does not authorize additional assumptions.

### Known alignment work

- add pending, accepted, expired, revoked states

### Candidate revision 2

The revised primary surface removes the obsolete onboarding-step treatment and establishes Invite as a post-setup lifecycle. Its sealed-invitation structure gives the pending state clear relational presence without implying that the Dynamic has already begun.

- Primary state represented: `Pending`.
- Lifecycle is visible as `Pending / Accepted / Expired / Revoked` without turning those labels into simultaneous actions.
- Share, copy and revoke are distinct operations; revocation remains a deliberate text action.
- “Nothing begins until both of you agree” is the governing trust statement.
- Candidate approval does not remove the need for accepted, expired, revoked and recovery variants.

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
| `icon.share` | Primary native share action | `manifests/assets.json` | planned — SVG master required |
| `icon.copy` | Copy private invite link/code | `manifests/assets.json` | planned — SVG master required |
| `icon.revoke` | Revoke the current invite | `manifests/assets.json` | planned — SVG master required |

Bundled fonts are under `design/assets/fonts/`. Do not trace, redraw, or embed one-off SVG paths from the preview.

## 5. Implementation and QA gate

- [ ] Requirement and flow IDs approved
- [ ] Product logic and permissions approved
- [ ] Default, loading, empty, error, offline and authorization states approved
- [ ] Copy and platform differences approved
- [ ] All required Asset IDs resolve to approved source files
- [ ] Build gate changed to `ready_for_build`
- [ ] Reference-size implementation render stored under `design/qa/implementation/SCR-09/`
- [ ] Android and Web comparison recorded

Current result: **blocked_alignment_required**.
