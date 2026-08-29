# Three alternative visual directions

These are alternatives to **Hinge / Reply**, not extensions of it. None uses its 64 dp context column, persistent hinge rule, dark full-width Reply Plane, lichen registration mark, or the rule that a serif means only “verified partner response.” All dimensions below are Flutter logical pixels. Phone specifications use a 390 × 844 reference viewport; at 600–839 dp use 24 dp page insets, and at 840 dp or wider center the working composition in a 720 dp column. Minimum touch target is 48 × 48 dp in every direction.

Across all three, notifications default to `New update`; lock-screen previews never expose a partner name, the action, or the words. The browser title, app-switcher label, URL, and icon use a neutral product codename. No direction uses points, streaks, scores, progress, badges, sexualized iconography, generated people, gradients, blobs, glass, grain, faux texture, large-radius cards, nested containers, or ornamental shadows.

---

# Direction 02 — Across / Two Edges

## 1. Thesis

**Across** treats the phone as space held between two people. Content is not grouped by “task status”; it is placed according to whose move it is. Expectations originating with the direction-giving partner begin from the left edge, completed actions and waiting states begin from the right, and a received response is the only object allowed to cross the quiet central gutter. The claim is that the app is not a manager sitting above the couple: it is a restrained channel between two distinct people. The interface stays calm because ordinary items never become cards, while the movement from one edge to the other makes reciprocity legible even in grayscale.

## 2. Palette

### Light

| Role | Hex | Use |
|---|---:|---|
| `canvas` | `#F5F7F6` | Cool white page and system-bar ground; never beige. |
| `ink` | `#16201C` | Primary text, icons, primary controls. |
| `inkSoft` | `#3F4A45` | Secondary state and section labels. |
| `muted` | `#6E7974` | Time, inactive navigation, placeholders. |
| `line` | `#C9D0CD` | List terminators and input boundaries only. |
| `leftField` | `#E4EBE7` | A shallow source band for Alex-originated expectations; never an enclosing card. |
| `rightField` | `#EDF0EE` | A shallow destination band for completed/waiting items. |
| `accent` | `#008A63` | Focus, unread dot, selected nav, send confirmation. |
| `accentInk` | `#FFFFFF` | Text/icons on `accent`. |
| `humanInk` | `#005C48` | Partner words on `canvas`; large text only. |
| `critical` | `#B52B42` | Error and destructive action only. |

### Dark

| Role | Hex | Use |
|---|---:|---|
| `canvas` | `#101512` | Neutral green-black page; not navy or purple. |
| `ink` | `#F1F5F2` | Primary text and icons. |
| `inkSoft` | `#C2CCC7` | Secondary state and labels. |
| `muted` | `#93A098` | Time and inactive navigation. |
| `line` | `#354039` | Functional rules and field boundaries. |
| `leftField` | `#1B2721` | Alex-originated source band. |
| `rightField` | `#171E1A` | Completed/waiting destination band. |
| `accent` | `#35D3A0` | Focus, unread dot, selected nav. |
| `accentInk` | `#06231A` | Text/icons on `accent`. |
| `humanInk` | `#72E1BD` | Partner words on `canvas`. |
| `critical` | `#FF7688` | Error and destructive action only. |

Supported text pairs are `ink`/`canvas`, `ink`/`leftField`, `ink`/`rightField`, `humanInk`/`canvas`, and `accentInk`/`accent`. Do not use the green accent as paragraph copy or section fill.

**What carries identity without the accent:** opposing alignment and the empty 24 dp shared gutter. Left-originating content stops before it; right-side content begins after it; only a real partner response spans it. Removing all colour still leaves a recognisable two-person composition.

## 3. Type

Bundle **Manrope** and **Literata**, both OFL faces available through Google Fonts.

- **Manrope** is the application’s voice: navigation, screen names, dates, counts, status, controls, people, and validation.
- **Literata** is for authored relationship content from either person: an expectation such as `Evening check-in message`, a completed action title, and received partner words. It is not proof of who wrote something. Automated suggestions, Explore titles, empty states, and buttons must remain Manrope.
- Partner words are distinguished by their crossing geometry and scale, not merely by changing face. This is deliberately different from Hinge / Reply’s “serif equals received human words” rule.

