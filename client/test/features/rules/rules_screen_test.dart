import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:dsapp/app/providers.dart';
import 'package:dsapp/app/shell/ds_primary_button.dart';
import 'package:dsapp/domain_client/models/points.dart';
import 'package:dsapp/domain_client/models/rule.dart';
import 'package:dsapp/domain_client/models/task.dart';
import 'package:dsapp/domain_client/models/today_view.dart';
import 'package:dsapp/features/rules/presentation/rules_screen.dart';
import 'package:dsapp/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tzdata;

import '../../support/explore_fakes.dart';
import '../../support/phase3_fakes.dart';
import '../../support/today_fakes.dart';

const _rules = [
  RuleView(id: 'r-1', title: '进门先跪', group: 'protocol', createdBy: 'u-d', status: 'active'),
  RuleView(id: 'r-2', title: '早安短信', group: 'ritual', createdBy: 'u-d', status: 'active'),
  RuleView(id: 'r-3', title: '晚上十点前睡', group: 'restriction', createdBy: 'u-s', status: 'proposed'),
];

const _tasks = [
  TaskView(
    id: 't-1',
    title: '早安汇报',
    kind: 'recurring',
    proof: 'text',
    createdBy: 'u-d',
    status: 'active',
    pointsEarn: 2,
    schedule: {'type': 'daily'},
  ),
  TaskView(id: 't-2', title: '周三整理', kind: 'recurring', proof: 'photo', createdBy: 'u-s', status: 'proposed'),
];

const _rewards = [Reward(id: 'w-1', title: '一起看电影', cost: 20, affordable: false)];

Future<
    ({
      FakeRuleRepository rules,
      FakeTaskDefinitions tasks,
      FakeDynamicRepository dynamic,
      FakePointsRepository points,
    })> _pump(
  WidgetTester tester, {
  required TodayView view,
  String? safeword,
}) async {
  tester.view.physicalSize = const Size(390, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final rules = FakeRuleRepository(rules: _rules);
  final tasks = FakeTaskDefinitions(tasks: _tasks);
  final dyn = FakeDynamicRepository(detail: pairDetail(safeword: safeword));
  final points = FakePointsRepository(rewardList: _rewards);
  final today = FakeTodayRepository(view: view);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        todayRepositoryProvider.overrideWithValue(today),
        ruleRepositoryProvider.overrideWithValue(rules),
        taskRepositoryProvider.overrideWithValue(tasks),
        dynamicRepositoryProvider.overrideWithValue(dyn),
        pointsRepositoryProvider.overrideWithValue(points),
        exploreRepositoryProvider.overrideWithValue(FakeExploreRepository(compare: fakeCompare)),
      ],
      child: MaterialApp(
        theme: DsTheme.ritual(),
        locale: const Locale('zh'),
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        home: const RulesScreen(dynamicId: 'dyn-1'),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return (rules: rules, tasks: tasks, dynamic: dyn, points: points);
}

void main() {
  setUpAll(tzdata.initializeTimeZones);

  testWidgets('the safeword sits under 底线与安全词 when the pair has one', (tester) async {
    await _pump(tester, view: sView(), safeword: '红灯');
    expect(find.byKey(const ValueKey('safeword')), findsOneWidget);
    expect(find.text('红灯'), findsOneWidget);
  });

  testWidgets('D sees groups, add doors, and the proposal decisions', (tester) async {
    await _pump(tester, view: dView());

    // Standing rules grouped under their group words.
    expect(find.text('礼节'), findsOneWidget);
    expect(find.text('仪式'), findsOneWidget);
    expect(find.text('进门先跪'), findsOneWidget);
    // The proposed one is not among the standing rules; it waits under 提议中.
    expect(find.text('晚上十点前睡'), findsOneWidget);
    expect(find.text('接受'), findsNWidgets(2)); // one rule, one task proposed
    expect(find.text('不要'), findsNWidgets(2));

    // D affordances present, s ones absent.
    expect(find.text('加一条规矩'), findsOneWidget);
    expect(find.text('提议一条规矩'), findsNothing);
    expect(find.text('加一条任务'), findsOneWidget);
    expect(find.text('加一条奖励'), findsOneWidget);
    expect(find.text('我不在'), findsOneWidget);
    expect(find.text('去兑换'), findsNothing);

    // Task definition summary: schedule, proof, points.
    expect(find.text('早安汇报'), findsOneWidget);
    expect(find.textContaining('每天'), findsWidgets);
  });

  testWidgets('s reads, proposes, and cannot accept or add', (tester) async {
    await _pump(tester, view: sView());

    expect(find.text('提议一条规矩'), findsOneWidget);
    expect(find.text('提议一条任务'), findsOneWidget);
    expect(find.text('加一条规矩'), findsNothing);
    expect(find.text('加一条奖励'), findsNothing);
    expect(find.text('接受'), findsNothing);
    expect(find.text('我不在'), findsNothing);
    // The s's own pending proposal shows who it waits for.
    expect(find.textContaining('等 Mara'), findsWidgets);
    expect(find.text('去兑换'), findsOneWidget);
  });

  testWidgets('s long-presses a rule and posts a proposed change', (tester) async {
    final f = await _pump(tester, view: sView());

    await tester.longPress(find.text('进门先跪'));
    await tester.pumpAndSettle();
    expect(find.text('提议改一条'), findsWidgets);

    final field = find.widgetWithText(TextField, '进门先跪');
    await tester.enterText(field, '进门先跪，三秒');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(DsPrimaryButton, '提议改一条'));
    await tester.pumpAndSettle();

    expect(f.rules.created, hasLength(1));
    expect(f.rules.created.single.title, '进门先跪，三秒');
    expect(f.rules.created.single.group, 'protocol');
    expect(find.textContaining('提议送到了'), findsOneWidget);
  });

  testWidgets('D accepts a proposed task and declines a proposed rule', (tester) async {
    final f = await _pump(tester, view: dView());

    await tester.tap(find.text('接受').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('不要').last);
    await tester.pumpAndSettle();

    expect(f.tasks.accepted.length + f.rules.accepted.length, 1);
    expect(f.tasks.declined.length + f.rules.archived.length, 1);
  });

  testWidgets('D「我不在」picks a day and posts /away; 回来了 posts /back', (tester) async {
    final f = await _pump(tester, view: dView());

    await tester.tap(find.text('我不在'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('确定'));
    await tester.pumpAndSettle();

    expect(f.dynamic.awayUntil, hasLength(1));
    // The instant is the picked day at the Dynamic's 04:00 boundary in
    // Asia/Shanghai, so 20:00 UTC the day before.
    expect(f.dynamic.awayUntil.single.toUtc().hour, 20);
  });

  testWidgets('when the D is away both faces read the date', (tester) async {
    final view = dView().copyWith(dAwayUntil: DateTime.utc(2026, 9, 9, 20));
    await _pump(tester, view: view);
    expect(find.textContaining('不在，到'), findsOneWidget);
    expect(find.text('回来了'), findsOneWidget);
    expect(find.text('我不在'), findsNothing);
  });

  testWidgets('s sees the D away, read-only', (tester) async {
    final view = sView().copyWith(dAwayUntil: DateTime.utc(2026, 9, 9, 20));
    final f = await _pump(tester, view: view);
    expect(find.textContaining('Mara 不在，到'), findsOneWidget);
    expect(find.text('回来了'), findsNothing);
    expect(f.dynamic.backs, 0);
  });
}
