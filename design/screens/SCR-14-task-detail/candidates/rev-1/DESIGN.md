# SCR-14 rev-1 — occurrence detail design

Status: **candidate for approval; no build gate change**. Reference viewport:
390 × 844. The page may scroll, but the header and action region keep their
order. This candidate removes proof/photo capture and never treats completion,
adjustment, review, or acknowledgement as interchangeable.

## Family contract

- Use `color.semantic.canvas.ritual`, `size.layout.mobileInset` (`space.5`),
  the 4dp spacing scale, and `opacity.grain`. The close control is existing
  navigation chrome in a `size.control.iconButton` target; it is not a SCR-14
  asset.
- The top reading region keeps the reference composition: page context, close,
  a `borderWidth.hairline` editorial rule, temporal eyebrow, expectation,
  attribution, then Intention / Completion / Boundary. Content sits
  `space.12` from the rule; section gaps use `space.6` or `space.8`.
- The expectation title uses `display.ritual` because of its ritual-focus role.
  Partner-authored acknowledgement text, when present, uses `display.partner`.
  All labels, status, metadata, controls, and system copy use Inter.
- Render actions directly from the latest `allowedActions`. Do not infer them
  from `state`, role, `dueAt`, or cached data. An absent action is withheld, not
  disabled. A mutation is successful only after server confirmation, followed
  by a fresh occurrence read.
- When four actions are returned, use a two-column grid with four identical
  `size.control.button` controls, `space.3` gaps, `radius.control`, and the same
  primary-action surface. Three actions use three equal full-width controls;
  one action uses one full-width control. Order follows the mapping below.
  Equal geometry and treatment make adjustment a peer of completion.
- `state.completed` is the only registered SCR-14 mark. Use it only for a
  server-confirmed completion. Every other state is carried by exact text and
  primitive rules/surfaces. A review, adjustment, waiting, error, offline, or
  authorization mark would require an asset-contract change.
- No photo/proof control, points, streak, score, trophy, warning-red treatment,
  partner-voice system copy, or completion-as-notification copy appears in any
  state.

### Server action labels

| `allowedActions` value | Exact control copy | Order / destination |
|---|---|---|
| `complete` | `Complete` | 1; inline completion confirmation |
| `discuss` | `Discuss` | 2; adjustment flow |
| `reschedule` | `New time` | 3; adjustment flow |
| `cant_do` | `Can’t do` | 4; adjustment flow |
| `withdraw` | `Withdraw request` | only action; fresh server confirmation required |
| `acknowledge` | `Acknowledge` | 1; SCR-33 composer |
| `praise` | `Praise` | 2; SCR-33 composer |
| `comment` | `Comment` | 3; SCR-33 composer |
| `review` | `Review` | 1; review resolution |
| `excuse` | `Excuse` | 2; review/adjustment resolution |
| `continue` | `Continue` | 1; adjustment resolution |
| `adjust` | `Adjust` | 2; adjustment resolution |
| `cancel` | `Cancel` | last; adjustment resolution |

Every control uses `label.action`,
`color.semantic.action.primary.background`, and
`color.semantic.action.primary.foreground`. `Cancel` does not take destructive
styling on this page; `color.semantic.action.destructiveFinal.*` is reserved for
its final confirmation threshold.

## Shared confirmed-detail hierarchy

| Element | Exact copy / composition | Frozen token or mark |
|---|---|---|
| Header | `TODAY / TASK` at left; Close at right | `label.ritual` + muted text; close target `size.control.iconButton`; primary icon tone |
| Editorial rule | Vertical rule from temporal block through Boundary; no decorative node | `borderWidth.hairline`; `color.semantic.decorative.ritualLine` |
| Temporal eyebrow | State-specific text below | `label.ritual`; muted or state-specific text token |
| Time | State-specific formatted `dueAt` or `completedAt` | `body.secondary`; secondary text |
| Expectation | `{title}` | `display.ritual`; primary text |
| Attribution | `Set by {partnerDisplayName}` | `body.secondary`; secondary text; no presence mark and no invented set time |
| Intention | `INTENTION` then `{purpose}` | `label.ritual` + muted text; `body.primary` + secondary text |
| Completion | `COMPLETION` then `A short note is enough.` | `label.ritual` + muted text; `body.primary` + secondary text |
| Boundary | `BOUNDARY` then `Pause if this no longer feels right.` | `label.ritual` + muted text; `body.primary` + secondary text |
| Section dividers | Between Intention, Completion, and Boundary | `borderWidth.hairline`; on-ritual hairline |
| Action label | `WHAT FITS NOW` | `label.ritual`; muted text |
| Action group | Exactly the controls represented in `allowedActions` | Geometry and colors in Family contract; no action icons |

