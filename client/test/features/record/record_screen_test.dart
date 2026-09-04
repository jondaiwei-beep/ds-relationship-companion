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

import '../../support/phase3_fakes.dart';
import '../../support/record_fakes.dart';
import '../../support/today_fakes.dart';

Future<void> _pump(
  WidgetTester tester, {
  required FakeRecordRepository record,
  required FakeTodayRepository today,
  FakeDynamicRepository? dynamics,
  void Function(String)? onOpenDay,
}) async {
  tester.view.physicalSize = const Size(390, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        todayRepositoryProvider.overrideWithValue(today),
        recordRepositoryProvider.overrideWithValue(record),
        dynamicRepositoryProvider.overrideWithValue(dynamics ?? FakeDynamicRepository()),
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

Finder _dot(String iso) => find.byKey(ValueKey('dot-$iso'));

void main() {
  setUpAll(tz.initializeTimeZones);

  testWidgets('the day is the anchor, today has one line, and the grid marks days with dots', (tester) async {
    final record = FakeRecordRepository(
      cells: const [
        MonthCell(day: '2026-09-02', due: 3, delivered: 2, undisposed: 1),
        MonthCell(day: '2026-09-05', due: 1, delivered: 1, comments: 2),
        MonthCell(day: '2026-09-15', due: 2, delivered: 2, undisposed: 1),
      ],
      factsView: const FactsView(from: '2026-09-01', to: '2026-09-30', delivered: 2, comments: 1),
    );
    final today = FakeTodayRepository(view: sView().copyWith(day: '2026-09-15'));
    await _pump(tester, record: record, today: today);

    // §1: eyebrow + the day in Cormorant; days together underneath, no streak (D-31).
    expect(find.text('记录 · 星期二'), findsOneWidget);
    expect(find.text('9月15日'), findsOneWidget);
    expect(find.text('在一起 40 天'), findsOneWidget);
    expect(find.textContaining('连续'), findsNothing);
    expect(record.monthReads, ['2026-09']);

    // One line on today from the month data: 2 due, both delivered, one still
    // waiting on the D → one answered.
    expect(find.text('要做 2 项 · 已回应 1 项'), findsOneWidget);
    expect(find.byKey(const ValueKey('open-today')), findsOneWidget);

    // Monday first: 1 Sep 2026 is a Tuesday, so the 1st sits in the second column.
    final x1 = tester.getCenter(find.byKey(const ValueKey('cell-2026-09-01'))).dx;
    final x7 = tester.getCenter(find.byKey(const ValueKey('cell-2026-09-07'))).dx;
    final x8 = tester.getCenter(find.byKey(const ValueKey('cell-2026-09-08'))).dx;
    expect(x1, closeTo(x8, 1), reason: 'the 1st and the 8th are both Tuesdays');
    expect(x7, lessThan(x1), reason: 'Monday the 7th starts the row');

    // No counts inside cells; a dot under days with something on them.
    expect(find.text('2/3'), findsNothing);
    expect(find.text('1/1'), findsNothing);
    expect(_dot('2026-09-02'), findsOneWidget);
    expect(_dot('2026-09-05'), findsOneWidget);
    expect(_dot('2026-09-03'), findsNothing);
    final waiting = tester.widget<Container>(_dot('2026-09-02'));
    final settled = tester.widget<Container>(_dot('2026-09-05'));
    expect((waiting.decoration as BoxDecoration).color, DsColors.relationshipPresence);
    expect((settled.decoration as BoxDecoration).color, isNot(DsColors.relationshipPresence));

    // Today is outlined, the future is not tappable.
    expect(_tile(tester, '2026-09-15').isToday, isTrue);
    expect(_tile(tester, '2026-09-16').onTap, isNull);
    expect(_tile(tester, '2026-09-14').onTap, isNotNull);

    // Facts: week (Mon 14 – Sun 20) and the visible month; only non-zero rows.
    expect(record.factsReads, containsAll([('2026-09-14', '2026-09-20'), ('2026-09-01', '2026-09-30')]));
    expect(find.text('本周'), findsOneWidget);
    expect(find.text('交付'), findsOneWidget);
    expect(find.text('留言'), findsOneWidget);
    expect(find.text('晚交'), findsNothing);
    expect(find.text('这周还没有记录。'), findsNothing);

    // Export lives at the very bottom, as a quiet word.
    await tester.scrollUntilVisible(find.byKey(const ValueKey('export-record')), 200);
    expect(find.text('导出记录'), findsOneWidget);
  });

  testWidgets('nothing on today and nothing this week both say so in one line', (tester) async {
    final record = FakeRecordRepository();
    final today = FakeTodayRepository(view: sView().copyWith(day: '2026-09-15'));
    await _pump(tester, record: record, today: today);

    expect(find.text('今天没有要做的事。'), findsOneWidget);
    expect(find.text('这周还没有记录。'), findsOneWidget);
    expect(find.text('本周'), findsNothing);
    expect(find.text('交付'), findsNothing);
  });

  testWidgets('alone: the partner has not joined, so days together is not shown', (tester) async {
    final record = FakeRecordRepository();
    final today = FakeTodayRepository(view: sView().copyWith(day: '2026-09-15'));
    final solo = pairDetail().copyWith(members: [pairDetail().members.first]);
    await _pump(tester, record: record, today: today, dynamics: FakeDynamicRepository(detail: solo));

    expect(find.text('9月15日'), findsOneWidget);
    expect(find.textContaining('在一起'), findsNothing);
    expect(find.byKey(const ValueKey('open-today')), findsOneWidget);
  });

  testWidgets('tapping a day or "open this day" opens it; arrows move by month and stop at today',
      (tester) async {
    String? opened;
    final record = FakeRecordRepository();
    final today = FakeTodayRepository(view: sView().copyWith(day: '2026-09-15'));
    await _pump(tester, record: record, today: today, onOpenDay: (d) => opened = d);

    await tester.tap(find.byKey(const ValueKey('open-today')));
    expect(opened, '2026-09-15');

    await tester.tap(find.byKey(const ValueKey('cell-2026-09-03')));
    expect(opened, '2026-09-03');

    await tester.tap(find.bySemanticsLabel('上个月'));
    await tester.pumpAndSettle();
    expect(record.monthReads, ['2026-09', '2026-08']);
    expect(find.byKey(const ValueKey('cell-2026-08-31')), findsOneWidget);
    // Today's line still speaks of today while another month is open.
    expect(find.text('今天没有要做的事。'), findsOneWidget);

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