| Token | Face | Size / height | Weight | Use |
|---|---|---:|---:|---|
| `screen` | Manrope | 29 / 34 | 650 | Screen title. |
| `section` | Manrope | 12 / 16 | 700 | Uppercase operational label, tracking `1.1`. |
| `authoredTitle` | Literata | 22 / 28 | 500 | Expectation or completed action. |
| `body` | Manrope | 16 / 23 | 450 | Form values and necessary copy. |
| `state` | Manrope | 14 / 19 | 600 | Actionable status. |
| `meta` | Manrope | 12 / 17 | 550 | Sender and time; tabular figures. |
| `button` | Manrope | 15 / 20 | 700 | Controls. |
| `nav` | Manrope | 11 / 15 | 650 | Bottom navigation. |
| `crossingWords` | Literata | 31 / 38 | 520 | Partner words on Today. |
| `crossingWordsHero` | Literata | 43 / 50 | 520 | Received screen, responsive 36–48. |

Preserve authored capitalization and punctuation. Do not add quotation marks, italics, or a generated preface.

## 4. Structural device

### Opposite edges

The usable phone width is 358 dp after 16 dp outer insets. Divide it into `167 left + 24 quiet gutter + 167 right`. The gutter is empty canvas: no line, seam, icon, colour, or decoration.

- **Origin / expectation:** left edge at x = 16; width 274 dp, ending 84 dp before the right screen edge. Text is left-aligned. A 6 dp-deep `leftField` band may run edge-to-edge behind the item’s top 56 dp, but it is a band, not a bounded surface.
- **Your action / waiting:** right edge at x = 374; width 274 dp, beginning at x = 100. Text is right-aligned; trailing controls remain right-aligned. Its optional shallow band uses `rightField`.
- **Shared system elements:** screen title and navigation use the full width and align left. Counts are positioned on the edge belonging to the person who must act.
- **Received response:** the sole `Crossing` form begins at the sender’s edge and crosses the 24 dp gutter to the receiver’s edge. It may occupy the full 358 dp.

This is not a chat layout: do not alternate bubbles, add tails, use avatars, or reduce content to short message capsules. Alignment encodes responsibility, not a conversation transcript.

### Bounds, density, and borders

- Page spacing steps: 4, 8, 12, 16, 24, 32, 40, 56.
- Ordinary item height: 88–116 dp with 16 dp internal vertical padding. Items are separated by 24 dp empty canvas, not boxed.
- A 1 dp horizontal `line` may terminate a repeated list only when two or more items share the same owner edge. It runs for that item’s 274 dp width, never page-wide. No top border.
- Input boundaries and modal boundaries may use 1 dp `line`; keyboard focus uses a 2 dp `accent` boundary. Buttons have 2 dp radius. Menus and system dialogs have 4 dp radius. All content surfaces have 0 radius.
- No normal content shadow. A modal may use `0 8 24 #00000024`.
- At widths below 350 dp or text scale above 1.3, keep ownership alignment but let both item widths grow to full width. Preserve the 24 dp gutter as a 24 dp vertical pause between owner changes. Do not squeeze text into two narrow columns.

## 5. Partner words — `Crossing`

`Crossing` is used only for a received, human-authored partner message. Its API must require a verified `HumanMessage`; drafts and automated text cannot instantiate it.

- No fill, border, radius, shadow, quote marks, or icon.
- Sender and time sit on the sender edge in Manrope `meta`, `muted`.
- Words start 16 dp below, span the full page inset width, and use Literata `crossingWords` in `humanInk`.
- The last line is aligned to the receiver’s edge: on a left-to-right phone, set the paragraph width to 358 dp and right-align only the final line with a custom `TextPainter` line break. If localization or dynamic type makes that unsafe, right-align the entire paragraph; never manually alter the words.
- A 12 × 12 solid `accent` square sits exactly in the quiet gutter, vertically aligned with the first text baseline. This square exists nowhere else. It is hidden from semantics.
- Compact minimum height is 148 dp. On Received it expands to the available height.
- Accessibility reads: `Message from Alex, received at 8:06 PM: I noticed the care you put into this.`

The visual event is literal crossing: Alex’s words begin from Alex’s side and finish on the side of the person receiving them.

## 6. Today, applied

Reference viewport: 390 × 844. Bottom nav begins at y = 760 before safe-area adjustment.

