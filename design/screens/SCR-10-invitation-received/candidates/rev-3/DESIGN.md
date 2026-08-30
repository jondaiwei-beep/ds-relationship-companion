# SCR-10 rev-3 — recovery-state design

Status: **candidate for approval; no build gate change**. Scope is the five blocked states only: `revoked`, `loading`, `error`, `offline`, and `authorization-loss`.

## Family rules

- Reference viewport: 390 × 844. Use `space.5` (20dp) horizontal insets and the 4dp spacing scale only.
- Every state uses `color.semantic.canvas.ritual`. It is a full-page Quiet Authority surface, not a card or dialog.
- The neutral header is the text `COMPANION`, not the relationship-category wordmark shown in the older references. It uses `label.ritual` and `color.semantic.text.onRitual.muted`; it has no mark. `mark.partner-bond` is withheld while invite truth is unresolved or unavailable rather than used as implied state evidence.
- System-authored recovery headings use `title.page`, not Cormorant. `type-in-practice.md` reserves Cormorant for words written by a person. The serif system headlines in the rev-2 recovery artwork are therefore not carried into these new states. If that exception is wanted, the type contract must be changed before build.
- Primary actions use `size.control.button` (56dp), `radius.control`, `color.semantic.action.primary.background` / `.foreground`, and `label.action`. Recovery is operational, so the 64dp ritual CTA is not used.
- Secondary text actions retain a `size.touchTarget` 48dp target and use `body.secondary` with `color.semantic.action.secondary.foreground`. No generic arrow is drawn and `icon.leave-right` is not reused as a chevron.
- Dividers are layout primitives: `borderWidth.hairline` with `color.semantic.border.onRitual.hairline`. Circles, progress arcs, and axes are also token-driven primitives, not SVG assets.
- Supporting copy uses `body.primary` with `color.semantic.text.onRitual.secondary`; quiet notes use `body.secondary` with `color.semantic.text.onRitual.muted`. No text uses Terracotta.
- The opaque invite token may be retained in memory/route state for retry or authentication return. It is never rendered, copied into analytics, or replaced by cached invite truth.
- Until a fresh server resolution succeeds, withhold inviter name, intended role, shared intention, Dynamic state/content, expiry, prior membership, account email/name/avatar, and any cached preview.
- Do not show skeleton lines shaped like names or relationship copy. They leak the kind and approximate amount of hidden content.

## 1. Revoked

### Direction A — unavailable, aligned to Expired (**recommended**)

Use the approved Expired composition: neutral header, a quiet central status field, label and title, one divider, a no-membership statement, then recovery actions and a privacy footnote. The page names the result without naming a cause or actor.

Why this direction: it gives a revoked token an explicit server-resolved landing rather than a 404, while “unavailable” also safely covers an access-relation change. It does not imply that the inviter, invitee, or another person did something wrong.

| Element | Exact copy / composition | Frozen token and mark |
|---|---|---|
| Header | `COMPANION`; top inset `space.8`, centered | `label.ritual`; muted text; no mark |
| Status field | One static 80dp circle outline; decorative only, no strike, cross, or warning pulse | Primitive using `borderWidth.hairline` + `color.semantic.decorative.ritualLine`; no state SVG |
| Eyebrow | `PRIVATE INVITATION · UNAVAILABLE` | `label.ritual`; `color.semantic.state.revoked` |
| Title | `This invitation is no longer available.` | `title.page`; primary text |
| Explanation | `No invitation details are shown here.` | `body.primary`; secondary text |
| Divider | Full content width after `space.8` | Hairline / on-ritual hairline |
| Assurance | `You have not joined anything.` | `title.page`; primary text |
| Guidance | `If you need a new invitation, ask the person who shared this link.` | `body.secondary`; muted text |
| Primary action | `I have another link` | Standard primary button; no mark |
| Secondary action | `Return to private entrance` | 48dp text action; no mark |
| Footer | `This link cannot be used to join anything.` | `icon.private-space`, 20dp, muted icon + `body.secondary`, muted text |

