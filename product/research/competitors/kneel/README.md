# Kneel — captured screens

Source: screenshots taken by the product owner on an Android device,
2026-09-01. Five screens, filed in `screens/`.

**Status: raw capture. Analysis has not been done yet.** Cut-off or
ambiguous labels are marked rather than guessed at.

Unlike the Obedience capture, this account appears to be **paired** — the
header carries a real user avatar rather than an "Invite a partner" prompt,
and the Tasks empty state reads "Tasks will appear here when assigned",
implying an assigner exists. This is not confirmed from the screens alone.

Free tier: two of the five captured screens are paywalls, so a substantial
part of this product was not observable.

## Global structure

Four-tab bottom navigation, labels visible on every tab:

`Home` (diamond) · `Actions` (check) · `Consequences` (gavel/pendulum) ·
`Chastity` (∞)

`Home` was not captured.

Visual register: near-black background, **crimson/magenta** (`#C41E4A`-ish)
for the active tab, primary buttons and the FAB; **warm tan/gold** for
numerals, eyebrow labels and the secondary tab underline; white sans-serif
headings. Noticeably more restrained than Obedience — thin line icons, wide
letter-spaced eyebrows, generous vertical space, faint botanical line-art
watermarks behind the Ideas rows.

Of the three products captured, this is the closest to our own visual and
verbal register.

## Screens

### 01 — Tasks, empty (`01-tasks-empty.jpg`)
Tab root (`Actions`). Title **Tasks**, eyebrow **DUTIES**.
Two levels of tabs:
- Primary: **Tasks** | Rituals
- Secondary: **Pending** | Completed

Two counters: **TODAY — None due today** · **PENDING — 0 awaiting**.

Empty state: clipboard glyph, "**No tasks yet**", "Tasks will appear here
when assigned", a crimson **Browse ideas** button, and a crimson `+` FAB.

Note the vocabulary pairing: Tasks/Duties alongside Rituals, and a
Pending/Completed split rather than a pass/fail one. The empty state offers
a library rather than an exhortation.

### 02 — Ideas (`02-ideas-collections.jpg`)
Reached from "Browse ideas". Title **Ideas**, back chevron.
Subtitle: "**Pick an idea, adjust the details, then assign it.**"

Numbered collections, each with a count and a faint line-art motif:

| # | Collection | Count | Blurb |
|---|---|---|---|
| 01 | **Beginnings** | 8 IDEAS | "Low-pressure ideas for building a clear, steady rhythm together." |
| 02 | **Service** | 13 IDEAS | "Practical acts of care that make daily life feel more intentional." |
| 03 | **Long-Distance** | 9 IDEAS | "Simple ways to stay present, accountable, and connected while apart." |
| 04 | **Discipline & Structure** | 9 IDEAS | "Clear standards, routines, and proof-based ideas for stronger structure." |
| 05 | **Connection & Aftercare** | 7 IDEAS | "Warm rituals for reflection, reassurance, gratitude, and care." |

46 ideas across 5 collections. The collection set is strikingly close to the
one we just wrote (Beginnings / Service / Aftercare all appear in both), and
Long-Distance is a category we have a documented design pressure case for but
no content addressing.

"Proof-based" appears in the Discipline & Structure blurb.

### 03 — Define the Task (`03-define-task-wizard.jpg`)
Creation wizard, close `×` top right. A three-dot progress indicator, step 1
of 3 filled. Eyebrow: **THE ESSENTIALS**.

- "**Define the *Task***" — "What needs to be accomplished?" — field
  placeholder "What needs to be done?", counter `0/100`
- "**The *Details***" — "Provide any additional context or instructions…" —
  field placeholder "Add more details…"
- Crimson **Continue**

Two-field first step, and the assigner writes both. Compare our own Ask flow,
which is also what-then-why.

### 04 — Consequences → Rewards, locked (`04-consequences-rewards-locked.jpg`)
Tab root (`Consequences`). Three sub-tabs: **Rewards** | Punish | Verify.

Counters: **BALANCE — 0 points earned** · **STREAK — 0 consecutive days**.

Locked state: gift glyph, "**Rewards are locked**", "Rewards let you set
treats your partner earns with points. Unlock premium to start."
Below, a bordered row: "Rewards and punishments are a premium feature" with
an **Unlock** button. A `LIBRARY` label is faintly visible behind it [partly
obscured].

The counters render even while the feature is locked, so points and streak
appear to be first-class product concepts rather than premium add-ons.
**Verify** as a peer of Rewards and Punish is the notable one — it suggests
proof-checking is a distinct step in this product's loop.

### 05 — Chastity (`05-chastity-premium.jpg`)
Tab root (`Chastity`), entirely paywalled.
Lock glyph, "**Premium Feature**", eyebrow **CHASTITY**, and: "Track lock
sessions, check-ins, release requests, and more with a premium membership."
Crimson **Upgrade to Premium**.

An entire bottom-nav tab is a single premium feature. "Release requests"
implies a request/approval flow between the two people.

## Vocabulary observed

tasks · duties · rituals · pending · completed · ideas · assign · beginnings ·
service · long-distance · discipline · structure · proof-based · connection ·
aftercare · consequences · rewards · punish · verify · balance · points ·
streak · chastity · lock sessions · release requests · premium

## Open questions for analysis

- What `Home` contains — the one tab not captured.
- What **Verify** does: who submits proof, who checks it, what happens on a
  failed verification.
- Whether points/streak are automatic, and what a broken streak causes.
- Steps 2 and 3 of the task wizard (deadline? proof? consequence?).
- Whether `Rituals` differs structurally from `Tasks` or is only a filter.
- What the 46 ideas actually say — the collection blurbs are close to ours,
  but blurbs are not content.
- Whether Chastity's "release requests" is a general request/approval
  mechanism or specific to that feature.
