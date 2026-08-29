# B-4 Texture Freeze v1 · deterministic ritual grain

Status: **frozen for implementation**. The dark references intentionally use restrained film grain; it is not PNG compression.

- Canonical asset: `design/assets/textures/ritual-grain-128.png`
- Size: 128 × 128 px, repeating monochrome tile
- Generator: `design/assets/textures/scripts/generate-ritual-grain.cjs`
- Seed: `0x44535243`
- Application: `softLight`, repeating, `opacity.grain = 0.035`
- Scope: Ritual Canvas only. Living surfaces remain flat until a Screen Package explicitly approves texture.
- Interaction/accessibility: always ignore pointer input and semantics; never reduce text contrast or carry state meaning.
- Vignette: remains a runtime gradient capped by `opacity.vignetteEdge = 0.18`; it is not baked into this tile.

Do not substitute random runtime noise, an unseeded shader, a downloaded texture, or a one-off screen asset. Regeneration must produce the SHA-256 recorded in `design/qa/reference/texture-freeze-b4-v1-validation.json`.
