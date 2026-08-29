# Pre-migration history

Everything here predates the GitHub design system and is kept for reasons, not
for reuse. Nothing in this directory is authoritative.

The authoritative sources are, and remain:

| Domain | Source |
|---|---|
| Product | `product/` |
| Visual system | `design/` + `manifests/` |
| Execution contract | root `AGENTS.md` and `CLAUDE.md` |

## What is here

- `CLAUDE-pre-migration.md` — the execution contract used before the design
  system moved to GitHub. Superseded by the root `CLAUDE.md`. Retained because
  it records the product red lines and the reasoning behind them.
- `DESIGN_SYSTEM.md`, `DIRECTION_02_HINGE.md`, `DIRECTIONS_*.md` — visual
  directions explored and rejected before V5 Warm Authority was selected.
  Superseded by `design/`.
- `IMPLEMENTATION_STATUS.md`, `CORE_BETA_GAPS.md`, `OPEN_SPEC_GAPS.md`,
  `PROJECT_CONTEXT.md` — status notes from the pre-migration build.
- `adr/` — architecture decision records. Still relevant: they explain why the
  stack is Riverpod/go_router/Dio and why deployment is shaped as it is.

Rejected mockups and pre-migration golden screenshots were deleted rather than
archived: they are baselines for a visual system that no longer applies, and
keeping them invites someone to diff against the wrong reference.
