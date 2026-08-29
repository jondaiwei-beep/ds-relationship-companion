# Direction 02: Hinge / Reply

This is a replacement identity, not a revision of Warm Authority V5. Remove Bone, Terracotta, Lora, the diagonal corner ribbon, the rounded-card component, and the decorative explanatory sentences. The new system should still communicate intimacy and authority, but it should look precise, private, and authored rather than soft, literary, or “wellness”.

The principle **Light Life, Dark Structure** survives, with a stricter definition:

- Light is the ordinary shared record: plans, actions, dates, navigation.
- Dark is used only for an authority surface or for words demonstrably written by a partner.
- A dark fill is never a generic “featured card”.
- Partner words outrank everything around them in area, contrast, and type size.

The visual audit covered all supplied screens: `m1-screen-attention.png`, `m1-screen-create-dynamic.png`, `m1-screen-received.png`, `m1-screen-signin.png`, `m1-screen-today.png`, and `m1-screen-us.png`, plus `current_tokens.dart`. Across them, the rejected identity is carried by the same combination: cream ground, terracotta tick/rail, olive panels, Lora headings, a diagonal top-right mark, rounded bordered cards, and gray explanatory sentences. None of those devices should be retained in disguised form.

## 1. Palette

The palette is mineral white, graphite, and sharp lichen. It is cool-neutral, not cream; lichen is yellow-green, not warm orange and not blue/purple. The hexadecimal values below are source-of-truth values, not suggestions.

### Light scheme

| Role / token | Hex | Use |
|---|---:|---|
| `canvas` | `#F2F4F1` | Default page and system-bar ground. A cool mineral gray, never tinted beige. |
| `surface` | `#FFFFFF` | Text fields, sheets, and the rare raised control surface. Not a card fill for ordinary rows. |
| `ink` | `#171917` | Primary text, icons, rules, and primary buttons. |
| `inkSoft` | `#454A45` | Secondary labels and non-critical metadata. |
| `muted` | `#6B716B` | Timestamps, inactive navigation, placeholder text. Minimum 13 sp on `canvas`. |
| `line` | `#C9CEC8` | Structural dividers and field underlines. |
| `lineStrong` | `#8E968E` | Focus-independent control outline and selected row rule. |
| `accent` | `#BDD72A` | Current-position ticks, focus ring, unread mark, and selected-nav key only. Never paragraph text. |
| `accentInk` | `#354200` | Text/icon on a pale accent tint if one is required for accessibility. |
| `accentWash` | `#EAF2BB` | Selection background only; never a page section or card. |
| `critical` | `#A23B47` | Destructive action and validation error only. It is not a brand colour. |
| `response` | `#101210` | The partner-response plane. Also the authority header/background where specified. |
| `onResponse` | `#F6F7F3` | Primary words on `response`. |
| `onResponseMuted` | `#ADB4AC` | Metadata on `response`. |

### Dark scheme

| Role / token | Hex | Use |
|---|---:|---|
| `canvas` | `#101210` | Default page and system-bar ground. Neutral graphite, with no navy or aubergine cast. |
| `surface` | `#191C19` | Fields, bottom sheet, and control groups. |
| `surfaceRaised` | `#222622` | Pressed/raised interactive state only. |
| `ink` | `#F3F5F1` | Primary text and icons. |
| `inkSoft` | `#C9CEC8` | Secondary labels. |
| `muted` | `#9DA49D` | Timestamps, inactive navigation, placeholders. |
| `line` | `#373D37` | Structural dividers and field rules. |
| `lineStrong` | `#687168` | Selected/focused structural rule. |
| `accent` | `#C8E438` | Current-position ticks, focus ring, unread mark, and selected-nav key. |
| `accentInk` | `#1D2400` | Text/icon on an accent-filled control. |
| `accentWash` | `#303A12` | Selection background only. |
| `critical` | `#EF7B86` | Destructive action and validation error. |
| `response` | `#F3F5F1` | In dark mode, invert the response plane so a person's arrival still changes the whole screen. |
| `onResponse` | `#101210` | Partner words on the inverted response plane. |
| `onResponseMuted` | `#596059` | Metadata on the inverted response plane. |

`ink` on `canvas`, `onResponse` on `response`, and `accentInk` on `accent` are the supported text pairs. Do not place white text on lichen. Disabled controls use 40% opacity and must not be the only way a state is communicated.

