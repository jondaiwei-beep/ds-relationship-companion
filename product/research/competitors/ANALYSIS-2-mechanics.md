# Points, punishment, streaks: a mechanism-level analysis

Written 2026-09-01. Supersedes the reasoning (not the file) of
`ANALYSIS.md` on these three features.

## Correction to the previous analysis

`ANALYSIS.md` rested its recommendation on two SubTasks blog lines and one
App Store review. That is **anecdote, not evidence of a widespread problem**,
and the owner was right to push back on it. Every feature attracts
complaints; three quotes prove nothing, and I selected those three *because
they agreed with a position we already held*. That is confirmation bias and
it belongs in the record.

The far stronger signal in that same file is the one pointing the other way:
**Obedience holds 4.7 stars across 2,800+ ratings.** Points work for a large
number of real couples. Any plan that treats them as simply a bad idea is
arguing with the market.

This file replaces "do they complain?" with a better question:
**what does each mechanism actually do, when does it help, when does it
break, and can we get the help without the breakage?**

## Method: separate the job from the implementation

Each of the three features is a specific implementation of a job the couple
genuinely needs done. The implementation is copyable and commodity. The job
is real and permanent. So for each: name the job, name what the mechanism
does well, name its documented failure mode, then ask what else satisfies the
job.

---

## Mechanism 1 — Points

### The job it does

**"That counted."** In a D/s dynamic the receiving partner's effort has to be
*seen*, and the giving partner cannot reliably be present at the moment of
completion — different schedules, different timezones (our own named pressure
case), ordinary life. Points are a machine that acknowledges instantly, every
time, at zero cost to the Dom.

Obedience's own guidance confirms this is the design intent: doms "create
their own point system to reward good behavior and tasks completed on time,"
and subs "accumulate points and unlock special rewards curated by their dom."

### What it does well

- **Latency.** Acknowledgement is instant. Our human response can take hours.
- **Reliability.** It never forgets, never gets busy, never has a bad week.
- **Legibility.** A balance is a visible, unambiguous state.
- **Low Dom effort.** The dominant sets it up once and the system runs.

These are real advantages and we should not pretend otherwise. Our design is
**worse than points on every one of these four axes.**

### The documented failure mode

Not "users complain" — a measured psychological effect. The
**overjustification effect**: expected external rewards for an already
intrinsically motivated activity reduce intrinsic motivation, a "crowding
out" of the original interest. Applied to gamification, "the more an app
rewards you for doing something, the less you might enjoy doing it for its
own sake."

Research on gamified intimacy specifically finds it "can strip intimacy of
its spontaneity, reducing it to a transactional loop of inputs and outputs,"
and that the risk arrives when gamification "shifts from facilitating
authentic connection to creating quid pro quo scorekeeping."

The sharpest formulation found, and worth stealing as a design rule:
**"rewards should be invitations, not invoices."**

### The honest reading

Points are not bad. They are a **trade**: instant reliable acknowledgement,
paid for with the risk that service becomes transactional. For many couples
that trade is worth it — 2,800 ratings' worth. The overjustification risk is
probabilistic and gradual, which is exactly why it does not show up in app
store reviews: someone whose dynamic slowly became transactional does not
write a one-star review, they quietly stop.

**This means review data structurally cannot settle this question.** Neither
can our intuition. Which is why the answer below is a measurement plan, not
an assertion.

---

## Mechanism 2 — Punishment

### The job it does

**"The structure is real."** An agreement with no consequence for breaking it
is a suggestion. Consequence is what makes a rule feel load-bearing, and
Kneel's own copy frames it exactly that way: consequences demonstrate "that
the structure matters."

**We currently have no answer to this job at all.** That is our largest
genuine gap — larger than points, because at least on acknowledgement we have
*an* answer (the human response), whereas here we have silence, and silence
reads as "nothing here matters."

### What it does well

- Makes agreements feel weighted rather than decorative.
- Gives the receiving partner certainty about where they stand.
- For many couples, punishment is **the erotic content itself**, not an
  administrative penalty. Corner time, writing lines and early bedtime are
  play, not HR.

That last point is one I underweighted before. For a large part of this
audience, "punishment" is not a compliance mechanism at all — **it is the
thing they came for.**

### The failure mode

Their own writing: "bad punishments just hurt, or worse, they make the sub
resent the dynamic entirely," and "vague punishments breed resentment." The
named remedies are proportionality, communication, and a system both partners
trust.

