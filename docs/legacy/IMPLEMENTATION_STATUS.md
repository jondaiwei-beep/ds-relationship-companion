# IMPLEMENTATION_STATUS.md

Living record of what is built, what is in progress, and what is blocked.
Update this file at the end of every task. Keep it factual — no aspirational entries.

**Last updated:** 2026-08-28 (Revision 3 增补 16 — Core Beta functionally complete except Android Push)

---

## Current Milestone

**M0 → M5 implemented.** Every Core Beta screen is built; the remaining items are non-blocking (see Next).

The M0/M1 exit-criteria checklist below is kept verbatim as the original gate. Two boxes stay unticked and are reported as such: the Android internal build is produced but has never run on an Android device (owner chose iOS instead), and CI does not build it.

Per `06 — Engineering Build Plan v2 §13.2`. Users see little, but every later reliability guarantee depends on it.

M0 must deliver: project skeleton + dev/staging/prod environments + migrations · CI (backend test, Flutter analyze/test, Android build, Web build) · fixed Flutter workspace/package boundaries · **M0 tech-stack freeze** · User/Dynamic/Membership · auth session basics · server authorization framework · IANA timezone primitives · RelationshipEvent · idempotency/command framework · feature flag + kill switch basics · shared API client skeleton + platform adapter skeleton · **API contract baseline (OpenAPI or equivalent — no hand-copied DTOs)** · Android internal build + Web staging deployment · Flutter Web browser support matrix + mobile Safari first-load/refresh/direct-URL performance baseline · crash/error observability baseline.

**M0 Exit Criteria**
- [ ] Same account reads the same Dynamic state on Flutter Android and Flutter Web
- [ ] Role is not written as a permanent User attribute
- [ ] Unauthorized Dynamic read/write is rejected server-side
- [ ] Migration / rollback / seed run repeatably
- [ ] CI reliably produces an Android internal build and a Web staging build
- [ ] Flutter Web direct URL / refresh does not 404
- [ ] API contract drift is caught in CI or contract tests
- [ ] Staging surfaces client crash/error and key API failures

---

## Completed