### What carries identity

The accent does **not** carry the identity. It is deliberately scarce and replaceable. The identity is carried by two structural devices:

1. **The hinge:** a persistent two-column alignment with a 64 dp context column, a 1 dp rule, and a flexible content column. It makes person, time, and state visibly distinct from the thing being acted on.
2. **The reply plane:** a full-width, square-cornered field reserved exclusively for a partner's literal words. It is the only place the serif appears.

Both devices still read in grayscale, high-contrast mode, and screenshots with the accent removed.

## 2. Type

Bundle two OFL families from Google Fonts:

- **Instrument Sans**: every app-authored element—screen titles, navigation, action names, field labels, status, timestamps, and user-entered directions before they have been sent.
- **Source Serif 4**: only literal words already sent by a human partner. Never use it for a screen heading, greeting, task/action name, prompt, button, empty state, or generated suggestion.

The serif is semantic evidence of human authorship, not atmosphere. If the backend cannot prove the text is human-authored, render it in Instrument Sans. The system must never pre-populate a response in Source Serif 4 or compose in a partner's voice.

### Type tokens

All values are Flutter logical pixels (`sp` here means logical font size). Use explicit `height`; do not inherit platform defaults.

| Token | Face | Size / line height | Weight | Use |
|---|---|---:|---:|---|
| `display` | Instrument Sans | 32 / 36 | 600 | One screen title; max two lines. |
| `title` | Instrument Sans | 24 / 29 | 600 | Major section or compact screen title. |
| `heading` | Instrument Sans | 19 / 24 | 600 | Item title and group heading. |
| `body` | Instrument Sans | 16 / 23 | 400 | User content and form values. |
| `bodyStrong` | Instrument Sans | 16 / 22 | 600 | Primary row action or emphasized value. |
| `label` | Instrument Sans | 12 / 16 | 650 | Uppercase section labels; letter spacing `1.2`. |
| `meta` | Instrument Sans | 13 / 18 | 500 | Person, timestamp, status. Use tabular figures. |
| `button` | Instrument Sans | 15 / 20 | 650 | Buttons and text actions. |
| `nav` | Instrument Sans | 12 / 16 | 600 | Bottom navigation labels. |
| `partnerQuote` | Source Serif 4 | 34 / 41 | 450 | Partner words on the received screen; responsive range 30–40. |
| `partnerQuoteCompact` | Source Serif 4 | 25 / 32 | 450 | Partner words embedded on Today/Us. Never below 22. |

Do not italicize partner words, add quotation marks, or use all caps for them. Preserve the writer's capitalization and punctuation. Cap dynamic text at 200% scaling without clipping; at large text sizes the hinge collapses as specified below.

## 3. Structure

### Base geometry

- Reference viewport: 390 dp wide. Layout must work from 320 dp through web widths.
- Phone page inset: 16 dp. At widths 600–839: 24 dp. At 840+: center a maximum 720 dp content column; the response plane may remain 720 dp, not browser-wide.
- Base spacing: 4 dp. Approved steps: 4, 8, 12, 16, 24, 32, 48, 64.
- Minimum touch target: 48 × 48 dp.
- Standard control height: 52 dp. Compact icon control: 48 dp.
- Bottom navigation: 72 dp plus safe-area inset; 1 dp top rule; no filled bar shadow.
- Radius: `0` for rows, groups, response planes, bars, sheets, and navigation; `2` for inputs and buttons; `4` maximum for menus/dialogs required by the platform. Delete the 10 dp card radius token.
- Shadow: none in normal page content. A modal may use `0 8 24 #0000001F`; a floating web menu may use `0 4 12 #00000014`. No other shadow.

### The hinge grid

Inside the page inset, create:

```text
| 64 dp context | 1 dp rule | 16 dp gap | flexible content |
```

The rule is `line`; it becomes `lineStrong` for the active/open row. Context contains only essential source data such as `ALEX`, `4:11 PM`, `TODAY`, or a state glyph. The content column contains the action/title and its control. Context aligns right; content aligns left. A section may omit context, but its title aligns to the content column, not arbitrarily to the page edge.

At widths under 350 dp or text scale above 1.3, collapse the hinge: context moves above content, the vertical rule becomes a 24 dp horizontal rule, and the content remains full width. Do not truncate a person's name to preserve the column.

