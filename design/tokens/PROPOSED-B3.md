# Proposed token additions · B-3 candidates

Two values that `SCR-01` needed and the B-2 freeze does not carry. Recorded as
proposals, not adopted — freezing a token is a design-owner decision.

Both are currently inline overrides in
`client/lib/features/today/presentation/today_screen.dart`, each with the reason
at the call site.

## `typography.display.expectation` — Cormorant 28 / 31

`display.ritual` at 34/42 is correct for the ritual-focus composition, where the
headline is the only thing on the screen. In a prioritised list the same role
sits above a button, three actions and two more rows, and the approved `SCR-01`
design sets it at 28px on a 31px line box — measured from the source at 3×: two
lines spanning 100px with baselines 31px apart.

These are different compositions, not a conflict. The ritual size stays.

**Reuse:** 5 screen contracts describe an expectation-style headline in a list
context.

## `typography.body.support` — Inter 400 · 12 / 17

`body.secondary` at 14px reads too heavy beside a 28px serif headline. Item
metadata and the quiet adjustment actions want one step below it. The design
owner identified this by eye on the render before it was measured.

12px is the floor for this system. `label.ritual` already occupies 12px, but
with 2.4 tracking and caps for a different purpose.

**Reuse:** 10 screen contracts carry status assets, which travel with a metadata
line.

## If adopted

1. Add both to `design/tokens/design-tokens.json`.
2. `npm run foundation:check` regenerates the Flutter and Web bindings.
3. Replace the inline overrides in `today_screen.dart` with the generated roles.
4. Extend the frozen-role test in
   `app/test/design_system_foundation_test.dart` from eight roles to ten.
5. Update `design/system/type-in-practice.md` to move them out of "gaps".