**Shown:** only the server-confirmed fact that this invitation cannot be used and the fact that no join occurred through it.

**Withheld:** inviter name, intended role, intention, expiry, whether it was manually revoked, whether access changed, who caused the change, any prior relationship, and any cached pending preview.

### Direction B — closed, state-mark led

Keep the same hierarchy but replace the circle with `state.invite-revoked` at 32dp in `color.semantic.icon.muted`. Copy becomes:

- Eyebrow: `PRIVATE INVITATION · CLOSED`
- Title: `This link has been closed.`
- Explanation: `It cannot be used to review or join an invitation.`
- Assurance, actions, and footer: same as Direction A.

This is more compact and makes the state visually distinct from Expired. It is not the recommendation because “closed” still invites speculation and because `state.invite-revoked` is frozen but is registered to SCR-09, not SCR-10. Selecting this direction requires an explicit SCR-10 asset-contract and manifest update; the candidate must not assume it.

## 2. Loading

Keep the shell fully stable so success or recovery replaces only the central state block. There is no percentage, countdown, relationship-shaped skeleton, or disabled invitation content behind it.

| Element | Exact copy / composition | Frozen token and mark |
|---|---|---|
| Header | `COMPANION` | Shared header tokens; no mark |
| Progress | 80dp quiet ring with one moving arc; reserve the final dimensions from first paint | Primitive: hairline ritual line + muted icon arc; no SVG mark |
| Eyebrow | `PRIVATE INVITATION` | `label.ritual`; muted text |
| Title | `Checking this invitation` | `title.page`; primary text |
| Explanation | `We’re confirming its current status.` | `body.primary`; secondary text |
| Footer | `Invitation details stay hidden until this check is complete.` | `icon.private-space`, 20dp, muted + `body.secondary`, muted text |

**Shown:** only that a current server check is in progress.

**Withheld:** all invite preview fields, cached status, account identity, and any suggestion that the invitation is valid. There are no actions while the first resolution is actively in flight; timeout becomes Error, and confirmed loss of connectivity becomes Offline.

## 3. Error

The loading block resolves in place to a calm retry state. Retain the opaque link context so retry repeats the anonymous server resolution; do not restore the last preview.

| Element | Exact copy / composition | Frozen token and mark |
|---|---|---|
| Header | `COMPANION` | Shared header tokens; no mark |
| Eyebrow | `INVITATION CHECK INCOMPLETE` | `label.ritual`; `color.semantic.state.error` |
| Title | `We couldn’t check this invitation.` | `title.page`; primary text |
| Explanation | `The link is still here. Try again to check its current status.` | `body.primary`; secondary text |
| Primary action | `Try again` | Standard primary button; no mark |
| Secondary action | `Return to private entrance` | 48dp text action; no mark |
| Footer | `No invitation details are shown until the check succeeds.` | `icon.private-space`, 20dp, muted + `body.secondary`, muted text |

There is no error illustration: the SCR-10 asset contract has no general error mark, and an improvised warning icon would break the asset freeze.

**Shown:** the failed check, retained safe link context, explicit retry, and safe exit.

**Withheld:** error internals, HTTP status, inviter/role/intention, cached server data, and any statement that the invitation is pending, expired, or revoked.

## 4. Offline

This state is distinct from Error because the system knows it cannot reach current server truth. Use the same composition and action positions to prevent a jump between the two.

| Element | Exact copy / composition | Frozen token and mark |
|---|---|---|
| Header | `COMPANION` | Shared header tokens; no mark |
| Eyebrow | `OFFLINE` | `label.ritual`; muted text |
| Title | `You’re offline.` | `title.page`; primary text |
| Explanation | `Connect to the internet, then check this invitation again. We can’t confirm whether it is available while you’re offline.` | `body.primary`; secondary text |
| Primary action | `Check again` | Standard primary button; no mark |
| Secondary action | `Return to private entrance` | 48dp text action; no mark |
| Footer | `Invitation details stay hidden while the current status cannot be confirmed.` | `icon.private-space`, 20dp, muted + `body.secondary`, muted text |

