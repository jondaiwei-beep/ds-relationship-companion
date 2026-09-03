import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:dsapp/app/providers.dart';
import 'package:dsapp/domain_client/models/record.dart';
import 'package:dsapp/domain_client/models/today_view.dart';
import 'package:dsapp/features/dynamic/presentation/dynamic_screen.dart' show dynamicViewerIdProvider;
import 'package:dsapp/features/record/presentation/day_screen.dart';
import 'package:dsapp/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tz;

import '../../support/record_fakes.dart';
import '../../support/today_fakes.dart';

const _day = '2026-09-01';
final _t = DateTime.utc(2026, 9, 1);

Future<void> _pump(
  WidgetTester tester, {
  required FakeRecordRepository record,
  required FakeTodayRepository today,
}) async {
  tester.view.physicalSize = const Size(390, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        todayRepositoryProvider.overrideWithValue(today),
        recordRepositoryProvider.overrideWithValue(record),
        dynamicViewerIdProvider.overrideWithValue('u-me'),
        agreementsProvider.overrideWith((ref, id) async => const []),
      ],
      child: MaterialApp(
        theme: DsTheme.ritual(),
        locale: const Locale('zh'),
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        home: const DayScreen(dynamicId: 'dyn-1', day: _day),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

DayView _fullDay() => DayView(
      day: _day,
      timeline: [
        outcomeAt(_t.add(const Duration(hours: 1)), occ: 'o1', title: '早安问候', to: 'delivered', proofKind: 'text', proofRef: '早上好'),
        dispositionAt(_t.add(const Duration(hours: 2)), occ: 'o1', title: '早安问候', to: 'praised', note: '乖'),
        commentAt(_t.add(const Duration(hours: 3)), id: 'c1', author: 'u-me', body: '今晚早点回来'),
        pointsAt(_t.add(const Duration(hours: 4)), id: 'p1', reason: 'task_earn', amount: 2),
        redemptionAt(_t.add(const Duration(hours: 5)), id: 'r1', title: '按摩半小时', subject: 'u-me'),
        outcomeAt(_t.add(const Duration(hours: 20)), occ: 'o2', title: '晚间日记', to: 'missed'),
        dispositionAt(
          _t.add(const Duration(hours: 21)),
          occ: 'o3',
          title: '拉伸',
          to: 'punished',
          consequenceTitle: '跪十分钟',
        ),
      ],
      comments: const [CommentEntry(id: 'c1', authorId: 'u-me', body: '今晚早点回来')],
    );

void main() {
  setUpAll(tz.initializeTimeZones);

  group('这一天', () {
    testWidgets('the timeline is read in time order, in the Dynamic\'s zone, with names', (tester) async {
      final record = FakeRecordRepository(days: {_day: _fullDay()});
      await _pump(tester, record: record, today: FakeTodayRepository(view: sView()));

      double y(String text) => tester.getTopLeft(find.text(text)).dy;
      expect(find.text('你 交付了「早安问候」'), findsOneWidget);
      expect(find.text('早上好'), findsOneWidget, reason: 'the proof text is shown');
      expect(find.text('Mara：很好——「早安问候」'), findsOneWidget);
      expect(find.text('乖'), findsOneWidget);
      expect(find.text('你 留了一句'), findsOneWidget);
      expect(find.text('今晚早点回来'), findsOneWidget);
      expect(find.text('+2 分 · 任务'), findsOneWidget);
      expect(find.text('你 兑换了「按摩半小时」'), findsOneWidget);
      expect(find.text('「晚间日记」当天没交'), findsOneWidget);
      expect(find.text('Mara：罚「拉伸」——跪十分钟'), findsOneWidget);

      expect(y('你 交付了「早安问候」'), lessThan(y('Mara：很好——「早安问候」')));
      expect(y('Mara：很好——「早安问候」'), lessThan(y('你 留了一句')));
      expect(y('你 留了一句'), lessThan(y('+2 分 · 任务')));
      expect(y('+2 分 · 任务'), lessThan(y('你 兑换了「按摩半小时」')));
      expect(y('你 兑换了「按摩半小时」'), lessThan(y('「晚间日记」当天没交')));

      // 01:00 UTC is 09:00 in Asia/Shanghai.
      expect(find.text('09:00'), findsOneWidget);
      expect(find.text('10:00'), findsOneWidget);
    });

    testWidgets('an empty day says so without a verdict', (tester) async {
      await _pump(tester, record: FakeRecordRepository(), today: FakeTodayRepository(view: sView()));
      expect(find.text('这一天没写下什么。'), findsOneWidget);
    });

    testWidgets('either side can leave a line; only your own can be removed', (tester) async {
      final record = FakeRecordRepository(
        days: {
          _day: DayView(
            day: _day,
            timeline: [commentAt(_t, id: 'c-them', author: 'u-them', body: '慢慢来')],
          ),
        },
      );
      await _pump(tester, record: record, today: FakeTodayRepository(view: sView()));
      expect(find.text('Mara 留了一句'), findsOneWidget);

      await tester.enterText(find.byKey(const ValueKey('comment-field')), '  今晚再说  ');
      await tester.pumpAndSettle();
      await tester.tap(find.text('送出'));
      await tester.pumpAndSettle();
      expect(record.comments, [(_day, '今晚再说')]);
      expect(find.text('今晚再说'), findsOneWidget, reason: 'the day is re-read after the write');
      expect(find.text('你 留了一句'), findsOneWidget);

      // The partner's line is not deletable from here.
      await tester.longPress(find.text('慢慢来'));
      await tester.pumpAndSettle();
      expect(find.text('删掉这句？'), findsNothing);

      await tester.longPress(find.text('今晚再说'));
      await tester.pumpAndSettle();
      expect(find.text('删掉这句？'), findsOneWidget);
      await tester.tap(find.text('删掉'));
      await tester.pumpAndSettle();
      expect(record.deletedComments, ['c-1']);
      expect(find.text('今晚再说'), findsNothing);
      expect(find.text('慢慢来'), findsOneWidget);
    });

    testWidgets('the private note is saved when the field is left; emptying it clears', (tester) async {
      final record = FakeRecordRepository(
        days: {_day: DayView(day: _day, myPrivateNote: '她今天有点累')},
      );
      await _pump(tester, record: record, today: FakeTodayRepository(view: sView()));
      expect(find.text('她今天有点累'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('private-note-field')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const ValueKey('private-note-field')), '她今天有点累，明天少排点');
      // Leaving the field is the save.
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      expect(record.notes, [(_day, '她今天有点累，明天少排点')]);
      expect(find.text('已保存'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('private-note-field')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const ValueKey('private-note-field')), '');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      expect(record.notes.last, (_day, ''));
    });

    testWidgets('an s may still deliver a missed occurrence; the write is the same outcome command',
        (tester) async {
      final today = FakeTodayRepository(view: sView());
      final record = FakeRecordRepository(days: {_day: _fullDay()});
      await _pump(tester, record: record, today: today);

      // Only the missed, undisposed occurrence offers repair.
      expect(find.text('补交付'), findsOneWidget);
      expect(find.text('说明做不了'), findsOneWidget);
      expect(find.text('看到了'), findsNothing, reason: 'the s never sees the D\'s words');

      await tester.tap(find.text('补交付'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, '睡过了，现在补');
      await tester.tap(find.text('补交付').last);
      await tester.pumpAndSettle();

      expect(today.outcomes.length, 1);
      final (id, change) = today.outcomes.single;
      expect(id, 'o2');
      expect(change.outcome, Outcome.delivered);
      expect(change.note, '睡过了，现在补');
      expect(record.dayReads.length, greaterThan(1), reason: 'the day is re-read after the write');
    });

    testWidgets('an s may explain instead', (tester) async {
      final today = FakeTodayRepository(view: sView());
      await _pump(tester, record: FakeRecordRepository(days: {_day: _fullDay()}), today: today);
      await tester.tap(find.text('说明做不了'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('说明做不了').last);
      await tester.pumpAndSettle();
      expect(today.outcomes.single.$1, 'o2');
      expect(today.outcomes.single.$2.outcome, Outcome.cantDo);
      expect(today.outcomes.single.$2.note, isNull);
    });

    testWidgets('a D may answer any undisposed occurrence, however old; the answer never expires',
        (tester) async {
      final today = FakeTodayRepository(view: dView());
      final record = FakeRecordRepository(
        days: {
          _day: DayView(
            day: _day,
            timeline: [
              outcomeAt(_t.add(const Duration(hours: 1)), occ: 'o1', title: '早安问候', to: 'delivered'),
              dispositionAt(_t.add(const Duration(hours: 2)), occ: 'o1', title: '早安问候', to: 'seen'),
              outcomeAt(_t.add(const Duration(hours: 3)), occ: 'o2', title: '喝水', to: 'cant_do', note: '肚子疼'),
              outcomeAt(_t.add(const Duration(hours: 20)), occ: 'o3', title: '晚间日记', to: 'missed'),
            ],
          ),
        },
      );
      await _pump(tester, record: record, today: today);

      // Names from the D's side: the s is the partner.
      expect(find.text('Nia 交付了「早安问候」'), findsOneWidget);
      expect(find.text('你 看到了「早安问候」'), findsOneWidget);
      expect(find.text('Nia 说「喝水」做不了'), findsOneWidget);
      expect(find.text('肚子疼'), findsOneWidget);

      // o1 is answered; o2 (cant_do) and o3 (missed) are not: five words each.
      expect(find.text('看到了'), findsNWidgets(2));
      expect(find.text('很好'), findsNWidgets(2));
      expect(find.text('算了'), findsNWidgets(2));
      expect(find.text('补上'), findsNWidgets(2));
      expect(find.text('罚'), findsNWidgets(2));
      expect(find.text('补交付'), findsNothing, reason: 'the D never speaks for the s');

      // The first 算了 belongs to 喝水 (earlier on the timeline).
      await tester.tap(find.text('算了').first);
      await tester.pumpAndSettle();
      expect(today.dispositions.length, 1);
      expect(today.dispositions.single.$1, 'o2');
      expect(today.dispositions.single.$2.disposition, Disposition.letGo);

      // 很好 asks for a line first.
      await tester.tap(find.text('很好').last);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, '补得好');
      await tester.tap(find.text('送出'));
      await tester.pumpAndSettle();
      expect(today.dispositions.last.$1, 'o3');
      expect(today.dispositions.last.$2.disposition, Disposition.praised);
      expect(today.dispositions.last.$2.note, '补得好');
    });

    testWidgets('a refused write steps back and says why', (tester) async {
      final today = FakeTodayRepository(view: sView())..nextError = conflict('OCCURRENCE_DISPOSED');
      await _pump(tester, record: FakeRecordRepository(days: {_day: _fullDay()}), today: today);
      await tester.tap(find.text('说明做不了'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('说明做不了').last);
      await tester.pumpAndSettle();
      expect(find.text('Mara 已经处置了这条。'), findsOneWidget);
    });
  });
}