| Date | Item |
|---|---|
| 2026-08-26 | Read Notion `CURRENT — Developer Handoff v2` and all 7 canonical documents (01–07) |
| 2026-08-26 | Created `CLAUDE.md` — permanent execution rules, Source of Truth, red lines, prohibitions |
| 2026-08-26 | Created `docs/PROJECT_CONTEXT.md` — product, users, core value, core loop, architecture, scope, non-goals |
| 2026-08-26 | Created `docs/IMPLEMENTATION_STATUS.md` — this file |
| 2026-08-26 | Created Notion `AI Implementation Review Queue` under CURRENT — Developer Handoff v2 — https://app.notion.com/p/3c8f73841f3d81baa66cef1958628fb7 |
| 2026-08-26 | Received Warm Authority V5 design HTML from product owner; copied to `docs/design/warm_authority_v5.html` |
| 2026-08-26 | Created `docs/DESIGN_SYSTEM.md` — tokens, typography, layout, components, 6 screen specs, 6 recorded deviations. **B-001 resolved.** |
| 2026-08-26 | Downloaded and installed **Lora + Inter** variable fonts (SIL OFL) with license files to `assets/fonts/`. **D-1 resolved.** |
| 2026-08-26 | Wrote `docs/adr/ADR-0001-technology-stack.md` — Flutter stack confirmed, backend stack proposed, D-1/D-2/D-3 resolved. **B-002 resolved pending sign-off.** |
| 2026-08-27 | Evaluated xmatch B-group reuse against live code + production host; wrote `docs/adr/ADR-0002-deployment-and-hosting.md`. **ADR-0001 accepted.** |
| 2026-08-27 | Installed JDK 21 LTS (arm64). Scaffolded Flutter workspace: feature-first package layout, frozen deps, design tokens, `Occurrence` model + codegen, 4 state tests, Lora/Inter bundled. **Android debug APK + Web release build both green.** |
| 2026-08-27 | Backend schema `V1__foundation.sql` — 11 tables, append-only trigger, partial unique indexes. **Verified against real PostgreSQL 16.15**; `backend/verify_schema.sh` reproduces it. |
| 2026-08-27 | Adversarial design review via Codex; recorded 7 real spec gaps in `docs/OPEN_SPEC_GAPS.md`. |
| 2026-08-27 | Backend skeleton: Gradle 8.14 wrapper, Spring Boot 3.5.6, Kotlin 2.1.20, 8 module boundaries, `OccurrenceState` domain enum. **Compiles; boots; Flyway applies V1; `/actuator/health` UP.** |
| 2026-08-27 | Fixed two schema defects found by testing: `NEED_TO_DISCUSS` wrongly terminal in the uniqueness index, and `due_at` wrongly NOT NULL. |
| 2026-08-27 | **Server JDK verified.** CentOS 7 has only JDK 8 and dead yum repos; installed Temurin 21 to `/opt/jdk21` and **ran our actual Spring Boot 3 jar on the host** (started in 10.1s). xmatch A/B untouched and healthy. |
| 2026-08-27 | Wrote + installed `ops/deploy-ds.sh` (port 8082, hardcoded `/opt/jdk21/bin/java`, automatic rollback). Preflight guards verified on the server. |
| 2026-08-27 | **Idempotency framework** (`shared/idempotency`): reserve-execute-complete in one transaction, DB-arbitrated concurrency, verbatim replay, 422 on key reuse. **4/4 tests pass incl. 8-thread concurrent duplicates.** |
| 2026-08-27 | Added missing `completed_at` + `(id, actor_user_id)` unique to `idempotency_keys` — found by the failing test, not by reading. |
| 2026-08-27 | CI workflow: backend (PG16 service + schema contract gate) and Flutter (codegen, analyze, test, Web + Android). Both paths verified locally. |
| 2026-08-27 | **Check-in + Starter Rhythm screens**: PRIVATE default with a visible visibility control; starter shows exactly three things with an unchecked opt-in second expectation. 11 tests. |
| 2026-08-27 | **Adjustment UI** (Journey D front end): ask + resolve sheets wired. Tests ban apology/failure vocabulary on the ask side and approve/reject vocabulary on the answer side. 12 tests. |
| 2026-08-27 | **Starter Rhythm + overdue sweep**: default is exactly 1 Ritual + 1 Expectation; overdue leads to `NEEDS_REVIEW` only, skips open adjustments, queues no notification, and records a NULL actor. 13 tests. |
| 2026-08-27 | Fixed test isolation: background schedulers now disabled under the test profile (they were racing tests). Verified deterministic across consecutive runs. |
| 2026-08-27 | **M2 Ritual recurrence + Check-in**: two frequencies (no RRULE engine), idempotent generation, Resume advances a barrier so there is never a backlog. Check-in privacy enforced in the read SQL. 12 tests. |
| 2026-08-27 | **M4B Leave / Block** (Journey F, the safety feature). **Closes G-1 and G-2.** Block is mutual in effect, ends the Dynamic, seals history both ways, never names the blocker. Delivery fenced by a per-Dynamic advisory lock. 13 tests. Verified live. |
| 2026-08-27 | **M3 adjustment path** (Journey D): Discuss / Reschedule / Cant-do end to end. **Closes G-3** — the full transition graph is encoded with the forbidden edges justified. Reschedule keeps history. 19 tests. Verified live. |
| 2026-08-27 | **M4A outbox dispatcher**: `outbox_records` had no consumer — the async chain was empty. Four re-checks before send (access / dynamic / staleness / quiet hours), lease-based claiming, neutral-copy-only provider requests. 9 tests. Live: 15 SENT, 14 suppressed. |
| 2026-08-27 | **Us + Dynamic screens**: all four nav surfaces now exist. `ALWAYS YOURS` renders inviolable agency unconditionally. 9 tests. |
| 2026-08-27 | **M3 relationship-day + DST** (S1 blocker): occurrence creation used SQL `CURRENT_DATE` — the DB server's date, not the Dynamic's timezone/boundary. Fixed. 15 DST unit tests + 3 persistence tests. |
| 2026-08-27 | **Flutter end-to-end loop test**: found a real routing bug — `WAITING_ACK` matched on state before `allowedActions`, so the direction-giving side was shown the receiving side's screen and could not acknowledge. Fixed. 6 tests. |
| 2026-08-27 | **Verified on a real iPhone 17 / iOS 26.5 simulator**: native app renders correctly, real mobile Safari opens the live staging invite with the real inviter name, nested-route refresh works. Android emulator abandoned per owner decision (image download kept failing); ~7 GB reclaimed. |
| 2026-08-27 | **Bottom navigation** — the product was not navigable: every surface existed but only Today was reachable on a phone. V5's Explore slot is taken by Attention (Explore is out of Core Beta). Rendering caught Material glyphs rendering as empty squares; the four marks are now drawn to the 24×24 1.5-stroke spec. **4 tests.** |
| 2026-08-27 | Rendered the nine screens that had never been looked at. Found the sheets had no grab handle — no visible way out of Discuss / Reschedule / Can't-do. Added `DsSheetHandle` once, used in all three. |
| 2026-08-27 | **Quiet Hours + lockscreen privacy** (Notion 04 §5), backend + UI: `/v1/me/notification-settings`, subject always the caller. Half a window and a zero-length window are refused rather than guessed. **14 tests.** Verified live. |
| 2026-08-27 | Fixed a data-loss bug the quiet-hours test caught: editable fields were never seeded from saved settings, so opening the screen showed defaults over a saved window and saving overwrote it. |
| 2026-08-27 | **D7 Weekly Reflection** (M5), backend + UI: describes the week, never grades it — no rate, score or streak, and no snapshot object; computed from domain events at read time. Hidden until the couple has a week behind them. Ends in a question, not a recommendation. **16 tests.** Verified live. |
| 2026-08-27 | Rendering the reflection caught two real defects: the connected-day count was stated twice on one screen, and a partner's exact words were quoted twice ~600px apart — which makes a human response read as machine-repeated. Both fixed with regression tests. |
| 2026-08-27 | **Leave / Block UI entry** (Journey F): both actions on one findable screen, two taps each — no danger zone, no typed phrase, no wizard, because a long flow is visible over a shoulder and slows an urgent act. Block discloses that it seals the actor's own history. **9 tests**, incl. one banning alarming vocabulary. |
| 2026-08-27 | **Us + Dynamic + Pause/Resume** (Notion 02 §8/§10, Journey E): human-only events, `connectedDays` needs two distinct actors, `alwaysAvailable` agency list, either member may pause. 8 tests. Verified live. |
| 2026-08-27 | **Today** (Journey B), backend + UI: capped at 3 expectations (focus surface, not a backlog), human response surfaced first, neutral greeting asserted. 16 tests. Verified live on staging. |
| 2026-08-27 | **Attention UI screen** (Journey C): server-ordered, empty state framed as good, backend state names mapped to human copy. 6 tests. |
| 2026-08-27 | Screenshot harness renders 4 response-loop screens at a real 390×844 surface with bundled fonts; Attention uses the exact live staging payload. **Screenshots attached to the Notion Review Entry.** |
| 2026-08-27 | Fixed 3 layout bugs found only by rendering: `DsCard` bare Stack gave unbounded constraints · `DsPage` Center passed unbounded width · Respond TextField had no height bound in a scroll view. |
| 2026-08-27 | **HTTPS staging LIVE**: `https://ds-staging.beforeweplay.com` (web) + `https://ds-api.beforeweplay.com` (API). Cloudflare-proxied, PG16 container on the host, real RSA keys. xmatch A/B unaffected (8080/8081 both 401, 3dermatch 200). |
| 2026-08-27 | **iPhone Safari acceptance PASSED** (WebKit, iPhone 13 profile, live staging): first open · nested-route refresh · browser back · direct URL cold context · 0 console errors. Screenshots in `docs/screenshots/m1-safari-*.png`. |
| 2026-08-27 | **API contract gate**: `/v3/api-docs` published (13 operations), baseline committed, `backend/contract/check_contract.sh` **proven to fail on injected drift** and pass when matched. |
| 2026-08-27 | Review follow-up: PKCE verifier now cleared in a `finally` — on success, failure AND expiry — not only on success. |
| 2026-08-27 | **Attention query** (Journey C): fixed journey priority — Discuss → WaitingAck → NeedsReview — not recency. Settled occurrences excluded so the Dom is not handed busywork. **5 tests.** |
| 2026-08-27 | **Magic-link auth wired end to end** and verified live: 300s JWT authorizes a protected endpoint, single-use replay → 401, PKCE wrong-verifier → 401, expired → 401, no plaintext stored. **5 tests.** |
| 2026-08-27 | Fixed a real bug: user auto-provisioning wrote `false` into `notification_preview` (a text NEUTRAL/RICH column) — **every first-time sign-in failed**. |
| 2026-08-27 | **Web-first invite flow verified in a real browser** (Playwright): `/invite/{token}` resolves live, renders the real inviter name, Lora/terracotta correct, neutral browser title. Screenshot: `docs/screenshots/m1-invite-web.png`. |
| 2026-08-27 | Browser testing caught **two bugs invisible to unit tests**: CORS blocked the Web companion entirely, and the SPA fallback 404'd invite tokens because `iv1.` contains a dot. Both fixed in code and in `ops/nginx-dsapp.conf`. |
| 2026-08-27 | Routing: stable `GoRouter`, synchronous auth-only redirect, continuation in the URL (survives refresh + new-tab callback), `errorBuilder` instead of dead ends. Opening an invite URL never auto-joins. |
| 2026-08-27 | **Flutter client**: design system (colors/type/spacing, DsCard/DsButton/DsQuote/DsNote), domain client (ApiClient with idempotency keys, repositories), and 3 Warm Authority screens — Waiting, Respond, Acknowledgement Received. **16 Flutter tests green.** |
| 2026-08-27 | **Contract tests caught real DTO drift**: server emits `WAITING_ACK` (SCREAMING_SNAKE), client expected `waiting_ack`. Would have crashed at runtime. Captured payloads from the live backend. |
| 2026-08-27 | **M1 VERTICAL SLICE RUNS END-TO-END over HTTP**: create Dynamic → Invite → anonymous resolve → Join → Expectation → Complete → human Acknowledge → partner sees it. **24/24 backend tests green.** |
| 2026-08-27 | REST layer: `DynamicController`, `OccurrenceController`, `OccurrenceQueryService` (`allowed_actions`), `ApiErrorHandler` (non-member → 404, never 403). |
| 2026-08-27 | Fixed an **activation deadlock**: a COUPLE dynamic starts `PENDING_PARTNER`, but mutations required `ACTIVE` — so the creator could never send the invite. Split `mayMutate` (relationship actions) from `maySetUp` (invite + first expectation). |
| 2026-08-27 | **Auth stack**: magic link + JWT + refresh rotation, PKCE-style verifier, ephemeral dev keys with a `prod` guard, dev magic-link logger. App boots with security on: health 200 anon, protected 401. |
| 2026-08-27 | **Invite lifecycle**: create (hash-only storage), anonymous resolve (never 404s), guarded single-use join. **8 tests. 20/20 backend tests green.** |
| 2026-08-27 | **M1 human-response loop**: `MembershipAuthorizer`, `CompleteOccurrenceService`, `SendAcknowledgementService`, `RelationshipEventWriter`. Guarded conditional transitions. **8 tests incl. the red-line invariants. 12/12 backend tests green.** |