There is no invented Wi-Fi/offline glyph; none is registered for SCR-10. Connectivity is communicated by the explicit label and copy, not color alone.

**Shown:** confirmed offline condition, retry, safe exit, and the refusal to infer validity.

**Withheld:** cached invite preview and status, inviter identity, expiry countdown, account information, and any claim that the invite remains available. Reconnection does not reveal cached content; `Check again` performs a fresh resolve.

## 5. Authorization loss

This state appears when the session is absent, expired, or cannot be used for this invitation. All three cases share one neutral surface. Do not reveal whether a different account is currently signed in.

### Direction A — account checkpoint (**recommended**)

The layout is action-clear but explanatory: privacy mark, neutral title, one statement about verification, one statement preserving agency, then an account chooser.

| Element | Exact copy / composition | Frozen token and mark |
|---|---|---|
| Header | `COMPANION` | Shared header tokens; no mark |
| Privacy mark | Centered at 28dp after `space.12` | `icon.private-space`; `color.semantic.icon.muted` |
| Eyebrow | `ACCOUNT CHECK` | `label.ritual`; muted text |
| Title | `Confirm your account.` | `title.page`; primary text |
| Explanation | `We need to check your account before showing this invitation.` | `body.primary`; secondary text |
| Agency line | `Choosing an account does not join anything.` | `body.secondary`; muted text |
| Primary action | `Choose an account` | Standard primary button; no mark |
| Secondary action | `Return to private entrance` | 48dp text action; no mark |
| Footer | `Invitation details stay hidden until access is confirmed.` | `body.secondary`; muted text; no second icon |

Why this direction: “confirm” describes the system need without saying the person is signed out, using the wrong account, or at fault. The chooser works for absent, expired, and shared-device sessions. It also states plainly that authentication is not joining.

After account recovery, preserve the opaque link, resolve server truth again, and then route to Default trust review, Auth return, Expired, Revoked, or another recovery state. Never jump directly to Join.

### Direction B — action-first sign-in

Use no central mark. Keep the same actions, but use:

- Eyebrow: `PRIVATE INVITATION`
- Title: `Sign in to continue.`
- Explanation: `Invitation details are shown only after access is confirmed.`
- Agency line: `Signing in does not join anything.`
- Primary action: `Continue to sign in`
- Secondary action: `Use a different account`
- Tertiary action: `Return to private entrance`

All typography, colors, and controls use the shared tokens above. This is shorter and familiar, but it creates two account actions that may feel duplicative and “sign in” is not exact when a valid but ineligible account is already present. Direction A is safer and more truthful across the complete state.

**Shown in either direction:** only the need to confirm an account, the fact that authentication is not joining, and neutral recovery actions.

**Withheld in either direction:** inviter name, invitation content/status, current account email/name/avatar, whether a session expired, whether another account is signed in, which account is eligible, any prior membership, and the reason access was lost. Do not use `state.auth-restored` (restoration has not happened) or `state.locked` (not in the SCR-10 asset contract and reads as accusation).

## Approval dependencies

1. Approve one Revoked direction and one Authorization-loss direction. Recommendation: Revoked A and Authorization-loss A.
2. Confirm that the frozen person-authored-only Cormorant rule governs these system-authored recovery states; otherwise record a screen-level type exception before build.
3. If Revoked B is selected, add `state.invite-revoked` to the SCR-10 asset contract and `manifests/assets.json` usage before changing the screen gate.
4. This document completes design coverage only. `screen.md`, the manifest gate, responsive/platform differences, reference renders, and Android/Web comparison remain blocked work until explicit approval.
