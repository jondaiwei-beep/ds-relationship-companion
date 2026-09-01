# Points, punishment, and what we should actually build

Written 2026-09-01, after capturing BeMoreKinky, Obedience and Kneel, and a
web pass for market evidence. Supersedes the "wait for more captures" gate in
`RESEARCH-PLAN.md` for the specific question of points/punishment: the
evidence found is enough to answer that one now.

**Sources are cited inline. Where I could not verify something, it says so.**
Reddit is not directly readable (our crawler is blocked by reddit.com), so
community sentiment here comes from app-store reviews, competitor blogs, and
third-party guides — a weaker source than a Reddit thread, and treated as
such.

## The question

All three captured products ship points, punishment, and (two of three) a
streak counter. Our `00-overview.md` Non-goals forbid automatic punishment,
compliance scoring and mandatory streaks. Are we the differentiated one, or
just the one missing table stakes?

## What the evidence actually says

### 1. The category is bigger and more crowded than three apps

Beyond the three captured, the search turned up **SubTasks**, **mysub**,
**Collared**, and **Embrace** — at least seven products. Every single one
that does task management ships points and punishments.

This is a commodity feature set, not a differentiator. Building it would make
us the eighth entrant to a copied design, arriving last.

### 2. Points genuinely work for a large audience — this is not a bad idea

Obedience holds **4.7 stars across 2,800+ ratings** on the US App Store.
That is a real product with real satisfied users. Any argument that
gamification "doesn't work for D/s couples" is contradicted by the evidence,
and I am not going to make it.

The honest read: points serve a real appetite. We are the unusual ones.

### 3. But the competitors' own writing names our thesis as their failure mode

This is the finding that matters most, and it comes from **their marketing
blogs, not ours**:

> "Tasks without feedback are just chores. That loop of effort and
> recognition is what makes daily tasks feel like D/s instead of a to-do
> list." — SubTasks blog

> "If daily tasks start feeling like an actual chore list that the sub
> dreads, something is off." — SubTasks blog

> "Bad punishments just hurt, or worse, they make the sub resent the dynamic
> entirely." — SubTasks blog

And from an actual Obedience App Store review, a user describing the gap in
the product they rated well:

> "I do... want something meaningful in the moment of completing a task"
> — noted as concern that the app is "gamified" but lacks immediate
> reinforcement

**"Effort and recognition" is our core loop.** `00-overview.md`:
`Expectation → Action → Human Response → Adjustment`. The category leader's
own content marketing says the thing that makes tasks feel like D/s is the
human response — and their users say they still want it "in the moment."

They know what the problem is. Their architecture answers it with points,
because points are automatable and a partner's attention is not.

### 4. The market has already tested the non-gamified position — and the
result is instructive

**Embrace** (shared journals, daily prompts, mood tracking, no gamification)
is made by **the same company as Obedience**, and it *integrates with*
Obedience: "connect with the Obedience app to get rewards for journalling."

Read that carefully. The one team that built both did not treat reflection as
an alternative to points. They shipped reflection as a **companion** to
points, and wired the points back in.

Two possible reasons, and I cannot tell which from outside:
- reflection alone did not retain, so it needed the points economy attached;
  or
- they simply monetise two audiences and never tried it standalone.

Either way, **"reflection instead of points" is not virgin territory, and the
one company that tried both hedged.** That is a caution about our position,
not a refutation of it.

### 5. Where the whole category is actually weak

Third-party guides converge on the same gap: apps are good at "repetition and
record-keeping" but cannot "negotiate on a person's behalf, read non-verbal
cues, notice hesitation... or provide genuine aftercare."

And what the captures show:
- **Obedience** puts Limits in a **free-text Notes tab**, apparently inert —
  a peer of Fantasies/Kinks/Rules, with no evidence it is read by any other
  part of the app.
- **BeMoreKinky** collects boundaries inside a board game ("The Path").
- **Kneel** has `Verify` — proof-checking — as a first-class concept, but
  nothing captured shows limits or negotiation.

We just built limits as **per-person, server-enforced, uneditable by the
partner**. On the captured evidence, no competitor does this. That is a real,
defensible difference, and it is aligned with the one thing the category is
independently criticised for.

