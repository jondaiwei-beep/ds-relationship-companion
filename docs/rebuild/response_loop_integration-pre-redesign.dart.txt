import 'package:dsapp/app/providers.dart';
import 'package:dsapp/domain_client/models/occurrence.dart';
import 'package:dsapp/domain_client/models/occurrence_view.dart';
import 'package:dsapp/domain_client/repositories/occurrence_repository.dart';
import 'package:dsapp/features/today/presentation/occurrence_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';

class _Repo extends Mock implements OccurrenceRepository {}

/// End-to-end client verification of the human-response loop.
///
/// Drives the REAL widget tree through the real state transitions, asserting
/// that each server state renders the correct screen and that the commands
/// fired are the ones the domain expects.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late _Repo repo;
  setUp(() => repo = _Repo());

  OccurrenceView view(OccurrenceState state, {AcknowledgementView? ack, List<String> actions = const []}) =>
      OccurrenceView(
        id: 'o1',
        title: 'Prepare the evening space',
        purpose: 'A small act of care.',
        state: state,
        completedAt: state == OccurrenceState.waitingAck || state == OccurrenceState.acknowledged
            ? DateTime(2026, 8, 27, 19, 42)
            : null,
        acknowledgement: ack,
        allowedActions: actions,
      );

  Future<void> boot(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(ProviderScope(
      overrides: [occurrenceRepositoryProvider.overrideWithValue(repo)],
      child: const MaterialApp(home: OccurrenceScreen(occurrenceId: 'o1')),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('receiving side: ACTIVE renders the expectation with adjustment offered',
      (tester) async {
    when(() => repo.get(any())).thenAnswer((_) async =>
        view(OccurrenceState.active, actions: ['complete', 'discuss', 'reschedule', 'cant_do']));

    await boot(tester);

    expect(find.text('Prepare the evening space'), findsOneWidget);
    expect(find.text('Complete'), findsOneWidget);
    // Red line #3: adjustment sits beside completion, never hidden.
    expect(find.text('Need to discuss'), findsOneWidget);
    expect(find.text('Request a new time'), findsOneWidget);
  });

  testWidgets('completing calls the command and re-reads SERVER state', (tester) async {
    var completed = false;
    when(() => repo.get(any())).thenAnswer((_) async => completed
        ? view(OccurrenceState.waitingAck)
        : view(OccurrenceState.active, actions: ['complete', 'discuss']));
    when(() => repo.complete(any(), note: any(named: 'note'),
            idempotencyKey: any(named: 'idempotencyKey')))
        .thenAnswer((_) async => completed = true);

    await boot(tester);
    await tester.tap(find.text('Complete'));
    await tester.pumpAndSettle();
    // The refetch after invalidate is async; give it a frame to resolve.
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    // The command fired with an idempotency key...
    verify(() => repo.complete('o1', note: any(named: 'note'),
        idempotencyKey: any(named: 'idempotencyKey'))).called(1);
    // ...and the UI followed the SERVER's new state, not a local guess.
    expect(find.textContaining('WAITING FOR HUMAN RESPONSE'), findsOneWidget);
    expect(find.textContaining('Done'), findsOneWidget);
  });

  testWidgets('WAITING_ACK never claims the partner has responded', (tester) async {
    when(() => repo.get(any())).thenAnswer((_) async => view(OccurrenceState.waitingAck));
    await boot(tester);

    // Red line #2.
    expect(find.textContaining('You were seen'), findsNothing);
    expect(find.textContaining('Acknowledged'), findsNothing);
  });

  testWidgets('direction-giving side sees Respond and sending requires typed words',
      (tester) async {
    when(() => repo.get(any())).thenAnswer((_) async =>
        view(OccurrenceState.waitingAck, actions: ['acknowledge', 'praise', 'comment']));
    when(() => repo.acknowledge(any(), type: any(named: 'type'), text: any(named: 'text'),
            idempotencyKey: any(named: 'idempotencyKey')))
        .thenAnswer((_) async {});

    await boot(tester);

    expect(find.text('Send acknowledgement'), findsOneWidget);

    // Red line #1: pressing send with an empty field must do nothing.
    await tester.tap(find.text('Send acknowledgement'));
    await tester.pumpAndSettle();
    verifyNever(() => repo.acknowledge(any(), type: any(named: 'type'),
        text: any(named: 'text'), idempotencyKey: any(named: 'idempotencyKey')));

    await tester.enterText(find.byType(TextField), 'I noticed the care.');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Send acknowledgement'));
    await tester.pumpAndSettle();

    verify(() => repo.acknowledge('o1', type: 'ACKNOWLEDGE', text: 'I noticed the care.',
        idempotencyKey: any(named: 'idempotencyKey'))).called(1);
  });

  testWidgets('ACKNOWLEDGED shows the human response attributed to the sender',
      (tester) async {
    when(() => repo.get(any())).thenAnswer((_) async => view(
          OccurrenceState.acknowledged,
          ack: AcknowledgementView(
            type: 'PRAISE',
            text: 'I noticed the care you put into this.',
            sentAt: DateTime(2026, 8, 27, 20, 6),
            senderDisplayName: 'Alex',
          ),
        ));

    await boot(tester);

    expect(find.text('You were seen.'), findsOneWidget);
    expect(find.text('I noticed the care you put into this.'), findsOneWidget);
    expect(find.text('FROM ALEX'), findsOneWidget);
  });

  testWidgets('a load failure offers recovery rather than a dead end', (tester) async {
    when(() => repo.get(any())).thenThrow(Exception('network'));
    await boot(tester);

    // Notion 02 §11: no dead ends.
    expect(find.text('Try again'), findsOneWidget);
    expect(find.textContaining('nothing was lost'), findsOneWidget);
  });
}
