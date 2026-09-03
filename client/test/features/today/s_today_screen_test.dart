import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:dsapp/app/providers.dart';
import 'package:dsapp/domain_client/models/today_view.dart';
import 'package:dsapp/features/today/presentation/today_screen.dart';
import 'package:dsapp/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tz;

import '../../support/phase3_fakes.dart';
import '../../support/today_fakes.dart';

Future<FakeTodayRepository> _pump(
  WidgetTester tester,
  FakeTodayRepository repo, {
  FakeDynamicRepository? dynamics,
  VoidCallback? onInvite,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        todayRepositoryProvider.overrideWithValue(repo),
        dynamicRepositoryProvider.overrideWithValue(dynamics ?? FakeDynamicRepository()),
        taskRepositoryProvider.overrideWithValue(FakeTaskRepository()),
      ],
      child: MaterialApp(
        theme: DsTheme.ritual(),
        locale: const Locale('zh'),
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        home: TodayScreen(dynamicId: 'dyn-1', onInvite: onInvite, onSelectTab: (_) {}),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return repo;
}

void main() {
  setUpAll(tz.initializeTimeZones);

  group('the Dynamic itself, before the list', () {
    testWidgets('alone: 等 TA 加入 with the invite link one tap away', (tester) async {
      var invited = 0;
      final alone = pairDetail().copyWith(members: [pairDetail().members.first]);
      await _pump(
        tester,
        FakeTodayRepository(view: sView(partner: null)),
        dynamics: FakeDynamicRepository(detail: alone),
        onInvite: () => invited++,
      );

      expect(find.text('等 TA 加入。'), findsOneWidget);
      await tester.tap(find.text('发邀请链接'));
      expect(invited, 1);
    });

    testWidgets('a pair with nothing today is offered the rules, not a blank', (tester) async {
      await _pump(tester, FakeTodayRepository(view: sView()));

      expect(find.text('等 TA 加入。'), findsNothing);
      expect(find.text('去看规矩'), findsOneWidget);
    });

    testWidgets('paused says so; D away names who and until when', (tester) async {
      final paused = pairDetail().copyWith(state: 'PAUSED', pausedAt: DateTime.utc(2026, 9, 1));
      await _pump(
        tester,
        FakeTodayRepository(view: sView(dAwayUntil: DateTime.utc(2099, 9, 5, 10))),
        dynamics: FakeDynamicRepository(detail: paused),
      );

      expect(find.textContaining('暂停中'), findsOneWidget);
      expect(find.textContaining('Mara 不在，到'), findsOneWidget);
    });
  });

  group('s 今天', () {
    testWidgets('renders the day: check-in first, timed items, then the rest, then 想做就做',
        (tester) async {
      await _pump(
        tester,
        FakeTodayRepository(
          view: sView(
            items: [
              occ(id: 'late', title: '晚间日记', dueAt: DateTime.utc(2026, 9, 1, 14)),
              occ(id: 'ci', title: '早安问候', kind: 'checkin'),
              occ(id: 'early', title: '喝水', dueAt: DateTime.utc(2026, 9, 1, 2), pointsEarn: 2),
              occ(id: 'any', title: '整理床铺'),
              occ(
                id: 'seen',
                title: '拉伸',
                outcome: Outcome.delivered,
                disposition: Disposition.seen,
                dispositionAt: DateTime.utc(2026, 9, 1, 4, 40),
              ),
              occ(id: 'p', title: '按摩', outcome: Outcome.paused),
            ],
            openTasks: const [OpenTaskView(id: 'ot', title: '洗车', proof: 'check', pointsEarn: 5)],
          ),
        ),
      );

      expect(find.text('今天从 04:00 算'), findsOneWidget);
      expect(find.text('12 分 · 在一起 40 天'), findsOneWidget);

      double y(String text) => tester.getTopLeft(find.text(text)).dy;
      expect(y('早安问候'), lessThan(y('喝水')));
      expect(y('喝水'), lessThan(y('晚间日记')), reason: 'earlier due time first');
      expect(y('晚间日记'), lessThan(y('整理床铺')));
      expect(find.text('想做就做'), findsOneWidget);
      expect(y('整理床铺'), lessThan(y('洗车')));

      // Dispositions are shown in the D's words, with the time in the Dynamic's zone.
      expect(find.text('Mara 看到了 · 12:40'), findsOneWidget);
      expect(find.text('Mara 不在，先停'), findsOneWidget);
      expect(find.text('10:00 前 · +2 分'), findsOneWidget);
      expect(find.text('今天没有要求你什么。'), findsNothing);
    });

    testWidgets('an empty day says so, once', (tester) async {
      await _pump(tester, FakeTodayRepository(view: sView()));
      expect(find.text('今天没有要求你什么。'), findsOneWidget);
    });

    testWidgets('tapping a row delivers optimistically and then re-reads', (tester) async {
      final repo = FakeTodayRepository(
        view: sView(items: [occ(id: 'o1', title: '整理床铺')]),
      );
      repo.onOutcome = (view, id, change) => view.copyWith(
            items: [
              for (final o in view.items)
                if (o.id == id) o.copyWith(outcome: change.outcome) else o,
            ],
          );
      await _pump(tester, repo);

      await tester.tap(find.text('整理床铺'));
      await tester.pump(); // optimistic frame, before the fake answers
      expect(find.text('已送到 · 等 Mara 看'), findsOneWidget);

      await tester.pumpAndSettle();
      expect(repo.outcomes.single.$1, 'o1');
      expect(repo.outcomes.single.$2.outcome, Outcome.delivered);
      expect(repo.reads, 2, reason: 'a command re-reads; the server decides');
      expect(find.text('已送到 · 等 Mara 看'), findsOneWidget);
    });

    testWidgets('a 409 reverts the row and says why in the D\'s name', (tester) async {
      final repo = FakeTodayRepository(
        view: sView(items: [occ(id: 'o1', title: '整理床铺')]),
      )
        ..nextError = conflict('OCCURRENCE_PAUSED')
        ..latency = const Duration(milliseconds: 50);
      await _pump(tester, repo);

      await tester.tap(find.text('整理床铺'));
      await tester.pump();
      await tester.pump();
      expect(find.text('已送到 · 等 Mara 看'), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.text('已送到 · 等 Mara 看'), findsNothing, reason: 'reverted');
      expect(find.text('Mara 停了这条。'), findsOneWidget);
      expect(repo.outcomes, isEmpty);
    });

    testWidgets('long press offers the other words, 做不了 takes an optional line', (tester) async {
      final repo = FakeTodayRepository(
        view: sView(items: [occ(id: 'o1', title: '整理床铺')]),
      );
      await _pump(tester, repo);

      await tester.longPress(find.text('整理床铺'));
      await tester.pumpAndSettle();
      expect(find.text('求个新时间'), findsOneWidget);
      expect(find.text('想谈谈'), findsOneWidget);
      expect(find.text('撤回'), findsNothing, reason: 'nothing said yet');

      await tester.tap(find.text('做不了'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '今天腰不舒服');
      await tester.tap(find.text('送出'));
      await tester.pumpAndSettle();

      expect(repo.outcomes.single.$2.outcome, Outcome.cantDo);
      expect(repo.outcomes.single.$2.note, '今天腰不舒服');
    });

    testWidgets('something already said can be withdrawn until the D answers', (tester) async {
      final repo = FakeTodayRepository(
        view: sView(items: [occ(id: 'o1', title: '整理床铺', outcome: Outcome.delivered)]),
      );
      await _pump(tester, repo);
      expect(find.text('已送到 · 等 Mara 看'), findsOneWidget);

      await tester.longPress(find.text('整理床铺'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('撤回'));
      await tester.pumpAndSettle();

      expect(repo.outcomes.single.$2.outcome, Outcome.open);
    });
  });
}
