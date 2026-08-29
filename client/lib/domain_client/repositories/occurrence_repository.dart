import '../api_client.dart';
import '../models/occurrence_view.dart';

/// Reads and commands for a single Expectation occurrence.
class OccurrenceRepository {
  OccurrenceRepository(this._api);

  final ApiClient _api;

  /// Always fetches server truth. Notion 06 §8: a stale push or deep link must
  /// resolve current state before rendering anything.
  Future<OccurrenceView> get(String occurrenceId) async =>
      OccurrenceView.fromJson(await _api.get('/v1/occurrences/$occurrenceId'));

  /// `ACTIVE -> WAITING_ACK`. Completing is not being seen.
  Future<void> complete(String occurrenceId, {String? note, required String idempotencyKey}) =>
      _api.post(
        '/v1/occurrences/$occurrenceId/complete',
        body: {'note': note},
        idempotencyKey: idempotencyKey,
      );

  /// `WAITING_ACK -> ACKNOWLEDGED`.
  ///
  /// [text] is written by the human sender. The UI may offer suggested wording,
  /// but the text sent here is whatever the person chose to send.
  Future<void> acknowledge(
    String occurrenceId, {
    required String type,
    required String text,
    required String idempotencyKey,
  }) =>
      _api.post(
        '/v1/occurrences/$occurrenceId/acknowledgements',
        body: {'type': type, 'text': text},
        idempotencyKey: idempotencyKey,
      );
}
