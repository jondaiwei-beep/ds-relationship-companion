import '../api_client.dart';
import '../models/consequence.dart';

/// The consequence lifecycle. Nothing here creates one — that is the D's
/// `punished` disposition on an occurrence (today_repository).
class ConsequenceRepository {
  ConsequenceRepository(this._api);

  final ApiClient _api;

  Future<List<ConsequenceView>> list(String dynamicId, {String? status}) async {
    final q = status == null ? '' : '?status=$status';
    final r = await _api.get('/v1/dynamics/$dynamicId/consequences$q');
    return ((r['consequences'] as List?) ?? const [])
        .cast<Map<String, dynamic>>()
        .map(ConsequenceView.fromJson)
        .toList(growable: false);
  }

  /// s:「做完了」.
  Future<ConsequenceView> done(String consequenceId, {required String idempotencyKey}) async =>
      ConsequenceView.fromJson(
        await _api.post('/v1/consequences/$consequenceId/done', idempotencyKey: idempotencyKey),
      );

  /// D:「确认」.
  Future<ConsequenceView> confirm(String consequenceId, {required String idempotencyKey}) async =>
      ConsequenceView.fromJson(
        await _api.post('/v1/consequences/$consequenceId/confirm', idempotencyKey: idempotencyKey),
      );

  /// D:「算了」. Recorded as plainly as confirming.
  Future<ConsequenceView> waive(String consequenceId, {required String idempotencyKey}) async =>
      ConsequenceView.fromJson(
        await _api.post('/v1/consequences/$consequenceId/waive', idempotencyKey: idempotencyKey),
      );
}
