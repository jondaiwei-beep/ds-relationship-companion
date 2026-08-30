# SCR-14 rev-1 — occurrence detail

The first Phase 2 screen. Nothing exists for it but one reference image, and
that image contradicts the contract in three places (below).

## Why this screen matters more than its sprint position suggests

Three things converge here:

- **`REQ-REVIEW-001` has no screen anywhere in the product.** "Past-due active
  work becomes Needs Review. The software does not assign punishment or
  consequence." `NEEDS_REVIEW` is a real server state that no surface expresses.
  This is where it belongs.
- **Today rows do not navigate.** An item in an adjustment state currently shows
  "Being discussed" and offers nothing, because the only permitted action
  (`withdraw`) has no affordance. This screen is that affordance's home.
- The server already returns everything needed, including an authoritative
  `allowedActions`. **No backend work. This is purely design.**

## The reference image is wrong in three places — do not carry them forward

1. **"Add photo".** The contract says *"remove Proof"* outright. Photographic
   proof of compliance is a surveillance pattern; this product does not ask
   anyone to evidence their obedience. Drop it entirely.
2. **Only "Mark complete" is offered.** Red line: *adjustment is a normal path,
   not a failure*, and it is offered **beside** completion, never beneath it or
   behind a menu. Discuss / New time / Can't do are peers of Complete.
3. **"Morgan will be notified."** Completion is never acknowledgement
   (`REQ-COMPLETE-001`). Framing the end of the action as a notification implies
   the loop closes when the system sends something. It closes when a human
   responds, and only then.

Keep from the reference: the editorial vertical rule, the DUE eyebrow, the
Cormorant statement of the expectation itself, "Set by Morgan" as attribution,
and the INTENTION / COMPLETION / BOUNDARY structure — that last one is good and
appears nowhere else in the product.

## What the server actually sends

`GET /v1/occurrences/{id}` returns: `title`, `purpose`, `state`, `dueAt`,
`completedAt`, `partnerDisplayName`, `privateNote`, `acknowledgement`
(type/text/sentAt/senderDisplayName), and **`allowedActions`**.

`allowedActions` is authoritative and the screen must render from it, never from
its own idea of what the state permits (`REQ-STATE-001`). The server's rules:

| State | Assignee sees | Creator sees |
|---|---|---|
| `ACTIVE` | complete, discuss, reschedule, cant_do | — |
| `WAITING_ACK` | — | acknowledge, praise, comment |
| `NEED_TO_DISCUSS` / `RESCHEDULE_REQUESTED` / `EXCUSE_REQUESTED` | withdraw | continue, adjust, reschedule, excuse, cancel |
| `NEEDS_REVIEW` | complete, discuss, reschedule, cant_do | review, excuse, reschedule |

Note `withdraw` is advertised and **has no endpoint yet** — design it, and it
will be flagged as needing one.

## States to design

| State | Note |
|---|---|
| `default` | ACTIVE, assignee's view: all four actions as peers |
| `needs-review` | **`REQ-REVIEW-001`.** Past due. Never punishment, never a red alert, never a streak broken. A prompt to look, nothing more |
| `adjustment-open` | The assignee's own request is pending; `withdraw` is the only action |
| `waiting-ack` | Completed, awaiting a human response. Must not read as done |
| `loading` | Privacy-safe; no name-shaped skeletons |
| `error` | Retry without losing context |
| `offline` | No mutation without server confirmation |
| `authorization-loss` | Withhold everything; see SCR-09 rev-3 for the house treatment |

## What is frozen — do not invent it

`design/tokens/B2-FREEZE.md`, `manifests/svg-freeze.v1.json`,
`design/system/spacing.md`, `design/system/type-in-practice.md`.

**This screen's asset contract registers exactly one mark: `state.completed`.**
Do not use any other. If a state needs a mark it does not have, say so — that is
an asset-contract change, not something to assume.

On type: `display.partner` is an authorship test (only words a person wrote and
sent — the expectation's title is written by the creator, so it qualifies for
Cormorant via `display.ritual`, not `display.partner`). `title.page` is Inter.

## Red lines

Completion is never acknowledgement. Adjustment sits beside completion. The
system never speaks in the partner's voice. No points, streaks, scores or
trophies. Past-due is never punishment. A failure is recoverable, never a dead
end.

## Reference images (attached, 390 wide)

1. `scr14-reference` — the original, with the three faults above
2. `scr02-completion` — the approved "completed, waiting for a human" screen
3. `scr01-today` — the built screen this one opens from
4. `scr33-composer` — the approved responder side

## Deliverable

Composition, hierarchy, exact copy, and the frozen token or mark per element,
for each state. Two directions for `needs-review` — it is the one with no
precedent anywhere in the product, and the one where getting the tone wrong
turns the product into a compliance tracker.