### Lists and groups

- A list item is bounded by one horizontal `line` divider at its bottom. The first item also has a top divider. No surrounding fill, border, or radius.
- Row vertical padding is 16 dp; minimum row height is 76 dp. A title and metadata row is normally 84–96 dp.
- A tappable row gets a full-width `#00000008` press overlay in light mode or `#FFFFFF0A` in dark mode. No hover elevation. Web hover changes the divider to `lineStrong`.
- A group is bounded by whitespace: 32 dp before its `label`, 12 dp from label to first rule, and 32 dp after its last rule. A group never gets an outer container.
- Two adjacent options share dividers. Do not put each option in a card.
- A border exists only to show an input boundary, selection, focus, modal boundary, or destructive confirmation. It must encode a state. Decorative borders and nested borders are forbidden.
- Text fields use a 1 dp bottom rule at rest, 2 dp `accent` bottom rule on focus, no filled capsule, and 0 radius. Multiline composers may use a complete 1 dp rectangular boundary with 2 dp radius because the edge communicates the editable region.
- Primary buttons use `ink` fill with `surface`/`onResponse` text, 2 dp radius, 52 dp height. Secondary buttons are text-only with a 2 dp underline appearing on focus/hover; do not outline a large empty rectangle merely to make a button look substantial.

### No descriptive text

Every visible string must be one of: navigation, a title, a person's actual words, an action label, a form label/value, a status required to act, a person, a date/time, validation, consent/safety/legal content, or an accessibility-equivalent label. Delete marketing explanations, reassuring filler, summaries that restate visible state, and subtitles that merely fill a row.

Examples from the current screens:

- Delete “Someone is waiting to hear from you.” The count and action already communicate it.
- Delete “A few words before the day closes.” It adds no state.
- Delete “usually under a minute.” It is promotional reassurance.
- Delete “You were seen.” The arriving words themselves must do that work.
- Keep `Completed · 7:42 PM` when it distinguishes a real state and time.
- Consent, age gate, privacy, error recovery, and irreversible-action warnings are functional copy and may remain.

## 4. Partner words: the Reply Plane

Use one form, named `ReplyPlane`, everywhere a received partner response appears. Do not use this form for drafts, app prompts, action titles, system suggestions, quotes from educational content, or empty states.

### Construction

- Geometry: full available content width; 0 radius; no border; no shadow. On a phone-level emotional-peak screen it extends edge to edge. In a feed it spans the page inset, not merely the right side of the hinge.
- Fill: `response`; foreground: `onResponse`.
- Minimum height: 216 dp compact, or all remaining height on the received screen.
- Padding: 24 dp left/right, 24 dp top, 28 dp bottom. On the received screen: 24 dp sides, 32 dp below safe area, 32 dp bottom.
- Header: sender in `label`, `onResponseMuted`; timestamp on the same baseline at the far right in `meta`. Text is factual: `ALEX` and `8:06 PM`, not “FROM ALEX” or “ALEX RESPONDED”.
- Registration mark: directly below the header, a 28 × 3 dp rectangle in `accent`, with 16 dp below it. This mark appears only inside `ReplyPlane`; elsewhere accent is a 2–3 dp operational tick, never this 28 dp signature.
- Words: Source Serif 4 `partnerQuote` or `partnerQuoteCompact`, `onResponse`, flush left. No quote marks, avatar, speech bubble tail, decorative icon, or generated preface.
- Reference line: optional and only if context is needed—action title at the bottom in Instrument Sans `meta`, `onResponseMuted`, separated from the words by at least 32 dp. Do not put it in a nested panel.
- Long text: grow vertically and scroll with the page. On the full-screen received view, the words region scrolls while the sender and bottom action remain reachable; never ellipsize or reduce below 30 sp there.
- Accessibility label: `Message from {name}, received {time}: {verbatim message}`. The accent mark is hidden from semantics.

This singular treatment makes real words visually undeniable and prevents automation from borrowing the partner's voice.

## 5. Recognition across screens

The system should be identifiable without a logo, illustration, or accent colour.

### Today

The date occupies the hinge's context column and `TODAY`/the current state occupies the content column. Ordinary actions are flat divided rows on the hinge. When partner words exist, `ReplyPlane` breaks out across both columns. The visual event is therefore also a structural event: the human response temporarily suspends the application's grid.

### Attention

