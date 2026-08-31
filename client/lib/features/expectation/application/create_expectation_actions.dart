import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../domain_client/api_client.dart';

sealed class CreateOutcome {
  const CreateOutcome();
}

class CreateSucceeded extends CreateOutcome {
  const CreateSucceeded(this.occurrenceId);

  final String occurrenceId;
}

class CreateFailed extends CreateOutcome {
  const CreateFailed(this.message);

  final String message;
}

/// Sends one expectation to the other person.
///
/// The key is minted once per composed task and kept across retries: a flaky
/// network must not ask the same thing twice. It is cleared only on success,
/// so pressing Send again after a failure is the same attempt, not a new one.
class CreateExpectationActions {
  CreateExpectationActions(this._ref);

  final Ref _ref;

  String? _key;

  Future<CreateOutcome> send({
    required String dynamicId,
    required String title,
    required String assigneeUserId,
    String? purpose,
    DateTime? dueAt,
  }) async {
    final key = _key ??= ApiClient.newIdempotencyKey();
    try {
      final id = await _ref
          .read(expectationRepositoryProvider)
          .create(
            dynamicId,
            title: title,
            purpose: purpose,
            assigneeUserId: assigneeUserId,
            dueAt: dueAt,
            idempotencyKey: key,
          );
      _key = null;
      return CreateSucceeded(id);
    } on Object {
      return const CreateFailed(
        'That did not reach the server. Nothing was sent — try again.',
      );
    }
  }
}

final createExpectationActionsProvider = Provider<CreateExpectationActions>(
  CreateExpectationActions.new,
);
