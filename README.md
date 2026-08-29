# D/s Relationship Companion

Private product, design, and implementation source of truth for the Android app and Web Companion.

## Current direction

- Product: a consent-aware D/s relationship companion organized around six Core Daily Loops.
- Visual system: **V5 · Warm Authority**, evolved from Quiet Authority.
- Design principles: authority, human warmth, ritual identity, partner presence, emblem system, restrained botanical/editorial detail.
- Platforms: Flutter Android first; Flutter Web Companion for invitation and iOS access.
- Figma: intentionally removed. This repository is the canonical handoff source.

## Reading order

1. `CLAUDE.md` or `AGENTS.md`
2. `manifests/screen-index.json`
3. Target `design/screens/SCR-*/screen.md`
4. Product references linked from that screen contract
5. Target `preview.webp`
6. `manifests/svg-freeze.v1.json` and `design/assets/svg/SVG-FREEZE.md`
7. `manifests/assets.json` and the linked SVG masters
8. `manifests/token-freeze.b2.v1.json`, `design/tokens/B2-FREEZE.md` and generated bindings
9. `design/tokens/design-tokens.json` and `design/system/`
10. `progress/status.md`

No implementation may infer missing behavior from a raster image. A screen must be marked `ready_for_build` in the active manifest before development begins.

## Repository layout

| Directory | What it holds | Authority |
|---|---|---|
| `product/` | Requirements, flows, domain and state contracts | Product truth |
| `design/` | Approved visual system: screens, tokens, SVG masters, fonts, textures | Visual truth |
| `manifests/` | Machine-readable freezes, screen index, gates, traceability | Gate truth |
| `app/` | Gate-independent Flutter design-system package | Foundation |
| `client/` | Flutter application: routing, features, domain client, platform adapters | Implementation |
| `backend/` | Kotlin/Spring modular monolith, Flyway migrations, jOOQ | Implementation |
| `ops/` | Deployment and journey scripts | Operations |
| `tool/` | Foundation generators, sync and drift validation | Tooling |
| `docs/legacy/` | Pre-migration history. Not authoritative | Archive |

### `app/` versus `client/`

`app/` is the portable design-system package: frozen fonts, the eight type
roles, B-2 tokens, all 33 semantic SVG assets, Ritual/Living themes and the
deterministic B-4 ritual surface. It carries no product screen and no
navigation shell, and it stays that way while screen gates remain blocked.

`client/` is the running Flutter application that predates this design system.
It is retained because it holds working product behavior — activation, the
human response loop, adjustments, and their tests — that the frozen design has
not yet been applied to. It still consumes its own pre-migration token layer.

**These two are not yet joined, and joining them is a gated task.** `client/`
screens migrate onto the `app/` foundation only as each Screen Package reaches
`ready_for_build`. Until then, do not import `app/` from `client/`, and do not
extend the pre-migration token layer in `client/lib/design_system/`.

## Verification

```bash
# Foundation: generators, drift validation
npm install && npm run foundation:check

# Design-system package
cd app && flutter pub get && flutter analyze && flutter test

# Flutter application
cd client && flutter pub get && flutter analyze && flutter test

# Backend (requires JDK 21 and PostgreSQL on 5433)
cd backend && ./gradlew test
```

## Traceability rule

Every buildable UI must form one unbroken chain:

`Product requirement → Screen contract → Visual reference → Asset ID/SVG → Component/code → QA evidence`

If any link is missing, the screen remains blocked.
