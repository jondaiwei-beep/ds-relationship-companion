# SCR-01 Today · implementation evidence

`today-default.png` — the default state rendered from the running Flutter Web
build at 390 × 844 with bundled fonts, captured through Playwright.

```bash
python3 tool/qa/compare-scr01.py
```

## Current state

The whole screen fits the viewport with no scrolling, ending at row 826 against
the design's 822. Every element in the approved composition is present.

## What the render confirms

- Ritual canvas measures `#080B07`, matching the frozen token.
- Cormorant Garamond appears only on the expectation headline and the partner
  quotation; Inter carries all UI chrome.
- All 11 registered SVG masters resolve and paint.
- `Complete` is 56dp; Discuss / New time / Can't do keep separate 48dp targets.
- No element exceeds 390dp — asserted by `client/test/overflow_probe_test.dart`,
  which found four real overflows during this build.

## Reading the comparison output

Band-index alignment is reported but should not be optimised for. Absolute
positions drift as soon as one block's height changes, so the score can fall
while the layout improves — the run scoring 12/17 pushed the relationship-day
line off the bottom of the screen, and the run scoring 4/17 was the first with
the entire screen visible. The unambiguous assertions are that content fits the
viewport and the page ends where the design ends.

## Known differences

| Where | State |
|---|---|
| Vertical rhythm through the first priority | Runs tighter than the design, so everything below sits higher. Deliberate: the design's spacing did not leave room for the relationship-day line within 844dp at these type sizes. |
| Band 10 in the comparison | A segmentation artefact — the design splits the 03 row's title and subtitle into two bands, the implementation renders them as one. Not a layout defect. |
