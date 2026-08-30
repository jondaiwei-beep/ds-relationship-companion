# SCR-32 — Attention · Revision 1

Status: `candidate_for_approval`. The gate in `manifests/screen-index.json`
is unchanged.

This was the only Core Beta screen with **no design at all** — the hole in
the middle of the loop, since it is the surface the acknowledgement composer
is reached from.

## Where the composition came from

Codex, briefed with the four surrounding screens (SCR-01 Today, SCR-33
Composer, SCR-02 Completion, SCR-03 Received), the real server response, the
frozen palette, and the product rules that constrain this screen. The brief
is `design/screens/SCR-32-attention/candidates/rev-1/BRIEF.md`.

Its structural decisions, kept:

- **Three sections, in server order** — "Morgan is waiting" (the partner
  asked something), "Completions to answer", "Look back together".
- **A Terracotta rail** down the partner's direct requests. The eye lands
  there first, which is correct: someone is waiting on a reply.
- **"Look back together"** for `NEEDS_REVIEW`, with "Open since Tuesday" as a
  plain fact. `REQ-REVIEW-001` forbids the software assigning consequence,
  and this is the phrasing that carries none.
- **Inline send** on the first completion. Two taps: choose, then send.
- **Empty is "The space is clear."** — not a void, and not mechanical
  congratulation.

## What changed porting it into the repository

| # | Problem | Fix |
|---|---|---|
| 1 | Every icon was drawn as inline path data | Registered marks from the SVG freeze. Screens reference Asset IDs; the renderer now throws on an unlicensed size or tone, which caught `mark.guidance` being asked for `muted` |
| 2 | "Send acknowledgement" overflowed its 142px button | "Acknowledge" / "Praise" at 152px and 150px |
| 3 | "Server order is preserved" printed on the screen | Removed. That is a note to a developer, not something a person reads |
| 4 | Summary read "2 responses · 1 review" | "4 awaiting your answer · 1 to revisit". `needsResponseCount` was fixed the same day to include the partner's requests — it counted only completions, so it would have said 2 while four things waited |
| 5 | Colours transcribed as literals | Resolved through `design-tokens.json`, so a token change reaches this screen |

## Rules Codex held without being caught out

Checked mechanically against the generator, not by eye: no forbidden queue
vocabulary (due, overdue, late, missed, pending, backlog, tasks), no colour
outside the frozen palette, no backend state name rendered to a person, no
Terracotta below the 24px text floor.

## Build rule

Claude Code may inspect this candidate but must not implement SCR-32 until
the product and design owner approves it and the gate becomes
`ready_for_build`. Revision must also increment to 1 in the screen index —
that is the owner's edit, not this file's.
