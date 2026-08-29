# DESIGN_SYSTEM.md — Warm Authority V5

> ## ⛔ Owner design rules — 2026-08-28
>
> These override everything below them. Stated by the product owner after
> installing the build and finding the design generic.
>
> 1. *(reserved)*
> 2. **No descriptive text elements.** Added later; the work is small. Do not
>    fill space with explanatory prose.
> 3. **No blue/purple dark mode. No Claude styling** — that is: cream/off-white
>    ground + warm orange accent + retro serif headings. **This is exactly the
>    current palette and it must be replaced.**
> 4. **No large-radius rounded cards. No purposeless nested borders or cards.
>    Restrained shadows.**
>
> Everything in this file that conflicts with the four rules above is
> superseded. The palette and type below are kept for reference until the
> replacement direction lands, not as instruction.


**Source**: `docs/design/warm_authority_v5.html` — *D/s Relationship Companion — Warm Authority · High-Fidelity V5*.
This is the **current visual Source of Truth**, replacing the unreachable Figma file (see IMPLEMENTATION_STATUS B-001).

Authority split is unchanged: **visual expression → this document. Business logic / scope / state → Notion CURRENT v2.**

---

## 1. Color tokens

| Token | Hex | Role |
|---|---|---|
| `bone` | `#F4F1EB` | Primary light surface — screen background |
| `stone` | `#E7E3DA` | Secondary surface — chips, notes, soft cards |
| `warm` | `#BAB6AC` | Warm gray |
| `olive` | `#2F3A2E` | Authority surface — app bar, dark cards, primary CTA |
| `moss` | `#1E241F` | Deepest structure — bottom nav |
| `terra` | `#B5533B` | The single accent. Emphasis, seal, rails, active indicator |
| `ivory` | `#FFFDF8` | Card surface on light; text on dark |
| `ink` | `#1C231E` | Primary text |
| `muted` | `#74736E` | Secondary text |
| `line` | `#D8D2C8` | Rules and dividers |

Supporting values in use: card border `#E3DDD3` · dark card border `#354137` · dark divider/actions border `#536052` · outline button border `#C9C1B6` · actions divider `#E4DED5` · page backdrop `#EEEAE2` · muted-on-dark `#D2CCC1` / `#CFC8BE` / `#D8D1C7` / `#D4CEC4` / `#D3CDC2` · praise accent on dark `#D98B72` · screen label `#A69F95`.

Shadow: `0 18px 45px rgba(27,34,29,.14)`.

**Terracotta is scarce by design.** It appears only on: the eyebrow kicker, the 18×2 rule, the dark-card left rail, the seal, the active nav underline, the bond line, timestamps on ritual cards, and a small number of accent strokes inside symbols. Never as a fill for large areas, never as a button background.

*Light Life, Dark Structure* — bone/ivory for the living layer; olive/moss for authority and response moments.

---

## 2. Typography

| Role | Family | Notes |
|---|---|---|
| Display / serif | **Lora** (variable, SIL OFL) — `assets/fonts/Lora-Variable.ttf` | **Resolved (ADR-0001).** The V5 HTML's Iowan Old Style / Palatino stack is Apple system fonts — unlicensable for bundling. Notion 05 names Lora as the placeholder. Rovel Display deferred until licensed. |
| UI / body | **Inter** (variable, SIL OFL) — `assets/fonts/Inter-Variable.ttf` | All body, labels, buttons, nav. Variable axis covers the 600/650/700/750 weights the design uses. |

Scale as implemented:

| Class | Size / line-height | Use |
|---|---|---|
| `.h1` serif | 27px / 1.12 | Screen headline |
| `.h2` serif | 20px / 1.2 | Section headline |
| App bar title | 21px serif | Nav title |
| Card title serif | 17–21px | Card headline |
| `.bigquote` serif | 23px / 1.18 | Received acknowledgement quote |
| `.body` | 13px / 1.45 | Body copy |
| `.eyebrow` | 10px, letter-spacing .13em, weight 750, uppercase | Section labels; `.terra` variant for accent |
| `.fine` | 10px / 1.35, muted | Metadata, timestamps, helper text |
| `.tiny-terra` | 10px, weight 700, terracotta | Time emphasis |
| Button | 12px, weight 650 | CTA |
| Nav item | 9px, weight 600 | Bottom nav |
| Status bar | 11px, weight 650 | Device chrome |
| Screen label | 9px, letter-spacing .1em, uppercase | Annotation only — not app UI |

