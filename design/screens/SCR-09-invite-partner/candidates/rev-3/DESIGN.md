# SCR-09 rev-3 — blocked-state design

Status: **candidate for approval; no build gate change**. Scope is `loading`, `share-error`, `offline`, and `authorization-loss` only. Reference viewport: 390 × 844.

## Family rules

- Use `color.semantic.canvas.ritual`, `size.layout.mobileInset` (`space.5`), and the 4dp spacing scale. Controls use `size.control.button` or `size.control.buttonRitual` only where noted, with `radius.control`.
- The authenticated owner shell keeps the back control, centred `Private invitation`, and right-hand status in `label.ritual`. The back target is `size.control.iconButton`; its arrow is existing navigation chrome, not a new SCR-09 asset.
- The lifecycle track always reads `Pending — Accepted — Expired — Revoked`. Its axis and nodes are primitives using `borderWidth.hairline`; labels use `nav.label`. It is informational, never four actions.
- `display.ritual` is the single centred system-authored statement. Operational recovery copy beneath it stays Inter (`body.primary`, `body.secondary`, `label.action`, `label.ritual`).
- `motif.botanical.invite-branch`, when present, is 160 or 220dp in `color.semantic.decorative.botanical` at `opacity.botanical`. It never carries state or competes with recovery copy.
- Terracotta is used only for confirmed relationship presence/state. Errors and offline states use neutral tokens; no warning red, invented error/offline mark, or unregistered privacy/lock icon is introduced.
- Authorization loss is the exception to the owner shell: it withholds all Dynamic context and uses the neutral SCR-10 account-recovery composition.

## 1. Loading

Loading reserves the approved Pending page bands from first paint: header, 80dp bond-mark slot, centred statement, invitation-detail/action region, and lifecycle track. The private link/action region is blank reserved space; it is not rendered as name- or code-shaped skeletons.

### Direction A — state-silent shell (**recommended**)

| Element | Exact copy / composition | Frozen token or mark |
|---|---|---|
| Header | Back; `Private invitation`; `CHECKING` | Back target `size.control.iconButton`; title `body.secondary` + primary text; status `label.ritual` + muted text |
| Bond region | Keep the approved 80dp slot empty. The state-bearing bond mark is withheld, not faded. | `space.20` reserved height; no mark |
| Headline | `Checking this invitation.` | `display.ritual`; primary text; centred |
| Explanation | `We’re confirming its current status.` | `body.secondary`; muted text; centred |
| Detail/action region | Preserve the approved region height without visible code, expiry, action rows, or skeletons. | Spacing tokens only; no asset |
| Lifecycle track | Show the full axis, four hollow equal nodes, and all four labels. No node is filled, enlarged, or Terracotta. | Hairline axis/nodes with `color.semantic.border.onRitual.hairline`; `nav.label` + muted text |

**Shown:** current server resolution, stable page geometry, and the complete lifecycle vocabulary.

**Withheld:** partner name, invite code/link, expiry, cached lifecycle position, bond state, botanical motif, share/copy/revoke actions, and all cached status copy. A timeout becomes a recoverable resolution error; confirmed loss of connectivity becomes Offline.

**Why choose it:** absence is the only treatment that does not make the Pending bond mark or any lifecycle node look like current truth. The stable reserved bands prevent layout jump without presenting stale content.

### Direction B — neutral progress in the bond slot

Keep Direction A unchanged except the empty bond slot contains a centred, indeterminate 64dp progress ring. It is a control primitive, not a relationship mark: one moving arc over a hairline circle, using `color.semantic.icon.muted` over `color.semantic.decorative.ritualLine`. Accessible text remains `Checking this invitation`; there is no percentage or countdown.

This direction makes activity more visible and still leaves every lifecycle node unselected. It is not preferred because a new circular focal form competes with the bond mark’s established place and makes the transition to resolved state feel like an emblem swap.

## 2. Share error

This state starts only after the current invite has resolved as Pending and the native share hand-off did not complete. The approved Pending composition remains visible: partner fact, current code, expiry, Pending bond mark, botanical motif, and Pending lifecycle position. Retry must invoke sharing for the same invite ID and link; it never creates or rotates an invite.

### Direction A — recovery at the failed action (**recommended**)

Keep the Pending header (`PENDING`), bond mark, headline, waiting statement, private code block, and lifecycle track in their approved positions. Replace only the share-action group with the following operational block:

| Element | Exact copy / composition | Frozen token or mark |
|---|---|---|
| Recovery label | `SHARING DIDN’T COMPLETE` | `label.ritual`; `color.semantic.state.error` |
| Recovery statement | `Your invitation is still active.` | `body.primary`; primary text |
| Explanation | `Only sharing was interrupted. Try again to share this same invitation.` | `body.secondary`; muted text |
| Primary action | `Share again` | `icon.share`, 24dp, primary; `size.control.buttonRitual`; primary action colors; `label.action` |
| Safe fallback | `Copy link` | `icon.copy`, 20dp, muted; `size.control.listRow`; `body.secondary`; secondary foreground |
| Existing mutation | `Revoke invitation` remains in its approved row and confirmation flow. | `icon.revoke`, 20dp, muted; `size.control.listRow`; `body.secondary` |

The retained Pending elements keep their rev-2 bindings: `mark.partner-bond` at 80dp with relationship presence, `display.ritual` headline, `label.ritual` code label/status, `body.secondary` supporting copy, and a Pending-filled lifecycle node using relationship presence plus a text label so color is not the sole cue.

**Shown:** Morgan as a factual recipient, the same live code/link and expiry, confirmed Pending position, the failed share hand-off, retry, copy, and deliberate revoke.

**Withheld:** platform error internals, blame, urgency, any “invitation failed” language, and every create/new-link action.

