import 'package:dsapp/app/providers.dart';
import 'package:dsapp/domain_client/repositories/adjustment_repository.dart';
import 'package:dsapp/domain_client/repositories/occurrence_repository.dart';
import 'package:dsapp/features/today/application/today_actions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockOccurrences extends Mock implements OccurrenceRepository {}

class _MockAdjustments extends Mock implements AdjustmentRepository {}

/// The command layer between Today and the server.
///
/// Idempotency is the thing worth testing here: a retried tap must not be able
/// to produce a second completion, and a genuinely new attempt must not be
/// mistaken for a retry.
void main() {
  late _MockOccurrences occurrences;
  late _MockAdjustments adjustments;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(AdjustmentType.discuss);
  });

  setUp(() {
    occurrences = _MockOccurrences();
    adjustments = _MockAdjustments();
    container = ProviderContainer(
      overrides: [
        occurrenceRepositoryProvider.overrideWithValue(occurrences),
        adjustmentRepositoryProvider.overrideWithValue(adjustments),
      ],
    );
    addTearDown(container.dispose);
  });

  TodayActions actions() => container.read(todayActionsProvider);

  Future<ActionOutcome> run(TodayAction action, {String id = 'o1'}) =>
      actions().run(dynamicId: 'd1', occurrenceId: id, action: action);

  group('completing', () {
    test('sends the command and reports success', () async {
      when(
        () => occurrences.complete(
          any(),
          note: any(named: 'note'),
          idempotencyKey: any(named: 'idempotencyKey'),
        ),
      ).thenAnswer((_) async {});

      expect(await run(TodayAction.complete), isA<ActionSucceeded>());
      verify(
        () => occurrences.complete(
          'o1',
          note: null,
          idempotencyKey: any(named: 'idempotencyKey'),
        ),
      ).called(1);
    });

    test('a retry after failure reuses the same idempotency key', () async {
      // Otherwise a flaky network turns one tap into two completions.
      final keys = <String>[];
      when(
        () => occurrences.complete(
          any(),
          note: any(named: 'note'),
          idempotencyKey: any(named: 'idempotencyKey'),
        ),
      ).thenAnswer((inv) async {
        keys.add(inv.namedArguments[#idempotencyKey] as String);
        throw Exception('network');
      });

      await run(TodayAction.complete);
      await run(TodayAction.complete);

      expect(keys, hasLength(2));
      expect(keys.first, keys.last, reason: 'a retry is the same attempt');
    });

    test('a new attempt after success gets a new key', () async {
      final keys = <String>[];
      when(
        () => occurrences.complete(
          any(),
          note: any(named: 'note'),
          idempotencyKey: any(named: 'idempotencyKey'),
        ),
      ).thenAnswer((inv) async {
        keys.add(inv.namedArguments[#idempotencyKey] as String);
      });

      await run(TodayAction.complete);
      await run(TodayAction.complete);

      expect(
        keys.first,
        isNot(keys.last),
        reason: 'a second deliberate action is not a retry',
      );
    });

    test('failure is reported in words a person can read', () async {
      when(
        () => occurrences.complete(
          any(),
          note: any(named: 'note'),
          idempotencyKey: any(named: 'idempotencyKey'),
        ),
      ).thenThrow(Exception());

      final outcome = await run(TodayAction.complete);
      expect(outcome, isA<ActionFailed>());
      final message = (outcome as ActionFailed).message;
      expect(message, contains('Nothing was lost'));
      // No stack trace, no status code, no backend vocabulary.
      expect(message.toLowerCase(), isNot(contains('exception')));
      expect(message, isNot(contains('500')));
    });
  });

  group('adjustment is a first-class path', () {
    setUp(() {
      when(
        () => adjustments.request(
          any(),
          type: any(named: 'type'),
          note: any(named: 'note'),
          requestedAt: any(named: 'requestedAt'),
          idempotencyKey: any(named: 'idempotencyKey'),
        ),
      ).thenAnswer((_) async {});
    });

    test('each path maps to its own adjustment type', () async {
      const expected = {
        TodayAction.discuss: AdjustmentType.discuss,
        TodayAction.requestNewTime: AdjustmentType.reschedule,
        TodayAction.cantDo: AdjustmentType.cantDo,
      };

      for (final entry in expected.entries) {
        await run(entry.key);
        verify(
          () => adjustments.request(
            'o1',
            type: entry.value,
            note: any(named: 'note'),
            requestedAt: any(named: 'requestedAt'),
            idempotencyKey: any(named: 'idempotencyKey'),
          ),
        ).called(1);
      }
    });

    test('an adjustment succeeds the same way completing does', () async {
      // Adjustment is not a failure path and must not behave like one.
      for (final action in [
        TodayAction.discuss,
        TodayAction.requestNewTime,
        TodayAction.cantDo,
      ]) {
        expect(await run(action), isA<ActionSucceeded>(), reason: '$action');
      }
    });
  });

  test('actions on different items do not share a key', () async {
    final keys = <String>[];
    when(
      () => occurrences.complete(
        any(),
        note: any(named: 'note'),
        idempotencyKey: any(named: 'idempotencyKey'),
      ),
    ).thenAnswer((inv) async {
      keys.add(inv.namedArguments[#idempotencyKey] as String);
      throw Exception('network');
    });

    await run(TodayAction.complete, id: 'o1');
    await run(TodayAction.complete, id: 'o2');

    expect(keys.first, isNot(keys.last));
  });
}
