import '../api_client.dart';
import '../models/d_note.dart';

/// The D's private notes. Never returned to the s by any endpoint.
class DNoteRepository {
  DNoteRepository(this._api);

  final ApiClient _api;

  Future<List<DNote>> list(String dynamicId, {bool includeDone = false}) async {
    final r = await _api.getList(
      '/v1/dynamics/$dynamicId/d-notes?includeDone=$includeDone',
    );
    return r.cast<Map<String, dynamic>>().map(DNote.fromJson).toList(growable: false);
  }

  Future<DNote> create(
    String dynamicId, {
    required String body,
    DateTime? remindAt,
    required String idempotencyKey,
  }) async =>
      DNote.fromJson(
        await _api.post(
          '/v1/dynamics/$dynamicId/d-notes',
          body: {'body': body, 'remindAt': remindAt?.toUtc().toIso8601String()},
          idempotencyKey: idempotencyKey,
        ),
      );

  Future<DNote> done(String noteId) async =>
      DNote.fromJson(await _api.post('/v1/d-notes/$noteId/done'));

  Future<void> delete(String noteId) => _api.delete('/v1/d-notes/$noteId');
}
