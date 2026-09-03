// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MonthCell _$MonthCellFromJson(Map<String, dynamic> json) => _MonthCell(
  day: json['day'] as String,
  due: (json['due'] as num?)?.toInt() ?? 0,
  delivered: (json['delivered'] as num?)?.toInt() ?? 0,
  flagged: (json['flagged'] as num?)?.toInt() ?? 0,
  missed: (json['missed'] as num?)?.toInt() ?? 0,
  undisposed: (json['undisposed'] as num?)?.toInt() ?? 0,
  comments: (json['comments'] as num?)?.toInt() ?? 0,
  hasPrivateNote: json['hasPrivateNote'] as bool? ?? false,
);

Map<String, dynamic> _$MonthCellToJson(_MonthCell instance) =>
    <String, dynamic>{
      'day': instance.day,
      'due': instance.due,
      'delivered': instance.delivered,
      'flagged': instance.flagged,
      'missed': instance.missed,
      'undisposed': instance.undisposed,
      'comments': instance.comments,
      'hasPrivateNote': instance.hasPrivateNote,
    };

_OutcomeEntry _$OutcomeEntryFromJson(Map<String, dynamic> json) =>
    _OutcomeEntry(
      occurrenceId: json['occurrenceId'] as String,
      taskId: json['taskId'] as String,
      taskTitle: json['taskTitle'] as String,
      toValue: json['toValue'] as String,
      note: json['note'] as String?,
      proofKind: json['proofKind'] as String?,
      proofRef: json['proofRef'] as String?,
      value: decimalFromJson(json['value']),
      unit: json['unit'] as String?,
    );

Map<String, dynamic> _$OutcomeEntryToJson(_OutcomeEntry instance) =>
    <String, dynamic>{
      'occurrenceId': instance.occurrenceId,
      'taskId': instance.taskId,
      'taskTitle': instance.taskTitle,
      'toValue': instance.toValue,
      'note': instance.note,
      'proofKind': instance.proofKind,
      'proofRef': instance.proofRef,
      'value': instance.value,
      'unit': instance.unit,
    };

_DispositionEntry _$DispositionEntryFromJson(Map<String, dynamic> json) =>
    _DispositionEntry(
      occurrenceId: json['occurrenceId'] as String,
      taskId: json['taskId'] as String,
      taskTitle: json['taskTitle'] as String,
      toValue: json['toValue'] as String,
      note: json['note'] as String?,
      consequenceTitle: json['consequenceTitle'] as String?,
      makeUpDay: json['makeUpDay'] as String?,
    );

Map<String, dynamic> _$DispositionEntryToJson(_DispositionEntry instance) =>
    <String, dynamic>{
      'occurrenceId': instance.occurrenceId,
      'taskId': instance.taskId,
      'taskTitle': instance.taskTitle,
      'toValue': instance.toValue,
      'note': instance.note,
      'consequenceTitle': instance.consequenceTitle,
      'makeUpDay': instance.makeUpDay,
    };

_CommentEntry _$CommentEntryFromJson(Map<String, dynamic> json) =>
    _CommentEntry(
      id: json['id'] as String,
      authorId: json['authorId'] as String,
      body: json['body'] as String,
    );

Map<String, dynamic> _$CommentEntryToJson(_CommentEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'authorId': instance.authorId,
      'body': instance.body,
    };

_PointsEntry _$PointsEntryFromJson(Map<String, dynamic> json) => _PointsEntry(
  id: json['id'] as String,
  reason: json['reason'] as String,
  amount: (json['amount'] as num).toInt(),
  note: json['note'] as String?,
  actorUserId: json['actorUserId'] as String?,
);

Map<String, dynamic> _$PointsEntryToJson(_PointsEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reason': instance.reason,
      'amount': instance.amount,
      'note': instance.note,
      'actorUserId': instance.actorUserId,
    };

_RedemptionEntry _$RedemptionEntryFromJson(Map<String, dynamic> json) =>
    _RedemptionEntry(
      id: json['id'] as String,
      rewardId: json['rewardId'] as String,
      rewardTitle: json['rewardTitle'] as String,
      givenByUserId: json['givenByUserId'] as String?,
      subjectUserId: json['subjectUserId'] as String,
    );

Map<String, dynamic> _$RedemptionEntryToJson(_RedemptionEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'rewardId': instance.rewardId,
      'rewardTitle': instance.rewardTitle,
      'givenByUserId': instance.givenByUserId,
      'subjectUserId': instance.subjectUserId,
    };