1. **Header, y = 44–100.** `Today` at x = 16, y = 58 in Manrope 29/34, `ink`. `FRI 28` at x = 374, right-aligned in `meta`, `muted`. No greeting.
2. **Partner message, y = 112–274.** `Crossing` spans x = 16–374. At y = 112: `ALEX` left and `8:06 PM` right in 12/17 `muted`. The unique 12 dp square is at x = 189, y = 143. Words begin y = 144: `I noticed the care you put into this.` in Literata 31/38 `humanInk`, maximum three lines. At y = 250, right-aligned metadata: `Prepare the evening space`, Manrope 12/17 `muted`. There is no dark plane.
3. **Needs response, y = 306–370.** Right-owned operational entry. A 6 dp-deep `rightField` band runs x = 100–390 at y = 306–362. At x = 374, right-aligned, `2 things need your response` in Manrope 17/23 weight 650, `ink`. A 48 dp chevron target sits at x = 326–374 without a circle or box. Tapping opens the two real rows; there is no subtitle.
4. **Expectation for today, y = 402–510.** Section label `TODAY` at x = 16 in `section`, `inkSoft`. The left-owned item starts y = 430. A shallow `leftField` band runs x = 0–290 behind the first 56 dp. `ALEX` in `meta`; `Evening check-in message` below in Literata 22/28, `ink`. If the item itself needs an action, place a 48 dp target at the left edge below the title; do not use a trailing card affordance or explanatory line.
5. **Waiting on partner, y = 550–650.** Section label `WAITING` at x = 374, right-aligned. The right-owned item is x = 100–374, right-aligned: `Tidy the entryway` in Literata 22/28; `Completed · waiting for Alex` in Manrope 13/18 `muted`. Use only the shallow `rightField` band. No container.
6. **Bottom nav, y = 760–844.** `canvas`, 1 dp top `line`, no shadow, 84 dp including safe area. Four equal destinations: Today · Dynamic · Explore · Us. Icons are 21 dp, 1.75 dp stroke. Active Today uses `ink` plus a 4 × 4 `accent` square centered 6 dp above its label; inactive items use `muted`. The 12 dp Crossing square is never reused here.

On web, the two owner edges attach to the centered 720 dp composition, not to the browser window. Keyboard traversal follows visual top-to-bottom order, never left/right ownership order.

## 7. Received, applied

This screen is open space crossed by Alex’s words, not a confirmation panel.

- **0–64:** `canvas`. A plain 48 dp back target at x = 8; no top app bar fill. `ALEX` at x = 16 and `8:06 PM` at x = 374, baseline y = 58, `meta`, `muted`.
- **64–676:** `Crossing` uses all available space. The 12 dp square sits at x = 189, y = 176. The verbatim words begin x = 16, y = 206 in Literata 43/50, `humanInk`, max width 358: `I noticed the care you put into this.` Position the block at 24% of usable height, not mechanically centered. The final line lands at the right edge. Long messages scroll between y = 104 and 632 without shrinking below 36 sp.
- **Context, y = 640–692:** right-aligned `Prepare the evening space`, Manrope 13/18 `muted`. No “You were seen,” “received,” celebration, or icon.
- **Action dock, y = 708–844:** 1 dp top `line`, `canvas`, 16 dp padding. A 52 dp primary control reads `Today`, `ink` fill, `canvas` text, radius 2. If human reply is supported, a text-only `Reply` can sit to its left and must open an empty composer.
- In dark mode the screen stays on `canvas #101512`; the partner words use `#72E1BD`. Do not invert to a light plane—the spatial crossing, not a colour flip, is the peak.

## 8. Cost and risk

The ownership model must be correct in data, including nonbinary role language and couples who swap roles; a simplistic “Alex is always left” mapping would become false or coercive. Right-aligned longer action titles are less familiar and may slow scanning. Custom last-line alignment in `Crossing` is difficult with Flutter’s `TextPainter`, localization, selectable text, and 200% text scale; the documented safe fallback is essential. The sparse, asymmetrical composition may alienate people who prefer conventional lists, and it can look accidentally empty if content density is not tightly art-directed. Its advantage is that the relational model remains visible without turning the product into chat or project management.

---

# Direction 03 — Register / Time Cuts

## 1. Thesis

**Register** makes the product a record of what happened, what is next, and where a human answer interrupted the sequence. The screen is one continuous vertical chronology made of edge-to-edge horizontal cuts; nothing floats and nothing is nested. Time, not category cards, organizes the day. A partner’s words break the regular rhythm by opening a large unruled interval inside the register. The claim is that expectations acquire meaning through action and response over time, and that the app should preserve that sequence with the sobriety of a private record rather than gamifying it or dressing it as intimacy.

## 2. Palette

### Light

| Role | Hex | Use |
|---|---:|---|
| `canvas` | `#EEF1F2` | Cool silver background. |
| `paper` | `#FAFBFB` | Active time cut and editable fields. |
| `ink` | `#15181A` | Primary text and icons. |
| `inkSoft` | `#454B4F` | Secondary labels and state. |
| `muted` | `#70777B` | Timestamps and inactive navigation. |
| `rule` | `#BFC6C9` | Register cuts. |
| `ruleStrong` | `#666F74` | Current/open cut. |
| `accent` | `#D6284F` | Current-time notch, focus, destructive-safe distinction. |
| `accentWash` | `#F5DCE3` | Selected text-field row only. |
| `humanInk` | `#8F1634` | Partner words. |
| `critical` | `#9A251D` | Destructive confirmation and validation. |

