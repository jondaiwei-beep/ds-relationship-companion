import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:dsapp/app/providers.dart';
import 'package:dsapp/app/shell/ds_primary_button.dart';
import 'package:dsapp/domain_client/models/dynamic_view.dart';
import 'package:dsapp/domain_client/models/points.dart';
import 'package:dsapp/domain_client/models/rule.dart';
import 'package:dsapp/domain_client/models/task.dart';
import 'package:dsapp/domain_client/models/today_view.dart';
import 'package:dsapp/features/rules/presentation/rules_screen.dart';
import 'package:dsapp/features/today/presentation/widgets/word_button.dart';
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

/// The D before anyone has joined: one member, nothing shared yet.
DynamicDetail _aloneDetail() => DynamicDetail(
      dynamicId: 'dyn-1',
      state: 'active',
      desiredOutcome: 'closer',
      structureLevel: 'light',
      referenceTimezone: 'Asia/Shanghai',
      members: const [
        MemberView(userId: 'u-d', displayName: 'Nia', roleContext: 'd', side: 'D', accessState: 'active'),
      ],
    );

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
  List<RuleView> rules = _rules,
  List<TaskView> tasks = _tasks,
  List<Reward> rewards = _rewards,
  DynamicDetail? detail,
  VoidCallback? onPause,
  VoidCallback? onStarterPacks,
}) async {
  tester.view.physicalSize = const Size(390, 3000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final ruleRepo = FakeRuleRepository(rules: rules);
  final taskRepo = FakeTaskDefinitions(tasks: tasks);
  final dyn = FakeDynamicRepository(detail: detail ?? pairDetail(safeword: safeword));
  final points = FakePointsRepository(rewardList: rewards);
  final today = FakeTodayRepository(view: view);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        todayRepositoryProvider.overrideWithValue(today),
        ruleRepositoryProvider.overrideWithValue(ruleRepo),
        taskRepositoryProvider.overrideWithValue(taskRepo),
        dynamicRepositoryProvider.overrideWithValue(dyn),
        pointsRepositoryProvider.overrideWithValue(points),
        exploreRepositoryProvider.overrideWithValue(FakeExploreRepository(compare: fakeCompare)),
      ],
      child: MaterialApp(
        theme: DsTheme.ritual(),
        locale: const Locale('zh'),
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        home: RulesScreen(
          dynamicId: 'dyn-1',
          onPause: onPause,
          onStarterPacks: onStarterPacks,
          onExplore: (_) {},
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return (rules: ruleRepo, tasks: taskRepo, dynamic: dyn, points: points);
}

Iterable<WordButton> _filled(WidgetTester tester) =>
    tester.widgetList<WordButton>(find.byType(WordButton)).where((b) => b.filled);

void main() {
  setUpAll(tzdata.initializeTimeZones);

  testWidgets('the page name is the one large thing; the header carries no title', (tester) async {
    await _pump(tester, view: dView());
    final hero = tester.widget<Text>(find.byKey(const ValueKey('rules-hero')));
    expect(hero.data, '规矩');
    expect(hero.style?.fontSize, DsTextStyles.displayHero.fontSize);
    // Once in the hero, once in the tab bar — not a third time as a small title.
    expect(find.text('规矩'), findsNWidgets(2));
  });

  testWidgets('the safeword sits inside 底线与安全词 with the compare limits', (tester) async {
    await _pump(tester, view: sView(), safeword: '红灯');
    final block = find.byKey(const ValueKey('rules-limits'));
    expect(block, findsOneWidget);
    expect(find.descendant(of: block, matching: find.byKey(const ValueKey('safeword'))), findsOneWidget);
    expect(find.descendant(of: block, matching: find.text('红灯')), findsOneWidget);
    expect(find.descendant(of: block, matching: find.text('蒙眼')), findsOneWidget);
    expect(find.descendant(of: block, matching: find.textContaining('安全词在设置里')), findsOneWidget);
    // One quiet way in; the word is not repeated in the doors row below.
    expect(find.text('去比对'), findsOneWidget);
    expect(find.text('两人比对'), findsNothing);
  });

  testWidgets('D sees groups, add doors, and the proposal decisions', (tester) async {
    await _pump(tester, view: dView());

    // Standing rules grouped under their group words.
    expect(find.text('礼节'), findsOneWidget);
    expect(find.text('仪式'), findsOneWidget);
    expect(find.text('进门先跪'), findsOneWidget);
    // The proposed one is not among the standing rules; it waits under 提议中.
    expect(find.text('提议中'), findsOneWidget);
    expect(find.text('晚上十点前睡'), findsOneWidget);
    expect(find.text('接受'), findsNWidgets(2)); // one rule, one task proposed
    expect(find.text('不要'), findsNWidgets(2));

    // D affordances present, s ones absent.
    expect(find.text('加一条规矩'), findsOneWidget);
    expect(find.text('提议一条规矩'), findsNothing);
    expect(find.text('加一条任务'), findsOneWidget);
    expect(find.text('加一条奖励'), findsOneWidget);
    expect(find.text('去兑换'), findsNothing);
    // The D's own face speaks to "you", never to "the D".
    expect(find.textContaining('只有你在处置交付时会用到'), findsOneWidget);

    // Task definition summary: schedule, proof, points.
    expect(find.text('早安汇报'), findsOneWidget);
    expect(find.textContaining('每天'), findsWidgets);

    // Nothing on a populated page is filled (§2).
    expect(_filled(tester), isEmpty);
  });

  testWidgets('s reads, proposes, and cannot accept or add', (tester) async {
    await _pump(tester, view: sView());

    expect(find.text('提议一条规矩'), findsOneWidget);
    expect(find.text('提议一条任务'), findsOneWidget);
    expect(find.text('加一条规矩'), findsNothing);
    expect(find.text('加一条奖励'), findsNothing);
    expect(find.text('接受'), findsNothing);
    // The s's own pending proposal shows who it waits for.
    expect(find.textContaining('等 Mara'), findsWidgets);
    expect(find.text('去兑换'), findsOneWidget);
    // Consequences are the D's by name.
    expect(find.textContaining('只有 Mara 在处置交付时会用到'), findsOneWidget);
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

  testWidgets('提议中 is omitted when nothing is proposed', (tester) async {
    await _pump(
      tester,
      view: dView(),
      rules: _rules.where((r) => r.status == 'active').toList(),
      tasks: _tasks.where((t) => t.status == 'active').toList(),
    );
    expect(find.text('提议中'), findsNothing);
    expect(find.text('没有待看的提议。'), findsNothing);
  });

  testWidgets('empty sections say what would appear and what makes it appear', (tester) async {
    var packs = 0;
    await _pump(
      tester,
      view: dView(),
      rules: const [],
      tasks: const [],
      rewards: const [],
      onStarterPacks: () => packs++,
    );
    expect(find.text('还没有规矩。先写一条，或从下面的起步包开始。'), findsOneWidget);
    expect(find.text('还没有循环任务。加一条，就会出现在「今天」里。'), findsOneWidget);
    expect(find.text('还没有奖励。加一条，就能用分兑换。'), findsOneWidget);
    expect(find.text('还没有惩罚。加一条，处置交付时就能选。'), findsOneWidget);
    expect(find.text('还没有。'), findsNothing);

    // An empty page gets one primary: the starter pack, beside an outlined Add.
    final pack = find.byKey(const ValueKey('rules-start-pack'));
    expect(pack, findsOneWidget);
    expect(_filled(tester).single.label, '从起步包开始');
    await tester.tap(pack);
    await tester.tap(find.text('起步包'));
    expect(packs, 2);
  });

  testWidgets('the starter pack is not the primary once there is anything on the page', (tester) async {
    await _pump(tester, view: dView(), onStarterPacks: () {});
    expect(find.byKey(const ValueKey('rules-start-pack')), findsNothing);
    expect(_filled(tester), isEmpty);
    // It stays reachable in the quiet row.
    expect(find.text('起步包'), findsOneWidget);
  });

  testWidgets('the s reads its own empty lines', (tester) async {
    await _pump(tester, view: sView(), rules: const [], tasks: const [], rewards: const []);
    expect(find.text('还没有规矩。你可以先提议一条。'), findsOneWidget);
    expect(find.text('还没有循环任务。你可以提议一条。'), findsOneWidget);
    expect(find.text('还没有奖励。Mara 加了就会出现在这里。'), findsOneWidget);
    expect(find.text('还没有惩罚。Mara 加了就会出现在这里。'), findsOneWidget);
  });

  testWidgets('alone, the limits block says it starts when they join', (tester) async {
    await _pump(tester, view: dView(), detail: _aloneDetail());
    final block = find.byKey(const ValueKey('rules-limits'));
    expect(find.descendant(of: block, matching: find.text('对方加入后开始。')), findsOneWidget);
    expect(find.text('去比对'), findsNothing);
    // 蒙眼 comes from the compare fixture, which needs two people to mean anything.
    expect(find.text('蒙眼'), findsNothing);
  });

  testWidgets('pause is the last, quiet word and opens the pause screen', (tester) async {
    var paused = 0;
    await _pump(tester, view: sView(), onPause: () => paused++);
    final pause = find.byKey(const ValueKey('rules-pause'));
    expect(pause, findsOneWidget);
    expect(tester.widget<WordButton>(pause).quiet, isTrue);
    await tester.tap(pause);
    expect(paused, 1);
  });

  testWidgets('away has left this page for Today, on both faces', (tester) async {
    final d = await _pump(tester, view: dView().copyWith(dAwayUntil: DateTime.utc(2026, 9, 9, 20)));
    expect(find.text('我不在'), findsNothing);
    expect(find.text('回来了'), findsNothing);
    expect(find.textContaining('不在，到'), findsNothing);
    expect(d.dynamic.awayUntil, isEmpty);

    final s = await _pump(tester, view: sView().copyWith(dAwayUntil: DateTime.utc(2026, 9, 9, 20)));
    expect(find.textContaining('Mara 不在，到'), findsNothing);
    expect(s.dynamic.backs, 0);
  });
}
