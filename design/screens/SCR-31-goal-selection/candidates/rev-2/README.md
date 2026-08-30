# Activation wizard · SCR-31 / 07 / 08 / 12

Status: `candidate_for_approval`. Gates unchanged.

`render-activation.cjs` renders all four, because they are **one command**.
The "1 of 4" in the approved compositions is accurate rather than
decorative: nothing reaches the server until step three's Continue, which
fires `POST /v1/dynamics` and then asks for a starting rhythm.

## Why there are so few states

That asymmetry is the whole shape of the family.

| Step | States | Why |
|---|---|---|
| SCR-31, SCR-07 | choice only | Pure local choice. No loading, error or offline, because nothing is being asked of anyone yet — closing the app here leaves nothing behind, which is correct: half a Dynamic is not worth resuming |
| SCR-08 | + busy, error, offline | Its Continue is where the wizard finally speaks |
| SCR-12 | + loading, busy, error, offline, **uncertain** | The rhythm is fetched, then committed |

I had originally specified steps one to three as having no network states at
all — "the draft is client-side, so N/A". Codex caught it: the draft is
local, the **transition** is not. Recorded in
`product/decisions/activation-state-family.md`.

## Three product rules made visible

- **`REQ-ACT-001` asks the outcome before the role.** SCR-31 is step one, and
  the choice is not cosmetic: `StarterRhythmService` picks different starter
  content per outcome, so Accountability and Closer produce different
  rituals. There is a `nothing-chosen` state because this is the one answer
  the wizard cannot skip.
- **Naming a role is optional.** SCR-07 has "I'd rather not name one" as a
  full-width control, not fine print, and a `no-role-named` state showing it
  chosen. The column is nullable at every layer for the same reason: a couple
  that does not want to name it must not be blocked, and the preset is never
  an authorization level.
- **The uncertain result is its own state.** `SCR-12` may have created the
  Dynamic when the response is lost. It says "check whether it was created"
  and offers Today, rather than "try again" — which would send someone at an
  email or a setup that already exists.

## What the tone guard caught

`mark.partner-bond` licenses only `primary` and `relationship`, never
`muted`. The unselected "With a partner" circle therefore keeps its mark at
full strength and is distinguished by ring and label instead. That is the
freeze refusing to let the bond between two people be a dimmed decoration,
and it is the kind of rule that only holds because the renderer throws.

## Not covered

- **Long-distance / Together is drawn and the server cannot store it.** No
  column, no field. Either the data model gains one or the control goes.
- **Boundaries & preferences** is a row that opens a screen nobody has
  designed.
- **"Add another expectation"** is drawn; the API supports one optional
  second expectation, not an open-ended list.
- **`assigneeUserId`** is required to start a rhythm and none of the four
  screens offers a way to choose it.

## Build rule

Inspect only. These become implementable when the product and design owner
approves them and the gates become `ready_for_build`.
