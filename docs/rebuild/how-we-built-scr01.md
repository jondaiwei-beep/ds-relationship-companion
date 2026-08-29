# How SCR-01 was built

The record of rebuilding one screen against an approved design, written so the
other 34 do not repeat the same mistakes. Read this before starting a screen.

## The failed attempt, and why it failed

The first rebuild was written from `today-b3-spec.json` — the JSON behaviour
contract — with a glance at one state image. It produced a screen that was
missing the serif headline, the Complete button, the three adjustment actions,
the per-row marks and the entire bottom navigation. The contract had stated the
four actions must be reachable without opening a detail page. Reading it was
not the same as reading the design.

**Rule: the design image is the specification. The JSON says what must be true;
the image says what it looks like. You need both, and you read the image first.**

The second failure was subtler. Told to match the design, I started sampling
pixel colours by hand and inventing values — while `design/system/`,
`design/tokens/B2-FREEZE.md` and `design/assets/svg/SVG-FREEZE.md` already
specified every one of them.

**Rule: read the frozen specs before measuring anything. Measure the design only
for what the specs deliberately leave to the composition — the vertical rhythm.**

## The order that worked

1. **Read the specs, in this order.** `B2-FREEZE.md` for canvas, surface, text
   and state semantics plus control geometry; `SVG-FREEZE.md` for asset rules
   and rendered sizes; `system/spacing.md` for the grid; the screen's own
   `screen.md` for the asset contract and state matrix; the candidate's
   `design-qa.md`, which often states the acceptance criteria outright. For
   SCR-01 it named the thing the first attempt had missed: *"the first priority
   uses a 56dp primary action and three distinct 48dp secondary touch targets."*
2. **Read the default-state design image.** Not the expanded state, not a
   thumbnail. The default is the composition being approved.
3. **Measure the design for vertical rhythm only.** Element heights and the gaps
   between them. Colours, radii, control heights and type roles come from the
   frozen tokens, never from a screenshot.
4. **Build with the design-system package.** No raw hex, no ad-hoc spacing, no
   local token layer, no copied SVG paths.
5. **Assert the viewport before looking at anything.** See below.
6. **Render with real fonts through a browser**, capture at 390 × 844, compare.
7. **Have a second reviewer compare the two images.** Verify what it claims
   before acting on it.

## The overflow probe is not optional

Three separate times I concluded the browser or the screenshot tool was
clipping content. It was not — the layout genuinely exceeded 390dp. A widget
test that walks the tree and fails on any `RenderBox` wider than the viewport
found four real overflows in minutes:

- the presence label, which would not shrink for a long partner name
- `MORGAN RESPONDED · 12 MIN AGO`, wider than it reads because `labelRitual`
  carries 2.4 tracking
- the `01 · NOW · EXPECTATION` row, same cause
- the compact row's two-line content against the frozen 72dp row height

It lives at `client/test/overflow_probe_test.dart`. **Copy it for every new
screen.** Rendering shows you that something is wrong; the probe tells you which
widget and by how much.

## What consuming the design system exposed

Three defects surfaced only because a second package consumed it, all the same
class — **a package's own assets do not resolve from a host application without
qualification**:

| Defect | Effect |
|---|---|
| `DsAssets` emitted bare `assets/svg/...` | All 33 SVGs 404'd in any consuming app |
| Type roles used bare family names | All eight would silently fall back to a system font |
| `DsBorderWidths.hairline` emitted as `int` | Unusable where Flutter wants a double; only `1.5` happened to work |

All three are fixed at the generators, with tests. The lesson generalises: **a
foundation package that only its own tests consume is not proven.** The first
real consumer is the test.

## Reviewing with a second model

Codex compared the render against the design and produced a useful list — it
caught that the type scale was uniformly too large, and that two row dividers
were missing entirely. Both were real and both were fixed.

It also produced coordinates that were wrong, because it read the two images as
sharing a coordinate system when they had already diverged vertically; its
"shift up 111px" figures were accumulated error. And one flagged difference —
a +41dp band offset — turned out to be a segmentation artefact: the design
splits a row's title and subtitle into two bands, the implementation renders
them as one.

**Rule: take the observations, verify the numbers.** A reviewer that finds a
missing divider is worth having even when its measurements need checking.

