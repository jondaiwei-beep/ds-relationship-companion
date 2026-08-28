# SVG Freeze v1 · Warm Authority

Status: **frozen for visual use**. This package contains the canonical vector masters for the current approved V5 Warm Authority screen candidates.

## Non-negotiable rules

1. Screen code references semantic Asset IDs from `manifests/assets.json`; it never copies SVG path data.
2. Masters are native vector geometry. Do not auto-trace raster previews or redraw these assets during implementation.
3. Every master has a stable `viewBox`, rounded line caps/joins where applicable, no embedded text, no bitmap data, no filters and no external dependencies.
4. Generic dividers, borders, circles, dots, progress axes and layout rules are Flutter/CSS primitives driven by design tokens; they are not standalone assets.
5. SVG color is `currentColor`. The consumer supplies only an allowed semantic color token registered for that Asset ID.
6. Botanical motifs remain decorative, low contrast and non-interactive. They must never reduce text contrast or touch-target clarity.
7. Do not open a screen's build gate merely because its SVG assets are approved. Product, state, recovery, platform and visual QA gates remain independent.

## Frozen geometry classes

| Class | Count | ViewBox convention | Stroke range | Typical rendered size |
|---|---:|---|---:|---:|
| Brand / ritual marks | 6 | `64×64`, `80×64`, `64×88` | 1.25–1.75 | 32–88 dp |
| Navigation | 4 | `32×32` | 1.25–1.5 | 24–28 dp |
| State | 8 | `32×32` or `48×32` | 1.25–1.75 | 24–32 dp |
| Functional | 8 | `32×32` | 1.25–1.7 | 20–28 dp |
| Response | 4 | `32×32` | 1.5–1.6 | 24–28 dp |
| Botanical | 3 | dedicated aspect ratio | 1.3–1.4 | responsive decorative |

## Semantic color application

- Primary line work: `Bone` / `color.text.primary`.
- Muted operational line work: `Warm Gray` / `color.icon.muted`.
- Authority/action surfaces: `Deep Olive` / `color.authority`.
- Partner presence and selected human response only: `Terracotta` / `color.relationship.presence`.
- Botanical layer: Deep Olive or Warm Gray at low opacity; never Terracotta.
- Expired and Revoked states stay neutral unless a separate final destructive confirmation is displayed.

## Flutter integration

Use `flutter_svg` through one generated semantic asset layer. Screen widgets may select an allowed token, but must not reference raw paths or ad-hoc hex colors.

~~~dart
SvgPicture.asset(
  DsAssets.markPartnerBond,
  width: 64,
  height: 52,
  colorFilter: ColorFilter.mode(
    context.dsColors.relationshipPresence,
    BlendMode.srcIn,
  ),
)
~~~

Botanical assets use `BoxFit.contain`, ignore pointer input, and sit behind content in a clipped decorative layer.

## Web integration

Use inline sanitized SVG or a CSS mask when dynamic semantic color is required. External `<img>` use is allowed only when the authored color does not need runtime substitution. Preserve the original `viewBox`; do not stretch assets to an unrelated aspect ratio.

## QA evidence

- Machine registry: `manifests/assets.json`
- Visual board: `design/qa/reference/svg-freeze-v1-board.png`
- Botanical detail board: `design/qa/reference/svg-freeze-v1-botanical-board.png`
- Machine validation: `design/qa/reference/svg-freeze-v1-validation.json`
- Reproducible validator/renderer: `design/qa/scripts/render-svg-freeze.cjs`
- Screen-level comparison remains under each Screen Package and `design/qa/`.
