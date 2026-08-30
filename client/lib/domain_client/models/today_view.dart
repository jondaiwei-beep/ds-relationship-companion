import 'package:freezed_annotation/freezed_annotation.dart';

part 'today_view.freezed.dart';
part 'today_view.g.dart';

@freezed
abstract class TodayItem with _$TodayItem {
  const factory TodayItem({
    required String occurrenceId,
    required String title,
    String? purpose,
    /// `TASK` or `RITUAL`, stated by the server (REQ-STATE-001). Defaulted so
    /// a client built against an older server degrades to the common kind
    /// rather than failing to parse the day.
    @Default('TASK') String kind,
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

    /// The relationship day this list belongs to, resolved by the server in
    /// the Dynamic's own timezone. The client never derives it from the
    /// device clock.
    DateTime? relationshipDay,

    /// Minutes past midnight at which the relationship day rolls over, in the
    /// Dynamic's own timezone. The screen used to state a hard-coded 2:00 AM,
    /// which was wrong for any Dynamic that chose another boundary.
    @Default(120) int dayBoundaryMinutes,

    /// When the server last confirmed this list. Offline shows the last
    /// confirmed list with this timestamp rather than implying it is current.
    DateTime? lastConfirmedAt,

    /// Total actionable items for the day, stated by the server.
    @Default(0) int totalCount,

    /// At most three, in server order: the first carries editorial emphasis,
    /// the next two are timeline rows. Never re-sorted on the client.
    @Default(<TodayItem>[]) List<TodayItem> priorityItems,

    /// Everything else for the day, behind one count-bearing disclosure.
    @Default(<TodayItem>[]) List<TodayItem> laterItems,
    @Default(<TodayItem>[]) List<TodayItem> awaitingResponse,
    RecentResponse? recentResponse,
  }) = _TodayView;

  factory TodayView.fromJson(Map<String, dynamic> json) => _$TodayViewFromJson(json);
}
