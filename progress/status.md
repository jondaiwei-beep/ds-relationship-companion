# Migration status

## Prepared

- GitHub-ready repository structure
- Codex and Claude Code working contracts
- Existing 00–30 raster inventory copied into the migration baseline
- Legacy design manifest preserved
- Warm Authority primitive colors and spacing baseline
- Bundled Cormorant Garamond and Inter font files with licenses
- Flutter font declaration and local Web font CSS
- Full-resolution GitHub-readable WebP mirror of all 31 design screens
- Developer-facing Screen Package structure for all 31 visual references
- Machine-readable Screen Index and requirement/design/asset traceability contract

## Next alignment work

1. Export and reconcile current Notion product specifications into `product/requirements/`, `product/flows/`, and `product/domain/`.
2. Assign stable requirement IDs and connect them to Screen Packages.
3. Resolve every `blocked_alignment_required` note without inventing product behavior.
4. Freeze semantic color, typography, spacing, radius, stroke, texture, and motion tokens.
5. Create and register the first SVG master batch.
6. Complete a `ready_for_build` Today pilot package before importing or modifying Flutter UI code.
