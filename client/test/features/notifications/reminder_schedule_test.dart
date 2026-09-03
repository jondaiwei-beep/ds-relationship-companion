import 'package:dsapp/domain_client/models/today_view.dart';
import 'package:dsapp/features/notifications/application/reminder_schedule.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tz;

import '../../support/today_fakes.dart';

void main() {
  setUpAll(tz.initializeTimeZones);

  // Fakes build the day 2026-09-01 in Asia/Shanghai with the day starting 04:00.
  final now = DateTime.utc(2026, 9, 1, 6); // 14:00 Shanghai, mid-day

  test('day end is next calendar day at the boundary, in the Dynamic zone', () {
    final view = sView(items: [occ(id: 'a', title: 'A')]);
    expect(view.timezone, 'Asia/Shanghai');
    expect(view.dayBoundaryMinutes, 240);
    expect(dayEndOf(view), DateTime.utc(2026, 9, 1, 20)); // 2026-09-02 04:00+08
  });

  test('plans one due reminder per open item and a 日终 reminder 60 min before day end', () {
    final due = DateTime.utc(2026, 9, 1, 12); // 20:00 Shanghai
    final view = sView(items: [
      occ(id: 'a', title: 'A', dueAt: due),
      occ(id: 'b', title: 'B'), // no due time
      occ(id: 'c', title: 'C', dueAt: DateTime.utc(2026, 9, 1, 2)), // already passed
      occ(id: 'd', title: 'D', dueAt: due, outcome: Outcome.delivered),
    ]);
    final plan = planReminders(view, now);
    final dues = plan.where((p) => p.kind == ReminderKind.due).toList();
    expect(dues.map((p) => p.occurrenceId), ['a']);
    expect(dues.single.at, due);
    final dayEnd = plan.singleWhere((p) => p.kind == ReminderKind.dayEnd);
    expect(dayEnd.at, DateTime.utc(2026, 9, 1, 19)); // 03:00+08 next day
    expect(dayEnd.openCount, 3);
  });

  test('nothing when everything is delivered, and nothing for D', () {
    expect(
      planReminders(sView(items: [occ(id: 'a', title: 'A', outcome: Outcome.delivered)]), now),
      isEmpty,
    );
    expect(planReminders(dView(items: [occ(id: 'a', title: 'A')]), now), isEmpty);
  });

  test('no 日终 reminder once that instant has passed', () {
    final late = DateTime.utc(2026, 9, 1, 19, 30);
    expect(planReminders(sView(items: [occ(id: 'a', title: 'A')]), late), isEmpty);
  });
}