### Dark

| Role | Hex | Use |
|---|---:|---|
| `canvas` | `#111315` | Neutral charcoal; no blue or purple cast. |
| `paper` | `#1A1D1F` | Active time cut and editable fields. |
| `ink` | `#F4F5F5` | Primary text and icons. |
| `inkSoft` | `#C7CCCE` | Secondary labels and state. |
| `muted` | `#969DA1` | Timestamps and inactive navigation. |
| `rule` | `#353A3D` | Register cuts. |
| `ruleStrong` | `#7A8388` | Current/open cut. |
| `accent` | `#FF5276` | Current-time notch and focus. |
| `accentWash` | `#451B27` | Selected field row only. |
| `humanInk` | `#FF8BA3` | Partner words. |
| `critical` | `#FF8B7E` | Destructive confirmation and validation. |

Supported pairs are `ink`/`canvas`, `ink`/`paper`, `humanInk`/`canvas`, and `ink`/`accentWash`. Never set small copy in `accent` or `humanInk`.

**What carries identity without the accent:** a full-width ruled chronology with fixed-height timestamp headers and the deliberate unruled interruption for human words. In grayscale, the cadence of dense cuts → open interval → dense cuts remains distinctive.

## 3. Type

Bundle **IBM Plex Sans** and **IBM Plex Mono**, both OFL families on Google Fonts.

- **IBM Plex Sans** says all names, navigation, actions, expectation titles, human response words, and controls. The product has one neutral speaking face; scale and structure establish priority.
- **IBM Plex Mono** says only machine-verifiable coordinates: date, time, count, state code, and input character count if required. It may never compose relational prose or a response.
- Partner words do not receive a special literary face. Their authorship is proved by the `Open Interval` component and data contract, not by typography alone.

| Token | Face | Size / height | Weight | Use |
|---|---|---:|---:|---|
| `screen` | IBM Plex Sans | 28 / 34 | 600 | Screen title. |
| `cutTitle` | IBM Plex Sans | 20 / 26 | 500 | Expectation/action title. |
| `body` | IBM Plex Sans | 16 / 23 | 400 | Form values. |
| `bodyStrong` | IBM Plex Sans | 16 / 22 | 600 | Primary row action. |
| `coordinate` | IBM Plex Mono | 11 / 16 | 500 | Date, time, state; tracking `0.5`. |
| `count` | IBM Plex Mono | 14 / 20 | 600 | Actionable count. |
| `label` | IBM Plex Sans | 12 / 16 | 650 | Uppercase group label, tracking `1.0`. |
| `button` | IBM Plex Sans | 15 / 20 | 650 | Controls. |
| `nav` | IBM Plex Sans | 11 / 15 | 600 | Bottom nav. |
| `human` | IBM Plex Sans | 33 / 39 | 450 | Partner words within Today. |
| `humanHero` | IBM Plex Sans | 46 / 52 | 450 | Received screen, responsive 38–50. |

Use tabular figures in both families. Do not uppercase the message, add quote marks, or normalize the writer’s punctuation.

## 4. Structural device

### The register

The page is a continuous sequence of `TimeCut` rows extending from x = 0 to viewport width. There are no 16 dp outer margins around the sequence; content inside each cut has 20 dp phone insets.

- Every ordinary cut begins with a 24 dp coordinate header: time/date at x = 20 in `coordinate`, and owner/state at x = 370 right-aligned. The content below is 56–88 dp high.
- Adjacent cuts share one 1 dp top `rule`. The first cut has a top rule and the final cut has a bottom rule. There are never borders on the left or right.
- The currently actionable cut uses `paper` and a 3 × 24 dp `accent` notch attached to the viewport’s left edge. The notch encodes “needs action,” never completion or reward.
- Non-actionable cuts use `canvas`; pressed state uses `paper`. No hover elevation; web hover changes the shared rule to `ruleStrong`.
- A section change is an 18 dp high coordinate band, not a titled card. Use factual labels only: `NOW`, `TODAY`, `WAITING`.
- The register is dense by design: ordinary cut 80–112 dp, group band 18 dp, 24 dp between the screen header and first rule. Do not insert promotional whitespace or descriptions.

### Border and control rules

