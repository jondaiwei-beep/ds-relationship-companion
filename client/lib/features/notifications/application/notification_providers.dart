import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../domain_client/models/notification.dart';
import '../../../domain_client/models/today_view.dart';
import '../../../platform/push/local_notifier.dart';
import 'reminder_schedule.dart';

/// How often the bell asks while the app is on screen.
const unreadPollInterval = Duration(seconds: 60);

/// The unread total behind the bell. [UnreadPoll] re-reads it every minute
/// while the app is on screen and on resume; the inbox re-reads it on open.
/// No retry: the next poll is the retry.
final unreadCountProvider = FutureProvider<int>(
  (ref) => ref.watch(notificationRepositoryProvider).unreadCount(),
  retry: (_, _) => null,
);

/// Keeps [unreadCountProvider] fresh for as long as it is on screen: a poll
/// every [unreadPollInterval] and one on every return to the foreground. Lives
/// in the tree, so it goes away with the screen that shows the bell.
class UnreadPoll extends ConsumerStatefulWidget {
  const UnreadPoll({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<UnreadPoll> createState() => _UnreadPollState();
}

class _UnreadPollState extends ConsumerState<UnreadPoll> {
  Timer? _timer;
  AppLifecycleListener? _lifecycle;

  void _refresh() => ref.invalidate(unreadCountProvider);

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(unreadPollInterval, (_) => _refresh());
    _lifecycle = AppLifecycleListener(onResume: _refresh);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _lifecycle?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

final inboxProvider = FutureProvider<NotificationInbox>(
  (ref) => ref.watch(notificationRepositoryProvider).inbox(),
);

final muteSettingsProvider = FutureProvider<NotificationMuteSettings>(
  (ref) => ref.watch(notificationRepositoryProvider).muteSettings(),
);

/// Puts the s's task reminders in the tray for the day just read, replacing
/// whatever the previous read scheduled. Delivered items drop out because
/// they are no longer open; nothing is cancelled one by one.
class TaskReminderScheduler {
  TaskReminderScheduler(this._notifier);

  final LocalNotifier _notifier;
  final _scheduled = <int>{};

  Future<void> reschedule(
    TodayView view, {
    required DateTime now,
    required String Function(String taskTitle) dueText,
    required String Function(int openCount) dayEndText,
    required String title,
    String? payload,
  }) async {
    final planned = planReminders(view, now);
    await _notifier.cancelAll(_scheduled);
    _scheduled.clear();
    for (final r in planned) {
      await _notifier.schedule(
        r.trayId,
        title: title,
        body: switch (r.kind) {
          ReminderKind.due => dueText(r.title ?? ''),
          ReminderKind.dayEnd => dayEndText(r.openCount),
        },
        at: r.at,
        payload: payload,
      );
      _scheduled.add(r.trayId);
    }
  }
}

final taskReminderSchedulerProvider = Provider<TaskReminderScheduler>(
  (ref) => TaskReminderScheduler(ref.watch(localNotifierProvider)),
);
