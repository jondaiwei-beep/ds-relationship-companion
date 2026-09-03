package com.dsapp.backend.media.api

import com.dsapp.backend.media.application.MediaService
import com.dsapp.backend.shared.api.actorId
import org.springframework.http.CacheControl
import org.springframework.http.HttpHeaders
import org.springframework.http.MediaType
import org.springframework.http.ResponseEntity
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController
import org.springframework.web.multipart.MultipartFile
import java.util.UUID

data class UploadMediaResponse(val id: UUID, val url: String)

@RestController
@RequestMapping("/v1")
class MediaController(private val media: MediaService) {

    /** Photo proof upload. Field name `file`, image only (content-sniffed), 10 MB max. */
    @PostMapping("/dynamics/{dynamicId}/media")
    fun upload(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
        @RequestParam("file") file: MultipartFile,
    ): ResponseEntity<Any> {
        val result = media.upload(jwt.actorId(), dynamicId, file.bytes)
        return ResponseEntity.status(201)
            .cacheControl(CacheControl.noStore())
            .body(UploadMediaResponse(result.id, result.url))
    }

    @GetMapping("/media/{mediaId}")
    fun download(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable mediaId: UUID,
    ): ResponseEntity<ByteArray> {
        val result = media.download(jwt.actorId(), mediaId)
        return ResponseEntity.ok()
            .header(HttpHeaders.CACHE_CONTROL, "private")
            .contentType(MediaType.parseMediaType(result.contentType))
            .body(result.bytes)
    }
}
