# Rebuilding the client UI

The entire pre-redesign visual layer was deleted on 2026-08-29: 24 feature
files, 11 design-system files, 15 widget test files, the router, the navigation
shell and the integration test.

## Why deleted rather than migrated

All 35 screens have approved designs in `design/screens/`. Keeping the old
layer would have meant editing each screen toward the new design instead of
building it from the design — which is how a system drifts. Uniformity and
quality were the goal, and a partial migration delivers neither.

The first attempt proved the point. SCR-01 Today was rebuilt by reading the
JSON behaviour contract and glancing at one state image, and it came out as a
different screen: no `Complete` button, no Discuss/New time/Can't do row, no
serif headline, no bottom navigation, no per-row marks. The contract explicitly
required those four actions to be reachable without opening a detail page. The
lesson is recorded here because it decides how the rebuild proceeds:

> The design image is the specification. Read the default state first, compare
> the render against it item by item, and treat any difference as a defect
> until proven otherwise.

## What was kept

| Kept | Why |
|---|---|
| `client/lib/domain_client/` (52 files) | API models, repositories, contracts. Independent of visuals. |
| `client/lib/platform/` | Push, deep links, secure storage, browser adapters. |
| `client/lib/app/providers.dart` | Dependency wiring. |
| `client/test/domain_client/` (11 tests) | Parsing and contract tests, all passing. |
| `android/`, `ios/`, `web/` | Platform hosts. |

## What was archived here

| File | Restore into |
|---|---|
| `route-contract.md` | The 16 URLs and the deep-link/Web rules the rebuild must preserve. |
| `router-pre-redesign.dart.txt` | Routing structure and guards. |
| `nav_shell-pre-redesign.dart.txt` | The four-tab shell. |
| `response_loop_integration-pre-redesign.dart.txt` | Complete → Waiting → Acknowledge, end to end. |
| `product/ui-invariants.md` | **120 behavioural invariants** the deleted tests asserted. |

`product/ui-invariants.md` is the important one. Those tests twice caught real
defects during the pre-redesign build, and they encode red lines in executable
form — Block reaches the server in two taps, PRIVATE is the default, the respond
screen starts empty, backend state names never leak. **A rebuilt screen is not
done until the invariants for its surface exist again as tests.**

## Order

Gated. Only `SCR-01` is `ready_for_build`; the other 34 stay blocked until
product, visual, asset and recovery contracts are approved for each.

When gates open, the vertical slice order is:

`Goal → Minimal Setup → Starter Rhythm → Invite → Web Join → First Shared
Interaction → Human Acknowledgement`

## Per-screen definition of done

1. Read `design/screens/SCR-*/screen.md` and every linked product contract.
2. Read the **default-state** design image, then the state family.
3. Build from `package:ds_relationship_companion/ds_design_system.dart`. No raw
   hex, no arbitrary spacing, no one-off SVG paths, no parallel token layer.
4. Restore this surface's invariants from `product/ui-invariants.md` as tests.
5. Render at 390 × 844 with fonts loaded, store under
   `design/qa/implementation/`, and compare against the approved reference item
   by item.
6. Verify on Android and Flutter Web, including refresh, back and direct URL.