- Register rules communicate chronological separation and are permitted. Nested rules inside a cut are forbidden.
- Single-line fields use one 1 dp bottom `rule`, 2 dp `accent` on focus. Multiline human composer is bounded by top and bottom rules only, minimum 144 dp; no side border.
- Buttons have 0 radius inside the register. The only permitted radius is 3 dp for platform menus/dialogs. Primary button is an edge-to-edge 52 dp bar.
- No normal shadow. Modal overlay maximum: `0 8 24 #00000026`.
- At 840+ dp, rules stop at the centered 720 dp composition. On phone they remain viewport-wide.

## 5. Partner words — `Open Interval`

`OpenInterval` is the one form for verified received human words, and no other content may create it.

- It interrupts the register: no rules cross its body. A 4 dp double cut appears only at its entrance—two 1 dp `ruleStrong` lines separated by 2 dp. This double cut is used nowhere else.
- Minimum compact height 188 dp; Received uses all remaining height above its action bar.
- Padding is 20 dp sides, 24 dp top, 28 dp bottom.
- Coordinate header remains: `20:06` in Plex Mono at left; `ALEX` at right. Below it, 20 dp blank space.
- Words use Plex Sans `human`/`humanHero` in `humanInk`, max width 620 dp on web.
- Related action is the only trailing coordinate: `PREPARE THE EVENING SPACE`, Plex Mono 11/16 `muted`, placed at least 32 dp after the words.
- No fill change, card, border box, avatar, icon, quotation mark, animation, or app-authored sentence.
- Model API requires `authorship == human`, sender, timestamp, verbatim body, and related action identifier. Unknown authorship falls back to an ordinary `TimeCut` and never receives `humanInk`.

The emotional distinction comes from rhythm: the machine’s regular ruled record stops, and a person’s language is allowed room.

## 6. Today, applied

Reference viewport: 390 × 844; the register scrolls behind a fixed 76 dp bottom navigation.

1. **Header, y = 44–104.** At x = 20: `Today`, Plex Sans 28/34, `ink`. At x = 370: `FRI 28`, Plex Mono 11/16, `muted`. No greeting or corner mark.
2. **Partner response, y = 116–316.** Double cut at y = 116–120. `OpenInterval` begins y = 120. Header at y = 144: `20:06` left, `ALEX` right. Words at x = 20, y = 178: `I noticed the care you put into this.` in Plex Sans 33/39, `humanInk`. Related coordinate at y = 286: `PREPARE THE EVENING SPACE`, `coordinate`, `muted`. No background fill.
3. **Needs response, y = 316–390.** A `TimeCut` with `paper` fill and a left 3 × 24 dp `accent` notch. Coordinate header: `NOW` left, `YOU` right. Content line: `2 things need your response` in Plex Sans 18/24 weight 600; chevron in a 48 dp trailing target. No subtitle.
4. **Today expectation, y = 390–496.** Shared top rule. Coordinate header: `TODAY` left, `ALEX` right. Content: `Evening check-in message`, Plex Sans 20/26, `ink`. If the expectation has a due time, use that real time; otherwise do not invent one. No explanatory sentence.
5. **Waiting, y = 496–604.** Shared top rule. Coordinate header: `COMPLETED` left, `WAITING / ALEX` right. Content: `Tidy the entryway`, 20/26 `ink`. A real completion time may replace `COMPLETED`; do not write “waiting for a response” twice.
6. **Remaining canvas.** Leave it empty or continue real cuts. Do not fill with suggestions.
7. **Bottom nav, y = 768–844.** `paper` in light mode, `canvas` in dark, 1 dp `rule` top, no shadow. Today · Dynamic · Explore · Us, four equal 48 dp targets. Active Today uses `ink` and a 20 × 3 dp `accent` notch attached to the nav’s top rule over the Today quarter. Inactive items use `muted`. This is a navigation notch, not the Open Interval double cut.

The `2 things need your response` summary opens a register filtered to the two relevant cuts. On the direction-giving side, each row contains only verified coordinates, the action title, and `Respond`; composer opening replaces the selected cut’s content rather than nesting a form inside it.

## 7. Received, applied

- **Status and header, y = 0–104:** `canvas`; plain back target at x = 8. `RECEIVED` is not shown. At y = 72, double cut begins across the full width.
- **Open Interval, y = 76–708:** coordinate header at x = 20/y = 100: `20:06`; `ALEX` at x = 370, right-aligned. Words begin x = 20, y = 216 in Plex Sans 46/52 weight 450, `humanInk`: `I noticed the care you put into this.` Keep the first line around 25% of usable height. Long text scrolls; never ellipsize or reduce below 38 sp.
- **Related action, y = 656:** `PREPARE THE EVENING SPACE`, Plex Mono 11/16, `muted`. No additional sentiment or confirmation title.
- **Action cut, y = 708–844:** 1 dp `ruleStrong` at top, then a 52 dp edge-to-edge primary bar inside 20 dp side insets, `ink` fill, `canvas` text, 0 radius, label `Today`. Optional `Reply` is text-only and opens an empty composer.
- Dark mode remains charcoal with pink-red human words. It does not become a blue/purple “cinematic” screen.

