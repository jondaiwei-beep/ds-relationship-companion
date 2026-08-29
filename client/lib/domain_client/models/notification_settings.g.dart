// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotificationSettings _$NotificationSettingsFromJson(
  Map<String, dynamic> json,
) => _NotificationSettings(
  timezone: json['timezone'] as String? ?? 'UTC',
  notificationPreview: json['notificationPreview'] as String? ?? 'NEUTRAL',
  quietHoursStartMin: (json['quietHoursStartMin'] as num?)?.toInt(),
  quietHoursEndMin: (json['quietHoursEndMin'] as num?)?.toInt(),
);

Map<String, dynamic> _$NotificationSettingsToJson(
  _NotificationSettings instance,
) => <String, dynamic>{
  'timezone': instance.timezone,
  'notificationPreview': instance.notificationPreview,
  'quietHoursStartMin': instance.quietHoursStartMin,
  'quietHoursEndMin': instance.quietHoursEndMin,
};
