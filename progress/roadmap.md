# Roadmap

Written 2026-08-29 after `SCR-01` reached the read model. Records the sequence
and, more importantly, why the order is what it is.

## The shape of the problem

Three layers, in dependency order:

```
design system (app/)        tokens · fonts · SVG · theme · texture
        ↓
shared components           none yet — all 20 live inside today_screen.dart
        ↓
screens (client/features)   1 of 35 built
```

The middle layer is empty on purpose. A component extracted from one use is a
guess about the second, and this project has already paid for guessing twice.

## What is genuinely finished

| | State |
|---|---|
| Backend | 189 tests. Full loop runs end to end. |
| Data layer | 12 repositories, untouched by the UI rebuild. |
| Design system foundation | 33 SVG masters, B-2 tokens, B-4 grain, 8 type roles, 2 themes. 26 tests. Proven by a real consumer. |
| Enforcement | `check-screens.py` in `foundation:check`; each rule verified by injecting its defect. |
| `SCR-01` Today | Default, loading, empty, error, offline and authorization-loss states. Live read model. 16 invariants as tests. |

## What is not, and is being called finished nowhere

- **Shared components: zero.** Contracts are written in
  `design/components/CONTRACTS.md`; no code has been promoted.
- **`SCR-01` state renders**: offline, authorization-loss, role-variant and
  solo exist in code but have no QA evidence.
- **Android**: never run. Only Flutter Web has been rendered.
- **34 screens**: gates closed.

## Sequence, and the reason for it

### Now · Finish SCR-01's evidence

Render the four unproven states, store them under
`design/qa/implementation/SCR-01/`, and run the screen on Android. Until this
happens "Today is done" is an assertion, and the last three times I asserted
something was done a render disproved it.

Small, and it closes the loop on the pattern every other screen will copy.

### Next · Bottom navigation, and only that

Eight screens reference the nav assets. It is the one component whose second
use is a fact rather than a forecast, and every tabbed screen needs it before
it can exist.

Promote `_BottomNavigation` and `_NavTab` into `client/lib/design_system/`.
Leave the other eighteen where they are.

### Then · The second screen, whichever gate opens

The component layer grows from the second screen, not before it. When
`SCR-02`, `SCR-33` or another opens, build it against the contracts — and
promote a component at the moment it is needed twice, with the second use in
hand to shape the API.

Two are worth taking early when available:

- **`SCR-33` Acknowledgement Composer** — where the central red line lives.
  Only an explicit human send creates an acknowledgement. The backend enforces
  it; no UI has ever expressed it.
- **`SCR-10` Web Join** — the only surface a non-user sees, and Web is the
  least exercised part of this codebase.

### After · The rest of the slice, then Attention and Check-in

`Goal → Minimal Setup → Starter Rhythm → Invite → Web Join → First Shared
Interaction → Human Acknowledgement`, each as its gate opens.

## The rhythm, per screen

Same loop every time, from `ds-screen-build`:

```
gate open? → read frozen specs → read the default-state image
  → build from the design system → overflow probe
  → browser render with fonts → compare → restore invariants as tests
  → Android + Web verification
```

One screen fully through this beats three screens most of the way through it.
Three-quarters-done screens are how a design system drifts: each one leaves a
decision someone later has to guess at.

## What would tell us this is going wrong

- A component promoted before a second screen needs it.
- A screen called done without a render stored beside its design.
- An invariant deleted rather than restored when a screen changes.
- A `check-screens` rule relaxed to make a build pass, rather than the code
  corrected — or relaxed without re-verifying that it still catches the defect.
- A gate opened by anyone other than the product and design owner.
