# Codex project rules

1. GitHub is the sole product/design/development source of truth. Do not recreate Figma dependencies.
2. Preserve V5 Warm Authority. Do not explore a new visual direction unless explicitly requested.
3. Product behavior belongs in `product/`; approved visual rules belong in `design/`.
4. Do not write raw color values, arbitrary spacing, or one-off SVG paths in application screens. Use tokens and registered assets.
5. Do not implement screens whose active manifest gate is not `ready_for_build`.
6. If product behavior and visual reference conflict, mark the screen blocked and document the conflict; never guess.
7. Every implemented screen requires a reference-size render, visual comparison, state coverage, and Android/Web verification where applicable.
8. Preserve consent, agency, privacy, pause/leave rights, and role-neutral safety behavior.

