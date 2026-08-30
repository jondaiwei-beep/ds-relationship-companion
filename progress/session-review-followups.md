# Session layer · review findings not yet fixed

Codex reviewed `platform/session/` and `app/router.dart` on 2026-08-29 and
raised twelve findings. Eight are fixed; these four are open, with the reason
each was deferred rather than done.

## Blocked on an owner decision

### CSRF cannot work across origins — needs a deployment or server change

The server rejects a Web refresh without `X-Refresh-CSRF`, whose value lives
in the `__Host-refresh-csrf` cookie. The `__Host-` prefix **forbids a
`Domain` attribute**, so that cookie is bound to `ds-api.beforeweplay.com`
exactly. Script served from `ds-staging.beforeweplay.com` can never read it.

The client now sends the header whenever it can read the cookie, which is
correct and sufficient for a same-origin deployment. Cross-origin, it reads
null and **every Web refresh fails with 401**.

Two ways out, both outside the client:

1. **Serve the Web app and the API from one origin** (a reverse proxy). Also
   removes the cross-origin credential problem entirely, and is the smaller
   change. Recommended.
2. **Return the CSRF token in the auth response body.** A server change, and
   it puts the token somewhere a crash reporter could pick it up.

Until one is chosen, Web sign-in works and Web *reload* signs the person out.

### Web sign-out cannot revoke locally if the server call fails

`signOut()` now clears local state first, so the current process is denied
immediately either way. But on Web the httpOnly refresh cookie can only be
cleared by the server. If `/logout` fails, a reload restores the session.

Android is fine: the stored token is deleted locally.

The fix is a retry or a queued revocation, and it interacts with the origin
decision above — same-origin deployment makes a `credentials: include`
logout reliable. Deferred until that is settled.

## Deferred deliberately

### A sign-in during sign-out loses the new refresh token

**Reproducing test exists and is skipped**, not deleted:
`session_test.dart` → "signing in during sign-out keeps the new credential".

`_endSession` publishes `SignedOut` and then clears storage. Secure storage
is a platform channel, so a sign-in can complete in between — and the clear
then deletes the *new* session's refresh token. The result is a sign-in that
works until the app is restarted and then silently does not, which is the
worst shape a bug in this layer can have.

I tried two fixes and both were worse than the bug:

- **A generation check in the controller.** Placed before its own `await` it
  is stale by the time the clear runs; placed after, the token is already
  gone. Making it work needed a timed yield, which made `signOut()` depend on
  a clock — and hung the router guard tests, because a widget test awaiting
  `signOut()` waits for a timer nobody advances. That is how it was found.
- **A token-scoped `clear(only:)` through `RefreshStore`.** The right shape —
  the store is the only thing both operations touch — but it is a contract
  change across the interface and both platform adapters, and I was three
  layers into it before noticing the window is one platform-channel round
  trip wide.

Deferred deliberately. The fix belongs in `RefreshStore`, done on its own
rather than in the middle of another change.

### Requests already on the wire outlive sign-out

Clearing the token stops new requests. It does not cancel ones already sent,
so a mutation can still succeed and its response be consumed after the guard
has switched to `SignedOut`. Nothing leaks — the server authorised it when it
was sent — but a caller can apply a result to a screen that should be gone.

Needs a request-scoped session fence, i.e. every response checked against the
generation that issued it. Belongs with the store change above.

### Two smaller ones, recorded and judged not worth the change yet

- Discarding `_inFlightRefresh` does not cancel the underlying request, so a
  new exchange can begin while the abandoned one is still running. The server
  rotates refresh tokens, so the loser is rejected; the generation check means
  its result is discarded either way.
- Web sign-out is not durable when `/logout` fails: the httpOnly cookie
  survives and a reload restores the session. This is the same origin problem
  as above and is listed there.

## Fixed in 2050c1d..HEAD

