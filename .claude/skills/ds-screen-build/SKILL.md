---
name: ds-screen-build
description: Build or revise a screen in the D/s Relationship Companion Flutter client against its approved design. Use whenever implementing any SCR-* screen, changing an existing screen's visuals, adding a widget to client/lib/features, or when asked to match a design, check a render against a design, or work with DsColors/DsTextStyles/DsAssets/DsRitualSurface.
---

# Building a screen

This app has an approved design system and 35 designed screens. Nothing here is
open to interpretation: colours, type, geometry, assets and behaviour are all
frozen and machine-readable. The failure mode is not disagreeing with the
design — it is not reading it.

Everything below was learned by building `SCR-01` and getting it wrong twice
first. The long form is `docs/rebuild/how-we-built-scr01.md`.

## Before writing any widget code

**1. Confirm the gate is open.**

```bash
python3 -c "import json;d=json.load(open('manifests/screen-index.json'));\
print([(s['screen_id'],s['build_gate']) for s in d['screens'] if s['screen_id']=='SCR-XX'])"
```

Only `ready_for_build` may be implemented. **You own the gate** (confirmed by
the owner on 2026-08-30: *"你们有完全的自主决定权，我只负责真机验收"*). Open it
when the design is genuinely complete, and hold it when it is not.

The gate means one checkable thing: **every row in the screen's state matrix has
a candidate or a justified N/A, and the states are rendered.** Verify that before
opening it — never assert it:

```bash
sed -n '/## 3. State matrix/,/## 4/p' design/screens/SCR-XX-*/screen.md | grep -c '| blocked |'
ls -d design/screens/SCR-XX-*/candidates/*/states/*/ | wc -l
```

Zero blocked rows and a non-empty state family, or it stays closed. Update both
`manifests/screen-index.json` and the screen's own `screen.md` — they must agree.

**A closed gate is not a reason to stop working.** It says the design is not
finished; it does not say to sit and wait for someone else to finish it. The
design system is frozen and the house style is settled, so a missing state
family is production work, not a decision that needs the owner. When a gate is
closed:

1. Find out *why* — a missing state family, no candidate, only a reference
   image. `design/screens/SCR-XX-*/screen.md` says which.
2. Produce what is missing, following `ds-design-generate`: brief Codex with the
   reference images and the frozen tokens, review what comes back against the
   house style, render the full state family deterministically.
3. Commit the design, then tell the owner the screen is ready for their gate
   decision — with the renders in hand, so the decision takes a minute rather
   than a design cycle.

Escalate and pause only for a genuine product question: a red line, a state
nobody has decided the meaning of, a flow that contradicts a requirement.
"Nobody has drawn this yet" is not one of those.

**2. Read these, in this order.** Skipping any of them means inventing a value
that already exists:

| File | Carries |
|---|---|
| `design/tokens/B2-FREEZE.md` | Canvas, surface, text and state colour semantics; control geometry; the Terracotta size floor |
| `design/assets/svg/SVG-FREEZE.md` | Asset rules, rendered size ranges, colour application |
| `design/system/spacing.md` | The 4dp grid and frozen control heights |
| `design/system/type-in-practice.md` | Which role each kind of content takes |
| `design/screens/SCR-XX-*/screen.md` | Product contract, state matrix, asset contract |
| `design/screens/SCR-XX-*/candidates/*/design-qa.md` | Often states the acceptance criteria outright |
| `product/ui-invariants.md` | The behavioural invariants this surface must restore |

**3. Read the default-state design image.** Not the expanded state, not a
thumbnail, not a state variant. `preview.webp` or `candidates/rev-N/source.png`.

The JSON behaviour contract says what must be true. The image says what it
looks like. You need both, and the image comes first — the first `SCR-01`
attempt was written from the contract alone and came out missing the primary
button, three actions, and the entire bottom navigation.

**4. Measure the design only for vertical rhythm.** Element heights and the
gaps between them. Colour, radius, control height and type all come from the
frozen tokens. Do not sample pixels for values the specs already carry.

## Writing the screen

Import one thing:

```dart
import 'package:ds_relationship_companion/ds_design_system.dart';
```

| Need | Use | Never |
|---|---|---|
| Colour | `DsColors.*` | A hex literal, `Colors.*` |
| Type | `DsTextStyles.*` | A bare `TextStyle` |
| Spacing | `DsSpacing.space*` | An arbitrary number |
| Radius | `DsRadii.*` | A literal |
| Control height | `DsControlSizes.*` | A literal |
| Icon or mark | `DsSvg(asset: DsAssets.*, tone: ...)` | `SvgPicture.asset`, copied path data |
| Page ground | `DsRitualSurface` | A plain `Container` |

`DsSvg` throws if you pass a tone the asset does not license. That is deliberate
— Terracotta belongs to partner presence and human response, and the registry
enforces it.

## Rules that come from the product, not from taste

- **The display serif belongs to human words.** Cormorant is for what a person
  wrote and what is being asked of them. Everything else is Inter. A test fails
  if UI chrome takes the display family.
- **Backend state names never reach a person.** `NEEDS_REVIEW` renders as
  "Needs review". Map every state to copy.
