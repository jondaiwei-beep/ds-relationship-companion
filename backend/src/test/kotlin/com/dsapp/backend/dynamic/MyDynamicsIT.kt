package com.dsapp.backend.dynamic

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

/**
 * Which dynamics am I in? Without this the client cannot route anywhere
 * after sign-in, because every other screen is addressed by `:id`.
 */
@SpringBootTest
@ActiveProfiles("test")
class MyDynamicsIT {

    @Autowired lateinit var dsl: DSLContext
    @Autowired lateinit var dynamics: DynamicQueryService

    private lateinit var alex: UUID
    private lateinit var jamie: UUID
    private lateinit var stranger: UUID
    private lateinit var dynamicId: UUID

    private fun user(name: String): UUID {
        val id = UUID.randomUUID()
        dsl.query(
            "INSERT INTO users (id, email, display_name, timezone) VALUES ({0},{1},{2},{3})",
            id, "$id@test.local", name, "UTC",
        ).execute()
        return id
    }

    private fun member(d: UUID, u: UUID, role: String, access: String = "ACTIVE") =
        dsl.query(
            """
            INSERT INTO memberships (id, dynamic_id, user_id, role_context, access_state)
            VALUES ({0},{1},{2},{3},{4})
            """.trimIndent(),
            UUID.randomUUID(), d, u, role, access,
        ).execute()

    @BeforeEach
    fun seed() {
        alex = user("Alex")
        jamie = user("Jamie")
        stranger = user("Sam")
        dynamicId = UUID.randomUUID()
        dsl.query(
            """
            INSERT INTO dynamics (id, mode, desired_outcome, structure_level,
                                  reference_timezone, state)
            VALUES ({0},'COUPLE','CLOSER','LIGHT','UTC','ACTIVE')
            """.trimIndent(),
            dynamicId,
        ).execute()
        member(dynamicId, alex, "CREATOR")
        member(dynamicId, jamie, "PARTNER")
    }

    @Test
    fun `a member finds their dynamic and is told who is in it`() {
        val mine = dynamics.forUser(alex)
        assertEquals(1, mine.size)
        assertEquals(dynamicId, mine[0].dynamicId)
        assertEquals("CREATOR", mine[0].roleContext)
        // Named, so a chooser shows a person rather than a UUID.
        assertEquals("Jamie", mine[0].partnerDisplayName)
    }

    @Test
    fun `role is answered per dynamic, not carried by the person`() {
        // Notion 03 §1: role belongs to Membership. The same user is CREATOR
        // here and PARTNER in another dynamic.
        val other = UUID.randomUUID()
        dsl.query(
            """
            INSERT INTO dynamics (id, mode, desired_outcome, structure_level,
                                  reference_timezone, state)
            VALUES ({0},'COUPLE','CLOSER','LIGHT','UTC','ACTIVE')
            """.trimIndent(),
            other,
        ).execute()
        member(other, stranger, "CREATOR")
        member(other, alex, "PARTNER")

        val mine = dynamics.forUser(alex).associateBy { it.dynamicId }
        assertEquals("CREATOR", mine[dynamicId]!!.roleContext)
        assertEquals("PARTNER", mine[other]!!.roleContext)
    }

    @Test
    fun `someone who was never a member sees nothing`() {
        assertTrue(dynamics.forUser(stranger).isEmpty())
    }

    @Test
    fun `a dynamic you left is not somewhere you can go back to`() {
        dsl.query(
            "UPDATE memberships SET access_state = 'LEFT' WHERE user_id = {0}",
            jamie,
        ).execute()
        assertTrue(dynamics.forUser(jamie).isEmpty())
        // And the person who stayed no longer sees them as a partner.
        assertEquals(null, dynamics.forUser(alex)[0].partnerDisplayName)
    }

    @Test
    fun `a paused dynamic is still yours`() {
        // Pause stops future generation; it does not remove the relationship.
        dsl.query("UPDATE dynamics SET state = 'PAUSED' WHERE id = {0}", dynamicId)
            .execute()
        val mine = dynamics.forUser(alex)
        assertEquals(1, mine.size)
        assertEquals("PAUSED", mine[0].state)
    }
}
