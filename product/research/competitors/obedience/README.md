# Obedience — captured screens

Source: screenshots taken by the product owner on an Android device,
2026-09-01. Eight screens, filed in `screens/`.

**Status: raw capture. Analysis has not been done yet** — this file records
what is visible and nothing else. Cut-off or ambiguous labels are marked
rather than guessed at.

The account is unpaired throughout ("Invite a partner / No partner yet" in
every header), so every screen here is the solo/pre-pairing state. Nothing in
this capture shows what the app looks like once two people are connected,
which is the state the product is presumably built for.

## Global structure

Four-tab bottom navigation. Tab labels are only rendered for the selected
tab, so the set is assembled across screenshots:

| Icon | Label | Seen in |
|---|---|---|
| heart | **Rewards** | 02 |
| gavel | **Punishments** | 05 |
| check | **Habits** | 01 |
| clipboard | **Notes** | 08 |

Persistent red header on every tab: hamburger (with an amber dot badge),
centre avatar + "Invite a partner / No partner yet", and a chat icon top
right. An amber `+` FAB sits bottom-right on the list screens.

Visual register: deep red (`#A81E1E`-ish) header and cards, near-black page
background, amber/gold (`#C99A2E`-ish) for primary actions and the FAB, white
sans-serif text. Emoji used as content iconography throughout.

## Screens

### 01 — Habits (`01-habits.jpg`)
Tab root (`Habits`).

Top card, red with an amber **Buy** button: "**Get 63% off!**", a live
countdown "**23:59:56**", "Get premium for just ~~$39.99~~ **$14.99** the
first year".

Section heading **Tomorrow**. One habit card:
- **Gratefulness 🌼** — "Write down at least 5 things you are grateful for
  every day." Right side shows **0 / 1** and a `+`.
- Below the description, a row of ~19 **× × × × …** marks filling the card
  width.

The × row is the only history display on the card; no streak number is shown
beside it.

### 02 — Rewards (`02-rewards.jpg`)
Tab root (`Rewards`).

A balance control at the top: `−` **♥ -152** `+`. The balance is **negative**,
and both `−` and `+` are tappable directly.

One reward card:
- **Massage 💕** — "Receive a loving full body massage from your partner."
  "Cost: 10". Right side: a count **0** and an amber **Buy** button.

The Buy button appears greyed/dimmed relative to the amber Buy in screen 01,
which is consistent with a balance of -152 being below the cost of 10, though
the screenshot alone does not prove the button is disabled.

### 03 — Add reward (`03-add-reward.jpg`)
Modal sheet, close `×` top right.
"**Popular Rewards** — Don't know where to start? Pick from one of the popular
reward ideas below."

Chips: `Ice Cream 🍨` · `Date night 🍽` · `Movie night 🎥` · `Brat pass 🃏` ·
`Cheat day 😼` · `Play session 🎭` · `New stuffie 🧸`

Then a wide chip **Find kinky ideas**, and a red primary button **Add custom
reward**.

The preset list mixes everyday treats (ice cream, movie night) with
subculture-specific items (brat pass, play session, stuffie) in one
undifferentiated row.

### 04 — Side menu (`04-side-menu.jpg`)
Drawer from the hamburger. Large circular avatar with an edit pencil, then an
amber card: "**Free** / Current plan" with an **Upgrade** button.

Collapsible rows, each with a chevron: **Account**, **Activity** (with an
amber dot badge), **Appearance & Sound**, **Settings**, **Resources**,
**Support**. Social icons are partly visible at the very bottom [cut].

### 05 — Punishments, empty (`05-punishments-empty.jpg`)
Tab root (`Punishments`), empty state.
"**Get started with punishments** — Select a punishment you want to get
started with. You can always add more later, or create custom punishments."

Full-width red rows, each with a `+`:
`Write lines 📝` · `Corner time 🚪` · `Cold shower 🚿` · `Early bedtime ⏰`

Then **Find kinky ideas**, and an amber **Add custom punishment**.

### 06 — Add punishment, picker (`06-add-punishment-picker.jpg`)
Modal sheet, same shape as 03. "**Popular Punishments** — Don't know where to
start? Pick from one of the popular punishment ideas below."
Chips: `Write lines 📝` · `Corner time 🚪` · `Cold shower 🚿` ·
`Early bedtime ⏰`, then **Find kinky ideas** and a red **Add custom
punishment**.

### 07 — Add punishment, form (`07-add-punishment-form.jpg`)
Back arrow, title "Add punishment", confirm ✓ top right.

- **Punishment name**: "Early bedtime ⏰" with counter `15/35`
- **Description & Images** (expanded) — "Add a description & images for
  additional context."
  - **Punishment description**: "You will go to bed 1 hour earlier than
    usual." counter `45/500`
  - **Add image** button
- **Proof** — value **Disabled**, collapsed (camera icon)
- **Randomize** — "Add multiple punishments and let fate decide", collapsed
  (dice icon)
- Red **Save** button

`Proof` defaults to Disabled but exists as a first-class field, and it is a
camera. `Randomize` assigns a punishment by chance rather than by decision.

### 08 — Notes (`08-notes.jpg`)
Tab root (`Notes`). Four red cards:

| Card | State |
|---|---|
| **Fantasies** | **Begin** button |
| **Kinks** | shows user-entered Chinese text instead of a Begin button — the owner has typed into this one |
| **Limits** | **Begin** button |
| **Rules** | **Begin** button |

The visible Chinese text in the Kinks card is the owner's own test input, not
app copy. Limits is a peer of Fantasies/Kinks/Rules — a free-text note, not a
structured field, at least at this entry point.

## Vocabulary observed

obedience · habits · rewards · punishments · notes · proof · randomize ·
cost · buy · balance · streak [implied by the × row] · brat pass ·
play session · stuffie · corner time · write lines · fantasies · kinks ·
limits · rules · premium

## Open questions for analysis

- What the × row on a habit card means — missed days, or slots for a target.
- How the ♥ balance goes negative, and what a negative balance does.
- Whether punishments are issued automatically on a missed habit, or only by
  the partner.
- What `Proof` requires when enabled, and who can see the photo.
- Whether Limits (Notes) is ever read by any other part of the app, or is
  purely a private notepad.
- What "Find kinky ideas" opens.
- What the app does with all of this while there is no partner — every screen
  here is unpaired, yet rewards, punishments and habits are all fully usable.
