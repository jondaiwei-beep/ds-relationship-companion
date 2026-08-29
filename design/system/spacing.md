# Spacing system

Base grid: 4 logical pixels.

| Token | Value |
|---|---:|
| space.1 | 4 |
| space.2 | 8 |
| space.3 | 12 |
| space.4 | 16 |
| space.5 | 20 |
| space.6 | 24 |
| space.8 | 32 |
| space.10 | 40 |
| space.12 | 48 |
| space.16 | 64 |
| space.20 | 80 |
| space.24 | 96 |

Default mobile horizontal inset is 20 logical pixels. Minimum touch target is 48 × 48. Components must use constraints and semantic spacing; avoid page-specific magic numbers.

## Frozen control geometry

| Contract | Token | Value |
|---|---|---:|
| Minimum touch target / icon button | `size.touchTarget`, `size.control.iconButton` | 48dp |
| Standard button | `size.control.button` | 56dp |
| Ritual/hero CTA | `size.control.buttonRitual` | 64dp |
| Text field | `size.control.textField` | 56dp |
| Text area minimum | `size.control.textAreaMin` | 144dp |
| Selection row | `size.control.selectionRow` | 64dp |
| Operational list row | `size.control.listRow` | 72dp |
| Bottom navigation before safe area | `size.control.bottomNavigation` | 80dp |

48dp is touch safety, not the default primary-button height. The selected high-fidelity references use 56dp standard controls and 64dp ritual CTAs.

## Radius and border

| Contract | Value |
|---|---:|
| `radius.small` / `radius.medium` | 4 / 8dp |
| `radius.control` | 10dp |
| `radius.card` | 12dp |
| `radius.sheet` | 16dp |
| `radius.capsule` | 999dp |
| `borderWidth.hairline` | 1dp |
| `borderWidth.selected` | 1.5dp |
| `borderWidth.focus` | 2dp |

Canonical values and generated Flutter/Web bindings live under `design/tokens/`.
