import '../api_client.dart';
import '../models/notification.dart';

class NotificationRepository {
  NotificationRepository(this._api);

  final ApiClient _api;

  /// Items newer than [since] (all when null), newest first, with the unread
  /// total across the whole inbox.
  Future<NotificationInbox> inbox({DateTime? since, int limit = 50}) async {
    final q = Uri(queryParameters: {
      if (since != null) 'since': since.toUtc().toIso8601String(),
      'limit': '$limit',
    }).query;
    return NotificationInbox.fromJson(await _api.get('/v1/me/notifications?$q'));
  }

  Future<int> unreadCount() async {
    final r = await _api.get('/v1/me/notifications/unread-count');
    return (r['unreadCount'] as num?)?.toInt() ?? 0;
  }

  /// Marks [ids], or everything created at or before [allBefore]. Not keyed:
  /// reading twice is reading once.
  Future<int> markRead({List<String>? ids, DateTime? allBefore}) async {
    final r = await _api.post('/v1/me/notifications/read', body: {
      'ids': ?ids,
      if (allBefore != null) 'allBefore': allBefore.toUtc().toIso8601String(),
    });
    return (r['updated'] as num?)?.toInt() ?? 0;
  }

  Future<NotificationMuteSettings> muteSettings() async =>
      NotificationMuteSettings.fromJson(await _api.get('/v1/me/notification-mute-settings'));

  /// A partial update: only what is passed changes. [clearDigest] turns the
  /// digest off, which a null could not say.
  Future<NotificationMuteSettings> updateMuteSettings({
    bool? neutralLockscreen,
    int? deliverDigestHours,
    bool clearDigest = false,
    Set<String>? mutedTypes,
  }) async =>
      NotificationMuteSettings.fromJson(await _api.put(
        '/v1/me/notification-mute-settings',
        body: {
          'neutralLockscreen': ?neutralLockscreen,
          'deliverDigestHours': ?deliverDigestHours,
          if (clearDigest) 'clearDeliverDigestHours': true,
          if (mutedTypes != null) 'mutedTypes': mutedTypes.toList(),
        },
      ));
}
