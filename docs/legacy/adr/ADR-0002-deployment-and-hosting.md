# ADR-0002 — Deployment, Hosting & the xmatch Reuse Question

**Status**: Accepted
**Date**: 2026-08-27
**Supersedes**: nothing. **Depends on**: ADR-0001 (technology stack).

---

## Context

The product owner asked whether the D/s Companion backend should be built inside the existing **xmatch B-group** project (a mature dating-app backend already running on `204.152.213.47`), and — if a new process is added instead — whether that server has capacity for a **third JVM**, or whether Cloudflare Workers would suffice.

Both questions were answered with measurement, not opinion. Findings below are from direct inspection of `/Users/li/code/xmatch-b` (branch `b-master`) and a live SSH session to the production host on 2026-08-27.

---

## Part 1 — Should we build inside xmatch B-group?

### Measured facts

| Dimension | xmatch B-group actual |
|---|---|
| Spring Boot | **2.0.2.RELEASE** (2018, **EOL — no security patches**) |
| Java | **1.8** |
| Source size | 572 Java files, 333 MB |
| DB migration tooling | **None** — no Flyway, no Liquibase |
| Tests | **5 test files** across 572 sources |
| Existing submodules | 22 (`aibot`, `chat`, `credit`, `kink`, `membership`, `payment`, …) |
| Multi-tenancy | Single database, **shared schema**, filtered by a `tenant_id` column (140 files) |
| `@Transactional` usage | 11 occurrences |
| `@Scheduled` usage | 1 occurrence |
| ORM | MyBatis-Plus |

### Decision: **do not build inside xmatch. Build an independent backend.**

Five reasons, in order of weight:

1. **"Without affecting the existing app" is not achievable in this architecture.** B-group is single-database, shared-schema, `tenant_id`-filtered, running as one JVM (port 8081, `-Xmx512m`) from one jar. Adding our tables means DDL against `sdm_pro_b` — the same database EliteSweet runs on. The project's own `xmatch-ab-group` skill records a **7–8 hour A-group outage on 2026-07-06** caused precisely by DDL/schema drift. Our schema churn would sit inside EliteSweet's blast radius on every migration.

2. **No migration tooling, but M0 mandates it.** Notion `06 §13.2` exit criteria require *"基础 migration / rollback / seed 可重复执行"*. xmatch applies DDL by hand (an entire section of its skill exists to compensate). Introducing Flyway into a 572-file legacy project is its own risk-bearing project; not introducing it fails the M0 gate.

3. **Spring Boot 2.0.2 does not support our core requirements.** Our engineering pressure is state correctness, not throughput. Missing entirely: transactional outbox (11 `@Transactional`, 1 `@Scheduled` — this is not a codebase built for async consistency), idempotent command framework, IANA timezone + local wall-clock + custom day-boundary semantics, and our visibility model (Private / Shared / System-only). All would be built from scratch anyway.

4. **Zero domain overlap.** xmatch `User` is a **permanent identity**; our Role belongs to **Membership** — product red line #4, a direct modelling conflict. xmatch's `credit` / `payment` / `membership` / `aibot` modules are all things Core Beta explicitly excludes (Points / Rewards / Subscription / AI persona). None of `Occurrence`, `Acknowledgement`, `AdjustmentRequest`, `DeliveryIntent` exist. The only reusable piece is the auth/session skeleton — the most standard part of Spring Security, faster and cleaner written fresh.

5. **AI-adjacency is a red-line hazard.** xmatch depends on `chatgpt-java`, `bedrockruntime`, `aws-java-sdk-rekognition`, and ships a `microservice/aibot/` module. Red line #1 is that the system must **never impersonate the Partner or substitute an AI persona for a real person**. Placing our code where an AI bot is one import away creates a trap for a future engineer or agent. Physical isolation is more reliable than discipline.

### What we *do* reuse

Infrastructure, not code: the server, the MySQL/RDS instance (separate database), R2/CDN, the nginx front, and the deploy-script pattern. This preserves the owner's actual goal — fast start on proven infrastructure — without schema coupling, JVM contention, release coupling, EOL framework debt, or AI-module proximity.

---

## Part 2 — Server capacity for a third JVM

### Measured on 2026-08-27 (live production host)

