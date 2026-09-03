# D/s Relationship Companion

Private product, design, and implementation source of truth for the Android app and Web Companion.

## Current direction (2026-09-03 重写)

给"白天分开、晚上见面"的 D/s 两人用的日常记录。四个 tab：今天 / 规矩 / 记录 / 分。全部产品决定来自真实用户原话（`research/`），见 `product/00-thesis.md`。

## Reading order

1. `product/README.md` → `00-thesis` → `01-users` → `02-surfaces` → `03-domain` → `04-explore` → `05-decisions` → `06-build-order`
2. `research/synthesis.md`（为什么是这样），`competitors.md` / `voices-*.md`（原话）
3. `design/tokens/design-tokens.json`、`design/system/`、`manifests/assets.json`（视觉基础）
4. `CLAUDE.md` / `AGENTS.md`

## Repository layout

| Directory | What it holds | Authority |
|---|---|---|
| `product/` | 7 份文档：命题、用户、界面、领域模型、探索、决策记录、开发顺序 | Product truth |
| `research/` | 用户原话、竞品评论、综合 | 出处 |
| `design/` | 视觉基础：tokens、SVG masters、fonts、textures、system | Visual truth |
| `manifests/` | 资产与 token 冻结清单 | Asset truth |
| `app/` | Gate-independent Flutter design-system package | Foundation |
| `client/` | Flutter application: routing, features, domain client, platform adapters | Implementation |
| `backend/` | Kotlin/Spring modular monolith, Flyway migrations, jOOQ | Implementation |
| `ops/` | Deployment and journey scripts | Operations |
| `tool/` | Foundation generators, sync and drift validation | Tooling |

### `app/` versus `client/`

`app/` is the portable design-system package: frozen fonts, the eight type
roles, B-2 tokens, all 33 semantic SVG assets, Ritual/Living themes and the
deterministic B-4 ritual surface. It carries no product screen and no
navigation shell, and it stays that way while screen gates remain blocked.

`client/` is the running Flutter application. It holds working product behavior
(activation, occurrences, response loop, points) that is being reshaped to
`product/03-domain.md`.

`client/` 界面按 `product/06-build-order.md` 逐阶段迁到 `app/` 的主题与组件上。

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

## Rule

产品行为改动先写进 `product/05-decisions.md`（带出处），再改代码。违反 `product/03-domain.md` 不变量的代码不合并。