_TimelineEntry _$TimelineEntryFromJson(
  Map<String, dynamic> json,
) => _TimelineEntry(
  at: DateTime.parse(json['at'] as String),
  kind: json['kind'] as String,
  outcome: json['outcome'] == null
      ? null
      : OutcomeEntry.fromJson(json['outcome'] as Map<String, dynamic>),
  disposition: json['disposition'] == null
      ? null
      : DispositionEntry.fromJson(json['disposition'] as Map<String, dynamic>),
  comment: json['comment'] == null
      ? null
      : CommentEntry.fromJson(json['comment'] as Map<String, dynamic>),
  points: json['points'] == null
      ? null
      : PointsEntry.fromJson(json['points'] as Map<String, dynamic>),
  redemption: json['redemption'] == null
      ? null
      : RedemptionEntry.fromJson(json['redemption'] as Map<String, dynamic>),
);

Map<String, dynamic> _$TimelineEntryToJson(_TimelineEntry instance) =>
    <String, dynamic>{
      'at': instance.at.toIso8601String(),
      'kind': instance.kind,
      'outcome': instance.outcome,
      'disposition': instance.disposition,
      'comment': instance.comment,
      'points': instance.points,
      'redemption': instance.redemption,
    };

_DayView _$DayViewFromJson(Map<String, dynamic> json) => _DayView(
  day: json['day'] as String,
  timeline:
      (json['timeline'] as List<dynamic>?)
          ?.map((e) => TimelineEntry.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <TimelineEntry>[],
  comments:
      (json['comments'] as List<dynamic>?)
          ?.map((e) => CommentEntry.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <CommentEntry>[],
  myPrivateNote: json['myPrivateNote'] as String?,
);

Map<String, dynamic> _$DayViewToJson(_DayView instance) => <String, dynamic>{
  'day': instance.day,
  'timeline': instance.timeline,
  'comments': instance.comments,
  'myPrivateNote': instance.myPrivateNote,
};

_FactsView _$FactsViewFromJson(Map<String, dynamic> json) => _FactsView(
  from: json['from'] as String,
  to: json['to'] as String,
  delivered: (json['delivered'] as num?)?.toInt() ?? 0,
  late: (json['late'] as num?)?.toInt() ?? 0,
  flagged: (json['flagged'] as num?)?.toInt() ?? 0,
  missed: (json['missed'] as num?)?.toInt() ?? 0,
  letGo: (json['letGo'] as num?)?.toInt() ?? 0,
  praised: (json['praised'] as num?)?.toInt() ?? 0,
  madeUp: (json['madeUp'] as num?)?.toInt() ?? 0,
  punished: (json['punished'] as num?)?.toInt() ?? 0,
  comments: (json['comments'] as num?)?.toInt() ?? 0,
  pointsEarned: (json['pointsEarned'] as num?)?.toInt() ?? 0,
  pointsDeducted: (json['pointsDeducted'] as num?)?.toInt() ?? 0,
  redemptions: (json['redemptions'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$FactsViewToJson(_FactsView instance) =>
    <String, dynamic>{
      'from': instance.from,
      'to': instance.to,
      'delivered': instance.delivered,
      'late': instance.late,
      'flagged': instance.flagged,
      'missed': instance.missed,
      'letGo': instance.letGo,
      'praised': instance.praised,
      'madeUp': instance.madeUp,
      'punished': instance.punished,
      'comments': instance.comments,
      'pointsEarned': instance.pointsEarned,
      'pointsDeducted': instance.pointsDeducted,
      'redemptions': instance.redemptions,
    };

_SummaryView _$SummaryViewFromJson(Map<String, dynamic> json) => _SummaryView(
  daysTogether: (json['daysTogether'] as num?)?.toInt() ?? 0,
  currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$SummaryViewToJson(_SummaryView instance) =>
    <String, dynamic>{
      'daysTogether': instance.daysTogether,
      'currentStreak': instance.currentStreak,
    };

_DayComment _$DayCommentFromJson(Map<String, dynamic> json) => _DayComment(
  id: json['id'] as String,
  dynamicId: json['dynamicId'] as String,
  day: json['day'] as String,
  authorId: json['authorId'] as String,
  body: json['body'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$DayCommentToJson(_DayComment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'dynamicId': instance.dynamicId,
      'day': instance.day,
      'authorId': instance.authorId,
      'body': instance.body,
      'createdAt': instance.createdAt.toIso8601String(),
    };

_SeriesPoint _$SeriesPointFromJson(Map<String, dynamic> json) => _SeriesPoint(
  day: json['day'] as String,
  value: decimalFromJson(json['value']),
);

Map<String, dynamic> _$SeriesPointToJson(_SeriesPoint instance) =>
    <String, dynamic>{'day': instance.day, 'value': instance.value};

_SeriesView _$SeriesViewFromJson(Map<String, dynamic> json) => _SeriesView(
  taskId: json['taskId'] as String,
  unit: json['unit'] as String?,
  points:
      (json['points'] as List<dynamic>?)
          ?.map((e) => SeriesPoint.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$SeriesViewToJson(_SeriesView instance) =>
    <String, dynamic>{
      'taskId': instance.taskId,
      'unit': instance.unit,
      'points': instance.points,
    };
