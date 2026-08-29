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

### No 401 handler ends the session

A revoked access token currently surfaces as an error on whichever screen
asked. The screen classifies 401/403 as authorization loss and shows the
designed state, so nothing leaks — but `Session` still says `Authenticated`,
and another screen would try again.

A Dio interceptor that ends the session on 401 is the fix. Not done yet
because it needs to distinguish "this token is dead" from "you may not read
*this*" — a 403 on someone else's Dynamic must not sign you out. That
distinction needs the server's error codes, which are worth reading properly
rather than guessing at.

### App resume is not a session transition

After a long Android suspension the access token may have expired while the
timer never fired. `Session` still says `Authenticated` and the first
protected request races the refresh.

Needs an `AppLifecycleListener` that revalidates on resume. Small, but it
belongs with the 401 handler above — both are "the session is not what we
think" and should share one path.

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

Findings 11 (async work outliving disposal) and 12 (access token in public
state) are noted and judged low-value for now: both providers are
app-lifetime, and the token is read only by the transport. Worth revisiting
if session scope is ever rebuilt.
