import 'package:freezed_annotation/freezed_annotation.dart';

import 'today_view.dart';

part 'record.freezed.dart';
part 'record.g.dart';

/// 记录 (product/02-surfaces.md Tab 3). Everything here is a fact the server
/// already holds; nothing is a verdict.

/// One day in the month grid. Days with nothing on them are not sent.
@freezed
abstract class MonthCell with _$MonthCell {
  const factory MonthCell({
    /// `yyyy-MM-dd`.
    required String day,
    @Default(0) int due,
    @Default(0) int delivered,
    @Default(0) int flagged,
    @Default(0) int missed,
    @Default(0) int undisposed,
    @Default(0) int comments,
    @Default(false) bool hasPrivateNote,
  }) = _MonthCell;

  factory MonthCell.fromJson(Map<String, dynamic> json) => _$MonthCellFromJson(json);
}

/// A change on the s axis, as history recorded it.
@freezed
abstract class OutcomeEntry with _$OutcomeEntry {
  const OutcomeEntry._();

  const factory OutcomeEntry({
    required String occurrenceId,
    required String taskId,
    required String taskTitle,
    /// The wire spelling (`delivered`, `missed`, …).
    required String toValue,
    String? note,
    String? proofKind,
    String? proofRef,
    /// `kind=measure` only: the number delivered, in [unit].
    @JsonKey(fromJson: decimalFromJson) double? value,
    String? unit,
  }) = _OutcomeEntry;

  factory OutcomeEntry.fromJson(Map<String, dynamic> json) => _$OutcomeEntryFromJson(json);

  Outcome get outcome => outcomeFromWire(toValue);
}

/// A change on the D axis, as history recorded it.
@freezed
abstract class DispositionEntry with _$DispositionEntry {
  const DispositionEntry._();

  const factory DispositionEntry({
    required String occurrenceId,
    required String taskId,
    required String taskTitle,
    required String toValue,
    String? note,
    String? consequenceTitle,
    /// `yyyy-MM-dd`, when the D asked for it to be made up.
    String? makeUpDay,
  }) = _DispositionEntry;

  factory DispositionEntry.fromJson(Map<String, dynamic> json) =>
      _$DispositionEntryFromJson(json);

  Disposition get disposition => dispositionFromWire(toValue);
}

/// A line either person left on the day.
@freezed
abstract class CommentEntry with _$CommentEntry {
  const factory CommentEntry({
    required String id,
    required String authorId,
    required String body,
  }) = _CommentEntry;

  factory CommentEntry.fromJson(Map<String, dynamic> json) => _$CommentEntryFromJson(json);
}

@freezed
abstract class PointsEntry with _$PointsEntry {
  const factory PointsEntry({
    required String id,
    /// `task_earn | d_award | d_deduct | redemption | redemption_refund`.
    required String reason,
    required int amount,
    String? note,
    /// Null when no person wrote it (a task's own points on delivery).
    String? actorUserId,
  }) = _PointsEntry;

  factory PointsEntry.fromJson(Map<String, dynamic> json) => _$PointsEntryFromJson(json);
}

@freezed
abstract class RedemptionEntry with _$RedemptionEntry {
  const factory RedemptionEntry({
    required String id,
    required String rewardId,
    required String rewardTitle,
    String? givenByUserId,
    required String subjectUserId,
  }) = _RedemptionEntry;

  factory RedemptionEntry.fromJson(Map<String, dynamic> json) =>
      _$RedemptionEntryFromJson(json);
}

/// One line of the day. Exactly one payload is set, matching [kind].
@freezed
abstract class TimelineEntry with _$TimelineEntry {
  const factory TimelineEntry({
    required DateTime at,
    /// `outcome | disposition | comment | points | redemption`.
    required String kind,
    OutcomeEntry? outcome,
    DispositionEntry? disposition,
    CommentEntry? comment,
    PointsEntry? points,
    RedemptionEntry? redemption,
  }) = _TimelineEntry;

  factory TimelineEntry.fromJson(Map<String, dynamic> json) => _$TimelineEntryFromJson(json);
}

/// Where one occurrence stands now, derived from the last history line on
/// each axis. The day view carries history, not current state, so the two
/// axes are read back from their latest entries.
class OccurrenceState {
  const OccurrenceState({
    required this.occurrenceId,
    required this.title,
    required this.outcome,
    required this.disposition,
  });

  final String occurrenceId;
  final String title;
  final Outcome outcome;
  final Disposition disposition;

  /// The s may still deliver or explain (invariant 5: history is repairable).
  bool get sMayRepair => outcome == Outcome.missed && disposition == Disposition.none;