The dark authority header establishes that the user is about to speak, not merely review. Below it, every waiting moment uses the hinge: partner/time on the left, completed action and `Respond` on the right. Opening a row strengthens only its hinge rule and reveals a plain composer below; there are no canned response chips and no generated draft.

### Received

The `ReplyPlane` expands to own almost the whole viewport. The hinge survives only in its metadata: sender and time occupy a deliberate top line, while the related action sits at the lower edge. The app's only competing control sits outside the plane in a fixed light/dark action dock.

### Us and Dynamic (system propagation)

`Us` becomes a hinge-aligned chronological record with divided rows; responses interrupt it as compact Reply Planes. `Dynamic` uses the hinge for person/role and agreement/value rather than putting each setting in a rounded card. Selection is a 2 dp accent tick plus weight change, never an outlined capsule. This proves the devices work beyond the three showcase screens.

## 6. Applied screens

Measurements below use a 390 × 844 dp logical reference viewport. Add device safe areas to the specified regions. Browser layouts use the same vertical measurements inside the centered 720 dp maximum column.

### A. Today with content

**0–48: system/safe region**

- Background `canvas`; status-bar icons `ink`.
- No diagonal ribbon or corner ornament.

**48–120: page header**

- Page inset 16 dp.
- Hinge starts at x = 16: context 64, rule at x = 80, 16 gap, content begins x = 97.
- Context: `FRI 28` in `label`, `muted`, aligned right at y = 63.
- Content: `Today` in `display` 32/36, `ink`, baseline around y = 83.
- Bottom space 20 dp. Do not use “Good morning.”

**120–354: received words**

- `ReplyPlane`, x = 0, width = 390, minimum height = 234, fill `response`, square corners.
- Padding x = 24. Header y = 146: `ALEX` at left, `8:06 PM` at right.
- Accent registration mark at x = 24, y = 174, 28 × 3.
- Partner words start y = 197 in Source Serif 4 30/37 for this compact plane: `I noticed the care you put into this.`
- Related action at y ≈ 316: `Prepare the evening space`, Instrument Sans 13/18, `onResponseMuted`.
- Entire plane is tappable to open the received view; semantics identify it as the message, not a “card”.

**354–490: action-required group**

- 32 dp gap after the plane.
- At x = 97, y = 386: `FOR YOU · 2` in `label`, `inkSoft`. The count is data, not prose.
- First/top rule y = 414 from x = 16 to 374, `line`.
- One 76 dp row: context `ALEX` then `4:11 PM`, stacked in `meta`; content `Evening check-in` in `heading`; trailing 48 dp target with `Respond` in `button`. Bottom rule.
- If there are two rows, render both; do not replace them with the old summary banner.

**522 onward: waiting group**

- Label at x = 97: `WAITING`.
- Top rule 12 dp below label.
- Row context: `7:42 PM`; content: `Tidy the entryway`, then `Completed` in `meta`, `muted`. No filled gray panel.
- Empty remainder stays `canvas`; do not fill it with encouragement or summaries.

**Bottom navigation**

- Anchored to bottom; height 72 plus safe area, `canvas`, 1 dp `line` top rule, no shadow.
- Four equal 48 dp targets: Today · Dynamic · Explore · Us. Icons 22 dp, 1.75 dp stroke, familiar neutral symbols.
- Active Today: `ink` icon/label and a 16 × 3 dp `accent` rectangular key directly above the label. Inactive: `muted`. No tinted active background.

### B. Acknowledgement received—the emotional peak

This screen is not a confirmation card. It is the partner's words taking over the interface.

**0–708: full-screen Reply Plane**

- From top edge through y = 708, fill `response` (`#101210` light scheme). Status bar matches it; status icons use `onResponse`.
- Content padding 24 dp. Close/back control: 48 dp target at top-left, simple 20 dp chevron in `onResponse`; no outlined circle.
- Header baseline y = 84: `ALEX` in `label`; `8:06 PM` right-aligned in `meta`, both `onResponseMuted`.
- Registration mark x = 24, y = 104, 28 × 3 dp `accent`.
- Quote starts y = 196 on a 390 dp phone, Source Serif 4 38/45 weight 450, max line width 342 dp. Vertically position the first line near 23% of the usable plane, not dead center. The real string remains verbatim: `I noticed the care you put into this.`
- Do not add “From”, “received”, a celebration, “You were seen”, an icon, or animation confetti.
- At y = 658: related action `Prepare the evening space`, Instrument Sans 13/18, then time only if it is not already in the header. Use `onResponseMuted`.
- For longer words, quote area scrolls between y = 132 and the reference line. The sender header and dock remain fixed.

