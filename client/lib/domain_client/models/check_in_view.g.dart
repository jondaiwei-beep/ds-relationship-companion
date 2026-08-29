// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_in_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CheckInView _$CheckInViewFromJson(Map<String, dynamic> json) => _CheckInView(
  id: json['id'] as String,
  relationshipDay: DateTime.parse(json['relationshipDay'] as String),
  mood: json['mood'] as String?,
  energy: json['energy'] as String?,
  need: json['need'] as String?,
  note: json['note'] as String?,
  visibility: json['visibility'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  creatorDisplayName: json['creatorDisplayName'] as String?,
  isMine: json['isMine'] as bool? ?? false,
);

Map<String, dynamic> _$CheckInViewToJson(_CheckInView instance) =>
    <String, dynamic>{
      'id': instance.id,
      'relationshipDay': instance.relationshipDay.toIso8601String(),
      'mood': instance.mood,
      'energy': instance.energy,
      'need': instance.need,
      'note': instance.note,
      'visibility': instance.visibility,
      'createdAt': instance.createdAt.toIso8601String(),
      'creatorDisplayName': instance.creatorDisplayName,
      'isMine': instance.isMine,
    };