- **No queue vocabulary on Today.** Not `due`, `overdue`, `late`, `missed`,
  `pending`, `backlog`, `tasks`. A person's day is not a work queue, and a test
  enforces this.
- **Adjustment is permanent furniture.** Discuss / Request New Time / Can't Do
  sit beside the primary action, never behind a menu, each keeping its own 48dp
  target.
- **Terracotta text needs 24sp regular or 19sp bold.** Below that use a neutral
  and put the Terracotta on a mark. State is never colour alone.

## Verify, in this order

**1. The overflow probe, before you look at anything.**

Copy `client/test/overflow_probe_test.dart` and point it at the new screen. It
walks the render tree and fails on any box wider than the viewport. On `SCR-01`
it found four real overflows after the browser had been blamed three times.
`label.ritual` carries 2.4 tracking and overflows far sooner than it reads.

**2. Render through a browser with real fonts.**

```bash
cd client
flutter build web --target lib/qa_<screen>_main.dart --release
(cd build/web && python3 -m http.server 8099 &)
```

Then Playwright at 390 × 844, `scale: "device"`. `flutter test` ships no fonts,
so `toImage` renders every glyph as a filled box — useful for geometry, useless
for type.

**3. Compare against the design.** Adapt `tool/qa/compare-scr01.py`. Store the
render under `design/qa/implementation/SCR-XX/` with a README recording what
still differs.

**Do not optimise the alignment score.** Absolute band positions drift as soon
as one block's height changes. On `SCR-01` the run scoring 12/17 pushed content
off the bottom of the screen; the run scoring 4/17 was the first where the whole
screen was visible. What must hold: everything fits 844dp, and the page ends
where the design ends.

**4. Restore this surface's invariants** from `product/ui-invariants.md` as
tests. A screen that renders correctly and drops one has regressed the product.

## Getting a second opinion

Codex can compare a render against a design and is good at catching what you
stopped seeing — on `SCR-01` it found the type scale was uniformly too large and
that two row dividers were missing.

```bash
codex exec --skip-git-repo-check -s read-only \
  -i design.png implementation.png -- \
  "DO NOT load any skill, plugin, audit rubric or user-context. \
   DO NOT run scripts. Answer directly from the two images. \
   图1=设计稿, 图2=实现。列出差异,每条:元素/设计如何/实现如何/具体改法。至少 8 条。"
```

The `DO NOT load` prefix is required — without it a design plugin hijacks the
run and produces hundreds of lines of self-loading and no review.

**Verify its numbers before acting on them.** It reads both images as one
coordinate system, so once they diverge vertically its offsets accumulate error.
Take the observations; check the measurements.

## Wiring a screen to the server

Three layers, and the boundary between them is the point:

```
widget        reports which action was chosen; knows nothing about the server
application   knows how a command reaches the server; knows nothing about layout
domain_client repositories, already written for every Core Beta surface
```

Changing copy or spacing must not be able to break a network call, and changing
a request must not be able to break the design. `SCR-01` does this with
`features/today/application/today_actions.dart` — copy its shape.

**Idempotency keys are cached per (item, action) and cleared on success.** A
retry after a network failure is the same attempt and cannot produce a second
completion; a deliberate second action gets a new key. This is worth a test,
and the test is worth verifying by removing the cache.

**After a command, invalidate the read provider — never patch the list.**
Business state has one authority and it is not the client.

**Give every action the same shape and the same failure path.** A design where
Complete succeeds cleanly and Can't Do fails obscurely makes adjustment feel
like the lesser choice, and adjustment is a normal path.

**Name the seams to screens that do not exist.** An optional callback left
unsupplied is honest; a button wired to a placeholder is a lie that survives
review.

## Keeping a screen maintainable

The owner's standard: simple, clean, well-componentised, no redundant code.

- **One file per widget** under `features/<screen>/presentation/widgets/`. The
  screen file holds composition only — `SCR-01` is 364 lines of arrangement
  over twelve widget files.
- **Extract a repeated frame.** Five recovery states each rebuilt the same
  header-plus-list scaffold by hand before `RecoveryScaffold`; repetition is how
  recovery copy drifts apart.
- **Pass the model, not its parts.** A widget taking `index, asset, title, meta`
  forces every call site to re-derive what the item already knows.
- **Pure text mapping belongs in one file**, not as private helpers inside a
  widget. See `today_meta.dart`.
- **Layout constants shared by a screen's widgets go in their own file**, or a
  widget moved out silently loses them.
- Deviations from a frozen token stay inline **with the reason at the call
  site**, and are proposed in `design/tokens/PROPOSED-B3.md`. A deviation that
  appears on a second screen becomes a token.

## Definition of done

- [ ] Gate was `ready_for_build` before starting
- [ ] Frozen specs read before implementation
- [ ] Zero raw hex, ad-hoc spacing, or copied SVG paths
- [ ] Overflow probe passes at 390 × 844
- [ ] Browser render with fonts stored under `design/qa/implementation/SCR-XX/`
- [ ] Remaining differences written down, not described as done
- [ ] This surface's invariants exist as tests
- [ ] Android and Flutter Web verified: refresh, back, direct URL