**708–844: action dock**

- Fill `canvas`, square top edge, no shadow; 1 dp `line` top rule. Padding 16 dp top/sides and safe area bottom.
- One 52 dp primary button, x = 16 to 374, fill `ink`, radius 2: `Today` in `button`, light foreground. The destination label is enough; do not write “Back to Today”.
- Optional text action `Reply` is allowed only if the product supports a genuine new human reply. It must open an empty composer. Never suggest the words.

In dark mode, invert the plane to `#F3F5F1` with `#101210` words and keep the dock dark. The inversion ensures the arrival remains the highest-contrast event rather than dissolving into dark-mode chrome.

### C. Attention—direction-giving work surface

**0–152: authority header**

- Fill `response` (`#101210`), square bottom edge. Status icons `onResponse`.
- Top row y = 48–96: one 48 dp back target at x = 8. Do not add a logo or corner ornament.
- Title at x = 16, baseline around y = 128: `Attention`, Instrument Sans `display` 32/36, `onResponse`.
- At x = 16, y = 140: a 12 × 3 dp `accent` authority tick. It must not use the Reply Plane's 28 dp registration mark; 28 dp is reserved for verified partner words.
- No subtitle such as “2 moments need a response” or “usually under a minute”. Put the count into the first group label.

**152 onward: waiting work list**

- Fill `canvas`; page inset 16; 32 dp top padding.
- Hinge geometry: 64 dp context, 1 dp rule, 16 dp gap.
- Group label in content column: `WAITING · 2`, `label`, `inkSoft`.
- Top divider 12 dp later.
- Each row is 104 dp minimum:
  - Context: `JAMIE` in `meta`, `inkSoft`; `4:11 PM` below in `meta`, `muted`.
  - Content: completed action in `heading`, `ink`: `Prepare the evening space` or `Evening check-in`.
  - Bottom/right: `Respond` in `button`, `ink`; its 48 dp target is aligned to the trailing edge. On focus/hover it receives a 2 dp `accent` underline, not an orange underline at rest.
  - One `line` divider at row bottom; no surface fill, border box, or radius.

**Opened row / composer**

- The selected row's hinge rule becomes 2 dp `ink`; other geometry stays put.
- An empty multiline field opens directly below the row in the content column, min height 128 dp, 1 dp `lineStrong` rectangular boundary, radius 2, 16 dp inset.
- Label `YOUR WORDS`, then an empty cursor. No placeholder sentence, suggested reply, completion, or auto-generated wording.
- Footer contains character count only if technically required. Primary action `Send` is 52 dp high, `ink` fill, 2 dp radius. Secondary `Cancel` is text-only.
- Automation may surface the completed action and timing; only the human can enter the response.

**Bottom navigation**

- Hide it while composing to protect vertical space and avoid accidental navigation. On the list state, use the fixed four-item navigation exactly as on Today, with no special fifth “attention” tab.

## 7. Component and token replacement

Replace the existing abstractions rather than reskinning `DsCard`.

```dart
abstract final class DsRadius {
  static const none = 0.0;
  static const control = 2.0;
  static const overlay = 4.0;
}

abstract final class DsLayout {
  static const pageInset = 16.0;
  static const contextWidth = 64.0;
  static const hingeGap = 16.0;
  static const ruleWidth = 1.0;
  static const controlHeight = 52.0;
  static const minTarget = 48.0;
  static const bottomNavHeight = 72.0;
  static const maxContentWidth = 720.0;
}
```

Delete `DsCardTone`, `showRail`, `darkRailWidth`, `cardRadius`, `cardBorder`, `darkCardBorder`, Bone, Stone, Olive, Moss, Terracotta, Ivory, Lora styles, and the diagonal corner asset. Introduce these primitives:

- `HingeSection`: lays out context/rule/content and owns collapse behavior.
- `DividedRow`: semantic button/list row with top/bottom-divider rules.
- `ReplyPlane`: accepts only `HumanMessage` data, not an arbitrary child widget. This API restriction prevents accidental reuse.
- `AuthorityHeader`: dark header for composing/responding/configuring authority; never displays received words.
- `UnderlineField`: one-line field; `BoundedComposer`: multiline human input.
- `BottomNav`: common 72 dp navigation with rectangular active key.

