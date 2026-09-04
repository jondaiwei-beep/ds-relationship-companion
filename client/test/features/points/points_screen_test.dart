import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:dsapp/app/providers.dart';
import 'package:dsapp/app/shell/ds_primary_button.dart';
import 'package:dsapp/domain_client/models/consequence.dart';
import 'package:dsapp/domain_client/models/points.dart';
import 'package:dsapp/domain_client/models/redemption.dart';
import 'package:dsapp/domain_client/models/today_view.dart' show TodayView;
import 'package:dsapp/features/points/presentation/points_screen.dart';
import 'package:dsapp/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/phase3_fakes.dart';
import '../../support/record_fakes.dart';
import '../../support/today_fakes.dart';

const _rewards = [
  Reward(id: 'w-cheap', title: '一起看电影', cost: 10, affordable: true),
  Reward(id: 'w-dear', title: '周末出门', cost: 30, affordable: false),
  Reward(id: 'w-open', title: '一个愿望', cost: null, affordable: true),
  Reward(id: 'w-free', title: '抱一下', cost: 0, affordable: true),
];

const _entries = [
  PointEntry(id: 'e-1', amount: 2, reason: PointReason.taskEarn),
  PointEntry(id: 'e-2', amount: 5, reason: PointReason.dAward, note: '今天很乖'),
  PointEntry(id: 'e-3', amount: -3, reason: PointReason.dDeduct),
  PointEntry(id: 'e-4', amount: -10, reason: PointReason.redemption),
  PointEntry(id: 'e-5', amount: 10, reason: PointReason.redemptionRefund),
];

const _redemptions = [
  RedemptionView(id: 'rd-1', rewardId: 'w-open', rewardTitle: '一个愿望', subjectUserId: 'u-s', status: 'requested'),
  RedemptionView(id: 'rd-2', rewardId: 'w-cheap', rewardTitle: '一起看电影', subjectUserId: 'u-s', status: 'approved'),
];

const _consequences = [
  ConsequenceView(id: 'c-1', issuedBy: 'u-d', title: '跪十分钟', status: 'issued'),
  ConsequenceView(id: 'c-2', issuedBy: 'u-d', title: '写反省', status: 'done_by_s'),
];

