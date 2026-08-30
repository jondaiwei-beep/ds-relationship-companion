---
name: ds-design-lookup
description: Find what the design system says about anything in the D/s Relationship Companion — which screen covers a feature, which SVG assets a screen uses, what a colour or size token resolves to, which screens are buildable, or what a product requirement maps to. Use before answering any question about the design, and before assuming something is missing.
---

# Finding things in the design system

The repository answers most design questions precisely. This is where to look,
so the answer is read rather than guessed.

Everything is machine-readable. Prefer querying the manifests over reading
prose, and never conclude something is missing without checking the registry.

## Which screens can I build right now

```bash
python3 -c "
import json
from collections import Counter
d=json.load(open('manifests/screen-index.json'))
s=d['screens']
print(dict(Counter(x['build_gate'] for x in s)))
print('ready:', [x['screen_id'] for x in s if x['build_gate']=='ready_for_build'])"
```

`blocked_alignment_required` means the design or product contract is incomplete.
`future_reference` is out of Core Beta scope. Only `ready_for_build` is
implementable, and gates change only by owner decision.

## What does this screen need

```bash
python3 -c "
import json
d=json.load(open('manifests/screen-index.json'))
s=[x for x in d['screens'] if x['screen_id']=='SCR-01'][0]
print(json.dumps(s, indent=2, ensure_ascii=False))"
```

Gives requirement IDs, flow IDs, every asset ID, the contract path and the
preview path. Then read `screen.md` in that folder for the state matrix, and
`candidates/rev-N/design-qa.md` where it exists — that file often states the
acceptance criteria in one paragraph.

## Which screens use a given asset

```bash
python3 -c "
import json
d=json.load(open('manifests/assets.json'))
a=[x for x in d['assets'] if x['id']=='mark.presence'][0]
print(a['source_path'], a['status'], a['used_by'])"
```

All 33 masters are `approved`. In Dart they are `DsAssets.markPresence` and so
on — camel-cased from the ID.

## What does a token resolve to

The generated bindings are authoritative:
`app/lib/src/design_system/generated/ds_design_tokens.g.dart`

The reasoning lives in `design/tokens/B2-FREEZE.md` — read it before using a
state or relationship colour, because several carry rules the value alone does
not express. `#080B07` is the ritual canvas; pure black and Material dark
defaults are explicitly wrong.

## Which type role should this text take

`design/system/type-in-practice.md` maps content kinds to roles, records the two
gaps the frozen eight do not cover, and states the rules that are not
negotiable — the serif belongs to human words, Terracotta text has a size floor.

## What is a requirement, flow, or domain rule

| Question | File |
|---|---|
| What must the product do | `product/requirements/core-beta.md` |
| How does a journey run | `product/flows/core-beta-flows.md` |
| What are the states and their legal transitions | `product/domain/core-beta-state-contracts.md` |
| Why is a domain decision the way it is | `product/domain/g1-g4-implemented-answers.md` |
| What behaviour must every screen preserve | `product/ui-invariants.md` |

`REQ-*` and `FLOW-*` IDs in a screen contract resolve into these files.

## Is a feature designed yet

`design/coverage/core-beta-coverage.md` is the product-family × design matrix.
For each family it states the current design, the decision (retain / redesign /
new / replace) and exactly what visual work remains. Check here before
concluding a surface is missing — several exist as rev-2 candidates awaiting
approval rather than as gaps.

## What is blocking implementation overall

`BLOCKERS-FOR-BUILD.md` at the root, and `progress/status.md` for what is done
and what is next.

## Rules that override convenience

- **Never trace or redraw an asset from a raster preview.** If a master does not
  exist, the screen cannot draw it. This is stated in `SVG-FREEZE.md` and it
  holds without exception — a traced mark is a forged asset. Adding a *new*
  master is a design task with its own freeze process, not something to
  improvise mid-screen.
- **Never infer product behaviour from a design image.** A raster is a visual
  reference, not a behavioural specification. Missing states, copy or permission
  rules are design work to be *produced* (see `ds-design-generate`), not gaps to
  fill with judgement while building.
- **Open a gate only on evidence.** You own the decision, but the gate means
  one checkable thing: every state-matrix row has a candidate or a justified
  N/A, and the states are rendered. Count the blocked rows; do not assert it.

  A closed gate means *go make the missing design*, not *stop and wait*. The
  system is frozen and the style is settled, so producing a state family is
  execution. Generate it, review it, render it, commit it, open the gate, build.
