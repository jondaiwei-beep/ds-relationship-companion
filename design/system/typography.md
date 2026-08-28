# Typography · bundled and deterministic

The application must not depend on fonts installed on a developer machine. All approved font files are committed under `design/assets/fonts/` and must be bundled into Flutter and served locally by Web Companion.

## Approved families

The generated PNG references do not contain embedded font metadata, so their source font cannot be proven from metadata alone. Direct glyph comparison of the Today headline—including the capital R and the shapes of f, t, a, and y—strongly matches Cormorant Garamond. The design system therefore freezes the open, redistributable pairing below. Final size, line height, and tracking still require screen-level calibration during the Today pilot.

| Role | Family | Included weights | Usage |
|---|---|---|---|
| Display / Ritual | Cormorant Garamond | 400, 500, 600 | Ritual prompts, partner quotations, editorial statements |
| UI / Functional | Inter | 400, 500, 600, 700 | Navigation, controls, labels, body copy, status text |

Both families are distributed under the SIL Open Font License 1.1; their license files are stored beside the font binaries. Do not substitute platform Garamond, Times, Roboto, or system sans fonts.

## Initial type roles

| Token | Family | Weight | Size / line height | Tracking |
|---|---|---:|---:|---:|
| display.ritual | Cormorant Garamond | 400 | 34 / 42 | 0 |
| display.partner | Cormorant Garamond | 400 | 28 / 36 | 0 |
| title.page | Inter | 600 | 22 / 28 | -0.2 |
| body.primary | Inter | 400 | 16 / 24 | 0 |
| body.secondary | Inter | 400 | 14 / 20 | 0 |
| label.action | Inter | 600 | 16 / 20 | 0.1 |
| label.ritual | Inter | 500 | 12 / 16 | 2.4 |
| nav.label | Inter | 500 | 12 / 16 | 0 |

These role values are a first freeze for implementation setup and must be calibrated screen-by-screen before a screen moves to `ready_for_build`.

## Flutter declaration

The paths below assume the Flutter `pubspec.yaml` is at repository root. If the existing Flutter project is retained under `app/`, copy or package these canonical binaries into that Flutter package during the controlled code-integration step and update only the paths—not the family names or font files.

```yaml
flutter:
  fonts:
    - family: Inter
      fonts:
        - asset: design/assets/fonts/inter/Inter-Regular.ttf
          weight: 400
        - asset: design/assets/fonts/inter/Inter-Medium.ttf
          weight: 500
        - asset: design/assets/fonts/inter/Inter-SemiBold.ttf
          weight: 600
        - asset: design/assets/fonts/inter/Inter-Bold.ttf
          weight: 700
    - family: CormorantGaramond
      fonts:
        - asset: design/assets/fonts/cormorant-garamond/CormorantGaramond-Regular.ttf
          weight: 400
        - asset: design/assets/fonts/cormorant-garamond/CormorantGaramond-Medium.ttf
          weight: 500
        - asset: design/assets/fonts/cormorant-garamond/CormorantGaramond-SemiBold.ttf
          weight: 600
```
