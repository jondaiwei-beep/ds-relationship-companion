import 'package:dio/dio.dart';
import 'package:dsapp/app/providers.dart';
import 'package:dsapp/domain_client/models/starter_rhythm_view.dart';
import 'package:dsapp/domain_client/repositories/dynamic_repository.dart';
import 'package:dsapp/domain_client/repositories/starter_rhythm_repository.dart';
import 'package:dsapp/features/activation/application/activation_actions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Activation is four screens producing one command. What is asserted here is
/// the product's shape, not the wizard's: what may be left unanswered, what
/// the server is actually told, and what a retry does.
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
    addTearDown(container.dispose);
  });

  ActivationActions actions() => container.read(activationActionsProvider);

  const complete = ActivationDraft(
    outcome: DesiredOutcome.accountability,
    timezone: 'Europe/Berlin',
  );

  group('the draft', () {
    test('starts at Steady, as the approved candidate shows', () {
      expect(const ActivationDraft().structure, StructureLevel.steady);
    });

    test('is complete without a role, because naming one is optional', () {
      // Invariant: the product must never require this to be answered.
      expect(complete.rolePreset, isNull);
      expect(complete.isComplete, isTrue);
    });

    test('is not complete without an outcome', () {
      // REQ-ACT-001 asks the outcome before role or configuration, so it is
      // the one answer the wizard cannot skip.
      expect(
        const ActivationDraft(timezone: 'UTC').isComplete,
        isFalse,
      );
    });

    test('a role can be taken back off', () {
      final withRole = complete.copyWith(rolePreset: RolePreset.switchRole);
      expect(withRole.copyWith(clearRolePreset: true).rolePreset, isNull);
    });
  });

  group('creating the Dynamic', () {
    test('sends the values the server actually validates', () async {
      await actions().createDynamic(
        complete.copyWith(
          structure: StructureLevel.defined,
          rolePreset: RolePreset.switchRole,
        ),
      );

      expect(dynamics.lastOutcome, 'ACCOUNTABILITY');
      expect(dynamics.lastStructure, 'DEFINED');
      expect(
        dynamics.lastRolePreset,
        'SWITCH',
        reason: 'the wire value is SWITCH; `switch` is a Dart keyword and the '
            'enum case is named around it',
      );
      expect(dynamics.lastTimezone, 'Europe/Berlin');
      expect(dynamics.lastDayBoundaryMinutes, 240, reason: 'the day turns at 04:00, not midnight');
      expect(dynamics.lastSide, 'D', reason: 'a switch disposes; only the submissive delivers');
    });

    test('naming yourself submissive takes the s side', () async {
      await actions().createDynamic(complete.copyWith(rolePreset: RolePreset.submissive));

      expect(dynamics.lastSide, 'S');
    });

    test('sends no role when none was named', () async {
      await actions().createDynamic(complete);

      expect(dynamics.lastRolePreset, isNull);
    });

    test('refuses to send a half-formed command', () async {
      final outcome = await actions()
          .createDynamic(const ActivationDraft(timezone: 'UTC'));

      expect(outcome, isA<ActivationFailed>());
      expect(dynamics.calls, 0);
    });

    test('a retry after a lost response does not create a second Dynamic',
        () async {
      dynamics.failure = DioException.receiveTimeout(
        timeout: const Duration(seconds: 1),
        requestOptions: RequestOptions(path: '/'),
      );
      await actions().createDynamic(complete);

      dynamics.failure = null;
      await actions().createDynamic(complete);

      expect(dynamics.keys.toSet(), hasLength(1));
    });

    test('choosing "For myself" does not create a couple', () async {
      // `mode` was hardcoded to COUPLE in the repository, so the solo choice
      // on the role screen had no effect at all.
      await actions().createDynamic(complete.copyWith(solo: true));

      expect(dynamics.lastMode, 'SOLO');
    });

    test('a bare UTC offset is refused', () async {
      // REQ-TIME-001. An offset passes every type check and then moves the
      // relationship day when the clocks change — months later, looking like
      // a scheduling bug.
      for (final bad in ['+02:00', 'UTC+2', 'GMT+0200', '']) {
        final outcome = await actions()
            .createDynamic(complete.copyWith(timezone: bad));
        expect(outcome, isA<ActivationFailed>(), reason: bad);
      }
      expect(dynamics.calls, 0);
    });

    test('real IANA names are accepted', () async {
      for (final zone in ['Europe/Berlin', 'America/Los_Angeles', 'UTC',
                          'America/Argentina/Ushuaia']) {
        await actions().createDynamic(complete.copyWith(timezone: zone));
      }
      expect(dynamics.calls, 4);
    });

    test('an edited draft is a different request, not a conflicting retry',
        () async {
      // The server scopes a key to the exact body. Retrying an edited draft
      // under the original key is a conflict, not a replay.
      dynamics.failure = DioException.receiveTimeout(
        timeout: const Duration(seconds: 1),
        requestOptions: RequestOptions(path: '/'),
      );
      await actions().createDynamic(complete);

      dynamics.failure = null;
      await actions().createDynamic(
        complete.copyWith(structure: StructureLevel.defined),
      );

      expect(dynamics.keys.toSet(), hasLength(2));
    });

    test('resubmitting the same draft after success does not duplicate',
        () async {
      await actions().createDynamic(complete);
      await actions().createDynamic(complete);

      expect(
        dynamics.keys.toSet(),
        hasLength(1),
        reason: 'back-navigation and resubmit must not create a second '
            'Dynamic; the server replays the original',
      );
    });

    test('offline says so', () async {
      dynamics.failure = DioException.connectionError(
        requestOptions: RequestOptions(path: '/'),
        reason: 'offline',
      );

      final outcome = await actions().createDynamic(complete);

      expect((outcome as ActivationFailed).message, contains('offline'));
    });
  });

  group('the starter rhythm', () {
    test('proposing writes nothing', () async {
      await actions().proposeRhythm('dyn-1');

      expect(rhythm.started, 0);
    });

    test('a retry replays rather than starting a second rhythm', () async {
      await actions().startRhythm('dyn-1', assigneeUserId: 'u1');
      await actions().startRhythm('dyn-1', assigneeUserId: 'u1');

      expect(
        rhythm.keys.toSet(),
        hasLength(1),
        reason: 'a rhythm that started but whose response was lost must not '
            'become two rhythms',
      );
    });

    test('a replaced title reaches the server', () async {
      // "Replace" on the approved SCR-12 candidate.
      await actions().startRhythm(
        'dyn-1',
        assigneeUserId: 'u1',
        ritualTitle: 'A walk after dinner',
      );

      expect(rhythm.lastRitual, 'A walk after dinner');
    });
  });
}