## 8. Cost and risk

Register can drift into enterprise logs or issue trackers if coordinate headers become verbose, if every row gains state codes, or if red is allowed to imply failure. The build must cap visible metadata and preserve large unruled intervals. Edge-to-edge shared rules require careful sliver composition in Flutter so rules do not double at recycling boundaries; sticky bottom navigation and a scrolling Received interval also need golden tests at large text sizes. Mono type is easy to overuse and can make the relationship feel clinical. People who want softness may reject the sobriety, but people embarrassed by overtly “intimate” branding may trust it precisely because it resembles a private, well-made record.

---

# Direction 04 — Still / The Stage

## 1. Thesis

**Still** is the genuine risk. It refuses the dashboard entirely: the screen behaves like a stage with one dominant moment and a compact cue stack beneath it. Today’s partner response owns the stage; what needs action becomes the next cue; expectation and waiting states remain narrow factual strips until selected. When words arrive, navigation and supporting state withdraw rather than wrapping the message in a special card. The claim is that a relationship product should spend its strongest visual energy on attention, not organization. A careful studio could argue that this is the most honest expression of “automation prepares; the partner responds”; a cautious studio could reject it as too editorial, unfamiliar, and demanding of immaculate type behavior.

## 2. Palette

### Light

| Role | Hex | Use |
|---|---:|---|
| `canvas` | `#F1F0EE` | Neutral pale gray with no cream cast. |
| `stage` | `#E7E6E3` | Dominant moment ground. |
| `ink` | `#101112` | Primary text, icons, primary bar. |
| `inkSoft` | `#3D4043` | Secondary labels and state. |
| `muted` | `#707477` | Time and inactive nav. |
| `line` | `#C5C5C2` | Cue separators and field boundaries. |
| `accent` | `#E6005C` | Focus cursor, selected cue index, unread signal. |
| `accentInk` | `#FFFFFF` | Text/icon on accent when required. |
| `humanInk` | `#101112` | Partner words; scale carries the peak. |
| `critical` | `#A62521` | Destructive and error only. |

### Dark

| Role | Hex | Use |
|---|---:|---|
| `canvas` | `#0E0F10` | Neutral black. |
| `stage` | `#171719` | Dominant moment ground; not aubergine or navy. |
| `ink` | `#F5F4F1` | Primary text and icons. |
| `inkSoft` | `#C9C8C4` | Secondary labels. |
| `muted` | `#92928F` | Time and inactive nav. |
| `line` | `#353537` | Cue separators and input bounds. |
| `accent` | `#FF3B82` | Focus cursor, selected cue index, unread signal. |
| `accentInk` | `#25000E` | Text/icon on accent. |
| `humanInk` | `#F5F4F1` | Partner words. |
| `critical` | `#FF817A` | Destructive and error only. |

Supported text pairs are `ink`/`canvas`, `ink`/`stage`, `humanInk`/`stage`, and `accentInk`/`accent`. Pink is an operational signal, never a decorative wash, large field, or paragraph colour.

**What carries identity without the accent:** the stage-to-cue proportion—roughly 55% of the useful viewport for one present moment and 45% for thin factual cues—and the vertical sender caption reserved for partner words. In grayscale the hierarchy remains unmistakable.

## 3. Type

Bundle **Archivo** and **Archivo Black**, both OFL families available on Google Fonts.

- **Archivo** is used for every app-authored label, status, navigation item, control, and all user-authored expectations/actions before a response arrives.
- **Archivo Black** is allowed only for verbatim received partner words. It is never used for a greeting, screen heading, Explore title, suggestion, badge, or generated copy. Unlike Hinge / Reply, the distinction is not “serif means human”; it is an unapologetically contemporary sans display voice.
- The stage structure, vertical author caption, and withdrawn chrome are mandatory. Archivo Black alone must never be treated as sufficient evidence of a partner response.

