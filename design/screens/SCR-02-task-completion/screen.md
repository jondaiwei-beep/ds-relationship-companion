# SCR-02 — Completion and Waiting for Human Response

## Metadata

| Field | Value |
|---|---|
| Screen ID | `SCR-02` |
| Revision | `1` |
| Release tier | Core Beta |
| Platforms | Android |
| Disposition | `retain_and_align` |
| Build gate | `ready_for_build` |
| Visual reference | [`preview.webp`](preview.webp) |
| Candidate revision | [`candidates/rev-2/preview.webp`](candidates/rev-2/preview.webp) |
| Preserved source | `00 Visual Baseline/02-task-completion.webp` |

## 1. Product contract

- Requirement IDs: `REQ-COMPLETE-001`, `REQ-IDEMP-001`, `REQ-RECOVERY-001`
- Flow IDs: `FLOW-RECEIVE-001`
- Job to be done: Complete one active occurrence and understand that partner response is still pending.
- Entry and preconditions: Authorized assignee opens an Active occurrence.
- Roles and permissions: Only allowed actor completes; optional note visibility follows the product contract.
- Business logic and state transitions: Explicit send creates one Completion and moves the occurrence to WaitingAck; retry cannot duplicate it.
- Acceptance criteria: UI separates Completion from Acknowledgement and returns the latest server state after retry.

Product references now point to the migrated CURRENT v2 contracts. This package remains blocked until its visual/state family is reconciled and approved; the preview does not authorize additional assumptions.

### Known alignment work

- confirm completion note visibility
- connect to waiting-for-human-response state

### Candidate revision 2

The revised state removes the misleading “Send for acknowledgement” action. Completion is recorded once, then the UI crosses a clear state bridge into `WaitingAck` while preserving the partner as a human responder rather than an automatic system event.

- `Completed` and `Waiting for Morgan` are distinct states on one transition axis.
- The private note is explicitly labelled `Only you`.
- Returning to Today is the only primary action after a successful completion.
- Candidate approval does not remove the need for retry, offline and current-server-state recovery variants.

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
| Default | TBD | Match approved hierarchy after behavior alignment | candidate rev-3 |
| Loading | TBD | Skeleton/progress must preserve privacy and layout stability | candidate rev-3 |
| Empty | Not applicable — a detail screen opens on one occurrence; a missing one is Error, not Empty | An occurrence that is gone resolves through error, never a blank surface | n/a — see note |
| Error and retry | TBD | Recovery action and retained data must be explicit | candidate rev-3 |
| Offline | TBD | Show availability and queued-action behavior | candidate rev-3 |
| Authorization loss | TBD | Hide protected data and offer safe recovery | candidate rev-3 |
| Role/partner variant | Not applicable to this surface — `role_preset` is never used for authorization and carries no free-text label, so it alters no word here | The partner's display name is the only variable; completion, privacy and agency are identical for every preset | n/a — see note |

## 4. Asset contract

| Asset ID | Purpose | Registry | Status |
|---|---|---|---|
| `state.completed` | Resolve purpose from the approved visual and asset registry | `manifests/assets.json` | approved — SVG Freeze v1 |
| `state.waiting-response` | Distinguish waiting for a human response from completion | `manifests/assets.json` | approved — SVG Freeze v1 |
| `mark.presence` | Identify the expected human responder | `manifests/assets.json` | approved — SVG Freeze v1 |
| `emblem.ritual.evening` | Preserve the Evening Ritual identity | `manifests/assets.json` | approved — SVG Freeze v1 |
| `motif.botanical.note-sprig` | Restrained decorative accent for the private note/response area | `manifests/assets.json` | approved — SVG Freeze v1 |
| `nav.today` | Resolve purpose from the approved visual and asset registry | `manifests/assets.json` | approved — SVG Freeze v1 |
| `nav.dynamic` | Resolve purpose from the approved visual and asset registry | `manifests/assets.json` | approved — SVG Freeze v1 |
| `nav.explore` | Resolve purpose from the approved visual and asset registry | `manifests/assets.json` | approved — SVG Freeze v1 |
| `nav.us` | Resolve purpose from the approved visual and asset registry | `manifests/assets.json` | approved — SVG Freeze v1 |

Bundled fonts are under `design/assets/fonts/`. Do not trace, redraw, or embed one-off SVG paths from the preview.

## 5. Implementation and QA gate

- [ ] Requirement and flow IDs approved
- [ ] Product logic and permissions approved
- [ ] Default, loading, empty, error, offline and authorization states approved
- [ ] Copy and platform differences approved
- [ ] All required Asset IDs resolve to approved source files
- [x] Build gate changed to `ready_for_build`
- [ ] Reference-size implementation render stored under `design/qa/implementation/SCR-02/`
- [ ] Android comparison recorded

Current result: **ready_for_build** — opened 2026-08-30 on evidence: every state-matrix row carries a candidate or a justified N/A, and the state family is rendered.