Note what that list *is*: it is negotiation and clarity — the things our
product is already built around, and the things the category is independently
criticised for being unable to provide (apps "cannot negotiate on a person's
behalf, read non-verbal cues, notice hesitation").

### The distinction that matters

Our non-goal says **automatic** punishment. It does not say consequence.

| | Automatic punishment | Agreed, human-issued consequence |
|---|---|---|
| Who decides | the system, on a missed deadline | the couple, in advance |
| Who issues | the system | the person giving direction |
| On a bad day | fires anyway | can be waived, and waiving is visible |
| Our red lines | violates #3 and the non-goal | compatible with both |
| Erotic content | yes | yes — same content |

**The whole of what this audience wants from punishment survives the second
column.** What does not survive is the machine deciding. That is a boundary
we can hold while still shipping the feature people actually want.

---

## Mechanism 3 — Streaks

### The job it does

**"We are keeping this up."** A sense that the dynamic has continuity and
that the effort is accumulating into something.

### What it does well

Streaks are the most effective retention mechanic in consumer software. They
work by loss aversion and identity attachment.

### The failure mode — and this one is measured, not anecdotal

This is the feature where the evidence is strongest and most one-sided:

- When a streak breaks, "users lose both the streak and the habit, which is
  why quitting often happens all at once rather than gradually."
- People who broke a weight-loss streak were **47% more likely to binge
  afterward** than those who never tracked a streak — the "zero" triggers a
  "what the hell" abandonment response.
- "The streak shifts from being a motivator to being a source of anxiety, and
  the learner continues not out of joy, but out of fear of loss."

Now map that onto this product. A broken streak in Duolingo costs you
Spanish. **A broken streak in a D/s app tells a submissive partner they have
failed their dynamic** — and the mechanic's own documented effect is
all-at-once abandonment.

Our red line #3 says adjustment is normal, not failure. A streak counter is a
machine whose entire motive force is *making a gap feel like failure*. These
are not merely in tension; they are opposites.

### Conclusion on streaks

This is the one of the three where I think the answer is clear-cut and I
would argue against it even if a competitor showed it doubled retention.
**Not because streaks don't work — because they work by a mechanism this
product exists to refuse.**

Note, though: BeMoreKinky's Sensate Focus counts a "Day streak" and Kneel
shows "STREAK — consecutive days" on a main surface. The *job* (continuity,
accumulation) is real. We should serve it — see "progression" below —
without the loss-aversion engine.

---

## What we should build, restated

### Ranked, with the job each serves

| # | Build | Job it serves | Why this instead of the competitor's version |
|---|---|---|---|
| 1 | **Long-distance content** | presence across distance | Pure content. Our own named pressure case. Kneel ships 9 ideas here; we ship zero. |
| 2 | **Agreed consequences, human-issued** | "the structure is real" | Delivers the content this audience wants; keeps the machine out of the decision. |
| 3 | **Acknowledgement that is fast and reliable** | "that counted" | This is the real competitor to points — see below. |
| 4 | **Continuity without loss aversion** | "we're keeping this up" | Serves the streak job; refuses the streak mechanism. |
| 5 | Private journal | reflection | Three competitors ship one; well-understood; low risk. |

### On #3 — the honest competitive answer to points

Points beat us on latency, reliability, legibility and Dom effort. If we
refuse points, **we owe this audience a better answer on those four axes, not
a lecture about authenticity.** Concretely, that means:

- **Make acknowledging trivially cheap.** `REQ-ACK-001` already says basic
  acknowledgement is at most two taps and carries no words. Is that actually
  true on the device today, and is it in the notification?
- **Make the wait visible and bounded**, so a completion that hasn't been
  seen yet doesn't feel ignored.
- **Prompt the Dom.** Not "the system praises for them" — that's a red line —
  but the system may absolutely tell them there is something waiting. That's
  what our Attention surface is for.

The competitive claim then becomes: *their app tells you a number went up;
ours makes sure a person actually saw you, and quickly.* That is a claim we
can only make if the second half is true in practice, which is a build
problem, not a positioning problem.

### On #4 — what progression looks like without scoring

Undecided, and I don't want to invent it here. The candidates:

- **Accumulated history** — "you have done this 40 times" is a fact, not a
  score, and it does not reset to zero.
- **The weekly reflection we already have** (`REQ-WEEKLY-001`) shown as an
  arc over months rather than one week at a time.
- **Depth rather than length** — the ladder BeMoreKinky uses, but unlocked by
  the couple's choice rather than by a completion count.

The test for any of them: **does a gap in it feel like a loss?** If yes, it's
a streak wearing a different hat.

---

## How to measure this instead of arguing about it

The owner's real question was how to *tell*, and the honest answer is that
none of the evidence available — reviews, blogs, our own taste — can settle
it. Two things can:

**1. Ship the differentiators and watch one number.**
Our North Star is already the right instrument: **Connected Dynamic Days per
Active Couple per Week**. It counts *bilateral* events — a completion plus a
human acknowledgement. A points economy would inflate task completion while
leaving that number flat; that is precisely the failure we're worried about,
and we can see it.

**2. Ask the couples, once we have some.**
The overjustification effect is invisible in reviews because its victims
churn silently. It is visible in a question like "in the last month, did
doing these things feel more like connection or more like admin?" — asked at
week 4, not week 1.

Until we have couples on it, this stays a judgement call, and it should be
recorded as one rather than dressed up as evidence.

## Where I might be wrong

- **If punishment is largely erotic content rather than compliance
  machinery**, then our non-goal on "automatic punishment" is protecting
  against a harm that the audience mostly doesn't experience, and the cost of
  our caution is higher than I estimated.
- **If the acknowledgement latency problem is unsolvable in practice** —
  Doms just don't respond promptly — then points are not a shortcut around
  human attention, they are a *substitute for attention that was never going
  to arrive*, and refusing them makes the product worse for real couples with
  real schedules. This is the strongest argument against our position and I
  do not have data to dismiss it.
- **Embrace's existence** (non-gamified, same company as Obedience, wired
  back into Obedience's points) remains the most decision-relevant unknown in
  the whole file.
