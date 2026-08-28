# Requirement → design → code traceability

Every implementation must preserve this chain:

| Link | Canonical location | Failure behavior |
|---|---|---|
| Product intent and behavior | `product/requirements/`, `product/flows/`, `product/domain/` | Block; never infer from UI |
| Page contract and build gate | `design/screens/SCR-*/screen.md` | Block if incomplete |
| Page discovery and machine routing | `manifests/screen-index.json` | Screen is not addressable |
| Visual appearance | Co-located `preview.webp` plus tokens/components | Block visual implementation if reference is absent |
| Asset identity | `manifests/assets.json` | Block; never redraw from raster |
| Vector source | Registered file in `design/assets/svg/` | Block or create/approve the master first |
| Code | Platform implementation referenced by the screen contract | Not complete without QA |
| QA evidence | `design/qa/implementation/` | Gate cannot be considered satisfied |

The legacy manifest is historical alignment evidence. The active implementation entry point is `manifests/screen-index.json`.
