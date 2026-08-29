# SCR-01 Today · Revision 2 · B-3

Status: `candidate_for_approval`. This package resolves the missing prioritized-list and Today recovery/role visual family without replacing the preserved ritual-focus state.

## Files

- `source.png` / `preview.webp`: default Today with three priorities and collapsed Later.
- `states/expanded/`: eight-item example; the contract supports eight through ten in server order.
- `states/loading/`, `empty/`, `error-retry/`, `offline/`, `authorization-loss/`: privacy-safe recovery family.
- `states/role-variant/`: same geometry and agency rights with custom-role wording.
- `states/solo/`: private Today without partner presence or automatic sharing.
- `today-b3-spec.json`: machine-readable behavior, privacy and role contract.
- `render-today-b3.cjs`: deterministic source/preview and review-board renderer.

The canonical comparison board is `design/qa/reference/today-b3-state-family-board.png`. It includes all Revision 2 states plus the preserved ritual-focus reference.

## Build rule

Claude Code may inspect this candidate, but must not mark SCR-01 built until the product/design owner approves it and the Screen Package build gate becomes `ready_for_build`.
