// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consequence.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ConsequenceView _$ConsequenceViewFromJson(Map<String, dynamic> json) =>
    _ConsequenceView(
      id: json['id'] as String,
      dynamicId: json['dynamicId'] as String?,
      issuedBy: json['issuedBy'] as String,
      title: json['title'] as String,
      detail: json['detail'] as String?,
      status: json['status'] as String,
      issuedAt: json['issuedAt'] == null
          ? null
          : DateTime.parse(json['issuedAt'] as String),
      doneAt: json['doneAt'] == null
          ? null
          : DateTime.parse(json['doneAt'] as String),
      decidedAt: json['decidedAt'] == null
          ? null
          : DateTime.parse(json['decidedAt'] as String),
    );

Map<String, dynamic> _$ConsequenceViewToJson(_ConsequenceView instance) =>
    <String, dynamic>{
      'id': instance.id,
      'dynamicId': instance.dynamicId,
      'issuedBy': instance.issuedBy,
      'title': instance.title,
      'detail': instance.detail,
      'status': instance.status,
      'issuedAt': instance.issuedAt?.toIso8601String(),
      'doneAt': instance.doneAt?.toIso8601String(),
      'decidedAt': instance.decidedAt?.toIso8601String(),
    };
