import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_settings.freezed.dart';
part 'notification_settings.g.dart';

/// A member's own notification settings (Notion 04 §5).
///
/// These belong to the person, not to a dynamic: no partner and no role can
/// see or set them.
@freezed
abstract class NotificationSettings with _$NotificationSettings {
  const factory NotificationSettings({
    @Default('UTC') String timezone,
    /// NEUTRAL keeps the lockscreen and email subject free of relationship
    /// content. It is the default and never widens on its own.
    @Default('NEUTRAL') String notificationPreview,
    /// Minutes past local midnight; null when quiet hours are off.
    int? quietHoursStartMin,
    int? quietHoursEndMin,
  }) = _NotificationSettings;

  const NotificationSettings._();

  bool get quietHoursOn =>
      quietHoursStartMin != null && quietHoursEndMin != null;

  factory NotificationSettings.fromJson(Map<String, dynamic> json) =>
      _$NotificationSettingsFromJson(json);
}
