import 'package:dsapp/app/providers.dart';
import 'package:dsapp/domain_client/repositories/dynamic_repository.dart';
import 'package:dsapp/domain_client/repositories/starter_rhythm_repository.dart';
import 'package:dsapp/features/activation/presentation/activation_wizard.dart';
import 'package:dsapp/platform/session/session.dart';
import 'package:dsapp/platform/session/session_controller.dart';
import 'package:dsapp/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// A JWT-shaped token whose `sub` the wizard can read. Only the payload is
/// real; nothing here verifies a signature.
const _token = 'h.'
    'eyJzdWIiOiIxMTExMTExMS0xMTExLTQxMTEtODExMS0xMTExMTExMTExMTEifQ'
    '.s';
const _me = '11111111-1111-4111-8111-111111111111';

class _FakeDynamics implements DynamicRepository {
  // `implements` on a concrete class: only the two methods the wizard calls
  // are real, and anything else fails loudly rather than silently.
  final created = <Map<String, Object?>>[];

  @override
  Future<String> create({
    String mode = 'COUPLE',
    required String desiredOutcome,
    required String structureLevel,
    required String referenceTimezone,
    int dayBoundaryMinutes = 240,
    String? side,
    String? rolePreset,
    bool longDistance = false,
    required String idempotencyKey,
  }) async {
    created.add({
      'mode': mode,
      'desiredOutcome': desiredOutcome,
      'structureLevel': structureLevel,
      'referenceTimezone': referenceTimezone,
      'dayBoundaryMinutes': dayBoundaryMinutes,
      'side': side,
      'rolePreset': rolePreset,
      'longDistance': longDistance,
    });
    return 'dyn-1';
  }

  @override
  Object noSuchMethod(Invocation i) => throw UnimplementedError('${i.memberName}');
}

class _FakeRhythm implements StarterRhythmRepository {
  final started = <String>[];

  @override
  Future<void> start(
    String dynamicId, {
    required String assigneeUserId,
    String? ritualTitle,
    String? expectationTitle,
    bool includeSecondExpectation = false,
    required String idempotencyKey,
  }) async {
    started.add(assigneeUserId);
  }

  @override
  Object noSuchMethod(Invocation i) => throw UnimplementedError('${i.memberName}');
}

