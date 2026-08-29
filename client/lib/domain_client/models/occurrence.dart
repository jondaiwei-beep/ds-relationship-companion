import 'package:freezed_annotation/freezed_annotation.dart';

part 'occurrence.freezed.dart';
part 'occurrence.g.dart';

/// Occurrence state — Notion 03 §2.
///
/// Server is the sole authority for this value. The client MUST NOT derive
/// it from timestamps or local cache (Notion 03 §8).
@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum OccurrenceState {
  scheduled,
  active,
  /// A Completion exists; awaiting a human Acknowledgement.
  /// Completion != Acknowledgement (product red line #2).
  waitingAck,
  acknowledged,
  /// Past due. Never punishment (product red line #3).
  needsReview,
  reviewed,
  needToDiscuss,
  rescheduleRequested,
  excuseRequested,
  excused,
  cancelled,
}

@freezed
abstract class Occurrence with _$Occurrence {
  const factory Occurrence({
    required String id,
    required String definitionId,
    required String dynamicId,
    required OccurrenceState state,
    /// The relationship day this belongs to, per the Dynamic's day boundary.
    required DateTime relationshipDay,
    DateTime? dueAt,
    /// Server-supplied UX convenience only. Authorization is still enforced
    /// server-side on every command endpoint (Notion 06 §7).
    @Default(<String>[]) List<String> allowedActions,
  }) = _Occurrence;

  factory Occurrence.fromJson(Map<String, dynamic> json) =>
      _$OccurrenceFromJson(json);
}
