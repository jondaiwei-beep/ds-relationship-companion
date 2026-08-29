package com.dsapp.backend.expectation

import com.dsapp.backend.expectation.application.CreateExpectationService
import org.jooq.DSLContext
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.test.context.ActiveProfiles
import java.time.Instant
import java.time.LocalDate
import java.util.UUID
import kotlin.test.assertEquals

/**
 * The persisted relationship_day must come from the DYNAMIC's timezone and day
 * boundary — never from the database server's date.
 *
 * Notion 07 §9 classes a wrong relationship day as an S1 release blocker.
 */
@SpringBootTest
@ActiveProfiles("test")
class RelationshipDayPersistenceIT {

    @Autowired lateinit var dsl: DSLContext
    @Autowired lateinit var createExpectation: CreateExpectationService

    private fun dynamic(zone: String, boundaryMinutes: Int): Pair<UUID, UUID> {
        val creator = UUID.randomUUID()
        val partner = UUID.randomUUID()
        val dyn = UUID.randomUUID()
        dsl.query("INSERT INTO users (id,email,display_name) VALUES ({0},{1},'Alex')", creator, "$creator@t").execute()
        dsl.query("INSERT INTO users (id,email,display_name) VALUES ({0},{1},'Jamie')", partner, "$partner@t").execute()
        dsl.query(
            """INSERT INTO dynamics (id,mode,desired_outcome,structure_level,state,
                                     reference_timezone,day_boundary_minutes)
               VALUES ({0},'COUPLE','CLOSER','LIGHT','ACTIVE',{1},{2})""",
            dyn, zone, boundaryMinutes,
        ).execute()
        dsl.query(
            "INSERT INTO memberships (user_id,dynamic_id,role_context,access_state) VALUES ({0},{1},'CREATOR','ACTIVE')",
            creator, dyn,
        ).execute()
        dsl.query(
            "INSERT INTO memberships (user_id,dynamic_id,role_context,access_state) VALUES ({0},{1},'PARTNER','ACTIVE')",
            partner, dyn,
        ).execute()
        return creator to dyn
    }

    private fun dayOf(occurrenceId: UUID): LocalDate =
        dsl.fetchOne("SELECT relationship_day FROM occurrences WHERE id = {0}", occurrenceId)!!
            .get("relationship_day", LocalDate::class.java)

    @Test
    fun `2am with a 4am boundary is stored as the PREVIOUS relationship day`() {
        val (creator, dyn) = dynamic("Asia/Shanghai", 240)
        // 2026-03-04 02:00 Shanghai == 2026-03-03 18:00Z
        val at2amLocal = Instant.parse("2026-03-03T18:00:00Z")

        val created = createExpectation.create(
            creator, dyn, "Late night task", null, creator, at2amLocal,
        )

        assertEquals(
            LocalDate.of(2026, 3, 3), dayOf(created.occurrenceId),
            "02:00 local is still the previous relationship day when the boundary is 04:00",
        )
    }

    @Test
    fun `the same instant lands on DIFFERENT days for differently configured dynamics`() {
        // 2026-03-04 02:00 Shanghai.
        val instant = Instant.parse("2026-03-03T18:00:00Z")

        val (c1, d1) = dynamic("Asia/Shanghai", 240)   // 04:00 boundary
        val (c2, d2) = dynamic("Asia/Shanghai", 0)     // midnight boundary

        val a = createExpectation.create(c1, d1, "x", null, c1, instant)
        val b = createExpectation.create(c2, d2, "x", null, c2, instant)

        assertEquals(LocalDate.of(2026, 3, 3), dayOf(a.occurrenceId))
        assertEquals(LocalDate.of(2026, 3, 4), dayOf(b.occurrenceId))
        // Proof the value is NOT the database server's CURRENT_DATE: one
        // instant produced two different stored days.
    }

    @Test
    fun `timezone matters - the same instant is a different day in different zones`() {
        // 2026-03-04 09:00 Tokyo == 2026-03-03 19:00 New York.
        val instant = Instant.parse("2026-03-04T00:00:00Z")

        val (c1, d1) = dynamic("Asia/Tokyo", 0)
        val (c2, d2) = dynamic("America/New_York", 0)

        assertEquals(LocalDate.of(2026, 3, 4), dayOf(createExpectation.create(c1, d1, "x", null, c1, instant).occurrenceId))
        assertEquals(LocalDate.of(2026, 3, 3), dayOf(createExpectation.create(c2, d2, "x", null, c2, instant).occurrenceId))
    }
}
