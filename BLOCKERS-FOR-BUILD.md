# What implementation is waiting on

Written by Claude Code after reading the repository on 2026-08-29; reconciled with SVG Freeze v1 on 2026-08-28 UTC.
This file states only what blocks writing Flutter code against this design system.
It does not propose design decisions — those belong to the design owner.

## Status summary

| Area | State | Blocks build? |
|---|---|---|
| Fonts | Cormorant Garamond + Inter committed with OFL licenses | No — usable now |
| Type scale | 8 roles frozen in `design/system/typography.md` | No — usable now |
| Spacing | 4dp scale frozen in `design/tokens/design-tokens.json` | No — usable now |
| Brand primitives | 6 colors frozen in `design/system/colors.md` | No — but see B-2 |
| Semantic color tokens | Not defined | **Yes** |
| SVG masters | 33 of 33 native masters exist; all `approved` in SVG Freeze v1 | No — B-1 resolved |
| Today prioritized-list state | Not designed | **Yes, for SCR-01** |
| Textures | Directory empty | Partially |
| Radius / control heights | Not specified | Partially |

---

## B-1 · Resolved by SVG Freeze v1

The original 31 requested masters now exist, plus two decorative motifs that
were required by the approved compositions but absent from the original list:
`motif.botanical.invite-branch` and `motif.botanical.note-sprig`.

- 33/33 SVG source files exist under `design/assets/svg/`.
- 33/33 entries are `approved` in `manifests/assets.json`.
- Stable `viewBox`, stroke, rendered sizes and semantic-color allowances are
  frozen in `manifests/svg-freeze.v1.json`.
- Source policy and Flutter/Web usage are frozen in
  `design/assets/svg/SVG-FREEZE.md`.
- All masters passed real parse/render validation with no embedded text,
  raster, filters, external references or hard-coded colors.
- QA evidence is stored in `design/qa/reference/svg-freeze-v1-board.png`,
  `svg-freeze-v1-botanical-board.png` and `svg-freeze-v1-validation.json`.

Implementation must continue to reference semantic Asset IDs and must not copy
path data into screens. B-1 no longer blocks the vertical slice; B-2, B-3 and
the independent screen build gates remain unchanged.

---

## B-2 · Semantic color tokens are not frozen

`design/system/colors.md` states:

> The near-black ritual canvas and secondary semantic colors remain calibration
> candidates until extracted and approved against the selected reference.

and also:

> Application code must consume semantic tokens, not these primitive values directly.

Both rules are right, but together they currently block all UI work: the
semantic layer that code is required to consume does not exist yet, and the
dark canvas that every approved screen is built on has no committed value.

`design/tokens/design-tokens.json` is `0.1.0-pre-freeze` and carries only the 6
primitives plus spacing — no semantic color group, no typography, no radius.

**Needed, as semantic tokens in `design-tokens.json`:**

- `canvas.ritual` — the near-black ground used by SCR-01/04/05 (reads as a
  green-biased near-black in the previews; exact value required)
- `canvas.raised` / `surface.*` — elevated surfaces
- `text.primary` / `text.secondary` / `text.muted`
- `border.hairline` / `border.strong`
- `action.primary.bg` / `action.primary.fg` — the deep-olive button
- `response.partner` — the terracotta used for human acknowledgement text
- `state.*` — needs-review and other status colors

The Terracotta rule in `colors.md` (relational emphasis, never a generic
warning) is understood and will be enforced in the token names.

---

## B-3 · Today has no prioritized-list state

`design/screens/SCR-01-today/screen.md` already records this under **Known
alignment work**: *add receiving-side prioritized list state / preserve this as
ritual-focus state*. `progress/status.md` lists it as next-alignment item 3.

Flagging it here only to record the implementation consequence: the approved
`preview.webp` is a single-item ritual-focus screen. A real day carries 8–10
items, and the 34/42 Cormorant headline in that composition has no defined
behavior for the second through tenth item. Building the dense list from
inference would invent hierarchy the design has not approved.

Also undefined for SCR-01 and every other screen: all seven rows of the state
matrix (default / loading / empty / error / offline / authorization loss /
role variant) are `TBD — blocked`.

---

## B-4 · Smaller gaps

- **Radius and control heights** are not in `design/system/spacing.md`.
  The pre-migration `CLAUDE.md` recorded card radius 10 and primary CTA 48dp —
  confirm whether those still hold under this system.
- **Textures**: `design/assets/textures/` is empty. The previews show a fine
  grain over the dark ground. If that is intentional, the implementation needs
  to know whether it is a tiling asset or a shader, plus opacity and blend mode.
  If it is only PNG compression, say so and I will render flat.
- **Light mode**: the pre-migration principle was *Light Life, Dark Structure* —
  a light living layer with dark authority/response moments. Every approved
  preview is dark. Confirm whether light surfaces still exist in the system, as
  this determines whether the token layer needs two themes or one.

---

## What is being built in the meantime

Work that does not depend on the above, and will not be thrown away:

1. Bundling Cormorant Garamond (400/500/600) and Inter (400/500/600/700).
2. Rewriting the Flutter type scale to the 8 roles in `typography.md`.
3. Adding `flutter_svg` so approved masters can be consumed as files.
4. Building the token layer's shape, with color values left as named holes to
   be filled the moment B-2 is frozen.

No screen will be marked done against a `blocked_alignment_required` package.
