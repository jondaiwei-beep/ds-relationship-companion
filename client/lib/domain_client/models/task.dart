import 'package:freezed_annotation/freezed_annotation.dart';

part 'task.freezed.dart';
part 'task.g.dart';

/// A task definition (product/03-domain.md · Task).
@freezed
abstract class TaskView with _$TaskView {
  const factory TaskView({
    required String id,
    required String title,
    String? detail,
    required String kind,
    Map<String, dynamic>? schedule,
    @Default(1) int timesPerDay,
    /// `HH:mm[:ss]` local to the Dynamic, or null when the task has no clock.
    String? dueTime,
    DateTime? dueAt,
    required String proof,
    @Default(0) int pointsEarn,
    @Default(false) bool requiresDPresent,
    DateTime? pausedUntil,
    String? unit,
    required String createdBy,
    /// `proposed | active | archived`.
    required String status,
    @Default(0) int position,
  }) = _TaskView;

  factory TaskView.fromJson(Map<String, dynamic> json) =>
      _$TaskViewFromJson(json);
}

/// `POST /v1/dynamics/{id}/tasks` body.
@freezed
abstract class NewTask with _$NewTask {
  const factory NewTask({
    required String title,
    String? detail,
    /// `recurring | one_off | open | checkin | measure`.
    @Default('recurring') String kind,
    /// `{"type":"daily"}` and friends. Null lets the server default a
    /// recurring task to daily.
    Map<String, dynamic>? schedule,
    @Default(1) int timesPerDay,
    String? dueTime,
    DateTime? dueAt,
    @Default('check') String proof,
    @Default(0) int pointsEarn,
    @Default(false) bool requiresDPresent,
    String? unit,
  }) = _NewTask;

  factory NewTask.fromJson(Map<String, dynamic> json) =>
      _$NewTaskFromJson(json);
}
