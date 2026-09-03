import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:timezone/data/latest.dart' as tz;
import 'package:workmanager/workmanager.dart';

import '../../app/providers.dart' show kApiBaseUrl;
import '../../domain_client/api_client.dart';
import '../../domain_client/repositories/auth_repository.dart';
import '../../domain_client/repositories/notification_repository.dart';
import '../session/refresh_store.dart';
import 'local_notifier.dart';
import 'notification_sync.dart';
import 'sync_store.dart';

const kNotificationSyncTask = 'companion.notificationSync';

/// Android: a periodic WorkManager job (15 min is the platform floor) that
/// signs in with the stored refresh credential and announces new inbox items.
///
/// iOS has no equivalent that fires reliably; there the inbox is polled while
/// the app is open, and task reminders are scheduled ahead of time so they
/// arrive without any fetch. Web has neither.
Future<void> registerBackgroundNotificationSync() async {
  if (kIsWeb || !Platform.isAndroid) return;
  await Workmanager().initialize(notificationSyncDispatcher);
  await Workmanager().registerPeriodicTask(
    kNotificationSyncTask,
    kNotificationSyncTask,
    frequency: const Duration(minutes: 15),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    constraints: Constraints(networkType: NetworkType.connected),
    backoffPolicy: BackoffPolicy.linear,
    backoffPolicyDelay: const Duration(minutes: 5),
  );
}

/// Runs in its own isolate: nothing from the app's ProviderScope exists here.
@pragma('vm:entry-point')
void notificationSyncDispatcher() {
  Workmanager().executeTask((task, _) async {
    if (task != kNotificationSyncTask) return true;
    try {
      tz.initializeTimeZones();
      final store = NotificationSyncStore();
      if (await store.isForeground()) return true;

      final refreshStore = RefreshStore();
      final refresh = await refreshStore.read();
      if (refresh == null) return true;

      final api = ApiClient(baseUrl: kApiBaseUrl);
      final auth = await AuthRepository(api).refresh(refreshToken: refresh);
      final rotated = auth.refreshToken;
      if (rotated != null) await refreshStore.write(rotated);
      api.accessToken = auth.accessToken;

      final notifier = PluginLocalNotifier();
      await notifier.init();
      await syncNewNotifications(
        repo: NotificationRepository(api),
        store: store,
        notifier: notifier,
      );
      return true;
    } catch (_) {
      // Network or a dead session: try again next period. Never surface this.
      return true;
    }
  });
}
