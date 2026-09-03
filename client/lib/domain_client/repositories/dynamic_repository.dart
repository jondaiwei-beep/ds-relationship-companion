import '../api_client.dart';
import '../models/dynamic_summary.dart';
import '../models/dynamic_view.dart';

class DynamicRepository {
  DynamicRepository(this._api);

  final ApiClient _api;

  /// Start a dynamic. Returns its id.
  ///
  /// Minimal by design (Notion 02 §A2): a goal, how much structure, and the
  /// timezone the day is measured in. Nothing here is an agreement about
  /// anything specific — that comes later, from the two people.
  Future<String> create({
    /// `SOLO` or `COUPLE`. Was hardcoded to COUPLE, which meant choosing
    /// "For myself" on the role screen silently created a couple Dynamic.
    String mode = 'COUPLE',
    required String desiredOutcome,
    required String structureLevel,
    required String referenceTimezone,
    /// Minutes after midnight where the relationship day turns over. 04:00
    /// (product/03-domain.md): a late night still belongs to the day it
    /// started in. Matches the server's own default.
    int dayBoundaryMinutes = 240,
    /// `D` or `S` — which side the creator takes. The partner who joins gets
    /// the other one. Null lets the server derive it from [rolePreset].
    String? side,
    /// Optional self-description (Notion 03 §2). Grants nothing.
    String? rolePreset,
    /// Couple is apart. Changes what is seeded, never what is permitted.
    bool longDistance = false,
    required String idempotencyKey,
  }) async {
    final r = await _api.post(
      '/v1/dynamics',
      body: {
        'mode': mode,
        'desiredOutcome': desiredOutcome,
        'structureLevel': structureLevel,
        'referenceTimezone': referenceTimezone,
        'dayBoundaryMinutes': dayBoundaryMinutes,
        'side': ?side,
        'rolePreset': rolePreset,
        'longDistance': longDistance,
      },
      idempotencyKey: idempotencyKey,
    );
    return r['dynamicId'] as String;
  }

  /// Which dynamics am I in? The client's entry point after signing in —
  /// every other screen is addressed by an id it has to get from here.
  Future<List<DynamicSummary>> mine() async {
    final r = await _api.getList('/v1/dynamics');
    return r
        .map((e) => DynamicSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<DynamicDetail> detail(String dynamicId) async =>
      DynamicDetail.fromJson(await _api.get('/v1/dynamics/$dynamicId'));

  /// Pause is inviolable agency — either member may call it (Notion 04 §4).
  Future<void> pause(String dynamicId, {required String idempotencyKey}) =>
      _api.post('/v1/dynamics/$dynamicId/pause', idempotencyKey: idempotencyKey);

  /// Come back — Journey E. [lighter] returns to half the structure rather
  /// than all of it; being handed the same load you paused under is how
  /// people leave again.
  Future<void> resume(
    String dynamicId, {
    bool lighter = false,
    required String idempotencyKey,
  }) =>
      _api.post(
        '/v1/dynamics/$dynamicId/resume?lighter=$lighter',
        idempotencyKey: idempotencyKey,
      );

  /// Leave — no partner approval, ever (Notion 04 §4).
  Future<void> leave(String dynamicId, {String? reason, required String idempotencyKey}) =>
      _api.post(
        '/v1/dynamics/$dynamicId/leave',
        body: {'reason': reason},
        idempotencyKey: idempotencyKey,
      );

  /// Block — mutual separation, permanent. The other person is never told
  /// who did it (Notion 04 §8).
  Future<void> block(
    String dynamicId, {
    required String targetUserId,
    String? reason,
    required String idempotencyKey,
  }) =>
      _api.post(
        '/v1/dynamics/$dynamicId/block',
        body: {'targetUserId': targetUserId, 'reason': reason},
        idempotencyKey: idempotencyKey,
      );

  /// D「我不在」until [until] (D-26). Every task that needs the D present is
  /// paused for the span; nothing owed accrues meanwhile.
  Future<DateTime?> away(String dynamicId, {required DateTime until, required String idempotencyKey}) async {
    final r = await _api.post(
      '/v1/dynamics/$dynamicId/away',
      body: {'until': until.toUtc().toIso8601String()},
      idempotencyKey: idempotencyKey,
    );
    final raw = r['dAwayUntil'] as String?;
    return raw == null ? null : DateTime.parse(raw);
  }

  /// D「回来了」.
  Future<void> back(String dynamicId, {required String idempotencyKey}) =>
      _api.post('/v1/dynamics/$dynamicId/back', idempotencyKey: idempotencyKey);
}