---

## In Progress

| Item | Notes |
|---|---|
| — | Nothing in flight. 170 backend / 136 Flutter tests, contract gate at 31 operations, deployed to staging. |


---

## Next

Ordered. None of these blocks Core Beta.

0. ~~Quiet Hours settings UI~~ — **done 2026-08-27**.
1. **Android Push adapter (M4A)** — **blocked on the owner**: needs `google-services.json` and an FCM service-account key. The outbox dispatcher, neutral-copy guard and delivery fence are already built and tested; only the provider adapter is missing.
3. **G-5 idempotency-key retention** — keys are kept forever today. "Retry is always safe" and short retention cannot both hold; needs a product decision.
4. **Report surface** — Notion 04 §11 says to bring it forward if an invite-only beta already carries real UGC. Core Beta does carry human acknowledgements, so this may already be triggered.
5. **Honorific setting** — deferred out of Core Beta by review; V5's "Sir" needs a user-configured value before it can ever be rendered.
6. **Rovel Display** — purchase decision. Lora + Inter ship today and a swap is one token change.

**Explicitly still out of scope**: Agreement · Rules · Proposal · complex permissions · full Explore · Experience · Proof · Points · Rewards · Consequences · Subscription · advanced scheduling · 30/90-day analytics · AI Dom-Sub.

