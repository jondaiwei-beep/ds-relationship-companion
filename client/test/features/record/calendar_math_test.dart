import 'package:dsapp/features/record/application/calendar_math.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a month knows its bounds, its length and where Monday-first starts', () {
    const m = YearMonth(2026, 9); // 1 Sep 2026 is a Tuesday
    expect(m.wire, '2026-09');
    expect(m.length, 30);
    expect(m.firstIsoDay, '2026-09-01');
    expect(m.lastIsoDay, '2026-09-30');
    expect(m.leadingBlanks, 1);
    expect(m.isoDayOf(3), '2026-09-03');
    expect(m.contains('2026-09-30'), isTrue);
    expect(m.contains('2026-10-01'), isFalse);
  });

  test('stepping wraps the year', () {
    expect(const YearMonth(2026, 12).next, const YearMonth(2027, 1));
    expect(const YearMonth(2026, 1).previous, const YearMonth(2025, 12));
    expect(YearMonth.ofIsoDay('2026-02-14'), const YearMonth(2026, 2));
    expect(const YearMonth(2024, 2).length, 29);
  });

  test('the week around a day runs Monday to Sunday', () {
    expect(weekAround('2026-09-03'), (from: '2026-08-31', to: '2026-09-06'));
    expect(weekAround('2026-08-31'), (from: '2026-08-31', to: '2026-09-06'));
    expect(weekAround('2026-09-06'), (from: '2026-08-31', to: '2026-09-06'));
  });
}
