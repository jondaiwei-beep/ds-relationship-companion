import 'package:freezed_annotation/freezed_annotation.dart';

part 'weekly_reflection_view.freezed.dart';
part 'weekly_reflection_view.g.dart';

/// A completion a real person answered this week.
@freezed
abstract class WeeklyMoment with _$WeeklyMoment {
  const factory WeeklyMoment({
    String? title,
    /// Their words, verbatim. Never paraphrased, never generated.
    String? text,
    String? fromDisplayName,
    required DateTime occurredAt,
  }) = _WeeklyMoment;

  factory WeeklyMoment.fromJson(Map<String, dynamic> json) =>
      _$WeeklyMomentFromJson(json);
}

/// D7 Weekly Reflection — Notion 02 §8.
///
/// Deliberately light. No score, no completion rate, no streak: the week is
/// described by what was actually answered, not measured.
@freezed
abstract class WeeklyReflectionView with _$WeeklyReflectionView {
  const factory WeeklyReflectionView({
    @Default(0) int connectedDays,
    @Default(<WeeklyMoment>[]) List<WeeklyMoment> answeredMoments,
    @Default(0) int adjustmentsResolved,
    /// False until the couple has a week behind them. A reflection offered on
    /// day two invites a judgement about a week that has not happened.
    @Default(false) bool hasEnoughHistory,
  }) = _WeeklyReflectionView;

  factory WeeklyReflectionView.fromJson(Map<String, dynamic> json) =>
      _$WeeklyReflectionViewFromJson(json);
}
