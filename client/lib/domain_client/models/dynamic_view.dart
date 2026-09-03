import 'package:freezed_annotation/freezed_annotation.dart';

part 'dynamic_view.freezed.dart';
part 'dynamic_view.g.dart';

@freezed
abstract class MemberView with _$MemberView {
  const factory MemberView({
    required String userId,
    String? displayName,
    required String roleContext,
    /// How they describe their role. Never used for authorization.
    String? rolePreset,
    /// `D` or `S` — which face of the app this member sees.
    String? side,
    required String accessState,
  }) = _MemberView;

  factory MemberView.fromJson(Map<String, dynamic> json) => _$MemberViewFromJson(json);
}

@freezed
abstract class StructureItem with _$StructureItem {
  const factory StructureItem({
    required String taskId,
    required String kind,
    required String title,
    required bool active,
  }) = _StructureItem;

  factory StructureItem.fromJson(Map<String, dynamic> json) =>
      _$StructureItemFromJson(json);
}

@freezed
abstract class DynamicDetail with _$DynamicDetail {
  const factory DynamicDetail({
    required String dynamicId,
    required String state,
    required String desiredOutcome,
    required String structureLevel,
    required String referenceTimezone,
    @Default(0) int dayBoundaryMinutes,
    DateTime? pausedAt,
    /// D-26: the D is away until this instant; tasks needing them are paused.
    DateTime? dAwayUntil,
    @Default(<MemberView>[]) List<MemberView> members,
    @Default(<StructureItem>[]) List<StructureItem> structure,
    /// Agency no role can ever remove. The UI must always be
    /// able to surface these, whatever the viewer's role.
    @Default(<String>[]) List<String> alwaysAvailable,
  }) = _DynamicDetail;

  factory DynamicDetail.fromJson(Map<String, dynamic> json) =>
      _$DynamicDetailFromJson(json);
}