```
Total RAM      7.6 GB          CPU        4 cores
Used           3.7 GB          Load avg   0.17 / 0.18 / 0.15   ← essentially idle
Available      3.3 GB          Disk       40G / 90G (44%)
Swap used      510 MB / 1 GB   Committed_AS  5.0 GB
Uptime         398 days
```

| Process | Configured | RSS | Actual heap |
|---|---|---|---|
| A-group `dating.jar` | `-Xmx2048m` | **2325 MB** | 617 MB used / 1578 MB total |
| B-group `dating-b.jar` | `-Xmx512m` | **679 MB** | 180 MB used / 256 MB total |

Others: redis 183 MB · dockerd 75 MB · BT-Panel 71 MB · node 44 MB · nginx ~120 MB · **mysqld 36 MB**.

### Key finding: the database is not on this host

`mysqld` at 36 MB is not serving production load. Consistent with the `xmatch-db` skill, the real database is **AWS RDS (`database-pro`)**. Therefore a third JVM adds **no database load** to this machine — the "three JVMs plus MySQL competing for RAM" concern does not apply.

### Decision: **yes, a third JVM fits.** Configure `-Xms256m -Xmx512m` (same profile as B-group).

```
Available now      3.3 GB
New process RSS   -0.7 GB   (B-group's measured RSS at identical settings)
──────────────────────────
Headroom           2.6 GB
```

CPU is not a constraint: load 0.17 across 4 cores. Core Beta is an invite-only couples beta with users numbered in the tens; 512 MB heap is generous.

**Two honest caveats (amber, not red):**

- **510 MB of swap is in use.** `vmstat` shows si/so at 0 — no active paging, no present performance impact — but it indicates memory has been tight at some point historically.
- **A-group is over-provisioned**: `-Xmx2048m` with only 617 MB of heap actually in use, holding 2325 MB RSS. Dropping it to `-Xmx1024m` would free roughly 1 GB immediately. **Not doing this** — it is a production change to a live app and warrants its own evaluation. Recorded here so the option is known if pressure appears.

**No change to A-group or B-group is required to proceed.**

---

## Part 3 — Cloudflare Workers?

### Decision: **no for the backend. Yes for the web tier.**

Workers cannot host this backend — an architectural incompatibility, not a capacity question:

| Requirement | Workers constraint |
|---|---|
| Kotlin / JVM | **Unsupported** — JS/WASM only |
| PostgreSQL with real transactions | Only via Hyperdrive proxy; **no long-lived transactional connections** |
| Atomic write of operational change + RelationshipEvent + outbox | **Not achievable** — this is our single most important consistency guarantee (Notion `06 §4`) |
| `SELECT … FOR UPDATE SKIP LOCKED` worker | No resident process; Cron Triggers only |
| Resident background worker | Stateless, request-driven, CPU-time capped |

Adopting Workers would also overturn ADR-0001: abandoning Kotlin forfeits sealed-class compile-time state exhaustiveness, and abandoning Postgres forfeits partial unique indexes as declarative idempotency constraints. That trades away the correctness guarantees this product most needs, in order to save a server that is currently idle.

### Cloudflare is used where it is strong

- **CDN / DNS / TLS** — already in use, unchanged.
- **R2** — static assets, fonts, and future Proof media.
- **Cloudflare Pages → Flutter Web Companion.** The web build is a static artifact. Edge distribution directly improves iPhone Safari first-load and time-to-interactive — an explicit **M1 exit criterion** (Notion `06 §13.3`) and an activation observability metric (`04 §13`). Better suited than serving it from nginx on a single US host.

---

## Part 4 — Server JDK provisioning (verified 2026-08-27)

### The problem

The production host is **CentOS 7** (EOL 2024-06-30) with **only JDK 1.8.0_412** installed.
`yum install java-21` is impossible: the CentOS 7 repositories are retired (now mirrored to
aliyun, which carries no JDK 21).

### Verified solution: Temurin tarball, side-by-side

Measured end-to-end on the live host, not assumed:

| Step | Result |
|---|---|
| `glibc` version (JDK 21 needs ≥ 2.17) | **2.17** — exactly meets the floor |
| Download Temurin 21 from Adoptium | ✅ HTTP 200, 207 MB |
| Extract to `/opt/jdk21`, run `java -version` | ✅ `openjdk 21.0.12.1 LTS` |
| Build our Spring Boot 3 fat jar locally (45 MB) | ✅ |
| Upload and **run our actual app on CentOS 7** | ✅ `Started BackendApplicationKt in 10.096s`, Tomcat bound |
| System `java -version` after install | ✅ still `1.8.0_412` — unchanged |
| `alternatives --list java` after install | ✅ still points at JDK 8 — unchanged |
| xmatch A (8080) / B (8081) health after install | ✅ both HTTP 401 (auth required = healthy) |

