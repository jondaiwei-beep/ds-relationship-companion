# Type in practice

`typography.md` freezes eight roles. This records which role each kind of
content actually takes, and the two places SCR-01 needed a value the frozen set
does not carry. Written from a built and rendered screen, not from theory.

## The eight frozen roles, and what they are for

| Role | Frozen | Use it for |
|---|---:|---|
| `display.ritual` | Cormorant 34/42 | The ritual-focus composition: one thing, centred, alone on the screen |
| `display.partner` | Cormorant 28/36 | Words a person wrote and sent |
| `title.page` | Inter 600 · 22/28 | The name of a surface |
| `body.primary` | Inter 400 · 16/24 | Content a person reads to decide something |
| `body.secondary` | Inter 400 · 14/20 | Supporting content that qualifies the primary |
| `label.action` | Inter 600 · 16/20 · 0.1 | Text inside a control |
| `label.ritual` | Inter 500 · 12/16 · 2.4 | Structural labels in caps |
| `nav.label` | Inter 500 · 12/16 | Bottom navigation |

## What SCR-01 actually used

| Element | Role | Deviation |
|---|---|---|
| `Today` | `title.page` | 23px, w600 — measured from the design |
| `Morgan is present` | `body.secondary` | — |
| `THREE THINGS MATTER` | `label.ritual` | — |
| `01 · NOW · EXPECTATION` | `label.ritual` | — |
| Expectation headline | `display.ritual` | **28/31**, not 34/42 |
| `From Morgan · due 9:00 PM` | `body.secondary` | **12/17** |
| `Complete` | `label.action` | — |
| Discuss / New time / Can't do | `body.secondary` | **12/17** |
| Row titles (`Evening ritual`) | `body.primary` | 17px |
| Row metadata (`8:30 PM · 6 min`) | `body.secondary` | **12/17** |
| `MORGAN RESPONDED · 12 MIN AGO` | `label.ritual` | — |
| `"I noticed your care."` | `display.partner` | — |
| `LATER / OPTIONAL` | `label.ritual` | — |
| `Relationship day ends at 2:00 AM` | `body.secondary` | — |
| Navigation labels | `nav.label` | — |

## The two gaps the frozen set does not cover

### 1. The serif has two sizes, not one

`display.ritual` at 34/42 is correct for the ritual-focus screen, where the
headline is the only thing present. In the prioritised list the same role sits
above a button, three actions and two more rows, and the design sets it at
**28px on a 31px line box**. Measured from the approved image: two lines
spanning 100px, baselines 31px apart.

Both are legitimate; they are different compositions. Proposed:

| Token | Value | Use |
|---|---:|---|
| `display.ritual` | 34/42 | Ritual focus — one expectation, alone |
| `display.expectation` | 28/31 | The first priority in a list |

Until frozen, SCR-01 overrides `display.ritual` inline with the reason stated
at the call site.

### 2. Supporting copy needs a step below 14px

`body.secondary` at 14px reads too heavy next to a 28px serif headline. Item
metadata and the quiet adjustment actions want one step down. The owner
confirmed this by eye before it was measured. Proposed:

| Token | Value | Use |
|---|---:|---|
| `body.support` | Inter 400 · 12/17 | Item metadata, quiet secondary actions |

12px is the floor. Nothing goes below it, and `label.ritual` already occupies
12px with heavy tracking for a different purpose.

## Rules that are not negotiable

**Cormorant appears only where a person's words appear.** On SCR-01 that is the
expectation itself and the partner's quotation. Every other string is Inter.
`app/test/design_system_foundation_test.dart` asserts UI chrome cannot take the
display family.

**Terracotta text needs 24sp regular or 19sp bold** (`B2-FREEZE.md` §2, 4.02:1
against the ritual canvas). The partner quotation qualifies at 28px. Small
partner-status labels stay Stone with a Terracotta mark beside them — colour
alone never carries state.

**`label.ritual` is wider than it looks.** 2.4 tracking on a caps string
overflowed the viewport twice during this build. Wrap it in `Flexible` with
`TextOverflow.ellipsis` wherever it shares a row.

**Never let a font fall back silently.** Every role carries the package
qualifier so it resolves from the design-system package rather than the host.
A test fails if a role is added without it.

## Where a deviation belongs

Inline in the widget, with the reason:

```dart
// Design measures 28px with a 31px line box; the frozen 34/42 role is the
// ritual-focus size, not this one.
style: DsTextStyles.displayRitual.copyWith(fontSize: 28, height: 31 / 28),
```

A deviation that appears on a second screen stops being a deviation and becomes
a token. Both proposals above have now appeared once.
