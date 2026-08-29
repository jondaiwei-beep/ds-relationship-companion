package com.dsapp.backend.shared.idempotency

import org.jooq.DSLContext
import org.jooq.impl.DSL
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.test.context.ActiveProfiles
import java.util.UUID
import java.util.concurrent.Callable
import java.util.concurrent.CyclicBarrier
import java.util.concurrent.Executors
import java.util.concurrent.atomic.AtomicInteger
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith
import kotlin.test.assertTrue

/**
 * Verifies the idempotency contract (Notion 03 §6): a retried command must
 * produce AT MOST ONE valid business action.
 *
 * Runs against the local PostgreSQL 16 on 5433 — no Docker.
 */
@SpringBootTest
@ActiveProfiles("test")
class IdempotencyServiceIT {

    @Autowired lateinit var service: IdempotencyService
    @Autowired lateinit var dsl: DSLContext

    private lateinit var actor: UUID

    @BeforeEach
    fun seedActor() {
        actor = UUID.randomUUID()
        dsl.query(
            "insert into users (id, email) values ({0}, {1})",
            actor, "${actor}@test.local",
        ).execute()
    }

    private fun hash(seed: String): ByteArray =
        java.security.MessageDigest.getInstance("SHA-256").digest(seed.toByteArray())

    @Test
    fun `first call executes and the retry replays without re-running the command`() {
        val runs = AtomicInteger()
        val key = "key-${UUID.randomUUID()}"
        val h = hash("body-A")

        val first = service.executeOnce(actor, key, "complete_occurrence", h) {
            runs.incrementAndGet()
            IdempotencyResponse(200, """{"ok":true}""".toByteArray())
        }
        val second = service.executeOnce(actor, key, "complete_occurrence", h) {
            runs.incrementAndGet()
            IdempotencyResponse(200, """{"ok":true}""".toByteArray())
        }

        assertTrue(first is IdempotencyOutcome.Executed, "first call must execute")
        assertTrue(second is IdempotencyOutcome.Replayed, "retry must replay")
        assertEquals(1, runs.get(), "the command body must run exactly once")
        assertEquals(
            String(first.body), String(second.body),
            "replay must return the original body verbatim",
        )
        assertEquals("true", second.headers[IdempotencyOutcome.REPLAYED_HEADER])
    }

    @Test
    fun `same key with a different request body is rejected as reuse`() {
        val key = "key-${UUID.randomUUID()}"
        service.executeOnce(actor, key, "complete_occurrence", hash("body-A")) {
            IdempotencyResponse(200, "first".toByteArray())
        }

        assertFailsWith<IdempotencyKeyReusedException> {
            service.executeOnce(actor, key, "complete_occurrence", hash("body-DIFFERENT")) {
                IdempotencyResponse(200, "second".toByteArray())
            }
        }
    }

    @Test
    fun `concurrent duplicates run the command only once`() {
        val threads = 8
        val runs = AtomicInteger()
        val key = "key-${UUID.randomUUID()}"
        val h = hash("body-A")
        val barrier = CyclicBarrier(threads)
        val pool = Executors.newFixedThreadPool(threads)

        try {
            // All threads fire the SAME key at the same instant. Arbitration must
            // come from the DB unique index, not application-level locking.
            val results = pool.invokeAll(
                (1..threads).map {
                    Callable {
                        barrier.await()
                        runCatching {
                            service.executeOnce(actor, key, "complete_occurrence", h) {
                                runs.incrementAndGet()
                                Thread.sleep(40)   // widen the race window
                                IdempotencyResponse(200, """{"ok":true}""".toByteArray())
                            }
                        }
                    }
                }
            ).map { it.get() }

            assertEquals(
                1, runs.get(),
                "under $threads concurrent duplicates the command must run exactly once",
            )

            val succeeded = results.filter { it.isSuccess }.map { it.getOrThrow() }
            assertEquals(
                1, succeeded.count { it is IdempotencyOutcome.Executed },
                "exactly one caller may be the executor",
            )
            assertTrue(succeeded.isNotEmpty(), "at least one caller must get a result")
        } finally {
            pool.shutdownNow()
        }
    }

    @Test
    fun `only one idempotency row exists per actor and key`() {
        val key = "key-${UUID.randomUUID()}"
        val h = hash("body-A")
        repeat(3) {
            runCatching {
                service.executeOnce(actor, key, "complete_occurrence", h) {
                    IdempotencyResponse(200, "x".toByteArray())
                }
            }
        }
        val count = dsl.fetchOne(
            "select count(*) from idempotency_keys where actor_user_id = {0} and key_value = {1}",
            actor, key,
        )!!.get(0, Int::class.java)
        assertEquals(1, count)
    }
}
