# ADR-0001 — Technology Stack Freeze

**Status**: Accepted (2026-08-27)
**Date**: 2026-08-26
**Driver**: `06 — Engineering Build Plan v2 §13.2` requires an M0 tech-selection freeze: *"state management、router、HTTP client、serialization/codegen、logging/error reporting；Core Beta 中途不再更换主方案。"*

---

## Context

Notion `06` fixes the backend **architecture** (modular monolith + one relational database + background worker + transactional outbox) but names no language, framework, or database. Flutter-side defaults were given by the product owner. This ADR freezes both so M0 scaffolding can start.

The selection pressure in this product is **not traffic scale**. It is:
- correctness of business state across two clients,
- server-side authorization on every sensitive read/write,
- idempotent commands under retry and concurrency,
- IANA timezone + local wall-clock + custom day boundary correctness across DST,
- async delivery decoupled from domain transactions via outbox,
- reliability that is treated as relationship trust, not ordinary bugs.

Every choice below is judged against those, not against throughput benchmarks.

---

## Decision — Flutter client

Confirming the owner-supplied defaults. No changes proposed.

| Concern | Choice | Rationale |
|---|---|---|
| State management | **Riverpod** (v2, code-gen) | Compile-safe DI, testable without widget tree, no BuildContext coupling. Better fit than BLoC for a repository/use-case architecture with heavy async state. **One solution only — BLoC must not coexist.** |
| Routing | **go_router** | Declarative, URL-first. Mandatory for Flutter Web: `/invite/{token}`, auth callback, nested-route refresh, browser back/forward, direct URL. |
| HTTP | **Dio** | Interceptor model fits our needs directly: idempotency-key injection, auth refresh, retry policy, error normalization, request logging. |
| Models / serialization | **freezed + json_serializable** | Immutable DTOs with unions — a natural fit for `Occurrence` state and `allowed_actions`. Exhaustive `when`/`map` makes unhandled states a compile error. |
| Codegen runner | build_runner | Required by the above. |
| Timezone | **`timezone` package** (IANA database) | Notion 06 §6: use a mature library, never hand-maintain DST tables. |
| Client logging / errors | **Sentry** (Flutter + Dart) | Covers the M0 exit criterion "staging surfaces client crash/error and key API failures" on both Android and Web from one SDK. |
| Testing | flutter_test · mocktail · integration_test · patrol *(optional, later)* | State-transition and integration tests are a Definition-of-Done requirement. |

### Fonts — resolves DESIGN_SYSTEM D-1

**Decision: bundle Lora (display/serif) + Inter (UI/body). Both SIL OFL — free to embed and redistribute.**

