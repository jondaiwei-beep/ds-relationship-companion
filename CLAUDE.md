# Claude Code implementation contract

## Deterministic reading sequence

For any UI task, follow this exact sequence:

1. Read `manifests/screen-index.json` and locate the requested Screen ID.
2. Open the linked `design/screens/SCR-*/screen.md` contract.
3. Read every linked product requirement and flow. An empty or `TBD` requirement reference is a blocker.
4. View the co-located `preview.webp`; use it for hierarchy and visual comparison only.
5. Resolve every asset ID through `manifests/assets.json`, then load its registered SVG master.
6. Read global tokens and any linked component contracts.
7. Implement only when the screen gate is `ready_for_build` and every required asset is available.
8. Render and record QA evidence at the paths required by the screen contract.

Do not search the repository for a visually similar page and assume it is the target. Screen IDs and manifest links are authoritative.

## Build gates

- Only implement screens marked `ready_for_build` in the active screen manifest.
- Raster images are visual references, not behavioral specifications.
- Missing states, copy, permission rules, or responsive behavior are blockers.
- Never silently replace missing fonts or SVG assets with local system alternatives.
- Never infer product behavior, state transitions, permissions, or acceptance criteria from `preview.webp`.

## Visual implementation

- Reference mobile viewport: 390 × 844 logical pixels.
- Use `design/tokens/design-tokens.json`; do not scatter raw Hex values or arbitrary spacing.
- Bundle and load the fonts in `design/assets/fonts/`.
- Use registered SVG masters; do not trace or redraw icons from PNG files during implementation.
- Preserve hierarchy, whitespace, typography, partner presence, ritual marks, and restrained texture.
- Minimum interaction target: 48 × 48 logical pixels.

## Verification

For every screen, render the reference viewport, store the result under `design/qa/implementation/`, compare it with the approved reference, and record remaining differences. Geometry should normally remain within 1–2 logical pixels. Texture/grain regions may use a controlled comparison mask; typography, layout, copy, SVG geometry, and state visibility may not.
