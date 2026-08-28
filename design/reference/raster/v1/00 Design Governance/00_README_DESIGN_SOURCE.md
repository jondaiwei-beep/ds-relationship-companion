# D/s Relationship Companion — Design Source & Development Handoff

Version: 1.0.0  
Date: 2026-08-28  
Visual direction: V5 Warm Authority / Quiet Authority  
Library root: `/D-s Relationship Companion/UI Design`

## 1. Canonical source model

This project uses two coordinated sources. Neither source may silently override the other.

- **Notion CURRENT v2** owns product intent, business behavior, domain state, permissions, release scope, and acceptance criteria.
- **Library** owns the approved visual system, screen composition, interaction hierarchy, visual copy placement, and versioned implementation handoff.
- **Figma** may remain the editable design workspace when available, but developers implement only from a released Library handoff package and its manifest.

If Notion and Library disagree, the affected screen is **BLOCKED**. Developers must not guess which side is correct.

## 2. Developer reading order

1. Read Notion `CURRENT — Developer Handoff v2 · Start Here` and its seven canonical documents.
2. Read this file.
3. Parse `design-manifest.v1.json`.
4. Read `00 Visual Baseline/00-selected-style-reference.png`.
5. Read only the screens whose `implementation_gate` is `ready_for_build`.
6. Treat `future_reference` and `replace_or_merge` screens as non-buildable references.

Reading every image without the manifest is not a valid handoff process.

## 3. Alignment contract

Every buildable screen must have the same values on both sides for:

- Screen ID and screen name
- Release tier
- Intended role and platform
- User question / job to be done
- Entry conditions and exit actions
- Business states and side paths
- Privacy and authorization behavior
- Primary and secondary actions
- Human-authored versus system-authored copy
- Empty, loading, offline, expired, blocked, and stale-link states

## 4. Version rules

- `product_spec_version`: version of the Notion canonical product contract.
- `design_manifest_version`: version of the Library handoff package.
- `screen_revision`: revision of one screen or state family.
- A screen becomes `ready_for_build` only after product and design are both approved at the recorded versions.
- Any behavior change updates Notion and the manifest in the same change set.
- Any layout, copy hierarchy, state visibility, or interaction change updates the image and the manifest in the same change set.

## 5. Current design decision

The existing Warm Authority visual direction is retained. Product alignment must not trigger a new visual exploration.

Preserve:

- Bone / Stone / Deep Olive / Dark Moss / Terracotta palette
- Near-black green material and restrained film grain
- Editorial serif for display moments and human response
- Humanist sans for operational content
- Emblem, Partner Presence, and relational axis systems
- Authority through hierarchy rather than fetish imagery
- Function-specific screen structures rather than one repeated page template

## 6. Current screen disposition

### Retain and align

`01–06`, `08–10`, `13–14`, `19–20`, `24–25`, `28–30`

These screens preserve their visual direction but may require product-state, copy, or navigation adjustments before implementation.

### Replace or merge

- `07` — place after Goal or merge into Minimal Setup.
- `11` — merge its trust/agency content into Web Join Confirmation.
- `12` — replace with Starter Rhythm.
- `17` — reframe Us around recent relationship events and a light D7 reflection.
- `22` — replace advanced reflection with simple Daily Check-in for Core Beta.
- `23` — simplify to one D7 Keep / Adjust / Pause card.
- `26` — simplify privacy for Core Beta; retain advanced controls for P1.

### Future reference

- `15` Agreements
- `16` Advanced Reflections
- `18` Full Explore
- `21` Agreement Change Review / Proposal
- `27` Subscription / Upgrade

These files remain valuable design assets but are not Core Beta build instructions.

## 7. Critical missing Core Beta design families

1. Goal selection
2. Starter Rhythm
3. Receiving-side Today list state
4. Direction-giving Attention state
5. Acknowledgement composer / inline response
6. Need to Discuss / Request New Time / Can't Do
7. Partner adjustment resolution and Needs Review
8. Simple Daily Check-in
9. Resume choice: same / lighter / adjust
10. Block, leave confirmation, ended and stale-link states
11. Timezone, custom day boundary, and timezone-change confirmation
12. Web Invite, Magic Link, Web Join, expired/revoked invite, and Safari recovery states
13. Loading, empty, offline, retry, duplicate-submit, and authorization-loss states

## 8. Semantic color rule

- Terracotta primarily means human Partner presence, acknowledgement, or proposed change.
- Destructive actions remain neutral at entry and use Terracotta only at the final confirmation threshold.
- Do not use the same visual signal simultaneously for Partner warmth and immediate danger on one screen.

## 9. Build gate checklist

- [ ] Notion behavior/state contract is current.
- [ ] Library image exists at the manifest path.
- [ ] Screen purpose, states, copy, and actions match Notion.
- [ ] Android and Web platform variants are identified.
- [ ] Privacy and agency invariants are represented.
- [ ] Error/empty/offline/stale states are specified.
- [ ] Accessibility implementation notes are present.
- [ ] `implementation_gate` is changed to `ready_for_build`.

## 10. Current handoff status

The visual system is approved. The current image set is a versioned design inventory, not yet a fully aligned build package. Until the missing flows and screen corrections are completed, developers should use it for visual-system implementation and explicitly approved vertical slices only.
