// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dynamic_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MemberView _$MemberViewFromJson(Map<String, dynamic> json) => _MemberView(
  userId: json['userId'] as String,
  displayName: json['displayName'] as String?,
  roleContext: json['roleContext'] as String,
  rolePreset: json['rolePreset'] as String?,
  accessState: json['accessState'] as String,
);

Map<String, dynamic> _$MemberViewToJson(_MemberView instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'displayName': instance.displayName,
      'roleContext': instance.roleContext,
      'rolePreset': instance.rolePreset,
      'accessState': instance.accessState,
    };

_StructureItem _$StructureItemFromJson(Map<String, dynamic> json) =>
    _StructureItem(
      definitionId: json['definitionId'] as String,
      kind: json['kind'] as String,
      title: json['title'] as String,
      active: json['active'] as bool,
    );

Map<String, dynamic> _$StructureItemToJson(_StructureItem instance) =>
    <String, dynamic>{
      'definitionId': instance.definitionId,
      'kind': instance.kind,
      'title': instance.title,
      'active': instance.active,
    };

_DynamicDetail _$DynamicDetailFromJson(Map<String, dynamic> json) =>
    _DynamicDetail(
      dynamicId: json['dynamicId'] as String,
      state: json['state'] as String,
      desiredOutcome: json['desiredOutcome'] as String,
      structureLevel: json['structureLevel'] as String,
      referenceTimezone: json['referenceTimezone'] as String,
      dayBoundaryMinutes: (json['dayBoundaryMinutes'] as num?)?.toInt() ?? 0,
      pausedAt: json['pausedAt'] == null
          ? null
          : DateTime.parse(json['pausedAt'] as String),
      members:
          (json['members'] as List<dynamic>?)
              ?.map((e) => MemberView.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <MemberView>[],
      structure:
          (json['structure'] as List<dynamic>?)
              ?.map((e) => StructureItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <StructureItem>[],
      alwaysAvailable:
          (json['alwaysAvailable'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
    );

Map<String, dynamic> _$DynamicDetailToJson(_DynamicDetail instance) =>
    <String, dynamic>{
      'dynamicId': instance.dynamicId,
      'state': instance.state,
      'desiredOutcome': instance.desiredOutcome,
      'structureLevel': instance.structureLevel,
      'referenceTimezone': instance.referenceTimezone,
      'dayBoundaryMinutes': instance.dayBoundaryMinutes,
      'pausedAt': instance.pausedAt?.toIso8601String(),
      'members': instance.members,
      'structure': instance.structure,
      'alwaysAvailable': instance.alwaysAvailable,
    };
