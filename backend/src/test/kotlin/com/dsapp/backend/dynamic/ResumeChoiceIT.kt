package com.dsapp.backend.dynamic

import com.dsapp.backend.dynamic.application.CreateDynamicService
import com.dsapp.backend.dynamic.application.DynamicQueryService
import org.jooq.DSLContext
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.test.context.ActiveProfiles
import java.util.UUID
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/** Coming back — Journey E (Notion 02 §6). */
@SpringBootTest
@ActiveProfiles("test")
class ResumeChoiceIT {

    @Autowired lateinit var dsl: DSLContext
    @Autowired lateinit var create: CreateDynamicService
    @Autowired lateinit var query: DynamicQueryService

    private lateinit var me: UUID
    private lateinit var dyn: UUID

    private fun task(title: String) {
        dsl.query(
            """
            INSERT INTO tasks (id, dynamic_id, title, kind, schedule, created_by)
            VALUES ({0},{1},{2},'recurring','{"type":"daily"}'::jsonb,{3})
            """.trimIndent(),
            UUID.randomUUID(), dyn, title, me,
        ).execute()
    }

    private fun activeCount() = dsl.fetchOne(
        "SELECT count(*) AS n FROM tasks WHERE dynamic_id = {0} AND status = 'active'", dyn,
    )!!.get("n", Int::class.java)

    @BeforeEach
    fun seed() {
        me = UUID.randomUUID()
        dsl.query(
            "INSERT INTO users (id, email, display_name, timezone) VALUES ({0},{1},{2},{3})",
            me, "$me@test.local", "Alex", "UTC",
        ).execute()
        dyn = create.create(
            actorUserId = me, mode = "SOLO", desiredOutcome = "CLOSER",
            structureLevel = "LIGHT", referenceTimezone = "UTC",
        ).dynamicId
        repeat(4) { task("thing $it") }
        query.pause(me, dyn)
    }

    @Test
    fun `coming back changes nothing about the rules`() {
        query.resume(me, dyn)
        assertEquals("ACTIVE", query.detail(me, dyn).state)
        assertEquals(4, activeCount())
    }

    @Test
    fun `resume produces no backlog`() {
        query.resume(me, dyn)
        val overdue = dsl.fetchOne(
            "SELECT count(*) AS n FROM occurrences WHERE dynamic_id = {0}",
            dyn,
        )!!.get("n", Int::class.java)
        // Paused = no debt (invariant 9). Nothing was generated while paused
        // and resuming does not reach back for it.
        assertTrue(overdue == 0, "resume created $overdue occurrences")
    }
}
