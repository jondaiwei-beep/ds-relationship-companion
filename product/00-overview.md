# Product overview — CURRENT v2 migration

Status: **migrated from Notion CURRENT v2; GitHub review required before replacing Notion**  
Source revision: 2026-08-28

## Product definition

A private companion that helps consensual adult D/s couples keep their dynamic present, responsive, and easier to maintain—especially when life or distance gets in the way.

The internal product test is: **reduce the work required to maintain a Dynamic without automating away the real human attention that gives the Dynamic meaning.**

## Primary users

- Adults who already have a partner and are beginning or maintaining a consensual D/s Dynamic.
- Design pressure case: Android direction-giving member + iPhone Safari receiving member + LDR + different timezones.
- Solo mode may establish a private rhythm, but must not turn the product into a personal habit tracker. The couple is the primary value unit.

## Four relationship signals

1. **Expectation** — what we hope will happen.
2. **Presence** — the relationship feels present even when partners are asynchronous.
3. **Response** — a real partner saw and responded to an action.
4. **Adjustment** — reality can be discussed and the rhythm can change.

Core loop: `Expectation → Action → Human Response → Adjustment / Next Expectation`.

Product boundary: **Automation prepares; the partner responds.** The system may suggest, sort, remind and prepare a Starter Rhythm. It must not impersonate partner praise, automate punishment, or determine consent.

## Core Beta success

**First Connected Dynamic Day** occurs when both members have joined one Dynamic and complete at least one bilateral meaningful event, such as completion + human acknowledgement or shared check-in + partner response.

North Star: **Connected Dynamic Days / Active Couple / Week**.

## Non-goals

Dating/discovery, community feed, AI Dom/Sub persona, automated partner praise, explicit-content discovery, emergency safety service, and treating a contract as consent certification are not part of this product.

Points, tasks, rewards and consequences **are** part of this product, decided
by the owner on 2026-09-02. See "Points and consequences" below for what that
does and does not include.

### Points and consequences

**Decision, 2026-09-02: we build points, tasks, rewards and consequences.**

This reverses the previous position, and the reasoning for the reversal is
the stronger half of the evidence that was already on file. Reviewed against
three shipped competitors (see `product/research/competitors/`): every
task-managing product in this category ships points and punishment, and
Obedience holds 4.7 stars across 2,800+ ratings. These mechanics
demonstrably work for a large audience, and the case against them rested on
a documented *risk* (overjustification) rather than on evidence that this
audience dislikes them. Refusing a feature the whole category ships, on the
strength of a risk we had not measured, was the more expensive bet.

What follows is what the previous analysis got right and is worth keeping as
design constraints rather than as refusals. Each is a rule about **how** we
build these four things, not whether.

**1. A person always decides a consequence.** Points may accrue
automatically; a consequence may not fire automatically. This is the one
piece of the old position that is safety rather than taste — their own
writing says vague punishment "breeds resentment" and bad punishment makes
"the sub resent the dynamic entirely", and an automatic system structurally
cannot be merciful. Every consequence event names the human who issued it,
and "let it go" is an equal-weight action. See
`product/design/agreed-consequences.md`.

**2. Points supplement the human response; they never replace it.** The
product test still stands: reduce the work of maintaining a Dynamic without
automating away the human attention that gives it meaning. A completion that
earns points and receives no human response is the failure case. Concretely:
awarding points must never mark an occurrence as answered, and the Attention
surface keeps asking for a real response.

**3. Streaks may show continuity, never fear of loss.** Breaking a streak is
documented to cause all-at-once abandonment rather than gradual decline, and
red line #3 says adjustment is normal. So: accumulated totals that never
reset are fine; a counter whose visible purpose is that a gap destroys it is
not. Test for any such display: **does a gap in it feel like a loss?**

**4. Nothing here is a compliance score shown as a verdict on a person.**
Totals are fine. A number presented as how well someone is doing at being a
partner is not.

The instrument that tells us whether points are helping or hollowing out the
loop is our own North Star — Connected Dynamic Days per Active Couple per
Week — which counts bilateral events. If task completion and points climb
while that stays flat, points are substituting for the relationship rather
than supporting it, and we will know.

## Sources

- [CURRENT — Developer Handoff v2](https://app.notion.com/p/3c8f73841f3d81f4ae0ac63bb8767993)
- [01 — Product Requirements v2](https://app.notion.com/p/3c8f73841f3d816d88c0ce627fca963a)
