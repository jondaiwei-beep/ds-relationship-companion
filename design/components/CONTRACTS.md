# Component contracts

Derived from the built and approved `SCR-01`. Each entry states the frozen
geometry, the tokens it consumes, and the product rule it carries. A component
that appears on a second screen should be promoted out of that screen's file
into a shared widget; until then this is the contract it must satisfy.

`design/tokens/B2-FREEZE.md` remains authoritative for values. This file records
how they compose.

---

## Primary action

56dp tall, full width of its column, `radius.control` 10dp,
`action.primary.background` on `action.primary.foreground`, label in
`label.action`.

Never 48dp — that is the minimum touch target, not the standard control height.
The 64dp `buttonRitual` is reserved for a hero CTA that is the only action on
the screen.

## Adjustment actions

Discuss · Request New Time · Can't Do, in a row beside the primary action, each
an equal flex cell at 48dp minimum height, `body.support` 12/17 in
`text.onRitual.primary`.

**These are structural furniture, not a menu.** Adjustment is a normal path, not
a failure, so they sit at the same level as Complete and are always visible.
They are never disabled, never collapsed behind an overflow, and never styled as
destructive. `product/ui-invariants.md` carries the tests.

Text must be `maxLines: 1` with `softWrap: false` — three labels in one row at
390dp is tight.

## Authority rule

A 1dp vertical line in `border.onRitual.strong` running the full height of the
first priority block, with 20dp between it and the content.

Signals that this item was set by the direction-giving person. Structural, not
decorative — it does not appear on rows the receiving person added.

## Operational row

72dp fixed (`size.control.listRow`), a 34dp index column in `label.ritual`,
a 24–26dp mark via `DsSvg`, then title in `body.primary` 17px above metadata in
`body.support` 12/17, separated by 4dp.

A 1dp `border.onRitual.hairline` closes the bottom, except on the last row of a
group where the following module's own top border closes it.

Two lines inside 72dp is tight: the metadata needs `maxLines: 1` and
`TextOverflow.ellipsis`.

## Partner response

Bounded top and bottom by 1dp hairlines rather than a card. Inside: the
`state.acknowledged` mark at 26dp in `relationship` tone, then
`NAME RESPONDED · TIME` in `label.ritual`, then the quotation in
`display.partner` 28px in `relationship.acknowledgement`, indented 40dp.

**Only ever renders human-authored, human-sent text.** The system does not write
here, and there is no placeholder or encouragement when a response has not
arrived — the absence is the truth. The backend rejects an empty
acknowledgement; the UI must not invent one.

Terracotta appears here because 28px clears the 24sp floor. Small partner labels
stay Stone with a Terracotta mark beside them.

## Presence indicator

A 22dp `mark.presence` in `relationship` tone plus a name label in
`body.secondary` `text.onRitual.secondary`, right-aligned in the header.

Presence, not status. It says a person is there; it never speaks for them and
never implies they are waiting or watching. The label must be `Flexible` with
ellipsis — a long display name otherwise overflows the header.

## Section label

`label.ritual` 12/16 with 2.4 tracking in `text.onRitual.muted`, caps.

The tracking makes this string far wider than it reads. Wrap it in `Flexible`
whenever it shares a row; it overflowed the viewport twice during `SCR-01`.

## Disclosure row

72dp, label left in `label.ritual`, action right: a word in `body.primary` plus
a 28dp circular count chip in `surface.ritual.raised`.

Carries a count so the person knows what is hidden. Never a badge, never a
notification dot, never a nag — Later items are less urgent, not neglected.

## Bottom navigation

80dp before the safe-area inset, four tabs, 1dp hairline on top. Each tab is a
24dp `DsSvg` above a `nav.label`, active in `primary` tone and
`text.onRitual.primary`, inactive in `muted` tone and `text.onRitual.muted`.

Exactly four: Today · Dynamic · Explore · Us. Attention is not a tab — it is
reached from Today when something waits on this person.

## Recovery states

Every screen owes loading, empty, error/retry, offline and authorization-loss.
`screen.md` carries the specific rules per surface, but three hold everywhere:

- **Loading** resolves authorization before revealing anything. Never show
  stale partner content while confirming.
- **Offline** shows only the last confirmed list, labelled with its timestamp,
  with every mutation disabled. It must not imply the data is current.
- **Authorization loss** removes all partner and Dynamic content and offers a
  safe recovery path.

Empty states state the fact without inventing urgency. "Nothing is expected of
you today." is complete; it does not need a suggestion attached.
