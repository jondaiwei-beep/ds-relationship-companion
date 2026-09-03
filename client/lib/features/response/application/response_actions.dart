import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../domain_client/api_client.dart';

/// The four ways one person answers another.
///
/// Named `HumanResponse` rather than `ResponseType` because Dio exports that
/// name for HTTP payload kinds, and a file that imports both would have to
/// alias one. The truer name anyway: these are ways a person answers, not
/// transport concerns.
///
/// Not a severity scale and not a workflow status. `REQ-ACK-001` calls all
/// four "explicit human sends", and the difference between them is what the
/// sender meant, not how much the system thinks the moment was worth.
enum HumanResponse {
  /// Two taps, no words. The floor `REQ-ACK-001` sets: a person who has
  /// nothing to add must still be able to answer, because silence and
  /// acknowledgement are different things and only one of them closes a loop.
  acknowledge('ACKNOWLEDGE', wordsRequired: false),
  praise('PRAISE', wordsRequired: false),

  /// Words by definition. An empty comment is not a quiet comment, it is
  /// nothing — and the server refuses it with `TEXT_REQUIRED`.
  comment('COMMENT', wordsRequired: true),
  review('REVIEW', wordsRequired: true);

  const HumanResponse(this.wire, {required this.wordsRequired});

  /// The value the server stores. Never shown to anyone.
  final String wire;

  final bool wordsRequired;
}

sealed class ResponseOutcome {
  const ResponseOutcome();
}

class ResponseSent extends ResponseOutcome {
  const ResponseSent();
}

/// The moment was already answered — by this person on another device, or by
/// a retry whose first attempt landed.
///
/// Deliberately not a failure. Someone whose acknowledgement arrived twice has
/// not done anything wrong, and telling them it failed would invite a third.
class ResponseAlreadySent extends ResponseOutcome {
  const ResponseAlreadySent();
}

class ResponseNeedsWords extends ResponseOutcome {
  const ResponseNeedsWords();
}

/// Why a send did not land, in terms the UI can translate. This layer has no
/// `BuildContext`, so the reason travels and the screen chooses the words.
enum ResponseFailureReason { offline, unknown }

class ResponseFailed extends ResponseOutcome {
  const ResponseFailed(this.reason, this.message);

  final ResponseFailureReason reason;

  /// The English sentence, kept for logs and tests. Screens render `reason`
  /// through the localisations instead.
  final String message;
}

/// Sending a human response.
///
/// The whole product turns on this being a deliberate act. The system never
/// sends on anyone's behalf, never pre-fills words as though a person wrote
/// them, and never treats a completion as an answer.
class ResponseActions {
  ResponseActions(this._ref);

  final Ref _ref;

  /// One key per occurrence and content, not per attempt.
  ///
  /// Keyed by what is being sent so an edited message is honestly a different
  /// send, while a retry of the same words replays rather than arriving twice.
  /// Kept after success for the same reason as `join`: a lost response is
  /// exactly the case a retry has to survive.
  final Map<String, String> _keys = {};

  Future<ResponseOutcome> send({
    required String occurrenceId,
    required HumanResponse type,
    String text = '',
  }) async {
    final words = text.trim();

    // Checked here as well as on the server — not as a boundary, but so the
    // person is told beside the field rather than by a round trip.
    if (type.wordsRequired && words.isEmpty) {
      return const ResponseNeedsWords();
    }

    final key = _keys.putIfAbsent(
      '$occurrenceId|${type.wire}|$words',
      ApiClient.newIdempotencyKey,
    );

    try {
      await _ref.read(occurrenceRepositoryProvider).acknowledge(
            occurrenceId,
            type: type.wire,
            text: words,
            idempotencyKey: key,
          );
      return const ResponseSent();
    } on DioException catch (e) {
      return _classify(e);
    } catch (_) {
      return const ResponseFailed(
        ResponseFailureReason.unknown,
        "We couldn't send that just now. Try again.",
      );
    }
  }

  ResponseOutcome _classify(DioException e) {
    if (_isOffline(e)) {
      return const ResponseFailed(
        ResponseFailureReason.offline,
        "You're offline. Connect to the internet, then try again.",
      );
    }
    return switch (_code(e)) {
      'TEXT_REQUIRED' => const ResponseNeedsWords(),
      // The occurrence is no longer waiting for an answer — someone got
      // there first, or a lost response actually landed. Not this person's
      // problem to solve, and not a failure of what they just did.
      //
      // `OCCURRENCE_NOT_WAITING_ACK` is the code the server actually sends
      // (`ApiErrors.kt`). An earlier draft guessed `ALREADY_ACKNOWLEDGED`,
      // which exists nowhere, so every real conflict fell through to
      // "couldn't send" and invited a third attempt.
      'OCCURRENCE_NOT_WAITING_ACK' ||
      'OCCURRENCE_NOT_ACTIVE' =>
        const ResponseAlreadySent(),
      _ => const ResponseFailed(
          ResponseFailureReason.unknown,
          "We couldn't send that just now. Try again.",
        ),
    };
  }

  static String? _code(DioException e) {
    final data = e.response?.data;
    return data is Map ? data['code'] as String? : null;
  }

  static bool _isOffline(DioException e) => switch (e.type) {
        DioExceptionType.connectionError ||
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout =>
          true,
        _ => false,
      };
}

final responseActionsProvider =
    Provider<ResponseActions>(ResponseActions.new);
