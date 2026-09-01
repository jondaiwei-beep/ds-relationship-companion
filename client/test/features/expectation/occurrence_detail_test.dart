import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dsapp/l10n/app_localizations.dart';

import 'package:dsapp/app/providers.dart';
import 'package:dsapp/domain_client/models/occurrence.dart';
import 'package:dsapp/domain_client/models/occurrence_view.dart';
import 'package:dsapp/domain_client/repositories/adjustment_repository.dart';
import 'package:dsapp/domain_client/repositories/occurrence_repository.dart';
import 'package:dsapp/features/expectation/presentation/occurrence_detail_screen.dart';

class _FakeOccurrenceRepository implements OccurrenceRepository {
  _FakeOccurrenceRepository(this.view);

  final OccurrenceView view;
  int completes = 0;
  String? lastNote;

  @override
  Future<OccurrenceView> get(String id) async => view;

  @override
  Future<void> complete(
    String occurrenceId, {
    String? note,
    required String idempotencyKey,
  }) async {
    completes++;
    lastNote = note;
  }

  @override
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError();
}

OccurrenceView _view({
  OccurrenceState state = OccurrenceState.active,
  List<String> allowed = const ['complete', 'discuss', 'reschedule', 'cant_do'],
  String? purpose = 'Create a calm space for our evening ritual.',
  String? privateNote,
  AcknowledgementView? acknowledgement,
}) => OccurrenceView(
  id: 'occ-1',
  title: 'Prepare the room before 8:00 PM',
  purpose: purpose,
  state: state,
  partnerDisplayName: 'Morgan',
  privateNote: privateNote,
  acknowledgement: acknowledgement,
  allowedActions: allowed,
);

class _FakeAdjustments implements AdjustmentRepository {
  int withdrawals = 0;

  @override
  Future<void> withdraw(
    String occurrenceId, {
    required String idempotencyKey,
  }) async {
    withdrawals++;
  }

  @override
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError();
}

// ignore: library_private_types_in_public_api
late _FakeAdjustments lastAdjustments;

Future<_FakeOccurrenceRepository> _pump(
  WidgetTester tester,
  OccurrenceView view,
) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final repo = _FakeOccurrenceRepository(view);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        occurrenceRepositoryProvider.overrideWithValue(repo),
        adjustmentRepositoryProvider.overrideWithValue(
          lastAdjustments = _FakeAdjustments(),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        theme: DsTheme.ritual(),
        home: const OccurrenceDetailScreen(
          dynamicId: 'dyn-1',
          occurrenceId: 'occ-1',
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return repo;
}

void main() {
  testWidgets('the four paths are equals, all reachable here', (tester) async {
    // The preview offers only "Mark complete". The alignment work adds the
    // other three, and the acceptance criterion is that no side path reads as
    // failure — so none of them hides behind a menu.
    await _pump(tester, _view());
    expect(find.text('Mark complete'), findsOneWidget);
    expect(find.text('Discuss'), findsOneWidget);
    expect(find.text('New time'), findsOneWidget);
    expect(find.text("Can't do"), findsOneWidget);
  });

  testWidgets('the server decides which actions exist, not the screen', (
    tester,
  ) async {
    // Already asked to discuss: Complete must be gone, or one person could
    // close a loop the other has opened.
    await _pump(
      tester,
      _view(state: OccurrenceState.needToDiscuss, allowed: const ['withdraw']),
    );
    expect(find.text('Mark complete'), findsNothing);
    expect(find.text('Discuss'), findsNothing);
    expect(find.text('You asked to talk about this.'), findsOneWidget);
  });

  testWidgets('no proof and no invented words from the partner', (
    tester,
  ) async {
    // "remove Proof" in the alignment work kills Add photo. The COMPLETION
    // and BOUNDARY rows in the preview read as if the partner had said them,
    // and nothing on the server carries either.
    await _pump(tester, _view());
    expect(find.textContaining('Add photo'), findsNothing);
    expect(find.textContaining('A short note is enough'), findsNothing);
    expect(find.textContaining('Pause if this no longer feels right'),
        findsNothing);
  });

  testWidgets('a completion note reaches the server with the completion', (
    tester,
  ) async {
    final repo = await _pump(tester, _view());
    await tester.enterText(find.byType(TextField).first, 'Lit the candles');
    await tester.tap(find.text('Mark complete'));
    await tester.pumpAndSettle();

    expect(repo.completes, 1);
    expect(repo.lastNote, 'Lit the candles');
  });

  testWidgets('a private note is labelled as only theirs', (tester) async {
    await _pump(tester, _view(privateNote: 'I almost did not manage it.'));
    expect(find.text('PRIVATE NOTE · ONLY YOU'), findsOneWidget);
    expect(find.text('I almost did not manage it.'), findsOneWidget);
  });

  testWidgets("a partner's words are attributed to them, never to the app", (
    tester,
  ) async {
    // Red line #1: the system never speaks in a partner's voice, so what they
    // wrote must be unmistakably theirs.
    await _pump(
      tester,
      _view(
        state: OccurrenceState.acknowledged,
        allowed: const [],
        acknowledgement: AcknowledgementView(
          type: 'ACKNOWLEDGE',
          text: 'Thank you — I noticed.',
          sentAt: DateTime.utc(2026, 8, 31),
          senderDisplayName: 'Morgan',
        ),
      ),
    );
    expect(find.text('MORGAN WROTE'), findsOneWidget);
    expect(find.text('Thank you — I noticed.'), findsOneWidget);
  });

  testWidgets('your own open request can be taken back', (tester) async {
    // The server advertised `withdraw` from the start and nothing implemented
    // it, so a NEED_TO_DISCUSS item was a dead end for the person who asked:
    // visible everywhere, actionable nowhere until the other person answered.
    await _pump(
      tester,
      _view(
        state: OccurrenceState.needToDiscuss,
        allowed: const ['withdraw'],
      ),
    );
    expect(find.text('You asked to talk about this.'), findsOneWidget);
    expect(find.text('Never mind, take it back'), findsOneWidget);

    await tester.tap(find.text('Never mind, take it back'));
    await tester.pumpAndSettle();
    expect(lastAdjustments.withdrawals, 1);
  });

  testWidgets('taking it back is not framed as agreeing or refusing', (
    tester,
  ) async {
    await _pump(
      tester,
      _view(
        state: OccurrenceState.needToDiscuss,
        allowed: const ['withdraw'],
      ),
    );
    expect(
      find.textContaining('Nothing is recorded as agreed or refused'),
      findsOneWidget,
    );
  });

  testWidgets('waiting says so plainly, and never as a fault', (tester) async {
    await _pump(
      tester,
      _view(state: OccurrenceState.waitingAck, allowed: const []),
    );
    expect(
      find.text('Done, and waiting for them to respond.'),
      findsOneWidget,
    );
  });
}
