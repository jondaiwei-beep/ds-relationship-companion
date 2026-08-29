# Development plan

Written 2026-08-29, after `SCR-01` shipped and the design-system defects it
exposed were fixed. Supersedes the "Next alignment work" list in
`status.md` for sequencing purposes; that file remains the record of what is
done.

## Where things actually stand

| Layer | State |
|---|---|
| Backend | 189 tests. The full loop runs end to end: register → dynamic → invite → join → expectation → complete → human acknowledgement. |
| Data layer | 12 repositories covering every Core Beta surface. Untouched by the UI rebuild. |
| Design system | Frozen and now proven by a real consumer: 33 SVG masters, B-2 tokens, B-4 grain, 8 type roles, Ritual/Living themes. 26 tests. |
| Client UI | One screen. `SCR-01` Today, built against its approved design and verified by browser render. |
| Screen gates | 1 `ready_for_build`, 29 blocked, 5 future. |

**The bottleneck is approval, not design and not engineering.** Nine of the
eleven screens in the vertical slice are `candidate_for_approval` — the visual
work exists and is waiting on a product/design decision. No amount of
engineering moves those.

## What blocks each slice screen

| Screen | Gate blocker |
|---|---|
| `SCR-31` Goal Selection | Candidate exists as a single source image; no candidates folder, no state family |
| `SCR-07` / `SCR-08` Minimal Setup | rev-2 candidates exist; state, Web adaptation and approval outstanding |
| `SCR-12` Starter Rhythm | Candidate exists; replace/edit interaction states missing |
| `SCR-09` Invite | Lifecycle states designed (3 state renders); share/copy, loading, offline, auth recovery missing |
| `SCR-10` Web Join | Trust + Expired + Auth Return designed (2 state renders); revoked/stale, loading, offline missing |
| `SCR-02` Complete → Waiting | Candidate exists; retry/current-state recovery missing, private-note visibility unapproved |
| `SCR-33` Acknowledgement Composer | rev-1 candidate; empty/retry/Web variants missing |
| `SCR-03` Acknowledgement Received | Existing reference only, no rev-2 candidate |
| `SCR-11` Mutual Consent | Existing reference only |

`SCR-01` is the only screen with a complete state family — eight states plus a
`design-qa.md` recording the acceptance criteria. **That completeness is why it
could be built.** It is the bar the others have to reach.

---

## Phase 1 · Finish SCR-01 properly

The screen renders correctly. It is not finished.

1. **Restore its invariants as tests.** `product/ui-invariants.md` lists 14 for
   Today and two-faces behaviour. The old widget tests were deleted with the old
   UI; the behaviour they guarded was not repealed. Until these exist, the
   screen can regress silently.
2. **Build the remaining seven states.** Only the default is implemented.
   Loading, empty, error/retry, offline, authorization-loss, role-variant and
   solo are all designed and approved.
3. **Wire it to the live read model.** The backend already serves
   `priorityItems`, `laterItems`, `relationshipDay`, `lastConfirmedAt`. Today
   currently renders fixtures.
4. **Verify on Android and on Flutter Web** — refresh, back, direct URL. Only
   the Web render exists.

This is the whole definition of done for one screen, executed once, so the
pattern is real rather than asserted.

## Phase 2 · Promote the shared layer

Nine components in `design/components/CONTRACTS.md` currently live inside
`today_screen.dart`. Several are needed by the next screens: the operational
row, the bottom navigation, the partner response, the section label, the
primary action.

Promote them into `client/lib/design_system/` **as they are needed by a second
screen, not before** — a component extracted from one use is a guess about the
second.

Adopt or reject the two B-3 token proposals at the same time. Both have appeared
once; the rule is that a second appearance makes them tokens.

## Phase 3 · The vertical slice, in dependency order

Each screen only when its gate opens. Order follows the product's own slice:

```
Goal → Minimal Setup → Starter Rhythm → Invite → Web Join
     → First Shared Interaction → Human Acknowledgement
```

Two screens are worth taking early once available, for reasons beyond their
position:

- **`SCR-33` Acknowledgement Composer** is where the product's central red line
  lives — only an explicit human send creates an acknowledgement. The backend
  enforces it; the UI has never expressed it.
- **`SCR-10` Web Join** is the only Flutter Web surface a non-user ever sees,
  and Web behaviour is the least exercised part of this codebase.

## Phase 4 · What remains after the slice

- Attention (`SCR-32`), the direction-giving queue — designed, not yet a
  candidate with states.
- Daily Check-in — `SCR-22` is an advanced reflection screen and the coverage
  matrix marks it for replacement, not reuse.
- Adjustment, pause/resume, leave/block state families.
- Android Push. Blocked on FCM credentials, which only the owner can supply.

---

## What I need from you, and when

| Decision | Blocks | When |
|---|---|---|
| Approve a screen's state family and open its gate | Every screen after `SCR-01` | Whenever you are ready for the next one |
| Adopt or reject the two B-3 tokens | Phase 2 | Before a second screen uses them inline |
| FCM credentials | Android Push | Any time before release |
| Confirm the three positions in `g1-g4-implemented-answers.md` | Adjustment and leave/block screens | Before Phase 4 |

Nothing here needs a decision today. `SCR-01` Phase 1 is four items of real work
that need no approval, and that is what happens next.

## How to judge whether this is going well

Not by screens shipped. By whether each screen, at the moment it is called done:

- renders within 1–2dp of its approved design at 390 × 844
- has its surface's invariants passing as tests
- has all its approved states implemented, not just the default
- works on Android and Web, including refresh, back and direct URL
- added no raw hex, no ad-hoc spacing, no parallel token layer —
  `npm run foundation:check` enforces this
