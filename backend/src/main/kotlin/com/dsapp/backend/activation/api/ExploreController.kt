package com.dsapp.backend.activation.api

import com.dsapp.backend.activation.domain.ExploreLibrary
import org.springframework.http.CacheControl
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import java.time.Duration

/**
 * The small reviewed library a person can browse before anyone else exists.
 *
 * Readable by any signed-in member and identical for everyone: it is
 * editorial content, not relationship data, so it carries nothing private
 * and no per-user state.
 */
@RestController
@RequestMapping("/v1/explore")
class ExploreController {

    @GetMapping
    fun library(): ResponseEntity<Map<String, Any>> = ResponseEntity.ok()
        // Static content — let clients hold it rather than refetching.
        .cacheControl(CacheControl.maxAge(Duration.ofHours(6)).cachePublic())
        .body(
            mapOf(
                "collections" to ExploreLibrary.collections.map {
                    mapOf("id" to it.id, "title" to it.title, "blurb" to it.blurb)
                },
                "ideas" to ExploreLibrary.ideas.map {
                    mapOf(
                        "id" to it.id,
                        "kind" to it.kind.name,
                        "title" to it.title,
                        "purpose" to it.purpose,
                        "detail" to it.detail,
                        "collectionId" to it.collectionId,
                    )
                },
            ),
        )
}
