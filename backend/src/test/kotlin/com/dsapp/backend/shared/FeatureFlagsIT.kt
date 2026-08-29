package com.dsapp.backend.shared

import com.dsapp.backend.shared.config.FeatureFlags
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.test.context.ActiveProfiles
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status
import kotlin.test.assertFalse

/** The Core Beta kill switches — Notion 06 §9. */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class FeatureFlagsIT {

    @Autowired lateinit var mvc: MockMvc
    @Autowired lateinit var flags: FeatureFlags

    @Test
    fun `Web Push is off unless someone turns it on`() {
        // Notion 04 §6 permits feature-flagging it in Core Beta; the stable
        // fallback is the invite/magic-link email.
        assertFalse(flags.webPush)
    }

    @Test
    fun `the client can read the switches without a session`() {
        // Throwing a switch has to take effect without shipping an app
        // build, which means the client reads it rather than deciding.
        mvc.perform(get("/v1/features"))
            .andExpect(status().isOk)
            .andExpect(jsonPath("$.webPush").exists())
            .andExpect(jsonPath("$.weeklyReflection").exists())
            .andExpect(jsonPath("$.explorePlaceholder").exists())
    }

    @Test
    fun `no safety control is behind a switch`() {
        // A kill switch that can disable Leave, Block, privacy defaults or
        // authorization is itself a safety defect (Notion 06 §9). Assert on
        // the actual field set so adding one is a failing test, not a
        // review comment somebody has to notice.
        val names = FeatureFlags::class.java.declaredFields
            .map { it.name.lowercase() }
        for (forbidden in listOf(
            "leave", "block", "privacy", "auth", "visibility", "consent",
            "safety", "report", "quiet",
        )) {
            assert(names.none { it.contains(forbidden) }) {
                "safety and access revocation must never be flag-controlled, " +
                    "found a flag matching '$forbidden' in $names"
            }
        }
    }

    @Test
    fun `the flag list stays short`() {
        // A general flag framework is on the do-not-build-early list
        // (Notion 06 §11). Every flag is a branch to reason about forever.
        val count = FeatureFlags::class.java.declaredFields
            .count { !it.isSynthetic }
        assert(count <= 6) { "flag list is growing into a framework: $count" }
    }
}