- The V5 HTML's `Iowan Old Style / Palatino` stack is **Apple system fonts** — present on this Mac, but not licensable for bundling into an Android APK or a web build. It was a mockup convenience, never a shippable choice.
- **Rovel Display** (Notion 05's first choice) is a commercial font with no obtainable license in hand. If the owner later purchases it, swapping is a single token change in `design_system`.
- Notion 05 explicitly names **Lora** as the placeholder. It is a transitional serif with the warmth and restraint the "Warm Authority" direction calls for, and it is the closest open alternative to the Iowan feel in the mockup.

Installed at `assets/fonts/`: `Lora-Variable.ttf`, `Lora-Italic-Variable.ttf`, `Inter-Variable.ttf`, plus both `OFL-*.txt` license files (redistribution requires shipping the license).

Variable fonts are used so weight is a continuous axis — the design needs Inter at 600/650/700/750, which would otherwise mean four static files.

---

## Decision — Backend

**Recommendation: Kotlin + Spring Boot + PostgreSQL + Flyway + a single in-process worker.**

| Concern | Choice | Rationale |
|---|---|---|
| Language / framework | **Kotlin + Spring Boot 3** | Sealed classes and exhaustive `when` model `Occurrence` / `Dynamic` state machines with compiler-enforced completeness — the single highest-value property for this domain. Null-safety removes a whole defect class. Spring gives transactional boundaries, method-level authorization, scheduling and Flyway integration without assembly. |
| Database | **PostgreSQL 16** | Real transactions for the "operational change + RelationshipEvent + outbox written atomically" requirement. Partial unique indexes give idempotency and single-valid-transition guarantees declaratively. `timestamptz` + full IANA tz support matches the time contract exactly. |
| Migrations | **Flyway** | Versioned, repeatable, rollback-documented. M0 exit criterion requires repeatable migration/rollback/seed. |
| DB access | **jOOQ** *(or Spring Data JDBC)* | Type-safe SQL with visible query shape. Deliberately avoiding JPA/Hibernate: lazy loading and dirty-checking obscure exactly the write paths whose atomicity we must reason about. |
| Worker | **In-process `@Scheduled` + Postgres `SELECT … FOR UPDATE SKIP LOCKED`** | The outbox pattern needs no broker at Core Beta scale. One deployable, one datastore, transactional handoff. Kafka/Rabbit would add operational surface with no correctness gain today. |
| Auth | **Spring Security + stateless JWT access + rotating refresh; magic link as single-use, short-TTL, hashed token** | Notion 04 §2: token locates Invite context only, never grants long-term business access. |
| API contract | **springdoc-openapi → generated Dart client** | M0 exit criterion: contract drift caught in CI; DTOs must not be hand-copied. |
| Server observability | **OpenTelemetry + Sentry** | Correlates client and server on one trace for the reliability incidents Notion 07 §2 item 8 tracks. |
| Testing | JUnit 5 · **Testcontainers** · MockMvc | Testcontainers runs real Postgres in tests — essential, because our concurrency and DST guarantees are database behavior, not application behavior. |

### Why not the alternatives

- **Node/TypeScript** — sharing types with Flutter is not a benefit here (the client is Dart). Weaker transactional and scheduling story; state machines rely on runtime validation instead of the compiler.
- **Go** — excellent operationally, but no sum types. Modelling `Occurrence` states becomes string constants plus hand-written guards — precisely the defect class we most need eliminated.
- **Python/Django** — fastest to scaffold, weakest at compile-time state correctness and concurrency guarantees.
- **Microservices** — explicitly forbidden by Notion 06 §11 at this stage.

**Kotlin wins on the one axis that matters most: the compiler can prove every state transition is handled.**

---

## Consequences

**Positive**
- State machines are compiler-verified on both sides (Kotlin sealed classes ↔ Dart freezed unions).
- One database, one deployable, one worker — matches modular-monolith intent; debuggable by one person.
- Outbox, idempotency and single-transition guarantees are enforced by Postgres constraints, not application discipline.
- OpenAPI-generated Dart client removes DTO drift structurally.
- Fonts are legally shippable on day one.

**Negative / accepted cost**
- JVM cold start and memory exceed Go or Node. Irrelevant at Core Beta scale; revisit only if it becomes real.
- Kotlin + jOOQ + Testcontainers is a heavier local setup than a scripting stack. Mitigated with Docker Compose in M0.
- If Rovel Display is licensed later, a font swap is required (cheap — one token change).

**Reversibility**: the client stack is effectively irreversible mid-Core-Beta (per the freeze). The backend database choice is likewise sticky. Framework choice is moderately reversible while the domain is small — which is now, hence this ADR.

---

## Decisions taken directly (not requiring a separate ADR)

| ID | Decision |
|---|---|
| **D-1** | Bundle **Lora + Inter** (SIL OFL). Rovel Display deferred until licensed. |
| **D-2** | Primary CTA rendered at **48dp**, not the mockup's 42px. Notion 05 states 48–52dp, and 48dp is the Android minimum touch target. Accessibility outranks a mockup pixel value. Full-width CTAs keep radius 7 and 12px/650 type; the extra 6px is absorbed in vertical padding, which does not alter the design's proportions. |
| **D-3** | Greeting renders **neutral** ("Good morning."). The V5 mockup's "Sir" is dynamic-specific content; Core Beta has no honorific setting, and hardcoding an honorific would make the system speak in the Dom's voice — a direct violation of *Automation prepares; the partner responds*. When an honorific setting exists, it becomes user-configured content. |
| **D-4/5/6** | Proposal line, "no proof requested", and the Partner-invitation card are **not implemented** — out of Core Beta scope (Notion wins on scope). |
