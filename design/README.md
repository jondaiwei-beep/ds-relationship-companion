# Design source of truth

The design source is composed of approved raster references, executable tokens, bundled fonts, master SVG assets, component contracts, screen specifications, and visual QA evidence. There is no Figma dependency.

## Implementation entry point

`design/screens/` is the developer-facing entry point. Every `SCR-*` folder contains:

- `screen.md` — product links, UI contract, states, assets, acceptance and build gate
- `preview.webp` — co-located visual reference for that exact revision

The central `reference/webp/v1/` tree remains the preserved visual inventory. A co-located preview is the handoff copy, not a second independent source.

## Status of current references

The 00–30 generated screens under `reference/raster/v1/` are retained as the current visual inventory. They are not all approved for implementation. The legacy manifest records known alignment gaps and build gates.

For repository and AI-tool access, full-resolution 853 × 1844 WebP references are mirrored under `reference/webp/v1/` with identical folders and filenames. These high-quality previews are the current GitHub-readable visual source. Original PNG files remain the lossless archive and will be added when a direct binary Git workflow is attached.

## Visual identity

V5 Warm Authority combines a near-black ritual canvas with Bone/Stone typography, Deep Olive and Dark Moss structure, and disciplined Terracotta warmth. It must feel private, editorial, human, and quietly authoritative—never generic dark UI, fetish theatre, or decorative AI excess.

The calibrated Ritual Canvas is `#080B07` through `color.semantic.canvas.ritual`. Semantic color, surface, state, radius and control geometry are frozen in `design/tokens/B2-FREEZE.md`; implementation must consume the generated platform bindings rather than copying these values into screens.

## Reference coordinate system

Generated raster files are 853 × 1844 pixels. Implement them against a normalized 390 × 844 logical-pixel mobile frame. Raster coordinates must not be copied as absolute application coordinates.
