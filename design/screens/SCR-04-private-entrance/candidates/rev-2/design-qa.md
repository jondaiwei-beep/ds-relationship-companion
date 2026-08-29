# Entrance candidate rev-2 · acceptance criteria

What must be true for SCR-04 / SCR-05 / SCR-06 to be considered built. The
same document served SCR-01, and its absence is one reason the other screens
stalled: a candidate without acceptance criteria cannot be checked, only
admired.

## Measured

| Check | Result |
|---|---|
| Every state fits 390 × 844 | **pass** — 18/18, last content ≤ 830dp |
| Marks at a frozen size | **pass** — `mark.authority` 64/40/32dp, `state.locked` 20dp |
| Marks at a licensed tone | **pass** — enforced by the renderer, which throws otherwise |
| Colour resolves through B-2 | **pass** — no literal in the renderer except via `token()` |
| Display face is Cormorant | **pass** — verified at render time, see below |

## The typeface check is not decorative

The renderer refuses to run unless Cormorant Garamond actually resolves.

This exists because it silently stopped resolving. The renderers wrote a
fontconfig file to `os.tmpdir()` and set `FONTCONFIG_FILE`; sharp bundles its
own fontconfig, which ignores that variable on macOS. Every family fell back
to a system sans and nothing failed — `render-today-b3.cjs` no longer
reproduced its own committed output, and the difference is invisible unless
you look at the letterforms.

`design/qa/scripts/fonts.cjs` installs the bundled faces where fontconfig
looks and then renders one glyph twice to prove the display face took. A
render in the wrong typeface looks fine and is wrong.

## Behaviour the implementation must hold

These are the ones a correct-looking screen can still get wrong.

1. **The signed-out surface never names the product category.** Not in the
   wordmark, headline, subtitle or footer. `For adults 18+` is required and
   stays, placed after the primary actions and kept quiet — with the category
   words gone it is the strongest remaining signal.
2. **Authorization loss says nothing about the account.** "Please sign in to
   continue." — never which account, partner, role, invitation or content
   caused the redirect.
3. **The entrance never mentions a previous session.** A borrowed phone must
   not learn that its owner has an account here.
4. **A wrong password and an unknown address are indistinguishable.**
   Enforced in `AuthActions`; the screen must not add anything that
   distinguishes them.
5. **The 18+ button stays visually enabled.** Pressing it unchecked explains
   the requirement and focuses the checkbox. A disabled control with no
   explanation is unreachable for a keyboard or screen-reader user.
6. **A request in flight cannot be sent twice.** `DsPrimaryButton(busy:)`.
7. **`Use an email sign-in link` is a real route**, not a stub. There is no
   password reset in this product.

## Not covered by these renders

- **Terms and Privacy destinations.** The links are drawn; the pages they open
  do not exist. They must open without a session.
- **Web adaptation.** These are 390 × 844. Browser back, refresh and direct
  URL entry are contract requirements and are unrendered.
- **The reveal control** is the word `Show`. SVG Freeze v1 has no eye asset
  and tracing from a raster is forbidden. See
  `design/assets/svg/REQUESTED.md`.
- **Focus order and live announcement** for validation errors.

## Build rule

The gate in `manifests/screen-index.json` is unchanged and stays
`blocked_alignment_required` until the product and design owner opens it.
