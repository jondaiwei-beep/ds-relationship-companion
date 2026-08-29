import 'package:dsapp/app/providers.dart';
import 'package:dsapp/domain_client/models/today_view.dart';
import 'package:dsapp/domain_client/repositories/today_repository.dart';
import 'package:dsapp/features/today/presentation/today_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockTodayRepo extends Mock implements TodayRepository {}

void main() {
  late _MockTodayRepo repo;
  setUp(() => repo = _MockTodayRepo());

  Future<void> pump(WidgetTester tester, TodayView view) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    when(() => repo.forDynamic(any())).thenAnswer((_) async => view);
    await tester.pumpWidget(ProviderScope(
      overrides: [todayRepositoryProvider.overrideWithValue(repo)],
      child: const MaterialApp(home: TodayScreen(dynamicId: 'd1')),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('the system never speaks in the Dom voice', (tester) async {
    await pump(tester, const TodayView());

    // Hardcoding an honorific would make the app speak as the partner.
    // SCR-01 rev 2 heads the screen with the surface name and nothing else.
    expect(find.text('Today'), findsOneWidget);
    expect(find.textContaining('Sir'), findsNothing);
    expect(find.textContaining('Master'), findsNothing);
  });

  testWidgets('an expectation shows who it came from', (tester) async {
    await pump(tester, const TodayView(priorityItems: [
      TodayItem(occurrenceId: 'o1', title: 'Prepare the evening space',
          purpose: 'A small act of care.', state: 'ACTIVE', fromDisplayName: 'Alex'),
    ]));

    // Direction comes from a person, and the row says whose.
    expect(find.textContaining('From Alex'), findsOneWidget);
    expect(find.text('Prepare the evening space'), findsOneWidget);
  });

  testWidgets('a recent human response is shown verbatim and attributed',
      (tester) async {
    await pump(tester, TodayView(recentResponse: RecentResponse(
      occurrenceId: 'o1', title: 'Prepare the evening space', type: 'PRAISE',
      text: 'I noticed the care you put into this.',
      sentAt: DateTime(2026, 8, 27, 20, 6), senderDisplayName: 'Alex',
    )));

    expect(find.text('I noticed the care you put into this.'), findsOneWidget);
    // Attributed to the person who sent it, never anonymous.
    expect(find.textContaining('ALEX'), findsOneWidget);
  });

  testWidgets('no response yet means nothing warm is fabricated', (tester) async {
    await pump(tester, const TodayView(awaitingResponse: [
      TodayItem(occurrenceId: 'o1', title: 'Done thing', state: 'WAITING_ACK'),
    ]));

    // The system must not invent encouragement to fill the gap.
    expect(find.textContaining('Well done'), findsNothing);
    expect(find.textContaining('Great job'), findsNothing);
    expect(find.textContaining('Proud'), findsNothing);
  });

  testWidgets('completing is not being seen', (tester) async {
    await pump(tester, const TodayView(priorityItems: [
      TodayItem(occurrenceId: 'o1', title: 'Done thing', state: 'WAITING_ACK'),
    ]));

    // A completed item is waiting on a human, and must never read as though
    // the response already arrived.
    expect(find.textContaining('Waiting for a reply'), findsOneWidget);
    expect(find.textContaining('Acknowledged'), findsNothing);
  });

  testWidgets('backend state names never leak', (tester) async {
    await pump(tester, const TodayView(priorityItems: [
      TodayItem(occurrenceId: 'o1', title: 'x', state: 'NEED_TO_DISCUSS'),
    ]));

    expect(find.text('Being discussed'), findsOneWidget);
    expect(find.textContaining('NEED_TO_DISCUSS'), findsNothing);
  });

  testWidgets('empty Today is stated plainly, not padded with filler',
      (tester) async {
    await pump(tester, const TodayView());
    expect(find.text('Nothing is expected of you today.'), findsOneWidget);
  });

  testWidgets('no gamification vocabulary', (tester) async {
    await pump(tester, const TodayView(priorityItems: [
      TodayItem(occurrenceId: 'o1', title: 'x', state: 'ACTIVE'),
    ]));
    final banned = RegExp(r'\b(points|streaks?|scores?|trophy|badges?)\b',
        caseSensitive: false);
    expect(
      find.byWidgetPredicate((w) => w is Text && w.data != null && banned.hasMatch(w.data!)),
      findsNothing,
    );
  });
}
