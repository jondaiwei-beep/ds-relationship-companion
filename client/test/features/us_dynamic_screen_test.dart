import 'package:dsapp/app/providers.dart';
import 'package:dsapp/domain_client/models/dynamic_view.dart';
import 'package:dsapp/domain_client/models/us_view.dart';
import 'package:dsapp/domain_client/models/weekly_reflection_view.dart';
import 'package:dsapp/domain_client/repositories/dynamic_repository.dart';
import 'package:dsapp/features/dynamic/presentation/dynamic_screen.dart';
import 'package:dsapp/features/us/presentation/us_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _Repo extends Mock implements DynamicRepository {}

void main() {
  late _Repo repo;
  setUp(() => repo = _Repo());

  Future<void> pumpUs(
    WidgetTester tester,
    UsView view, {
    WeeklyReflectionView? weekly,
  }) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    when(() => repo.us(any())).thenAnswer((_) async => view);
    when(() => repo.weekly(any())).thenAnswer(
        (_) async => weekly ?? const WeeklyReflectionView());
    await tester.pumpWidget(ProviderScope(
      overrides: [dynamicRepositoryProvider.overrideWithValue(repo)],
      child: const MaterialApp(home: UsScreen(dynamicId: 'd1')),
    ));
    await tester.pumpAndSettle();
  }

  Future<void> pumpDynamic(WidgetTester tester, DynamicDetail d) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    when(() => repo.detail(any())).thenAnswer((_) async => d);
    await tester.pumpWidget(ProviderScope(
      overrides: [dynamicRepositoryProvider.overrideWithValue(repo)],
      child: const MaterialApp(home: DynamicScreen(dynamicId: 'd1')),
    ));
    await tester.pumpAndSettle();
  }

  DynamicDetail detail({String state = 'ACTIVE'}) => DynamicDetail(
        dynamicId: 'd1',
        state: state,
        desiredOutcome: 'CLOSER',
        structureLevel: 'LIGHT',
        referenceTimezone: 'America/New_York',
        members: const [
          MemberView(userId: 'u1', displayName: 'Alex', roleContext: 'CREATOR', accessState: 'ACTIVE'),
          MemberView(userId: 'u2', displayName: 'Jamie', roleContext: 'PARTNER', accessState: 'ACTIVE'),
        ],
        structure: const [
          StructureItem(definitionId: 's1', kind: 'TASK',
              title: 'Prepare the evening space', active: true),
        ],
        alwaysAvailable: const ['discuss', 'reschedule', 'cant_do', 'pause', 'leave', 'block'],
      );

  group('Us', () {
    testWidgets('a human response is shown verbatim and attributed', (tester) async {
      await pumpUs(tester, UsView(connectedDays: 3, moments: [
        RelationshipMoment(
          eventType: 'acknowledgement_sent', actorDisplayName: 'Alex',
          occurredAt: DateTime.now(), title: 'Prepare the evening space',
          text: 'I noticed the care you put into this.',
        ),
      ]));

      expect(find.text('ALEX RESPONDED'), findsOneWidget);
      expect(find.text('I noticed the care you put into this.'), findsOneWidget);
    });

    testWidgets('connected days are stated as a fact, never as a score',
        (tester) async {
      await pumpUs(
        tester,
        UsView(connectedDays: 3, moments: [
          RelationshipMoment(eventType: 'completion_submitted',
              actorDisplayName: 'Jamie', occurredAt: DateTime.now(), title: 'x'),
        ]),
        // The connected-day count is stated once, by the weekly reflection
        // which owns the week's framing — not repeated as a page subtitle.
        weekly: const WeeklyReflectionView(
            connectedDays: 3, hasEnoughHistory: true),
      );

      expect(find.text('3 days this week you were both here.'), findsOneWidget);
      // Not a streak, not a score, not a target to beat (Notion 01 §10).
      final banned = RegExp(r'\b(streaks?|scores?|points|record|goal)\b',
          caseSensitive: false);
      expect(
        find.byWidgetPredicate((w) => w is Text && w.data != null && banned.hasMatch(w.data!)),
        findsNothing,
      );
    });

    testWidgets('backend event names never leak', (tester) async {
      await pumpUs(tester, UsView(moments: [
        RelationshipMoment(eventType: 'completion_submitted',
            actorDisplayName: 'Jamie', occurredAt: DateTime.now(), title: 'x'),
      ]));

      expect(find.text('JAMIE COMPLETED'), findsOneWidget);
      expect(find.textContaining('completion_submitted'), findsNothing);
    });

    testWidgets('empty Us invites rather than scolds', (tester) async {
      await pumpUs(tester, const UsView());
      expect(find.text('Nothing here yet.'), findsOneWidget);
      expect(find.textContaining('will collect'), findsOneWidget);
    });
  });

  group('Dynamic', () {
    testWidgets('inviolable agency is ALWAYS shown, never behind a menu',
        (tester) async {
      await pumpDynamic(tester, detail());

      // Red line #4: no role can remove these, so the UI must not hide them.
      expect(find.text('ALWAYS YOURS'), findsOneWidget);
      expect(find.textContaining('Ask to discuss anything'), findsOneWidget);
      expect(find.textContaining('Leave at any time'), findsOneWidget);
      expect(find.textContaining('Block and cut off contact'), findsOneWidget);
    });

    testWidgets('Core Beta shows no Agreement, Rules or permissions matrix',
        (tester) async {
      await pumpDynamic(tester, detail());

      // Notion 02 §10 keeps governance out of Core Beta entirely.
      for (final banned in ['Agreement', 'Rules', 'Permissions', 'Subscription']) {
        expect(find.textContaining(banned), findsNothing, reason: '$banned is out of scope');
      }
    });

    testWidgets('either member can pause — the button is always offered',
        (tester) async {
      await pumpDynamic(tester, detail());
      expect(find.text('Pause this dynamic'), findsOneWidget);
    });

    testWidgets('a paused dynamic promises there is nothing to catch up on',
        (tester) async {
      await pumpDynamic(tester, detail(state: 'PAUSED'));

      expect(find.text('Paused'), findsOneWidget);
      // Journey E: returning must not require making up missed work.
      expect(find.textContaining('nothing to catch up on'), findsOneWidget);
      // Coming back is a choice, not a switch — being handed the same load
      // you paused under is how people leave again (Notion 02 §6).
      expect(find.text('Pick up where we left off'), findsOneWidget);
      expect(find.text('Come back lighter'), findsOneWidget);
      expect(find.textContaining('Nothing is deleted'), findsOneWidget);
    });

    testWidgets('pausing calls the command with an idempotency key', (tester) async {
      when(() => repo.pause(any(), idempotencyKey: any(named: 'idempotencyKey')))
          .thenAnswer((_) async {});
      await pumpDynamic(tester, detail());

      await tester.tap(find.text('Pause this dynamic'));
      await tester.pumpAndSettle();

      verify(() => repo.pause('d1', idempotencyKey: any(named: 'idempotencyKey'))).called(1);
    });
  });

  group('Agency does not depend on a network answer', () {
    testWidgets('Always yours renders in full even when the server sends none',
        (tester) async {
      await pumpDynamic(tester, DynamicDetail(
        dynamicId: 'd1',
        state: 'ACTIVE',
        desiredOutcome: 'CLOSER',
        structureLevel: 'LIGHT',
        referenceTimezone: 'UTC',
        members: detail().members,
        // An empty or partial payload must not silently remove rights that
        // are supposed to be inviolable (red line #4).
        alwaysAvailable: const [],
      ));

      for (final right in [
        'Ask to discuss anything',
        'Request a new time',
        "Say you can't do something",
        'Pause this dynamic',
        'Leave at any time',
        'Block and cut off contact',
      ]) {
        expect(find.text('· $right'), findsOneWidget,
            reason: 'this list is client-owned, not server-derived');
      }
    });

    testWidgets('it sits with the relationship, not at the bottom',
        (tester) async {
      await pumpDynamic(tester, detail());
      // These are part of the shape of the relationship, not a footnote to
      // its settings.
      final between = tester.getTopLeft(find.text('BETWEEN')).dy;
      final always = tester.getTopLeft(find.text('ALWAYS YOURS')).dy;
      final pause = tester.getTopLeft(find.text('Pause this dynamic')).dy;
      expect(between < always, isTrue);
      expect(always < pause, isTrue,
          reason: 'rights come before controls');
    });

    testWidgets('an unknown backend value never reaches the user',
        (tester) async {
      await pumpDynamic(tester, DynamicDetail(
        dynamicId: 'd1',
        state: 'ACTIVE',
        desiredOutcome: 'CLOSER',
        structureLevel: 'LIGHT',
        referenceTimezone: 'UTC',
        members: const [
          MemberView(userId: 'u1', displayName: 'Alex',
              roleContext: 'SOMETHING_NEW', accessState: 'ACTIVE'),
        ],
        alwaysAvailable: const [],
      ));

      // Notion 05 §12. A fallthrough that returns the raw value ships an
      // enum to a person the day the server adds one.
      expect(find.textContaining('SOMETHING_NEW'), findsNothing);
    });
  });
}
