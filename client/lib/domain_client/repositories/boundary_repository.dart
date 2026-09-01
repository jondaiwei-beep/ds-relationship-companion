import '../api_client.dart';
import '../models/boundary.dart';

class BoundaryRepository {
  BoundaryRepository(this._api);

  final ApiClient _api;

  /// Both members' lists. The server marks which rows are the caller's.
  Future<List<Boundary>> forDynamic(String dynamicId) async {
    final r = await _api.get('/v1/dynamics/$dynamicId/boundaries');
    final rows = (r['boundaries'] as List?) ?? const [];
    return rows
        .cast<Map<String, dynamic>>()
        .map(Boundary.fromJson)
        .toList(growable: false);
  }

  /// Adds one to the caller's own list, or updates it if they already named
  /// the same thing. The author is taken from the session, never sent.
  Future<void> add(
    String dynamicId, {
    required String label,
    required BoundaryStance stance,
    String? note,
  }) =>
      _api.post(
        '/v1/dynamics/$dynamicId/boundaries',
        body: {'label': label, 'stance': stance.wire, 'note': note},
      );

  Future<void> remove(String dynamicId, String boundaryId) =>
      _api.delete('/v1/dynamics/$dynamicId/boundaries/$boundaryId');
}