---

## 3. Layout & shape

- Device frame: **390 × 844**, radius 34, 1px border `#353C36`.
- **Top bar 112px** (olive): 18px status row + 76px app bar. App bar title centered; 24×24 left/right icon slots at `top:29px`.
- **Content area**: inset between top bar and nav, **padding 20px** (matches Notion 05's 20dp horizontal padding).
- **Bottom nav 68px** (moss), 4 equal columns, 18×18 icons, active item ivory with a 28×2 terracotta underline.
  Tabs are fixed: **Today · Dynamic · Explore · Us** (Notion 02 §2). **Attention is not a tab** — Today already
  means "what needs me today", and it shows the direction-giving face when the server reports work waiting on
  this member. Explore keeps its slot as a light placeholder even though the full library is out of Core Beta
  (Notion 01 §7): dropping it now would force the whole shell to be rebuilt when the library lands.
- **App bar 76px** (olive), centred serif title, 24×24 icon slots. Sub-screens carry a back control — the Android
  system button does not exist on iOS Safari or the web build.
- Card radius **10**, padding `14px 15px`, border 1px. Consecutive cards `margin-top: 10px`.
- Button height **48dp**, radius 7. *(V5 renders 42px; overridden per ADR-0001 D-2 — 48dp is the Android minimum touch target and Notion 05 states 48–52dp. Extra height absorbed in vertical padding; proportions unchanged.)*
- Icon stroke: 1.55 for app bar, 1.45–1.5 for section/nav, no fill, round caps and joins.
- Rules: 1px `line`, 16px vertical margin. Accent rule 18×2 terracotta.
- Spacing utilities in 2px steps from 6 to 22 — the design's rhythm is **6 / 8 / 10 / 12 / 16 / 18 / 22**.

---

## 4. Components

**`.card`** — ivory, 1px `#E3DDD3`, radius 10.
**`.card.dark`** — olive on ivory text, border `#354137`. The authority/response surface.
**`.card.stone`** — stone, borderless. Soft secondary content (check-in).
**`.dark-rail`** — 3px terracotta bar on the left edge of a dark card, radius `10 0 0 10`. Marks *waiting* and *needs response*.
**`.actions`** — full-bleed footer row inside a card, split by 1px dividers, 12px padding, 11px/650 labels. Two-up: `View | Respond`, `Acknowledge | Praise`.
**`.seal`** — 43px terracotta disc, "D/s", Georgia 11px, 2px translucent white border plus inset ring. The ritual identity mark. Used sparingly: partner invitation card, received acknowledgement card.
**`.quote-block`** — 2px terracotta left bar, 14px padding-left. For partner-authored text.
**`.quote-mark`** — Georgia 32px terracotta open-quote, positioned absolutely, with the following line pulled up (`margin-top:-15px`) to nest under it.
**`.partner-bond`** — two 30px overlapping gradient avatars (`-8px`), an 18×2 terracotta bond line with a 5px dot, then a caption. The presence signal.
**`.chips`** — equal-flex 38px stone pills, radius 20, 10px/700 olive. `.chip.out` is the transparent/bordered muted variant for deferred items.
**`.note`** — stone block, radius 8, `12px 14px`, 11px muted. Privacy and system-suggestion framing.
**`.button`** — olive fill, ivory text. `.outline` is transparent with a `#C9C1B6` border and olive text.
**`.section-title`** — 21px stroked icon + eyebrow + value, 9px gap.

### Brand marks (inline SVG, no raster assets)
- **Ritual Emblem** — circle + vertical axis + terracotta arc + terracotta center dot.
- **Authority Mark** — shield with a vertical stroke and a terracotta node at the crown.
- **Presence Mark** — concentric circles inside a lens/eye form, terracotta inner ring.
- **Botanical line motif** — fern/branch line drawing, used as `.illustration` at **opacity .09** or `.watermark` at **.07** (`.12` on dark).
- **Bond mark** — the `.partner-bond` avatar pair + connector.

All marks are 1.1–1.6 stroke weight, unfilled except for small terracotta nodes. **No handcuff, whip, chain, flame, crown, demon, leather, or 3D/gloss anywhere** — consistent with Notion 05 §9.

---

## 5. Screens specified

| # | Screen | Primary question | Notes |
|---|---|---|---|
| 1 | **Today** (receiving) | What matters for me today? | Greeting → today's intention → Next ritual → Partner invitation. Bottom nav present. |
| 2 | **Expectation Detail** | What is this and where is it now? | Eyebrow category → title → partner quote → When → Rhythm → privacy note → `Complete` + `Need to discuss` / `Request reschedule`. |
| 3 | **Completed / Waiting** | What happens after I finish? | "Done — now it can be seen." Dark rail card: *Waiting for human response*. Outline `Back to Today`. |
| 4 | **Attention** (direction-giving) | What needs my human response? | "2 things need you." + counts chips → Needs your response (dark) → Check-in (stone) → Later. |
| 5 | **Respond** | How do I respond quickly but genuinely? | Suggestion card + explicit *Wording suggestion* note → `Send acknowledgement` → `Discuss instead`. |
| 6 | **Acknowledgement Received** | — | "You were seen." Dark quote card with seal. Bottom nav present. |

These six map exactly onto the Core Beta human-response loop and cover the M1 vertical slice screens.

---

## 6. How the design enforces the product red lines

The V5 file is not just visual — it encodes the product boundaries, and implementation must preserve these:

1. **Completion ≠ Acknowledgement** — Waiting screen states it in copy: *"The action is complete. The relationship moment is not finished until your partner responds."*
2. **Automation prepares; the partner responds** — the Respond screen labels the pre-written text **"Wording suggestion"** with *"Use it as a starting point — your partner should still hear from you."* System suggestion is visually and verbally separated from human speech. This is the single most important detail in the file.
3. **Adjustment is a normal path** — `Need to discuss` and `Request reschedule` sit directly under the primary CTA on Expectation Detail, not hidden in an overflow menu. `Discuss instead` sits under `Send acknowledgement`.
4. **Privacy is explicit** — *"Private by design — Only you can see your private notes."* rendered inline on the detail screen.
5. **Human response is visibly human** — partner text always appears in a quote block with the terracotta bar, attributed ("From Alex"), timestamped, and paired with the bond mark.
6. **No gamification** — zero points, streaks, scores, trophies or progress bars anywhere in the file.

---

## 7. Deviations from Notion 05 (must be resolved)

| # | Notion 05 says | V5 HTML does | Proposed resolution |
|---|---|---|---|
| D-1 | Display font **Rovel Display**, Lora placeholder | `Iowan Old Style / Palatino / Georgia` system serif | **RESOLVED (ADR-0001)** — bundle **Lora + Inter**, both SIL OFL, installed at `assets/fonts/` with license files. Apple system fonts cannot be bundled. Rovel Display revisited only if licensed. |
| D-2 | Primary CTA **48–52dp** | Button height **42px** | **RESOLVED (ADR-0001)** — implement at **48dp**. Accessibility outranks a mockup pixel value. Flag in the first UI Review Entry. |
| D-3 | Terminology: "Ritual", "Expectation" | Today screen says *"Good morning, Sir."* | **RESOLVED (ADR-0001)** — render a **neutral greeting**. Hardcoding an honorific would make the system speak in the Dom's voice, violating *Automation prepares; the partner responds*. Becomes user-configured content when a setting exists. |
| D-4 | — | Attention screen shows *"1 proposal can wait until tomorrow."* | **Proposal is explicitly out of Core Beta** (01 §7, 02 §4: "Core Beta 不做 Proposal inbox"). This line must **not** be implemented. Notion wins — it is scope, not visual. |
| D-5 | — | Detail screen shows *"no proof requested"* | **Proof is P1** (01 §7). Do not implement; omit the phrase entirely. |
| D-6 | — | Today shows a "Partner invitation / Confirm availability" card | Not a Core Beta object. Closest legitimate mapping is an `AdjustmentRequest` or a scheduling ask; without a canonical object, **do not build** in M1. Raise in Review. |

**Rule applied**: D-4, D-5, D-6 are scope/state conflicts → **Notion CURRENT v2 wins**. D-1, D-2, D-3 are visual/content and were resolved in **ADR-0001**, defaulting to Notion where accessibility, licensing or product voice is implicated.

**All six deviations are now closed.** No open design decisions remain.
