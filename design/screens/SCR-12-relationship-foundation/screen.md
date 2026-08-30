# SCR-12 — Starter Rhythm

## Metadata

| Field | Value |
|---|---|
| Screen ID | `SCR-12` |
| Revision | `1` |
| Candidate revision | `2 — approval pending` |
| Release tier | Core Beta |
| Platforms | Android |
| Disposition | `replace_or_merge` |
| Build gate | `ready_for_build` |
| Released legacy reference | [`preview.webp`](preview.webp) |
| Candidate preview | [`candidates/rev-2/preview.webp`](candidates/rev-2/preview.webp) |
| Candidate lossless source | [`candidates/rev-2/source.png`](candidates/rev-2/source.png) |
| Preserved source | `03 Pairing Consent and Foundation/12-relationship-foundation.webp` |

## 1. Product contract

- Requirement IDs: `REQ-ACT-003`, `REQ-FIRST-001`
- Flow IDs: `FLOW-ACTIVATE-001`
- Job to be done: Review and start a small relationship rhythm that feels acceptable.
- Entry and preconditions: Minimal setup completed.
- Roles and permissions: Creator/Solo chooses the starting rhythm; partner join does not silently approve future expectations.
- Business logic and state transitions: Replace the pictured principles screen with 1 Ritual + 1 core Expectation + 1 Check-in; allow keep/replace/start.
- Acceptance criteria: A user can start without blank-canvas work or complex governance.

Product references now point to the migrated CURRENT v2 contracts. This package remains blocked until its visual/state family is reconciled and approved; the preview does not authorize additional assumptions.

### Known alignment work

- replace with Starter Rhythm: one ritual, one expectation, one check-in

## 2. UI contract

- Candidate revision 2 replaces principles/governance with a three-part editorial rhythm score: 1 Ritual + 1 Expectation + 1 Check-in.
- Each item can be replaced without rebuilding the whole setup; a second Expectation remains optional.
- The continuous numbered ledger makes the three items feel like one intentional rhythm, not a checklist or card dashboard.

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
| Default | Use candidate revision 2 after approval | Three-part starter rhythm | candidate |
| Loading | TBD | Skeleton/progress must preserve privacy and layout stability | candidate rev-3 |
| Empty | Not applicable — a rhythm that cannot be produced is Error, not Empty | Failure to propose a rhythm resolves through error and retry | n/a — see note |
| Error and retry | TBD | Recovery action and retained data must be explicit | candidate rev-3 |
| Offline | TBD | Show availability and queued-action behavior | candidate rev-3 |
| Authorization loss | TBD | Hide protected data and offer safe recovery | candidate rev-3 |
| Role/partner variant | Solo starts a private rhythm; Couple may frame shared expectations, but partner participation requires explicit join | Identical geometry and identical agency in both | candidate rev-3 |

## 4. Asset contract

| Asset ID | Purpose | Registry | Status |
|---|---|---|---|
| `emblem.ritual.evening` | Resolve purpose from the approved visual and asset registry | `manifests/assets.json` | approved — SVG Freeze v1 |
| `mark.partner-bond` | Expectation relationship mark | `manifests/assets.json` | approved — SVG Freeze v1 |
| `mark.check-in` | Daily Check-in mark | `manifests/assets.json` | approved — SVG Freeze v1 |

Bundled fonts are under `design/assets/fonts/`. Do not trace, redraw, or embed one-off SVG paths from the preview.

## 5. Implementation and QA gate

- [ ] Requirement and flow IDs approved
- [ ] Product logic and permissions approved
- [ ] Default, loading, empty, error, offline and authorization states approved
- [ ] Copy and platform differences approved
- [ ] All required Asset IDs resolve to approved source files
- [ ] Build gate changed to `ready_for_build`
- [ ] Reference-size implementation render stored under `design/qa/implementation/SCR-12/`
- [ ] Android comparison recorded

Current result: **blocked_alignment_required**.