| Token | Face | Size / height | Weight | Use |
|---|---|---:|---:|---|
| `screen` | Archivo | 22 / 27 | 650 | Compact screen title. |
| `cueTitle` | Archivo | 18 / 23 | 600 | Expectation/action cue. |
| `label` | Archivo | 11 / 15 | 700 | Uppercase factual label, tracking `1.0`. |
| `body` | Archivo | 16 / 23 | 400 | Form values. |
| `meta` | Archivo | 12 / 17 | 500 | Person, time, state; tabular figures. |
| `button` | Archivo | 15 / 20 | 700 | Controls. |
| `nav` | Archivo | 11 / 15 | 650 | Bottom navigation. |
| `humanStage` | Archivo Black | 36 / 37 | 400 | Partner words on Today. |
| `humanHero` | Archivo Black | 54 / 54 | 400 | Received screen, responsive 42–60. |

Archivo Black has a single practical weight; do not simulate heavier weight or tighten tracking below `-0.4`. Preserve words exactly. At 200% text scale, reduce `humanHero` only to the 42 sp floor and let the stage scroll.

## 4. Structural device

### Stage and cue stack

After the 60 dp screen header and before bottom navigation, divide the available height into:

- **Stage:** minimum 328 dp, normally 55% of available height. Full viewport width, `stage` fill, square corners. It holds exactly one selected real event—not a carousel of promotional content.
- **Cue stack:** the remaining height, `canvas`, made of 64–78 dp full-width rows separated by one 1 dp `line`. Each row shows one title, one factual state, and at most one trailing action. No subtitle.
- Selecting a cue swaps it onto the stage with a 160 ms linear opacity crossfade plus a 160 ms 8 dp vertical translation. Respect reduced motion by switching instantly. No spring, parallax, glow, or celebratory animation.
- The cue stack is ordered by action cost: response needed, today’s expectation, waiting. It is not ranked, scored, or numbered. Never show more than four cues; additional real items open in a plain full-screen list.
- The direction-giving side stays cheap: entering `Needs you` makes the first waiting cue the stage and places an empty composer immediately beneath the factual action, with `Send` fixed above the keyboard. No AI draft, tone selector, suggestions, or “improve” control.

### Geometry, bounds, and borders

- Phone header inset 16 dp; stage content inset 24 dp. Cue content inset 16 dp.
- Stage has 0 radius, no border, no shadow. It is a page region, not a card.
- Cue rows have only a shared top separator. The final row has a bottom separator. No left/right bounds, fills, or rounded corners.
- Inputs use a full 1 dp rectangular boundary only when editability would otherwise be ambiguous, radius 0; focus boundary 2 dp `accent`. Buttons are rectangular, radius 0. Menus/dialogs may use radius 3.
- No shadows in content. Modal maximum `0 8 24 #0000002B`.
- On web, keep stage and cue stack in a centered 720 × min(844, viewport height) composition. Do not turn cues into a multi-column dashboard. On landscape, stage occupies the left 62%; cues form a right column, but retain the single dominant selection.

## 5. Partner words — `Still`

`Still` is a verified human-message stage state and the only place a vertical caption is permitted.

- Fill is the normal `stage`, not a contrasting response card.
- The caption `ALEX · 8:06 PM` is rotated 90° clockwise, positioned 12 dp from the right viewport edge, and centered vertically. It uses Archivo `meta`, `muted`. It is the one unique form used nowhere else; all other labels remain horizontal.
- Words occupy x = 24–326 so they never collide with the caption. Use Archivo Black `humanStage` or `humanHero`, `humanInk`, left aligned.
- No quote mark, speech bubble, sender avatar, border, icon, label such as `FROM`, or related app sentiment.
- The related action sits horizontally at the lower left in Archivo `meta`, `muted`, at least 32 dp below the words.
- Compact `Still` stage minimum height is 328 dp. Received expands it to the full viewport and withdraws bottom navigation.
- API requires verified human authorship and verbatim body. The rotated caption is excluded from rotor order and exposed to accessibility as ordinary sender/time text before the message.

## 6. Today, applied

Reference viewport: 390 × 844.

