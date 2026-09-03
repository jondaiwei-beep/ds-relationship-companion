import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:dsapp/app/providers.dart';
import 'package:dsapp/domain_client/models/explore.dart';
import 'package:dsapp/domain_client/models/today_view.dart';
import 'package:dsapp/features/explore/presentation/explore_screen.dart';
import 'package:dsapp/features/explore/presentation/starter_pack_screen.dart';
import 'package:dsapp/features/rules/presentation/rules_screen.dart';
import 'package:dsapp/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tzdata;

import '../../support/explore_fakes.dart';
import '../../support/phase3_fakes.dart';
import '../../support/today_fakes.dart';

Future<FakeExploreRepository> _pump(
  WidgetTester tester, {
  required TodayView view,
  required Widget screen,
  FakeExploreRepository? explore,
  FakeRuleRepository? rules,
}) async {
  tester.view.physicalSize = const Size(390, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  final repo = explore ?? FakeExploreRepository(compare: fakeCompare);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        todayRepositoryProvider.overrideWithValue(FakeTodayRepository(view: view)),
        exploreRepositoryProvider.overrideWithValue(repo),
        ruleRepositoryProvider.overrideWithValue(rules ?? FakeRuleRepository()),
        taskRepositoryProvider.overrideWithValue(FakeTaskDefinitions()),
        dynamicRepositoryProvider.overrideWithValue(FakeDynamicRepository()),
        pointsRepositoryProvider.overrideWithValue(FakePointsRepository()),
      ],
      child: MaterialApp(
        theme: DsTheme.ritual(),
        locale: const Locale('zh'),
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        home: screen,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return repo;
}

void main() {
  setUpAll(tzdata.initializeTimeZones);

  group('偏好', () {
    testWidgets('items render grouped; a tap autosaves the answer', (tester) async {
      final repo = await _pump(tester, view: dView(), screen: const ExploreScreen(dynamicId: 'dyn-1'));

      expect(find.text('服务与仪式'), findsOneWidget);
      expect(find.text('感官'), findsOneWidget);
      expect(find.text('早安问安'), findsOneWidget);
      expect(find.text('蒙眼'), findsOneWidget);

      // Four words per item, none more.
      final row = find.byKey(const ValueKey('pref-p-1'));
      await tester.tap(find.descendant(of: row, matching: find.text('想要')));
      await tester.pumpAndSettle();

      expect(repo.answers, [('p-1', 'want')]);

      await tester.tap(find.descendant(of: row, matching: find.text('想聊')));
      await tester.pumpAndSettle();
      expect(repo.answers, [('p-1', 'want'), ('p-1', 'talk')]);
    });
  });

  group('对照', () {
    testWidgets('「不要」 shows as 这条不做 with no one attached', (tester) async {
      await _pump(
        tester,
        view: sView(),
        screen: const ExploreScreen(dynamicId: 'dyn-1', initialSection: ExploreSection.compare),
      );

      expect(find.text('都想要'), findsOneWidget);
      expect(find.text('早安问安'), findsOneWidget);
      expect(find.text('一个想要、一个可以'), findsOneWidget);
      expect(find.text('有人想聊'), findsOneWidget);
      expect(find.text('这条不做'), findsOneWidget);
      expect(find.text('蒙眼'), findsOneWidget);

      // No side marker leaks (wantSide is never rendered), and the propose
      // verb sits on the three shared rows only — never on the 不要 row.
      expect(find.text('D'), findsNothing);
      expect(find.text('S'), findsNothing);
      expect(find.text('提议给 Mara'), findsNWidgets(3));
      final notDoingRow = find.ancestor(of: find.text('蒙眼'), matching: find.byType(Row)).first;
      expect(find.descendant(of: notDoingRow, matching: find.text('提议给 Mara')), findsNothing);
    });

    testWidgets('until the partner answers, nothing of theirs shows', (tester) async {
      await _pump(
        tester,
        view: dView(),
        explore: FakeExploreRepository(compare: const CompareView(partnerAnswered: false)),
        screen: const ExploreScreen(dynamicId: 'dyn-1', initialSection: ExploreSection.compare),
      );
      expect(find.text('Nia 还没答。你的答案已经存好。'), findsOneWidget);
      expect(find.text('这条不做'), findsNothing);
    });
  });

  group('灵感卡', () {
    testWidgets('D opens a card and acts; the verb reaches the server', (tester) async {
      final repo = await _pump(
        tester,
        view: dView(),
        screen: const ExploreScreen(dynamicId: 'dyn-1', initialSection: ExploreSection.cards),
      );

      expect(find.text('今晚的三句话'), findsOneWidget);
      expect(find.text('试过了·再来'), findsOneWidget); // tried card sinks with its mark

      await tester.tap(find.text('今晚的三句话'));
      await tester.pumpAndSettle();
      expect(find.text('睡前让对方说三句今天做到的事。'), findsOneWidget);
      expect(find.text('加到今天'), findsOneWidget);
      expect(find.text('加到规矩'), findsOneWidget);
      expect(find.text('存起来'), findsOneWidget);
      expect(find.textContaining('提议给'), findsNothing);

      await tester.tap(find.text('加到规矩'));
      await tester.pumpAndSettle();
      expect(repo.acts, [('c-1', 'add_rule')]);
      expect(find.text('记上了。'), findsOneWidget);
    });

    testWidgets('s gets 提议 and 存起来, not D verbs', (tester) async {
      await _pump(
        tester,
        view: sView(),
        screen: const ExploreScreen(dynamicId: 'dyn-1', initialSection: ExploreSection.cards),
      );
      await tester.tap(find.text('今晚的三句话'));
      await tester.pumpAndSettle();
      expect(find.text('提议给 Mara'), findsOneWidget);
      expect(find.text('存起来'), findsOneWidget);
      expect(find.text('加到规矩'), findsNothing);
    });
  });

  group('规矩', () {
    testWidgets('底线 lists the compare 不要 titles, unattributed', (tester) async {
      await _pump(tester, view: dView(), screen: const RulesScreen(dynamicId: 'dyn-1'));
      await tester.scrollUntilVisible(find.text('底线与安全词'), 400);
      expect(find.text('蒙眼'), findsOneWidget);
      expect(find.text('这条不做'), findsOneWidget);
      expect(find.text('两人在比对里标「不要」的项，会列在这里。'), findsNothing);
    });
  });

  group('起步包', () {
    testWidgets('pick, drop a line, reword one, apply exactly what is left', (tester) async {
      final repo = await _pump(
        tester,
        view: dView(),
        screen: const StarterPackScreen(dynamicId: 'dyn-1'),
      );
      expect(find.text('日常问安'), findsOneWidget);
      expect(find.text('2 条任务 · 1 条规矩 · 1 条奖励'), findsOneWidget);

      await tester.tap(find.text('日常问安'));
      await tester.pumpAndSettle();
      expect(find.text('早安汇报'), findsOneWidget);
      expect(find.text('晚安汇报'), findsOneWidget);

      // Drop the evening report.
      await tester.tap(find.descendant(of: find.byKey(const ValueKey('task-1')), matching: find.bySemanticsLabel('撤下')));
      await tester.pumpAndSettle();
      expect(find.text('晚安汇报'), findsNothing);

      // Reword the rule.
      await tester.tap(find.text('称呼要用「主人」'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '称呼要用「先生」');
      await tester.tap(find.text('好'));
      await tester.pumpAndSettle();
      expect(find.text('称呼要用「先生」'), findsOneWidget);

      await tester.tap(find.text('启用这一套'));
      await tester.pumpAndSettle();

      expect(repo.applied.length, 1);
      final (packId, draft) = repo.applied.single;
      expect(packId, 'daily-greeting');
      expect(draft.tasks.map((t) => t.title), ['早安汇报']);
      expect(draft.tasks.single.schedule, {'type': 'daily'});
      expect(draft.rules.map((r) => r.title), ['称呼要用「先生」']);
      expect(draft.rewards.single.cost, 20);
      expect(find.text('建好了，都在「规矩」里。'), findsOneWidget);
    });
  });
}