Future<({FakePointsRepository points, FakeConsequenceRepository cons})> _pump(
  WidgetTester tester, {
  required TodayView view,
  List<RedemptionView> redemptions = _redemptions,
}) async {
  tester.view.physicalSize = const Size(390, 1800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final points = FakePointsRepository(
    balance: 12,
    entries: _entries,
    rewardList: _rewards,
    redemptionList: redemptions,
    rules: const [PointsRule(taskId: 't-1', title: '早安汇报', pointsEarn: 2)],
  );
  final cons = FakeConsequenceRepository(items: _consequences);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        todayRepositoryProvider.overrideWithValue(FakeTodayRepository(view: view)),
        dynamicRepositoryProvider.overrideWithValue(FakeDynamicRepository()),
        pointsRepositoryProvider.overrideWithValue(points),
        consequenceRepositoryProvider.overrideWithValue(cons),
        recordRepositoryProvider.overrideWithValue(FakeRecordRepository()),
      ],
      child: MaterialApp(
        theme: DsTheme.ritual(),
        locale: const Locale('zh'),
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        home: const PointsScreen(dynamicId: 'dyn-1'),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return (points: points, cons: cons);
}

void main() {
  testWidgets('s sees its balance, the streak line, and affordability words', (tester) async {
    final f = await _pump(tester, view: sView());

    expect(find.text('12 分'), findsOneWidget);
    expect(find.text('在一起 40 天'), findsOneWidget);
    expect(find.text('还差 18 分'), findsOneWidget); // 30 - 12
    expect(find.text('Mara 定'), findsOneWidget); // null-cost reward
    // Balance was asked for the s, resolved from the pair.
    expect(f.points.subjects, contains('u-s'));
    // Only the D gives or deducts.
    expect(find.text('给分'), findsNothing);
    expect(find.text('扣分'), findsNothing);
  });

  testWidgets('D sees the s balance by name and can give points', (tester) async {
    final f = await _pump(tester, view: dView());

    expect(find.text('12'), findsOneWidget);
    expect(find.text('Nia · 12 分'), findsOneWidget);
    await tester.tap(find.text('给分'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '5');
    await tester.enterText(find.byType(TextField).last, '今天很乖');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(DsPrimaryButton, '给分'));
    await tester.pumpAndSettle();

    expect(f.points.adjustments, [('u-s', 5, '今天很乖')]);
  });

  testWidgets('s requests a priced reward with a note, redeems a free one directly', (tester) async {
    final f = await _pump(tester, view: sView(), redemptions: const []);

    // 去兑换 appears only on affordable rewards: cheap, open, free.
    expect(find.text('去兑换'), findsNWidgets(3));

    await tester.tap(find.text('去兑换').first);
    await tester.pumpAndSettle();
    expect(find.textContaining('申请兑换'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '这周末想看');
    await tester.tap(find.text('申请'));
    await tester.pumpAndSettle();
    expect(f.points.requested, [('w-cheap', '这周末想看')]);

    await tester.tap(find.text('去兑换').last);
    await tester.pumpAndSettle();
    expect(f.points.redeemed, ['w-free']);
    expect(f.points.requested, hasLength(1));
  });

  testWidgets('D approving a「D 决定」reward must name a cost', (tester) async {
    final f = await _pump(tester, view: dView());

    expect(find.text('等 你 看'), findsOneWidget);
    await tester.tap(find.text('同意'));
    await tester.pumpAndSettle();
    expect(find.text('定多少分'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, '15');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(DsPrimaryButton, '同意'));
    await tester.pumpAndSettle();

    expect(f.points.decisions, [('rd-1', true, null, 15)]);
  });

  testWidgets('D denies with an optional note; either side fulfills an approved one', (tester) async {
    final f = await _pump(tester, view: dView());

    await tester.tap(find.text('不行'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('不行').last);
    await tester.pumpAndSettle();
    expect(f.points.decisions, [('rd-1', false, null, null)]);

    await tester.tap(find.text('完成了'));
    await tester.pumpAndSettle();
    expect(f.points.fulfilled, ['rd-2']);
  });

  testWidgets('ledger reasons are words, never codes', (tester) async {
    await _pump(tester, view: sView());

    expect(find.text('任务'), findsOneWidget);
    expect(find.text('Mara 给'), findsOneWidget);
    expect(find.text('Mara 扣'), findsOneWidget);
    expect(find.text('兑换'), findsOneWidget);
    expect(find.text('退回'), findsOneWidget);
    expect(find.text('+5'), findsOneWidget);
    expect(find.text('-3'), findsOneWidget);
    expect(find.textContaining('task_earn'), findsNothing);

    // 规则可见: which tasks pay, then the base line.
    expect(find.text('早安汇报'), findsOneWidget);
    expect(find.text('其余基础项 0 分。'), findsOneWidget);
  });

  testWidgets('s marks a consequence done; D confirms or lets one go', (tester) async {
    var f = await _pump(tester, view: sView());
    expect(find.text('做完了'), findsOneWidget);
    expect(find.text('确认'), findsNothing);
    await tester.tap(find.text('做完了'));
    await tester.pumpAndSettle();
    expect(f.cons.doneIds, ['c-1']);

    f = await _pump(tester, view: dView());
    expect(find.text('做完了'), findsNothing);
    expect(find.text('确认'), findsNWidgets(2));
    await tester.tap(find.text('确认').last);
    await tester.pumpAndSettle();
    expect(f.cons.confirmedIds, ['c-2']);
    await tester.tap(find.text('算了').first);
    await tester.pumpAndSettle();
    expect(f.cons.waivedIds, ['c-1']);
  });
}
