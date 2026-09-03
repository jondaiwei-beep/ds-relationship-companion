import 'package:freezed_annotation/freezed_annotation.dart';
import 'occurrence.dart';

part 'occurrence_view.freezed.dart';
part 'occurrence_view.g.dart';

/// A human-authored response. Never system-generated.
@freezed
abstract class AcknowledgementView with _$AcknowledgementView {
  const factory AcknowledgementView({
    required String type,
    required String text,
    required DateTime sentAt,
    String? senderDisplayName,
  }) = _AcknowledgementView;

  factory AcknowledgementView.fromJson(Map<String, dynamic> json) =>
      _$AcknowledgementViewFromJson(json);
}

/// Authoritative occurrence state from the server.
///
/// Notion 03 §8: the client renders this. It never computes `missed` or
/// `acknowledged` from timestamps or cache.
@freezed
abstract class OccurrenceView with _$OccurrenceView {
  const factory OccurrenceView({
    required String id,
    required String title,
    String? purpose,
    required OccurrenceState state,
    DateTime? dueAt,
    DateTime? completedAt,
    AcknowledgementView? acknowledgement,
    /// The other person, by name. Screens in the loop address a human being
    /// rather than a workflow role.
    String? partnerDisplayName,

    /// What this person wrote for themselves when completing.
    ///
    /// The server returns it only to its author — null for the partner, and
    /// null when nothing was written. A screen may show it back to the person
    /// who wrote it; nothing may put it anywhere the other person can see.
    String? privateNote,
    /// Server-computed UX hint. Never treated as authorization.
    @Default(<String>[]) List<String> allowedActions,
  }) = _OccurrenceView;

  factory OccurrenceView.fromJson(Map<String, dynamic> json) =>
      _$OccurrenceViewFromJson(json);
}
