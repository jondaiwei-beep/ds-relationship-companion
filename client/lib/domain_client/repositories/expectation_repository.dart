import '../api_client.dart';

class ExpectationRepository {
  ExpectationRepository(this._api);

  final ApiClient _api;

  /// Ask something of the other person — the direction-giving half of the
  /// loop. Until this existed, that half could not be started from the app.
  ///
  /// [dueAt] is optional on purpose: an expectation without a deadline is a
  /// standing intention, and forcing a time on everything would turn the
  /// product into a scheduler.
  Future<String> create(
    String dynamicId, {
    required String title,
    String? purpose,
    required String assigneeUserId,
    DateTime? dueAt,
    required String idempotencyKey,
  }) async {
    final r = await _api.post(
      '/v1/dynamics/$dynamicId/expectations',
      body: {
        'title': title,
        'purpose': purpose,
        'assigneeUserId': assigneeUserId,
        'dueAt': dueAt?.toUtc().toIso8601String(),
      },
      idempotencyKey: idempotencyKey,
    );
    return r['definitionId'] as String? ?? r['occurrenceId'] as String? ?? '';
  }
}
