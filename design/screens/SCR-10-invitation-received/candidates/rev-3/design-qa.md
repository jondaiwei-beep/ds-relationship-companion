# SCR-10 rev-3 — review and decisions

Reviewed 2026-08-30 against `ds-design-generate`. Scope: the five states the
contract lists as `blocked` — `revoked`, `loading`, `error`, `offline`,
`authorization-loss`.

## Verification performed

- **Every frozen value cited resolves.** All 17 tokens named in `DESIGN.md`
  (`color.semantic.*`, `space.*`, `size.*`, `radius.*`, `borderWidth.*`) exist
  in `design/tokens/design-tokens.json`. Nothing was invented.
- **`title.page` is a real type role** (`design/system/type-in-practice.md`).
- **`state.invite-revoked` is approved and frozen** but registered
  `used_by: ["SCR-09"]` and absent from SCR-10's asset contract — as the
  document says.

## Decisions

**Revoked → Direction A** (align with the approved Expired composition).

Two reasons beyond the one given. Revoked and Expired are the same fact to the
person holding the link — *this cannot be used* — and only differ in a cause
they must not be told. Giving them different compositions would make the
difference visible and invite exactly the speculation the red line forbids.
Direction A also needs no asset-contract change, so it can be built now, and
"unavailable" covers an access-relation change while "closed" implies an actor.

**Authorization loss → Direction A** (account checkpoint).

Direction B's `Continue to sign in` is untrue when a valid but ineligible
account is already present, and two account actions read as a choice the person
cannot meaningfully make.

**Cormorant — Codex read the rule correctly and drew the wrong conclusion, and
the rule was at fault.** It cited *"Cormorant appears only where a person's
words appear"* and concluded these system-authored headings must be
`title.page`. Following that consistently would also have condemned four
*approved* entrance headlines ("A private space,", "A link is on its way.",
"Return to your space.", "Begin privately.") — none of which are anyone's
words.

That is the tell that the rule, not the artwork, was wrong. The two Cormorant
roles are distinguished by different things: `display.partner` is an
**authorship** test (only words a person wrote and sent — red line #1 in a
typeface), while `display.ritual` is a **compositional** one ("one thing,
centred, alone on the screen"). SCR-01 settles it: the expectation headline
takes `display.ritual` and is written by the creator, not the reader.

`type-in-practice.md` has been corrected to say this, with the practical test:
*is the line alone at the centre, and is it the one thing the screen is about?*

Applied to these five states:

| State | Headline | Role | Why |
|---|---|---|---|
| `revoked` | `This invitation is no longer available.` | `display.ritual` | Alone at the centre; the whole point of the screen |
| `loading` | — | — | No headline; a resolving surface states nothing yet |
| `error` | `We couldn't check this invitation.` | `display.ritual` | Same composition as revoked and expired |
| `offline` | `You're offline.` | `display.ritual` | Same |
| `authorization-loss` | `Confirm your account to continue.` | `display.ritual` | Same |

This keeps rev-3 consistent with the approved rev-2 recovery states rather than
splitting the flow across two type treatments — which was the real risk.

**`mark.partner-bond` withheld while invite truth is unresolved — accepted.**
Drawing the bond mark before the server confirms the invite would be the app
implying a relationship exists. That is the right reading of `REQ-INVITE-001`.

## Open for the owner

1. **Gate.** Not set here. `blocked_alignment_required` stands until the owner
   opens it.

The type question that appeared to need a decision did not: the frozen roles
already answered it once stated precisely. Recorded in `type-in-practice.md`.

## Not done yet

`DESIGN.md` is a specification, not a render. The deterministic renderer and the
five state PNGs are the next step, following the `ds-design-generate` step 4
rules (`fonts.cjs` first, colours through `design-tokens.json`, marks through
the SVG registry, every named state rendered).
