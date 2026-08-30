# SCR-14 — Task Detail

## Metadata

| Field | Value |
|---|---|
| Screen ID | `SCR-14` |
| Revision | `1` |
| Release tier | Core Beta |
| Platforms | Android |
| Disposition | `retain_and_align` |
| Build gate | `blocked_alignment_required` |
| Visual reference | [`preview.webp`](preview.webp) |
| Preserved source | `04 Core Relationship/14-task-detail.webp` |

## 1. Product contract

- Requirement IDs: `REQ-EXPECT-001`, `REQ-COMPLETE-001`, `REQ-ADJUST-001`, `REQ-REVIEW-001`
- Flow IDs: `FLOW-RECEIVE-001`, `FLOW-ADJUST-001`
- Job to be done: Understand one occurrence and take the correct current-state action.
- Entry and preconditions: Authorized member opens an occurrence from Today or Attention.
- Roles and permissions: Allowed actions depend on assignee/reviewer and server authorization; agency actions cannot be disabled.
- Business logic and state transitions: Support Complete, Discuss, Request New Time, Can't Do and review/resolution variants; remove Proof.
- Acceptance criteria: No side path is labelled as failure and stale actions resolve current state.

Product references now point to the migrated CURRENT v2 contracts. This package remains blocked until its visual/state family is reconciled and approved; the preview does not authorize additional assumptions.

### Known alignment work

- add Discuss, Request New Time, Can't Do
- remove Proof/photo from Core Beta

## 2. UI contract

- Reference viewport: **390 × 844 logical pixels**; source preview is 853 × 1844 pixels.
- Visual direction: **V5 Warm Authority / Quiet Authority**.
- Palette, type, spacing and component values must resolve through `design/tokens/` and `design/system/`.
- Preserve the specific information hierarchy and function-specific page structure shown in `preview.webp`; do not force it into a generic card template.
- Terracotta is relational/human emphasis, not a general action color.
- Cormorant Garamond is selective editorial/ritual typography; Inter is operational UI typography.
- Responsive and platform differences: **TBD — must be specified before build**.
- Copy status: **TBD — visual copy is not automatically product-approved**.

## 3. State matrix

| State | Product rule | UI requirement | Status |
|---|---|---|---|
| Default | Authorized member opens one occurrence | Actions render from the server’s allowedActions, never from the state | candidate rev-1 |
| Loading | Current server truth is not yet confirmed | Privacy-safe; no name-shaped skeletons | candidate rev-1 |
| Empty | Not applicable — a detail screen opens on one occurrence; a missing one is Error, not Empty | An occurrence that is gone resolves through error, never a blank surface | n/a — see note |
| Error and retry | Current server truth cannot be confirmed | Retry without losing context; nothing was changed | candidate rev-1 |
| Offline | No mutation without server confirmation | Detail stays readable; every action is withheld, not disabled | candidate rev-1 |
| Authorization loss | Session or membership is no longer current | Withhold the expectation entirely; sign in again | candidate rev-1 |
| Needs review | `REQ-REVIEW-001` — past-due active work becomes Needs Review | A prompt to look, never punishment, consequence or urgency; Stone, never Terracotta | candidate rev-1 |
| Adjustment open | The member's own adjustment request is pending the other person's answer | Only `withdraw` is offered, because it is the only action the server permits | candidate rev-1 |
| Waiting for acknowledgement | Completed; the moment is unfinished until a human answers | Completion is marked and no action is offered; never reads as finished | candidate rev-1 |
| Role/partner variant | Not applicable to this surface — `role_preset` is never used for authorization and carries no free-text label | Allowed actions come from the server; every preset sees identical geometry and agency | n/a — see note |

## 4. Asset contract

| Asset ID | Purpose | Registry | Status |
|---|---|---|---|
| `state.completed` | Resolve purpose from the approved visual and asset registry | `manifests/assets.json` | approved — SVG Freeze v1 |

Bundled fonts are under `design/assets/fonts/`. Do not trace, redraw, or embed one-off SVG paths from the preview.

## 5. Implementation and QA gate

- [ ] Requirement and flow IDs approved
- [ ] Product logic and permissions approved
- [ ] Default, loading, empty, error, offline and authorization states approved
- [ ] Copy and platform differences approved
- [ ] All required Asset IDs resolve to approved source files
- [ ] Build gate changed to `ready_for_build`
- [ ] Reference-size implementation render stored under `design/qa/implementation/SCR-14/`
- [ ] Android comparison recorded

Current result: **blocked_alignment_required**.
