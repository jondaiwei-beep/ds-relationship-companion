import 'package:freezed_annotation/freezed_annotation.dart';

part 'dynamic_summary.freezed.dart';
part 'dynamic_summary.g.dart';

/// One dynamic this person belongs to.
///
/// Role is answered per dynamic (Notion 03 §1) — the same person can be the
/// creator in one and the partner in another, so it is never cached against
/// the user.
@freezed
abstract class DynamicSummary with _$DynamicSummary {
  const factory DynamicSummary({
    required String dynamicId,
    required String state,
    required String roleContext,
    String? partnerDisplayName,
  }) = _DynamicSummary;

  factory DynamicSummary.fromJson(Map<String, dynamic> json) =>
      _$DynamicSummaryFromJson(json);
}
