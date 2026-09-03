package com.dsapp.backend.today

import com.dsapp.backend.dynamic.domain.AuthorizationException
import com.dsapp.backend.today.application.ConsequenceLifecycleService
import com.dsapp.backend.today.application.DispositionService
import com.dsapp.backend.today.application.OutcomeService
import com.dsapp.backend.today.application.TaskNotActionable
import com.dsapp.backend.today.application.TaskService
import com.dsapp.backend.today.domain.Disposition
import com.dsapp.backend.today.domain.Outcome
import org.jooq.DSLContext
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.test.context.ActiveProfiles
import java.util.UUID
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith

/**
 * Consequence lifecycle: `issued -> done_by_s -> confirmed` or
 * `issued -> waived` (product/03-domain.md §Consequence). The consequence is
 * only ever created by a D disposing `punished`; this only advances it.
 */
@SpringBootTest
@ActiveProfiles("test")
class ConsequenceLifecycleIT {

    @Autowired lateinit var dsl: DSLContext
    @Autowired lateinit var tasks: TaskService
    @Autowired lateinit var outcomes: OutcomeService
    @Autowired lateinit var dispositions: DispositionService
    @Autowired lateinit var lifecycle: ConsequenceLifecycleService

    private lateinit var d: UUID
    private lateinit var s: UUID
    private lateinit var dyn: UUID

    @BeforeEach
    fun seed() {
        d = UUID.randomUUID(); s = UUID.randomUUID(); dyn = UUID.randomUUID()
        for ((u, n) in listOf(d to "Alex", s to "Jamie")) {
            dsl.query("INSERT INTO users (id,email,display_name) VALUES ({0},{1},{2})", u, "$u@t", n).execute()
        }
        dsl.query(
            """INSERT INTO dynamics (id,mode,desired_outcome,structure_level,state,reference_timezone)
               VALUES ({0},'COUPLE','STRUCTURE','STEADY','ACTIVE','UTC')""", dyn,
        ).execute()
        for ((u, r, side) in listOf(Triple(d, "CREATOR", "D"), Triple(s, "PARTNER", "S"))) {
            dsl.query(
                "INSERT INTO memberships (user_id,dynamic_id,role_context,side,access_state) VALUES ({0},{1},{2},{3},'ACTIVE')",
                u, dyn, r, side,
            ).execute()
        }
    }

    private fun issueConsequence(): UUID {
        val t = tasks.create(d, dyn, TaskService.NewTask(title = "Greeting"))
        val occ = dsl.fetchOne("SELECT id FROM occurrences WHERE task_id={0}", t.id)!!.get("id", UUID::class.java)
        outcomes.set(s, occ, OutcomeService.Change(Outcome.cant_do))
        val r = dispositions.set(
            d, occ,
            DispositionService.Change(Disposition.punished, consequence = DispositionService.NewConsequence(title = "Early bedtime")),
        )
        return r.consequenceId!!
    }

    @Test
    fun `s marks issued done, then D confirms`() {
        val c = issueConsequence()

        val done = lifecycle.done(s, c)
        assertEquals("done_by_s", done.status)

        val confirmed = lifecycle.confirm(d, c)
        assertEquals("confirmed", confirmed.status)
    }

    @Test
    fun `D may waive directly from issued, without waiting for done`() {
        val c = issueConsequence()
        val waived = lifecycle.waive(d, c)
        assertEquals("waived", waived.status)
    }

    @Test
    fun `D may waive after the s already marked it done`() {
        val c = issueConsequence()
        lifecycle.done(s, c)
        val waived = lifecycle.waive(d, c)
        assertEquals("waived", waived.status)
    }

    @Test
    fun `only the s side may mark done`() {
        val c = issueConsequence()
        assertFailsWith<AuthorizationException> { lifecycle.done(d, c) }
    }

    @Test
    fun `only the D side may confirm or waive`() {
        val c = issueConsequence()
        assertFailsWith<AuthorizationException> { lifecycle.confirm(s, c) }
        assertFailsWith<AuthorizationException> { lifecycle.waive(s, c) }
    }

    @Test
    fun `a confirmed consequence cannot be marked done again`() {
        val c = issueConsequence()
        lifecycle.done(s, c)
        lifecycle.confirm(d, c)
        assertFailsWith<TaskNotActionable> { lifecycle.done(s, c) }
    }

    @Test
    fun `listing is visible to both sides and filterable by status`() {
        val c = issueConsequence()
        assertEquals(1, lifecycle.list(d, dyn).size)
        assertEquals(1, lifecycle.list(s, dyn).size)
        assertEquals(1, lifecycle.list(d, dyn, status = "issued").size)
        lifecycle.done(s, c)
        assertEquals(0, lifecycle.list(d, dyn, status = "issued").size)
        assertEquals(1, lifecycle.list(d, dyn, status = "done_by_s").size)
    }
}
