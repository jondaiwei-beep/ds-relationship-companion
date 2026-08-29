# B-2 Token Freeze v1 · Warm Authority

Status: **frozen for implementation**. Canonical machine source: `design/tokens/design-tokens.json`. This freeze resolves semantic color, canvas, surface, border, state, radius and control-height ambiguity. It does not approve unfinished screen states or open any screen build gate.

## 1. Canvas and surface model

Warm Authority is not a generic dark theme and is not a user-switchable light/dark mode in Core Beta. It has two intentional spatial contexts:

| Context | Semantic token | Frozen value | Use |
|---|---|---:|---|
| Ritual structure | `color.semantic.canvas.ritual` | `#080B07` | Today focus, entrance, invite, response and authority moments |
| Living layer | `color.semantic.canvas.living` | `#F4F1EB` | Future lighter daily-management surfaces where approved by a Screen Package |
| Raised ritual surface | `color.semantic.surface.ritual.raised` | `#1E241F` | Sheet, card, composer and modal body |
| Authority/action surface | `color.semantic.surface.ritual.action` | `#2F3A2E` | Primary actions and selected structural controls |
| Raised living surface | `color.semantic.surface.living.raised` | `#E7E3DA` | Light cards and grouped settings |

`#080B07` is the calibrated near-black repeatedly sampled from the selected high-fidelity references. Do not substitute pure black, Material dark defaults or `Dark Moss` as the page canvas.

## 2. Text and accessibility

| Pair | Contrast | Rule |
|---|---:|---|
| Bone on Ritual Canvas | 17.55:1 | Primary copy and controls |
| Stone on Ritual Canvas | 15.45:1 | Secondary copy |
| Warm Gray on Ritual Canvas | 9.78:1 | Muted operational copy |
| Bone on Deep Olive | 10.55:1 | Primary CTA label |
| Olive Mist on Bone | 4.74:1 | Muted light-context copy |
| Terracotta on Ritual Canvas | 4.02:1 | Large text, icons, marks and non-text relationship accents only |

Terracotta is never generic warning red. Small partner-status labels use Stone/Bone text with a Terracotta presence mark. Terracotta text requires at least 24sp regular or 19sp bold; otherwise use an accessible neutral. State is never communicated by color alone.

## 3. State semantics

- `completed`: Bone; pair with `state.completed`.
- `waiting`, `paused`, `expired`: Warm Gray; pair with distinct copy and the registered state SVG.
- `activePartner`, `acknowledged`: Terracotta for the mark/large relational statement; small supporting copy stays Stone.
- `needsReview`, `revoked`, `error`: Stone with a unique icon/label. Warm Authority does not turn generic errors into red threat theatre.
- `destructiveFinal`: Terracotta outline at the final confirmation threshold only; foreground stays Stone.

## 4. Geometry freeze

| Contract | Token | Value |
|---|---|---:|
| Minimum touch target / icon button | `size.touchTarget`, `size.control.iconButton` | 48dp |
| Standard primary/secondary button | `size.control.button` | 56dp |
| Ritual/hero primary CTA | `size.control.buttonRitual` | 64dp |
| Text field | `size.control.textField` | 56dp |
| Text area minimum | `size.control.textAreaMin` | 144dp |
| Selection row | `size.control.selectionRow` | 64dp |
| Dense operational list row | `size.control.listRow` | 72dp |
| Bottom navigation before safe-area inset | `size.control.bottomNavigation` | 80dp |
| Control / card / sheet radius | `radius.control`, `radius.card`, `radius.sheet` | 10 / 12 / 16dp |
| Hairline / selected / focus border | `borderWidth.*` | 1 / 1.5 / 2dp |

The old 48dp primary-CTA note is retired. 48dp is the minimum target, 56dp is the standard visual control and 64dp preserves the approved ritual CTA proportions.

## 5. Surface effects

Use tonal separation before shadow. Raised cards use the frozen `shadow.raised` only when a border and surface color cannot express hierarchy. Modal sheets use `shadow.modal` plus a 1dp strong top border. Never add generic glow to controls.

The approved visual references contain restrained film grain. B-2 freezes the application rule at `opacity.grain = 0.035` and vignette-edge maximum at `0.18`; the reusable texture implementation remains a separate B-4 deliverable. Until B-4 is resolved, do not invent a raster texture or ship a non-deterministic noise shader.

## 6. Consumption

- Flutter: use `design/tokens/generated/ds_design_tokens.dart` as the generated input to the app theme layer.
- Web: import `design/tokens/generated/ds-design-tokens.css`.
- Never copy raw Hex values into screens.
- Regenerate bindings with `node design/tokens/scripts/generate-token-bindings.cjs` after a versioned token change.
- Validate and regenerate QA evidence with `node design/qa/scripts/render-token-freeze.cjs`.
