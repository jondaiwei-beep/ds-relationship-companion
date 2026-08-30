# Core loop candidate rev-3 · acceptance criteria

What must be true for SCR-02 / SCR-33 / SCR-03 to count as built. These three
carry red lines #1 to #3, so most of what follows is behaviour a
correct-looking screen can still get wrong.

## Measured

| Check | Result |
|---|---|
| Every state fits 390 × 844 | **pass** — 18/18; content ends at 791dp on the composer, whose sheet reaches the edge by design |
| Marks at a frozen size and licensed tone | **pass** — enforced by the renderer, which throws otherwise |
| Colour resolves through B-2 | **pass** — no literal except via `token()` |
| Display face is Cormorant | **pass** — verified at render time |

The tone licences are doing product work here, not just styling.
`state.completed` licenses only `primary`; `state.waiting-response` and the
four response marks license `relationship`. Completion is not warmth from a
partner, and the freeze already said so.

## Behaviour

1. **Completion is never acknowledgement.** The two-node line says it before
   any copy does: `COMPLETED` filled, the second node hollow until a person
   answers. The second node may not fill on completion, on a timer, or on
   anything but a real response.
2. **Only an explicit Send creates an acknowledgement.** Selecting a type
   sends nothing. Typing sends nothing. Closing the sheet sends nothing.
3. **Two taps is a complete response.** Acknowledge or Praise with no words
   must reach the server. Comment and Review require words and say so before
   the request goes out; the server also refuses them with `TEXT_REQUIRED`.
4. **A wordless acknowledgement is never given invented wording.** It renders
   as "Morgan acknowledged this." — no quotation marks, no generated
   sentence. This is where red line #2 lands in the render.
5. **The partner's words are visually distinct from every system line.**
   Terracotta Cormorant at 24sp, which is also the floor the token freeze
   sets for Terracotta text.
6. **"Not now" sends nothing and records nothing.** Silence is not a
   response; storing a refusal to respond would make it one.
7. **The private note is readable by its author and by nobody else.** Both
   halves are tested server-side.
8. **A conflict is not a failure.** 409 `OCCURRENCE_NOT_ACTIVE`,
   `OCCURRENCE_NOT_WAITING_ACK` and `OCCURRENCE_ACKNOWLEDGED` each get their
   own state, phrased as what happened rather than as an error, and none of
   them offers a retry that cannot work.
9. **Unsent words survive a failure and never survive sign-out.** A retry
   keeps what was typed; authorization loss clears it.

## Deviation from the approved composition, deliberate

Revision 1 of SCR-33 shows the text area **pre-filled** with "I noticed your
care and intention tonight." This candidate makes it a chip outside the
field instead.

Being able to edit prose is not the same as having chosen it — Send would
read as agreement to the system's wording, which is what red line #2 exists
to prevent. The screen's own contract already requires suggestions to stay
"visibly system-provided" and "visually subordinate until an explicit send",
so the picture and its contract disagreed. This resolves it toward the
contract, and it is the change most in need of a decision.

## Not covered

- **SCR-32 Attention has no design at all.** It is the surface the composer
  is reached from, so the loop has a hole in the middle of it.
- **`NEEDS_REVIEW`.** `REQ-REVIEW-001` says past-due work enters review and
  that the software assigns no punishment. No screen expresses either half.
- **Web adaptation.** These are 390 × 844.
- **The four response types beyond their icons.** What distinguishes Review
  from Comment in the receiving screen is unspecified.
