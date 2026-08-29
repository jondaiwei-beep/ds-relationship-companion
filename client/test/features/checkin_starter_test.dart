import 'package:dsapp/app/providers.dart';
import 'package:dsapp/domain_client/models/check_in_view.dart';
import 'package:dsapp/domain_client/models/starter_rhythm_view.dart';
import 'package:dsapp/domain_client/repositories/starter_rhythm_repository.dart';
import 'package:dsapp/features/activation/presentation/starter_rhythm_screen.dart';
import 'package:dsapp/design_system/components/ds_button.dart';
import 'package:dsapp/features/today/presentation/check_in_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _StarterRepo extends Mock implements StarterRhythmRepository {}

void main() {
  group('Check-in', () {
    Future<void> pump(
      WidgetTester tester, {
      Future<void> Function({
        String? mood,
        String? energy,
        String? need,
        String? note,
        required CheckInVisibility visibility,
      })? onSubmit,
    }) async {
      await tester.binding.setSurfaceSize(const Size(390, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CheckInSheet(
            framing: 'How is your energy today?',
            onSubmit: onSubmit ??
                ({mood, energy, need, note, required visibility}) async {},
          ),
        ),
      ));
      await tester.pumpAndSettle();
    }

    testWidgets('PRIVATE is the default - sharing is a deliberate act',
        (tester) async {
      CheckInVisibility? got;
      await pump(tester, onSubmit: ({mood, energy, need, note, required visibility}) async {
        got = visibility;
      });

      // Notion 04 §3 forbids "you're in a dynamic so it's obviously shared".
      expect(find.text('Keep private'), findsOneWidget);
      await tester.tap(find.text('Keep private'));
      await tester.pumpAndSettle();
      expect(got, CheckInVisibility.private);
    });

    testWidgets('the visibility choice is visible, not buried in settings',
        (tester) async {
      await pump(tester);

      expect(find.text('WHO CAN SEE THIS'), findsOneWidget);
      expect(find.text('Just me'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
      expect(find.text('Kept private.'), findsOneWidget);
    });

    testWidgets('choosing Share changes both the button and what is sent',
        (tester) async {
      CheckInVisibility? got;
      await pump(tester, onSubmit: ({mood, energy, need, note, required visibility}) async {
        got = visibility;
      });

      // Pick the "Share" visibility option (the one inside the option card).
      await tester.tap(find.widgetWithText(InkWell, 'Share'));
      await tester.pumpAndSettle();

      // The primary button now reads "Share" too, so target it by type.
      await tester.tap(find.byType(DsButton));
      await tester.pumpAndSettle();
      expect(got, CheckInVisibility.shared);
    });

    testWidgets('nothing is required - an empty check-in can be saved',
        (tester) async {
      var submitted = false;
      await pump(tester, onSubmit: ({mood, energy, need, note, required visibility}) async {
        submitted = true;
      });

      // A check-in with nothing filled in is still a valid signal.
      await tester.tap(find.text('Keep private'));
      await tester.pumpAndSettle();
      expect(submitted, isTrue);
    });

    testWidgets('no judgement vocabulary', (tester) async {
      await pump(tester);

      final banned = RegExp(r'\b(fail\w*|excuse|justify|reason required|should)\b',
          caseSensitive: false);
      expect(
        find.byWidgetPredicate((w) => w is Text && w.data != null && banned.hasMatch(w.data!)),
        findsNothing,
      );
    });
  });

  group('Starter Rhythm', () {
    late _StarterRepo repo;
    setUp(() => repo = _StarterRepo());

    const proposal = StarterRhythmProposal(
      ritualTitle: 'Evening check-in',
      ritualPurpose: 'A pause for presence before the day closes.',
      expectationTitle: 'Prepare the evening space',
      expectationPurpose: 'A small act of care before you reconnect.',
      checkInFraming: 'How is your energy today?',
      optionalSecondTitle: 'Make them a drink the way they like it',
      optionalSecondPurpose: 'Attention to a detail you already know.',
    );

    Future<void> pump(WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      when(() => repo.propose(any())).thenAnswer((_) async => proposal);
      when(() => repo.start(any(),
          assigneeUserId: any(named: 'assigneeUserId'),
          ritualTitle: any(named: 'ritualTitle'),
          expectationTitle: any(named: 'expectationTitle'),
          includeSecondExpectation: any(named: 'includeSecondExpectation'),
          idempotencyKey: any(named: 'idempotencyKey'))).thenAnswer((_) async {});

      await tester.pumpWidget(ProviderScope(
        overrides: [starterRhythmRepositoryProvider.overrideWithValue(repo)],
        child: const MaterialApp(
          home: StarterRhythmScreen(dynamicId: 'd1', assigneeUserId: 'u1'),
        ),
      ));
      await tester.pumpAndSettle();
    }

    testWidgets('uses the canonical copy contract', (tester) async {
      await pump(tester);

      // Notion 05 §3 fixes this wording.
      expect(find.textContaining("Here's a starting"), findsOneWidget);
      expect(find.textContaining("Keep what feels right"), findsOneWidget);
    });

    testWidgets('shows exactly three things by default', (tester) async {
      await pump(tester);

      expect(find.text('A STEADY RITUAL'), findsOneWidget);
      expect(find.text('ONE EXPECTATION'), findsOneWidget);
      expect(find.text('A SIMPLE CHECK-IN'), findsOneWidget);
    });

    testWidgets('the second expectation is OPT-IN, unchecked by default',
        (tester) async {
      await pump(tester);

      final box = tester.widget<CheckboxListTile>(find.byType(CheckboxListTile));
      // The first day must not arrive already full (Notion 05 §4).
      expect(box.value, isFalse);
    });

    testWidgets('starting passes the opt-in choice through', (tester) async {
      await pump(tester);

      await tester.tap(find.byType(CheckboxListTile));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Start this rhythm'));
      await tester.pumpAndSettle();

      verify(() => repo.start('d1',
          assigneeUserId: 'u1',
          ritualTitle: any(named: 'ritualTitle'),
          expectationTitle: any(named: 'expectationTitle'),
          includeSecondExpectation: true,
          idempotencyKey: any(named: 'idempotencyKey'))).called(1);
    });

    testWidgets('reassures that nothing here is permanent', (tester) async {
      await pump(tester);
      expect(find.text('You can change any of this later.'), findsOneWidget);
    });

    testWidgets('no gamification or obligation vocabulary', (tester) async {
      await pump(tester);

      final banned = RegExp(r'\b(points|streaks?|scores?|goal|must|required)\b',
          caseSensitive: false);
      expect(
        find.byWidgetPredicate((w) => w is Text && w.data != null && banned.hasMatch(w.data!)),
        findsNothing,
      );
    });
  });
}
