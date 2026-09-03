import 'package:freezed_annotation/freezed_annotation.dart';

part 'today_view.freezed.dart';
part 'today_view.g.dart';

/// The s axis (product/03-domain.md). Written by the s, or by the day-end
/// sweep (`missed`, `paused`). Nothing here is a judgement.
enum Outcome {
  open,
  delivered,
  @JsonValue('delivered_late')
  deliveredLate,
  @JsonValue('cant_do')
  cantDo,
  @JsonValue('new_time_requested')
  newTimeRequested,
  @JsonValue('discuss_requested')
  discussRequested,
  missed,
  paused;

  /// The wire spelling the backend expects in `POST .../outcome`.
  String get wire => switch (this) {
        Outcome.open => 'open',
        Outcome.delivered => 'delivered',
        Outcome.deliveredLate => 'delivered_late',
        Outcome.cantDo => 'cant_do',
        Outcome.newTimeRequested => 'new_time_requested',
        Outcome.discussRequested => 'discuss_requested',
        Outcome.missed => 'missed',
        Outcome.paused => 'paused',
      };

  bool get isDelivered => this == delivered || this == deliveredLate;

  /// Something the s has said and can still take back before the D answers.
  bool get saidByS =>
      this == delivered ||
      this == deliveredLate ||
      this == cantDo ||
      this == newTimeRequested ||
      this == discussRequested;
}

/// The D axis. Written only by the D, never by a job, never expiring.
enum Disposition {
  none,
  seen,
  praised,
  @JsonValue('let_go')
  letGo,
  @JsonValue('make_up')
  makeUp,
  punished;

  String get wire => switch (this) {
        Disposition.none => 'none',
        Disposition.seen => 'seen',
        Disposition.praised => 'praised',
        Disposition.letGo => 'let_go',
        Disposition.makeUp => 'make_up',
        Disposition.punished => 'punished',
      };
}

@freezed
abstract class ConsequenceView with _$ConsequenceView {
  const factory ConsequenceView({
    required String id,
    required String title,
    String? detail,
    required String status,
    required DateTime issuedAt,
  }) = _ConsequenceView;

  factory ConsequenceView.fromJson(Map<String, dynamic> json) =>
      _$ConsequenceViewFromJson(json);
}

/// One task on one relationship day, on both axes.
@freezed
abstract class OccurrenceView with _$OccurrenceView {
  const OccurrenceView._();

  const factory OccurrenceView({
    required String id,
    required String taskId,
    required String title,
    String? detail,
    /// `recurring | one_off | open | checkin | measure`.
    required String kind,
    /// `check | photo | text | any`.
    required String proof,
    @Default(0) int pointsEarn,
    @Default(false) bool requiresDPresent,
    /// The relationship day, `yyyy-MM-dd`, in the Dynamic's zone.
    required String day,
    @Default(0) int slot,
    DateTime? dueAt,
    @Default(Outcome.open) Outcome outcome,
    DateTime? outcomeAt,
    String? outcomeNote,
    String? proofKind,
    String? proofRef,
    DateTime? proposedTime,
    @Default(Disposition.none) Disposition disposition,
    DateTime? dispositionAt,
    String? dispositionNote,
    ConsequenceView? consequence,
    String? makeUpDay,
    String? makeUpOf,
    DateTime? seenAt,
    @Default(0) int version,
  }) = _OccurrenceView;

  factory OccurrenceView.fromJson(Map<String, dynamic> json) =>
      _$OccurrenceViewFromJson(json);

  bool get isCheckin => kind == 'checkin';
  bool get isRecurring => kind == 'recurring';
  bool get isPaused => outcome == Outcome.paused;
}

/// A `kind=open` task: no schedule, delivered whenever, as often as wanted.
@freezed
abstract class OpenTaskView with _$OpenTaskView {
  const factory OpenTaskView({
    required String id,
    required String title,
    String? detail,
    required String proof,
    @Default(0) int pointsEarn,
  }) = _OpenTaskView;

  factory OpenTaskView.fromJson(Map<String, dynamic> json) =>
      _$OpenTaskViewFromJson(json);
}

/// `GET /v1/dynamics/{id}/today`. Both faces read the same shape.
@freezed
abstract class TodayView with _$TodayView {
  const TodayView._();

  const factory TodayView({
    required String dynamicId,
    /// The relationship day shown, `yyyy-MM-dd`.
    required String day,
    required String timezone,
    @Default(240) int dayBoundaryMinutes,
    /// `D` or `S` — the caller's side, as the server sees it.
    required String side,
    @Default(<OccurrenceView>[]) List<OccurrenceView> items,
    @Default(<OpenTaskView>[]) List<OpenTaskView> openTasks,
    @Default(0) int balance,
    @Default(0) int daysTogether,
    /// D face: things the s has said that have no answer yet, all days.
    @Default(0) int needsMe,
    String? partnerDisplayName,
  }) = _TodayView;

  factory TodayView.fromJson(Map<String, dynamic> json) =>
      _$TodayViewFromJson(json);

  bool get isD => side == 'D';
}
