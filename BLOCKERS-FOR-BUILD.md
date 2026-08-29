# What implementation is waiting on

Written by Claude Code after reading the repository on 2026-08-29; reconciled with SVG Freeze v1, Token Freeze B-2 v1 and the Today B-3 Revision 2 candidate on 2026-08-29 UTC.
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
| Today prioritized-list/state family | Rev-2 candidate designed and QA-rendered | **Approval still blocks SCR-01** |
| Textures | Deterministic B-4 grain frozen and wired into Flutter | No — usable now |
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

## B-3 · Visual production complete; owner approval pending

Revision 2 now defines Today without discarding the approved ritual-focus visual:

- default Today exposes 1–3 priorities, with full agency actions on the first;
- `Later / Optional` expands inline to a server-ordered total of 8–10 items;
- partner presence, recent human response, ritual and check-in are integrated;
- loading, empty, error/retry, offline/read-only, authorization-loss,
  role-neutral and solo/private states have lossless source plus 390 × 844 preview;
- server current truth, cache, privacy and invariant rights are explicit in the
  machine-readable contract.

Canonical files: `design/screens/SCR-01-today/candidates/rev-2/` and
`design/qa/reference/today-b3-state-family-board.png`. Visual QA passed for
candidate review. SCR-01 remains `blocked_alignment_required` until the
product/design owner approves Revision 2 plus copy and Web/platform behavior.

---

## B-4 · Resolved by Texture Freeze B-4 v1

The dark references intentionally use fine film grain; it is not PNG compression.
The implementation contract is deterministic and directly consumable:

- canonical 128 × 128 repeating tile at `design/assets/textures/ritual-grain-128.png`;
- seeded generator and SHA-256 validation evidence committed with the asset;
- `softLight` blend at frozen `opacity.grain = 0.035` on Ritual Canvas only;
- runtime randomness and one-off screen textures are prohibited;
- Flutter consumption is implemented by `DsRitualSurface` in the foundation package.

Canonical manifest: `manifests/texture-freeze.b4.v1.json`. B-4 no longer blocks
visual implementation; independent screen product/state/platform gates remain.

---

## Foundation available to implementation

The portable package under `app/` now provides work that does not depend on a
screen gate and will not be thrown away:

1. Bundled Cormorant Garamond (400/500/600) and Inter (400/500/600/700).
2. The frozen 8-role Flutter type scale from `typography.md`.
3. `flutter_svg` plus a generated semantic Asset ID registry for all 33 masters.
4. Generated B-2 Flutter tokens, spacing, Ritual/Living themes and B-4 surface.
5. Reproducible asset sync and validation scripts under `tool/`.

No screen will be marked done against a `blocked_alignment_required` package.
