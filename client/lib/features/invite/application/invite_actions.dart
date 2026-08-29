import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../domain_client/api_client.dart';
import '../../../domain_client/models/invite_view.dart';

/// The result of asking the server for a private invitation link.
sealed class InviteCreated {
  const InviteCreated();
}

class InviteLinkReady extends InviteCreated {
  const InviteLinkReady(this.url);

  /// The full URL to hand to a partner. It points at the Web companion, not
  /// at the API — the person opening it has not installed anything.
  final String url;
}

class InviteCreateFailed extends InviteCreated {
  const InviteCreateFailed(this.message);

  final String message;
}

/// The result of accepting an invitation.
sealed class JoinOutcome {
  const JoinOutcome();
}

class Joined extends JoinOutcome {
  const Joined(this.membershipId);

  final String membershipId;
}

/// The invitation could not be accepted, and the reason is terminal — the
/// link expired, was revoked, or was already used.
class JoinRefused extends JoinOutcome {
  const JoinRefused(this.message);

  final String message;
}

class JoinFailed extends JoinOutcome {
  const JoinFailed(this.message);

  final String message;
}

/// Creating, reading and accepting an invitation.
///
/// The one place in the product where two people's actions meet before a
/// relationship exists, so the rules here are unusually strict:
///
/// - **Resolving an invitation is not accepting it.** Mail scanners and link
///   previews issue requests; only an explicit human action joins.
/// - **Creating twice must not produce two live links.** The key is held per
///   Dynamic and only cleared once a link comes back.
class InviteActions {
  InviteActions(this._ref);

  final Ref _ref;

  /// One key per Dynamic, kept until a link is actually returned.
  ///
  /// A retry after a timeout is the same attempt: without this, a Creator on
  /// a slow connection who taps twice ends up with two live invitations to
  /// the same Dynamic and no way to tell which one they sent.
  final Map<String, String> _createKeys = {};

  Future<InviteCreated> create(String dynamicId) async {
    final key = _createKeys.putIfAbsent(
      dynamicId,
      ApiClient.newIdempotencyKey,
    );

    try {
      final token =
          await _ref.read(inviteRepositoryProvider).create(dynamicId, idempotencyKey: key);
      _createKeys.remove(dynamicId);
      return InviteLinkReady('${webBaseUrl()}/invite/$token');
    } on DioException catch (e) {
      // The key is deliberately kept: the next attempt is the same attempt.
      return InviteCreateFailed(
        _isOffline(e)
            ? "You're offline. Connect to the internet, then try again."
            : "We couldn't create the link right now. Try again.",
      );
    }
  }

  /// Read what an invitation is, without accepting it.
  ///
  /// Anonymous and safe to call from a link: the server never 404s here, so
  /// every terminal state can explain itself instead of dead-ending.
  Future<InviteView> resolve(String token) =>
      _ref.read(inviteRepositoryProvider).resolve(token);

  /// Accept an invitation. Requires a session.
  ///
  /// Separate from [resolve] by design — this is the explicit human act, and
  /// nothing else in the flow may perform it.
  Future<JoinOutcome> join(String token) async {
    try {
      final membershipId = await _ref
          .read(inviteRepositoryProvider)
          .join(token, idempotencyKey: ApiClient.newIdempotencyKey());
      return Joined(membershipId);
    } on DioException catch (e) {
      if (_isOffline(e)) {
        return const JoinFailed(
          "You're offline. Connect to the internet, then try again.",
        );
      }
      final status = e.response?.statusCode;
      // 409/410 mean the invitation itself is finished, not that the request
      // failed. Retrying will never help, so it is not offered.
      if (status == 409 || status == 410 || status == 404) {
        return const JoinRefused(
          'This invitation can no longer be used. Ask for a new one.',
        );
      }
      return const JoinFailed("We couldn't complete that just now. Try again.");
    }
  }

  static bool _isOffline(DioException e) => switch (e.type) {
        DioExceptionType.connectionError ||
        DioExceptionType.connectionTimeout =>
          true,
        _ => false,
      };
}

final inviteActionsProvider = Provider<InviteActions>(InviteActions.new);
