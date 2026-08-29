# CORE_BETA_GAPS.md

Audited 2026-08-27 against Notion 01–06. Judged by **what a real person can
do in the app**, not by what exists in the repo — the previous audit counted
screens that were built but unreachable.

Backend is not the constraint: 30 endpoints are live and tested. Almost every
gap below is a missing client path to something the server already does.

---

## P0 — CLOSED 2026-08-27. The core loop now runs end to end from the app.

| # | Gap | Source | Why it blocks |
|---|---|---|---|
| ~~**G-A**~~ | ~~No way to create an Expectation.~~ **CLOSED** — `ExpectationRepository` + an Ask screen, reachable from Today. Verified live: it lands on the partner's Today. | 06 §13.3 M1, 02 §4 | — |
| ~~**G-B**~~ | ~~Check-in unreachable.~~ **CLOSED** — opened from Today; private stays private (verified live). | 02 §2 A6, 02 §3, 06 §13.4 | — |
| ~~**G-C**~~ | ~~Members carry no `userId`.~~ **CLOSED.** | 03 §2 | — |

## P1 — CLOSED 2026-08-28 (G-G remains a product decision)

| # | Gap | Source | Note |
|---|---|---|---|
| ~~**G-D**~~ | ~~Goal question wording and missing 5th option.~~ **CLOSED** — Notion's exact question, all five outcomes. | 02 §2 A1 | — |
| ~~**G-E**~~ | ~~No starting role preset.~~ **CLOSED** — V7 adds `role_preset`, kept separate from `role_context` so a self-description can never become load-bearing for access. Optional; grants nothing. 5 tests. | 02 §2 A2, 03 §2 | — |
| ~~**G-F**~~ | ~~Today card shows no time context.~~ **CLOSED** — rendered as a person would say it, and never as "overdue". | 02 §3 | — |
| **G-G** | Expectation detail shows no due time and no partner quote. | 02 §3 | Raised for product review; unresolved. |
| ~~**G-H**~~ | ~~Resume is a single action.~~ **CLOSED** — same / lighter, with adjust being the rhythm list on the same screen. Lighter deactivates, never deletes. 4 tests. | 02 §6, 06 §13.5 | — |
| ~~**G-I**~~ | ~~Weekly names the choice but offers no control.~~ **CLOSED** — Adjust and Pause are real actions; Keep is stated, not a button that only dismisses. 5 tests. | 02 §8, 06 §13.7 | — |

## P2 — only G-J remains, and it is blocked on credentials

| # | Gap | Source | Note |
|---|---|---|---|
| **G-J** | **Android Push adapter absent.** Outbox, dedupe, quiet-hours enforcement and the neutral-copy guard are built and tested; the provider adapter is not. | 04 §6, 06 §13.6 (4A) | **Blocked on the owner for FCM credentials.** |
| ~~**G-K**~~ | ~~No quiet-hours aggregation.~~ **CLOSED** — V8 adds `deferred_until` so only genuinely deferred records collapse; a daytime burst is never merged. One neutral summary, no count. 3 tests. | 04 §7 | — |
| ~~**G-L**~~ | ~~No sign-out.~~ **CLOSED** — in Notifications, where a person's own controls live. Ends the local session even if the server call fails. | 04 §11 | — |
| ~~**G-M**~~ | ~~Web Push has no flag.~~ **CLOSED** — `dsapp.features` holds the four switches 06 §9 names, readable at `GET /v1/features` so throwing one needs no app build. Web Push defaults off. A test fails if any safety control ever gains a switch. 4 tests. | 04 §6, 06 §9 | — |

## Still-open product decisions (not engineering)

G-5 idempotency-key retention · Report brought forward or not · honorific setting ·
Rovel Display purchase · whether the expectation screen should carry the due
time and the partner's words (G-G).

---

## Not gaps

Deliberately absent and correct: Proposal, Proof, Points, Rewards, Rules,
Agreement, subscription, 30/90-day analytics, relationship score, saved
moments, AI persona. Explore is an honest placeholder holding its slot in the
IA (02 §1 permits "轻量占位").


---

## Where this leaves Core Beta (2026-08-28)

Twelve of thirteen gaps are closed. **One remains, and it is not engineering:**

**G-J — Android Push.** The outbox, dedupe, delivery fence, quiet-hours
suppression, backlog aggregation and the neutral-copy guard are all built and
tested. Only the provider adapter is missing, and it needs a
`google-services.json` plus an FCM service-account key that must come from the
product owner.

**G-G** is a product decision, not work: whether the expectation screen should
carry the due time and the partner's words.

Every other Core Beta capability now runs end to end from the app and is
verified against live staging by `ops/creator_journey.py` (16 checks) and
`ops/staging_journey.py` (20 checks).