If `purpose` is absent, withhold the complete Intention section and close its
space. Completion and Boundary remain system-authored guidance. Do not show an
empty value or invent an intention.

## 1. Default — `ACTIVE`, assignee

| Element | Exact copy / composition | Frozen token or mark |
|---|---|---|
| Temporal block | `DUE`; `{formatted dueAt}` | `label.ritual` + muted text; `body.secondary` + secondary text |
| Detail | Shared confirmed-detail hierarchy | Shared bindings above |
| Optional note | `PRIVATE NOTE WITH COMPLETION (OPTIONAL)`; placeholder `What did you attend to?` | `label.ritual` + muted text; `size.control.textField`; transparent surface; hairline bottom border; `body.primary` |
| Actions | `Complete`; `Discuss`; `New time`; `Can’t do` when those four values are returned | Equal two-column standard buttons; `label.action` |

The note is submitted only with `complete`; entering an adjustment path does
not send it. There is no Add photo row. Completion success resolves to
`WAITING_ACK`; it never displays “notified,” “done,” or acknowledgement copy.

**Withheld:** proof/photo capture, inferred actions, set time not supplied by
the endpoint, completion outcome, partner response, and any claim about what
the partner will do.

## 2. Needs review — `NEEDS_REVIEW`

Both directions use `color.semantic.state.needsReview` (Stone), never
Terracotta, and no mark. They retain the expectation and its context instead of
turning the page into an alert.

### Direction A — review in temporal context (**recommended**)

| Element | Exact copy / composition | Frozen token or mark |
|---|---|---|
| Temporal eyebrow | `NEEDS REVIEW` | `label.ritual`; `color.semantic.state.needsReview` |
| Time | `Due {formatted dueAt}` | `body.secondary`; muted text |
| Quiet explanation | Directly below the time: `This is past due. It only needs another look.` | `body.secondary`; secondary text; no surface, icon, or accent border |
| Detail | Expectation, attribution, Intention / Completion / Boundary | Shared bindings |
| Action label | Assignee: `WHAT FITS NOW`; creator: `HOW SHOULD THIS CONTINUE` | `label.ritual`; muted text |
| Assignee actions | `Complete`; `Discuss`; `New time`; `Can’t do`, only when returned | Equal two-column standard buttons |
| Creator actions | `Review`; `Excuse`; `New time`, only when returned | Three equal full-width standard buttons |

**Why recommended:** the due fact and its meaning are read together before the
person reaches the expectation. The page names the server state without adding
a warning object or emotional escalation.

### Direction B — review at the decision point

Keep the shared temporal block as `DUE` / `{formatted dueAt}`. Add `NEEDS
REVIEW` to the header’s left context after `TODAY / TASK`, using
`label.ritual` and `color.semantic.state.needsReview`. Immediately above the
action group place a tonal review block:

| Element | Exact copy / composition | Frozen token or mark |
|---|---|---|
| Review label | `TAKE ANOTHER LOOK` | `label.ritual`; state needsReview text |
| Review copy | `This is past due. Choose what fits now.` | `body.primary`; secondary text |
| Review surface | Full content width; `space.4` inset; no icon or warning border | Raised ritual surface; `radius.card` |
| Actions | Same authoritative assignee/creator variants as Direction A | Same equal control treatment |

**Trade-off:** the prompt is closer to the decision, but state meaning arrives
later and the raised block has more visual weight than the fact warrants.

