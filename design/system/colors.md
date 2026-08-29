# Color system · B-2 frozen

Canonical machine source: `design/tokens/design-tokens.json`. Freeze contract: `design/tokens/B2-FREEZE.md`.

## Brand and support primitives

| Token | Hex | Role |
|---|---:|---|
| Bone | `#F4F1EB` | Primary warm light text and living canvas |
| Stone | `#E7E3DA` | Secondary light text and raised living surface |
| Warm Gray | `#BAB6AC` | Muted information on ritual surfaces |
| Deep Olive | `#2F3A2E` | Authority, primary actions and structural borders |
| Dark Moss | `#1E241F` | Raised ritual surfaces |
| Terracotta | `#B5533B` | Partner presence and selected human response |
| Ritual Black | `#080B07` | Calibrated near-black ritual canvas |
| Olive Mist | `#666D63` | Accessible muted text on Bone |

Black and transparent are technical support values for scrims and alpha composition, not visible brand colors.

## Semantic surface stack

| Layer | Token | Value |
|---|---|---:|
| Ritual canvas | `color.semantic.canvas.ritual` | Ritual Black |
| Living canvas | `color.semantic.canvas.living` | Bone |
| Ritual raised | `color.semantic.surface.ritual.raised` | Dark Moss |
| Ritual authority/action | `color.semantic.surface.ritual.action` | Deep Olive |
| Living raised | `color.semantic.surface.living.raised` | Stone |

Core Beta is not a user-toggleable light/dark theme. Dark Structure and Light Life are semantic contexts chosen by the approved Screen Package. Existing approved ritual screens remain dark; a light surface may be used only where a screen contract explicitly approves the living context.

## Text and relationship rules

- Bone/Stone/Warm Gray on Ritual Black are the primary, secondary and muted dark-context text roles.
- Dark Moss/Deep Olive/Olive Mist on Bone are the primary, secondary and muted light-context roles.
- Terracotta is not generic warning red. It represents a real partner, human acknowledgement or the final destructive threshold.
- Terracotta on Ritual Black is 4.02:1. It is limited to large text (at least 24sp regular or 19sp bold), icons, marks and lines. Small partner-status copy uses Stone or Bone plus a Terracotta presence mark.
- Completed, waiting, review, paused, expired, revoked and error states always combine semantic color with distinct copy and an icon; color alone is insufficient.
- Final destructive controls use a Terracotta outline with Stone foreground. Do not ship filled Terracotta buttons with normal-sized text.

The token validator records all required contrast pairs in `design/qa/reference/token-freeze-b2-v1-validation.json`.
