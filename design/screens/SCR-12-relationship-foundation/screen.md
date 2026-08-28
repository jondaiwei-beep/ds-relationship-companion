# SCR-12 — Relationship Foundation

## Metadata

| Field | Value |
|---|---|
| Screen ID | `SCR-12` |
| Revision | `1` |
| Release tier | Core Beta |
| Platforms | Android |
| Disposition | `replace_or_merge` |
| Build gate | `blocked_alignment_required` |
| Visual reference | [`preview.webp`](preview.webp) |
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
| Default | TBD | Match approved hierarchy after behavior alignment | blocked |
| Loading | TBD | Skeleton/progress must preserve privacy and layout stability | blocked |
| Empty | TBD | Explain next safe action without invented urgency | blocked |
| Error and retry | TBD | Recovery action and retained data must be explicit | blocked |
| Offline | TBD | Show availability and queued-action behavior | blocked |
| Authorization loss | TBD | Hide protected data and offer safe recovery | blocked |
| Role/partner variant | TBD | Preserve consent, privacy and agency invariants | blocked |

## 4. Asset contract

| Asset ID | Purpose | Registry | Status |
|---|---|---|---|
| `emblem.ritual.evening` | Resolve purpose from the approved visual and asset registry | `manifests/assets.json` | planned — SVG master required |

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
