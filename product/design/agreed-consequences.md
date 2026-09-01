# Agreed consequences — design

Status: **proposal for review.** Written 2026-09-01. No code written yet.

## The gap

Every competitor answers the question "what happens when it doesn't get
done?" Obedience has a Punishments tab. Kneel has a Consequences tab with
Rewards / Punish / Verify. BeMoreKinky's Habits is "protocol tracker for
service with rewards, points and discipline."

We answer it with **silence**. A past-due occurrence becomes `NEEDS_REVIEW`
and stops there. Nothing is shown to either person beyond a "look back"
section, and nothing follows.

Silence is not neutrality. To a couple who chose this app *because* they want
structure, an agreement that nothing happens to is an agreement that did not
matter. That is the single largest hole in the product relative to the
category, and unlike points it is a hole we can fill without breaking
anything we believe.

## The constraint that shapes everything

`REQ-REVIEW-001`: "Past-due active work becomes Needs Review. **The software
does not assign punishment or consequence.**"

Read the object of that sentence carefully. What is forbidden is *the
software* assigning. The couple assigning, in advance, and one of them
issuing it, is a different actor entirely — and it is the actor the whole
product is built around ("Automation prepares; the partner responds").

So the design rule is:

> **The app may hold the agreement and remind them of it. Only a person may
> invoke it. Nothing happens on a timer.**

Everything below follows from that one line.

## The model

### `agreements` — what the couple decided in advance

A short list, written by both, visible to both. Each entry is plain text plus
who it applies to.

```
id, dynamic_id, author_user_id, applies_to_user_id,
label            "Missed evening tasks"
consequence      "Early bedtime, one hour"
created_at, updated_at
```

Authorship rules, matching `boundaries`:

- Either member may **propose** one.
- It becomes active only when **both** have agreed — unlike a boundary, which
  is unilateral by design, an agreement binds someone else and so cannot be
  written *onto* them. This is the inverse of the boundaries rule and for the
  same reason: red line #4.
- Either member may **end** one at any time, alone, without the other's
  consent. Ending is not a negotiation. An agreement you can't leave is not
  an agreement.

### `consequence_events` — what was actually invoked

```
id, dynamic_id, agreement_id, occurrence_id (nullable),
issued_by_user_id       always a real user; never null, never "system"
outcome                 ISSUED | WAIVED
note                    optional, from the issuer
created_at
```

`issued_by_user_id` being non-null is the schema-level guarantee that the
software never does this. There is no code path that writes this row without
a user id, and that is deliberate: it makes the red line unbreakable by a
future bug rather than merely by convention.

## The flow

```
An occurrence passes its due boundary
        │
        ▼
  NEEDS_REVIEW                          ← unchanged, exactly as today
        │
        │  (nothing has happened yet. No notification of failure.
        │   No counter. No state that means "missed".)
        ▼
The person who set it opens Attention, sees it under "Look back",
and — only if the couple has an agreement covering it — also sees:

    ┌────────────────────────────────────────────┐
    │ You agreed:                                │
    │ "Missed evening tasks → early bedtime,     │
    │  one hour"                                 │
    │                                            │
    │  [ Hold to it ]   [ Let it go ]   [ Talk ] │
    └────────────────────────────────────────────┘
        │              │              │
        ▼              ▼              ▼
     ISSUED         WAIVED      opens the existing
                                adjustment path
```

Three properties of that panel that are not negotiable:

1. **It is a reminder of their own words, not a verdict.** The text shown is
   what they wrote. The app adds nothing.
2. **No default and no timeout.** If the Dom never opens it, nothing happens,
   forever. There is no "auto-issue after 24h" and there never will be.
3. **"Let it go" is a first-class, equal-weight action** — same visual weight
   as "Hold to it", not a small escape hatch. Waiving is a decision a person
   in authority makes, not a failure to act.

## What the other person sees

Both outcomes are shown, and both are attributed:

- Issued: "**Alex held you to it.** Early bedtime, one hour."
- Waived: "**Alex let this one go.**"

The waive is shown *deliberately*. In a D/s dynamic, being let off is
something the dominant did — it carries meaning, and hiding it would waste
the most humane moment the feature produces. It is also the honest reason
this feature is not a punishment machine: the machine has no way to be
merciful, and this does.

## Red lines, checked one by one

| Line | How this respects it |
|---|---|
| #1 system never speaks in the partner's voice | The panel quotes the couple's own written agreement, attributed to them. Every event names its human issuer. |
| #3 adjustment is normal, not failure | "Talk" sits beside the other two and opens the existing adjustment path. Nothing is recorded as a miss. `NEEDS_REVIEW` keeps its current meaning. |
| #4 agency no role can remove | Agreements need both to create; either can end alone. |
| Non-goal: automatic punishment | Nothing fires on a timer. `issued_by_user_id` is NOT NULL. |
| Non-goal: compliance scoring | Nothing counts. No totals, no history view of "how many times". See below. |
| `REQ-REVIEW-001` | The software still assigns nothing. It shows the couple what they wrote. |

## What this deliberately does NOT have

- **No count.** Not "3 consequences this month", not anywhere. The moment
  this feature can be tallied it becomes a compliance score.
- **No severity, tier or escalation.** No "third strike". Escalation is a
  scoring system with a narrative.
- **No automatic anything.** No timer, no default, no reminder that nags.
- **No proof.** Kneel has `Verify`; we do not. Our answer to "how do you know
  it happened" stays the human response, and this feature does not smuggle in
  evidence-checking through a side door.
- **No history surface of its own.** Events appear in Us as ordinary moments
  and are not aggregated.

## Why this beats the competitor's version

Their punishment systems are cheap to build and expensive to live with —
their own writing says vague punishment "breeds resentment" and bad
punishment makes "the sub resent the dynamic entirely", and prescribes
proportionality, communication, and a system both partners trust.

This design *is* those three things: proportionality (the couple set it),
communication (they wrote it together, and Talk is always there), trust (it
cannot fire without a person). And it keeps the one move an automatic system
structurally cannot make — **mercy** — and makes it visible.

The claim becomes: *their app punishes you automatically; ours makes sure a
person decided, and lets them decide not to.*

## Cost

- One migration (two tables), one service, one controller.
- One panel on the existing Attention "Look back" rows.
- One settings surface to write agreements, reusing the boundaries screen
  shape almost exactly.
- Roughly the same size as boundaries lite, which took about half a day.

## Open question for the owner

**Does an agreement need both people to accept it, or may the person giving
direction set it alone?**

I have designed it as needing both, because an agreement written onto someone
is not an agreement and red line #4 is the strictest thing in the product.
But a real objection exists: for some couples the dominant setting the terms
*is* the dynamic, and requiring mutual acceptance may read as the app not
understanding them.

I would rather ship mutual-acceptance and be told it is too cautious than
ship the other and have built a tool for writing rules onto someone.
