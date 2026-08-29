# What implementation is waiting on

Written by Claude Code after reading the repository on 2026-08-29; reconciled with SVG Freeze v1 and Token Freeze B-2 v1 on 2026-08-29 UTC.
This file states only what blocks writing Flutter code against this design system.
It does not propose design decisions — those belong to the design owner.

## Status summary

| Area | State | Blocks build? |
|---|---|---|
| Fonts | Cormorant Garamond + Inter committed with OFL licenses | No — usable now |
| Type scale | 8 roles frozen in `design/system/typography.md` | No — usable now |
| Spacing | 4dp scale frozen in `design/tokens/design-tokens.json` | No — usable now |
| Brand/support primitives | 10 colors frozen in `design/system/colors.md` | No — usable now |
| Semantic color tokens | Frozen in `TOKEN-FREEZE-B2-V1` with Flutter/Web bindings | No — B-2 resolved |
| SVG masters | 33 of 33 native masters exist; all `approved` in SVG Freeze v1 | No — B-1 resolved |
| Today prioritized-list state | Not designed | **Yes, for SCR-01** |
| Textures | Directory empty | Partially |
| Radius / control heights | Frozen in `TOKEN-FREEZE-B2-V1` | No — usable now |

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

## B-2 · Resolved by Token Freeze B-2 v1

The semantic layer is frozen and directly consumable:

- Ritual Canvas is `#080B07` through `color.semantic.canvas.ritual`.
- Ritual raised/action surfaces resolve to Dark Moss and Deep Olive; the Living
  foundation resolves to Bone and Stone.
- Text, border, action, relationship, state, icon and decorative semantic groups
  are present in `design/tokens/design-tokens.json`.
- Radius, 1/1.5/2dp borders and 48/56/64dp control contracts are frozen.
- Flutter and Web bindings are generated under `design/tokens/generated/`.
- Six required normal-text contrast pairs pass WCAG AA. Terracotta's 4.02:1
  pair is explicitly restricted to large text, icons, marks and lines.
- QA evidence and a reproducible validator are stored under `design/qa/`.

Canonical manifest: `manifests/token-freeze.b2.v1.json`. Canonical rules:
`design/tokens/B2-FREEZE.md`. B-2 no longer blocks implementation setup, but
screen-level B-3/state/product/platform gates remain unchanged.

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

## B-4 · Remaining texture gap

- **Textures**: `design/assets/textures/` is empty. The previews show a fine
  grain over the dark ground. If that is intentional, the implementation needs
  to know whether it is a tiling asset or a shader, plus opacity and blend mode.
  If it is only PNG compression, say so and I will render flat.

B-2 resolves the earlier geometry and light-mode questions: 48dp is the minimum
target, 56dp is the standard button, 64dp is the ritual CTA, and Core Beta uses
semantic Ritual/Living contexts rather than a user-toggleable two-theme system.

---

## What is being built in the meantime

Work that does not depend on the above, and will not be thrown away:

1. Bundling Cormorant Garamond (400/500/600) and Inter (400/500/600/700).
2. Rewriting the Flutter type scale to the 8 roles in `typography.md`.
3. Adding `flutter_svg` so approved masters can be consumed as files.
4. Wiring the generated B-2 Flutter binding into the token layer without
   duplicating raw values.

No screen will be marked done against a `blocked_alignment_required` package.
