# SCR-10 — Web Join Trust

## Metadata

| Field | Value |
|---|---|
| Screen ID | `SCR-10` |
| Revision | `1` |
| Release tier | Core Beta |
| Platforms | Web, Android |
| Disposition | `retain_and_align` |
| Build gate | `ready_for_build` |
| Visual reference | [`preview.webp`](preview.webp) |
| Candidate revision | [`candidates/rev-2/preview.webp`](candidates/rev-2/preview.webp) |
| Preserved source | `03 Pairing Consent and Foundation/10-invitation-received.webp` |

## 1. Product contract

- Requirement IDs: `REQ-JOIN-001`, `REQ-AUTH-001`, `REQ-PRIVACY-001`, `REQ-RECOVERY-001`
- Flow IDs: `FLOW-ACTIVATE-001`
- Job to be done: Understand who invited me, what I am joining and what remains mine.
- Entry and preconditions: Invitee opens `/invite/{opaque_token}` on Web or Android.
- Roles and permissions: Invitee; join is explicit, authenticated under the final trust decision, and never consent to future expectations.
- Business logic and state transitions: Resolve invite, survive auth callback, show intention/shared-private/leave framing, then confirm or decline.
- Acceptance criteria: Accepted/expired/revoked/stale states are explicit and no protected Dynamic data leaks.

Product references now point to the migrated CURRENT v2 contracts. This package remains blocked until its visual/state family is reconciled and approved; the preview does not authorize additional assumptions.

### Known alignment work

- becomes Web Join trust screen
- show shared intention, shared/private boundary, leave right

### Candidate revision 2

The revised mobile-Web trust surface makes the invitation legible before authentication or acceptance. It uses an asymmetric shared/private ledger rather than repeating the creator-side sealed-invitation structure.

- Inviter identity and shared intention lead the page.
- “Shared together” and “Stays yours” are intentionally separate information regions.
- Joining is explicitly not consent to future expectations.
- Role choice, pause and leave rights remain with the invitee.
- Candidate approval does not remove the need for auth-return, expired, revoked, stale and session-recovery variants.

#### Recovery and safe-state candidates

- [`Expired`](candidates/rev-2/states/expired/preview.webp) — hides inviter and Dynamic content, confirms that no membership exists and offers safe navigation.
- [`Auth Return`](candidates/rev-2/states/auth-return/preview.webp) — preserves the invitation through magic-link authentication while keeping final Join review explicit.
- These are mobile-Web states. They share product meaning with Android but preserve browser/session behavior.

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
| Default trust review | Pending invite resolved | Show inviter, intention, shared/private boundary and leave right | candidate rev-2 |
| Auth return | Identity restored; Join not yet confirmed | Preserve invite context and return to explicit review | candidate rev-2 |
| Expired | Invite is Expired | Hide protected context; confirm no membership | candidate rev-2 |
| Revoked/stale | Invite unavailable or access relation changed | Neutral safe landing with no sensitive content | candidate rev-3 |
| Loading | Resolve token and current server truth | Stable privacy-safe loading surface | candidate rev-3 |
| Error and retry | Recover without dropping invite context | Explicit retry and retained safe context | candidate rev-3 |
| Offline | Cannot confirm current invite truth | Explain offline state; never infer validity | candidate rev-3 |
| Authorization loss/shared device | Session is absent, expired or wrong account | Hide protected content and offer safe account recovery | candidate rev-3 |

## 4. Asset contract

| Asset ID | Purpose | Registry | Status |
|---|---|---|---|
| `mark.partner-bond` | Resolve purpose from the approved visual and asset registry | `manifests/assets.json` | approved — SVG Freeze v1 |
| `icon.shared-space` | Identify information shared by the Dynamic | `manifests/assets.json` | approved — SVG Freeze v1 |
| `icon.private-space` | Identify information retained by the member | `manifests/assets.json` | approved — SVG Freeze v1 |
| `icon.leave-right` | Reinforce pause/leave agency | `manifests/assets.json` | approved — SVG Freeze v1 |
| `state.invite-expired` | Safe expired-link identity | `manifests/assets.json` | approved — SVG Freeze v1 |
| `state.auth-restored` | Identity restored while Join remains pending | `manifests/assets.json` | approved — SVG Freeze v1 |
| `motif.botanical.note-sprig` | Restrained trust-layer accent; decorative and non-interactive | `manifests/assets.json` | approved — SVG Freeze v1 |

Bundled fonts are under `design/assets/fonts/`. Do not trace, redraw, or embed one-off SVG paths from the preview.

## 5. Implementation and QA gate

- [ ] Requirement and flow IDs approved
- [ ] Product logic and permissions approved
- [ ] Default, loading, empty, error, offline and authorization states approved
- [ ] Copy and platform differences approved
- [ ] All required Asset IDs resolve to approved source files
- [ ] Build gate changed to `ready_for_build`
- [ ] Reference-size implementation render stored under `design/qa/implementation/SCR-10/`
- [ ] Android and Web comparison recorded

Current result: **blocked_alignment_required**.
