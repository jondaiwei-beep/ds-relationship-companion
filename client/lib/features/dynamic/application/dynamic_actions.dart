import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../domain_client/api_client.dart';
import 'dynamic_providers.dart';

/// The agency actions Dynamic offers. Either member may take either one,
/// whatever their role — agency no role can remove.
enum DynamicAction { pause, resume }

sealed class DynamicOutcome {
  const DynamicOutcome();
}

class DynamicSucceeded extends DynamicOutcome {
  const DynamicSucceeded();
}

/// Which action failed. The words belong to the screen: this layer has no
/// BuildContext, and a sentence built here would be in whichever language the
/// build was compiled with rather than the reader's.
enum DynamicFailureReason { pause, resume }

class DynamicFailed extends DynamicOutcome {
  const DynamicFailed(this.reason, this.message);

  final DynamicFailureReason reason;

  /// English, for logs and the walking skeleton. No screen renders it.
  final String message;
}

/// Runs Dynamic's commands against the server.
///
/// Holds no view state: after each command the detail provider is invalidated
/// so pause state is re-read rather than assumed. Pause is the one thing here
/// a person may rely on having actually taken effect, so it is never shown
/// from a local guess.
class DynamicActions {
  DynamicActions(this._ref);

  final Ref _ref;

  /// Keys survive a retry of the *same* attempt, so a flaky network cannot
  /// pause twice. A new attempt gets a new key.
  final Map<(String, DynamicAction), String> _keys = {};

  String _keyFor(String dynamicId, DynamicAction action) => _keys.putIfAbsent(
    (dynamicId, action),
    ApiClient.newIdempotencyKey,
  );

  /// [lighter] applies to resume only. It defaults to true because that is
  /// Journey E's default — being handed the same load you paused under is how
  /// people leave again — but SCR-24 lets the person returning decide, and
  /// their choice must reach the server rather than being overridden here.
  Future<DynamicOutcome> run(
    String dynamicId,
    DynamicAction action, {
    bool lighter = true,
  }) async {
    final repo = _ref.read(dynamicRepositoryProvider);
    final key = _keyFor(dynamicId, action);
    try {
      switch (action) {
        case DynamicAction.pause:
          await repo.pause(dynamicId, idempotencyKey: key);
        case DynamicAction.resume:
          await repo.resume(dynamicId, lighter: lighter, idempotencyKey: key);
      }

      _keys.remove((dynamicId, action));
      _ref.invalidate(dynamicDetailProvider(dynamicId));
      return const DynamicSucceeded();
    } on Object {
      // The key is deliberately kept so a retry is the same attempt.
      return action == DynamicAction.pause
          ? const DynamicFailed(
              DynamicFailureReason.pause,
              'That did not reach the server. Nothing changed — try again.',
            )
          : const DynamicFailed(
              DynamicFailureReason.resume,
              'That did not reach the server. Still paused — try again.',
            );
    }
  }
}

final dynamicActionsProvider = Provider<DynamicActions>(DynamicActions.new);
