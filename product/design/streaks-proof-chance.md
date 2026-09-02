# Streaks, proof and chance — better, and simpler

Owner direction 2026-09-02: build all three, beat them on experience, and
make the product *simpler* rather than more complex.

Those last two pull against each other, so the whole design is about where
each feature lives. The naive version of all three adds a counter, a camera
flow and a dice screen — three new surfaces, and an app that feels like an
admin console.

## What makes theirs complex

Look at where they put things:

- **Kneel** makes `Verify` a third sub-tab beside Rewards and Punish. Proof
  is a *destination* you visit.
- **Obedience** makes `Proof` and `Randomize` two separate collapsible
  sections inside the punishment editor — the form has five sections before
  you have written anything.
- Both show **BALANCE and STREAK as two counters side by side**, so the
  screen opens with two numbers competing for the same glance.

Every one of those is a feature given its own real estate. That is what makes
an app feel complicated: not the number of capabilities, but the number of
places you have to go.

**Our rule: no new screen, no new tab, no new section.** All three features
attach to something that already exists.

---

## 1. Streaks — the number that cannot punish you

### What theirs does

Kneel: `STREAK — 0 consecutive days` beside the balance. Obedience: a row of
~19 `× × × ×` marks across the habit card. Both are the standard mechanic,
and the standard mechanic has a documented failure: breaking one causes
all-at-once abandonment rather than gradual decline, because the "zero"
triggers a *what the hell* response.

### What ours does

Same motivating idea — **you are keeping this up, and it is visible** —
without the cliff:

**A streak that never resets to zero.** It counts days you showed up. A gap
does not destroy it; it just does not add to it.

```
   Theirs                          Ours
   STREAK  12                      12 days together
   (miss one)                      (miss one)
   STREAK  0    ← everything gone  12 days together  ← nothing lost
```

The number is a **count of what happened**, not a fragile object you are
carrying. That is not a softer streak; it is a different quantity — the honest
one. Nobody's twelve days stopped having happened because Tuesday was bad.

**Why this is better, not just safer:** the standard streak's whole value is
"don't break it", which means its value goes to zero the moment you do — and
so does the user. A count that only accumulates keeps motivating on day 40
after a bad week, which is exactly when a couple needs the app most.

Placement: **one line on the existing points page**, under the balance. No
second counter competing for the glance.

---

## 2. Proof — the photo that is a gift, not evidence

### What theirs does

Obedience: a `Proof` field on a punishment, defaulting to Disabled, and it is
a **camera**. Kneel: a whole `Verify` sub-tab, and "proof-based ideas" in its
content. The framing is auditing — the submissive supplies evidence, the
dominant checks it.

### What ours does

Same capability — **a photo attached to a completion** — with the framing
inverted:

- It attaches to a **completion**, not to a punishment. You show what you did
  because you want it seen, not because you are proving you are not lying.
- It is **always optional and always the person's own choice**. There is no
  "proof required" toggle on the giving side, because a required photo makes
  the relationship an audit.
- It appears in the response flow the dominant already uses, as part of
  *seeing* the completion.

**Why this is better:** their version answers "did you really?" Ours answers
"look what I did." The second is the thing people actually want to send, and
it costs the same photo. An audit is also a worse product: the moment proof
is required, the sub is doing it for the camera, and the dominant is doing
inspection instead of attention.

Placement: **one camera control on the completion sheet that already exists.**
No new screen, no `Verify` tab.

---

## 3. Chance — one dice, on the thing it applies to

### What theirs does

Obedience: `Randomize — "add multiple punishments and let fate decide"`, a
collapsible section in the punishment editor.

The appeal is real and I underrated it before: **not knowing is part of the
play.** Anticipation is the content. That is not an abdication when the couple
chose to be surprised — it is a choice to be surprised, which is different
from a machine deciding *whether* there is a consequence.

### What ours does

**The distinction that keeps this safe and makes it better:**

| | Machine decides | Chance decides |
|---|---|---|
| **whether** anything happens | never — a person always chooses | — |
| **which** of several, once chosen | — | yes, if they want the surprise |

So: a person still presses "Hold to it". *Then*, if the couple set up more
than one agreed consequence, the app can pick which one — and the reveal is
the fun part.

**Why this is better:** Obedience's randomiser is a settings field you
configure in a form. Ours is one tap at the moment of the decision, when the
anticipation is live. Same mechanic, better staging — and it never removes
the human from the only decision that matters.

Placement: **one extra door on the consequence panel that already exists** —
"Hold to it" gains a sibling, "Let chance decide". No new surface.

---

## What this adds, in total

- One line on the points page (streak).
- One camera button on a sheet that exists (proof).
- One door on a panel that exists (chance).

**No new screen. No new tab. No new form section.** Three capabilities the
competitors have, added to surfaces the person already visits.

## What we still will not do

- **No streak that resets to zero.** The mechanic works by fear of loss and
  its documented effect is abandonment.
- **No required proof.** Optional is the whole difference between a gift and
  an audit.
- **No chance deciding whether.** Only which, and only after a person chose.
