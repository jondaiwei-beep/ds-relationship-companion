# SCR-01 Today · implementation evidence

`today-default.png` — the default state rendered from the running Flutter Web
build at 390 × 844 with the bundled fonts loaded, captured through Playwright.

Compare it against
`design/screens/SCR-01-today/candidates/rev-2/source.png`:

```bash
python3 tool/qa/compare-scr01.py
```

The script reports vertical band alignment. Both images resolve to 17 bands,
and 12 of them sit within 12dp.

## Known differences

| Where | State |
|---|---|
| Bands 4, 5, 7 (headline second line → adjustment row) | Implementation runs 15–43dp higher. The serif block is shorter than the design's. |
| Band 10 | Reads as +41dp but is a segmentation artefact: the design splits the 03 row's title and subtitle into two bands, the implementation renders them as one. Not a layout defect. |
| `Relationship day ends at 2:00 AM` | Correctly positioned (−1dp) but falls under the bottom navigation, so it needs a scroll. |

## What the render already confirms

- The ritual canvas measures `#080B07`, matching the frozen token.
- Cormorant Garamond appears only on the expectation headline and the partner
  quotation. Inter carries every piece of UI chrome.
- All 11 registered SVG masters resolve and paint.
- `Complete` is 56dp; Discuss / New time / Can't do keep separate 48dp targets.
- No element exceeds the 390dp viewport — asserted by
  `client/test/overflow_probe_test.dart`, which caught four real overflows.
