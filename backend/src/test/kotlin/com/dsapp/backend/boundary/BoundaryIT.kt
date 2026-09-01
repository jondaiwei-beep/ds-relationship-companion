package com.dsapp.backend.boundary

import com.dsapp.backend.boundary.application.BoundaryService
import com.dsapp.backend.boundary.application.NoSuchBoundary
import com.dsapp.backend.boundary.application.NotTheAuthor
import com.dsapp.backend.dynamic.domain.AuthorizationException
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
 * Boundaries lite — REQ-ACT-002.
 *
 * The rule these defend is red line #4: agency no role can remove. A limit is
 * only worth writing down if the other person cannot edit it, so that is
 * tested first and from the direction that would do the damage — the member
 * giving direction reaching for the limits of the member receiving it.
 */
@SpringBootTest
@ActiveProfiles("test")
class BoundaryIT {

    @Autowired lateinit var dsl: DSLContext
    @Autowired lateinit var boundaries: BoundaryService

    private lateinit var dom: UUID
    private lateinit var sub: UUID
    private lateinit var outsider: UUID
    private lateinit var dynamicId: UUID

    @BeforeEach
    fun seed() {
        dom = UUID.randomUUID(); sub = UUID.randomUUID(); outsider = UUID.randomUUID()
        dynamicId = UUID.randomUUID()

        for ((u, n) in listOf(dom to "Alex", sub to "Jamie", outsider to "Sam")) {
            dsl.query("INSERT INTO users (id,email,display_name) VALUES ({0},{1},{2})",
                u, "$u@t", n).execute()
        }
        dsl.query(
            """INSERT INTO dynamics (id,mode,desired_outcome,structure_level,state,reference_timezone)
               VALUES ({0},'COUPLE','STRUCTURE','STEADY','ACTIVE','America/New_York')""", dynamicId,
        ).execute()
        for ((u, r) in listOf(dom to "CREATOR", sub to "PARTNER")) {
            dsl.query(
                "INSERT INTO memberships (user_id,dynamic_id,role_context,access_state) VALUES ({0},{1},{2},'ACTIVE')",
                u, dynamicId, r,
            ).execute()
        }
    }

    @Test
    fun `the person giving direction cannot delete the other's limit`() {
        val id = boundaries.add(sub, dynamicId, "Anything in front of other people",
            BoundaryService.Stance.OFF, null)

        assertFailsWith<NotTheAuthor> { boundaries.remove(dom, dynamicId, id) }

        // Still there, and unchanged.
        assertEquals(1, boundaries.list(sub, dynamicId).count { it.id == id })
    }

    @Test
    fun `writing the same label as the partner creates a separate entry, not an overwrite`() {
        // Both name "rope". They are two people's positions on one subject and
        // must not collapse into one row, or the second writer silently edits
        // the first.
        val a = boundaries.add(sub, dynamicId, "Rope", BoundaryService.Stance.OFF, null)
        val b = boundaries.add(dom, dynamicId, "Rope", BoundaryService.Stance.CURIOUS, null)

        assertTrue(a != b)
        val all = boundaries.list(sub, dynamicId)
        assertEquals(2, all.count { it.label.equals("Rope", ignoreCase = true) })
        assertEquals(BoundaryService.Stance.OFF, all.first { it.id == a }.stance)
        assertEquals(BoundaryService.Stance.CURIOUS, all.first { it.id == b }.stance)
    }

    @Test
    fun `both members read both lists`() {
        boundaries.add(sub, dynamicId, "Being filmed", BoundaryService.Stance.OFF, null)
        boundaries.add(dom, dynamicId, "Early mornings", BoundaryService.Stance.ASK, null)

        assertEquals(2, boundaries.list(dom, dynamicId).size)
        assertEquals(2, boundaries.list(sub, dynamicId).size)
    }

    @Test
    fun `mine is answered from the viewer, not from the row`() {
        val subs = boundaries.add(sub, dynamicId, "Being filmed", BoundaryService.Stance.OFF, null)

        assertTrue(boundaries.list(sub, dynamicId).first { it.id == subs }.mine)
        assertTrue(!boundaries.list(dom, dynamicId).first { it.id == subs }.mine)
    }

    @Test
    fun `changing your mind updates in place rather than piling up duplicates`() {
        val first = boundaries.add(sub, dynamicId, "Rope", BoundaryService.Stance.OFF, null)
        val again = boundaries.add(sub, dynamicId, "rope", BoundaryService.Stance.CURIOUS,
            "Talked about it")

        assertEquals(first, again, "same person, same subject — one entry")
        val row = boundaries.list(sub, dynamicId).first { it.id == first }
        assertEquals(BoundaryService.Stance.CURIOUS, row.stance)
        assertEquals("Talked about it", row.note)
    }

    @Test
    fun `withdrawing a limit removes it rather than leaving a record`() {
        val id = boundaries.add(sub, dynamicId, "Rope", BoundaryService.Stance.OFF, null)
        boundaries.remove(sub, dynamicId, id)

        assertTrue(boundaries.list(dom, dynamicId).none { it.id == id })
    }

    @Test
    fun `a non-member sees nothing and can write nothing`() {
        boundaries.add(sub, dynamicId, "Being filmed", BoundaryService.Stance.OFF, null)

        assertFailsWith<AuthorizationException.NotAMember> { boundaries.list(outsider, dynamicId) }
        assertFailsWith<AuthorizationException.NotAMember> {
            boundaries.add(outsider, dynamicId, "x", BoundaryService.Stance.OFF, null)
        }
    }

    @Test
    fun `an unknown id is not found rather than a server error`() {
        assertFailsWith<NoSuchBoundary> {
            boundaries.remove(sub, dynamicId, UUID.randomUUID())
        }
    }

    @Test
    fun `the firmest limits are listed first, and the viewer's own before the partner's`() {
        boundaries.add(dom, dynamicId, "Dom curious", BoundaryService.Stance.CURIOUS, null)
        boundaries.add(sub, dynamicId, "Sub curious", BoundaryService.Stance.CURIOUS, null)
        boundaries.add(sub, dynamicId, "Sub off", BoundaryService.Stance.OFF, null)

        val seen = boundaries.list(sub, dynamicId)
        assertEquals("Sub off", seen[0].label)
        assertEquals("Sub curious", seen[1].label)
        assertEquals("Dom curious", seen[2].label)
    }

    @Test
    fun `a blank label is refused`() {
        assertFailsWith<IllegalArgumentException> {
            boundaries.add(sub, dynamicId, "   ", BoundaryService.Stance.OFF, null)
        }
    }
}
