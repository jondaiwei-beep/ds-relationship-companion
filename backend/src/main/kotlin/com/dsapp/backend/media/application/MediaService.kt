package com.dsapp.backend.media.application

import com.dsapp.backend.dynamic.application.MembershipAuthorizer
import com.dsapp.backend.media.domain.ImageSniffer
import org.jooq.DSLContext
import org.springframework.beans.factory.annotation.Value
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.io.File
import java.nio.file.Files
import java.nio.file.Path
import java.util.UUID

/** The upload was not one of the accepted image formats, once sniffed from its bytes. */
class UnsupportedMediaType : RuntimeException("not a supported image type")

/** The upload exceeded the configured maximum. */
class MediaTooLarge : RuntimeException("file too large")

/** No media row with this id. */
class NoSuchMedia : RuntimeException("no such media")

/** The caller is not an active member of the dynamic that owns this media. */
class MediaAccessDenied : RuntimeException("not a member of this media's dynamic")

/**
 * Photo proof storage (product feature: media upload).
 *
 * Files live on local disk under [mediaDir], named `<uuid>.<ext>`; only the
 * metadata row is queried for authorization and content-type on download.
 * Content type is never trusted from the client — [ImageSniffer] reads the
 * real bytes.
 */
@Service
class MediaService(
    private val dsl: DSLContext,
    private val authorizer: MembershipAuthorizer,
    @Value("\${dsapp.media.dir:./media}") private val mediaDir: String,
    @Value("\${dsapp.media.max-bytes:10485760}") private val maxBytes: Long,
) {
    data class UploadResult(val id: UUID, val url: String)

    private fun dir(): Path {
        val path = Path.of(mediaDir)
        Files.createDirectories(path)
        return path
    }

    @Transactional
    fun upload(actorUserId: UUID, dynamicId: UUID, bytes: ByteArray): UploadResult {
        authorizer.requireActive(authorizer.contextForDynamic(actorUserId, dynamicId))

        if (bytes.size.toLong() > maxBytes) throw MediaTooLarge()
        val kind = ImageSniffer.sniff(bytes) ?: throw UnsupportedMediaType()

        val id = UUID.randomUUID()
        val fileName = "$id.${kind.extension}"
        val target = dir().resolve(fileName)
        Files.write(target, bytes)

        dsl.query(
            """
            INSERT INTO media (id, dynamic_id, uploaded_by, content_type, byte_size)
            VALUES ({0}, {1}, {2}, {3}, {4})
            """.trimIndent(),
            id, dynamicId, actorUserId, kind.contentType, bytes.size.toLong(),
        ).execute()

        return UploadResult(id, "/v1/media/$id")
    }

    data class DownloadResult(val bytes: ByteArray, val contentType: String)

    @Transactional(readOnly = true)
    fun download(actorUserId: UUID, mediaId: UUID): DownloadResult {
        val row = dsl.fetchOne(
            "SELECT dynamic_id, content_type FROM media WHERE id = {0}",
            mediaId,
        ) ?: throw NoSuchMedia()
        val dynamicId = row.get("dynamic_id", UUID::class.java)
        val contentType = row.get("content_type", String::class.java)

        val ctx = authorizer.contextForDynamic(actorUserId, dynamicId)
        if (ctx == null || !ctx.mayRead) throw MediaAccessDenied()

        val extension = contentType.substringAfterLast('/').let { if (it == "jpeg") "jpg" else it }
        val path = dir().resolve("$mediaId.$extension")
        val file = File(path.toUri())
        if (!file.exists()) throw NoSuchMedia()

        return DownloadResult(Files.readAllBytes(path), contentType)
    }
}
