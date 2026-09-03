import 'package:timezone/timezone.dart' as tz;

/// Relationship-day arithmetic — the client half of the one algorithm
/// (product/03-domain.md invariant 7; backend `RelationshipDay.kt`).
///
/// A relationship day is NOT midnight to midnight. With a 04:00 boundary,
/// something done at 02:00 local belongs to the PREVIOUS relationship day.
///
/// Wall-clock times are passed as *naive* `DateTime.utc(...)` values — the
/// UTC flag is only a container for the digits. Instants are real UTC
/// `DateTime`s. Calendar days are `DateTime.utc(y, m, d)` at midnight.
///
/// Nothing here reads the device zone. Every call takes the Dynamic's zone.
abstract final class RelationshipDay {
  static const _hour = Duration(hours: 1);

  /// Resolve a local wall-clock time to an instant, handling DST correctly.
  ///
  /// - **Gap** (spring forward, the time does not exist): shift forward by
  ///   the actual gap length — Lord Howe Island shifts by 30 minutes.
  /// - **Fold** (fall back, the time happens twice): take the FIRST
  ///   occurrence, so a ritual fires once rather than twice.
  static DateTime resolve(DateTime local, tz.Location zone) {
    final lm = _naiveMillis(local);
    final candidates = <int>{
      zone.timeZone(lm - 14 * _hour.inMilliseconds).offset.inMilliseconds,
      zone.timeZone(lm).offset.inMilliseconds,
      zone.timeZone(lm + 14 * _hour.inMilliseconds).offset.inMilliseconds,
    };
    final valid = <int>[];
    for (final o in candidates) {
      final i = lm - o;
      if (zone.timeZone(i).offset.inMilliseconds == o) valid.add(i);
    }
    if (valid.isNotEmpty) {
      // One offset: the ordinary case. Two: a fold; the earlier instant is
      // the first pass through that wall-clock time.
      valid.sort();
      return DateTime.fromMillisecondsSinceEpoch(valid.first, isUtc: true);
    }
    // Gap. The offset in force just before the transition is the one at the
    // instant the *later* offset would have given; shifting by it lands
    // exactly one gap-length after the missing time.
    final after = candidates.reduce((a, b) => a > b ? a : b);
    final before = zone.timeZone(lm - after).offset.inMilliseconds;
    return DateTime.fromMillisecondsSinceEpoch(lm - before, isUtc: true);
  }

  /// Which relationship day does [instant] fall in?
  ///
  /// [boundaryMinutes] is minutes after local midnight at which the day turns
  /// over (0..1439). 0 means true midnight.
  static DateTime dayOf(DateTime instant, tz.Location zone, int boundaryMinutes) {
    _checkBoundary(boundaryMinutes);
    final local = tz.TZDateTime.from(instant.toUtc(), zone);
    final minutesIntoDay = local.hour * 60 + local.minute;
    final date = DateTime.utc(local.year, local.month, local.day);
    // Before the boundary means we are still in yesterday's relationship day.
    // Second precision matters at the exact boundary: 03:59:59 is before.
    final before = minutesIntoDay < boundaryMinutes;
    return before ? _addDays(date, -1) : date;
  }

  /// The half-open instant range `[start, end)` covering a relationship day.
  ///
  /// Length is NOT always 24 hours: a spring-forward day is 23 hours and a
  /// fall-back day is 25.
  static ({DateTime start, DateTime end}) rangeOf(
    DateTime day,
    tz.Location zone,
    int boundaryMinutes,
  ) {
    _checkBoundary(boundaryMinutes);
    final start = resolve(_atMinutes(day, boundaryMinutes), zone);
    final end = resolve(_atMinutes(_addDays(day, 1), boundaryMinutes), zone);
    return (start: start, end: end);
  }

  /// True when a whole calendar date does not exist in [zone]
  /// (e.g. Pacific/Apia 2011-12-30).
  static bool dateExists(DateTime day, tz.Location zone) {
    final startOfDay = tz.TZDateTime.from(
      resolve(DateTime.utc(day.year, day.month, day.day), zone),
      zone,
    );
    return startOfDay.year == day.year &&
        startOfDay.month == day.month &&
        startOfDay.day == day.day;
  }

  /// How long a relationship day actually lasts.
  static Duration lengthOf(DateTime day, tz.Location zone, int boundaryMinutes) {
    final r = rangeOf(day, zone, boundaryMinutes);
    return r.end.difference(r.start);
  }

  /// `yyyy-MM-dd`, the wire form the server uses for a relationship day.
  static String isoDay(DateTime day) =>
      '${day.year.toString().padLeft(4, '0')}-'
      '${day.month.toString().padLeft(2, '0')}-'
      '${day.day.toString().padLeft(2, '0')}';

  static DateTime parseIsoDay(String s) {
    final p = s.split('-').map(int.parse).toList(growable: false);
    return DateTime.utc(p[0], p[1], p[2]);
  }

  static void _checkBoundary(int m) {
    if (m < 0 || m > 1439) {
      throw ArgumentError.value(m, 'boundaryMinutes', 'must be 0..1439');
    }
  }

  static int _naiveMillis(DateTime local) => DateTime.utc(
        local.year,
        local.month,
        local.day,
        local.hour,
        local.minute,
        local.second,
        local.millisecond,
      ).millisecondsSinceEpoch;

  static DateTime _atMinutes(DateTime day, int minutes) =>
      DateTime.utc(day.year, day.month, day.day, minutes ~/ 60, minutes % 60);

  // Calendar arithmetic on a UTC-midnight date never crosses a DST edge, so
  // adding a whole day is exact.
  static DateTime _addDays(DateTime day, int n) =>
      DateTime.utc(day.year, day.month, day.day + n);
}
