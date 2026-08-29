// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'occurrence.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Occurrence _$OccurrenceFromJson(Map<String, dynamic> json) => _Occurrence(
  id: json['id'] as String,
  definitionId: json['definitionId'] as String,
  dynamicId: json['dynamicId'] as String,
  state: $enumDecode(_$OccurrenceStateEnumMap, json['state']),
  relationshipDay: DateTime.parse(json['relationshipDay'] as String),
  dueAt: json['dueAt'] == null ? null : DateTime.parse(json['dueAt'] as String),
  allowedActions:
      (json['allowedActions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
);

Map<String, dynamic> _$OccurrenceToJson(_Occurrence instance) =>
    <String, dynamic>{
      'id': instance.id,
      'definitionId': instance.definitionId,
      'dynamicId': instance.dynamicId,
      'state': _$OccurrenceStateEnumMap[instance.state]!,
      'relationshipDay': instance.relationshipDay.toIso8601String(),
      'dueAt': instance.dueAt?.toIso8601String(),
      'allowedActions': instance.allowedActions,
    };

const _$OccurrenceStateEnumMap = {
  OccurrenceState.scheduled: 'SCHEDULED',
  OccurrenceState.active: 'ACTIVE',
  OccurrenceState.waitingAck: 'WAITING_ACK',
  OccurrenceState.acknowledged: 'ACKNOWLEDGED',
  OccurrenceState.needsReview: 'NEEDS_REVIEW',
  OccurrenceState.reviewed: 'REVIEWED',
  OccurrenceState.needToDiscuss: 'NEED_TO_DISCUSS',
  OccurrenceState.rescheduleRequested: 'RESCHEDULE_REQUESTED',
  OccurrenceState.excuseRequested: 'EXCUSE_REQUESTED',
  OccurrenceState.excused: 'EXCUSED',
  OccurrenceState.cancelled: 'CANCELLED',
};