This is a genuine application start on the target OS, not a version banner.

### Isolation

```
A-group dating.jar    → system JDK 8   (untouched)
B-group dating-b.jar  → system JDK 8   (untouched)
dsapp.jar             → /opt/jdk21     (independent)
```

`deploy-ds.sh` hardcodes the absolute path `/opt/jdk21/bin/java`. It never modifies
`alternatives`, `JAVA_HOME` system-wide, or `/usr/lib/jvm`. Its process matcher is
`pgrep -f "dsapp\.jar"`, which cannot match `dating.jar` or `dating-b.jar`.

### `deploy-ds.sh`

Modelled on `deploy-b.sh`, adding **automatic rollback** (restore previous jar and restart
if the new build fails to start or times out) — `deploy-b.sh` has no rollback path.
Guards: JDK presence, env-file presence, branch verification (refuses to build anything
but the intended branch), and post-swap md5 verification.

### Accepted risk — CentOS 7 EOL

The OS has had no security patches since 2024-06-30. Kernel, glibc and openssl are frozen.
**This is pre-existing and shared by the two live xmatch apps; our deployment does not change
the risk level.** JDK 21 we can update ourselves (swap the tarball); the OS cannot be upgraded
in place. Migrating the host is a larger decision than this project.

---

## Final topology

```
Backend API      204.152.213.47:8082    independent JVM, -Xms256m -Xmx512m, /opt/jdk21
Database         AWS RDS (same instance) new database `dsapp` — NOT in sdm_pro_b
Flutter Web      Cloudflare Pages        static, edge-distributed
CDN / DNS / R2   Cloudflare              unchanged
Repository       /Users/li/code/app/dsapp   independent
Deploy           ~/deploy-ds.sh          modelled on deploy-b.sh
```

## Consequences

**Positive**
- EliteSweet and A-group are unaffected: separate schema, separate JVM, separate release cycle.
- Fast start — server, RDS, CDN, deploy pattern, and nginx front all already exist.
- ADR-0001's correctness guarantees (Kotlin sealed classes, Postgres constraints, real transactions) are preserved intact.
- iPhone web performance improves via edge distribution, addressing an M1 exit criterion directly.

**Negative / accepted**
- A second technology stack (Kotlin/Spring Boot 3) to operate alongside the existing Java 8 estate. Accepted: state correctness is this product's dominant risk, and the stacks are fully isolated.
- Server headroom drops to ~2.6 GB. Sufficient now; a fourth process or real user growth would require reducing A-group's `-Xmx` or adding RAM.
- Swap at 510 MB should be watched after the third process starts.

**Operational note — nginx.** Adding the `:8082` server block must follow the `xmatch-ab-group` rule learned from the **2026-08-14 incident** (a blanket `return 301` downgraded App `POST /api/login` to `GET`, dropping the body and causing a 2-hour login outage). API paths are exempted **before** any redirect rule, and `nginx_redirect_gate.py` is run both `check` (pre-change) and `probe` (post-change), requiring `num_redirects == 0` on `POST`.

---

## Decisions taken

| ID | Decision |
|---|---|
| **H-1** | Independent backend. Do **not** build inside xmatch B-group. |
| **H-2** | Reuse infrastructure: server, RDS instance (separate database), R2/CDN, nginx, deploy pattern. |
| **H-3** | Third JVM on `204.152.213.47:8082`, `-Xms256m -Xmx512m`. No change to A/B-group JVMs. |
| **H-4** | Cloudflare Workers rejected for backend; **Cloudflare Pages adopted** for Flutter Web. |
| **H-5** | A-group `-Xmx` reduction identified as available headroom but **deliberately not performed**. |
| **H-6** | JDK 21 installed as a **Temurin tarball at `/opt/jdk21`**, side-by-side with system JDK 8. Verified: our Spring Boot 3 app starts on CentOS 7; xmatch A/B unaffected. |
| **H-7** | `deploy-ds.sh` hardcodes `/opt/jdk21/bin/java` and adds automatic rollback. Never mutates system JDK state. |