---

## Blockers

| ID | Blocker | Impact | Status |
|---|---|---|---|
| B-001 | ~~Figma MCP quota exhausted.~~ | — | **RESOLVED 2026-08-26** — product owner supplied `warm_authority_v5.html` as the visual Source of Truth. Figma remains unreachable but is no longer on the critical path. |
| B-002 | ~~Backend stack undecided.~~ | — | **RESOLVED 2026-08-26** — `ADR-0001` proposes Kotlin + Spring Boot 3 + PostgreSQL 16 + Flyway + jOOQ + in-process outbox worker. Awaiting owner sign-off; no other blocker. |

---

## Design Decisions — all closed

Detail in `docs/DESIGN_SYSTEM.md` §7 and `docs/adr/ADR-0001`.

| ID | Issue | Resolution |
|---|---|---|
| D-1 | Display font | **Lora + Inter** bundled (SIL OFL) at `assets/fonts/`. Apple system fonts unlicensable; Rovel Display deferred until purchased |
| D-2 | Primary CTA height | **48dp** — accessibility outranks the mockup's 42px |
| D-3 | "Good morning, Sir." | **Neutral greeting**; honorific becomes user-configured content later |
| D-4 | Proposal line | **Not implemented** — out of Core Beta (Notion wins) |
| D-5 | "no proof requested" | **Not implemented** — Proof is P1 |
| D-6 | Partner invitation card | **Not built in M1** — no canonical Core Beta object |
| G-3 | Occurrence side-path transition graph | ✅ **CLOSED 2026-08-27** — encoded in `OccurrenceTransition` with 8 tests |
| G-1 | Leave/Block delivery guarantee | ✅ **CLOSED 2026-08-27** — restated achievably and fenced with a per-Dynamic advisory lock |
| G-2 | Block semantics | ✅ **CLOSED 2026-08-27** — directional record, mutual effect, ends the Dynamic, never names the blocker |