class _FakeDynamics implements DynamicRepository {
  int calls = 0;
  final keys = <String>[];
  String? lastMode;
  String? lastOutcome;
  String? lastStructure;
  String? lastRolePreset;
  String? lastSide;
  int? lastDayBoundaryMinutes;
  String? lastTimezone;
  Object? failure;

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
    calls++;
    keys.add(idempotencyKey);
    lastMode = mode;
    lastSide = side;
    lastDayBoundaryMinutes = dayBoundaryMinutes;
    lastOutcome = desiredOutcome;
    lastStructure = structureLevel;
    lastRolePreset = rolePreset;
    lastTimezone = referenceTimezone;
    if (failure != null) throw failure!;
    return 'dyn-1';
  }

  @override
  noSuchMethod(Invocation i) =>
      throw UnimplementedError('${i.memberName} not used by this test');
}

class _FakeRhythm implements StarterRhythmRepository {
  int started = 0;
  final keys = <String>[];
  String? lastRitual;

  @override
  Future<StarterRhythmProposal> propose(String dynamicId) async =>
      const StarterRhythmProposal(
        ritualTitle: 'Evening check-in',
        ritualPurpose: 'A pause for presence before the day closes.',
        expectationTitle: "Send one message that isn't logistics",
        expectationPurpose: 'Something that is only about the two of you.',
        checkInFraming: 'Mood · Energy · Need',
        optionalSecondTitle: 'Morning intention',
        optionalSecondPurpose: 'One line about how you want today to feel.',
      );

  @override
  Future<void> start(
    String dynamicId, {
    required String assigneeUserId,
    String? ritualTitle,
    String? expectationTitle,
    bool includeSecondExpectation = false,
    required String idempotencyKey,
  }) async {
    started++;
    keys.add(idempotencyKey);
    lastRitual = ritualTitle;
  }

  @override
  noSuchMethod(Invocation i) =>
      throw UnimplementedError('${i.memberName} not used by this test');
}
