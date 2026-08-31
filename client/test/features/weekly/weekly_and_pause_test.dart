import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dsapp/app/providers.dart';
import 'package:dsapp/domain_client/models/dynamic_view.dart';
import 'package:dsapp/domain_client/models/weekly_reflection_view.dart';
import 'package:dsapp/domain_client/repositories/dynamic_repository.dart';
import 'package:dsapp/features/dynamic/presentation/pause_screen.dart';
import 'package:dsapp/features/weekly/presentation/weekly_screen.dart';

class _FakeDynamicRepository implements DynamicRepository {
  _FakeDynamicRepository({this.weeklyResult, this.detailResult});

  final WeeklyReflectionView? weeklyResult;
  final DynamicDetail? detailResult;

  int pauseCalls = 0;
  int resumeCalls = 0;
  bool? lastLighter;

  @override
  Future<WeeklyReflectionView> weekly(String id) async => weeklyResult!;

  @override
  Future<DynamicDetail> detail(String id) async => detailResult!;

  @override
  Future<void> pause(String id, {required String idempotencyKey}) async {
    pauseCalls++;
  }

  @override
  Future<void> resume(
    String id, {
    bool lighter = false,
    required String idempotencyKey,
  }) async {
    resumeCalls++;
    lastLighter = lighter;
  }

  @override
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError();
}

DynamicDetail _detail({bool paused = false}) => DynamicDetail(
  dynamicId: 'dyn-1',
  state: paused ? 'PAUSED' : 'ACTIVE',
  desiredOutcome: 'SERVICE',
  structureLevel: 'STEADY',
  referenceTimezone: 'Asia/Shanghai',
  pausedAt: paused ? DateTime.utc(2026, 8, 30) : null,
);

Future<_FakeDynamicRepository> _pumpWeekly(
  WidgetTester tester,
  WeeklyReflectionView view,
) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final repo = _FakeDynamicRepository(weeklyResult: view);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [dynamicRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(
        theme: DsTheme.ritual(),
        home: WeeklyScreen(dynamicId: 'dyn-1', onPause: () {}),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return repo;
}

Future<_FakeDynamicRepository> _pumpPause(
  WidgetTester tester, {
  bool paused = false,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final repo = _FakeDynamicRepository(detailResult: _detail(paused: paused));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [dynamicRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(
        theme: DsTheme.ritual(),
        home: const PauseScreen(dynamicId: 'dyn-1'),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return repo;
}

void main() {
  group('SCR-23 weekly', () {
    testWidgets('no score, and no comparison between the two people', (
      tester,
    ) async {
      // The preview draws a slider placing you against your partner. The
      // contract forbids exactly this — "no comparative score" — and the
      // server reports no ratings, so both positions would be invented.
      await _pumpWeekly(
        tester,
        const WeeklyReflectionView(
          connectedDays: 4,
          adjustmentsResolved: 1,
          hasEnoughHistory: true,
        ),
      );
      expect(find.byType(Slider), findsNothing);
      expect(find.textContaining('UNCLEAR'), findsNothing);
      expect(find.textContaining('STEADY'), findsNothing);
      expect(find.textContaining('/ 4'), findsNothing, reason: 'no step count');
    });

    testWidgets('the week is described by what happened', (tester) async {
      await _pumpWeekly(
        tester,
        const WeeklyReflectionView(
          connectedDays: 4,
          adjustmentsResolved: 1,
          hasEnoughHistory: true,
        ),
      );
      expect(find.text('4 days had something on them.'), findsOneWidget);
      expect(
        find.textContaining('one adjustment was worked out together'),
        findsOneWidget,
      );
    });

    testWidgets('an empty week is stated without blame', (tester) async {
      await _pumpWeekly(
        tester,
        const WeeklyReflectionView(connectedDays: 0, hasEnoughHistory: true),
      );
      expect(find.text('A quiet week.'), findsOneWidget);
      expect(
        find.textContaining('not about either of you'),
        findsOneWidget,
      );
    });

    testWidgets('a partner\'s words are theirs, and attributed', (
      tester,
    ) async {
      await _pumpWeekly(
        tester,
        WeeklyReflectionView(
          connectedDays: 2,
          hasEnoughHistory: true,
          answeredMoments: [
            WeeklyMoment(
              title: 'Prepare the room',
              text: 'Thank you — I noticed.',
              fromDisplayName: 'Morgan',
              occurredAt: DateTime.utc(2026, 8, 30),
            ),
          ],
        ),
      );
      expect(find.text('Thank you — I noticed.'), findsOneWidget);
      expect(find.text('— Morgan'), findsOneWidget);
    });

    testWidgets('too early is the server\'s call, never guessed', (
      tester,
    ) async {
      await _pumpWeekly(
        tester,
        const WeeklyReflectionView(connectedDays: 2),
      );
      expect(
        find.text('There is not a week to look back on yet.'),
        findsOneWidget,
      );
    });
  });

  group('SCR-24 pause', () {
    testWidgets('pausing says what it does, and never warns', (tester) async {
      final repo = await _pumpPause(tester);
      expect(
        find.textContaining('No backlog builds up'),
        findsOneWidget,
      );
      expect(find.textContaining('Are you sure'), findsNothing);
      expect(find.textContaining('lose'), findsNothing);

      await tester.tap(find.text('Pause'));
      await tester.pumpAndSettle();
      expect(repo.pauseCalls, 1);
    });

    testWidgets('returning defaults to lighter, and the choice is real', (
      tester,
    ) async {
      // Journey E: being handed the load you paused under is how people leave
      // for good. The default is lighter, but the person decides.
      final repo = await _pumpPause(tester, paused: true);
      await tester.tap(find.text('Resume'));
      await tester.pumpAndSettle();
      expect(repo.lastLighter, isTrue);

      final same = await _pumpPause(tester, paused: true);
      await tester.tap(find.text('The same as before'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Resume'));
      await tester.pumpAndSettle();
      expect(same.lastLighter, isFalse, reason: 'the choice must reach the API');
    });

    testWidgets('nothing is owed on return', (tester) async {
      await _pumpPause(tester, paused: true);
      expect(find.textContaining('You are not behind'), findsOneWidget);
    });
  });
}
