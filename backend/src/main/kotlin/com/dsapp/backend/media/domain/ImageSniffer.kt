package com.dsapp.backend.media.domain

/**
 * Detects an image's real type from its bytes — never from the filename or
 * the client-supplied Content-Type, both of which are trivially spoofable.
 *
 * Only the four formats Core Beta accepts as photo proof are recognised;
 * everything else (including other image formats) is rejected.
 */
object ImageSniffer {

    enum class Kind(val contentType: String, val extension: String) {
        JPEG("image/jpeg", "jpg"),
        PNG("image/png", "png"),
        HEIC("image/heic", "heic"),
        WEBP("image/webp", "webp"),
    }

    /** Returns the detected kind, or null when the bytes are not one of the accepted image formats. */
    fun sniff(bytes: ByteArray): Kind? {
        if (isJpeg(bytes)) return Kind.JPEG
        if (isPng(bytes)) return Kind.PNG
        if (isHeic(bytes)) return Kind.HEIC
        if (isWebp(bytes)) return Kind.WEBP
        return null
    }

    private fun isJpeg(b: ByteArray): Boolean =
        b.size >= 3 && b[0] == 0xFF.toByte() && b[1] == 0xD8.toByte() && b[2] == 0xFF.toByte()

    private fun isPng(b: ByteArray): Boolean {
        val sig = byteArrayOf(0x89.toByte(), 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A)
        return b.size >= sig.size && sig.indices.all { b[it] == sig[it] }
    }

    /** ISO base media file format: bytes 4-7 are "ftyp", followed by a HEIC-family brand. */
    private fun isHeic(b: ByteArray): Boolean {
        if (b.size < 12) return false
        if (!(b[4] == 'f'.code.toByte() && b[5] == 't'.code.toByte() && b[6] == 'y'.code.toByte() && b[7] == 'p'.code.toByte())) {
            return false
        }
        val brand = String(b, 8, 4, Charsets.US_ASCII)
        return brand in setOf("heic", "heix", "hevc", "hevx", "heim", "heis", "hevm", "hevs", "mif1", "msf1")
    }

    /** RIFF container with a WEBP form type. */
    private fun isWebp(b: ByteArray): Boolean {
        if (b.size < 12) return false
        val riff = b[0] == 'R'.code.toByte() && b[1] == 'I'.code.toByte() && b[2] == 'F'.code.toByte() && b[3] == 'F'.code.toByte()
        val webp = b[8] == 'W'.code.toByte() && b[9] == 'E'.code.toByte() && b[10] == 'B'.code.toByte() && b[11] == 'P'.code.toByte()
        return riff && webp
    }
}
