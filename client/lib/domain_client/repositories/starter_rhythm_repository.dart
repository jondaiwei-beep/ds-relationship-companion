import '../api_client.dart';
import '../models/starter_rhythm_view.dart';

class StarterRhythmRepository {
  StarterRhythmRepository(this._api);

  final ApiClient _api;

  /// Suggest a rhythm. Writes nothing.
  Future<StarterRhythmProposal> propose(String dynamicId) async =>
      StarterRhythmProposal.fromJson(
        await _api.get('/v1/dynamics/$dynamicId/starter-rhythm'),
      );

  Future<void> start(
    String dynamicId, {
    required String assigneeUserId,
    String? ritualTitle,
    String? expectationTitle,
    bool includeSecondExpectation = false,
    required String idempotencyKey,
  }) =>
      _api.post(
        '/v1/dynamics/$dynamicId/starter-rhythm',
        body: {
          'assigneeUserId': assigneeUserId,
          'ritualTitle': ritualTitle,
          'expectationTitle': expectationTitle,
          'includeSecondExpectation': includeSecondExpectation,
        },
        idempotencyKey: idempotencyKey,
      );
}
