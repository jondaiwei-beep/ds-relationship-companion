# Product specification

This directory is replacing Notion as the canonical product source. Migration must preserve feature intent, role/permission semantics, consent and privacy invariants, platform scope, state transitions, and acceptance criteria.

## Current migrated entry points

1. `00-overview.md`
2. `requirements/core-beta.md`
3. `flows/core-beta-flows.md`
4. `domain/core-beta-state-contracts.md`
5. `notion-source-map.md`

`design/coverage/core-beta-coverage.md` records how these product contracts map to existing, redesigned, missing and future visual families.

## Target structure

- `00-overview.md`
- `01-positioning.md`
- `02-core-daily-loop.md`
- `03-role-permissions.md`
- `requirements/` — stable, testable requirement IDs referenced by screens
- `flows/` — entry, transition, recovery, and exit behavior across screens
- `domain/` — roles, consent, privacy, pairing, task, ritual, and notification state models
- `feature-specs/`
- `decisions/`

Notion content is not automatically authoritative. During migration it must be challenged against the current product direction and approved visual system. Conflicts remain blocked until resolved.

Product files must define behavior without describing pixel layout. Every approved requirement receives a stable ID, for example `REQ-TODAY-001`, and is referenced from both `manifests/screen-index.json` and the relevant screen contract.
