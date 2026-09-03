// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'redemption.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RedemptionView _$RedemptionViewFromJson(Map<String, dynamic> json) =>
    _RedemptionView(
      id: json['id'] as String,
      rewardId: json['rewardId'] as String,
      rewardTitle: json['rewardTitle'] as String?,
      subjectUserId: json['subjectUserId'] as String,
      status: json['status'] as String,
      note: json['note'] as String?,
      decidedBy: json['decidedBy'] as String?,
      decidedAt: json['decidedAt'] == null
          ? null
          : DateTime.parse(json['decidedAt'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$RedemptionViewToJson(_RedemptionView instance) =>
    <String, dynamic>{
      'id': instance.id,
      'rewardId': instance.rewardId,
      'rewardTitle': instance.rewardTitle,
      'subjectUserId': instance.subjectUserId,
      'status': instance.status,
      'note': instance.note,
      'decidedBy': instance.decidedBy,
      'decidedAt': instance.decidedAt?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
    };
