import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

/// The device's own notification tray. No push service sits behind this: the
/// app shows what it fetched itself, and schedules what it already knows.
abstract class LocalNotifier {
  Future<void> init();

  /// Asks for permission where the platform wants one (Android 13+, iOS).
  Future<void> requestPermission();

  Future<void> show(int id, {required String title, required String body, String? payload});

  /// Fires at [at] (an instant). Nothing happens when [at] is already past.
  Future<void> schedule(int id, {required String title, required String body, required DateTime at, String? payload});

  Future<void> cancel(int id);

  /// Cancels every id in [ids]; the tray's other entries are untouched.
  Future<void> cancelAll(Iterable<int> ids);

  /// A tap on a notification, as the payload it carried.
  Stream<String> get opened;
}

class NoopLocalNotifier implements LocalNotifier {
  @override
  Future<void> init() async {}
  @override
  Future<void> requestPermission() async {}
  @override
  Future<void> show(int id, {required String title, required String body, String? payload}) async {}
  @override
  Future<void> schedule(int id, {required String title, required String body, required DateTime at, String? payload}) async {}
  @override
  Future<void> cancel(int id) async {}
  @override
  Future<void> cancelAll(Iterable<int> ids) async {}
  @override
  Stream<String> get opened => const Stream.empty();
}

class PluginLocalNotifier implements LocalNotifier {
  PluginLocalNotifier({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  final _opened = StreamController<String>.broadcast();

  static const channelId = 'companion.default';
  static const channelName = 'Companion';

  static const _android = AndroidNotificationDetails(
    channelId,
    channelName,
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
    // The lockscreen decides what it shows from `neutralLockscreen`, not from
    // a private-visibility flag: a hidden body would look like a secret.
  );
  static const _details = NotificationDetails(
    android: _android,
    iOS: DarwinNotificationDetails(),
  );

  @override
  Future<void> init() => _quietly(_init);

  Future<void> _init() async {
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (r) {
        final p = r.payload;
        if (p != null && p.isNotEmpty) _opened.add(p);
      },
    );
    final launch = await _plugin.getNotificationAppLaunchDetails();
    final p = launch?.notificationResponse?.payload;
    if ((launch?.didNotificationLaunchApp ?? false) && p != null && p.isNotEmpty) {
      _opened.add(p);
    }
  }

  @override
  Future<void> requestPermission() => _quietly(() async {
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  });

  /// The tray is a convenience, never a dependency: a platform without the
  /// plugin (tests, an unsupported build) must not break the screen asking.
  Future<void> _quietly(Future<void> Function() op) async {
    try {
      await op();
    } catch (_) {}
  }

  @override
  Future<void> show(int id, {required String title, required String body, String? payload}) =>
      _quietly(() => _plugin.show(id: id, title: title, body: body, notificationDetails: _details, payload: payload));

  @override
  Future<void> schedule(int id, {required String title, required String body, required DateTime at, String? payload}) async {
    final when = tz.TZDateTime.from(at.toUtc(), tz.UTC);
    if (!when.isAfter(tz.TZDateTime.now(tz.UTC))) return;
    await _quietly(() => _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: when,
      notificationDetails: _details,
      payload: payload,
      // Inexact is enough for a reminder and needs no alarm permission.
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    ));
  }

  @override
  Future<void> cancel(int id) => _quietly(() => _plugin.cancel(id: id));

  @override
  Future<void> cancelAll(Iterable<int> ids) async {
    for (final id in ids) {
      await cancel(id);
    }
  }

  @override
  Stream<String> get opened => _opened.stream;
}

final localNotifierProvider = Provider<LocalNotifier>(
  (_) => kIsWeb ? NoopLocalNotifier() : PluginLocalNotifier(),
);
