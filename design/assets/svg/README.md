# SVG masters

This directory will hold original vector masters for the Authority Mark, Ritual Emblems, Partner Bond, Presence Mark, Guidance Mark, navigation, state icons, and restrained botanical/editorial motifs.

Every asset must be registered in `manifests/assets.json` with a stable ID, viewBox, stroke width, color-token mapping, intended sizes, and usage rules. Do not trace SVGs from raster references during application development.
# SVG master assets

Every vector has one stable Asset ID in `manifests/assets.json` and one canonical source file in this directory. Application code references the semantic Asset ID through a generated asset layer; it must not embed copied SVG path data inside a screen.

## File naming

Convert dots to hyphens: Asset ID `emblem.ritual.evening` maps to `emblem-ritual-evening.svg` unless the registry declares another path.

`planned` means the design calls for the asset but no approved SVG master exists. A screen requiring a planned or missing asset cannot be `ready_for_build`.