**Why choose it:** the live invitation never disappears, and the recovery sits at the operation that failed. “Still active” plus “same invitation” removes the duplicate-link ambiguity before retry.

### Direction B — operational notice above unchanged actions

Keep the full Pending action stack in place. Insert a raised notice immediately above it:

| Element | Exact copy / composition | Frozen token or mark |
|---|---|---|
| Notice label | `SHARE INTERRUPTED` | `label.ritual`; state error |
| Notice copy | `The invitation is still active. Sharing it did not complete.` | `body.primary`; secondary text |
| Notice surface | Tonal block, no warning border or icon | `color.semantic.surface.ritual.raised`; `radius.card`; `space.4` inset |
| Primary action below | `Try sharing again` | `icon.share`, 24dp; ritual primary button |
| Remaining actions | `Copy link`; `Revoke invitation` | Existing approved Pending rows and icons |

This direction preserves the original action stack more literally and makes the failure dismissible after another successful share. It is not preferred because the added card creates a second container and separates the explanation from the control it qualifies.

## 3. Offline

Offline is an authenticated owner state, not the withheld SCR-10 receiver state. Keep the locally held invitation visible and make its freshness limits explicit. Sharing or copying the stored link does not mutate server state; revoke is unavailable and is never queued.

| Element | Exact copy / composition | Frozen token or mark |
|---|---|---|
| Header | Back; `Private invitation`; `OFFLINE` | Shared owner header; status `label.ritual` + muted text |
| Bond mark | Show the last confirmed bond state, never animated. | `mark.partner-bond`, 80dp; primary/relationship tone licensed by SVG freeze |
| Headline | `Your invitation is still here.` | `display.ritual`; primary text; centred |
| Availability | `You’re offline. You can still share or copy the saved link.` | `body.primary`; secondary text |
| Freshness note | `Its current status will be checked when you reconnect.` | `body.secondary`; muted text |
| Code block | `PRIVATE LINK / CODE`; stored code; stored expiry text. Prefix the lifecycle fact with `Last confirmed: Pending`. | Label/code bindings from Pending; supporting copy `body.secondary`; no Terracotta text |
| Primary action | `Share invitation` | `icon.share`, 24dp; ritual primary button; same stored invite |
| Safe action | `Copy link` | `icon.copy`, 20dp; active list row |
| Retry | `Try again` | 48dp secondary text action; secondary foreground; fresh server resolve |
| Mutation row | `Revoke unavailable offline` | `icon.revoke`, 20dp; `size.control.listRow`; disabled background/foreground and `opacity.disabled`; no tap action |
| Mutation note | `Revoking needs a connection and will not be queued.` | `body.secondary`; muted text |
| Lifecycle track | Keep all four nodes. Mark the cached node with an outline, not a filled current-state node, and pair it with the `Last confirmed: Pending` text above. | Hairline track; strong border on cached node; `nav.label` + muted text; no relationship fill |

**Shown:** owned partner/invite facts already stored on device, safe share/copy, offline status, historical lifecycle position clearly qualified as last confirmed, fresh retry, and the unavailable revoke.

**Withheld:** any claim that the cached state or expiry is current, successful revoke feedback, queued mutation, new-invitation creation, and server-only updates since the last check. If no locally stored invite exists, do not fabricate a code block; show the headline, connectivity copy, neutral track, and `Try again` only.

## 4. Authorization loss

Authorization loss uses the neutral account checkpoint rather than the owner shell. It does not reveal that a particular Dynamic, partner, or active invitation exists. The route may retain an opaque recovery reference in memory, but no protected value is rendered or logged.

| Element | Exact copy / composition | Frozen token or mark |
|---|---|---|
| Header | `COMPANION`, centred; no back arrow or right status | `label.ritual`; muted text |
| Status field | One static 80dp circle outline; neutral, with no dot, rings, lock, or pulse | Primitive using `borderWidth.hairline` + `color.semantic.decorative.ritualLine`; no SVG mark |
| Eyebrow | `PRIVATE INVITATION · ACCOUNT NEEDED` | `label.ritual`; muted text |
| Headline | `Confirm your account to continue.` | `display.ritual`; primary text; centred |
| Explanation | `This invitation is not shown until we know who is looking.` | `body.primary`; secondary text; centred |
| Divider | Full content width after `space.8` | Hairline + on-ritual hairline |
| Agency line | `Confirming an account does not change this invitation.` | `body.secondary`; muted text; centred |
| Primary action | `Confirm account` | Standard primary button; `label.action` |
| Secondary action | `Use a different account` | 48dp text action; secondary foreground |
| Footer | `No Dynamic details are shown until access is confirmed.` | `body.secondary`; muted text; no icon |

**Shown:** only the need for account confirmation, the fact that confirmation does not alter the invitation, and session-recovery choices.

**Withheld:** `Private invitation` owner header, partner name, invite code/link, expiry, bond mark, botanical motif, lifecycle track/position, cached status, current account name/email/avatar, whether another account is signed in, and the reason authorization was lost. `icon.private-space`, `state.locked`, and `state.auth-restored` are not used because none is registered for SCR-09.

After successful account recovery, resolve server truth before restoring this screen. Route to Pending, Accepted, Expired, Revoked, Loading, Offline, or another recovery state from that fresh result; never restore cached lifecycle truth directly.

## Approval recommendation

Approve Loading Direction A and Share-error Direction A. Together they preserve the rev-2 composition while making the two essential distinctions explicit: unresolved truth is not displayed as lifecycle truth, and an interrupted share is not presented as an invalid invitation. This candidate completes the four blocked-state design coverage only; `screen.md`, platform behavior, reference renders, comparisons, and the build gate remain unchanged until explicit approval.
