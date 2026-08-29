package com.dsapp.backend.identity

import com.dsapp.backend.identity.api.StagingLinkController
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.context.ApplicationContext
import org.springframework.test.context.ActiveProfiles
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status
import kotlin.test.assertTrue

/**
 * The staging link endpoint is a full authentication bypass for any address
 * it is asked about. An annotation alone is not evidence — assert that the
 * bean genuinely does not exist when `staging` is not active.
 */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class StagingLinkAbsentIT {

    @Autowired lateinit var ctx: ApplicationContext
    @Autowired lateinit var mvc: MockMvc

    @Test
    fun `the staging link endpoint does not exist outside the staging profile`() {
        val beans = ctx.getBeanNamesForType(StagingLinkController::class.java)
        assertTrue(
            beans.isEmpty(),
            "StagingLinkController must not be registered without the staging " +
                "profile — it returns a credential for any address. Found: " +
                beans.joinToString(),
        )
    }

    @Test
    fun `the staging path is not reachable anonymously outside staging`() {
        // The bean being absent is not on its own proof that the URL is shut:
        // the security rule that permits it must also be profile-gated.
        mvc.perform(get("/v1/staging/last-magic-link?email=a@b.test"))
            .andExpect(status().isUnauthorized)
    }
}
