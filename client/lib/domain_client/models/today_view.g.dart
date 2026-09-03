// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'today_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ConsequenceView _$ConsequenceViewFromJson(Map<String, dynamic> json) =>
    _ConsequenceView(
      id: json['id'] as String,
      title: json['title'] as String,
      detail: json['detail'] as String?,
      status: json['status'] as String,
      issuedAt: DateTime.parse(json['issuedAt'] as String),
    );

Map<String, dynamic> _$ConsequenceViewToJson(_ConsequenceView instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'detail': instance.detail,
      'status': instance.status,
      'issuedAt': instance.issuedAt.toIso8601String(),
    };

_OccurrenceView _$OccurrenceViewFromJson(
  Map<String, dynamic> json,
) => _OccurrenceView(
  id: json['id'] as String,
  taskId: json['taskId'] as String,
  title: json['title'] as String,
  detail: json['detail'] as String?,
  kind: json['kind'] as String,
  proof: json['proof'] as String,
  pointsEarn: (json['pointsEarn'] as num?)?.toInt() ?? 0,
  requiresDPresent: json['requiresDPresent'] as bool? ?? false,
  day: json['day'] as String,
  slot: (json['slot'] as num?)?.toInt() ?? 0,
  dueAt: json['dueAt'] == null ? null : DateTime.parse(json['dueAt'] as String),
  outcome:
      $enumDecodeNullable(_$OutcomeEnumMap, json['outcome']) ?? Outcome.open,
  outcomeAt: json['outcomeAt'] == null
      ? null
      : DateTime.parse(json['outcomeAt'] as String),
  outcomeNote: json['outcomeNote'] as String?,
  proofKind: json['proofKind'] as String?,
  proofRef: json['proofRef'] as String?,
  proposedTime: json['proposedTime'] == null
      ? null
      : DateTime.parse(json['proposedTime'] as String),
  disposition:
      $enumDecodeNullable(_$DispositionEnumMap, json['disposition']) ??
      Disposition.none,
  dispositionAt: json['dispositionAt'] == null
      ? null
      : DateTime.parse(json['dispositionAt'] as String),
  dispositionNote: json['dispositionNote'] as String?,
  consequence: json['consequence'] == null
      ? null
      : ConsequenceView.fromJson(json['consequence'] as Map<String, dynamic>),
  makeUpDay: json['makeUpDay'] as String?,
  makeUpOf: json['makeUpOf'] as String?,
  seenAt: json['seenAt'] == null
      ? null
      : DateTime.parse(json['seenAt'] as String),
  version: (json['version'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$OccurrenceViewToJson(_OccurrenceView instance) =>
    <String, dynamic>{
      'id': instance.id,
      'taskId': instance.taskId,
      'title': instance.title,
      'detail': instance.detail,
      'kind': instance.kind,
      'proof': instance.proof,
      'pointsEarn': instance.pointsEarn,
      'requiresDPresent': instance.requiresDPresent,
      'day': instance.day,
      'slot': instance.slot,
      'dueAt': instance.dueAt?.toIso8601String(),
      'outcome': _$OutcomeEnumMap[instance.outcome]!,
      'outcomeAt': instance.outcomeAt?.toIso8601String(),
      'outcomeNote': instance.outcomeNote,
      'proofKind': instance.proofKind,
      'proofRef': instance.proofRef,
      'proposedTime': instance.proposedTime?.toIso8601String(),
      'disposition': _$DispositionEnumMap[instance.disposition]!,
      'dispositionAt': instance.dispositionAt?.toIso8601String(),
      'dispositionNote': instance.dispositionNote,
      'consequence': instance.consequence,
      'makeUpDay': instance.makeUpDay,
      'makeUpOf': instance.makeUpOf,
      'seenAt': instance.seenAt?.toIso8601String(),
      'version': instance.version,
    };

const _$OutcomeEnumMap = {
  Outcome.open: 'open',
  Outcome.delivered: 'delivered',
  Outcome.deliveredLate: 'delivered_late',
  Outcome.cantDo: 'cant_do',
  Outcome.newTimeRequested: 'new_time_requested',
  Outcome.discussRequested: 'discuss_requested',
  Outcome.missed: 'missed',
  Outcome.paused: 'paused',
};

const _$DispositionEnumMap = {
  Disposition.none: 'none',
  Disposition.seen: 'seen',
  Disposition.praised: 'praised',
  Disposition.letGo: 'let_go',
  Disposition.makeUp: 'make_up',
  Disposition.punished: 'punished',
};

_OpenTaskView _$OpenTaskViewFromJson(Map<String, dynamic> json) =>
    _OpenTaskView(
      id: json['id'] as String,
      title: json['title'] as String,
      detail: json['detail'] as String?,
      proof: json['proof'] as String,
      pointsEarn: (json['pointsEarn'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$OpenTaskViewToJson(_OpenTaskView instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'detail': instance.detail,
      'proof': instance.proof,
      'pointsEarn': instance.pointsEarn,
    };

_TodayView _$TodayViewFromJson(Map<String, dynamic> json) => _TodayView(
  dynamicId: json['dynamicId'] as String,
  day: json['day'] as String,
  timezone: json['timezone'] as String,
  dayBoundaryMinutes: (json['dayBoundaryMinutes'] as num?)?.toInt() ?? 240,
  side: json['side'] as String,
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => OccurrenceView.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <OccurrenceView>[],
  openTasks:
      (json['openTasks'] as List<dynamic>?)
          ?.map((e) => OpenTaskView.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <OpenTaskView>[],
  balance: (json['balance'] as num?)?.toInt() ?? 0,
  daysTogether: (json['daysTogether'] as num?)?.toInt() ?? 0,
  needsMe: (json['needsMe'] as num?)?.toInt() ?? 0,
  partnerDisplayName: json['partnerDisplayName'] as String?,
  dAwayUntil: json['dAwayUntil'] == null
      ? null
      : DateTime.parse(json['dAwayUntil'] as String),
);

Map<String, dynamic> _$TodayViewToJson(_TodayView instance) =>
    <String, dynamic>{
      'dynamicId': instance.dynamicId,
      'day': instance.day,
      'timezone': instance.timezone,
      'dayBoundaryMinutes': instance.dayBoundaryMinutes,
      'side': instance.side,
      'items': instance.items,
      'openTasks': instance.openTasks,
      'balance': instance.balance,
      'daysTogether': instance.daysTogether,
      'needsMe': instance.needsMe,
      'partnerDisplayName': instance.partnerDisplayName,
      'dAwayUntil': instance.dAwayUntil?.toIso8601String(),
    };
