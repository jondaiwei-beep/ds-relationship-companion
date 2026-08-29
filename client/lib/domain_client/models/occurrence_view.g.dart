// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'occurrence_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AcknowledgementView _$AcknowledgementViewFromJson(Map<String, dynamic> json) =>
    _AcknowledgementView(
      type: json['type'] as String,
      text: json['text'] as String,
      sentAt: DateTime.parse(json['sentAt'] as String),
      senderDisplayName: json['senderDisplayName'] as String?,
    );

Map<String, dynamic> _$AcknowledgementViewToJson(
  _AcknowledgementView instance,
) => <String, dynamic>{
  'type': instance.type,
  'text': instance.text,
  'sentAt': instance.sentAt.toIso8601String(),
  'senderDisplayName': instance.senderDisplayName,
};

_OccurrenceView _$OccurrenceViewFromJson(Map<String, dynamic> json) =>
    _OccurrenceView(
      id: json['id'] as String,
      title: json['title'] as String,
      purpose: json['purpose'] as String?,
      state: $enumDecode(_$OccurrenceStateEnumMap, json['state']),
      dueAt: json['dueAt'] == null
          ? null
          : DateTime.parse(json['dueAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      acknowledgement: json['acknowledgement'] == null
          ? null
          : AcknowledgementView.fromJson(
              json['acknowledgement'] as Map<String, dynamic>,
            ),
      partnerDisplayName: json['partnerDisplayName'] as String?,
      privateNote: json['privateNote'] as String?,
      allowedActions:
          (json['allowedActions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
    );

Map<String, dynamic> _$OccurrenceViewToJson(_OccurrenceView instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'purpose': instance.purpose,
      'state': _$OccurrenceStateEnumMap[instance.state]!,
      'dueAt': instance.dueAt?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'acknowledgement': instance.acknowledgement,
      'partnerDisplayName': instance.partnerDisplayName,
      'privateNote': instance.privateNote,
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
