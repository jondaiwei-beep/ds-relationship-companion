# Product specification

This directory will replace Notion as the canonical product source. Migration must preserve feature intent, role/permission semantics, consent and privacy invariants, platform scope, state transitions, and acceptance criteria.

## Structure

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