---

## Technical Debt

| Item | Reason accepted | Repayment condition |
|---|---|---|
| `freezed: ^3.2.6-dev.1` (dev prerelease) | On Flutter 3.44.1 this is the **only** version satisfying the analyzer chain shared with `riverpod_generator 4.0.4` + `json_serializable 6.14.1`. Riverpod 2.x and freezed 3.2.5 were both tested and fail to resolve. Codegen, analyze, tests and both builds verified green. | Pin to stable `freezed 3.2.6` the moment it ships |
| `riverpod_lint` / `custom_lint` omitted | Mutually incompatible with the resolved `freezed_annotation`. Lint-only; no runtime effect. | Revisit when the constraint clears |
| Local Postgres 16 runs on port **5433** | Port 5432 is occupied by a pre-existing Postgres 14. | Harmless; documented in `backend/verify_schema.sh` |
| **CentOS 7 host is EOL** (since 2024-06-30) | Pre-existing; shared with the two live xmatch apps. No OS security patches. Our JDK is independently updatable. | Host migration — a decision larger than this project |

---

## Feature Flags

Planned per `06 §9`. None implemented yet.

| Flag | Purpose | Status |
|---|---|---|
| `web_push` | Web Push is optional in Core Beta; Invite/Magic Email is the stable fallback | Planned |
| `weekly_reflection` | D7 Reflection kill switch | Planned |
| `explore_placeholder` | Explore placeholder recommendations | Planned |
| `analytics_experiments` | Optional analytics experiments | Planned |

**Rule:** safety and access revocation (Leave / Block / authorization) must **never** depend on a switchable flag.

---

## Review Queue Entries

| Entry | Milestone | Status |
|---|---|---|
| [[REVIEW] M0+M1 · Foundation & First Connected Vertical Slice · 2026-08-27](https://app.notion.com/p/3c9f73841f3d8163b033d1cdf1b56563) | M0 + M1 | **Awaiting Review** (Revision 1) |

Statuses: `Awaiting Review` · `APPROVED` · `APPROVED WITH MINOR FIXES` · `CHANGES REQUIRED` · `PRODUCT DECISION NEEDED`.
A task is Done only on `APPROVED`, or `APPROVED WITH MINOR FIXES` with fixes complete.
