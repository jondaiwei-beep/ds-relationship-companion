# SCR-14 rev-1 — review and decisions

Reviewed 2026-08-30 per `ds-design-generate`. First Phase 2 screen; nothing
existed for it but one reference image.

## Verification performed

- **All 22 frozen values cited resolve** in `design/tokens/design-tokens.json`.
- **Only `state.completed` is used** — the single mark this screen's asset
  contract registers. Nothing was borrowed from another screen, and the document
  says explicitly that a review mark would require an asset-contract change
  first.
- `color.semantic.state.needsReview` resolves to **Stone**, not Terracotta or
  an error colour. The freeze already encodes the product principle: past due is
  not an alarm.

## Decision — Needs review, Direction A

This is the state with no precedent anywhere in the product, and the one where
the wrong tone converts a relationship companion into a compliance tracker.
`REQ-REVIEW-001` is one sentence: *"Past-due active work becomes Needs Review.
The software does not assign punishment or consequence."*

Direction A puts the fact and its meaning together, before the expectation:
**"This is past due. It only needs another look."** That sentence does the whole
job — it states the truth and removes the accusation in the same breath, with
no surface, icon or accent border to give it weight it should not have.

Direction B's raised block was rejected for the reason given and one more: a
tonal container is how a UI says *this is a problem*. Past due is not a problem,
it is a fact about a clock.

The withhold list is the strongest part of the document — punishment,
consequence, "missed", failure, urgency, countdown, streak impact, red alert.
Those are the words a compliance tracker would reach for, and naming them is
what keeps them out.

## The reference image was wrong in three places, all corrected

Recorded because the image is the only prior art and someone will look at it
again:

1. **"Add photo" is gone.** The contract says *remove Proof*. Photographic
   evidence of compliance is a surveillance pattern; this product does not ask
   anyone to prove their obedience.
2. **Adjustment now sits beside completion.** The reference offered only "Mark
   complete", which makes every other path a deviation. Red line #3.
3. **"Morgan will be notified" is gone.** Completion is never acknowledgement
   (`REQ-COMPLETE-001`); framing the end of the action as a notification implies
   the loop closes when the system sends something. It closes when a human
   answers.

Kept from the reference: the editorial vertical rule, the DUE eyebrow, the
Cormorant statement of the expectation, "Set by Morgan" as attribution, and the
INTENTION / COMPLETION / BOUNDARY structure — which is good and appears nowhere
else in the product.

## Blocker this design surfaces

`adjustment-open` renders `withdraw`, because the server advertises it in
`allowedActions`. **There is still no endpoint.** Designing the affordance does
not create one, and a client that trusts `allowedActions` — as Today now does —
will render a button that 404s. Already recorded in
`progress/session-review-followups.md`; this design makes it visible rather than
resolving it.

## Open for the owner

1. **Gate.** Not set here. `blocked_alignment_required` stands.
2. **`withdraw`:** implement it, or stop advertising it.

## Not rendered yet

`DESIGN.md` is a specification. The deterministic renderer and the eight state
PNGs are the next step.
