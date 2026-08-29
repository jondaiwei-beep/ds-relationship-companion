# dsapp backend

Kotlin · Spring Boot 3.5 · PostgreSQL 16 · Flyway · jOOQ · Gradle (see `docs/adr/ADR-0001`).
Modular monolith. Port **8082** (8080 = xmatch A-group, 8081 = B-group — see `docs/adr/ADR-0002`).

## Prerequisites

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@21     # Java 21 required
export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"
```

Local Postgres 16 runs on **5433** (5432 is occupied by a pre-existing Postgres 14):

```bash
PG16DATA=<scratch>/pg16data
pg_ctl -D "$PG16DATA" -o "-p 5433 -k /tmp" start
createdb -p 5433 -U postgres dsapp
```

## Run

```bash
./gradlew bootRun          # Flyway migrates on startup
curl localhost:8082/actuator/health
```

## Tests

**No Docker / Testcontainers.** Tests run against the local PostgreSQL 16 on **5433**:

```bash
createdb -p 5433 -U postgres dsapp_it     # once
./gradlew test
```

Override with `TEST_DB_URL` / `TEST_DB_USER` / `TEST_DB_PASSWORD` if needed.

`IdempotencyServiceIT` proves the Notion 03 §6 contract — a retried command yields
**at most one** business action — including an 8-thread concurrent-duplicate race
arbitrated by the database unique index rather than application locking.

## Verify the schema contracts

`verify_schema.sh` applies `V1__foundation.sql` to a scratch database and asserts that
**6 invalid writes are rejected**. It fails loudly if any constraint stops enforcing:

```bash
./backend/verify_schema.sh
```

| # | Rule enforced | Mechanism |
|---|---|---|
| 1–2 | `relationship_events` is append-only (UPDATE and DELETE both blocked) | `BEFORE UPDATE OR DELETE` trigger |
| 3 | One active membership per (user, dynamic) | partial unique index |
| 4 | One pending invite per dynamic | partial unique index |
| 5 | Outbox `dedupe_key` unique — retry never double-sends | unique constraint |
| 6 | An open `NEED_TO_DISCUSS` still blocks a duplicate occurrence | partial unique index |

## Module boundaries

`identity` · `dynamic` · `expectation` · `response` · `timeline` · `delivery` · `analytics` · `shared`

Each has `api / application / domain / infrastructure`. Do not expose jOOQ records across
module boundaries — cross via small APIs and typed IDs.
