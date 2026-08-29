import '../api_client.dart';
import '../models/notification_settings.dart';

class SettingsRepository {
  SettingsRepository(this._api);

  final ApiClient _api;

  Future<NotificationSettings> notifications() async =>
      NotificationSettings.fromJson(
          await _api.get('/v1/me/notification-settings'));

  /// Quiet hours are sent as a pair or not at all — half a window would
  /// suppress nothing while looking set.
  Future<NotificationSettings> update({
    String? notificationPreview,
    int? quietHoursStartMin,
    int? quietHoursEndMin,
  }) async =>
      NotificationSettings.fromJson(await _api.post(
        '/v1/me/notification-settings',
        body: {
          'notificationPreview': notificationPreview,
          'quietHoursStartMin': quietHoursStartMin,
          'quietHoursEndMin': quietHoursEndMin,
        },
      ));
}
