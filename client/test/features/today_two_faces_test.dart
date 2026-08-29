import 'package:dsapp/app/providers.dart';
import 'package:dsapp/domain_client/models/today_view.dart';
import 'package:dsapp/domain_client/repositories/today_repository.dart';
import 'package:dsapp/features/today/presentation/today_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _Repo extends Mock implements TodayRepository {}

void main() {
  late _Repo repo;
  setUp(() => repo = _Repo());

  var opened = 0;

  Future<void> pump(WidgetTester tester, TodayView v) async {
    opened = 0;
    await tester.binding.setSurfaceSize(const Size(390, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    when(() => repo.forDynamic(any())).thenAnswer((_) async => v);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [todayRepositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(
          home: TodayScreen(dynamicId: 'd1', onOpenAttention: () => opened++),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  String allText(WidgetTester tester) => tester
      .widgetList<Text>(find.byType(Text))
      .map((t) => t.data ?? '')
      .join(' | ');

  group('Today has two faces', () {
    testWidgets('the receiving side sees no direction-giving entry', (
      tester,
    ) async {
      await pump(
        tester,
        const TodayView(
          needsMyResponseCount: 0,
          priorityItems: [
            TodayItem(
              occurrenceId: 'o1',
              title: 'Prepare the evening space',
              purpose: 'Something small.',
              state: 'ACTIVE',
            ),
          ],
        ),
      );

      // Nothing is waiting on this person, so Today stays a single surface.
      expect(allText(tester).contains('need your response'), isFalse);
      expect(find.text('Prepare the evening space'), findsOneWidget);
    });

    testWidgets('the direction-giving side is offered the way in', (
      tester,
    ) async {
      await pump(tester, const TodayView(needsMyResponseCount: 2));

      expect(
        find.textContaining('Someone is waiting to hear from you'),
        findsOneWidget,
      );
      await tester.tap(
        find.textContaining('Someone is waiting to hear from you'),
      );
      await tester.pumpAndSettle();
      expect(opened, 1);
    });

    testWidgets('both faces can appear at once', (tester) async {
      // Direction-giving is recorded per expectation, so the same person can
      // be on both sides of the same dynamic on the same day.
      await pump(
        tester,
        const TodayView(
          needsMyResponseCount: 1,
          priorityItems: [
            TodayItem(
              occurrenceId: 'o1',
              title: 'Evening check-in',
              purpose: 'A few words.',
              state: 'ACTIVE',
            ),
          ],
        ),
      );

      expect(
        find.textContaining('Someone is waiting to hear from you'),
        findsOneWidget,
      );
      expect(find.text('Evening check-in'), findsOneWidget);
    });

    testWidgets('a partner\'s words outrank the routing row', (tester) async {
      await pump(
        tester,
        TodayView(
          needsMyResponseCount: 2,
          recentResponse: RecentResponse(
            occurrenceId: 'o1',
            title: 'Prepare the evening space',
            type: 'PRAISE',
            text: 'I noticed the care you put into this.',
            sentAt: DateTime(2026, 8, 28, 20, 6),
            senderDisplayName: 'Alex',
          ),
        ),
      );

      // The highest-value content on the whole screen must not lose first
      // position to administration. This was previously stated in a comment
      // while the widget tree did the opposite, so it is asserted on
      // geometry rather than on intent.
      final words = tester.getTopLeft(
        find.text('I noticed the care you put into this.'),
      );
      final door = tester.getTopLeft(
        find.textContaining('Someone is waiting to hear from you'),
      );
      expect(
        words.dy < door.dy,
        isTrue,
        reason: 'the response is a moment; the Attention row is a door',
      );
    });

    testWidgets('it says a person is waiting, never that something is late', (
      tester,
    ) async {
      await pump(tester, const TodayView(needsMyResponseCount: 3));

      expect(allText(tester), contains('Someone is waiting to hear from you'));
      // A Miss is not disobedience and lateness is not the frame here.
      for (final banned in [
        'overdue',
        'late',
        'missed',
        'pending',
        'due',
        'backlog',
        'tasks',
      ]) {
        expect(
          allText(tester).toLowerCase().contains(banned),
          isFalse,
          reason: 'this is a person waiting, not a queue: "$banned"',
        );
      }
    });

    testWidgets('an empty day is still stated when nothing needs anyone', (
      tester,
    ) async {
      await pump(tester, const TodayView(needsMyResponseCount: 0));
      expect(find.text('Nothing is expected of you today.'), findsOneWidget);
    });
  });
}
