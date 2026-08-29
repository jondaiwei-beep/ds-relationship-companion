# Claude Code implementation contract

## Deterministic reading sequence

For any UI task, follow this exact sequence:

1. Read `manifests/screen-index.json` and locate the requested Screen ID.
2. Read `manifests/design-coverage.json` to understand whether the surface is retained, redesigned, missing, state-only, or future scope.
3. Open the linked `design/screens/SCR-*/screen.md` contract.
4. Read every linked product requirement, flow and domain contract. An empty Core Beta requirement reference is a blocker.
5. View the approved co-located preview and required state/platform variants; use them for hierarchy and visual comparison only. A null preview or `missing_required_design` status is a blocker.
6. Read `manifests/svg-freeze.v1.json` and `design/assets/svg/SVG-FREEZE.md`.
7. Resolve every asset ID through `manifests/assets.json`, then load its registered SVG master.
8. Read `manifests/token-freeze.b2.v1.json`, `design/tokens/B2-FREEZE.md` and the generated Flutter/Web token binding for the target platform.
9. Read linked component contracts.
10. Implement only when the screen gate is `ready_for_build` and every required asset is available.
11. Render and record QA evidence at the paths required by the screen contract.

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
- Ritual Canvas is `color.semantic.canvas.ritual` (`#080B07` through the token layer), not pure black or Material dark defaults.
- 48dp is the minimum target; standard buttons are 56dp and ritual/hero CTAs are 64dp.
- Bundle and load the fonts in `design/assets/fonts/`.
- Use registered SVG masters; do not trace or redraw icons from PNG files during implementation.
- Apply SVG colors through semantic tokens and `currentColor`; do not add raw colors or duplicate path data in screen code.
- Preserve hierarchy, whitespace, typography, partner presence, ritual marks, and restrained texture.
- Minimum interaction target: 48 × 48 logical pixels.

## Verification

For every screen, render the reference viewport, store the result under `design/qa/implementation/`, compare it with the approved reference, and record remaining differences. Geometry should normally remain within 1–2 logical pixels. Texture/grain regions may use a controlled comparison mask; typography, layout, copy, SVG geometry, and state visibility may not.
