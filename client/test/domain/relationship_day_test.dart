import 'package:dsapp/domain/relationship_day.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// The backend's `RelationshipDayTest` vectors, ported verbatim. Both halves
/// of the one algorithm must agree on every one of these (invariant 7).
void main() {
  setUpAll(tzdata.initializeTimeZones);

  late tz.Location ny;
  late tz.Location shanghai;
  late tz.Location london;
  late tz.Location lordHowe;
  late tz.Location phoenix; // no DST

  setUp(() {
    ny = tz.getLocation('America/New_York');
    shanghai = tz.getLocation('Asia/Shanghai');
    london = tz.getLocation('Europe/London');
    lordHowe = tz.getLocation('Australia/Lord_Howe');
    phoenix = tz.getLocation('America/Phoenix');
  });

  // A plain UTC DateTime, so equality is by instant and not by subclass.
  DateTime local(tz.Location z, int y, int mo, int d, int h, int mi) =>
      DateTime.fromMillisecondsSinceEpoch(
        tz.TZDateTime(z, y, mo, d, h, mi).millisecondsSinceEpoch,
        isUtc: true,
      );
  DateTime date(int y, int m, int d) => DateTime.utc(y, m, d);
  DateTime wall(int y, int mo, int d, int h, int mi) => DateTime.utc(y, mo, d, h, mi);

  group('day boundary', () {
    test('with a 4am boundary, 2am belongs to the PREVIOUS relationship day', () {
      final at2am = local(shanghai, 2026, 3, 4, 2, 0);
      expect(RelationshipDay.dayOf(at2am, shanghai, 240), date(2026, 3, 3));
    });

    test('exactly at the boundary the new day begins', () {
      final at4am = local(shanghai, 2026, 3, 4, 4, 0);
      expect(RelationshipDay.dayOf(at4am, shanghai, 240), date(2026, 3, 4));
    });

    test('a zero boundary is plain midnight', () {
      final justAfter = local(shanghai, 2026, 3, 4, 0, 1);
      expect(RelationshipDay.dayOf(justAfter, shanghai, 0), date(2026, 3, 4));
    });
  });

  group('DST gap (spring forward)', () {
    test('a local time inside the spring gap shifts forward by the real gap', () {
      // 2026-03-08 02:30 does not exist in New York.
      final resolved = RelationshipDay.resolve(wall(2026, 3, 8, 2, 30), ny);
      expect(
        resolved,
        local(ny, 2026, 3, 8, 3, 30),
        reason: 'a nonexistent local time must land at 03:30 EDT, not be silently dropped',
      );
    });

    test('Lord Howe has a THIRTY minute gap - never hardcode one hour', () {
      // 2026-10-04 02:15 does not exist; the gap is 30 minutes, not 60.
      final resolved = RelationshipDay.resolve(wall(2026, 10, 4, 2, 15), lordHowe);
      expect(resolved, local(lordHowe, 2026, 10, 4, 2, 45));
    });

    test('a day boundary inside the gap still yields a usable day start', () {
      final range = RelationshipDay.rangeOf(date(2026, 3, 8), ny, 150); // 02:30
      expect(range.start, local(ny, 2026, 3, 8, 3, 30));
    });
  });

  group('DST fold (fall back)', () {
    test('an ambiguous local time takes the FIRST occurrence, so a ritual fires once', () {
      // 2026-11-01 01:30 happens twice in New York.
      final resolved = RelationshipDay.resolve(wall(2026, 11, 1, 1, 30), ny);
      // The first pass is still EDT (-04:00) => 05:30Z.
      expect(resolved, DateTime.parse('2026-11-01T05:30:00Z'));
    });
  });

  group('day length', () {
    test('a spring-forward relationship day is 23 hours', () {
      // The transition is at 02:00 on 03-08. With a 04:00 boundary that moment
      // sits inside the day that STARTED on 03-07, so 03-07 is the short one.
      expect(RelationshipDay.lengthOf(date(2026, 3, 7), ny, 240), const Duration(hours: 23));
      // At a midnight boundary the short day is 03-08 itself.
      expect(RelationshipDay.lengthOf(date(2026, 3, 8), ny, 0), const Duration(hours: 23));
    });

    test('a fall-back relationship day is 25 hours', () {
      expect(RelationshipDay.lengthOf(date(2026, 10, 31), ny, 240), const Duration(hours: 25));
      expect(RelationshipDay.lengthOf(date(2026, 11, 1), ny, 0), const Duration(hours: 25));
    });

    test('an ordinary day is 24 hours', () {
      expect(RelationshipDay.lengthOf(date(2026, 6, 15), ny, 240), const Duration(hours: 24));
    });
  });

  group('wall-clock preservation', () {
    test('a ritual at 2030 stays at 2030 local across DST, though its UTC time moves', () {
      final before = RelationshipDay.resolve(wall(2026, 3, 1, 20, 30), ny);
      final after = RelationshipDay.resolve(wall(2026, 3, 15, 20, 30), ny);

      // Same wall clock for the human...
      expect(tz.TZDateTime.from(before, ny).hour, 20);
      expect(tz.TZDateTime.from(after, ny).hour, 20);
      // ...but a different UTC instant.
      expect(before.toUtc().hour - after.toUtc().hour, 1);
    });
  });

  group('zones without DST', () {
    test('a zone without DST behaves identically all year', () {
      for (final month in [1, 3, 6, 11]) {
        expect(
          RelationshipDay.lengthOf(date(2026, month, 15), phoenix, 240),
          const Duration(hours: 24),
        );
      }
    });
  });

  group('skipped calendar dates', () {
    test('a date that does not exist in a zone is detectable', () {
      // Samoa skipped 2011-12-30 entirely when it crossed the date line.
      final apia = tz.getLocation('Pacific/Apia');
      expect(RelationshipDay.dateExists(date(2011, 12, 30), apia), isFalse);
      expect(RelationshipDay.dateExists(date(2011, 12, 31), apia), isTrue);
    });
  });

  group('environment independence', () {
    test('results never depend on the device timezone', () {
      // Dart has no mutable default zone; the equivalent guarantee is that
      // the same instant expressed in different local containers classifies
      // identically, because only the Dynamic's zone is consulted.
      final instant = DateTime.parse('2026-03-04T18:00:00Z');
      final seen = <DateTime>{
        RelationshipDay.dayOf(instant, ny, 240),
        RelationshipDay.dayOf(instant.toLocal(), ny, 240),
        RelationshipDay.dayOf(instant.toUtc(), ny, 240),
      };
      expect(seen.length, 1, reason: 'the device zone must never influence the result');
    });
  });

  group('the required timezone matrix', () {
    test('LA, NY, London and a non-DST zone all resolve consistently', () {
      final zones = [tz.getLocation('America/Los_Angeles'), ny, london, phoenix];
      for (final zone in zones) {
        for (final boundary in [0, 240]) {
          final day = date(2026, 6, 15);
          final range = RelationshipDay.rangeOf(day, zone, boundary);
          expect(range.start.isBefore(range.end), isTrue,
              reason: '${zone.name}/$boundary produced an empty day');
          // A moment inside the range must classify back to the same day.
          final mid = range.start.add(const Duration(hours: 6));
          expect(RelationshipDay.dayOf(mid, zone, boundary), day,
              reason: '${zone.name}/$boundary');
        }
      }
    });
  });

  group('wire form', () {
    test('round-trips yyyy-MM-dd', () {
      expect(RelationshipDay.isoDay(date(2026, 3, 4)), '2026-03-04');
      expect(RelationshipDay.parseIsoDay('2026-03-04'), date(2026, 3, 4));
    });
  });
}
