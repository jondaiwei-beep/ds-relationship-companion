# Assets the built screens need and SVG Freeze v1 does not have

Tracing a glyph from a raster preview is forbidden, and a Material icon would
be the only non-frozen mark in the product. So each gap below is currently a
word or an omission in code, with a comment at the call site pointing here.

| Needed | Where | Drawn in the design? | What the code does instead |
|---|---|---|---|
| `icon.reveal` / `icon.conceal` | SCR-05, SCR-06 password fields | Yes — an eye glyph, and a struck-through eye implied for the revealed state | `Show` / `Hide` as text, 48dp target |
| `icon.back` | SCR-05, SCR-06 top left | Yes — a thin left arrow | Pending: same problem, see below |

## Why the back arrow is separate

A back affordance is navigation chrome rather than product iconography, so it
may legitimately belong to the platform rather than to the frozen set. That is
a design-owner call, not one to settle in a widget. Until it is settled the
screens use the platform back affordance, which is correct on Android and on
Web and matches the drawn position closely enough not to invent an asset.

## Rules that still apply

- Do not trace or redraw these from `preview.webp`. The rasters are previews.
- Do not substitute a Material or Cupertino icon "temporarily". Temporary
  marks are how a design system stops being the only source of marks.
- When an asset lands, it goes through the same freeze as the other 33:
  registered in `manifests/assets.json`, given a tone licence, validated.
