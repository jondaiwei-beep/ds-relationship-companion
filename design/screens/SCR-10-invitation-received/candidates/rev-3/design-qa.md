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

**Cormorant is not used in these states — accepted, and it exposes a real
inconsistency.** `type-in-practice.md` is unambiguous: *"Cormorant appears only
where a person's words appear."* These headings are system-authored, so they
take `title.page`. This means **the approved rev-2 recovery artwork violates
the frozen type contract** by setting serif system headlines. That is a
pre-existing defect in approved work, not a new one, and is recorded below
rather than silently copied forward.

**`mark.partner-bond` withheld while invite truth is unresolved — accepted.**
Drawing the bond mark before the server confirms the invite would be the app
implying a relationship exists. That is the right reading of `REQ-INVITE-001`.

## Open for the owner

1. **Type-contract inconsistency in approved rev-2.** Either rev-2's recovery
   headlines are corrected to `title.page`, or `type-in-practice.md` gains an
   explicit exception for recovery headings. Until then, rev-2 and rev-3
   disagree with each other on screen. **This one needs deciding before build**,
   because the two revisions will sit side by side in the same flow.
2. **Gate.** Not set here. `blocked_alignment_required` stands until the owner
   opens it.

## Not done yet

`DESIGN.md` is a specification, not a render. The deterministic renderer and the
five state PNGs are the next step, following the `ds-design-generate` step 4
rules (`fonts.cjs` first, colours through `design-tokens.json`, marks through
the SVG registry, every named state rendered).
