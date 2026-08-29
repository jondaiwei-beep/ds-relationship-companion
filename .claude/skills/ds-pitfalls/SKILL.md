---
name: ds-pitfalls
description: Traps specific to this codebase that have already cost real time — Flutter Web rendering and viewport, Codex prompting, verifying a running backend, package-qualified assets, and how to tell a tooling artefact from a real defect. Read before debugging anything that "looks broken but the code is right", before dispatching Codex, and before concluding a screenshot shows a layout bug.
---

# Traps already paid for

Every entry cost real time at least once. Ordered by how likely it is to
recur.

## A screenshot that looks clipped is usually not a layout bug

**Cost: four misdiagnoses.** Content appeared cut off at the right edge; twice
the layout was "fixed" and nothing changed.

Headless Chrome's `--window-size` is not the CSS viewport. It crops the page
rather than laying it out at that width. `--force-device-scale-factor=3` with
`--window-size=390,844` compounds it.

**Use Playwright** — `browser_resize(390, 844)` then `browser_take_screenshot`
with `scale: "device"`. That sets a real viewport.

**Settle it with the probe, not the eye.**
`client/test/features/today_viewport_test.dart` walks the render tree across
every state and fails on any box wider than the viewport, naming the widget and
its width. It has found six real overflows and cleared four false alarms.

When the same symptom gets explained away twice, stop explaining and build the
instrument.

## `flutter test` has no fonts

`toImage()` in a widget test renders every glyph as a filled box. Useful for
geometry and colour; useless for typography, and misleading as evidence.

Only a browser render with the bundled fonts is evidence about type. A
`FontLoader` given an unresolved `Future` hangs the harness rather than failing
— read the bytes synchronously first if you must load fonts in a test.

## Assets in a package need the package prefix

**Cost: 33 SVGs silently 404'd, and all 8 type roles silently fell back to a
system font.**

A bare `assets/svg/x.svg` or a bare family name resolves against the *host*
application. From a consuming app it finds nothing. Both were shipped and both
were invisible until `client` became the first real consumer.

Paths must be `packages/ds_relationship_companion/assets/…`; every `TextStyle`
needs `package:`. `check-screens.py` enforces both.

**The general lesson: a foundation package that only its own tests consume is
not proven.** The first real consumer is the test.

## A test that passes with the fix removed is not a test

Three separate versions of this went wrong in one sitting, so check the check:

**MockMvc does not perform a servlet ERROR dispatch.** A validation bug that
turns 400 into 401 in a real container is invisible to `@AutoConfigureMockMvc`
— it renders the 400 directly. The first `RequestValidationIT` passed with the
fix removed. Use `webEnvironment = RANDOM_PORT` for anything about what the
container does with a *failed* request.

**Gradle caches a green test run.** `./gradlew test --tests X` after editing
only main sources may print `BUILD SUCCESSFUL in 1s` and run nothing. Check
the timestamp on `build/test-results/test/TEST-*.xml`, or that the failure
count actually changed. `--rerun-tasks` is not always enough.

**Verify against the fix that matters.** I injected a defect into
`SecurityConfig`, saw the tests still pass, and nearly concluded they were
weak — the truth was that the `SecurityConfig` change was doing nothing and
the exception handler was the whole fix. Removing *that* failed four of five.
If injecting a defect changes nothing, the first hypothesis is that the code
you removed was not load-bearing.

## Unit tests bypass controller validation

`AuthService.register(email = " a@b.com ")` in a `@SpringBootTest` reaches the
service with the spaces intact. Over HTTP, `@field:Email` rejects it at the
controller and the service never runs. A bug "proved" by calling the service
directly may be unreachable in production — and a rule proved that way may not
be enforced where you think it is.

## Codex hangs forever reading stdin

`codex exec ... > out.txt &` in a background shell prints one line —
`Reading additional input from stdin...` — and never returns. It is waiting on
a stdin that will never close.

```bash
codex exec ... < /dev/null > out.txt 2>&1     # always redirect stdin
```

Earlier invocations in this repository worked by accident: they were written
with a heredoc, which closes stdin on its own. The failure only appears once
you stop using one.

## Codex loads a design plugin unless told not to

**Cost: two runs, 728 lines of self-loading, zero output.**

Prefix every prompt:

```
DO NOT load any skill, plugin, audit rubric or user-context.
DO NOT run scripts. Answer directly from the images.
```

`-i` is variadic and swallows a following positional prompt — put `--` before
the prompt or Codex reads stdin and exits immediately.

Codex is good at seeing what you have stopped seeing: it caught a uniformly
oversized type scale and two missing dividers. Its *coordinates* are unreliable
— it reads two images as one coordinate system, so once they diverge
vertically its offsets accumulate error. **Take the observations, verify the
numbers.**

## A healthy backend can still be the wrong build

**Cost: debugging a "missing field" that was actually a day-old process.**

`/actuator/health` returning UP says a JVM is listening, not that it is running
your code. `pkill -f bootRun` often misses it, the new process cannot bind, and
the old one keeps answering.

```bash
lsof -nP -iTCP:8082 -sTCP:LISTEN | awk 'NR>1{print $2}' | xargs ps -o lstart= -p
grep "Started BackendApplicationKt" backend.log | tail -1
```

Compare the start time to when you built. The backend is on **8082** — 8080 and
8081 belong to another project on this machine.

## Riverpod hides an error behind a reload

**Cost: three recovery states that could never appear in a running app.**

An `AsyncValue` can be loading *and* carry the error from the previous attempt.
Without `skipLoadingOnReload: true` and `skipLoadingOnRefresh: true`, a failed
refresh shows a spinner forever instead of the error state.

Offline, authorization-loss and plain-failure were written, reviewed, committed
— and unreachable.

## Extracting a widget is a rewrite

**Cost: a hardcoded `'Morgan is present'` left behind when the header moved to
its own file**, so every recovery state claimed a partner was present while
access was unconfirmed.

Splitting a file carries the same risk as rewriting it. Render afterwards and
compare; a refactor that "changed nothing" should produce an identical image.

## Verify a guard by breaking the thing it guards

An unverified check is not a check. This repository already had a test named
`an acknowledgement with empty text is rejected` that passed for years for the
wrong reason — it never moved the occurrence into `WAITING_ACK`, so the request
was refused on state, not on content. The red line was unguarded the whole time.

For every rule in `check-screens.py` and every invariant test: inject the
defect, confirm red, restore, confirm green. Doing this caught a false positive
— the rule was flagging the switch that maps backend states to human copy,
which is the rule being satisfied.

## Shell and tooling

- Git commit messages with `·`, `—` or quotes break `git commit -m` under zsh.
  Use `git commit -F-` with a heredoc.
- `timeout` does not exist on macOS. Use `perl -e 'alarm N; exec @ARGV' cmd`.
- `dart format` rewraps code, so a `python3` string replacement written against
  the pre-format text will silently not match. Re-read the file after
  formatting, or match on a smaller unique fragment.
- Playwright MCP writes only under its own temp root and the old project path;
  save there and copy into the repository.
