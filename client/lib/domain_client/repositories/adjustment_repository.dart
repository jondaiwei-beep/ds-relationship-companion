import '../api_client.dart';

/// Ask to discuss, move, or skip.
///
/// None of these is a Miss. No role can disable them, so the
/// client never gates these calls on a role either.
enum AdjustmentType { discuss, reschedule, cantDo }

/// How the partner answers — Journey D vocabulary. Deliberately not
/// approve/reject, which would frame asking as requesting permission.
enum AdjustmentResolution { cont, adjust, reschedule, excuse, cancel }

extension on AdjustmentType {
  String get wire => switch (this) {
        AdjustmentType.discuss => 'DISCUSS',
        AdjustmentType.reschedule => 'RESCHEDULE',
        AdjustmentType.cantDo => 'CANT_DO',
      };
}

extension on AdjustmentResolution {
  String get wire => switch (this) {
        AdjustmentResolution.cont => 'CONTINUE',
        AdjustmentResolution.adjust => 'ADJUST',
        AdjustmentResolution.reschedule => 'RESCHEDULE',
        AdjustmentResolution.excuse => 'EXCUSE',
        AdjustmentResolution.cancel => 'CANCEL',
      };
}

class AdjustmentRepository {
  AdjustmentRepository(this._api);

  final ApiClient _api;

  Future<void> request(
    String occurrenceId, {
    required AdjustmentType type,
    String? note,
    DateTime? requestedAt,
    required String idempotencyKey,
  }) =>
      _api.post(
        '/v1/occurrences/$occurrenceId/adjustments',
        body: {
          'type': type.wire,
          'note': note,
          'requestedAt': requestedAt?.toUtc().toIso8601String(),
        },
        idempotencyKey: idempotencyKey,
      );

  Future<void> resolve(
    String occurrenceId, {
    required AdjustmentResolution resolution,
    String? note,
    DateTime? newTime,
    required String idempotencyKey,
  }) =>
      _api.post(
        '/v1/occurrences/$occurrenceId/adjustments/resolve',
        body: {
          'resolution': resolution.wire,
          'note': note,
          'newTime': newTime?.toUtc().toIso8601String(),
        },
        idempotencyKey: idempotencyKey,
      );

  /// Take your own request back.
  ///
  /// Not a sixth [AdjustmentResolution]: that vocabulary is how the OTHER
  /// person answers. This is the person who asked deciding they no longer
  /// need to, which is why it carries no resolution and no note.
  Future<void> withdraw(
    String occurrenceId, {
    required String idempotencyKey,
  }) =>
      _api.post(
        '/v1/occurrences/$occurrenceId/adjustments/withdraw',
        idempotencyKey: idempotencyKey,
      );
}
