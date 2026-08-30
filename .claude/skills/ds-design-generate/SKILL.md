---
name: ds-design-generate
description: Produce a missing screen design for the D/s Relationship Companion — brief Codex with reference images, review what comes back against the frozen house style, then render the full state family deterministically. Use whenever a screen has no design, only a reference image, or an incomplete state family; whenever a build gate is closed for a design reason; and whenever sending images to Codex (they must be compressed first).
---

# Producing a missing design

The design system is frozen and the house style is settled. That means a screen
with no state family is **production work, not a decision waiting on the
owner**. Generate it, review it, render it, commit it — then hand the owner a
gate decision they can make in a minute because the renders are in front of
them.

The one thing that still stops you is a genuine product question: a red line, a
state whose meaning nobody has decided, a flow contradicting a requirement.
"Nobody has drawn this yet" is not one of those.

Read `ds-design-lookup` for where the frozen values live and `ds-screen-build`
for what happens after the gate opens. `ds-pitfalls` has the mechanics of
invoking Codex (stdin, sandbox, plugins) — do not re-derive them here.

## Always compress images before sending them to Codex

Measured on a real 1170×2532 design source in this repo:

| Sent as | Bytes | Share of original |
|---|---|---|
| original `source.png` | 187,422 | 100% |
| **390×844 WebP q82** | **14,578** | **7.8%** |
| 585×1266 WebP q82 | 24,872 | 13.3% |
| 390×844 JPEG q80 | 25,311 | 13.5% |

**Send 390×844 WebP.** It is 13× smaller and still fully legible — type, marks,
timeline and button states all read clearly at review size. Design sources are
authored at 3× device scale; that resolution is for rendering, never for review.

```bash
python3 - <<'PY'
from PIL import Image
import sys, os
src, dst = sys.argv[1], sys.argv[2]   # or hard-code the pair
im = Image.open(src).convert('RGB')
w = 390
im.resize((w, round(im.height * w / im.width)), Image.LANCZOS) \
  .save(dst, 'WEBP', quality=82, method=6)
print(f"{os.path.getsize(src)} -> {os.path.getsize(dst)} bytes")
PY
```

Put the compressed copies in the scratchpad, never in `design/`. Sending several
images in one brief multiplies this, so it is exactly when it matters most.

## The loop

### 1. Find out what is actually missing

`design/screens/SCR-XX-*/screen.md` states the contract and the state matrix.
Compare it against what exists on disk:

```bash
ls design/screens/SCR-XX-*/candidates/*/           # candidates and renderers
ls design/screens/SCR-XX-*/candidates/*/states/    # which states are rendered
```

Three distinct situations, and they need different work:

| On disk | Missing | Do |
|---|---|---|
| A renderer and some states | The rest of the family | Skip to step 4 — just render them |
| A candidate image, no states | The state family | Steps 2–4 |
| Only a reference image, or nothing | The screen | Steps 2–4, with more reference |

Do the cheapest one that applies. A committed renderer that simply was never run
for every state is not a design problem.

### 2. Brief Codex with reference, not with instructions

Codex designs well when shown the neighbourhood and badly when told to invent.
The brief carries four things:

1. **Reference images, compressed** — the nearest built screen (`SCR-01` is the
   only fully realised one), the screen's own reference board, and any adjacent
   screen in the same journey.
2. **The frozen values it must not invent** — point at
   `design/tokens/B2-FREEZE.md`, `design/system/spacing.md`,
   `design/system/type-in-practice.md`, and the SVG registry. Say that colours,
   type roles, spacing and marks are already decided.
3. **The product contract** — the screen's `screen.md`, the relevant `REQ-*`,
   and any red line the surface touches. Behaviour is specified, not designed.
4. **The exact state list** — name every state. An unnamed state comes back
   undesigned.

Write the brief to `BRIEF.md` in the candidate directory and keep it. It is the
record of what was asked, and the next revision starts from it.

Codex needs `--sandbox workspace-write` to write files, `-i` per image, `--` to
separate images from the prompt, and `< /dev/null`. See `ds-pitfalls`.

### 3. Review before accepting — two or more directions, then pick

Ask for **more than one direction** when the screen has any real freedom in it,
then judge them side by side. A single returned design gets accepted by default;
two get compared, which is where the actual decision happens.

Judge against the house style, in this order:

- **Does it obey the freeze?** Any hex that is not a token, any size off the 4dp
  grid, any type role invented — reject that part outright, it is not a matter
  of taste.
- **Does it read as this product?** Warm Authority / Quiet Authority: editorial
  serif for the human voice, operational sans for system labels, restraint over
  decoration. A screen that could belong to a productivity app is wrong even if
  every token is legal.
- **Does it hold the red lines?** Completion is never acknowledgement. The
  system never speaks in the partner's voice. Adjustment sits beside completion,
  never beneath it.
- **Does the state family cover recovery?** loading / empty / error / offline /
  stale / authorization-lost. A family that only draws the happy path is half a
  design and will block the build later.

Send the shortlist back to Codex for a critical pass — it is good at seeing what
you have stopped seeing — but the choice is yours, and say plainly which
direction won and why in `design-qa.md`.

### 4. Render the family deterministically

Hand-made one-off images drift. Every state comes from a committed renderer, so
the family can be regenerated and diffed:

- Write `render-<screen>.cjs` in the candidate directory, resolving colours
  through `design-tokens.json` and marks through the SVG registry — never a
  literal hex.
- **`fonts.cjs` first.** `sharp` ignores `FONTCONFIG_FILE`; without
  `install()` the renders silently come out in Inter instead of Cormorant, and
  `assertDisplayFaceResolves(sharp)` is what catches it.
- Render **every** state named in `screen.md`, not a sample. A committed
  renderer with two of eighteen states rendered looks finished and is not.
- Check a render back in at 390×844 and actually look at it.

### 5. Commit, then ask for the gate

Commit the brief, the candidate, the renderer, the full state family and a
`design-qa.md` that states the acceptance criteria. Then tell the owner the
screen is ready for a gate decision and show the renders.

**Never set `build_gate` yourself.** That is the one part of this loop that
stays the owner's.

## What this does not authorise

- **Tracing or redrawing an SVG master from a raster.** Absolute, no exceptions.
  A new master is its own freeze process.
- **Inventing product behaviour.** If the design needs a rule nobody has
  decided — what a state means, who may see something, what happens on tap —
  that is the escalation case. Ask.
- **Changing a screen's gate, or a red line, to make a design work.** If the
  design fights a red line, the design is wrong.
