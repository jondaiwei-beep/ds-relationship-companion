---
name: ds-design-lookup
description: Look up design tokens, type roles and registered assets for the D/s app (design/tokens, manifests/assets.json). Product behavior questions go to product/ and research/, not here.
---

# Finding things in the design system

The repository answers most design questions precisely. This is where to look,
so the answer is read rather than guessed.

Everything is machine-readable. Prefer querying the manifests over reading
prose, and never conclude something is missing without checking the registry.

## What does a token resolve to

The generated bindings are authoritative:
`app/lib/src/design_system/generated/ds_design_tokens.g.dart`

The reasoning lives in `design/tokens/B2-FREEZE.md` — read it before using a
state or relationship colour, because several carry rules the value alone does
not express. `#080B07` is the ritual canvas; pure black and Material dark
defaults are explicitly wrong.

## Which type role should this text take

`design/system/type-in-practice.md` maps content kinds to roles, records the two
gaps the frozen eight do not cover, and states the rules that are not
negotiable — the serif belongs to human words, Terracotta text has a size floor.

## Rules that override convenience

- **Never trace or redraw an asset from a raster preview.** If a master does not
  exist, the screen cannot draw it. This is stated in `SVG-FREEZE.md` and it
  holds without exception — a traced mark is a forged asset. Adding a *new*
  master is a design task with its own freeze process, not something to
  improvise mid-screen.
- **Product behaviour comes from `product/`, never from a design image.** Missing
  states, copy or permission rules: check `product/02-surfaces.md` and
  `03-domain.md`; if still missing, decide, record it in `05-decisions.md` as
  「推断」, and keep going.
