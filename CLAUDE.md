# Claude Code implementation contract

## Mandatory reading

Read `README.md`, `product/README.md`, `design/README.md`, the active manifests, and the relevant screen specification before changing UI code.

## Build gates

- Only implement screens marked `ready_for_build` in the active screen manifest.
- Raster images are visual references, not behavioral specifications.
- Missing states, copy, permission rules, or responsive behavior are blockers.
- Never silently replace missing fonts or SVG assets with local system alternatives.

## Visual implementation

- Reference mobile viewport: 390 × 844 logical pixels.
- Use `design/tokens/design-tokens.json`; do not scatter raw Hex values or arbitrary spacing.
- Bundle and load the fonts in `design/assets/fonts/`.
- Use registered SVG masters; do not trace or redraw icons from PNG files during implementation.
- Preserve hierarchy, whitespace, typography, partner presence, ritual marks, and restrained texture.
- Minimum interaction target: 48 × 48 logical pixels.

## Verification

For every screen, render the reference viewport, store the result under `design/qa/implementation/`, compare it with the approved reference, and record remaining differences. Geometry should normally remain within 1–2 logical pixels. Texture/grain regions may use a controlled comparison mask; typography, layout, copy, SVG geometry, and state visibility may not.