**Withheld in both directions:** punishment, consequence, “missed,” failure,
urgency, countdown, streak impact, red alert, inferred role, and any review
mark. If a visual state mark is later required, change the SCR-14 asset contract
before design or implementation.

## 3. Adjustment open

This is the assignee’s own pending request. Keep the full confirmed detail and
replace the action group with one calm status block and the one returned action.

| Server state | Exact status label |
|---|---|
| `NEED_TO_DISCUSS` | `DISCUSSION OPEN` |
| `RESCHEDULE_REQUESTED` | `NEW TIME REQUESTED` |
| `EXCUSE_REQUESTED` | `CAN’T DO REQUESTED` |

| Element | Exact copy / composition | Frozen token or mark |
|---|---|---|
| Temporal block | `DUE`; `{formatted dueAt}` | Shared temporal bindings |
| Request label | State-specific label above | `label.ritual`; muted text; no mark |
| Request statement | `Your request is open.` | `body.primary`; secondary text |
| Supporting copy | `{partnerDisplayName} can respond when they’re ready.` | `body.secondary`; muted text |
| Action | `Withdraw request`, only when `withdraw` is returned | One full-width standard primary button; `label.action` |

**Shown:** the original occurrence context, the kind of request, its pending
status, and withdrawal agency. **Withheld:** completion and every adjustment
action not returned, predicted response time, blame, and failure language.

`withdraw` is design-ready but **backend-blocked**: the server advertises it and
has no mutation endpoint. Do not ship a dead control, queue it, or simulate
success. The endpoint and idempotent confirmation behavior are required before
this state becomes buildable.

## 4. Waiting for acknowledgement — `WAITING_ACK`

| Element | Exact copy / composition | Frozen token or mark |
|---|---|---|
| Temporal eyebrow | `COMPLETED`; `{formatted completedAt}` | `label.ritual` + muted text; `body.secondary` + secondary text |
| Completion mark | Beside the temporal block, after server confirmation only | `state.completed`, 32dp; `color.semantic.state.completed` |
| Detail | Expectation, attribution, and Intention / Completion / Boundary remain readable | Shared bindings |
| Assignee statement | `Your part is complete.` | `body.primary`; primary text |
| Assignee waiting copy | `Waiting for {partnerDisplayName} to respond.` | `body.secondary`; muted text |
| Creator statement | `{partnerDisplayName} completed this at {formatted completedAt}.` | `body.primary`; secondary text; system-authored Inter, never `display.partner` |
| Creator action label | `RESPOND TO {PARTNERDISPLAYNAME}` | `label.ritual`; muted text; ellipsize safely |
| Creator actions | `Acknowledge`; `Praise`; `Comment`, only when returned | Three equal full-width standard buttons; open SCR-33 |
| Private note, when present to its author | `PRIVATE NOTE · ONLY YOU`; `{privateNote}` | `label.ritual` + muted text; raised ritual surface; `radius.card`; `body.primary` + secondary text |

If the current viewer receives no actions, show the assignee statement and no
action region. If response actions are returned, show the creator variant; do
not infer that variant from identity. If an acknowledgement later exists, its
human-authored `text` may use `display.partner`, with sender attribution and
`sentAt` in `body.secondary`; that is a subsequent acknowledged state, not this
waiting state.

**Withheld:** “done,” “closed,” “notified,” a filled acknowledgement node,
predicted response, response copy before it exists, and actions absent from the
server array.

## 5. Loading

Reserve header, editorial-rule, title, three-section, and action bands so the
confirmed page does not jump. Leave content bands empty; do not draw text-line,
name-, time-, or title-shaped skeletons.

| Element | Exact copy / composition | Frozen token or mark |
|---|---|---|
| Header | `TASK DETAIL`; Close | `label.ritual` + muted text; close target `size.control.iconButton` |
| Temporal eyebrow | `CHECKING` | `label.ritual`; muted text |
| Headline | `Confirming where this stands.` | `display.ritual`; primary text |
| Explanation | `Details and actions appear after the server confirms them.` | `body.secondary`; muted text |
| Reserved structure | Empty editorial rule and content/action bands | Spacing tokens; hairline ritual line; no mark or skeleton |