1. **Compact header, y = 44–96.** `Today` at x = 16, baseline around y = 74, Archivo 22/27 `ink`; `FRI 28` at x = 374, right-aligned in `meta`, `muted`. No greeting.
2. **Stage / partner message, y = 96–454.** Full width, `stage`. `Still` words start x = 24, y = 158 in Archivo Black 36/37: `I noticed the care you put into this.` Maximum width 302 dp. Vertical caption `ALEX · 8:06 PM` occupies a 17 × 120 dp rotated box centered at x = 354. Related action `Prepare the evening space` at x = 24, y = 414 in 12/17 `muted`. The message is the largest and highest-contrast content on Today.
3. **Cue 1, y = 454–526.** A 3 dp `accent` index at x = 0, y = 454–478 indicates the next actionable cue; it is not a progress bar. At x = 16: `2 things need your response`, Archivo 18/23 weight 650, `ink`. At x = 342 a 48 dp chevron target. No subtitle. Selecting opens the response-needed stage.
4. **Cue 2, y = 526–606.** Top 1 dp `line`. `TODAY · ALEX` in `label`, `muted`; below: `Evening check-in message` in Archivo 18/23, `ink`. No description.
5. **Cue 3, y = 606–686.** Top 1 dp `line`. `WAITING · ALEX` in `label`, `muted`; below: `Tidy the entryway`, 18/23. Trailing `Completed` in `meta`, `muted`. No background panel.
6. **Flexible gap, y = 686–760.** `canvas`; may collapse if text scale grows. The stage never shrinks below 328 dp at 1.0 scale.
7. **Bottom nav, y = 760–844.** 1 dp `line` top, `canvas`, no shadow. Today · Dynamic · Explore · Us in four equal 48 dp targets. Icons 20 dp. Active Today uses `ink`; a 3 × 16 dp vertical `accent` index touches the nav’s top edge above the active destination. Inactive items use `muted`. Never use a filled active capsule.

When the user selects the response-needed cue, the stage shows the first actual waiting item (`Prepare the evening space`, `Jamie completed`, `4:11 AM`) and a single `Respond` action; the second waiting item remains the first cue beneath it. The count disappears because the actual work is visible.

## 7. Received, applied

Received is the purest version of the stage: the application becomes still around a person’s words.

- **Full viewport, y = 0–844:** `stage` fill including status bar. Bottom navigation is absent. A 48 dp back target at x = 8/y = 40 uses a plain chevron, no circle.
- **Vertical caption:** `ALEX · 8:06 PM`, rotated clockwise in a 17 × 120 dp box at x = 354, vertically centered; `meta`, `muted`.
- **Words:** x = 24–326, first baseline near y = 244. Archivo Black 54/54, `humanInk`: `I noticed the care you put into this.` Do not vertically center by bounding-box math; place the first line around 27% of the usable height so the block has room to breathe below. Long messages scroll inside x = 24–326/y = 132–670, with 42 sp floor.
- **Related action:** x = 24, y = 686: `Prepare the evening space`, Archivo 12/17, `muted`.
- **Exit action:** a 52 dp full-width rectangular bar at x = 16–374, y = 744, `ink` fill, `canvas` text: `Today`. It has 0 radius and no shadow. A real `Reply` action, if supported, is text-only above it and opens a blank composer.
- On entry, the stage may perform one 120 ms opacity fade from 0 to 1. With reduced motion it appears immediately. No word-by-word reveal, typing simulation, vibration pattern, confetti, or sound; those would aestheticize the partner’s voice.

## 8. Cost and risk

This direction can feel like a fashion editorial rather than a utility, and Archivo Black may read as loud or impersonal to people who expect softness. The one-at-a-time stage hides comparison and makes three or more pending items less efficient; the cap-and-overflow behavior must be rigorously implemented. Rotated metadata is difficult for screen readers, localization, selectable text, and large accessibility sizes, so semantics must expose a normal horizontal reading order and the visual caption must switch horizontal at text scale above 1.3. Flutter’s nested scroll behavior—scrollable message inside a fixed stage above a cue stack—needs careful gesture arbitration. It also demands disciplined real content: a short message looks monumental, while a long one can overwhelm. This is the route a cautious team is most likely to reject, but it is also the only route that makes attention itself, rather than organization, the product identity.

---

# Comparison and recommendation

| Direction | Organising idea | Partner words | Strongest quality | Primary failure mode |
|---|---|---|---|---|
| **Across / Two Edges** | Spatial ownership between two people | Cross the shared gutter from one edge to the other | Relational without looking like chat or a D/s product | Asymmetry and right alignment can slow scanning |
| **Register / Time Cuts** | One continuous chronology | Rules stop and create an Open Interval | Discreet, sober, cheap to operate | Can become clinical or task-log-like if metadata grows |
| **Still / The Stage** | One present moment plus compact cues | The interface withdraws; words occupy the stage | Most distinctive and emotionally uncompromising | Least conventional, hardest accessibility and long-copy behavior |

**I would ship Across / Two Edges.** It turns the two-person model into structure, makes partner words visibly traverse the relationship, and stays usable when there are several real states on Today. It is more ownable than Register and less fragile than Still, while remaining discreet over someone’s shoulder.

If the priority is specifically **“a person shows this to their partner and is not embarrassed,” I would ship Register / Time Cuts.** Its cool, precise record avoids wellness sentiment, sexualized cues, and theatrical intimacy. It looks intentional and private, and the Open Interval still lets the human response outrank the surrounding system without asking the user to buy into a conspicuous visual persona.
