# Screen Packages

This directory is the fastest and safest entry point for UI implementation. Open `manifests/screen-index.json`, choose a Screen ID, then read its package.

## Package contract

Each `SCR-*` folder contains `screen.md` and `preview.webp`. The contract answers three implementation questions in one place:

1. What does this page do, and which approved product requirements control it?
2. What must it look and behave like across states and platforms?
3. Which registered assets and SVG masters does it require?

No package becomes buildable until product references, state coverage, assets, and acceptance criteria are complete and its gate is `ready_for_build`.
