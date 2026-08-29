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

    private fun definition(title: String) {
        dsl.query(
            """
            INSERT INTO expectation_definitions
                (id, dynamic_id, kind, title, creator_user_id,
                 assignee_user_id, visibility, active)
            VALUES ({0},{1},'TASK',{2},{3},{3},'SHARED',true)
            """.trimIndent(),
            UUID.randomUUID(), dyn, title, me,
        ).execute()
    }

    private fun activeCount() = dsl.fetchOne(
        "SELECT count(*) AS n FROM expectation_definitions " +
            "WHERE dynamic_id = {0} AND active",
        dyn,
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
        repeat(4) { definition("thing $it") }
        query.pause(me, dyn)
    }

    @Test
    fun `coming back the same way changes nothing`() {
        query.resume(me, dyn, lighter = false)
        assertEquals("ACTIVE", query.detail(me, dyn).state)
        assertEquals(4, activeCount())
    }

    @Test
    fun `coming back lighter reduces the load`() {
        // Handing someone the same load they paused under is how they leave
        // again. Journey E says the choice is theirs.
        query.resume(me, dyn, lighter = true)
        assertEquals("ACTIVE", query.detail(me, dyn).state)
        assertEquals(2, activeCount())
    }

    @Test
    fun `lighter deactivates, it never deletes`() {
        query.resume(me, dyn, lighter = true)
        val total = dsl.fetchOne(
            "SELECT count(*) AS n FROM expectation_definitions WHERE dynamic_id = {0}",
            dyn,
        )!!.get("n", Int::class.java)
        // Nothing is destroyed — the definitions can be switched back on.
        assertEquals(4, total)
    }

    @Test
    fun `neither choice produces a backlog`() {
        query.resume(me, dyn, lighter = true)
        val overdue = dsl.fetchOne(
            "SELECT count(*) AS n FROM occurrences WHERE dynamic_id = {0}",
            dyn,
        )!!.get("n", Int::class.java)
        // Returning must never mean facing work you "owe" (Journey E).
        assertTrue(overdue == 0, "resume created $overdue occurrences")
    }
}
