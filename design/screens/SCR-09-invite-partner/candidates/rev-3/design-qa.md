# SCR-09 rev-3 — review and decisions

Reviewed 2026-08-30 per `ds-design-generate`. Scope: the four states the
contract lists as `blocked` — `loading`, `share-error`, `offline`,
`authorization-loss`.

## Verification performed

- **All 21 frozen values cited resolve** in `design/tokens/design-tokens.json`
  (`color.semantic.*`, `size.control.*`, `size.layout.*`, `space.*`, `radius.*`,
  `borderWidth.*`, `opacity.*`).
- **Every mark used is registered to SCR-09.** `icon.private-space`,
  `state.locked` and `state.auth-restored` appear only in a sentence declining
  them, for the correct reason: none is in this screen's asset contract.

## Decisions

**Loading → Direction A** (state-silent shell).

The contract asks for something that sounds contradictory — *preserve lifecycle
geometry without revealing stale state* — and Direction A resolves it exactly:
**show all four nodes, fill none**. The geometry holds its place so nothing
jumps when truth arrives, while no node claims to be current. Withholding the
bond mark rather than fading it follows from the same reasoning: the mark
carries relationship state, so a faded one still asserts a state.

Direction B's progress ring was rejected for the reason given, and one more:
this screen already has a Terracotta point at the centre of the bond mark in
Pending. A second circular focal element in that slot would read as the mark
transforming, not as loading.

**Share error → Direction A** (recovery at the failed action).

This state's rule is the sharpest on the screen — *never create duplicate active
links silently* — and Direction A defuses it before the person can act: the live
code stays on screen and the copy says **"Your invitation is still active"** and
**"this same invitation"**. Direction B's notice card is weaker precisely
because it separates the explanation from the control it qualifies, so a person
scanning to the button may act without reading it.

Keeping `Revoke invitation` in place is right. A share failing is no reason to
remove the owner's deliberate action.

**Offline — accepted as written, no alternative needed.**

Two details worth naming because they are decisions, not styling:

- **`Revoke unavailable offline`, never queued.** A revoke that appears to
  succeed offline and then silently does not is the worst possible outcome here
  — the person believes a link is dead while it is live. Disabled with the
  reason stated beats hidden.
- **The cached lifecycle node is outlined, not filled**, and paired with
  `Last confirmed: Pending`. This is the one place the screen shows a lifecycle
  position it cannot vouch for, and the outline plus the words carry that
  together rather than colour alone.

**Authorization loss — accepted.** The only state that behaves like its SCR-10
sibling, and correctly so: withholding an authenticated owner's own content
would be losing their work, but here we do not yet know it *is* their work.
Resolving server truth before restoring the screen, rather than restoring the
cached lifecycle, is the right sequencing.

## Divergence from SCR-10, deliberately

SCR-10's recovery states withhold almost everything because the viewer may not
be entitled to see anything. SCR-09's viewer is authenticated, inside their own
Dynamic, and owns the invitation — so `offline` keeps the code visible and
`share-error` keeps the whole Pending composition. Only `authorization-loss`
converges with the receiving side. That asymmetry is the design, not an
inconsistency.

## Open for the owner

1. **Gate.** Not set here. `blocked_alignment_required` stands.

## Rendered

`render-invite-recovery.cjs` produces all four states deterministically.
Verified byte-identical across a rerun.
