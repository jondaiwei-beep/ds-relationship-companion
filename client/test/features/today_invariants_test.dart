import 'package:dsapp/app/providers.dart';
import 'package:dsapp/domain_client/models/today_view.dart';
import 'package:dsapp/domain_client/repositories/today_repository.dart';
import 'package:dsapp/features/today/presentation/today_screen.dart';
import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tzdata;

import 'package:dsapp/features/today/fixtures/today_fixtures.dart';

/// The invariants SCR-01 must hold, restored from `product/ui-invariants.md`
/// after the pre-redesign UI was deleted.
///
/// These are product red lines in executable form, not styling preferences.
/// A screen that renders correctly and drops one of them has regressed the
/// product, not just its coverage.
void main() {
  Future<void> pump(WidgetTester tester, TodayView view) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          todayRepositoryProvider.overrideWithValue(
            FixtureTodayRepository(view) as TodayRepository,
          ),
        ],
        child: MaterialApp(
          theme: DsTheme.ritual(),
          home: const TodayScreen(dynamicId: 'd1'),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  String allText(WidgetTester tester) => tester
      .widgetList<Text>(find.byType(Text))
      .map((t) => t.data ?? '')
      .join(' | ');

  group('the system never speaks for a person', () {
    testWidgets('no honorific is ever put in the partner\'s mouth', (
      tester,
    ) async {
      await pump(tester, todayFixture());
      // Hardcoding "Sir" would make the app speak as the Dominant.
      for (final word in [
        'Sir',
        'Master',
        'Mistress',
        'good girl',
        'good boy',
      ]) {
        expect(
          allText(tester).toLowerCase().contains(word.toLowerCase()),
          isFalse,
          reason: 'the system must not speak in the partner\'s voice: $word',
        );
      }
    });

    testWidgets('a response is shown verbatim and attributed', (tester) async {
      await pump(tester, todayFixture());
      expect(find.textContaining('I noticed your care.'), findsOneWidget);
      expect(find.textContaining('MORGAN RESPONDED'), findsOneWidget);
    });

    testWidgets('no response means nothing warm is fabricated', (tester) async {
      await pump(tester, todayFixture(response: null));
      for (final phrase in [
        'Well done',
        'Great job',
        'Proud of you',
        'Nice work',
      ]) {
        expect(
          allText(tester).contains(phrase),
          isFalse,
          reason: 'the gap where a response would be must stay empty',
        );
      }
    });
  });

  group('direction comes from a person', () {
    testWidgets('an expectation shows who set it', (tester) async {
      await pump(tester, todayFixture());
      expect(find.textContaining('From Morgan'), findsWidgets);
    });

    testWidgets('partner presence is named, not implied', (tester) async {
      await pump(tester, todayFixture());
      expect(find.textContaining('Morgan is present'), findsOneWidget);
    });
  });

  group('completion is not acknowledgement', () {
    testWidgets('a completed item reads as waiting, never as answered', (
      tester,
    ) async {
      await pump(
        tester,
        todayFixture(
          priority: const [
            TodayItem(
              occurrenceId: 'o1',
              title: 'Done thing',
              state: 'WAITING_ACK',
            ),
          ],
          response: null,
        ),
      );

      expect(find.textContaining('Waiting for a reply'), findsOneWidget);
      expect(allText(tester).contains('Acknowledged'), isFalse);
    });
  });

  group('copy protects the person', () {
    testWidgets('backend state names never leak', (tester) async {
      await pump(
        tester,
        todayFixture(
          priority: const [
            TodayItem(occurrenceId: 'o1', title: 'x', state: 'NEED_TO_DISCUSS'),
          ],
        ),
      );
      expect(find.textContaining('Being discussed'), findsOneWidget);
      for (final raw in [
        'NEED_TO_DISCUSS',
        'WAITING_ACK',
        'NEEDS_REVIEW',
        'EXCUSE_REQUESTED',
      ]) {
        expect(allText(tester).contains(raw), isFalse, reason: raw);
      }
    });

    testWidgets('a day is not a work queue', (tester) async {
      await pump(tester, todayFixture());
      // A miss is not disobedience, and lateness is not the frame here.
      for (final word in ['overdue', 'late', 'missed', 'backlog', 'task']) {
        expect(
          allText(tester).toLowerCase().contains(word),
          isFalse,
          reason: 'this is a person\'s day, not a queue: "$word"',
        );
      }
    });

    testWidgets('no gamification vocabulary', (tester) async {
      await pump(tester, todayFixture());
      for (final word in [
        'points',
        'streak',
        'score',
        'trophy',
        'badge',
        'level',
      ]) {
        expect(
          allText(tester).toLowerCase().contains(word),
          isFalse,
          reason: word,
        );
      }
    });

    testWidgets('an empty day is stated plainly, not padded', (tester) async {
      await pump(
        tester,
        todayFixture(priority: const [], later: const [], response: null),
      );
      expect(find.text('Nothing is expected of you today.'), findsOneWidget);
      // No invented urgency, and the optional check-in stays optional.
      expect(allText(tester).toLowerCase().contains('should'), isFalse);
      expect(allText(tester).toLowerCase().contains('must'), isFalse);
    });
  });

  group('agency is structural', () {
    testWidgets('all three adjustments are offered beside completion', (
      tester,
    ) async {
      await pump(tester, todayFixture());
      expect(find.text('Complete'), findsOneWidget);
      expect(find.text('Discuss'), findsOneWidget);
      expect(find.text('New time'), findsOneWidget);
      expect(find.text("Can't do"), findsOneWidget);
    });

    testWidgets('adjustment actions keep their own touch targets', (
      tester,
    ) async {
      await pump(tester, todayFixture());
      for (final label in ['Discuss', 'New time', "Can't do"]) {
        final box = tester.getSize(
          find
              .ancestor(of: find.text(label), matching: find.byType(SizedBox))
              .first,
        );
        expect(
          box.height,
          greaterThanOrEqualTo(48),
          reason: '$label must remain reachable',
        );
      }
    });

    testWidgets('no adjustment is framed as a failure', (tester) async {
      await pump(tester, todayFixture());
      for (final word in ['failed', 'failure', 'excuse', 'sorry', 'penalty']) {
        expect(
          allText(tester).toLowerCase().contains(word),
          isFalse,
          reason: 'adjustment is a normal path: "$word"',
        );
      }
    });
  });

  group('recovery states protect the person', () {
    Future<void> pumpState(WidgetTester tester, TodayFixtureState state) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            todayRepositoryProvider.overrideWithValue(
              FixtureTodayRepository(null, state) as TodayRepository,
            ),
          ],
          child: MaterialApp(
            theme: DsTheme.ritual(),
            home: const TodayScreen(dynamicId: 'd1'),
          ),
        ),
      );
      // A rejected Future reaches the provider on the next microtask drain,
      // so a single pump still shows the loading state.
      //
      // Loading is pumped rather than settled: its skeleton pulses for as long
      // as it is on screen, which is the point, and `pumpAndSettle` waits for
      // an animation that is never meant to end.
      if (state == TodayFixtureState.loading) {
        await tester.pump();
      } else {
        await tester.pumpAndSettle();
      }
    }

    testWidgets('no partner is named until access is confirmed', (
      tester,
    ) async {
      // The header once hardcoded a name, so every recovery state claimed a
      // partner was present while the server was still being consulted.
      for (final state in [
        TodayFixtureState.loading,
        TodayFixtureState.offline,
        TodayFixtureState.authorizationLost,
        TodayFixtureState.unavailable,
      ]) {
        await pumpState(tester, state);
        expect(
          allText(tester).contains('is present'),
          isFalse,
          reason: '\$state must not imply partner presence',
        );
      }
    });

    testWidgets('offline withdraws every action and dates what it shows', (
      tester,
    ) async {
      await pumpState(tester, TodayFixtureState.offline);
      expect(find.textContaining('OFFLINE'), findsOneWidget);
      expect(find.textContaining('Read-only'), findsOneWidget);
      // Cached content is never presented as current.
      expect(
        find.textContaining('never treated as a new state'),
        findsOneWidget,
      );
      expect(find.text('Complete'), findsNothing);
    });

    testWidgets('authorization loss removes all protected content', (
      tester,
    ) async {
      await pumpState(tester, TodayFixtureState.authorizationLost);
      expect(find.textContaining('PRIVATE SESSION ENDED'), findsOneWidget);
      // No item, no partner, no response may survive.
      expect(allText(tester).contains('Morgan'), isFalse);
      expect(allText(tester).contains('Prepare the bedroom'), isFalse);
      expect(allText(tester).contains('I noticed your care'), isFalse);
    });
  });

  group('server truth', () {
    testWidgets('items render in server order, never re-sorted', (
      tester,
    ) async {
      await pump(
        tester,
        todayFixture(
          priority: const [
            TodayItem(occurrenceId: 'z', title: 'Zulu first', state: 'ACTIVE'),
            TodayItem(
              occurrenceId: 'a',
              title: 'Alpha second',
              state: 'ACTIVE',
            ),
          ],
          later: const [],
          response: null,
        ),
      );

      final zulu = tester.getTopLeft(find.textContaining('Zulu first')).dy;
      final alpha = tester.getTopLeft(find.textContaining('Alpha second')).dy;
      expect(
        zulu,
        lessThan(alpha),
        reason: 'the server composes the order; the client renders it',
      );
    });

    testWidgets('the relationship day comes from the server', (tester) async {
      await pump(tester, todayFixture());
      // A ListView builds lazily, so reach it the way a person would.
      await tester.scrollUntilVisible(
        find.textContaining('Relationship day'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.textContaining('Relationship day'), findsOneWidget);
    });

    testWidgets('later items stay behind one count-bearing disclosure', (
      tester,
    ) async {
      await pump(tester, todayFixture());
      await tester.scrollUntilVisible(
        find.text('Show'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('5'), findsOneWidget);
      expect(find.textContaining("Read Morgan's note"), findsNothing);

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();
      expect(find.textContaining("Read Morgan's note"), findsOneWidget);
    });

    testWidgets('an item\'s kind comes from the server, not its wording', (
      tester,
    ) async {
      // REQ-STATE-001. The two cases disagree on purpose. A person who names
      // a task "Evening ritual reminder" has written a TASK; one who names a
      // ritual "Prepare the bedroom" has written a RITUAL. Inferring the kind
      // from the title got both backwards, silently reclassifying an item by
      // its author's own wording and changing which mark it drew.
      await pump(
        tester,
        todayFixture(
          priority: const [
            TodayItem(
              occurrenceId: 'k1',
              title: 'Evening ritual reminder',
              kind: 'TASK',
              state: 'ACTIVE',
            ),
          ],
          later: const [],
        ),
      );
      expect(find.textContaining('EXPECTATION'), findsOneWidget);
      expect(find.textContaining('RITUAL'), findsNothing);

      await pump(
        tester,
        todayFixture(
          priority: const [
            TodayItem(
              occurrenceId: 'k2',
              title: 'Prepare the bedroom',
              kind: 'RITUAL',
              state: 'ACTIVE',
            ),
          ],
          later: const [],
        ),
      );
      expect(find.textContaining('RITUAL'), findsOneWidget);
    });

    testWidgets('the mark states the kind, not the row position', (
      tester,
    ) async {
      // SCR-01 §4 registers every mark as an *identity*: `mark.authority` is
      // "Priority/expectation identity", `emblem.ritual.evening` is "Evening
      // ritual identity". The primary card hard-coded the authority mark, so
      // a ritual in first position said RITUAL and drew the wrong emblem.
      await pump(
        tester,
        todayFixture(
          priority: const [
            TodayItem(
              occurrenceId: 'k3',
              title: 'Prepare the bedroom',
              kind: 'RITUAL',
              state: 'ACTIVE',
            ),
          ],
          later: const [],
        ),
      );

      final marks = tester
          .widgetList<DsSvg>(find.byType(DsSvg))
          .map((w) => w.asset)
          .toList();
      expect(marks, contains(DsAssets.emblemRitualEvening));
      expect(marks, isNot(contains(DsAssets.markAuthority)));
    });

    testWidgets('the day boundary is the one the Dynamic chose', (
      tester,
    ) async {
      // REQ-STATE-001. The screen used to state a hard-coded "2:00 AM" while
      // the server owned `day_boundary_minutes`, so any Dynamic on a different
      // boundary was told the wrong time by a widget whose own comment claimed
      // the value came from the server. 5:30 AM is deliberately not the
      // default.
      await pump(
        tester,
        todayFixture().copyWith(dayBoundaryMinutes: 330),
      );
      await tester.scrollUntilVisible(
        find.textContaining('Relationship day ends'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('Relationship day ends at 5:30 AM'), findsOneWidget);
    });

    testWidgets('only the actions the server permits are offered', (
      tester,
    ) async {
      // REQ-STATE-001 names entitlement explicitly. Verified against a live
      // server: a partner who has asked to discuss an expectation gets
      // allowedActions ['withdraw'] from GET /v1/occurrences/{id}, while Today
      // rendered Complete / Discuss / New time / Can't do — four actions, none
      // of them the permitted one.
      await pump(
        tester,
        todayFixture(
          priority: const [
            TodayItem(
              occurrenceId: 'a1',
              title: 'Prepare the evening space',
              state: 'NEED_TO_DISCUSS',
              allowedActions: ['withdraw'],
            ),
          ],
          later: const [],
        ),
      );

      expect(find.text('Complete'), findsNothing);
      expect(find.text('Discuss'), findsNothing);
      expect(find.text('New time'), findsNothing);
      expect(find.text("Can't do"), findsNothing);
      // The item itself is still shown — losing an action is not losing the
      // item, and the state is what tells the person where it stands.
      expect(find.textContaining('Prepare the evening space'), findsOneWidget);
      expect(find.textContaining('Being discussed'), findsOneWidget);
      // And the one action the server DOES permit is offered. Until withdraw
      // was implemented this card showed no action at all, so the person who
      // asked to discuss something could only wait for the other to answer.
      expect(find.text('Take it back'), findsOneWidget);
    });

    testWidgets('what the server did not say is not invented', (tester) async {
      // A client newer than its server. `kind` and `dayBoundaryMinutes` are
      // rollout concessions (plan item T1.6 has not redeployed staging), so
      // they can arrive absent — but absent must read as unknown, never as a
      // guessed fact. The old defaults asserted TASK and 2:00 AM.
      await pump(
        tester,
        todayFixture(
          priority: const [
            TodayItem(
              occurrenceId: 'u1',
              title: 'Something from an older server',
              state: 'ACTIVE',
              allowedActions: ['complete'],
            ),
          ],
          later: const [],
        ).copyWith(dayBoundaryMinutes: null),
      );

      // Neither kind is claimed.
      expect(find.textContaining('EXPECTATION'), findsNothing);
      expect(find.textContaining('RITUAL'), findsNothing);
      expect(find.textContaining('ON TODAY'), findsOneWidget);
      // No boundary is stated at all, rather than a time nobody chose.
      expect(find.textContaining('Relationship day ends'), findsNothing);
    });

    testWidgets('a due time reads in the Dynamic\'s zone, not the device\'s', (
      tester,
    ) async {
      // REQ-TIME-001: "device timezone changes do not silently move a
      // relationship day". `toLocal()` showed a partner in another zone a
      // different hour than the one their partner set — the exact failure for
      // the long-distance couple this product is built for.
      //
      // 2026-08-29T18:30Z is 8:30 PM in Berlin (CEST) and 2:30 PM in New York,
      // whatever the machine running this test believes.
      tzdata.initializeTimeZones();
      const item = TodayItem(
        occurrenceId: 'z1',
        title: 'Prepare the evening space',
        kind: 'TASK',
        state: 'ACTIVE',
        allowedActions: ['complete'],
      );
      final dueAt = DateTime.utc(2026, 8, 29, 18, 30);

      await pump(
        tester,
        todayFixture(
          priority: [item.copyWith(dueAt: dueAt)],
          later: const [],
        ).copyWith(referenceTimezone: 'Europe/Berlin'),
      );
      expect(find.textContaining('8:30 PM'), findsOneWidget);

      await pump(
        tester,
        todayFixture(
          priority: [item.copyWith(dueAt: dueAt)],
          later: const [],
        ).copyWith(referenceTimezone: 'America/New_York'),
      );
      expect(find.textContaining('2:30 PM'), findsOneWidget);
    });
  });

}
