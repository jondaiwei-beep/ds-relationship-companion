// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'd_note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DNote _$DNoteFromJson(Map<String, dynamic> json) => _DNote(
  id: json['id'] as String,
  body: json['body'] as String,
  remindAt: json['remindAt'] == null
      ? null
      : DateTime.parse(json['remindAt'] as String),
  remindedAt: json['remindedAt'] == null
      ? null
      : DateTime.parse(json['remindedAt'] as String),
  doneAt: json['doneAt'] == null
      ? null
      : DateTime.parse(json['doneAt'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$DNoteToJson(_DNote instance) => <String, dynamic>{
  'id': instance.id,
  'body': instance.body,
  'remindAt': instance.remindAt?.toIso8601String(),
  'remindedAt': instance.remindedAt?.toIso8601String(),
  'doneAt': instance.doneAt?.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
};
