// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TaskView _$TaskViewFromJson(Map<String, dynamic> json) => _TaskView(
  id: json['id'] as String,
  title: json['title'] as String,
  detail: json['detail'] as String?,
  kind: json['kind'] as String,
  schedule: json['schedule'] as Map<String, dynamic>?,
  timesPerDay: (json['timesPerDay'] as num?)?.toInt() ?? 1,
  dueTime: json['dueTime'] as String?,
  dueAt: json['dueAt'] == null ? null : DateTime.parse(json['dueAt'] as String),
  proof: json['proof'] as String,
  pointsEarn: (json['pointsEarn'] as num?)?.toInt() ?? 0,
  requiresDPresent: json['requiresDPresent'] as bool? ?? false,
  pausedUntil: json['pausedUntil'] == null
      ? null
      : DateTime.parse(json['pausedUntil'] as String),
  unit: json['unit'] as String?,
  createdBy: json['createdBy'] as String,
  status: json['status'] as String,
  position: (json['position'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$TaskViewToJson(_TaskView instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'detail': instance.detail,
  'kind': instance.kind,
  'schedule': instance.schedule,
  'timesPerDay': instance.timesPerDay,
  'dueTime': instance.dueTime,
  'dueAt': instance.dueAt?.toIso8601String(),
  'proof': instance.proof,
  'pointsEarn': instance.pointsEarn,
  'requiresDPresent': instance.requiresDPresent,
  'pausedUntil': instance.pausedUntil?.toIso8601String(),
  'unit': instance.unit,
  'createdBy': instance.createdBy,
  'status': instance.status,
  'position': instance.position,
};

_NewTask _$NewTaskFromJson(Map<String, dynamic> json) => _NewTask(
  title: json['title'] as String,
  detail: json['detail'] as String?,
  kind: json['kind'] as String? ?? 'recurring',
  schedule: json['schedule'] as Map<String, dynamic>?,
  timesPerDay: (json['timesPerDay'] as num?)?.toInt() ?? 1,
  dueTime: json['dueTime'] as String?,
  dueAt: json['dueAt'] == null ? null : DateTime.parse(json['dueAt'] as String),
  proof: json['proof'] as String? ?? 'check',
  pointsEarn: (json['pointsEarn'] as num?)?.toInt() ?? 0,
  requiresDPresent: json['requiresDPresent'] as bool? ?? false,
  unit: json['unit'] as String?,
);

Map<String, dynamic> _$NewTaskToJson(_NewTask instance) => <String, dynamic>{
  'title': instance.title,
  'detail': instance.detail,
  'kind': instance.kind,
  'schedule': instance.schedule,
  'timesPerDay': instance.timesPerDay,
  'dueTime': instance.dueTime,
  'dueAt': instance.dueAt?.toIso8601String(),
  'proof': instance.proof,
  'pointsEarn': instance.pointsEarn,
  'requiresDPresent': instance.requiresDPresent,
  'unit': instance.unit,
};
