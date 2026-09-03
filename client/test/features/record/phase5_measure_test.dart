import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:dsapp/app/providers.dart';
import 'package:dsapp/domain_client/models/record.dart';
import 'package:dsapp/domain_client/models/task.dart';
import 'package:dsapp/domain_client/models/today_view.dart';
import 'package:dsapp/features/dynamic/application/dynamic_providers.dart' show dynamicViewerIdProvider;
import 'package:dsapp/features/record/application/record_export.dart';
import 'package:dsapp/features/record/application/record_providers.dart';
import 'package:dsapp/features/record/presentation/day_screen.dart';
import 'package:dsapp/features/record/presentation/record_screen.dart';
import 'package:dsapp/features/record/presentation/series_screen.dart';
import 'package:dsapp/features/record/presentation/widgets/series_chart.dart';
import 'package:dsapp/features/today/presentation/today_screen.dart';
import 'package:dsapp/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tz;

import '../../support/record_fakes.dart';
import '../../support/today_fakes.dart';

Future<void> _pump(
  WidgetTester tester,
  Widget home, {
  required FakeTodayRepository today,
  FakeRecordRepository? record,
  ExportSink? sink,
  List<TaskView>? measureTasks,
}) async {
  tester.view.physicalSize = const Size(390, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        todayRepositoryProvider.overrideWithValue(today),
        recordRepositoryProvider.overrideWithValue(record ?? FakeRecordRepository()),
        taskRepositoryProvider.overrideWithValue(FakeTaskRepository()),
        dynamicViewerIdProvider.overrideWithValue('u-me'),
        agreementsProvider.overrideWith((ref, id) async => const []),
        if (sink != null) exportSinkProvider.overrideWithValue(sink),
        if (measureTasks != null) measureTasksProvider.overrideWith((ref, id) async => measureTasks),
      ],
      child: MaterialApp(
        theme: DsTheme.ritual(),
        locale: const Locale('zh'),
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        home: home,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(tz.initializeTimeZones);

  testWidgets('delivering a measure task asks for the number and sends it as value', (tester) async {
    final repo = FakeTodayRepository(
      view: sView(items: [occ(id: 'm1', title: '体重', kind: 'measure', unit: 'kg')]),
    );
    repo.onOutcome = (view, id, change) => view.copyWith(
          items: [
            for (final o in view.items)
              if (o.id == id) o.copyWith(outcome: change.outcome, value: change.value) else o,
          ],
        );
    await _pump(tester, const TodayScreen(dynamicId: 'dyn-1'), today: repo);

    await tester.tap(find.text('体重'));
    await tester.pumpAndSettle();
    expect(find.text('数值（kg）'), findsOneWidget);

    await tester.enterText(find.byKey(const ValueKey('measure-field')), '72.5');
    await tester.pumpAndSettle();
    await tester.tap(find.text('送出'));
    await tester.pumpAndSettle();

    expect(repo.outcomes.single.$1, 'm1');
    expect(repo.outcomes.single.$2.outcome, Outcome.delivered);
    expect(repo.outcomes.single.$2.value, 72.5);
    expect(repo.outcomes.single.$2.toJson()['value'], 72.5);
    expect(find.text('已送到 · 等 Mara 看 · 72.5 kg'), findsOneWidget);
  });

  testWidgets('a delivered measure entry in the day shows the number and a way to its curve', (tester) async {
    final t = DateTime.utc(2026, 9, 1);
    final record = FakeRecordRepository(
      days: {
        '2026-09-01': DayView(
          day: '2026-09-01',
          timeline: [
            outcomeAt(t.add(const Duration(hours: 1)), occ: 'm1', title: '体重', to: 'delivered', value: 72, unit: 'kg'),
          ],
        ),
      },
    );
    String? opened;
    await _pump(
      tester,
      DayScreen(dynamicId: 'dyn-1', day: '2026-09-01', onOpenSeries: (id, _) => opened = id),
      today: FakeTodayRepository(view: sView()),
      record: record,
    );
    expect(find.text('72 kg'), findsOneWidget);
    await tester.tap(find.text('曲线'));
    await tester.pumpAndSettle();
    expect(opened, 't-m1');
  });

  testWidgets('the series screen draws the last 30 days and names the range', (tester) async {
    final record = FakeRecordRepository()
      ..series_ = {
        't-1': const SeriesView(
          taskId: 't-1',
          unit: 'kg',
          points: [
            SeriesPoint(day: '2026-08-20', value: 74),
            SeriesPoint(day: '2026-08-25', value: 73.2),
            SeriesPoint(day: '2026-09-01', value: 72.5),
          ],
        ),
      };
    await _pump(
      tester,
      const SeriesScreen(dynamicId: 'dyn-1', taskId: 't-1', title: '体重'),
      today: FakeTodayRepository(view: sView()),
      record: record,
    );
    expect(record.seriesReads.single, ('t-1', '2026-08-03', '2026-09-01'));
    expect(find.text('体重'), findsOneWidget);
    expect(find.byKey(const ValueKey('series-chart')), findsOneWidget);
    final paint = tester.widget<CustomPaint>(
      find.descendant(of: find.byKey(const ValueKey('series-chart')), matching: find.byType(CustomPaint)),
    );
    expect((paint.painter as SeriesPainter).points, hasLength(3));
    expect(find.text('最低 72.5 kg'), findsOneWidget);
    expect(find.text('最高 74 kg'), findsOneWidget);
    expect(find.text('记了 3 天'), findsOneWidget);
  });

  testWidgets('导出记录 defaults to the last 90 days, fetches the CSV and hands it on', (tester) async {
    final record = FakeRecordRepository()..csv = 'day,task_title\n2026-09-01,体重\n';
    final shared = <(String, String)>[];
    String? openedSeries;
    await _pump(
      tester,
      RecordScreen(dynamicId: 'dyn-1', onOpenSeries: (id, _) => openedSeries = id),
      today: FakeTodayRepository(view: sView()),
      record: record,
      sink: (name, csv) async => shared.add((name, csv)),
      measureTasks: const [
        TaskView(id: 't-1', title: '体重', kind: 'measure', proof: 'check', unit: 'kg', createdBy: 'u', status: 'active'),
      ],
    );

    await tester.tap(find.byKey(const ValueKey('export-record')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('最近 90 天'));
    await tester.pumpAndSettle();

    expect(record.exports.single, ('2026-06-04', '2026-09-01'));
    expect(shared.single.$1, 'record-2026-06-04-2026-09-01.csv');
    expect(shared.single.$2, startsWith('day,task_title'));
    expect(find.text('已导出 record-2026-06-04-2026-09-01.csv'), findsOneWidget);

    // The measure task is listed at the bottom, a way into its curve.
    await tester.scrollUntilVisible(find.byKey(const ValueKey('measure-t-1')), 200);
    await tester.tap(find.byKey(const ValueKey('measure-t-1')));
    expect(openedSeries, 't-1');
  });
}
