# Points that carry authority and warmth

Design for the client surfaces. Owner brief 2026-09-02: *more authority and
more warmth than the three competitors.*

## The two words pull against each other, and that is the design

**Authority** wants the dominant's decisions to feel weighted, deliberate,
and consequential. **Warmth** wants the submissive to feel held rather than
audited. Most products pick one: Obedience picks authority and reads like a
disciplinary record; a generic couples app picks warmth and has no structure
at all.

The resolution is not to average them. It is to notice **they fail in the same
place** — when a *machine* holds the authority. A number that judges you has
authority nobody chose and no warmth at all. Take the machine out of the
judging seat and both words get satisfied by the same move: **every
consequential act is visibly a person's decision, and every person's decision
is visible as an act of attention.**

## What the competitors actually got wrong

Not "they use points". Three specific, fixable things:

### 1. The balance can go negative — Obedience showed **♥ -152**

Read what that says to the person who opens it: *you are 152 in the hole.* No
reward is reachable. The only available move is climbing out of a debt. And
the unit is a **heart** — the app is telling someone their affection account
is overdrawn.

Debt is the opposite of both briefs. It has no authority (nobody decided it;
it accumulated) and no warmth (it is a dunning notice).

**Our rule: the balance never goes below zero.** Deductions clamp at zero.
A consequence can cost points that don't exist — it just costs what is there.
Nobody is ever in the hole with their partner.

### 2. Punishment is a form, filled in alone, with a `Proof` camera field

Obedience's punishment editor has: name, description, images, **Proof
(camera)**, and **Randomize — "let fate decide"**. Whatever else that is, it
is not authority: *fate* decides, and a photo proves it. Delegating the
decision to a dice roll is the abdication of the thing the dominant is
supposedly holding.

**Our rule: no randomiser, no proof field, and the issuing screen shows a
person's name.** Authority means someone chose. If a die chose, nobody did.

### 3. Nothing is ever given warmly — only earned, spent, or lost

Across all three, every positive movement is transactional: complete → earn →
spend. There is no path for a dominant to simply *give* something because
they noticed. The reward economy crowds out the gift.

**Our rule: giving is a first-class action, and it is the warmest thing in
the product.** See "The gift" below.

## The five design moves

### Move 1 — The balance is never a verdict on a person

The number is shown as **what is available**, never as a score.

```
Obedience:                    Ours:
   ♥  -152                       3 points to spend
   (a judgement)                 (an inventory)
```

Concretely:
- Floors at zero, always.
- Labelled by what it enables ("to spend"), never "earned" or "score".
- Never shown next to a person's name or avatar. A number beside a face is a
  rating of that face.
- No totals, no lifetime, no "this month". A running total is a report card.

### Move 2 — Every entry says who, and why, in a human sentence

The ledger is not `+1 COMPLETION`. It is written as something that happened
between two people:

```
   Alex noticed          Prepare the evening space          +1
   Alex gave you 5       "good week"                        +5
   You took             Massage                             −3
   Alex held you to it   Early bedtime, one hour             −2
   Alex let it go        Early bedtime, one hour              ·
```

Note the last row. **A waived consequence appears in the ledger with no
number at all** — a dot, not a zero. It is the only row that costs nothing
and it is deliberately the most visible thing in the list, because it is the
moment where authority and warmth are the same act.

The automatic completion award is phrased "Alex noticed" rather than "you
earned", because the points were configured by Alex in advance. It is still
attributable to a person, just an earlier decision by that person.

### Move 3 — The gift: giving without a reason, and without a ledger

A dominant can give a reward directly — no cost, no balance check, no
deduction. It lands as:

> **Alex gave you this.** *Massage*
> — no points involved

This is the single feature none of the three competitors have, and it is the
answer to "warmer". In their model the sub must earn everything; the dom is
reduced to an accountant enforcing a price list. A gift is authority in its
most generous form: *I can give you this because I decided to.*

Implementation: `redeem` already handles a zero-cost reward via
`reward_redemptions`. Giving is the same write, initiated by the other person.

### Move 4 — The consequence panel is a quote, three doors, and no default

When something is past due and an agreement covers it, the person who set it
sees:

```
   ┌──────────────────────────────────────────┐
   │  YOU BOTH AGREED                         │
   │                                          │
   │  "Missed evening tasks →                 │
   │   early bedtime, one hour"               │
   │                                          │
   │  ┌────────────┐ ┌────────────┐ ┌───────┐ │
   │  │ Hold to it │ │ Let it go  │ │ Talk  │ │
   │  └────────────┘ └────────────┘ └───────┘ │
   └──────────────────────────────────────────┘
```

Non-negotiables:
- **"Let it go" has identical visual weight to "Hold to it".** Not a text
  link, not smaller, not grey. Mercy is not the escape hatch; it is one of
  two equal exercises of authority.
- **No timer, no default, no nag.** If they never open it, nothing happens,
  forever.
- The quoted text is the couple's own words. The app adds nothing to it.
- Nothing anywhere counts how many times either door was used.

### Move 5 — What the receiving partner sees is attribution, never a status

Every one of these events reaches the other person as a sentence with a name
in it, in the Us timeline, alongside ordinary moments:

- "Alex held you to it."
- "**Alex let this one go.**"
- "Alex gave you a massage."

Never: "Consequence applied." "Penalty: -2." "Status: punished."

The difference between those two columns is the entire product.

## What we will not build, and why it is not caution

- **No negative balance.** See above.
- **No streak counter.** A gap in it would feel like a loss; that is the test.
- **No lifetime totals, no leaderboard, no per-month stats.** The moment this
  is tallied it is a compliance score.
- **No randomiser.** Fate deciding is authority nobody exercised.
- **No proof/photo field.** Our answer to "did it happen" is the human
  response, and it stays that.
- **No automatic consequence.** Enforced in the schema, not by convention.

## What this makes true

A person using Obedience sees a heart with −152 beside it and a punishment
that a dice roll picked.

A person using ours sees *3 points to spend*, a list of things that read
"Alex noticed", a partner who can simply give them something, and — on the
day they miss — a screen where their partner had to choose, and could have
chosen mercy, and it says which.

That is more authority (a person decided, every time, and it is signed) and
more warmth (they could always have decided otherwise, and giving needs no
reason) than any of the three.
