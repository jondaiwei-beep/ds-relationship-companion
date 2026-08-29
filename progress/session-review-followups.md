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

Both of the items that were here are now done — see the table below. What
remains deferred is the Web origin decision above, which is not a client fix.

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
