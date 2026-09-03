import 'package:dio/dio.dart';

import '../api_client.dart';
import '../models/today_view.dart';

/// Why a write on an occurrence was refused (HTTP 409, `{code}`).
///
/// Every one of these is a fact about the other person having moved first,
/// never a judgement. The screen reverts its optimistic state and says which.
enum OccurrenceConflict {
  /// `OCCURRENCE_PAUSED` — the D paused this task.
  paused,

  /// `OCCURRENCE_DISPOSED` — the D already answered; the s can no longer
  /// change what they said.
  disposed,

  /// `OCCURRENCE_OPEN` — the D tried to answer something the s has not said.
  open,

  /// `OCCURRENCE_CHANGED` — someone else wrote in between; reload.
  changed,

  /// A 409 this build does not know.
  other;

  static OccurrenceConflict? fromError(Object error) {
    if (error is! DioException) return null;
    if (error.response?.statusCode != 409) return null;
    final data = error.response?.data;
    final code = data is Map ? data['code'] as String? : null;
    return switch (code) {
      'OCCURRENCE_PAUSED' => OccurrenceConflict.paused,
      'OCCURRENCE_DISPOSED' => OccurrenceConflict.disposed,
      'OCCURRENCE_OPEN' => OccurrenceConflict.open,
      'OCCURRENCE_CHANGED' => OccurrenceConflict.changed,
      _ => OccurrenceConflict.other,
    };
  }
}

/// What the s says about one occurrence. `open` takes it back.
class OutcomeChange {
  const OutcomeChange({
    required this.outcome,
    this.note,
    this.proofKind,
    this.proofRef,
    this.proposedTime,
    this.value,
  });

  final Outcome outcome;
  final String? note;
  final String? proofKind;
  final String? proofRef;
  final DateTime? proposedTime;

  /// `kind=measure` only; the server requires it on `delivered` and refuses
  /// it on any other kind.
  final double? value;

  Map<String, dynamic> toJson() => {
        'outcome': outcome.wire,
        'note': note,
        'proofKind': proofKind,
        'proofRef': proofRef,
        'proposedTime': proposedTime?.toUtc().toIso8601String(),
        if (value != null) 'value': value,
      };
}

/// What the D says about one occurrence.
class DispositionChange {
  const DispositionChange({
    required this.disposition,
    this.note,
    this.makeUpDay,
    this.consequenceTemplateId,
    this.consequenceTitle,
    this.consequenceDetail,
  });

  final Disposition disposition;
  final String? note;

  /// `yyyy-MM-dd`, required for `makeUp`.
  final String? makeUpDay;

  /// Required for `punished`: either a template or a title of the D's own.
  final String? consequenceTemplateId;
  final String? consequenceTitle;
  final String? consequenceDetail;

  Map<String, dynamic> toJson() => {
        'disposition': disposition.wire,
        'note': note,
        'makeUpDay': makeUpDay,
        if (disposition == Disposition.punished)
          'consequence': {
            'templateId': consequenceTemplateId,
            'title': consequenceTitle,
            'detail': consequenceDetail,
          },
      };
}

class OutcomeResult {
  const OutcomeResult({
    required this.occurrenceId,
    required this.outcome,
    this.outcomeAt,
    required this.version,
  });

  factory OutcomeResult.fromJson(Map<String, dynamic> json) => OutcomeResult(
        occurrenceId: json['occurrenceId'] as String,
        outcome: _outcomeFromWire(json['outcome'] as String),
        outcomeAt: (json['outcomeAt'] as String?).let(DateTime.parse),
        version: (json['version'] as num?)?.toInt() ?? 0,
      );

  final String occurrenceId;
  final Outcome outcome;
  final DateTime? outcomeAt;
  final int version;
}

class DispositionResult {
  const DispositionResult({
    required this.occurrenceId,
    required this.disposition,
    this.dispositionAt,
    this.consequenceId,
    this.makeUpOccurrenceId,
    required this.version,
  });

  factory DispositionResult.fromJson(Map<String, dynamic> json) =>
      DispositionResult(
        occurrenceId: json['occurrenceId'] as String,
        disposition: _dispositionFromWire(json['disposition'] as String),
        dispositionAt: (json['dispositionAt'] as String?).let(DateTime.parse),
        consequenceId: json['consequenceId'] as String?,
        makeUpOccurrenceId: json['makeUpOccurrenceId'] as String?,
        version: (json['version'] as num?)?.toInt() ?? 0,
      );

  final String occurrenceId;
  final Disposition disposition;
  final DateTime? dispositionAt;
  final String? consequenceId;
  final String? makeUpOccurrenceId;
  final int version;
}

Outcome _outcomeFromWire(String w) =>
    Outcome.values.firstWhere((o) => o.wire == w, orElse: () => Outcome.open);

Disposition _dispositionFromWire(String w) => Disposition.values
    .firstWhere((d) => d.wire == w, orElse: () => Disposition.none);

extension<T> on T? {
  R? let<R>(R Function(T) f) {
    final v = this;
    return v == null ? null : f(v);
  }
}

class TodayRepository {
  TodayRepository(this._api);

  final ApiClient _api;

  /// The relationship day the server says it is, or [day] (`yyyy-MM-dd`).
  /// The client never derives "today" from the device clock (invariant 7).
  Future<TodayView> today(String dynamicId, {String? day}) async {
    final q = day == null ? '' : '?day=$day';
    return TodayView.fromJson(await _api.get('/v1/dynamics/$dynamicId/today$q'));
  }

  /// D face: everything the s has said that has no answer yet, oldest first.
  Future<List<OccurrenceView>> needsMe(String dynamicId, {int limit = 50}) async {
    final r = await _api.getList('/v1/dynamics/$dynamicId/needs-me?limit=$limit');
    return r
        .cast<Map<String, dynamic>>()
        .map(OccurrenceView.fromJson)
        .toList(growable: false);
  }

  Future<OccurrenceView> occurrence(String occurrenceId) async =>
      OccurrenceView.fromJson(await _api.get('/v1/occurrences/$occurrenceId'));

  /// s axis. [idempotencyKey] is stable across retries of the same tap.
  Future<OutcomeResult> setOutcome(
    String occurrenceId,
    OutcomeChange change, {
    required String idempotencyKey,
  }) async =>
      OutcomeResult.fromJson(
        await _api.post(
          '/v1/occurrences/$occurrenceId/outcome',
          body: change.toJson(),
          idempotencyKey: idempotencyKey,
        ),
      );

  /// D axis.
  Future<DispositionResult> setDisposition(
    String occurrenceId,
    DispositionChange change, {
    required String idempotencyKey,
  }) async =>
      DispositionResult.fromJson(
        await _api.post(
          '/v1/occurrences/$occurrenceId/disposition',
          body: change.toJson(),
          idempotencyKey: idempotencyKey,
        ),
      );

  /// Receipt only: the D opened it. Not keyed — the first look sticks.
  Future<DateTime?> markSeen(String occurrenceId) async {
    final r = await _api.post('/v1/occurrences/$occurrenceId/seen');
    return (r['seenAt'] as String?).let(DateTime.parse);
  }
}
