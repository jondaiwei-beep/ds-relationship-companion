# Redesign brief · 2026-09-04

Why: the owner's first hands-on (0.9.1+4) and a Codex review of seven device
screenshots (`design/reviews/2026-09-04-codex-ui-review.md`) agreed on the
verdict: every rule is followed and the pages still read as a dark to-do
template. Type hierarchy is 1.5–2×, every action is the same pill, every empty
state says "Nothing yet", and the pages show relationship data before there is
a relationship. This brief is the fix. It is binding for the four tabs.

## 1. The one expensive decision: the page anchor

Each tab has exactly one Cormorant Garamond anchor at `display.hero`
(44/48, weight 400, lining figures). Everything else is Inter and small.
Hierarchy target: largest ÷ smallest ≥ 3.5 (44 ÷ 12).

| Tab | Anchor | Eyebrow above it (`label.ritual`) |
|---|---|---|
| Today | the day, e.g. `4 September` | `FRIDAY · FROM 04:00` |
| Rules | `Rules` | none |
| Record | the day being looked at | `RECORD · FRIDAY` |
| Points | the balance (already) | `{NAME} HAS` |

Shared widget: `client/lib/app/shell/page_hero.dart` → `PageHero(eyebrow:, hero:, support:)`.
The old small Inter title row (`TodayHeader.title`) is dropped on tabs whose
anchor is the page name: pass `title: null`; the row keeps presence + bell + settings.

## 2. Button grammar — three kinds, used for three reasons

| Kind | Widget | Use for | Per screen |
|---|---|---|---|
| Primary | `WordButton(filled: true)` | the thing you came to do | ≤ 1 per section, ideally 1 per screen |
| Secondary | `WordButton()` outlined | create / adjust | as needed |
| Quiet | `WordButton(quiet: true)` text-only | navigation, low-frequency, links: Export, Compare, Explore, Pause, I'm away | as needed |
| Danger | `WordButton(danger: true)` outlined in the destructive border | Pause the dynamic (inside its confirm sheet), Delete | inside sheets only |

Never two filled buttons side by side. Never a filled button for navigation.

## 3. Stage before data

`alone` = the partner has not joined (`TodayNotice.isAlone(detail)`).
While alone: no balance, no days-together, no `0/2 delivered`, no streak, no
"today for {partner}", no Give/Deduct. The invite block is the page's main
content. Lists that need two people say so in one line
("Starts when they join.") instead of showing zeros.

Streak ("N in a row") is no longer displayed anywhere (decision D-31).
Days together shows only when not alone.

## 4. Empty states say why and what next

Never a bare "Nothing yet." / "None." One or two sentences: what would appear
here, and the one thing that makes it appear. Where a section is empty *and*
optional (Proposed, Requests, Consequences on Points), omit the section.

## 5. Copy changes (en → see ARB; zh alongside)

- "What about tonight?" → "Draw an idea for tonight"
- "Waiting on me" → "For you to answer"
- "Today for {name}" → "{name}'s day"
- "Add one" / "What" → "Add for today" / "One thing, in a line"
- "To remember" / "Note to self" → "Only you" / "A note only you see"
- Consequences intro → "Only you use these, when you answer a delivery. Nothing here runs on its own."
- Limits intro → "What either of you marked “no”. Your safeword is also in Settings."
- Partner fallback everywhere: "your partner" / 「对方」, never "the s".
- Record header: drop " · N in a row".

## 6. Icons

Tab icons are drawn glyphs (`DsGlyph`), 1.5 stroke, not Material. Rules gets a
new `DsGlyph.rules` (two full rules and a short third) replacing the waveform.

## 7. Page skeletons (top → bottom)

Today (D): header row · PageHero(day) · status line (presence / balance · days,
only when not alone) · Notice (invite / paused / away) · quiet row
[Draw an idea for tonight · I'm away] · FOR YOU TO ANSWER · {NAME}'S DAY (list
the tasks, not just a count; hidden while alone) · ADD FOR TODAY · ONLY YOU.

Rules: header row · PageHero("Rules") · STANDING RULES · RECURRING TASKS ·
PROPOSED (only when non-empty) · LIMITS & SAFEWORD as the one bordered block
(hairline above and below, intro + list + quiet "Compare preferences") ·
REWARDS · CONSEQUENCES · quiet row [Preferences · Inspiration · Starter pack]
· quiet "Pause the dynamic…" at the very bottom. "I'm away" leaves this page.

Record: header row · PageHero(day) · that day's summary line + quiet "Open this
day" · month grid as navigation (dots, not `0/2` text; today outlined) ·
THIS WEEK · THIS MONTH with all-zero rows hidden (all zero → one line) ·
quiet "Export record" at the bottom.

Points: header row · eyebrow `{NAME} HAS` · hero number · support line: last
ledger change or why it is 0 · [Give filled · Deduct outlined] (hidden while
alone) · REDEEMABLE (empty → "No rewards yet." + quiet "Set one in Rules") ·
REQUESTS / CONSEQUENCES only when non-empty · LEDGER last 3 + quiet "All entries".

## 8. Done means

`flutter analyze` clean, `flutter test` green, then a device screenshot of
every changed screen in both stages (alone / joined) reviewed against §1–§7.
