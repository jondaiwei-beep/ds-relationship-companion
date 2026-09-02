# Product overview — CURRENT v2 migration

Status: **migrated from Notion CURRENT v2; GitHub review required before replacing Notion**  
Source revision: 2026-08-28

## Product definition

A private companion for people in a D/s dynamic — one Dominant, one submissive
(or a switch pair), in a persistent power-exchange relationship — that makes the
dynamic **felt** every day: direction given, received, acknowledged, carried
out, witnessed, and answered.

**Owner's positioning, 2026-09-02:** the core user is a BDSM practitioner, not
"a couple". Kneel manages a dynamic's objects (tasks, rules, points); we design
the moments a dynamic happens between two people. "Kneel 帮你管理 Dynamic；
我们让你感受到 Dynamic。"

The internal product test is: **reduce the work required to maintain a Dynamic without automating away the real human attention that gives the Dynamic meaning.**

## Primary users

- Adults in, or beginning, a consensual D/s / power-exchange dynamic: 24/7 or
  lifestyle D/s, Master/slave, Owner/pet, Daddy/little, Domestic discipline,
  and bedroom-only couples who want the dynamic to reach further into the day.
- They already use the vocabulary — kneel, collar, protocol, punishment,
  safeword, aftercare — and a product that will not say those words reads as
  not for them.
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

## Content stance

**Decision, 2026-09-02: all content restrictions are removed.** ("解除所有限制！
我们就是为这些用户提供服务。")

Until this date the Explore library and the first-day seeds were guarded by
tests banning kneel, collar, master, slave, obey, punish, discipline, spank,
worship, and by a rule of "low privacy sensitivity, nothing that describes a
scene". The stated reason was that a person might be reading on a train. The
effect was a D/s product that could not use D/s words, and users correctly read
it as a couples app in costume.

The train problem is solved where it belongs — the private entrance
(REQ-TRUST-001), app lock, and neutral notifications — not by sanitising what
is behind the door. Content now says what it means: kneeling, collars,
honorifics, positions, inspection, rules with agreed punishments, chastity and
orgasm control terms, scene negotiation, safewords, sub drop and top drop.

What remains is not a content rule but the trust architecture, and it is
unchanged:

- The system never speaks in the partner's voice (red line #1).
- The system never issues a consequence; a person does (`issued_by_user_id
  NOT NULL`).
- Consent, limits and safewords are the couple's, recorded and enforced per
  person, never decided by the software.

App-store boundary: naming kinks and practices in text is what Kneel,
Obedience and BeMoreKinky ship on both stores. Explicit sexual imagery is not,
and remains out of scope.

## Non-goals

Dating/discovery, community feed, AI Dom/Sub persona, automated partner praise, pornographic imagery, emergency safety service, and treating a contract as consent certification are not part of this product.

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
