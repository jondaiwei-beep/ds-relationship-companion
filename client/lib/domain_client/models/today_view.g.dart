// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'today_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TodayItem _$TodayItemFromJson(Map<String, dynamic> json) => _TodayItem(
  occurrenceId: json['occurrenceId'] as String,
  title: json['title'] as String,
  purpose: json['purpose'] as String?,
  kind: json['kind'] as String? ?? '',
  state: json['state'] as String,
  allowedActions:
      (json['allowedActions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  dueAt: json['dueAt'] == null ? null : DateTime.parse(json['dueAt'] as String),
  fromDisplayName: json['fromDisplayName'] as String?,
  assigneeDisplayName: json['assigneeDisplayName'] as String?,
  receivedAt: json['receivedAt'] == null
      ? null
      : DateTime.parse(json['receivedAt'] as String),
  actorNote: json['actorNote'] as String?,
);

Map<String, dynamic> _$TodayItemToJson(_TodayItem instance) =>
    <String, dynamic>{
      'occurrenceId': instance.occurrenceId,
      'title': instance.title,
      'purpose': instance.purpose,
      'kind': instance.kind,
      'state': instance.state,
      'allowedActions': instance.allowedActions,
      'dueAt': instance.dueAt?.toIso8601String(),
      'fromDisplayName': instance.fromDisplayName,
      'assigneeDisplayName': instance.assigneeDisplayName,
      'receivedAt': instance.receivedAt?.toIso8601String(),
      'actorNote': instance.actorNote,
    };

_RecentResponse _$RecentResponseFromJson(Map<String, dynamic> json) =>
    _RecentResponse(
      occurrenceId: json['occurrenceId'] as String,
      title: json['title'] as String,
      type: json['type'] as String,
      text: json['text'] as String,
      sentAt: DateTime.parse(json['sentAt'] as String),
      senderDisplayName: json['senderDisplayName'] as String?,
    );

Map<String, dynamic> _$RecentResponseToJson(_RecentResponse instance) =>
    <String, dynamic>{
      'occurrenceId': instance.occurrenceId,
      'title': instance.title,
      'type': instance.type,
      'text': instance.text,
      'sentAt': instance.sentAt.toIso8601String(),
      'senderDisplayName': instance.senderDisplayName,
    };

_TodayView _$TodayViewFromJson(Map<String, dynamic> json) => _TodayView(
  roleContext: json['roleContext'] as String? ?? 'PARTNER',
  needsMyResponseCount: (json['needsMyResponseCount'] as num?)?.toInt() ?? 0,
  relationshipDay: json['relationshipDay'] == null
      ? null
      : DateTime.parse(json['relationshipDay'] as String),
  dayBoundaryMinutes: (json['dayBoundaryMinutes'] as num?)?.toInt(),
  referenceTimezone: json['referenceTimezone'] as String?,
  lastConfirmedAt: json['lastConfirmedAt'] == null
      ? null
      : DateTime.parse(json['lastConfirmedAt'] as String),
  totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
  priorityItems:
      (json['priorityItems'] as List<dynamic>?)
          ?.map((e) => TodayItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <TodayItem>[],
  laterItems:
      (json['laterItems'] as List<dynamic>?)
          ?.map((e) => TodayItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <TodayItem>[],
  awaitingResponse:
      (json['awaitingResponse'] as List<dynamic>?)
          ?.map((e) => TodayItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <TodayItem>[],
  recentResponse: json['recentResponse'] == null
      ? null
      : RecentResponse.fromJson(json['recentResponse'] as Map<String, dynamic>),
  needsMyResponse:
      (json['needsMyResponse'] as List<dynamic>?)
          ?.map((e) => TodayItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <TodayItem>[],
  given:
      (json['given'] as List<dynamic>?)
          ?.map((e) => TodayItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <TodayItem>[],
);

Map<String, dynamic> _$TodayViewToJson(_TodayView instance) =>
    <String, dynamic>{
      'roleContext': instance.roleContext,
      'needsMyResponseCount': instance.needsMyResponseCount,
      'relationshipDay': instance.relationshipDay?.toIso8601String(),
      'dayBoundaryMinutes': instance.dayBoundaryMinutes,
      'referenceTimezone': instance.referenceTimezone,
      'lastConfirmedAt': instance.lastConfirmedAt?.toIso8601String(),
      'totalCount': instance.totalCount,
      'priorityItems': instance.priorityItems,
      'laterItems': instance.laterItems,
      'awaitingResponse': instance.awaitingResponse,
      'recentResponse': instance.recentResponse,
      'needsMyResponse': instance.needsMyResponse,
      'given': instance.given,
    };
