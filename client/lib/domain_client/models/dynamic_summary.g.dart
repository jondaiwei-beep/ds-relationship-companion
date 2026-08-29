// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dynamic_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DynamicSummary _$DynamicSummaryFromJson(Map<String, dynamic> json) =>
    _DynamicSummary(
      dynamicId: json['dynamicId'] as String,
      state: json['state'] as String,
      roleContext: json['roleContext'] as String,
      partnerDisplayName: json['partnerDisplayName'] as String?,
    );

Map<String, dynamic> _$DynamicSummaryToJson(_DynamicSummary instance) =>
    <String, dynamic>{
      'dynamicId': instance.dynamicId,
      'state': instance.state,
      'roleContext': instance.roleContext,
      'partnerDisplayName': instance.partnerDisplayName,
    };
