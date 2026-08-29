# Implementation QA evidence

Renders produced from the running Flutter code at the reference viewport
(390 × 844 logical, ×3 = 1170 × 2532), for comparison against the approved
design reference.

## SCR-01 Today

`scr01-default.png` — three priorities with Later collapsed, rendered from
`client/lib/features/today/presentation/today_screen.dart`.

**Read this render for geometry and colour, not for typography.**
`flutter test` runs without the bundled font files, so every glyph rasterises
as a filled box. That is a harness limitation, not a defect in the screen; the
type roles are asserted separately in `app/test/design_system_foundation_test.dart`.

Verified from the pixels:

| Property | Expected | Measured |
|---|---|---|
| Viewport | 1170 × 2532 | 1170 × 2532 |
| Ground | `canvas.ritual` `#080B07` | `#080B07` |

The renderer lives at `tool/qa/render-scr01.dart.txt`. It is kept out of
`client/test/` deliberately: it writes files and captures images, which is not
what the test suite is for. To re-run it, copy it into `client/test/` as a
`_test.dart` file, run it, then remove it again.

Full-fidelity comparison against `design/screens/SCR-01-today/candidates/rev-2/`
still requires a device or browser render with the fonts loaded.