| # | Finding |
|---|---|
| 1 | Cross-origin requests sent no cookies — `withCredentials` now set on Web |
| 2 | Sign-out awaited the network before denying locally |
| 3 | An in-flight refresh could resurrect a session after sign-out |
| 4 | Concurrent refreshes were not coalesced (server keeps one ACTIVE token) |
| 5 | Transport sent authenticated requests with no session |
| 6 | A rotated token that failed to persist left the session poisoned |
| 7 | Offline was treated as credential rejection, deleting a good token |
| 10 | `returnTo` was double-decoded and unvalidated |
| — | **A 401 now ends the session.** The worry that stopped this was
  distinguishing "this token is dead" from "you may not read *this*". Reading
  the server settles it: authorization failures answer **404**, deliberately,
  so a non-member cannot tell an existing Dynamic from an absent one. On a
  protected endpoint a 401 has one meaning. The interceptor also ignores
  requests that carried no token, so a wrong password does not clear a
  session. |
| — | **App resume revalidates.** A scheduled refresh does not fire while the
  process is suspended, so a device picked up hours later claimed
  `Authenticated` with an expired token and raced its own refresh.
  `AppLifecycleListener` now refreshes on resume, and only when a session is
  meant to exist. |

Findings 11 (async work outliving disposal) and 12 (access token in public
state) are noted and judged low-value for now: both providers are
app-lifetime, and the token is read only by the transport. Worth revisiting
if session scope is ever rebuilt.

## REQ-STATE-001 — the client was inventing an item's identity

