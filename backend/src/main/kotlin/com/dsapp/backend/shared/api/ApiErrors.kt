package com.dsapp.backend.shared.api

import com.dsapp.backend.dynamic.application.InviteAlreadyPending
import com.dsapp.backend.dynamic.application.InviteNotRevocable
import com.dsapp.backend.dynamic.application.InviteNotJoinable
import com.dsapp.backend.dynamic.application.DynamicNotPausable
import com.dsapp.backend.dynamic.domain.AuthorizationException
import com.dsapp.backend.expectation.application.OccurrenceNotCompletable
import com.dsapp.backend.response.application.AdjustmentNotPossible
import com.dsapp.backend.response.application.NoOpenAdjustment
import com.dsapp.backend.response.application.OccurrenceNotAcknowledgeable
import com.dsapp.backend.shared.idempotency.IdempotencyKeyReusedException
import com.dsapp.backend.shared.idempotency.MissingIdempotencyKeyException
import org.springframework.http.HttpStatus
import org.springframework.http.converter.HttpMessageNotReadableException
import org.springframework.web.bind.MethodArgumentNotValidException
import org.springframework.http.ResponseEntity
import com.dsapp.backend.identity.application.NotificationSettingsService
import org.springframework.web.bind.annotation.ExceptionHandler
import org.springframework.web.bind.annotation.RestControllerAdvice

/** Stable machine-readable error codes. Backend state names never leak (Notion 05 §12). */
data class ApiError(val code: String, val detail: String? = null)

@RestControllerAdvice
class ApiErrorHandler {

    /**
     * A request that did not satisfy its own contract.
     *
     * Answered as 400 with the offending field, never 401. A client that sees
     * 401 concludes the session ended and clears it — so without this a
     * mistyped email would sign someone out instead of asking them to fix it.
     *
     * The field name is safe to return: it names an input the caller just
     * sent, not anything about an account.
     */
    @ExceptionHandler(MethodArgumentNotValidException::class)
    fun onInvalidBody(e: MethodArgumentNotValidException): ResponseEntity<ApiError> {
        val field = e.bindingResult.fieldErrors.firstOrNull()?.field
        return ResponseEntity.badRequest()
            .body(ApiError("INVALID_REQUEST", field))
    }

    /** A body that could not be parsed at all — same reasoning as above. */
    @ExceptionHandler(HttpMessageNotReadableException::class)
    fun onUnreadableBody(e: HttpMessageNotReadableException): ResponseEntity<ApiError> =
        ResponseEntity.badRequest().body(ApiError("INVALID_REQUEST"))

    @ExceptionHandler(AuthorizationException::class)
    fun onAuthorization(e: AuthorizationException): ResponseEntity<ApiError> =
        // 404, not 403: revealing "this exists but you may not touch it" leaks
        // relationship structure to a non-member (Notion 04 §3).
        ResponseEntity.status(HttpStatus.NOT_FOUND).body(ApiError("NOT_FOUND"))

    @ExceptionHandler(OccurrenceNotCompletable::class)
    fun onNotCompletable(e: OccurrenceNotCompletable): ResponseEntity<ApiError> =
        ResponseEntity.status(HttpStatus.CONFLICT).body(ApiError("OCCURRENCE_NOT_ACTIVE"))

    @ExceptionHandler(OccurrenceNotAcknowledgeable::class)
    fun onNotAcknowledgeable(e: OccurrenceNotAcknowledgeable): ResponseEntity<ApiError> =
        ResponseEntity.status(HttpStatus.CONFLICT).body(ApiError("OCCURRENCE_NOT_WAITING_ACK"))

    @ExceptionHandler(AdjustmentNotPossible::class)
    fun onAdjustmentNotPossible(e: AdjustmentNotPossible): ResponseEntity<ApiError> =
        ResponseEntity.status(HttpStatus.CONFLICT).body(ApiError("OCCURRENCE_${e.state}"))

    @ExceptionHandler(NoOpenAdjustment::class)
    fun onNoOpenAdjustment(e: NoOpenAdjustment): ResponseEntity<ApiError> =
        ResponseEntity.status(HttpStatus.CONFLICT).body(ApiError("NO_OPEN_ADJUSTMENT"))

    @ExceptionHandler(InviteNotRevocable::class)
    fun onInviteNotRevocable(e: InviteNotRevocable): ResponseEntity<ApiError> =
        // 409, not 404: the caller is a member of this Dynamic and is allowed
        // to know that the invitation is settled. What they are not told is
        // *how* it settled — accepted, revoked and expired answer alike.
        ResponseEntity.status(HttpStatus.CONFLICT).body(ApiError("INVITE_NOT_LIVE"))

    @ExceptionHandler(InviteAlreadyPending::class)
    fun onInvitePending(e: InviteAlreadyPending): ResponseEntity<ApiError> =
        // A live invitation already exists. The Creator revokes it to make a
        // new one; the partial unique index would otherwise surface this as a
        // 500, and the screen contract requires retry to be recoverable.
        ResponseEntity.status(HttpStatus.CONFLICT).body(ApiError("INVITE_ALREADY_PENDING"))

    @ExceptionHandler(InviteNotJoinable::class)
    fun onInvite(e: InviteNotJoinable): ResponseEntity<ApiError> =
        // The state is deliberately disclosed so the join page can explain
        // itself rather than dead-ending (Notion 02 §A4).
        ResponseEntity.status(HttpStatus.CONFLICT).body(ApiError("INVITE_${e.state}"))

    @ExceptionHandler(DynamicNotPausable::class)
    fun onNotPausable(e: DynamicNotPausable): ResponseEntity<ApiError> =
        ResponseEntity.status(HttpStatus.CONFLICT).body(ApiError("DYNAMIC_${e.state}"))

    @ExceptionHandler(NotificationSettingsService.InvalidSettings::class)
    fun onInvalidSettings(
        e: NotificationSettingsService.InvalidSettings,
    ): ResponseEntity<ApiError> =
        ResponseEntity.badRequest().body(ApiError("INVALID_NOTIFICATION_SETTINGS"))

    @ExceptionHandler(MissingIdempotencyKeyException::class)
    fun onMissingKey(e: MissingIdempotencyKeyException): ResponseEntity<ApiError> =
        ResponseEntity.badRequest().body(ApiError("IDEMPOTENCY_KEY_REQUIRED"))

    @ExceptionHandler(IdempotencyKeyReusedException::class)
    fun onReuse(e: IdempotencyKeyReusedException): ResponseEntity<ApiError> =
        ResponseEntity.unprocessableEntity().body(ApiError("IDEMPOTENCY_KEY_REUSED"))
}
