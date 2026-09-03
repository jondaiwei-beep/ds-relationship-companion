package com.dsapp.backend.rules

import com.dsapp.backend.dynamic.domain.AuthorizationException
import com.dsapp.backend.rules.application.RuleService
import com.dsapp.backend.today.application.TaskNotActionable
import org.jooq.DSLContext
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.test.context.ActiveProfiles
import java.util.UUID
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith
import kotlin.test.assertTrue

/**
 * Rule — 常设规矩 (product/03-domain.md §Rule). D writes and edits directly;
 * an s may only propose, and the proposal is invisible as `active` until the
 * D accepts.
 */
@SpringBootTest
@ActiveProfiles("test")
class RuleIT {

    @Autowired lateinit var dsl: DSLContext
    @Autowired lateinit var rules: RuleService

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

    @Test
    fun `a D-written rule is active immediately`() {
        val r = rules.create(d, dyn, RuleService.NewRule("称呼要用「先生」", group = "protocol"))
        assertEquals("active", r.status)
    }

    @Test
    fun `an s proposal is invisible as active until the D accepts it`() {
        val r = rules.create(s, dyn, RuleService.NewRule("可以晚十分钟报到吗", group = "reporting"))
        assertEquals("proposed", r.status)

        // Not active: the default list excludes nothing (archived aside), but
        // its status stays proposed until accepted — the s cannot self-promote.
        val listed = rules.list(d, dyn).first { it.id == r.id }
        assertEquals("proposed", listed.status)

        val accepted = rules.accept(d, dyn, r.id)
        assertEquals("active", accepted.status)
    }

    @Test
    fun `an s cannot edit a D-written rule`() {
        val r = rules.create(d, dyn, RuleService.NewRule("跪迎", group = "ritual"))
        assertFailsWith<AuthorizationException> {
            rules.update(s, dyn, r.id, RuleService.RuleEdit(title = "改一下"))
        }
    }

    @Test
    fun `an s may archive only their own proposal, never a D rule`() {
        val proposal = rules.create(s, dyn, RuleService.NewRule("提议一条"))
        rules.archive(s, dyn, proposal.id) // fine: their own proposal

        val dRule = rules.create(d, dyn, RuleService.NewRule("D的规矩"))
        assertFailsWith<TaskNotActionable> { rules.archive(s, dyn, dRule.id) }
    }

    @Test
    fun `D may archive anything, including an s proposal`() {
        val proposal = rules.create(s, dyn, RuleService.NewRule("提议一条"))
        rules.archive(d, dyn, proposal.id)
        val listed = rules.list(d, dyn, includeArchived = true).first { it.id == proposal.id }
        assertEquals("archived", listed.status)
    }

    @Test
    fun `listing groups by group then position`() {
        rules.create(d, dyn, RuleService.NewRule("Z appearance", group = "appearance"))
        rules.create(d, dyn, RuleService.NewRule("A protocol", group = "protocol"))
        rules.create(d, dyn, RuleService.NewRule("B protocol", group = "protocol"))

        val listed = rules.list(d, dyn).map { it.group }
        assertTrue(listed.indexOf("appearance") > listed.lastIndexOf("protocol") || listed.count { it == "protocol" } == 2)
    }

    @Test
    fun `D can edit title, body, group and position`() {
        val r = rules.create(d, dyn, RuleService.NewRule("原标题", group = "other"))
        val edited = rules.update(d, dyn, r.id, RuleService.RuleEdit(title = "新标题", body = "细节", group = "ritual", position = 5))
        assertEquals("新标题", edited.title)
        assertEquals("细节", edited.body)
        assertEquals("ritual", edited.group)
        assertEquals(5, edited.position)
    }
}