Prompting note: the design plugin hijacked the first two review runs, producing
728 lines of self-loading and zero output. Prefix the prompt with an explicit
`DO NOT load any skill, plugin, audit rubric or user-context`.

## Comparison, and what it can prove

`tool/qa/compare-scr01.py` reports vertical band alignment. It is useful and it
is limited: absolute band positions drift as soon as one block's height changes,
so index-for-index alignment reads as a regression even when the layout got
closer. It now also asserts the things that are unambiguous — content fits the
viewport, and the page ends where the design ends.

**Do not chase the alignment score.** The run that scored 12/17 pushed the
relationship-day line off the bottom of the screen. The run that scored 4/17
was the first where the entire screen was visible without scrolling. The second
is better.

## Definition of done for a screen

- [ ] Frozen specs read before implementation
- [ ] Built only from `package:ds_relationship_companion/ds_design_system.dart`
- [ ] Zero raw hex, zero ad-hoc spacing, zero copied SVG paths
- [ ] Overflow probe passes at 390 × 844
- [ ] Rendered through a browser with fonts loaded, stored under
      `design/qa/implementation/SCR-XX/`
- [ ] Compared against the approved design; remaining differences written down,
      not described as done
- [ ] This surface's invariants from `product/ui-invariants.md` exist as tests
- [ ] Android and Flutter Web verified, including refresh, back and direct URL

---

# What the states and the device build added

Written after taking `SCR-01` from a default-state render to seven states and
an Android package.

## Rendering the states found what reading could not

Three defects, none visible in the source:

**Recovery states were unreachable in a running app.** An `AsyncValue` can be
loading *and* carry the error from the previous attempt. Without
`skipLoadingOnReload` the screen shows a spinner forever after a failed
refresh. Offline, authorization loss and plain failure had all been written,
reviewed and committed — and none of them could ever appear.

**A split-out widget silently dropped its logic.** Moving the header into its
own file left `'Morgan is present'` hardcoded where a derived label had been.
Every recovery state then claimed a partner was present while access was
unconfirmed. Extracting a widget is a refactor with the same risk as a rewrite,
and it needs the same verification.

**The asset registry caught two wrong tones.** `mark.authority` does not
license `muted`; neither does `mark.presence`. Both threw at build time. The
licence is doing exactly what it exists for, and both times the screen code was
wrong rather than the constraint being too strict.

## The misdiagnosis worth naming

Four times I concluded a capture was clipped because the layout overflowed.
It never did. **Headless Chrome's `--window-size` is not the CSS viewport** —
it crops the page rather than laying it out at 390dp. Playwright sets a real
viewport; Chrome's screenshot flag does not.

The fix was a probe that walks the render tree across every state and fails on
any box wider than the viewport. It should have been written the first time,
not the fourth. **When the same symptom is explained away twice, stop
explaining and build the instrument.**

## Working faster without working looser

The parts that were slow and avoidable:

- **Iterating to convergence on a refactor.** Renaming twenty classes produced
  27 errors, then 9, then 5, then 3 — four rounds because the dependency map
  was built by trial. Read the references first, change once.
- **Inferring runtime behaviour from static text.** Whether `--dart-define`
  reached the build was settled in seconds by one `debugPrint`, after several
  minutes of grepping the compiled bundle for string literals.
- **Not tooling a repeated problem.** See the misdiagnosis above.

The parts that were slow and worth it, and stay:

- **Rendering every state.** Three real defects, one of which would have
  stranded a user on a spinner.
- **Injecting a defect to verify each guard.** It caught a false positive in
  `check-screens` — the rule was flagging the switch that maps backend states
  to human copy, which is the rule being satisfied.

## Packaging for a device

The Android host still carried Flutter template defaults. `applicationId` was
`com.dsapp.dsapp`, which appears in system settings, notification channels and
any share sheet. Renamed to a neutral identifier alongside the label that had
already been fixed.

Verify a package rather than trusting the build log:

```bash
aapt2 dump badging app-arm64-v8a-release.apk | grep -E 'package|label|permission'
unzip -l app-arm64-v8a-release.apk | grep -c '\.svg'
```

For this build: 33 SVGs, 7 fonts and the grain texture are all present, under
`packages/ds_relationship_companion/` — the package-qualified paths hold on
Android, not just on Web.

`client/lib/main.dart` is a preview shell, not the product entry point: one
gated screen with a state switcher, replaced when the vertical slice opens.
