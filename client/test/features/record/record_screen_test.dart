import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:dsapp/app/providers.dart';
import 'package:dsapp/domain_client/models/record.dart';
import 'package:dsapp/features/record/presentation/record_screen.dart';
import 'package:dsapp/features/record/presentation/widgets/month_grid.dart';
import 'package:dsapp/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tz;

import '../../support/record_fakes.dart';
import '../../support/today_fakes.dart';

Future<void> _pump(
  WidgetTester tester, {
  required FakeRecordRepository record,
  required FakeTodayRepository today,
  void Function(String)? onOpenDay,
}) async {
  tester.view.physicalSize = const Size(390, 1200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        todayRepositoryProvider.overrideWithValue(today),
        recordRepositoryProvider.overrideWithValue(record),
      ],
      child: MaterialApp(
        theme: DsTheme.ritual(),
        locale: const Locale('zh'),
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        home: RecordScreen(dynamicId: 'dyn-1', onOpenDay: onOpenDay),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

MonthCellTile _tile(WidgetTester tester, String iso) => tester.widget<MonthCellTile>(
      find.ancestor(of: find.byKey(ValueKey('cell-$iso')), matching: find.byType(MonthCellTile)),
    );

void main() {
  setUpAll(tz.initializeTimeZones);

  testWidgets('the month grid shows delivered/due, a dot for undisposed and a mark for comments',
      (tester) async {
    final record = FakeRecordRepository(
      cells: const [
        MonthCell(day: '2026-09-02', due: 3, delivered: 2, undisposed: 1),
        MonthCell(day: '2026-09-05', due: 1, delivered: 1, comments: 2),
      ],
    );
    final today = FakeTodayRepository(view: sView().copyWith(day: '2026-09-15'));
    await _pump(tester, record: record, today: today);

    // D-27: two numbers, no verdict.
    expect(find.text('在一起 40 天 · 连续 6 天'), findsOneWidget);
    expect(record.monthReads, ['2026-09']);

    // Monday first: 1 Sep 2026 is a Tuesday, so the 1st sits in the second column.
    final x1 = tester.getCenter(find.byKey(const ValueKey('cell-2026-09-01'))).dx;
    final x7 = tester.getCenter(find.byKey(const ValueKey('cell-2026-09-07'))).dx;
    final x8 = tester.getCenter(find.byKey(const ValueKey('cell-2026-09-08'))).dx;
    expect(x1, closeTo(x8, 1), reason: 'the 1st and the 8th are both Tuesdays');
    expect(x7, lessThan(x1), reason: 'Monday the 7th starts the row');

    expect(find.text('2/3'), findsOneWidget);
    expect(find.text('1/1'), findsOneWidget);
    final undisposed = find.descendant(
      of: find.byKey(const ValueKey('cell-2026-09-02')),
      matching: find.byIcon(Icons.circle),
    );
    expect(undisposed, findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('cell-2026-09-05')),
        matching: find.byIcon(Icons.mode_comment_outlined),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('cell-2026-09-05')),
        matching: find.byIcon(Icons.circle),
      ),
      findsNothing,
    );

    // Today is marked, the future is not tappable.
    expect(_tile(tester, '2026-09-15').isToday, isTrue);
    expect(_tile(tester, '2026-09-16').onTap, isNull);
    expect(_tile(tester, '2026-09-14').onTap, isNotNull);

    // Facts: week (Mon 14 – Sun 20) and the visible month, numbers only.
    expect(record.factsReads, containsAll([('2026-09-14', '2026-09-20'), ('2026-09-01', '2026-09-30')]));
    expect(find.text('本周'), findsOneWidget);
    expect(find.text('交付'), findsOneWidget);
  });

  testWidgets('tapping a day opens it; arrows move by month and stop at today', (tester) async {
    String? opened;
    final record = FakeRecordRepository();
    final today = FakeTodayRepository(view: sView().copyWith(day: '2026-09-15'));
    await _pump(tester, record: record, today: today, onOpenDay: (d) => opened = d);

    await tester.tap(find.byKey(const ValueKey('cell-2026-09-03')));
    expect(opened, '2026-09-03');

    await tester.tap(find.bySemanticsLabel('上个月'));
    await tester.pumpAndSettle();
    expect(record.monthReads, ['2026-09', '2026-08']);
    expect(find.byKey(const ValueKey('cell-2026-08-31')), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('下个月'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('cell-2026-09-30')), findsOneWidget);
    // October has not begun: the step is inert.
    final next = tester.widget<InkWell>(
      find.descendant(of: find.bySemanticsLabel('下个月'), matching: find.byType(InkWell)),
    );
    expect(next.onTap, isNull);
  });
}