  /// The D may still answer (disposition never expires).
  bool get dMayDispose =>
      outcome != Outcome.open && outcome != Outcome.paused && disposition == Disposition.none;
}

/// `GET /v1/dynamics/{id}/record/day?day=`.
@freezed
abstract class DayView with _$DayView {
  const DayView._();

  const factory DayView({
    required String day,
    @Default(<TimelineEntry>[]) List<TimelineEntry> timeline,
    @Default(<CommentEntry>[]) List<CommentEntry> comments,
    /// The caller's own note, never the partner's.
    String? myPrivateNote,
  }) = _DayView;

  factory DayView.fromJson(Map<String, dynamic> json) => _$DayViewFromJson(json);

  /// Current state of every occurrence that appears on the timeline.
  Map<String, OccurrenceState> get occurrenceStates {
    final out = <String, OccurrenceState>{};
    for (final e in timeline) {
      final o = e.outcome;
      final d = e.disposition;
      if (o != null) {
        final prev = out[o.occurrenceId];
        out[o.occurrenceId] = OccurrenceState(
          occurrenceId: o.occurrenceId,
          title: o.taskTitle,
          outcome: o.outcome,
          disposition: prev?.disposition ?? Disposition.none,
        );
      } else if (d != null) {
        final prev = out[d.occurrenceId];
        out[d.occurrenceId] = OccurrenceState(
          occurrenceId: d.occurrenceId,
          title: d.taskTitle,
          outcome: prev?.outcome ?? Outcome.open,
          disposition: d.disposition,
        );
      }
    }
    return out;
  }

  /// The index of the last timeline line about each occurrence — where an
  /// action on it belongs.
  Map<String, int> get lastEntryIndexByOccurrence {
    final out = <String, int>{};
    for (var i = 0; i < timeline.length; i++) {
      final id = timeline[i].outcome?.occurrenceId ?? timeline[i].disposition?.occurrenceId;
      if (id != null) out[id] = i;
    }
    return out;
  }
}

/// `GET .../record/facts?from=&to=`. Counts only (product/02-surfaces.md:
/// 只陈述事实，不评价).
@freezed
abstract class FactsView with _$FactsView {
  const factory FactsView({
    required String from,
    required String to,
    @Default(0) int delivered,
    @Default(0) int late,
    @Default(0) int flagged,
    @Default(0) int missed,
    @Default(0) int letGo,
    @Default(0) int praised,
    @Default(0) int madeUp,
    @Default(0) int punished,
    @Default(0) int comments,
    @Default(0) int pointsEarned,
    @Default(0) int pointsDeducted,
    @Default(0) int redemptions,
  }) = _FactsView;

  factory FactsView.fromJson(Map<String, dynamic> json) => _$FactsViewFromJson(json);
}

/// `GET .../record/summary` — D-27: two numbers, the first only grows.
@freezed
abstract class SummaryView with _$SummaryView {
  const factory SummaryView({
    @Default(0) int daysTogether,
    @Default(0) int currentStreak,
  }) = _SummaryView;

  factory SummaryView.fromJson(Map<String, dynamic> json) => _$SummaryViewFromJson(json);
}

/// `POST .../record/comments` answer.
@freezed
abstract class DayComment with _$DayComment {
  const factory DayComment({
    required String id,
    required String dynamicId,
    required String day,
    required String authorId,
    required String body,
    required DateTime createdAt,
  }) = _DayComment;

  factory DayComment.fromJson(Map<String, dynamic> json) => _$DayCommentFromJson(json);
}

Outcome outcomeFromWire(String w) =>
    Outcome.values.firstWhere((o) => o.wire == w, orElse: () => Outcome.open);

Disposition dispositionFromWire(String w) =>
    Disposition.values.firstWhere((d) => d.wire == w, orElse: () => Disposition.none);

/// One measured day on a `kind=measure` task's curve.
@freezed
abstract class SeriesPoint with _$SeriesPoint {
  const factory SeriesPoint({
    /// `yyyy-MM-dd`.
    required String day,
    @JsonKey(fromJson: decimalFromJson) double? value,
  }) = _SeriesPoint;

  factory SeriesPoint.fromJson(Map<String, dynamic> json) => _$SeriesPointFromJson(json);
}

/// The s's numbers over time for one measure task (Phase 5).
@freezed
abstract class SeriesView with _$SeriesView {
  const factory SeriesView({
    required String taskId,
    String? unit,
    @Default([]) List<SeriesPoint> points,
  }) = _SeriesView;

  factory SeriesView.fromJson(Map<String, dynamic> json) => _$SeriesViewFromJson(json);
}
