# Design source of truth

The design source is composed of approved raster references, executable tokens, bundled fonts, master SVG assets, component contracts, screen specifications, and visual QA evidence. There is no Figma dependency.

## Status of current references

The 00–30 generated screens under `reference/raster/v1/` are retained as the current visual inventory. They are not all approved for implementation. The legacy manifest records known alignment gaps and build gates.

## Visual identity

V5 Warm Authority combines a near-black ritual canvas with Bone/Stone typography, Deep Olive and Dark Moss structure, and disciplined Terracotta warmth. It must feel private, editorial, human, and quietly authoritative—never generic dark UI, fetish theatre, or decorative AI excess.

## Reference coordinate system

Generated raster files are 853 × 1844 pixels. Implement them against a normalized 390 × 844 logical-pixel mobile frame. Raster coordinates must not be copied as absolute application coordinates.