## Answers to your three questions

### Why did they design it this way?

Because **points solve a hard problem cheaply**. In a D/s dynamic, the sub's
effort needs to be *seen*. Requiring the Dom to notice, in the moment, every
time, is expensive and fragile — Doms are busy, asynchronous, sometimes in
another timezone. A points balance is a machine that says "that counted"
instantly, every time, with zero Dom effort.

Punishment is the same trade in reverse: it makes structure *feel* real
without requiring the Dom to hold a difficult conversation.

**Points are a substitute for partner attention.** That is why they exist,
why they work, and precisely why our product's stated test — "reduce the work
required to maintain a Dynamic **without automating away the real human
attention that gives the Dynamic meaning**" — rules them out.

### Should we build them?

My recommendation, split by feature:

| Feature | Verdict | Why |
|---|---|---|
| Points / balance economy | **HOLD — do not build** | Directly automates away the human response, which is our stated product test. Commodity: seven products have it. Building it makes us a worse Obedience. |
| Automatic punishment | **HOLD — do not build** | Red line #3 (adjustment is normal, not failure). Their own blogs say bad punishment "makes the sub resent the dynamic entirely." Also a safety surface we would own. |
| Streak counters | **HOLD — do not build as pressure** | A streak's motive force is fear of breaking it. Incompatible with a product whose adjustment path must feel ordinary. |
| **Consequence as an agreed, human-issued thing** | **REFRAME — build a version** | We currently have *no answer at all* to "what happens when it doesn't get done." Silence is not neutrality; it reads as "nothing here matters." See below. |
| **Visible progression** | **REFRAME — build a version** | BeMoreKinky's staged ladder and Kneel's counters both give a couple a sense of arc. We give none. Progression ≠ scoring. |
| **Long-distance content** | **GAP — build now** | Kneel ships 9 LDR ideas. LDR is our *named design pressure case* in `00-overview.md` and we have zero content for it. Cheapest, most clearly-ours win available. |
| Private journal | **GAP — consider** | Obedience, BeMoreKinky and Embrace all ship one. We have none. Low risk, well-understood. |
| Proof / photo verification | **HOLD, but state it** | Kneel makes `Verify` first-class. Our answer is human acknowledgement. That answer is currently implicit; make it explicit so it reads as a choice. |
| Chastity tracking | **HOLD for now** | An entire Kneel tab. Real demand, but a large specialised feature; not before the core loop is felt. |

### What should we build?

Ranked, for the next stage:

1. **Long-distance content** (days). Pure content, requirement already ours.
2. **The consequence answer** (the important one). Not points, not automatic
   punishment. The gap is that when an expectation isn't met, our product
   currently does *nothing visible*. The reframe: the couple agrees in
   advance what happens, and **a human issues it**. That keeps red line #3
   (it's agreed, not imposed), keeps the non-goal (nothing automatic), and
   answers the question every competitor answers and we duck.
3. **Progression without scoring** (design work first). What does a couple's
   third month look like different from their first? BeMoreKinky answers with
   locked stages. We need our own answer, and I don't have it yet.
4. **Private journal** (well-trodden, low risk).

## What I could not establish

- **No Reddit access.** reddit.com blocks our crawler. Everything above about
  user sentiment comes from app-store reviews and vendor blogs. Vendor blogs
  have an obvious interest; I quoted them only where they argue *against*
  their own architecture, which is the case where bias runs in our favour.
- **No retention or revenue data** for any competitor. 4.7 stars measures
  satisfaction among people who kept using it, not how many left.
- **Whether Embrace succeeded standalone.** This is the single most decision-
  relevant unknown, since Embrace is the closest thing to our position that
  has been market-tested.
- Whether punishment in these apps fires automatically on a missed task or
  only by partner action. Obedience's marketing says "automatically or
  manually", which suggests both — but I did not see it happen.

## The recommendation in one line

**Hold the line on points, punishment and streaks — they are commodity, they
are what seven other products do, and they automate away the exact thing our
product exists to protect. But stop mistaking "no punishment" for "no
consequence": build the agreed, human-issued version, ship the long-distance
content we already owe, and find our own answer to progression.**
