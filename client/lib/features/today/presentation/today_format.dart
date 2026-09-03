import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

/// Clock and date text for the 今天 surface, always in the Dynamic's zone.
///
/// The device zone is never consulted (invariant 7). If the zone database has
/// not been loaded — a test, or a zone this build does not know — the instant
/// is shown in UTC rather than silently in the device's idea of local time.
abstract final class TodayFormat {
  static tz.Location? _location(String zone) {
    try {
      return tz.getLocation(zone);
    } on Object {
      return null;
    }
  }

  static DateTime _inZone(DateTime instant, String zone) {
    final loc = _location(zone);
    if (loc == null) return instant.toUtc();
    return tz.TZDateTime.from(instant.toUtc(), loc);
  }

  /// `HH:mm` in the reader's convention.
  static String clock(DateTime instant, String zone, String locale) =>
      DateFormat.Hm(locale).format(_inZone(instant, zone));

  /// Minutes past midnight as a clock, e.g. the day boundary.
  static String minutesClock(int minutes, String locale) {
    final wrapped = minutes % (24 * 60);
    return DateFormat.Hm(locale)
        .format(DateTime(2000, 1, 1, wrapped ~/ 60, wrapped % 60));
  }

  /// A relationship day (`yyyy-MM-dd`) as a short date.
  static String day(String isoDay, String locale) {
    final parts = isoDay.split('-').map(int.parse).toList(growable: false);
    return DateFormat.MMMd(locale).format(DateTime(parts[0], parts[1], parts[2]));
  }

  /// A relationship day with weekday, for the header.
  static String dayLong(String isoDay, String locale) {
    final parts = isoDay.split('-').map(int.parse).toList(growable: false);
    return DateFormat.MMMEd(locale).format(DateTime(parts[0], parts[1], parts[2]));
  }

  /// Day and clock together, for something said on another day.
  static String dayClock(DateTime instant, String zone, String locale) {
    final local = _inZone(instant, zone);
    return '${DateFormat.MMMd(locale).format(local)} ${DateFormat.Hm(locale).format(local)}';
  }

  /// Build an instant from a relationship day and a wall clock in [zone].
  static DateTime instantOf(String isoDay, int hour, int minute, String zone) {
    final parts = isoDay.split('-').map(int.parse).toList(growable: false);
    final loc = _location(zone);
    if (loc == null) {
      return DateTime.utc(parts[0], parts[1], parts[2], hour, minute);
    }
    return tz.TZDateTime(loc, parts[0], parts[1], parts[2], hour, minute).toUtc();
  }
}
