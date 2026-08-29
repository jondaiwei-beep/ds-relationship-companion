# Repository inventory · 2026-08-29

Written after merging the implementation into this repository. Every number
below was measured, not carried over from a previous document.

## Consistency

All cross-references resolve. Nothing was repaired to make this true.

| Check | Result |
|---|---|
| SVG masters on disk / `assets.json` / `svg-freeze.v1` / `app/assets` / `DsAssets` | 33 / 33 / 33 / 33 / 33 |
| Asset IDs referenced by a screen contract but unregistered | 0 |
| Screen contracts named in `screen-index.json` but absent | 0 of 35 |
| `REQ-*` / `FLOW-*` used by a screen but undefined in `product/` | 0 of 36 |
| Flutter token binding vs. `design/tokens/generated/` | byte-identical |
| Foundation regeneration drift | none |

## Verification

| Surface | Result |
|---|---|
| `npm run foundation:check` | pass — 33 SVGs, 7 fonts, B-2, B-4, no raw colors |
| `app` (design system) | 25 tests pass · analyze clean · format clean |
| `client` (Flutter app) | 131 tests pass · analyze clean |
| `backend` (Kotlin) | 187 tests pass |

## Screen gates

| Gate | Count |
|---|---|
| `blocked_alignment_required` | 29 |
| `future_reference` | 5 |
| `reference_only` | 1 |
| **`ready_for_build`** | **0** |

No screen may be implemented yet. This is the single fact that governs what
happens next.

## Open blockers

**Design side** — the one gate-opening dependency:

- Today `SCR-01` B-3 Revision 2 awaits approval. Everything else it needs
  (assets, tokens, texture, type) exists.
- Attention and Daily Check-in have no design yet.
- Invite share retry and Web Join revoked/stale/loading/offline/auth-loss
  variants are incomplete.

**Product side** — four domain gaps in `product/domain/core-beta-state-contracts.md`:

- `G-1` — precise cutoff for provider calls initiated after the membership
  transaction, replacing the impossible "future delivery = 0".
- `G-2` — Block directionality, Dynamic termination, historical visibility,
  rejoin policy.
- `G-3` — the complete Occurrence side-path transition graph and terminal states.
- `G-4` — whether an authenticated identity is mandatory to accept an invite.

`G-2` and `G-3` block implementation of adjustment, pause/resume and
leave/block behavior regardless of how the visual design resolves.

## The two Flutter trees

`app/` and `client/` both exist on purpose and are not yet joined.

`app/` is the frozen design system with no product UI. `client/` is the working
application, still on its pre-migration token layer, holding behavior the
frozen design has not been applied to: activation, the human response loop,
adjustments, and 131 tests that cover them.

They converge screen by screen as gates open. Until a screen is
`ready_for_build`, `client/` must not import `app/`, and the pre-migration
token layer in `client/lib/design_system/` must not be extended.

## What the backend fixes changed

Two defects found by running the product rather than reading it:

- 14 of 18 endpoints were missing `@Valid`, so `@NotBlank` never executed. An
  empty acknowledgement returned 201 and rendered to the partner as a response
  from a person. This is red line #2.
- Password registration never wrote `display_name`, so every "who did this" in
  the product resolved to nobody.

Both are fixed and covered. The existing test for the first one had been
passing for the wrong reason — it never moved the occurrence into
`WAITING_ACK`, so the request was refused on state rather than on content.
