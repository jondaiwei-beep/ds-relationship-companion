import '../api_client.dart';
import '../models/record.dart';

/// 记录 reads and the two small writes that live on a day: a comment either
/// person leaves, and the private note only its author ever reads.
///
/// Repairing history — an s delivering a `missed` occurrence, a D answering
/// an old one — goes through `TodayRepository`: it is the same command on the
/// same occurrence, whatever day it is looked at from.
class RecordRepository {
  RecordRepository(this._api);

  final ApiClient _api;

  /// [month] is `yyyy-MM`. Days with nothing on them are not returned.
  Future<List<MonthCell>> month(String dynamicId, String month) async {
    final r = await _api.getList('/v1/dynamics/$dynamicId/record/month?month=$month');
    return r.cast<Map<String, dynamic>>().map(MonthCell.fromJson).toList(growable: false);
  }

  /// [day] is `yyyy-MM-dd`.
  Future<DayView> day(String dynamicId, String day) async =>
      DayView.fromJson(await _api.get('/v1/dynamics/$dynamicId/record/day?day=$day'));

  Future<FactsView> facts(String dynamicId, {required String from, required String to}) async =>
      FactsView.fromJson(
        await _api.get('/v1/dynamics/$dynamicId/record/facts?from=$from&to=$to'),
      );

  Future<SummaryView> summary(String dynamicId) async =>
      SummaryView.fromJson(await _api.get('/v1/dynamics/$dynamicId/record/summary'));

  Future<DayComment> addComment(
    String dynamicId, {
    required String day,
    required String body,
    required String idempotencyKey,
  }) async =>
      DayComment.fromJson(
        await _api.post(
          '/v1/dynamics/$dynamicId/record/comments',
          body: {'day': day, 'body': body},
          idempotencyKey: idempotencyKey,
        ),
      );

  /// Only the author's own; the server refuses anything else.
  Future<void> deleteComment(String commentId) => _api.delete('/v1/day-comments/$commentId');

  /// Whole-value write. An empty [body] removes the note. Returns what is now
  /// stored — null when nothing is.
  Future<String?> putPrivateNote(
    String dynamicId, {
    required String day,
    required String body,
  }) async {
    final r = await _api.put(
      '/v1/dynamics/$dynamicId/record/private-note',
      body: {'day': day, 'body': body},
    );
    final stored = r['body'] as String?;
    return stored == null || stored.isEmpty ? null : stored;
  }
}
