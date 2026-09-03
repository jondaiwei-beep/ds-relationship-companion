// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RuleView _$RuleViewFromJson(Map<String, dynamic> json) => _RuleView(
  id: json['id'] as String,
  title: json['title'] as String,
  body: json['body'] as String?,
  group: json['group'] as String? ?? 'other',
  createdBy: json['createdBy'] as String,
  status: json['status'] as String,
  position: (json['position'] as num?)?.toInt() ?? 0,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$RuleViewToJson(_RuleView instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'body': instance.body,
  'group': instance.group,
  'createdBy': instance.createdBy,
  'status': instance.status,
  'position': instance.position,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

_NewRule _$NewRuleFromJson(Map<String, dynamic> json) => _NewRule(
  title: json['title'] as String,
  body: json['body'] as String?,
  group: json['group'] as String? ?? 'other',
);

Map<String, dynamic> _$NewRuleToJson(_NewRule instance) => <String, dynamic>{
  'title': instance.title,
  'body': instance.body,
  'group': instance.group,
};

_RuleEdit _$RuleEditFromJson(Map<String, dynamic> json) => _RuleEdit(
  title: json['title'] as String?,
  body: json['body'] as String?,
  group: json['group'] as String?,
  position: (json['position'] as num?)?.toInt(),
);

Map<String, dynamic> _$RuleEditToJson(_RuleEdit instance) => <String, dynamic>{
  'title': instance.title,
  'body': instance.body,
  'group': instance.group,
  'position': instance.position,
};
