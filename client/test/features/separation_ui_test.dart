import 'package:dsapp/app/providers.dart';
import 'package:dsapp/domain_client/repositories/dynamic_repository.dart';
import 'package:dsapp/features/dynamic/presentation/separation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _Repo extends Mock implements DynamicRepository {}

/// The safety screen — Journey F.
///
/// Someone reaching for Block may be unsafe and may be observed. These tests
/// defend the trace, not just the behaviour: how fast it is, how much is
/// disclosed, and how little evidence it leaves.
void main() {
  late _Repo repo;
  var done = false;

  setUp(() {
    repo = _Repo();
    done = false;
    when(() => repo.leave(any(), reason: any(named: 'reason'),
        idempotencyKey: any(named: 'idempotencyKey'))).thenAnswer((_) async {});
    when(() => repo.block(any(), targetUserId: any(named: 'targetUserId'),
        reason: any(named: 'reason'),
        idempotencyKey: any(named: 'idempotencyKey'))).thenAnswer((_) async {});
  });

  Future<void> pump(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(ProviderScope(
      overrides: [dynamicRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(
        home: SeparationScreen(
          dynamicId: 'd1',
          partnerUserId: 'u2',
          partnerName: 'Alex',
          onDone: () => done = true,
        ),
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('both actions are offered together and stated as always available',
      (tester) async {
    await pump(tester);

    // Notion 04 §4: no role may disable these, so they must not be buried.
    expect(find.text('Leave this dynamic'), findsOneWidget);
    expect(find.text('Block and separate'), findsOneWidget);
    expect(find.textContaining('always available to you'), findsOneWidget);
  });

  testWidgets('Block reaches the server in TWO taps - no wizard, no typing',
      (tester) async {
    await pump(tester);

    await tester.tap(find.text('Block'));           // 1
    await tester.pumpAndSettle();
    await tester.tap(find.text('Block and seal now')); // 2
    await tester.pumpAndSettle();

    verify(() => repo.block('d1', targetUserId: 'u2', reason: any(named: 'reason'),
        idempotencyKey: any(named: 'idempotencyKey'))).called(1);
    // A long flow is visible over someone's shoulder and slows an urgent act.
    expect(find.byType(TextField), findsNothing, reason: 'no typed confirmation phrase');
  });

  testWidgets('Block discloses that it seals the ACTOR\'s own history too',
      (tester) async {
    await pump(tester);

    // Withholding an irreversible consequence is not protection.
    expect(find.textContaining('including for you'), findsOneWidget);
    expect(find.textContaining('cannot be undone'), findsOneWidget);
  });

  testWidgets('Block states the other person is not told who did it',
      (tester) async {
    await pump(tester);
    expect(find.textContaining('not told who did this'), findsOneWidget);
  });

  testWidgets('Leave says the partner KEEPS existing history', (tester) async {
    await pump(tester);

    // Leaving is gentler than blocking: the person who stayed did nothing.
    expect(find.textContaining('keeps access to the history'), findsOneWidget);
  });

  testWidgets('either action can be backed out of', (tester) async {
    await pump(tester);

    await tester.tap(find.text('Block'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Go back'));
    await tester.pumpAndSettle();

    verifyNever(() => repo.block(any(), targetUserId: any(named: 'targetUserId'),
        reason: any(named: 'reason'), idempotencyKey: any(named: 'idempotencyKey')));
  });

  testWidgets('after blocking it returns to an ordinary screen, with no fanfare',
      (tester) async {
    await pump(tester);

    await tester.tap(find.text('Block'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Block and seal now'));
    await tester.pumpAndSettle();

    // A success page or banner is itself evidence to an observer.
    expect(done, isTrue);
    expect(find.textContaining('You blocked'), findsNothing);
    expect(find.textContaining('Blocked'), findsNothing);
  });

  testWidgets('no alarming or accusatory language anywhere', (tester) async {
    await pump(tester);

    // Notion 05 §1: calm, private, intentional. An alarmed screen is a
    // conspicuous screen.
    final banned = RegExp(
      r'\b(danger|warning|abuse|abusive|report them|emergency|are you safe|victim)\b',
      caseSensitive: false,
    );
    expect(
      find.byWidgetPredicate((w) => w is Text && w.data != null && banned.hasMatch(w.data!)),
      findsNothing,
      reason: 'an alarmed screen is visible over a shoulder',
    );
  });

  testWidgets('a failure is recoverable, never a dead end', (tester) async {
    when(() => repo.block(any(), targetUserId: any(named: 'targetUserId'),
        reason: any(named: 'reason'),
        idempotencyKey: any(named: 'idempotencyKey'))).thenThrow(Exception('network'));
    await pump(tester);

    await tester.tap(find.text('Block'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Block and seal now'));
    await tester.pumpAndSettle();

    expect(done, isFalse);
    expect(find.textContaining("didn't go through"), findsOneWidget);
    // Still on the screen and still able to retry (Notion 02 §11).
    expect(find.text('Block and separate'), findsOneWidget);
  });
}