Model-level guard: `ReplyPlane(message:)` should require fields such as `authorId`, `authorship == human`, `body`, and `sentAt`. Fail closed to Instrument Sans ordinary content if authorship is unknown. Styling alone is not sufficient to enforce “automation prepares; the partner responds.”

## 8. Discretion and platform behavior

- Browser title and app switcher label use a neutral product codename only; never include D/s, dynamic, task/action text, a partner name, or received words.
- Notifications default to `New update` with no sender, action, or message preview. A user may explicitly opt into richer previews per device; lock-screen default remains redacted.
- App icon must be an abstract split square/hinge in graphite and mineral white. No crown, flame, chain, handcuff, whip, initials, or relationship terminology. Do not use lichen at full-bleed icon scale.
- Web URLs and document titles must not expose action titles. Use opaque identifiers.
- At app resume, blur/protect the last frame until local authentication/privacy cover resolves where the platform permits it.
- No AI-generated people, gradients, blobs, glass, grain, faux paper, or texture.

## 9. Migration order for ~25 screens

The order is based on perceived change per unit of work and on preventing old components from leaking back into new screens.

1. **Swap foundations and remove global signatures (0.5–1 day).** Replace the palette and default font, set `canvas`, change system bars, delete the diagonal corner mark, set global radius to 2/0, flatten the bottom nav, and remove default shadows. Even before layout migration, every screen stops reading as the rejected identity.
2. **Build the five primitives (1–1.5 days).** Implement and golden-test `HingeSection`, `DividedRow`, `ReplyPlane`, `AuthorityHeader`, and the new `BottomNav`. Add the human-authorship type/API guard. Do not spend time reskinning `DsCard`; deprecate it immediately.
3. **Ship the emotional path (1 day).** Migrate received acknowledgement first, then its compact appearance on Today, then Attention and its composer. These three screens establish the product's governing rule and provide the reference implementation for all other work.
4. **Flatten high-traffic screens (1–2 days).** Migrate Today remainder, Dynamic, Explore, and Us. Convert repeated card lists to hinge sections/divided rows. Remove secondary descriptive strings during the conversion rather than leaving empty subtitle space.
5. **Forms and onboarding (1–2 days).** Sign-in and Create Dynamic lose the serif headlines, prose fillers, rounded option cards, and pill selectors. Use section labels, divided option rows, underline fields, and 2 dp buttons. Preserve only functional consent/privacy language.
6. **Long tail and overlays (1–2 days).** Settings, histories, error/empty states, sheets, and web-width behavior. Audit every remaining border: if it does not communicate editability, selection, focus, modal containment, or risk, remove it.
7. **Visual/semantic regression gate (0.5 day).** Search source for old hex values, `Lora`, `DsCard`, radius values above 4, forbidden icon terms/assets, and marketing subtitles. Golden-test the three showcase screens at 320, 390, and 720 dp, light/dark, text scale 1.0/1.5/2.0. Verify that ReplyPlane is never constructed from automated copy.

### Temporary compatibility rule

During migration, an unmigrated screen may use the new colours and Instrument Sans while retaining its old layout for one short-lived release branch. A migrated screen may not import old colour, typography, rail, ribbon, or card tokens. Add deprecation annotations and a lint/CI grep so the compatibility phase has an end.

## Acceptance checklist

- No pixel uses Bone `#F4F1EB`, Terracotta `#B5533B`, Olive `#2F3A2E`, Moss `#1E241F`, or a visually equivalent cream/orange/olive substitution.
- No Lora or serif appears outside verified human-authored received words.
- No ordinary content is enclosed by a rounded card.
- No radius exceeds 4 dp; page content has no shadow.
- No explanatory subtitle merely restates a title, count, or state.
- A screenshot in grayscale is still recognisable through the hinge and Reply Plane.
- On every screen containing a partner response, those words have the greatest combination of type size, contrast, and uninterrupted area.
- No automation-generated string can be styled as a partner response or inserted into the response composer.
- Today · Dynamic · Explore · Us remain the only bottom-navigation destinations.
- Lockscreen, browser title, app icon, and app switcher remain discreet at default settings.
