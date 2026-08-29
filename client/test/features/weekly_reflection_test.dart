import 'package:dsapp/app/providers.dart';
import 'package:dsapp/domain_client/models/us_view.dart';
import 'package:dsapp/domain_client/models/weekly_reflection_view.dart';
import 'package:dsapp/domain_client/repositories/dynamic_repository.dart';
import 'package:dsapp/features/us/presentation/us_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _Repo extends Mock implements DynamicRepository {}

void main() {
  late _Repo repo;
  setUp(() => repo = _Repo());

  final anchor = DateTime(2026, 8, 20, 21, 4);

  UsView history() => UsView(connectedDays: 4, moments: [
        RelationshipMoment(
          eventType: 'acknowledgement_sent',
          actorDisplayName: 'Alex',
          occurredAt: anchor,
          text: 'I saw it. Thank you.',
        ),
      ]);

  Future<void> pump(
    WidgetTester tester,
    WeeklyReflectionView w, {
    bool decidable = true,
  }) async {
    await tester.binding.setSurfaceSize(const Size(390, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    when(() => repo.us(any())).thenAnswer((_) async => history());
    when(() => repo.weekly(any())).thenAnswer((_) async => w);
    await tester.pumpWidget(ProviderScope(
      overrides: [dynamicRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(
        home: UsScreen(
          dynamicId: 'd1',
          onAdjust: decidable ? () {} : null,
          onPause: decidable ? () {} : null,
        ),
      ),
    ));
    await tester.pumpAndSettle();
  }

  String screenText(WidgetTester tester) => tester
      .widgetList<Text>(find.byType(Text))
      .map((t) => t.data ?? '')
      .join(' | ');

  group('Weekly reflection', () {
    testWidgets('stays hidden until the couple has a week behind them',
        (tester) async {
      await pump(tester, const WeeklyReflectionView(
        connectedDays: 2,
        adjustmentsResolved: 1,
        hasEnoughHistory: false,
      ));

      // Not merely empty — absent. A reflection on day two invites a
      // judgement about a week that has not happened.
      expect(find.text('This past week'), findsNothing);
      expect(screenText(tester).contains('yours to decide'), isFalse);
    });

    testWidgets('describes the week by what was answered', (tester) async {
      await pump(tester, WeeklyReflectionView(
        connectedDays: 4,
        adjustmentsResolved: 2,
        hasEnoughHistory: true,
        answeredMoments: [
          WeeklyMoment(
            title: 'Prepare the evening space',
            text: 'I saw it. Thank you.',
            fromDisplayName: 'Alex',
            occurredAt: anchor,
          ),
        ],
      ));

      final text = screenText(tester);
      expect(text, contains('One moment got a real response'));
      expect(text, contains('4 days you were both here'));
      // Counts stay inside ordinary prose. A tabulated number in the
      // headline is glanceable as a metric even when the copy is kind.
      expect(text, contains('You worked several things out together'));
    });

    testWidgets('the reflection synthesises; it never quotes a moment',
        (tester) async {
      await pump(tester, WeeklyReflectionView(
        connectedDays: 3,
        hasEnoughHistory: true,
        answeredMoments: [
          WeeklyMoment(
            title: 'Prepare the evening space',
            text: 'That mattered to me tonight.',
            fromDisplayName: 'Alex',
            occurredAt: anchor,
          ),
        ],
      ));

      // Quoting inside the frame puts a log entry back into it. The
      // reflection is the frame; Recently carries the particulars, where a
      // partner's words already appear verbatim and attributed.
      expect(find.text('That mattered to me tonight.'), findsNothing);
      expect(find.text('From Alex'), findsNothing);
      expect(find.textContaining('got a real response'), findsOneWidget);
    });

    testWidgets('never grades the week', (tester) async {
      await pump(tester, WeeklyReflectionView(
        connectedDays: 2,
        adjustmentsResolved: 1,
        hasEnoughHistory: true,
        answeredMoments: [
          WeeklyMoment(text: 'Well done.', fromDisplayName: 'Alex',
              occurredAt: anchor),
        ],
      ));

      final text = screenText(tester).toLowerCase();
      // No score, rate, streak, grade or progress language anywhere.
      for (final banned in [
        '%', 'score', 'rate', 'streak', 'points', 'level', 'rank',
        'goal', 'target', 'progress', 'consistency', 'performance',
      ]) {
        expect(text.contains(banned), isFalse,
            reason: 'reflection must describe, not measure: found "$banned"');
      }
    });

    testWidgets('never names a shortfall or implies disobedience',
        (tester) async {
      await pump(tester, const WeeklyReflectionView(
        connectedDays: 0,
        hasEnoughHistory: true,
      ));

      final text = screenText(tester).toLowerCase();
      // A Miss is not disobedience, and a quiet week is not a failure.
      for (final banned in [
        'missed', 'miss', 'failed', 'incomplete', 'behind', 'slipped',
        'should have', 'only', 'fell short', 'disappoint',
      ]) {
        expect(text.contains(banned), isFalse,
            reason: 'must not name a shortfall: found "$banned"');
      }
      expect(find.text('A quiet week.'), findsOneWidget);
    });

    testWidgets('offers no verdict — the decision stays with the couple',
        (tester) async {
      await pump(tester, const WeeklyReflectionView(
        connectedDays: 1,
        hasEnoughHistory: true,
      ));

      final text = screenText(tester);
      // The system asks; it does not advise. Automation prepares; the
      // partner responds.
      expect(text, contains('What rhythm feels right for the week ahead?'));
      for (final banned in [
        'we recommend', 'we suggest', 'you should', 'try to', 'consider ',
      ]) {
        expect(text.toLowerCase().contains(banned), isFalse,
            reason: 'must not advise: found "$banned"');
      }
    });

    testWidgets('no question is asked when it cannot be answered',
        (tester) async {
      await pump(tester, const WeeklyReflectionView(
        connectedDays: 3,
        hasEnoughHistory: true,
      ), decidable: false);

      // A question with no way to answer it is worse than no question. The
      // shipped screen ended in a dangling prompt because this was left to
      // the caller.
      expect(find.textContaining('What rhythm feels right'), findsNothing);
      expect(find.text('Adjust it'), findsNothing);
      // The description of the week still stands on its own.
      expect(find.textContaining('you were both here'), findsOneWidget);
    });

    testWidgets('never quotes words the history below already shows',
        (tester) async {
      // history() carries 'I saw it. Thank you.' as its most recent moment.
      await pump(tester, WeeklyReflectionView(
        connectedDays: 4,
        hasEnoughHistory: true,
        answeredMoments: [
          WeeklyMoment(
              title: 'Prepare the evening space',
              text: 'I saw it. Thank you.',
              fromDisplayName: 'Alex',
              occurredAt: anchor),
        ],
      ));

      // Repeating a partner's exact words twice on one screen makes a real
      // human response read as machine-generated.
      expect(find.text('I saw it. Thank you.'), findsOneWidget);
      // The reflection itself still appears — only the duplicate quote drops.
      expect(find.text('This past week'), findsOneWidget);
    });

    testWidgets('states the connected-day count exactly once', (tester) async {
      await pump(tester, const WeeklyReflectionView(
        connectedDays: 4,
        hasEnoughHistory: true,
      ));

      final hits = RegExp('4 days.{0,12}you were both here')
          .allMatches(screenText(tester))
          .length;
      expect(hits, 1, reason: 'the same fact must not be stated twice');
    });

    testWidgets('a failed reflection load never breaks the history below it',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      when(() => repo.us(any())).thenAnswer((_) async => history());
      when(() => repo.weekly(any())).thenThrow(Exception('offline'));
      await tester.pumpWidget(ProviderScope(
        overrides: [dynamicRepositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(
          home: UsScreen(dynamicId: 'd1', onAdjust: () {}, onPause: () {}),
        ),
      ));
      await tester.pumpAndSettle();

      // The reflection is not why anyone opened this screen.
      expect(find.text('This past week'), findsNothing);
      expect(find.text('I saw it. Thank you.'), findsOneWidget);
      expect(find.text('RECENTLY'), findsOneWidget,
          reason: 'history must still render when the reflection fails');
    });
  });
}
