# SCR-10 rev-3 — the five blocked recovery states

## What is being asked for

Three states are approved in rev-2: **default trust review**, **auth return**,
**expired**. Five remain `blocked` in the contract's state matrix and are the
whole of this brief:

| State | Product rule | UI requirement |
|---|---|---|
| `revoked` | Invite unavailable or access relation changed | Neutral safe landing, no sensitive content |
| `loading` | Resolve token and current server truth | Stable privacy-safe loading surface |
| `error` | Recover without dropping invite context | Explicit retry, retained safe context |
| `offline` | Cannot confirm current invite truth | Explain offline; never infer validity |
| `authorization-loss` | Session absent, expired or wrong account | Hide protected content, safe account recovery |

## Why this screen is unusual

This is the **only pre-authentication surface that renders relationship
content**, and it opens from a link in a browser on someone else's device as
often as not. Every state has to answer one question first: *what may a person
who is not yet authenticated be shown?*

`REQ-INVITE-001` — Pending / Accepted / Expired / Revoked must all resolve from
the server. **An opaque 404 is forbidden.** `revoked` is newly reachable: a
revoke endpoint now exists, so this state is live, not theoretical.

`REQ-JOIN-001` — the invited person must not repeat the creator's onboarding.

`REQ-PRIVACY-001` — three-state visibility.

## Absorb SCR-11's trust language

SCR-11 (Mutual Consent) is `blocked` and its own contract says: *"Do not build
independently; merge the useful trust language into SCR-10"* and *"do not imply
role grants consent."* So the trust framing belongs **here**, in the default
review — not as a second screen. Do not design a separate consent step; do not
add a consent certification claim.

## What is already decided — do not invent it

| Concern | Where it is frozen |
|---|---|
| Colour semantics, control geometry, Terracotta floor | `design/tokens/B2-FREEZE.md` |
| Marks, licensed sizes and tones | `design/assets/svg/SVG-FREEZE.md`, `manifests/svg-freeze.v1.json` |
| 4dp grid, control heights | `design/system/spacing.md` |
| Which role each kind of content takes | `design/system/type-in-practice.md` |
| This screen's contract and asset list | `design/screens/SCR-10-invitation-received/screen.md` |

Cormorant Garamond is selective editorial/ritual typography; Inter is
operational UI. Terracotta is relational/human emphasis, never a generic action
colour. Visual direction is **V5 Warm Authority / Quiet Authority**.

## Red lines this surface touches

- The system never speaks in the partner's voice. The inviter's name is a fact;
  it is never a quote.
- No invented urgency. An expired or revoked invite is not an emergency and must
  not be styled as one.
- Never imply that accepting confers a role, or that a role confers consent.

## Reference images (attached, 390×844)

1. `scr10-default` — the approved rev-2 default trust review
2. `scr10-expired` — approved; the nearest existing recovery state
3. `scr10-auth-return` — approved
4. `scr09-invite` — the sending side of this handshake
5. `scr01-today` — the only fully built screen; the house style in practice

## Deliverable

For each of the five states: the composition, the hierarchy, what is shown and
— more importantly — **what is withheld**, plus the copy. State plainly which
frozen token and which mark each element uses.

Where a state has real freedom, give **two directions** and say which you would
choose and why. `revoked` and `authorization-loss` are the two worth exploring:
both must be safe landings that neither leak nor accuse.
