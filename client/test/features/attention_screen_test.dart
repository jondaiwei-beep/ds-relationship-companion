import 'package:dsapp/app/providers.dart';
import 'package:dsapp/domain_client/models/attention_view.dart';
import 'package:dsapp/domain_client/repositories/attention_repository.dart';
import 'package:dsapp/features/attention/presentation/attention_screen.dart';
import 'package:dsapp/design_system/components/ds_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAttentionRepo extends Mock implements AttentionRepository {}

void main() {
  late _MockAttentionRepo repo;

  setUp(() => repo = _MockAttentionRepo());

  Future<void> pump(
    WidgetTester tester,
    AttentionView view, {
    void Function(String)? onOpen,
  }) async {
    await tester.binding.setSurfaceSize(const Size(390, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    when(() => repo.forDynamic(any())).thenAnswer((_) async => view);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [attentionRepositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(
          home: AttentionScreen(dynamicId: 'd1', onOpen: onOpen),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('empty Attention is presented as a good state, not a void',
      (tester) async {
    await pump(tester, const AttentionView());

    // The Dom must never be handed busywork, and an empty list must not read
    // as "something is broken".
    expect(find.textContaining('Nothing needs you'), findsOneWidget);
    expect(find.textContaining("You're up to date"), findsOneWidget);
  });

  testWidgets('renders server order, never re-sorted by recency', (tester) async {
    await pump(tester, AttentionView(
      items: [
        AttentionItem(occurrenceId: 'a', title: 'Discuss item', state: 'NEED_TO_DISCUSS',
            priority: 1, occurredAt: DateTime(2026, 8, 27, 9)),
        AttentionItem(occurrenceId: 'b', title: 'Waiting item', state: 'WAITING_ACK',
            priority: 2, actorDisplayName: 'Jamie', occurredAt: DateTime(2026, 8, 27, 19, 42)),
        AttentionItem(occurrenceId: 'c', title: 'Review item', state: 'NEEDS_REVIEW',
            priority: 3),
      ],
      needsResponseCount: 1,
    ));

    // "Waiting item" is the MOST RECENT but must not float to the top —
    // Journey C priority wins.
    final discuss = tester.getTopLeft(find.text('Discuss item')).dy;
    final waiting = tester.getTopLeft(find.text('Waiting item')).dy;
    final review = tester.getTopLeft(find.text('Review item')).dy;
    expect(discuss < waiting, isTrue, reason: 'discussion outranks awaiting response');
    expect(waiting < review, isTrue, reason: 'awaiting response outranks review');
  });

  testWidgets('a completion is attributed to the person, not the task',
      (tester) async {
    await pump(tester, AttentionView(
      items: [
        AttentionItem(occurrenceId: 'b', title: 'Prepare the evening space',
            state: 'WAITING_ACK', priority: 2, actorDisplayName: 'Jamie'),
      ],
      needsResponseCount: 1,
    ));

    expect(find.text('Jamie completed'), findsOneWidget);
  });

  testWidgets('backend state names never leak to the user', (tester) async {
    await pump(tester, const AttentionView(
      items: [
        AttentionItem(occurrenceId: 'a', title: 'x', state: 'NEEDS_REVIEW', priority: 3),
        AttentionItem(occurrenceId: 'b', title: 'y', state: 'RESCHEDULE_REQUESTED', priority: 1),
      ],
    ));

    // Notion 05 §12: NeedsReview renders as "Needs review", never as a raw
    // enum or anything resembling FAILED.
    // The band heading and the row line both say it in plain words.
    expect(find.text('NEEDS REVIEW'), findsOneWidget);
    expect(find.textContaining('asked for a new time'), findsOneWidget);
    expect(find.textContaining('NEEDS_REVIEW'), findsNothing);
    expect(find.textContaining('RESCHEDULE_REQUESTED'), findsNothing);
  });

  testWidgets('count copy is singular for one item', (tester) async {
    await pump(tester, const AttentionView(
      items: [AttentionItem(occurrenceId: 'a', title: 'x', state: 'WAITING_ACK', priority: 2)],
      needsResponseCount: 1,
    ));
    // A quiet line, not a headline: a large count reads like a score to
    // clear, and the app bar already says why you are here.
    expect(find.textContaining('1 moment needs a response'), findsOneWidget);
  });

  testWidgets('no gamification vocabulary', (tester) async {
    await pump(tester, const AttentionView(
      items: [AttentionItem(occurrenceId: 'a', title: 'x', state: 'WAITING_ACK', priority: 2)],
      needsResponseCount: 1,
    ));
    final banned = RegExp(r'\b(points|streaks?|scores?|trophy|badges?)\b',
        caseSensitive: false);
    expect(
      find.byWidgetPredicate((w) => w is Text && w.data != null && banned.hasMatch(w.data!)),
      findsNothing,
    );
  });

  testWidgets('priority is spatial, not just a sort order', (tester) async {
    await pump(tester, const AttentionView(
      items: [
        AttentionItem(occurrenceId: 'a', title: 'Talk item',
            state: 'NEED_TO_DISCUSS', priority: 1),
        AttentionItem(occurrenceId: 'b', title: 'Waiting item',
            state: 'WAITING_ACK', priority: 2),
        AttentionItem(occurrenceId: 'c', title: 'Review item',
            state: 'NEEDS_REVIEW', priority: 3),
      ],
    ));

    // A request to change course is handled before routine praise, and the
    // grouping makes that visible rather than leaving it implicit in the
    // server's ordering.
    expect(find.text('TALK ABOUT'), findsOneWidget);
    expect(find.text('WAITING FOR YOUR WORDS'), findsOneWidget);
    expect(find.text('NEEDS REVIEW'), findsOneWidget);
  });

  testWidgets('empty bands are not shown', (tester) async {
    await pump(tester, const AttentionView(
      items: [
        AttentionItem(occurrenceId: 'b', title: 'Waiting item',
            state: 'WAITING_ACK', priority: 2),
      ],
    ));
    expect(find.text('WAITING FOR YOUR WORDS'), findsOneWidget);
    expect(find.text('TALK ABOUT'), findsNothing);
    expect(find.text('NEEDS REVIEW'), findsNothing);
  });

  testWidgets('answering happens in the list, not on another page',
      (tester) async {
    var opened = 0;
    await pump(
      tester,
      const AttentionView(items: [
        AttentionItem(occurrenceId: 'b', title: 'Prepare the evening space',
            state: 'WAITING_ACK', priority: 2, actorDisplayName: 'Jamie'),
      ]),
      onOpen: (_) => opened++,
    );

    // Detouring through a detail page to say one sentence is how keeping a
    // rhythm turns into admin work.
    await tester.tap(find.text('Respond'));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
    expect(opened, 0, reason: 'responding must not navigate away');
  });

  testWidgets('the inline composer will not send words nobody wrote',
      (tester) async {
    await pump(
      tester,
      const AttentionView(items: [
        AttentionItem(occurrenceId: 'b', title: 'Prepare the evening space',
            state: 'WAITING_ACK', priority: 2, actorDisplayName: 'Jamie'),
      ]),
    );

    await tester.tap(find.text('Respond'));
    await tester.pumpAndSettle();

    // Empty is not sendable.
    var send = tester.widget<DsButton>(
        find.widgetWithText(DsButton, 'Send'));
    expect(send.onPressed, isNull);

    // Neither is an untouched suggestion: filling the field is not
    // authorship, and sending it would put words in a partner's mouth that
    // no person wrote (red line #1).
    await tester.tap(find.text('Need a starting point?'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Thank you. That mattered.'));
    await tester.pumpAndSettle();
    send = tester.widget<DsButton>(find.widgetWithText(DsButton, 'Send'));
    expect(send.onPressed, isNull);

    // Once a human writes, it goes.
    await tester.enterText(find.byType(TextField), 'Thank you. That really mattered.');
    await tester.pumpAndSettle();
    send = tester.widget<DsButton>(find.widgetWithText(DsButton, 'Send'));
    expect(send.onPressed, isNotNull);
  });

  testWidgets('only one composer is open at a time', (tester) async {
    await pump(tester, const AttentionView(items: [
      AttentionItem(occurrenceId: 'a', title: 'First',
          state: 'WAITING_ACK', priority: 2, actorDisplayName: 'Jamie'),
      AttentionItem(occurrenceId: 'b', title: 'Second',
          state: 'WAITING_ACK', priority: 2, actorDisplayName: 'Jamie'),
    ]));

    await tester.tap(find.text('Respond').first);
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);

    await tester.tap(find.text('Respond').last);
    await tester.pumpAndSettle();
    // Two half-written messages to two people is a way to send the wrong one.
    expect(find.byType(TextField), findsOneWidget);
  });
}
