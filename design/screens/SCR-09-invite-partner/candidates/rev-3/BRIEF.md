# SCR-09 rev-3 — the four blocked states

## What is being asked for

Four lifecycle states are approved in rev-2 — **Pending** (default),
**Accepted**, **Expired**, **Revoked**. Four remain `blocked`:

| State | Product rule | UI requirement |
|---|---|---|
| `loading` | Resolve server current truth | Preserve lifecycle geometry **without revealing stale state** |
| `share-error` | Retain the current Invite and retry safely | **Never create duplicate active links silently** |
| `offline` | No state mutation without server confirmation | Explain availability and safe retry |
| `authorization-loss` | Hide protected Dynamic context | Offer sign-in/session recovery |

## How this screen differs from SCR-10, which you already designed

SCR-10 is the **receiving** side: pre-authentication, opened from a link,
possibly on someone else's device, and the person may not be entitled to see
anything. Its recovery states withhold almost everything.

SCR-09 is the **sending** side: the person is authenticated, inside their own
Dynamic, and **owns this invitation**. Withholding their own content from them
would be wrong — it is not privacy, it is losing their work. The two screens
therefore diverge, and only `authorization-loss` behaves like SCR-10.

## The composition to preserve

From the attached rev-2 states:

- **Header**: back arrow, `Private invitation` centred, and a status word top
  right (`PENDING` / `REVOKED`) in `label.ritual`.
- **The bond mark** at the top. In Pending the two rings overlap with a
  Terracotta point at the centre; in Revoked they have separated and the point
  is gone. It carries the relationship's state, so it is never decorative.
- **The Cormorant headline** — `display.ritual`, one thing centred and alone.
- **The four-node lifecycle track** near the bottom: Pending — Accepted —
  Expired — Revoked, current node filled. This is the "lifecycle geometry" the
  contract says `loading` must preserve.

## The hard part, per state

**`loading`** — the contract says *preserve lifecycle geometry without
revealing stale state*. The track must hold its position on the page so nothing
jumps when truth arrives, but it must not assert which node is current, because
the last-known one may now be wrong. Do not show the private link or code while
unresolved.

**`share-error`** — the sharpest rule on this screen: *never create duplicate
active links silently*. A failed share must not leave the person suspecting they
need to make a new invitation; the existing one is still live and still valid.
Retry re-shares **the same** invite. The distinction between "the share sheet
failed" and "the invitation failed" has to be legible, because they are not the
same event and only one of them is alarming.

**`offline`** — no state mutation without server confirmation. Revoke in
particular must be unavailable, not queued: a revoke that appears to succeed
offline and then does not is the worst outcome on this screen. Copy link is
still safe — the code is already on the device.

**`authorization-loss`** — the only state that hides Dynamic context. It behaves
like its SCR-10 sibling (attached): no partner name, no invite code, no
lifecycle position.

## What is already decided — do not invent it

| Concern | Where it is frozen |
|---|---|
| Colour semantics, control geometry, Terracotta floor | `design/tokens/B2-FREEZE.md` |
| Marks, licensed sizes and tones | `manifests/svg-freeze.v1.json` |
| 4dp grid, control heights | `design/system/spacing.md` |
| Type roles | `design/system/type-in-practice.md` |
| Contract, state matrix, asset list | `design/screens/SCR-09-invite-partner/screen.md` |

Registered for this screen: `mark.partner-bond`, `icon.share`, `icon.copy`,
`icon.revoke`, `state.invite-accepted`, `state.invite-expired`,
`state.invite-revoked`, `motif.botanical.invite-branch`. **Do not use a mark
that is not on this list** — check `used_by` in `manifests/assets.json` before
proposing one.

On type: `display.partner` is an authorship test (only words a person wrote and
sent). `display.ritual` is a compositional one — one thing, centred, alone —
and system-authored headlines take it. Both the rev-2 states and SCR-10 rev-3
use `display.ritual` this way.

## Red lines this surface touches

- No invented urgency. A failed share is not an emergency.
- The system never speaks in the partner's voice. Morgan's name is a fact here,
  never a quotation.
- A failure is recoverable, never a dead end (`product/ui-invariants.md`).

## Reference images (attached, 390×844)

1. `scr09-pending` — the approved default, with the full composition
2. `scr09-accepted` — approved
3. `scr09-revoked` — approved; shows how the mark and track change at closure
4. `scr10-offline-sibling` — the receiving side's offline, for family coherence
5. `scr10-authloss-sibling` — the receiving side's authorization loss

## Deliverable

For each of the four states: composition, hierarchy, what is shown and what is
withheld, exact copy, and the frozen token or mark for each element.

Give **two directions** for `share-error` and for `loading` — those two carry
the real difficulty. Say which you would choose and why.
