# SCR-02 — Completion and Waiting · Revision 3

Status: `candidate_for_approval`. The gate in `manifests/screen-index.json`
is unchanged.

## Why the three are rendered together

`design/screens/SCR-02-task-completion/candidates/rev-3/render-loop.cjs`
renders all three. They are one moment seen three times — something was
completed, someone responded, the response arrived — and the visual thread
that carries it (the emblem, the descending line, Terracotta reserved for
what a human said) has to hold across all three or the loop stops reading as
a loop.

## What this resolves

The state matrices in all three `screen.md` files were entirely `TBD`.
Behaviour is now specified in
`product/decisions/core-loop-state-family.md` and rendered here.

The states that were missing are the conflict ones, and they turn out to be
the interesting half: an occurrence completed on another device, a response
already sent, an occurrence no longer waiting. All three answer 409 —
measured against a running server, not inferred — and **none of them is a
failure**. Showing them as errors would make ordinary two-device life look
like something went wrong.

## Two behaviours changed in the backend to make these states real

- A **wordless acknowledgement** now works. `REQ-ACK-001` puts basic
  acknowledgement at two taps and the API had required non-empty text, so the
  most common response in the product was unreachable.
- A **private note** is now readable by its author. It was stored and selected
  by nothing, so "PRIVATE NOTE · ONLY YOU" was true about the partner and
  false about the person who wrote it.

## Build rule

Claude Code may inspect this candidate but must not implement SCR-02 until the
product and design owner approves it and the build gate becomes
`ready_for_build`.