`REQ-STATE-001` ("server is the only business-state authority; clients do not
derive missed, acknowledged, blocked or entitlement from local
timestamps/cache") was the one requirement with **zero** references anywhere in
the repository. Checking whether it held found a live violation.

`today_meta.dart` decided what kind of thing an item was by substring-matching
its **title**:

```dart
if (title.contains('check-in') || title.contains('check in')) return _Kind.checkIn;
if (title.contains('ritual')) return _Kind.ritual;
```

That choice drove both the row's label (`RITUAL` / `EXPECTATION` / `CHECK-IN`)
and which frozen SVG master it drew. So a person's own wording silently
reclassified their item: an expectation named "Evening ritual reminder" was
labelled a RITUAL and drew the evening emblem.

This was not hypothetical. The payload already captured in `contract_test.dart`
from the running backend is titled **"Evening check-in message"** — a `TASK`
that the client rendered as a CHECK-IN.

`expectation_definitions.kind` has been `CHECK (kind IN ('TASK','RITUAL'))`
since `V1__foundation.sql`. The server knew the answer and did not send it; the
query already joined the table for the title. `d.kind` now travels on the read
model and the client reads it.

**A check-in is not an expectation kind.** It is a separate entity
(`POST /v1/dynamics/{id}/check-ins` — mood, energy, need, note, visibility): a
person sharing their state, not something expected of them. The client's third
branch conflated an obligation with a state disclosure. `DsAssets.markCheckIn`
is therefore now unreferenced — correctly so. It is a frozen master waiting for
the check-in surface, which `REQ-TODAY-001` gives its own slot in the priority
order and no screen yet builds. **Do not delete it.**

Covered by `TodayIT."Today states each item's kind so the client never guesses
it"` and the `today_invariants_test` case of the same name; both fail if the
title guess returns.

### Two more REQ-STATE-001 violations of the same family, not yet fixed

Codex's review of the `kind` fix surfaced two others. Both are the same
mistake — the client stating a server-owned fact — and both are wider than
this change, so they are recorded rather than folded in:

1. ~~**The relationship-day boundary is hard-coded.**~~ **Fixed.**
   `day_boundary.dart` rendered the literal `'Relationship day ends at
   2:00 AM'` while the server computed the day from
   `dynamics.day_boundary_minutes` and did not send it — a screen whose own
   comment claimed the value was server-stated. The query already read the
   column to resolve the day and then discarded it; `dayBoundaryMinutes` now
   travels on the read model beside `relationshipDay`. The freshly captured
   contract payload has `dayBoundaryMinutes: 0`, so that Dynamic rolls over at
   midnight and was being told 2:00 AM.

2. ~~**Today invents the available actions.**~~ **Fixed.**
   `primary_expectation.dart` rendered all four commands unconditionally while
   `GET /v1/occurrences/{id}` returned an authoritative `allowedActions` — the
   "entitlement" word in REQ-STATE-001. Reproduced against a live server: a
   partner who asks to discuss an expectation may do exactly one thing,
   `withdraw`, and Today showed Complete / Discuss / New time / Can't do —
   four actions, none of them the permitted one.

   The rule moved out of `OccurrenceQueryService` into `AllowedActions` so both
   read models share one definition rather than drifting, and Today now carries
   the list per item. A card with no offerable action shows the item and its
   state, not a button that would be refused.

Judged acceptable and deliberately left alone: `responseAge()` uses
`DateTime.now()` to say "12 MIN AGO". That is elapsed-time *formatting*, not
state derivation — it decides no status, ordering or affordance. It would
become a violation the moment it fed missed/overdue.

### `withdraw` is advertised and not implemented — open product gap

Found reviewing the `allowedActions` fix. The server tells a partner with an
open adjustment that their one permitted action is `withdraw`:

```
GET /v1/occurrences/{id}  ->  allowedActions: ["withdraw"]
```

**No endpoint implements it.** `POST /occurrences/{id}/adjustments/resolve` is
the creator's side (continue / adjust / reschedule / excuse / cancel). Nothing
lets the person who asked to discuss take the request back.

So a `NEED_TO_DISCUSS` item is a dead end for its own author. It is visible —
Attention lists it at priority 1 and Today shows it as "Being discussed" — but
neither surface offers an action, and Today rows do not navigate anywhere.

This gap pre-dates the `allowedActions` fix and the fix did not widen it. Before
it, Today offered Complete on that item, which the server refuses with
`409 OCCURRENCE_NOT_ACTIVE` (verified live). The dead end was the same; it was
just reached through a button that looked like it worked.

Not fixed here because it is a feature, not a cleanup: it needs an endpoint, a
service method and guarded transition, a screen affordance, and copy — and it
touches the adjustment vocabulary Journey D fixes deliberately ("never approve
or reject, which would frame asking as a request for permission"). Withdrawing
your own request is a fifth verb that vocabulary does not yet name.

**Owner decision needed:** either implement `withdraw` end-to-end, or drop it
from `AllowedActions` so the server stops advertising an action that does not
exist. Advertising it is the worse of the two — a client that trusts
`allowedActions`, as Today now does, will render a button that 404s.

### `dueAt.toLocal()` rendered due times in the device's zone — fixed

Codex's last finding, and a REQ-TIME-001 violation rather than a REQ-STATE-001
one: *"DST and device timezone changes do not silently move a relationship
day."* `itemMeta` formatted `item.dueAt!.toLocal()`, so a partner in another
zone read a different hour than the one their partner set — the exact failure
for the long-distance couple this product exists for.

Same shape as the day boundary: the Today query already read
`dynamics.reference_timezone` to resolve the relationship day, then discarded
it. It now travels on the read model, and the two row widgets render the due
time in it. The `timezone` package was already a declared dependency and had
never been imported; `initializeTimeZones()` now runs in both entry points.

Falls back to the device zone only when the server did not state one (an older
server) or named a zone this build's database does not know.

### Two systemic gaps between the state matrices and REQ-RECOVERY-001

Found while clearing the last blocked rows in Phase 1, and both affect all 31
screen contracts rather than any one screen.

**1. No screen has a `Stale` row.** `REQ-RECOVERY-001` names six behaviours —
*loading, empty, error/retry, offline, **stale**, authorization-loss* — and the
matrix template carries rows for five of them. Zero of 31 matrices mention
stale.

It is not unhandled in practice: SCR-01 folds it into Offline (*"Only
last-confirmed cache is available / Label timestamp, make list read-only"*), and
SCR-09 rev-3 and SCR-03 rev-3 do the same. But no contract states that, so the
requirement reads as unmet on every screen and the coverage is invisible.

**Owner decision:** either add a `Stale` row to the template and point it at the
offline treatment, or amend `REQ-RECOVERY-001` to say stale is a qualifier on
offline rather than a seventh state.

**2. `Role/partner variant` is in every matrix and in no requirement.**
`REQ-RECOVERY-001` does not list it. It appears to have come from SCR-01's
matrix, where it is real and carries a genuine principle (*"Custom roles may
alter wording, never rights"*), and then propagated to screens where it means
nothing — including three pre-authentication screens that have no role at all.

Resolved per screen from each contract rather than by template. Notably, on
SCR-02 and SCR-03 it resolves to *not applicable*, and the schema is why:
`memberships.role_preset` is `DOMINANT | SUBMISSIVE | SWITCH | CUSTOM` with **no
free-text label column**, and V7 states it is *"never used for authorization"*.
So a custom role cannot alter a word or a right on those screens — the display
name is the only variable. SCR-01's rule is aspirational for a capability the
schema does not yet have.

### SCR-19 Task List should not be built, like SCR-11

Found when starting Sprint 7. Its contract says so directly:

> Business logic and state transitions: **Merge into the Today family as its
> prioritized-list state, not a separate primary navigation tab.**
>
> Known alignment work: use as Today secondary list, not a new primary tab

SCR-01 already implements this — the priority list, the count-bearing "Show"
disclosure and the Later rows *are* SCR-19. Designing it separately would build
the fourth navigation tab the contract rejects.

Same shape as SCR-11 Mutual Consent, whose contract says "do not build
independently; merge the useful trust language into SCR-10". Two of the 35
screens are instructions to fold something in, not screens.

**Phase 2 screen count is therefore 12, not 13.**

### REQ-IDEMP-001 — coverage audited, two real gaps closed

Sprint 6 T6.3. The requirement names six operations; the mechanisms protecting
them turn out to be three different things, and two operations had no retry test
at all.

| Operation | Protected by | Retry test |
|---|---|---|
| Complete | idempotency key | HTTP, pre-existing |
| **Acknowledge** | idempotency key + `occurrence_id UNIQUE` | **HTTP, added** |
| **Adjustment resolution** | idempotency key | **HTTP, added (reschedule)** |
| Join | invite single-use | service |
| Pause / Resume | guarded transition, throws | service |
| Leave / Block | authorization guard | **service, added** |

**Acknowledge** mattered most: it is the only thing that closes the loop, so two
of them would mean the system manufactured a human response nobody sent.

**Adjustment resolution had no HTTP test whatsoever.** `AdjustmentIT` calls the
service directly with a fresh key each time, exercising the domain rule and not
the idempotency layer. `RESCHEDULE` is the dangerous branch because it is the
only resolution that *creates* an occurrence — applied twice, a person owes two
of the same thing and the duplicate is indistinguishable from something their
partner set.

**Leave taught me something by failing.** Reading the method, steps 1–2 use
guarded SQL (`WHERE access_state = 'ACTIVE'`) but the `membership_terminations`
insert and the event append below them are unconditional, so I wrote a test
expecting duplicates. It failed for a different reason: `requireRead` rejects
the second call before any insert runs, because the actor is no longer an active
member of what they just left. The protection is real but sits somewhere the
code does not look like it is. Now tested, and verified by removing the guard.

Codex's review corrected two things. The reschedule assertion counted active
occurrences per *dynamic*, which would pass for the wrong reason once the
fixture gains a second expectation — now counted against the original's
definition, plus an assertion that the original stays `CANCELLED`. And it caught
that `requireRead` runs *before* the advisory lock, so two concurrent direct
service calls could both pass it. Over HTTP that is unreachable — `/leave` goes
through `runOnce` and the DB unique index arbitrates same-key races, which
`IdempotencyServiceIT` already proves — so the test now states its scope rather
than overclaiming.

### staging was deploying from a repo that no longer exists — fixed

TD-04 / TD-16, open since the plan was written. The root cause was not the
script in this repository: that had been corrected days ago. The server's own
copy at `~/deploy-ds.sh` was a snapshot from 27 August that still cloned
`JonDai/dsapp.git`, a repo the project moved away from. Every deploy since then
had been a no-op against a stale build.

Fixed by uploading the corrected script (md5 verified on both ends) and running
it. Live commit is now `eb5718a`.

Verified by behaviour rather than by the health check, which the script itself
warns is not evidence:

- `POST /v1/auth/register` answers **400**, not 401 — the exact symptom that
  identified the stale jar.
- It returns `AGE_NOT_CONFIRMED`, so the V9 password-registration schema is live.
- A full register → create dynamic → create expectation → read Today loop runs
  against production, and Today returns all four fields added this session:
  `kind`, `dayBoundaryMinutes`, `referenceTimezone`, `allowedActions`.

The corrected script also repoints an existing `origin` rather than only fixing
fresh clones, so a stale checkout on the server cannot reintroduce this.

**On-device acceptance is no longer blocked.** Builds should carry
`--dart-define=API_BASE_URL=https://ds-api.beforeweplay.com`.
