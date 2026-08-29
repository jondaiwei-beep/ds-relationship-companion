# D/s Relationship Companion

Private product, design, and implementation source of truth for the Android app and Web Companion.

## Current direction

- Product: a consent-aware D/s relationship companion organized around six Core Daily Loops.
- Visual system: **V5 · Warm Authority**, evolved from Quiet Authority.
- Design principles: authority, human warmth, ritual identity, partner presence, emblem system, restrained botanical/editorial detail.
- Platforms: Flutter Android first; Flutter Web Companion for invitation and iOS access.
- Figma: intentionally removed. This repository is the canonical handoff source.

## Reading order

1. `CLAUDE.md` or `AGENTS.md`
2. `manifests/screen-index.json`
3. Target `design/screens/SCR-*/screen.md`
4. Product references linked from that screen contract
5. Target `preview.webp`
6. `manifests/svg-freeze.v1.json` and `design/assets/svg/SVG-FREEZE.md`
7. `manifests/assets.json` and the linked SVG masters
8. `manifests/token-freeze.b2.v1.json`, `design/tokens/B2-FREEZE.md` and generated bindings
9. `design/tokens/design-tokens.json` and `design/system/`
10. `progress/status.md`

No implementation may infer missing behavior from a raster image. A screen must be marked `ready_for_build` in the active manifest before development begins.

## Traceability rule

Every buildable UI must form one unbroken chain:

`Product requirement → Screen contract → Visual reference → Asset ID/SVG → Component/code → QA evidence`

If any link is missing, the screen remains blocked.
