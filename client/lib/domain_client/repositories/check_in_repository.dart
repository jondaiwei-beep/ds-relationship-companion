import '../api_client.dart';
import '../models/check_in_view.dart';

class CheckInRepository {
  CheckInRepository(this._api);

  final ApiClient _api;

  Future<List<CheckInView>> recentFor(String dynamicId) async {
    final r = await _api.get('/v1/dynamics/$dynamicId/check-ins');
    return ((r['items'] as List?) ?? const [])
        .map((e) => CheckInView.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> create(
    String dynamicId, {
    String? mood,
    String? energy,
    String? need,
    String? note,
    required CheckInVisibility visibility,
    required String idempotencyKey,
  }) =>
      _api.post(
        '/v1/dynamics/$dynamicId/check-ins',
        body: {
          'mood': mood,
          'energy': energy,
          'need': need,
          'note': note,
          'visibility': visibility == CheckInVisibility.shared ? 'SHARED' : 'PRIVATE',
        },
        idempotencyKey: idempotencyKey,
      );
}