**Withheld:** all endpoint values, cached state, names, title, times, note,
acknowledgement, every action, and `state.completed`.

## 6. Error

An authenticated refresh error keeps safe, last-confirmed occurrence content
only when it was already visible in this session. Prefix the temporal block
with `NOT REFRESHED`; remove the complete action region. On first-load error,
use only the recovery composition below.

| Element | Exact copy / composition | Frozen token or mark |
|---|---|---|
| Status | `NOT REFRESHED` | `label.ritual`; `color.semantic.state.error` |
| Headline | `We couldn’t refresh this expectation.` | `title.page`; primary text |
| Explanation | `Your place is still here. Try again for the current details and actions.` | `body.primary`; secondary text |
| Primary action | `Try again` | Standard primary button; `label.action` |
| Secondary action | `Close` | `size.touchTarget` text action; secondary foreground |

**Shown:** navigation context and clearly qualified last-confirmed detail, if
available. **Withheld:** all actions, unqualified cached state, technical error
text, blame, success feedback, and a state mark. Retry reuses the same opaque
occurrence reference and does not create a mutation.

## 7. Offline

Keep safe, last-confirmed detail only when it was already visible in the
authorized session; label it historically. Do not show disabled mutation
controls because that would present stale permissions as current permissions.

| Element | Exact copy / composition | Frozen token or mark |
|---|---|---|
| Status | `OFFLINE · LAST CONFIRMED` | `label.ritual`; muted text |
| Headline | `This detail can’t be confirmed right now.` | `title.page`; primary text |
| Explanation | `Reconnect before choosing an action.` | `body.primary`; secondary text |
| Primary action | `Try again` | Standard primary button; `label.action` |
| Secondary action | `Close` | `size.touchTarget` text action; secondary foreground |

**Withheld:** every `allowedActions` control, mutation field, queued mutation,
current-state claim, and state mark. If no last-confirmed detail exists, show
only this recovery copy. Reconnection always performs a fresh GET before any
action is offered.

## 8. Authorization loss

Use the SCR-09 rev-3 neutral account checkpoint. It replaces the entire task
shell and reveals neither that a particular partner nor occurrence exists. An
opaque return reference may remain in memory but is not rendered or logged.

| Element | Exact copy / composition | Frozen token or mark |
|---|---|---|
| Header | `COMPANION`, centred; no back, close, or right status | `label.ritual`; muted text |
| Status field | One static 80dp circle outline; no dot, lock, rings, or pulse | Primitive: `borderWidth.hairline` + ritual line; no SVG mark |
| Eyebrow | `EXPECTATION · ACCOUNT NEEDED` | `label.ritual`; muted text |
| Headline | `Confirm your account to continue.` | `display.ritual`; primary text; centred |
| Explanation | `This expectation is not shown until we know who is looking.` | `body.primary`; secondary text; centred |
| Divider | Full content width after `space.8` | Hairline + on-ritual hairline |
| Agency line | `Confirming an account does not change this expectation.` | `body.secondary`; muted text; centred |
| Primary action | `Confirm account` | Standard primary button; `label.action` |
| Secondary action | `Use a different account` | `size.touchTarget` text action; secondary foreground |
| Footer | `No Dynamic details are shown until access is confirmed.` | `body.secondary`; muted text |

**Withheld:** task header, close/back destination, partner name, title, purpose,
due/completion times, private note, acknowledgement, editorial rail, all state
and action information, `allowedActions`, and `state.completed`. After account
recovery, fetch server truth before restoring any detail; never restore cached
state or actions directly.

## Approval recommendation

Approve Needs-review Direction A. It names the server truth beside the due fact,
uses the frozen neutral review color without inventing a mark, and reaches the
same peer action grammar as Active. Direction B is safe but gives an ordinary
past-due transition unnecessary container weight. Approval of this design does
not clear the screen’s build gate; the missing `withdraw` endpoint, responsive
Web behavior, state renders, and Android/Web verification remain required.
