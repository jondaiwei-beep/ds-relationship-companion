import '../../domain_client/models/notification.dart';
import '../../domain_client/repositories/notification_repository.dart';
import 'local_notifier.dart';
import 'sync_store.dart';

/// Stable tray id for one inbox item, kept clear of the reminder range.
int notificationTrayId(String id) => 10000 + (id.hashCode & 0x7fffff);

/// Fetches what arrived since the last run and puts one device notification
/// in the tray per new, unread, unmuted item. Returns how many it showed.
///
/// Shared by the background isolate and by a foreground resume, so the two
/// can never disagree about what "new" means.
Future<int> syncNewNotifications({
  required NotificationRepository repo,
  required NotificationSyncStore store,
  required LocalNotifier notifier,
  DateTime? Function()? now,
}) async {
  final since = await store.lastSeen();
  final settings = await repo.muteSettings();
  final inbox = await repo.inbox(since: since, limit: 20);
  var shown = 0;
  DateTime? newest = since;
  for (final item in inbox.items) {
    if (newest == null || item.createdAt.isAfter(newest)) newest = item.createdAt;
    if (!item.unread || item.muted) continue;
    if (since != null && !item.createdAt.isAfter(since)) continue;
    await notifier.show(
      notificationTrayId(item.id),
      title: settings.neutralLockscreen ? '' : item.title,
      body: item.bodyFor(neutralLockscreen: settings.neutralLockscreen),
      payload: '${item.dynamicId}|${item.deepLink}',
    );
    shown++;
  }
  await store.setLastSeen(newest ?? (now?.call() ?? DateTime.now().toUtc()));
  return shown;
}

/// Splits a tray payload back into `(dynamicId, deepLink)`.
(String, String)? parseTrayPayload(String payload) {
  final i = payload.indexOf('|');
  if (i <= 0) return null;
  return (payload.substring(0, i), payload.substring(i + 1));
}

/// Where a notification's `deepLink` lands in this app, which addresses every
/// surface by Dynamic.
String routeForDeepLink(String deepLink, String dynamicId) {
  final base = '/dynamics/$dynamicId';
  if (deepLink == '/today') return '$base/today';
  if (deepLink == '/rules') return '$base/rules';
  if (deepLink == '/points') return '$base/points';
  if (deepLink.startsWith('/record/')) {
    final day = deepLink.substring('/record/'.length);
    return day.isEmpty ? '$base/record' : '$base/record/$day';
  }
  // `/occurrences/{id}` and anything unknown: the day it belongs to is where
  // the person will find it.
  return '$base/today';
}

/// Convenience for tests and callers holding only the model.
extension AppNotificationRoute on AppNotification {
  String get route => routeForDeepLink(deepLink, dynamicId);
}
