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
import kotlin.test.assertFailsWith
import kotlin.test.assertNull

/**
 * Role preset — Notion 03 §2. A starting point, never an identity and never
 * a permission.
 */
@SpringBootTest
@ActiveProfiles("test")
class RolePresetIT {

    @Autowired lateinit var dsl: DSLContext
    @Autowired lateinit var create: CreateDynamicService
    @Autowired lateinit var query: DynamicQueryService

    private lateinit var me: UUID

    @BeforeEach
    fun seed() {
        me = UUID.randomUUID()
        dsl.query(
            "INSERT INTO users (id, email, display_name, timezone) VALUES ({0},{1},{2},{3})",
            me, "$me@test.local", "Alex", "UTC",
        ).execute()
    }

    private fun make(preset: String?) = create.create(
        actorUserId = me,
        mode = "COUPLE",
        desiredOutcome = "CLOSER",
        structureLevel = "LIGHT",
        referenceTimezone = "UTC",
        rolePreset = preset,
    )

    @Test
    fun `a preset is recorded and returned`() {
        val c = make("DOMINANT")
        val m = query.detail(me, c.dynamicId).members.single()
        assertEquals("DOMINANT", m.rolePreset)
        // Position and self-description are separate things.
        assertEquals("CREATOR", m.roleContext)
    }

    @Test
    fun `naming a role is optional and never blocks starting`() {
        // Red line #4: the product must not require this to be answered.
        val c = make(null)
        assertNull(query.detail(me, c.dynamicId).members.single().rolePreset)
    }

    @Test
    fun `all four presets from the spec are accepted`() {
        for (p in listOf("DOMINANT", "SUBMISSIVE", "SWITCH", "CUSTOM")) {
            val c = make(p)
            assertEquals(p, query.detail(me, c.dynamicId).members.single().rolePreset)
        }
    }

    @Test
    fun `an unknown preset is refused rather than stored`() {
        assertFailsWith<IllegalArgumentException> { make("MASTER") }
    }

    @Test
    fun `the preset grants nothing`() {
        // A submissive creator still holds the creator's position, and a
        // dominant preset confers no extra reach. Authorization reads
        // role_context and access_state only.
        val c = make("SUBMISSIVE")
        val ctx = query.detail(me, c.dynamicId)
        assertEquals("CREATOR", ctx.members.single().roleContext)
        assertEquals(
            listOf("discuss", "reschedule", "cant_do", "pause", "leave", "block"),
            ctx.alwaysAvailable,
        )
    }
}
