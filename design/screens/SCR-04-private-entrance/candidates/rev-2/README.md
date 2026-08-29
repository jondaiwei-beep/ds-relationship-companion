# SCR-04 — Private Entrance · Revision 2

Status: `candidate_for_approval`.

This package resolves what the build gate is actually waiting on: the state
matrix in `screen.md` was entirely `TBD`, and the copy was never product
approved. Both are now specified and rendered.

## Files

- `source.png` / `preview.webp`: default state at 390 × 844.
- `states/*/`: the rest of the family; see the table in
  `product/decisions/entrance-state-family.md`.
- Rendered by
  `design/screens/SCR-04-private-entrance/candidates/rev-2/render-entrance.cjs`,
  which renders all three entrance screens together. They are one composition
  with three arrangements, and rendering them apart is how the three drift.

## What changed from revision 1

Copy: `product/decisions/d8-entrance-copy.md`. The signed-out surface no
longer names the product category. The application identity was already
deliberately neutral — `app.companion.two`, launcher label `Companion` — and
the first screen contradicted it, which matters because shared and borrowed
devices are the ordinary case for this product.

Three corrections against the server, not preferences:

- `Forgot password?` had no endpoint. There is no password reset. It is now
  `Use an email sign-in link`, which exists and works.
- `At least 8 characters` contradicted the enforced minimum of 10.
- Terms, Privacy, 18+ and private-by-default were absent from all three
  screens; `REQ-TRUST-001` requires them on entry surfaces.

## Build rule

Claude Code may inspect this candidate, but must not implement SCR-04 until the
product and design owner approves it and the build gate becomes
`ready_for_build`. The gate in `manifests/screen-index.json` is unchanged.
