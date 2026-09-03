import '../../../domain_client/models/today_view.dart';
import '../../today/presentation/today_format.dart';

enum ReminderKind { due, dayEnd }

/// One local notification the s's device should fire, as an instant.
class PlannedReminder {
  const PlannedReminder({
    required this.kind,
    required this.at,
    this.occurrenceId,
    this.title,
    this.openCount = 0,
  });

  final ReminderKind kind;
  final DateTime at;
  final String? occurrenceId;
  final String? title;

  /// `dayEnd` only: how many items are still open.
  final int openCount;

  /// Stable tray id; reminders live in their own range so they never collide
  /// with inbox items.
  int get trayId => switch (kind) {
        ReminderKind.dayEnd => dayEndTrayId,
        ReminderKind.due => 20000 + (occurrenceId!.hashCode & 0x7fffff),
      };

  static const dayEndTrayId = 19999;
}

/// How long before the day closes the 日终 reminder fires.
const dayEndReminderLead = Duration(minutes: 60);

/// Something the s has not yet said anything about.
bool _stillOpen(OccurrenceView o) =>
    (o.outcome == Outcome.open || o.outcome == Outcome.missed) &&
    o.disposition == Disposition.none;

/// The instant the relationship day [view] shows ends: the next day's start,
/// at the Dynamic's boundary, in its zone (product/03-domain.md · invariant 7).
DateTime dayEndOf(TodayView view) {
  final p = view.day.split('-').map(int.parse).toList(growable: false);
  final next = DateTime.utc(p[0], p[1], p[2]).add(const Duration(days: 1));
  final iso = '${next.year.toString().padLeft(4, '0')}-'
      '${next.month.toString().padLeft(2, '0')}-'
      '${next.day.toString().padLeft(2, '0')}';
  final m = view.dayBoundaryMinutes;
  return TodayFormat.instantOf(iso, m ~/ 60, m % 60, view.timezone);
}

/// What to schedule for [view] as of [now] (UTC): one reminder per open item
/// with a due time still ahead, and one 日终 reminder an hour before the day
/// ends while anything is still open. Pure; the caller puts them in the tray.
List<PlannedReminder> planReminders(TodayView view, DateTime now) {
  if (view.isD) return const [];
  final nowUtc = now.toUtc();
  final open = view.items.where((o) => _stillOpen(o) && !o.isPaused).toList(growable: false);
  final out = <PlannedReminder>[];
  for (final o in open) {
    final due = o.dueAt;
    if (due == null || !due.toUtc().isAfter(nowUtc)) continue;
    out.add(PlannedReminder(
      kind: ReminderKind.due,
      at: due.toUtc(),
      occurrenceId: o.id,
      title: o.title,
    ));
  }
  if (open.isNotEmpty) {
    final at = dayEndOf(view).subtract(dayEndReminderLead);
    if (at.isAfter(nowUtc)) {
      out.add(PlannedReminder(kind: ReminderKind.dayEnd, at: at, openCount: open.length));
    }
  }
  return out;
}
