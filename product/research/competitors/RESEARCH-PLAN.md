# Competitive research plan — what to deepen next

Status: **proposal, not yet approved.** Written 2026-09-01.

Inputs available: BeMoreKinky (9 screens) and Obedience (8 screens), filed
under this directory. A third product, Kneel, is expected and has a slot
reserved but has not been captured yet.

## The problem with the obvious version of this question

"Look at the competitors, decide which features to adopt" cannot be run
straight, because of a collision that is visible on the very first pass:

Obedience's four tabs are **Rewards · Punishments · Habits · Notes**. Our
`00-overview.md` Non-goals bar **automatic punishment**, **compliance
scoring** and **mandatory streaks** outright. BeMoreKinky's Sensate Focus
counts **day streaks** and gates stages behind completed sessions;
its Habits tool is described in its own copy as "protocol tracker for service
with **rewards, points and discipline**".

So at least half of what these two products do is not a feature we have
failed to build. It is a design we ruled out, in writing, before building.

That makes the useful research question a different one:

> Where our product and theirs diverge, is the divergence a **considered
> product boundary we should hold**, or an **execution gap we mistook for a
> boundary**?

Both answers occur, and they need to be told apart one case at a time. The
Explore library rewrite is the precedent: it looked like a taste problem, and
turned out to be a requirement (`REQ-ACT-002`) that had simply never been
built. The reverse case exists too — points and automatic punishment are
things we should keep refusing, and a research pass that quietly relaxes
them because two competitors ship them would be the worst possible outcome.

## What this plan will NOT do

- It will not treat a shipped competitor feature as evidence that the feature
  is good. Both products are unvalidated for us; neither one's retention,
  revenue or complaint volume is visible from a screenshot.
- It will not revisit a Non-goal on competitive grounds alone. Changing one
  is a deliberate product decision for the owner, made explicitly, with the
  reason recorded — not a side effect of a feature comparison.
- It will not produce a feature checklist. The output is a small number of
  decisions with reasoning, not a backlog.

## Method

Four passes. Each produces a written artifact; each is small enough to
review.

### Pass 1 — Complete the capture (blocking)

The current material is thin in a way that matters:

- **Every Obedience screen is the unpaired state.** Rewards, punishments and
  habits are all fully usable with no partner, which is itself a finding, but
  it means we have seen nothing of the two-person experience — the state our
  product is entirely about.
- **BeMoreKinky's `Explore` tab was never captured**, and it is the tab whose
  name matches our own weakest surface.
- **Kneel has not been captured at all.**

Needed before analysis is worth doing: the paired state of Obedience (or an
explicit note that we cannot get it), BeMoreKinky's Explore tab, and Kneel.

Owner action, since I cannot install or drive these apps.

### Pass 2 — Map each product's actual loop

For each competitor, write one page answering only:

1. What does the app ask a person to do on an ordinary day?
2. Who initiates it — the system, the person, or their partner?
3. What happens when they do not do it?
4. What is the app's unit of value — a completed task, a session, a
   conversation, a purchase?

Question 3 is the one that separates these products from ours. Our red line
#3 says adjustment is normal, not failure; Obedience has a Punishments tab
with a `Randomize` field that lets "fate decide". Those are opposite answers
to the same question, and the difference is the product.

This is answerable from screens plus the paired-state capture. Where it is
not answerable, it says so.

### Pass 3 — The divergence table

One row per meaningful difference. Four columns:

| What they do | What we do | Why we differ | Verdict |
|---|---|---|---|

`Why we differ` must cite either a Non-goal / red line / REQ id, **or** admit
there is no written reason — in which case the divergence is an accident, not
a decision, and that is the interesting case.

`Verdict` is exactly one of:

- **HOLD** — a real boundary, keep refusing it, and say so in the product
  docs so it stops coming up.
- **GAP** — we agree with the idea and simply have not built it. Becomes a
  candidate.
- **REFRAME** — they solve a real problem in a way we reject; we need our own
  answer to the same problem. The most valuable outcome of this exercise.
- **UNKNOWN** — cannot be judged without the missing capture or an owner
  decision.

Candidate REFRAME rows, from what is already visible (to be confirmed, not
assumed):

- They answer "what happens when you do not do it" with punishment and lost
  points. We currently answer it with the adjustment path. Is our answer
  actually *felt* by a user, or is it invisible?
- Obedience's Notes has **Limits** as a peer of Fantasies/Kinks/Rules — free
  text, apparently inert. We now have structured, per-person, server-enforced
  limits. That looks like a genuine advantage; is it reachable enough to
  matter?
- BeMoreKinky's Sensate Focus is a **staged ladder** with locked stages. We
  have nothing that gives a couple a sense of progression. Progression
  without scoring is the hard version of that problem, and it is worth
  asking whether it is solvable within our rules.
- Both ship a **journal/private notes** surface. We have none.

### Pass 4 — Decide, and write it down

Take the GAP and REFRAME rows to the owner with a recommendation and a rough
cost for each, and pick a small number — two or three, not ten. Every HOLD
row gets one line added to `00-overview.md` Non-goals or `ui-invariants.md`
so the same question does not have to be re-litigated from screenshots next
time.

## What I need from the owner

1. The missing captures (Pass 1), or permission to proceed with the gaps
   named as UNKNOWN.
2. Answers to two questions no amount of screenshot reading can settle:
   - Which of these two products would *you* keep using, and why? Your own
     reaction as a member of the audience is worth more than my inference.
   - Are any of the four colliding Non-goals (automatic punishment,
     compliance scoring, mandatory streaks, reward economy) actually open for
     reconsideration? If they are all closed, Pass 3 gets much shorter and I
     should know that before starting.

## Estimated effort

Pass 2 and 3 are roughly a day of work together once the captures exist.
Pass 1 is owner time, not mine. Pass 4 is a conversation.

I would not start Pass 2 before Pass 1, because a loop map built from the
unpaired state of a two-person app would be confidently wrong.
