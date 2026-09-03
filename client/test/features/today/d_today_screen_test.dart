import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:dsapp/app/providers.dart';
import 'package:dsapp/app/shell/ds_text_field.dart';
import 'package:dsapp/domain_client/models/d_note.dart';
import 'package:dsapp/domain_client/models/today_view.dart';
import 'package:dsapp/features/today/presentation/today_screen.dart';
import 'package:dsapp/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tz;

import '../../support/explore_fakes.dart';
import '../../support/phase3_fakes.dart';
import '../../support/today_fakes.dart';

Future<void> _pump(
  WidgetTester tester, {
  required FakeTodayRepository today,
  FakeTaskRepository? tasks,
  FakeDNoteRepository? notes,
  FakeExploreRepository? explore,
  FakeDynamicRepository? dynamics,
}) async {
  tester.view.physicalSize = const Size(390, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        todayRepositoryProvider.overrideWithValue(today),
        dynamicRepositoryProvider.overrideWithValue(dynamics ?? FakeDynamicRepository()),
        taskRepositoryProvider.overrideWithValue(tasks ?? FakeTaskRepository()),
        dNoteRepositoryProvider.overrideWithValue(notes ?? FakeDNoteRepository()),
        agreementsProvider.overrideWith((ref, id) async => const []),
        if (explore != null) exploreRepositoryProvider.overrideWithValue(explore),
      ],
      child: MaterialApp(
        theme: DsTheme.ritual(),
        locale: const Locale('zh'),
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        home: const TodayScreen(dynamicId: 'dyn-1'),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// The TextField under a DsTextField label.
Finder _field(WidgetTester tester, String label) => find.descendant(
      of: find.ancestor(of: find.text(label), matching: find.byType(DsTextField)),
      matching: find.byType(TextField),
    );

void main() {
  setUpAll(tz.initializeTimeZones);

  group('D 今天', () {
    testWidgets('nothing waiting says so', (tester) async {
      await _pump(tester, today: FakeTodayRepository(view: dView()));
      expect(find.text('等我处置的'), findsOneWidget);
      expect(find.text('没有等你的。'), findsOneWidget);
      expect(find.text('快速加一条'), findsOneWidget);
      expect(find.text('我要记得的'), findsOneWidget);
      expect(find.text('只有你看得到。'), findsOneWidget);
    });

    testWidgets('opening a row is the receipt; 看到了 posts a disposition', (tester) async {
      final repo = FakeTodayRepository(
        view: dView(items: [occ(id: 'o1', title: '整理床铺', outcome: Outcome.delivered)]),
        needsMeRows: [
          occ(
            id: 'o1',
            title: '整理床铺',
            outcome: Outcome.delivered,
            outcomeAt: DateTime.utc(2026, 9, 1, 1, 30),
            outcomeNote: '弄好了',
          ),
        ],
      );
      await _pump(tester, today: repo);

      expect(find.text('已交付 · 09:30'), findsOneWidget);
      expect(find.text('Nia：弄好了'), findsOneWidget);
      expect(find.text('1/1 已交付'), findsOneWidget);
      expect(repo.seen, isEmpty, reason: 'seeing the list is not seeing the item');

      await tester.tap(find.text('整理床铺'));
      await tester.pumpAndSettle();
      expect(repo.seen, ['o1']);

      await tester.tap(find.text('看到了'));
      await tester.pumpAndSettle();

      expect(repo.dispositions.single.$1, 'o1');
      expect(repo.dispositions.single.$2.disposition, Disposition.seen);
      expect(find.text('没有等你的。'), findsOneWidget);
    });

    testWidgets('很好 carries an optional line; 算了 posts at once', (tester) async {
      final repo = FakeTodayRepository(
        view: dView(),
        needsMeRows: [
          occ(id: 'a', title: '晚间日记', outcome: Outcome.delivered),
          occ(id: 'b', title: '喝水', outcome: Outcome.cantDo),
        ],
      );
      await _pump(tester, today: repo);

      await tester.tap(find.text('晚间日记'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('很好'));
      await tester.pumpAndSettle();
      await tester.enterText(_field(tester, '附一句（可不写）'), '写得认真');
      await tester.tap(find.text('送出'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('喝水'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('算了'));
      await tester.pumpAndSettle();

      expect(repo.dispositions.length, 2);
      expect(repo.dispositions[0].$2.disposition, Disposition.praised);
      expect(repo.dispositions[0].$2.note, '写得认真');
      expect(repo.dispositions[1].$2.disposition, Disposition.letGo);
    });

    testWidgets('a 409 puts the row back with the reason', (tester) async {
      final repo = FakeTodayRepository(
        view: dView(),
        needsMeRows: [occ(id: 'a', title: '晚间日记', outcome: Outcome.delivered)],
      )..nextError = conflict('OCCURRENCE_CHANGED');
      await _pump(tester, today: repo);

      await tester.tap(find.text('晚间日记'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('看到了'));
      await tester.pumpAndSettle();

      expect(find.text('晚间日记'), findsOneWidget);
      expect(find.text('这条在别处改过了。'), findsOneWidget);
      expect(repo.dispositions, isEmpty);
    });

    testWidgets('快速加一条 creates a one-off today or a daily task', (tester) async {
      final tasks = FakeTaskRepository();
      await _pump(tester, today: FakeTodayRepository(view: dView()), tasks: tasks);

      await tester.enterText(_field(tester, '做什么'), '倒垃圾');
      await tester.tap(find.text('加上'));
      await tester.pumpAndSettle();
      expect(find.text('加上了。'), findsOneWidget);

      await tester.enterText(_field(tester, '做什么'), '早安问候');
      await tester.tap(find.text('每天'));
      await tester.pump();
      await tester.tap(find.text('加上'));
      await tester.pumpAndSettle();

      expect(tasks.created.length, 2);
      expect(tasks.created[0].kind, 'one_off');
      expect(tasks.created[1].kind, 'recurring');
      expect(tasks.created[1].schedule, {'type': 'daily'});
    });

    testWidgets('我要记得的 lists, adds, finishes and deletes private notes', (tester) async {
      final notes = FakeDNoteRepository(notes: [
        DNote(id: 'n1', body: '问她周末想去哪', createdAt: DateTime.utc(2026, 9, 1)),
      ]);
      await _pump(tester, today: FakeTodayRepository(view: dView()), notes: notes);
      expect(find.text('问她周末想去哪'), findsOneWidget);

      await tester.enterText(_field(tester, '记一句'), '买她要的茶');
      await tester.tap(find.text('记下'));
      await tester.pumpAndSettle();
      expect(find.text('买她要的茶'), findsOneWidget);
      expect(notes.notes.length, 2);

      await tester.tap(find.text('好了').first);
      await tester.pumpAndSettle();
      expect(notes.marked, ['n1']);
      expect(find.text('问她周末想去哪'), findsNothing);

      await tester.tap(find.text('删掉').first);
      await tester.pumpAndSettle();
      expect(notes.deleted, ['n-2']);
    });

    testWidgets('「今晚要什么？」 draws a card and its verbs act', (tester) async {
      final explore = FakeExploreRepository();
      await _pump(tester, today: FakeTodayRepository(view: dView()), explore: explore);

      expect(find.text('今晚要什么？'), findsOneWidget);
      await tester.tap(find.text('今晚要什么？'));
      await tester.pumpAndSettle();

      expect(explore.draws, 1);
      expect(find.text('今晚的三句话'), findsOneWidget);
      expect(find.text('再抽一张'), findsOneWidget);

      await tester.tap(find.text('加到今天'));
      await tester.pumpAndSettle();
      expect(explore.acts, [('c-1', 'add_today')]);
      expect(find.text('记上了。'), findsOneWidget);
    });
  });
}
