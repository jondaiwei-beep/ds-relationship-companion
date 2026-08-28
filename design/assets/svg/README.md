# SVG masters

This directory contains the 33 native vector masters frozen in SVG Freeze v1: brand and ritual marks, navigation, state, functional and response icons, plus restrained botanical/editorial motifs.

Read [`SVG-FREEZE.md`](SVG-FREEZE.md) before implementation. Every vector has one stable Asset ID in `manifests/assets.json`, one canonical source file and an approved semantic color contract. Application code references the semantic Asset ID through a generated asset layer; it must not trace raster references, duplicate SVG paths or embed ad-hoc colors inside a screen.

## File naming

Convert dots to hyphens: Asset ID `emblem.ritual.evening` maps to `emblem-ritual-evening.svg` unless the registry declares another path.

SVG Freeze v1 contains no planned assets. Any future asset starts as `planned`, receives a versioned native master and passes the same QA process before becoming `approved`.
