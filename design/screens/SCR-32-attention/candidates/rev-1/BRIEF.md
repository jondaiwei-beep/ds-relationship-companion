# SCR-32 "Attention" — design this screen

The only screen in the Core Beta loop with **no design at all**. Every other
screen it connects to exists; this is the hole in the middle of the product.

## What the product is

A private companion for two consenting adults in a D/s relationship. The core
loop is: `Expectation → Action → Human Response → Continue / Adjust`.

Governing law: **"Automation prepares; the partner responds."** The system may
suggest, sort, remind and prepare. It must never impersonate the partner,
automate praise, automate punishment, or decide consent.

## What this screen is

**Attention is the direction-giving member's daily surface.** Today (image 1)
is what the receiving member sees — "what is being asked of me". Attention is
its counterpart — "what is waiting for a real answer from me".

Job to be done: *see what requires a real human response, and clear
meaningful work with minimal mental load.*

The screen contract is explicit that this is **not** Today's shape:

> This is an operational authority surface, not the same centered ritual
> structure as Today. Use a disciplined vertical queue with Terracotta
> reserved for human relational urgency/response.

So: Today is centred, ceremonial, one thing at a time. Attention is a
**list** — scannable, ordered, several items visible at once. Same world,
different posture.

## The four reference images

- **image 1 — SCR-01 Today.** The receiving side. Note the ritual centring,
  the emblem, the descending thread, the bottom navigation.
- **image 2 — SCR-33 Acknowledgement Composer.** *This is where Attention
  leads.* Tapping an item that is waiting for a response opens this sheet.
  Note the four response icons and the compact bottom-sheet posture.
- **image 3 — SCR-02 Completion.** What the other person saw when they
  completed. The two-node progress line: COMPLETED ●———○ WAITING FOR MORGAN.
- **image 4 — SCR-03 Acknowledgement received.** The payoff, back on the
  receiving side. Partner's words in Terracotta Cormorant.

Attention must look like it belongs beside these four and unmistakably like a
different *kind* of screen from them.

## Real data — this is what the server actually returns

`GET /v1/dynamics/{id}/attention` returns `items[]`, `needsResponseCount`,
`needsReviewCount`. Each item has: `title`, `state`, `actorDisplayName`,
`occurredAt`, `priority`.

The server already sorts, in this exact order (verified in SQL):

| priority | states | what it means to the person |
|---|---|---|
| 1 | `NEED_TO_DISCUSS`, `RESCHEDULE_REQUESTED`, `EXCUSE_REQUESTED` | Your partner asked you something and is waiting |
| 2 | `WAITING_ACK` | They completed something; nobody has responded yet |
| 3 | `NEEDS_REVIEW` | Past due, still open |

**The client must render server order and never re-sort.** Priority is a
server fact.

Use these realistic contents:

```
1  NEED_TO_DISCUSS       "Evening ritual"        Morgan · asked to discuss · 2h ago
2  RESCHEDULE_REQUESTED  "Morning intention"     Morgan · asked for a new time · 4h ago
3  WAITING_ACK           "One honest sentence"   Morgan completed · 9:14 PM
4  WAITING_ACK           "Prepare the evening"   Morgan completed · yesterday
5  NEEDS_REVIEW          "Daily check-in"        open since Tuesday
```

## Hard product rules that shape the design

1. **Basic acknowledgement is at most two taps** (`REQ-ACK-001`). From this
   screen, responding to a WAITING_ACK item should be fast. Inline response
   affordances are explicitly allowed: "common responses work inline".
2. **Only an explicit human Send creates an acknowledgement** (red line #1).
   Nothing here may send by itself. If you draw an inline action, it must be
   a deliberate press, and a wordless Acknowledge/Praise is legitimate.
3. **The system never speaks in the partner's voice** (red line #2). You may
   show what your partner wrote. You may not generate words for them, and any
   system suggestion must look system-provided.
4. **Adjustment is a normal path, not a failure** (`REQ-ADJUST-001`). Discuss,
   Request New Time and Can't Do are ordinary. **They must not be styled as
   errors, warnings or problems** — no red, no alert icons, no "overdue"
   framing.
5. **`NEEDS_REVIEW` carries no punishment** (`REQ-REVIEW-001`): "the software
   does not assign punishment or consequence". Past-due is a fact, not a
   judgement. **No scolding, no streak-breaking, no red.**
6. **No queue vocabulary.** Forbidden words: due, overdue, late, missed,
   pending, backlog, tasks. A person's day is not a work queue. This is
   enforced by an automated check on the built screen.
7. **Backend state names never reach a person.** `NEEDS_REVIEW` must be
   rendered as human copy, not as a code.
8. **A response is addressed to a person, not a task.** The server returns
   `actorDisplayName` for exactly this reason — use the name.

## Design system — these are frozen, use them exactly

Colours (do not invent any others):

```
canvas (page)          #080B07   near-black with a green bias
raised surface         #1E241F
text primary           #F4F1EB
text secondary         #E7E3DA
text muted             #BAB6AC
hairline / borders     #2F3A2E
primary button bg      #2F3A2E
primary button text    #F4F1EB
TERRACOTTA             #B5533B
```

**Terracotta is not a general accent.** It is reserved for human relational
presence, urgency and response. It may not be used for ordinary UI emphasis,
and Terracotta *text* must be at least 24px regular (below that it fails
contrast) — so small Terracotta belongs on marks, dots and lines, not on
labels.

Type:
- **Cormorant Garamond** (serif) — only for human words and ritual language.
  Weight 500.
- **Inter** — everything operational: labels, list rows, buttons, counts.
- Bottom navigation is exactly four tabs: Today · Dynamic · Explore · Us.
  Attention is *not* a tab — it is reached from Today.

Geometry: 390 × 844. 24dp side margins. 56dp primary buttons, 48dp minimum
touch target, 72dp list rows, 80dp bottom navigation.

## What to produce

**A high-fidelity PNG mockup at 390 × 844**, in the visual language of the
four references. Then, if you can, the same for these states:

- **loading** — skeleton that preserves layout, reveals no content
- **empty** — nothing is waiting. This is a *good* state, not a void. Do not
  invent urgency; do not congratulate mechanically either.
- **offline** — "You're offline"; the list may show last known state but must
  say it is not current
- **error / retry**
- **authorization loss** — remove all relationship content, offer sign-in,
  and **do not reveal what was being shown**

Also answer in text, briefly:

1. How does priority read in **seconds** without using forbidden vocabulary?
   What does the eye land on first?
2. How do you show `NEEDS_REVIEW` as a fact and not a reprimand?
3. Where exactly does the inline two-tap acknowledgement live, and how is it
   visibly a deliberate send rather than a toggle?
4. What did you deliberately leave out, and why?

Save the images into this directory. Name them
`scr32-default.png`, `scr32-loading.png`, `scr32-empty.png`,
`scr32-offline.png`, `scr32-error.png`, `scr32-auth-loss.png`.
