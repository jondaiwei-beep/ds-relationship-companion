import 'package:freezed_annotation/freezed_annotation.dart';

part 'today_view.freezed.dart';
part 'today_view.g.dart';

@freezed
abstract class TodayItem with _$TodayItem {
  const factory TodayItem({
    required String occurrenceId,
    required String title,
    String? purpose,
    required String state,
    DateTime? dueAt,
    /// Who set this. Direction comes from a person, not from the app.
    String? fromDisplayName,
  }) = _TodayItem;

  factory TodayItem.fromJson(Map<String, dynamic> json) => _$TodayItemFromJson(json);
}

/// The most recent human response — presence, even when apart.
@freezed
abstract class RecentResponse with _$RecentResponse {
  const factory RecentResponse({
    required String occurrenceId,
    required String title,
    required String type,
    required String text,
    required DateTime sentAt,
    String? senderDisplayName,
  }) = _RecentResponse;

  factory RecentResponse.fromJson(Map<String, dynamic> json) =>
      _$RecentResponseFromJson(json);
}

@freezed
abstract class TodayView with _$TodayView {
  const factory TodayView({
    /// My role in THIS dynamic (Notion 03 §1 — role belongs to Membership).
    @Default('PARTNER') String roleContext,
    /// How many things are waiting on my human response, stated by the
    /// server. Today shows the direction-giving face when this is non-zero.
    @Default(0) int needsMyResponseCount,
    @Default(<TodayItem>[]) List<TodayItem> expectations,
    @Default(<TodayItem>[]) List<TodayItem> awaitingResponse,
    RecentResponse? recentResponse,
  }) = _TodayView;

  factory TodayView.fromJson(Map<String, dynamic> json) => _$TodayViewFromJson(json);
}
