# BeMoreKinky — captured screens

Source: screenshots taken by the product owner on an Android device,
2026-09-01. Nine screens, filed in `screens/`.

**Status: raw capture. Analysis has not been done yet** — this file records
what is visible on each screen and nothing else. Where a label is cut off by
the screen edge or the navigation bar, it is marked `[cut]` rather than
guessed at. Nothing here is a recommendation, and no conclusion about our own
product should be drawn from this file alone; that comes next, with the owner.

Note on completeness: these are nine screens of a shipped app, not a map of
it. Several tabs were not captured, and no flow was followed end to end, so
absence from this file is not evidence that a feature is absent from the
product.

## Global structure

Five-tab bottom navigation, consistent across every captured screen:

`Explore` · `Play` · `Partner` · `Workshop` · `Profile`

Visual register: near-black background, cream serif headings, purple accent
(`#8B5CF6`-ish) for primary actions and iconography, amber/orange for a `PRO`
badge and for some category icons. Illustration style is warm, painterly,
low-light figurative art.

## Screens

### 01 — Practices & bodywork (`01-practices-bodywork.jpg`)
Reached from a back arrow, so it is a sub-page rather than a tab root.
Subtitle: "Guided exercises for connection, awareness, and intimacy".
A vertical list of cards, each with painterly artwork on the left and text
right, tagged by who it is for:

| Card | Description | Tag |
|---|---|---|
| Sensate Focus | Guided couples touch exercises for mindful sensation | COUPLES |
| Learning to Touch | Practise asking, receiving, and giving with clarity | COUPLES |
| Self Discovery | Build body awareness and confidence at your own pace | SOLO |
| Active Receiving | Learn to move, breathe, speak, and ask while receiving touch | [cut] |

### 02 — Play Hub (`02-play-hub.jpg`)
Tab root (`Play`). Subtitle: "Your intimate connection center".
Primary card, purple-outlined: **Suggest a Plan** — "Create a play proposal
for your partner".
Below: **Draft Proposals (2)**, with the line "These will be sent when you
connect with a partner". Each draft row shows a document icon, the title
"Draft Proposal", a target date ("For Thu, Jun 18" / "For Thu, Jun 11"), the
count "1 activity selected", an **Expired** pill, and a delete (bin) icon.

Both visible drafts are Expired, and the dates are months before the capture
date — so a proposal appears to carry a deadline that lapses on its own.

### 03 — Partner Connection (`03-partner-connection.jpg`)
Tab root (`Partner`), in the not-yet-connected state. "Connect with your
partner to unlock personalized experiences and explore together."

Under **WHAT YOU'LL UNLOCK**:
- **Encrypted Chat** — "End-to-end encrypted messaging only you and your
  partner can read"
- **Shared Preferences** — "Discover what you both enjoy and find shared
  interests"
- **Habits Together** — "Assign tasks, track completion, and build your
  dynamic"

Then a partially visible list: "See each other's quiz results and
preferences", "View your partner's activity ratings", "Schedule intimate
moments together" [partly obscured by the tab bar].

The whole tab is gated on pairing, and the gate is presented as a list of
rewards for connecting.

### 04 — Workshop, top (`04-workshop-top.jpg`)
Tab root (`Workshop`). Subtitle: "Games, tools, and guided practice for two
or solo."

- Eyebrow **PARTNER TOOL** → **Habits** — "Protocol tracker for service with
  rewards, points and discipline" · Open
- Eyebrow **PRIVATE JOURNAL** + **NEW** badge → **Journal** — "Daily
  check-ins, reflections, and emotion tracking." · Open

Section heading **Games & play** begins below.

### 05 — Workshop, games and skills (`05-workshop-games-skills.jpg`)
Continuation of the same tab, scrolled.

**Games & play** — horizontally scrolling cards:
- **The Path** — "A pass-the-phone board game for two: set your boundaries
  together, then see where t…" [cut]
- **Punishm…** [cut] — "Spin the wh…" [cut]

**Skills & learning** — horizontally scrolling cards:
- **Shibari Practice** — "Guided video tutorials for Japanese rope bondage
  foundations"
- **Speaking…** [cut] — "Choose titl… / speaking" [cut]

Then a full-width card: eyebrow **SCENE GENERATOR** → **AI Scene Builder** —
"Create personalized scenarios with AI assistance", "About 5 min", with an
amber **🔒 PRO** badge.

### 06 — Profile, top (`06-profile-top.jpg`)
Tab root (`Profile`). Two counters: **0 Quizzes Completed**, **15 Activities
Rated**.
- **In the Mood** card with a toggle, currently off: "Connect a partner before
  turning this on."
- **Free Account** — "Upgrade to unlock exclusive quizzes and content" ·
  Upgrade
- **Your Content** section begins: Account, Activities & Quizzes.

### 07 — Profile, Your Content (`07-profile-your-content.jpg`)
Same tab, scrolled. Rows:
- **Account** — "Name, notifications and partners"
- **Activities & Quizzes** — "Your rated activities, quiz results and resets"
- **My Journal** — "Your daily logs and reflections"
- **Personalization** — "Gender, titles, role terms and images"
- **Habit Settings** — "Timezone, vacation mode and more"

"Titles, role terms" and "vacation mode" are both user-configurable.

### 08 — Sensate Focus (`08-sensate-focus-stages.jpg`)
Detail page reached from 01. Map and clock icons top right.
Description: "Guided couples touch exercises. Reduce pressure, increase
presence, rebuild connection through mindful sensation."
Counters: **0 Sessions · 0 Day streak · 1 Stages open · 0 Regions**.

**Choose a stage** — a locked ladder:
| Stage | Description | State |
|---|---|---|
| 1: Exploratory Touch | Discovering sensation without expectation | open, counter 0 |
| 2: Expanded Touch | Including the whole body with the same curious attention | 🔒 "Complete 1 more session at Stage 1 to unlock" |
| 3: Enhanced Sensation | Adding a new sensory dimension | 🔒 "Complete 1 more session at Stage 2 to unlock" |
| 4: Mutual Touch | Touching and being touched at the same time | 🔒 [cut] |

### 09 — Suggest a Plan (`09-suggest-a-plan.jpg`)
Reached from 02. "Create a play proposal for your partner".
Notice: "**Creating a Draft** — Your proposal will be saved as a draft until
you connect with a partner. Once connected, your drafts will automatically be
sent."
**When?** — a horizontal date strip (TUE 1 selected, WED 2, THU 3, FRI 4,
SAT 5, …).
**Activities for this proposal** — empty state "No activities selected /
Choose activities for your proposal", with a **Choose activities** button.
Footer: "Proposal for today" and **Save as draft**.

## Vocabulary observed

Recorded because it is the most directly comparable thing to our own glossary
work, without any judgement attached here:

play · proposal · plan · practice · bodywork · protocol · service · rewards ·
points · discipline · punishment · habits · boundaries · scene · titles ·
role terms · dynamic · session · streak · stages · regions

## Open questions for analysis

- What is behind `Explore` — the one tab root not captured.
- What "Regions" counts on a Sensate Focus session.
- Whether "Habits" points/rewards/discipline are automated or partner-entered.
- What The Path does with the boundaries it collects.
- Where limits/safewords live, if anywhere, outside The Path's setup.
- Whether proposals expire server-side, and what the couple sees when one does.
