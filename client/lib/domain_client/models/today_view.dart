import 'package:freezed_annotation/freezed_annotation.dart';

part 'today_view.freezed.dart';
part 'today_view.g.dart';

@freezed
abstract class TodayItem with _$TodayItem {
  const factory TodayItem({
    required String occurrenceId,
    required String title,
    String? purpose,
    /// `TASK` or `RITUAL`, stated by the server (REQ-STATE-001).
    ///
    /// The default is a rollout concession, not a fact: the current server
    /// always sends this, but staging has not been redeployed (plan item
    /// T1.6) and a required field would hard-fail the build the owner tests
    /// with. It is deliberately `''` rather than `'TASK'` — an absent kind is
    /// unknown, not a task, and [kindLabel] keeps the claim neutral instead of
    /// asserting one. Make it required once staging is redeployed.
    @Default('') String kind,
    required String state,

    /// What this person may do with this item right now, stated by the server.
    /// REQ-STATE-001 names entitlement explicitly: the screen used to offer
    /// all four actions unconditionally, including on items whose only
    /// permitted action was to withdraw an open adjustment.
    @Default(<String>[]) List<String> allowedActions,
    DateTime? dueAt,
    /// Who set this. Direction comes from a person, not from the app.
    String? fromDisplayName,

    /// Who this was given to, when the viewer is the one who gave it.
    String? assigneeDisplayName,

    /// When the receiving person said "received". Null until they do — and
    /// the difference between the two is the first thing the giving side
    /// looks for.
    DateTime? receivedAt,

    /// The words the other person attached when they asked to adjust. Shown
    /// to the person who now has to answer; never paraphrased by the app.
    String? actorNote,
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
    ///
    /// `null` when an older server did not send it, in which case the line is
    /// omitted rather than stating a boundary nobody chose. Make it required
    /// once staging is redeployed (plan item T1.6).
    int? dayBoundaryMinutes,

    /// The Dynamic's IANA zone. REQ-TIME-001: due times are rendered here, not
    /// in the device's zone, so a travelling partner reads the same hour their
    /// partner set. `null` from a server that predates the field, in which
    /// case the device's zone is the only thing left to use.
    String? referenceTimezone,

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

    /// What the other person did that now waits on me: completions to
    /// acknowledge, adjustments to answer, past-due items to look at. Most
    /// urgent first, ordered by the server.
    @Default(<TodayItem>[]) List<TodayItem> needsMyResponse,

    /// What I gave that is still open on their side, with whether it has
    /// been received.
    @Default(<TodayItem>[]) List<TodayItem> given,
  }) = _TodayView;

  factory TodayView.fromJson(Map<String, dynamic> json) => _$TodayViewFromJson(json);
}
