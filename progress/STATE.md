# Where the project stands

Written 2026-08-29. **Read this first in a new session**, then
`progress/plan.md` for sequencing and `progress/roadmap.md` for why the order
is what it is.

## One-line summary

Backend and data layer are complete and tested; the design system is frozen and
proven; one screen of thirty-five is built, wired to the server, and accepted
by the owner. The bottleneck is screen-gate approval, not engineering.

## Working directory

`/Users/li/code/app/dsapp-gh` — the only one. The old local repository was
deleted on 2026-08-29 after verifying every source file matched byte for byte;
its history is preserved at `/Users/li/code/app/dsapp-legacy-history.bundle`
(79MB, verified complete).

One branch: `main`. One remote: `git@github.com:jondaiwei-beep/ds-relationship-companion.git`.

## Layers

| Layer | State |
|---|---|
| `backend/` | Kotlin, 189 tests. Full loop runs end to end. Port **8082**. |
| `client/lib/domain_client/` | 12 repositories, all Core Beta surfaces. |
| `app/` | Frozen design system: 33 SVGs, B-2 tokens, B-4 grain, 8 type roles, 2 themes. 26 tests. |
| `client/lib/features/today/` | `SCR-01`, built and wired. |
| `client/lib/app/` + `platform/session/` | App shell: router, auth guard, session lifecycle. 70 client tests. |
| Everything else | 34 screens, gates closed. |

## What is verified, and how

- **`SCR-01` renders within 4dp of its approved design** at 390 × 844, all
  seven states, captured through a browser with the bundled fonts. Evidence in
  `design/qa/implementation/SCR-01/`.
- **The four actions reach the server.** Complete, Discuss, New Time, Can't Do,
  each idempotent per attempt, verified by removing the key cache and confirming
  the test fails.
- **19 behavioural invariants** hold as tests, restored from
  `product/ui-invariants.md` after the pre-redesign UI was deleted.
- **An Android package was accepted by the owner** on device: 18MB arm64, neutral
  identity (`app.companion.two`, label `Companion`), all assets bundled.
- **The auth guard holds in a real browser**, not only in tests: a deep link to
  `/dynamics/abc/today` while signed out goes
  `→ /holding?returnTo=… → /sign-in?returnTo=/dynamics/abc/today`, issuing no
  read for relationship data on the way. `/invite/:token` stays put.

## Open blockers

**Approval** — nine of the eleven screens in the vertical slice are
`candidate_for_approval`. The design exists; the gate needs the product and
design owner. Never change a gate yourself.

**Staging serves a stale build** — `ops/deploy-ds.sh` cloned the abandoned
`JonDai/dsapp`. Fixed in the script, with a guard that repoints an existing
checkout's remote, but **the server has not been redeployed yet**: as of
2026-08-29 `/v1/auth/register` answers 401 there while the current source
marks it `permitAll`. Password registration does not exist on the deployed
build. Redeploy before any real-device acceptance.

**FCM credentials** — Android Push, owner-supplied.

**Two proposed tokens** — `display.expectation` 28/31 and `body.support` 12/17,
both currently inline overrides. See `design/tokens/PROPOSED-B3.md`.

## Next, in order

The plan is `progress/MASTER-PLAN.md`; decisions are in `product/decisions/`.

1. **Redeploy staging** so it serves the current source.
2. **Promote the bottom navigation** into a shared component. It is the only one
   whose second use is a fact: eight screens reference the nav assets. The other
   eleven components have a reuse count of one; promoting them now would be
   guessing at an API from a single example.
3. **SCR-04/05/06** — entrance, sign in, create account. The guard already
   routes to `/sign-in`; nothing is reachable until that screen exists. Their
   state families need designing first.

Build order and its reasoning: `product/decisions/d2-build-order.md`. Note
that activation is split around consent — role, structure and rhythm come
*after* mutual consent, not before, or the product configures a shared
Dynamic for someone who has not agreed to it.

## Working agreements

- Rendered evidence beside every screen, or it is not done.
- A screen is not done until its invariants exist as tests.
- No raw hex, no ad-hoc spacing, no parallel token layer —
  `npm run foundation:check` enforces this and covers 15 files.
- The design image is the specification; the JSON contract says what must be
  true, the image says what it looks like, and the image is read first.
- Promote a component when a second screen needs it, not before.

## Commands

```bash
npm run foundation:check                      # generators, drift, design rules
cd client && flutter test && flutter analyze  # 44 tests
cd app && flutter test                        # 26 tests
cd backend && ./gradlew test                  # 189 tests, needs JDK 21
python3 tool/qa/compare-scr01.py              # render vs design
```

JDK 21 is at `/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home`
and is not the default JVM.
