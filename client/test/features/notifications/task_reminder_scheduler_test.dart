
import 'package:dsapp/features/notifications/application/notification_providers.dart';
import 'package:dsapp/platform/push/local_notifier.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tz;

import '../../support/today_fakes.dart';

/// A notifier that iterates the ids it is given the way the plugin-backed one
/// does — one awaited cancel per id — so a set changing underneath it shows.
class _SlowNotifier extends NoopLocalNotifier {
  final scheduled = <int>[];
  final cancelled = <int>[];

  @override
  Future<void> cancelAll(Iterable<int> ids) async {
    for (final id in ids) {
      await Future<void>.delayed(Duration.zero);
      cancelled.add(id);
    }
  }

  @override
  Future<void> schedule(int id, {required String title, required String body, required DateTime at, String? payload}) async {
    await Future<void>.delayed(Duration.zero);
    scheduled.add(id);
  }
}

void main() {
  setUpAll(tz.initializeTimeZones);

  test('two reschedules in flight at once do not trip over the id set', () async {
    final notifier = _SlowNotifier();
    final scheduler = TaskReminderScheduler(notifier);
    final now = DateTime.utc(2026, 9, 1, 6);
    final view = sView(items: [
      occ(id: 'a', title: 'A', dueAt: DateTime.utc(2026, 9, 1, 12)),
      occ(id: 'b', title: 'B', dueAt: DateTime.utc(2026, 9, 1, 13)),
    ]);

    Future<void> go() => scheduler.reschedule(
          view,
          now: now,
          dueText: (t) => t,
          dayEndText: (n) => '$n',
          title: 't',
        );

    // Today refreshed, then the fetch behind it landed: the second call
    // arrives before the first has finished cancelling.
    await go();
    final first = go();
    final second = go();
    await expectLater(Future.wait([first, second]), completes);

    // Each round cancels what the previous one scheduled, in order.
    expect(notifier.cancelled.length, notifier.scheduled.length - 3);
  });
}
