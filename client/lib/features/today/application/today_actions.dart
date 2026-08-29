import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../domain_client/api_client.dart';
import '../../../domain_client/repositories/adjustment_repository.dart';
import '../presentation/today_screen.dart';

/// What a person can do to an item from Today, and what happened when they did.
///
/// The four actions are equals. Completing is not more legitimate than asking
/// to discuss, so they share one shape and one failure path — a design where
/// Complete succeeds cleanly and Can't Do fails obscurely would make adjustment
/// feel like the lesser choice.
enum TodayAction { complete, discuss, requestNewTime, cantDo }

/// The outcome of one attempt, so the UI can say what happened without
/// inspecting exceptions.
sealed class ActionOutcome {
  const ActionOutcome();
}

class ActionSucceeded extends ActionOutcome {
  const ActionSucceeded();
}

/// The server refused, or could not be reached. [message] is already written
/// for a person to read.
class ActionFailed extends ActionOutcome {
  const ActionFailed(this.message);

  final String message;
}

/// Runs Today's commands against the server.
///
/// Holds no state of its own: after every command it invalidates the Today
/// provider so the list is re-read from the server rather than patched locally.
/// Business state has exactly one authority, and it is not this class.
class TodayActions {
  TodayActions(this._ref);

  final Ref _ref;

  /// Keys survive a retry of the *same* attempt, so a flaky network cannot
  /// produce two completions. A new attempt gets a new key.
  final Map<(String, TodayAction), String> _keys = {};

  String _keyFor(String occurrenceId, TodayAction action) => _keys.putIfAbsent((
    occurrenceId,
    action,
  ), () => ApiClient.newIdempotencyKey());

  void _clearKey(String occurrenceId, TodayAction action) =>
      _keys.remove((occurrenceId, action));

  Future<ActionOutcome> run({
    required String dynamicId,
    required String occurrenceId,
    required TodayAction action,
    String? note,
    DateTime? requestedTime,
  }) async {
    final key = _keyFor(occurrenceId, action);
    try {
      switch (action) {
        case TodayAction.complete:
          await _ref
              .read(occurrenceRepositoryProvider)
              .complete(occurrenceId, note: note, idempotencyKey: key);
        case TodayAction.discuss:
          await _request(occurrenceId, AdjustmentType.discuss, note, null, key);
        case TodayAction.requestNewTime:
          await _request(
            occurrenceId,
            AdjustmentType.reschedule,
            note,
            requestedTime,
            key,
          );
        case TodayAction.cantDo:
          await _request(occurrenceId, AdjustmentType.cantDo, note, null, key);
      }

      // The attempt is finished; a later action on the same item is new.
      _clearKey(occurrenceId, action);

      // Re-read rather than patch. The server decides what Today now contains.
      _ref.invalidate(todayProvider(dynamicId));
      return const ActionSucceeded();
    } on Object {
      // The key is deliberately kept so a retry is the same attempt.
      return const ActionFailed(
        'That did not reach the server. Nothing was lost — try again.',
      );
    }
  }

  Future<void> _request(
    String occurrenceId,
    AdjustmentType type,
    String? note,
    DateTime? at,
    String key,
  ) => _ref
      .read(adjustmentRepositoryProvider)
      .request(
        occurrenceId,
        type: type,
        note: note,
        requestedAt: at,
        idempotencyKey: key,
      );
}

final todayActionsProvider = Provider<TodayActions>(TodayActions.new);
