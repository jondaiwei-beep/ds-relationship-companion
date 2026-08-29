import 'package:freezed_annotation/freezed_annotation.dart';

part 'starter_rhythm_view.freezed.dart';
part 'starter_rhythm_view.g.dart';

/// What we would suggest as a starting rhythm. Nothing is written yet.
@freezed
abstract class StarterRhythmProposal with _$StarterRhythmProposal {
  const factory StarterRhythmProposal({
    required String ritualTitle,
    required String ritualPurpose,
    required String expectationTitle,
    required String expectationPurpose,
    required String checkInFraming,
    /// Offered, not included. The creator opts in (Notion 05 §4).
    required String optionalSecondTitle,
    required String optionalSecondPurpose,
  }) = _StarterRhythmProposal;

  factory StarterRhythmProposal.fromJson(Map<String, dynamic> json) =>
      _$StarterRhythmProposalFromJson(json);
}