void main() {
  late _FakeDynamics dynamics;
  late _FakeRhythm rhythm;
  late ProviderContainer container;

  setUp(() {
    dynamics = _FakeDynamics();
    rhythm = _FakeRhythm();
    container = ProviderContainer(
      overrides: [
        dynamicRepositoryProvider.overrideWithValue(dynamics),
        starterRhythmRepositoryProvider.overrideWithValue(rhythm),
      ],
    );
    container.read(sessionProvider.notifier).state =
        const Authenticated(accessToken: _token);
    addTearDown(container.dispose);
  });

  final needsPartner = <String>[];

  Future<List<String>> pump(
    WidgetTester tester, {
    String timezone = 'America/Los_Angeles',
  }) async {
    final started = <String>[];
    needsPartner.clear();
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: L.localizationsDelegates,
          supportedLocales: L.supportedLocales,
          home: ActivationWizard(
            timezone: timezone,
            onStarted: started.add,
            onStartedNeedsPartner: needsPartner.add,
            onLeave: () {},
          ),
        ),
      ),
    );
    await tester.pump();
    return started;
  }

  Future<void> walkToLastStep(WidgetTester tester) async {
    await tester.tap(find.text('Closer'));
    await tester.pump();
    // Goal -> role.
    await tester.tap(find.text('Continue'));
    await tester.pump();
    // Role -> structure.
    await tester.tap(find.text('Continue'));
    await tester.pump();
    // Structure -> rhythm.
    await tester.tap(find.text('Continue'));
    await tester.pump();
  }

  group('nothing exists until the last step', () {
    testWidgets('walking to the last step writes nothing', (tester) async {
      await pump(tester);
      await walkToLastStep(tester);

      expect(find.text('Start this rhythm'), findsOneWidget);
      expect(
        dynamics.created,
        isEmpty,
        reason: 'a person must be able to go back and change an answer '
            'without a Dynamic having been created behind them',
      );
    });

    testWidgets('only the last action writes', (tester) async {
      final started = await pump(tester);
      await walkToLastStep(tester);
      await tester.tap(find.text('Start this rhythm'));
      await tester.pumpAndSettle();

      expect(dynamics.created, hasLength(1));
      expect(rhythm.started, [_me]);
      expect([...started, ...needsPartner], ['dyn-1']);
    });
  });

  group('the order is the product', () {
    testWidgets('it asks what you want before who you are', (tester) async {
      await pump(tester);

      // REQ-ACT-001. A product that asks "are you dominant or submissive"
      // before "what do you want" has framed the relationship for them.
      expect(find.textContaining('What would you'), findsOneWidget);
      expect(find.text('Dominant'), findsNothing);
    });

    testWidgets('an unanswered first question says so and does not advance', (
      tester,
    ) async {
      await pump(tester);
      await tester.tap(find.text('Continue'));
      await tester.pump();

      expect(find.text('Choose one to continue.'), findsOneWidget);
      expect(find.text('1 of 5'), findsOneWidget);
    });
  });

  group('naming a role is optional', () {
    testWidgets('the wizard finishes without one', (tester) async {
      await pump(tester);
      await walkToLastStep(tester);
      await tester.tap(find.text('Start this rhythm'));
      await tester.pumpAndSettle();

      // Invariant: a couple that does not want to name a role must not be
      // blocked, and the column is nullable at every layer for that reason.
      expect(dynamics.created.single['rolePreset'], isNull);
    });

    testWidgets('declining after naming clears it', (tester) async {
      await pump(tester);
      await tester.tap(find.text('Closer'));
      await tester.pump();
      await tester.tap(find.text('Continue'));
      await tester.pump();
      await tester.tap(find.text('Dominant'));
      await tester.pump();
      await tester.tap(find.text("I'd rather not name one"));
      await tester.pump();
      await tester.tap(find.text('Continue'));
      await tester.pump();
      await tester.tap(find.text('Continue'));
      await tester.pump();
      await tester.tap(find.text('Start this rhythm'));
      await tester.pumpAndSettle();

      expect(dynamics.created.single['rolePreset'], isNull);
    });
  });

  testWidgets('the draft survives going back', (tester) async {
    await pump(tester);
    await tester.tap(find.text('Explore together'));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pump();
    // Found by what the control means, not by a Material codepoint: the icon
    // is drawn now, and a test that binds to an icon font breaks whenever the
    // picture changes without the behaviour changing.
    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pump();

    // Nothing was written, so nothing needs undoing — but the answer is still
    // there, because retyping an answer you already gave is its own friction.
    expect(find.text('1 of 5'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pump();
    expect(find.text('2 of 5'), findsOneWidget);
  });

  testWidgets('the timezone travels as the IANA name', (tester) async {
    await pump(tester, timezone: 'Europe/Berlin');
    await walkToLastStep(tester);
    await tester.tap(find.text('Start this rhythm'));
    await tester.pumpAndSettle();

    // REQ-TIME-001: an offset would survive every type check and then move
    // someone's relationship day when the clocks change.
    expect(dynamics.created.single['referenceTimezone'], 'Europe/Berlin');
  });

  testWidgets('solo and couple reach different modes', (tester) async {
    await pump(tester);
    await tester.tap(find.text('Closer'));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pump();
    await tester.tap(find.text('For myself'));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pump();

    // Solo has nobody to adjust together with.
    expect(find.text('Start light. Adjust as you go.'), findsOneWidget);

    await tester.tap(find.text('Start this rhythm'));
    await tester.pumpAndSettle();
    expect(dynamics.created.single['mode'], 'SOLO');
    // Nobody to invite.
    expect(needsPartner, isEmpty);
  });

  testWidgets('a couple is sent to invite the partner, not to an empty day', (tester) async {
    final started = await pump(tester);
    await walkToLastStep(tester);
    await tester.tap(find.text('Start this rhythm'));
    await tester.pumpAndSettle();

    expect(dynamics.created.single['mode'], 'COUPLE');
    expect(dynamics.created.single['dayBoundaryMinutes'], 240);
    expect(needsPartner, ['dyn-1']);
    expect(started, isEmpty);
  });

  testWidgets('saying you are apart reaches the server', (tester) async {
    // The wizard has always drawn this choice and always discarded it, so the
    // starter rhythm offered an apart couple "prepare the evening space".
    await pump(tester);
    await tester.tap(find.text('Closer'));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pump();

    await tester.tap(find.text('Long-distance'));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pump();
    await tester.tap(find.text('Start this rhythm'));
    await tester.pumpAndSettle();

    expect(dynamics.created.single['longDistance'], true);
  });

  testWidgets('every step fits 390x844', (tester) async {
    await pump(tester);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Closer'));
    await tester.pump();

    for (final (i, label) in [
      'Continue', // -> role
      'Continue', // -> structure
      'Continue', // -> rhythm
    ].indexed) {
      await tester.tap(find.text(label));
      await tester.pump();
      expect(tester.takeException(), isNull, reason: 'step ${i + 2} overflowed');
    }
  });

}
