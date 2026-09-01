import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../l10n/app_localizations.dart';
import '../../../domain_client/repositories/invite_repository.dart';
import '../../../domain_client/api_client.dart';
import '../../../domain_client/models/invite_view.dart';

/// Which sentence an invite outcome carries.
///
/// Named here rather than written here: creating, withdrawing and accepting
/// all happen without a `BuildContext`, and the join page in particular is
/// opened from a link by someone who may not read English.
enum InviteMessage {
  offline,
  createFailed,
  revokeFailed,
  joinRefused,
  joinFailed,
}

/// The sentence an [InviteMessage] stands for, in the reader's language.
String inviteMessage(L l, InviteMessage key) => switch (key) {
      InviteMessage.offline => l.inviteErrorOffline,
      InviteMessage.createFailed => l.inviteErrorCreateFailed,
      InviteMessage.revokeFailed => l.inviteErrorRevokeFailed,
      InviteMessage.joinRefused => l.inviteErrorJoinRefused,
      InviteMessage.joinFailed => l.inviteErrorJoinFailed,
    };

/// The result of asking the server for a private invitation link.
sealed class InviteCreated {
  const InviteCreated();
}

class InviteLinkReady extends InviteCreated {
  const InviteLinkReady(this.invite);

  /// The whole invitation as the server described it: the link to share, the
  /// id needed to withdraw it, and when it stops working. The screen shows
  /// the expiry rather than inventing one, and can revoke without a second
  /// round trip to find out what it just made.
  final CreatedInvite invite;

  String get url => invite.url;
}

class InviteCreateFailed extends InviteCreated {
  const InviteCreateFailed(this.key, this.message);

  /// Which sentence to show. This layer has no `BuildContext`, so it names a
  /// sentence and the screen resolves it against the current locale.
  final InviteMessage key;

  /// The same sentence in English, kept for callers outside the invite
  /// screens and for tests that pin the wording. Screens must prefer [key].
  final String message;
}

/// The invitation is no longer live.
class InviteRevoked extends InviteCreated {
  const InviteRevoked();
}

/// A live invitation already exists for this Dynamic.
///
/// Not a failure of the Creator's action: two taps, or reopening the screen
/// after the link was already made, both land here. The token is shown once
/// and only its hash is stored, so the existing link cannot be produced
/// again — the way forward is to revoke it and issue another.
class InviteAlreadyExists extends InviteCreated {
  const InviteAlreadyExists();
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
  const JoinRefused(this.key, this.message);

  final InviteMessage key;
  final String message;
}

class JoinFailed extends JoinOutcome {
  const JoinFailed(this.key, this.message);

  final InviteMessage key;
  final String message;
}

/// Joining needs an account, and this visitor does not have a session.
///
/// Not a failure: the invitation is fine and so is the person. SCR-10 is
/// public on purpose — someone must be able to see *what* they are being
/// asked to join before signing in — so arriving here unauthenticated is the
/// expected path, not an error to report.
class JoinNeedsAccount extends JoinOutcome {
  const JoinNeedsAccount();
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

  /// One key per invitation token, held for the life of this object.
  ///
  /// The server's join is a guarded update: it only flips an invite that is
  /// still `PENDING`. So a join that succeeded but whose response was lost
  /// finds the invite already `ACCEPTED` on retry and answers 409
  /// `INVITE_ACCEPTED` — which reads exactly like a revoked link. The person
  /// has in fact joined, and would be told to ask for a new invitation.
  ///
  /// Held, the server replays the original 201 instead. Unlike the create
  /// key, this one is **not cleared on success**: success is precisely the
  /// case a retry has to survive.
  final Map<String, String> _joinKeys = {};

  Future<InviteCreated> create(String dynamicId) async {
    final key = _createKeys.putIfAbsent(
      dynamicId,
      ApiClient.newIdempotencyKey,
    );

    try {
      final invite = await _ref
          .read(inviteRepositoryProvider)
          .create(dynamicId, idempotencyKey: key);
      _createKeys.remove(dynamicId);
      return InviteLinkReady(invite);
    } on DioException catch (e) {
      if (_code(e) == 'INVITE_ALREADY_PENDING') {
        // Terminal for this attempt, and not retryable: the key goes.
        _createKeys.remove(dynamicId);
        return const InviteAlreadyExists();
      }
      // The key is deliberately kept: the next attempt is the same attempt.
      return _isOffline(e)
          ? const InviteCreateFailed(
              InviteMessage.offline,
              "You're offline. Connect to the internet, then try again.",
            )
          : const InviteCreateFailed(
              InviteMessage.createFailed,
              "We couldn't create the link right now. Try again.",
            );
    }
  }

  /// Withdraw a live invitation.
  ///
  /// Keyed per invitation so a retry after a lost response replays rather
  /// than reporting a second revoke as a conflict — the person did withdraw
  /// it, and telling them otherwise would send them looking for a link that
  /// is already gone.
  Future<InviteCreated> revoke(String dynamicId, String inviteId) async {
    final key = _revokeKeys.putIfAbsent(inviteId, ApiClient.newIdempotencyKey);
    try {
      await _ref.read(inviteRepositoryProvider)
          .revoke(dynamicId, inviteId, idempotencyKey: key);
      // The Dynamic can hold a live invitation again, so a create attempt
      // that was refused should no longer be treated as the same attempt.
      _createKeys.remove(dynamicId);
      return const InviteRevoked();
    } on DioException catch (e) {
      if (_code(e) == 'INVITE_NOT_LIVE') {
        // Already settled — accepted, expired, or revoked elsewhere. Not a
        // failure of this action.
        _createKeys.remove(dynamicId);
        return const InviteRevoked();
      }
      return _isOffline(e)
          ? const InviteCreateFailed(
              InviteMessage.offline,
              "You're offline. Connect to the internet, then try again.",
            )
          : const InviteCreateFailed(
              InviteMessage.revokeFailed,
              "We couldn't withdraw that link right now. Try again.",
            );
    }
  }

  final Map<String, String> _revokeKeys = {};

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
    final key = _joinKeys.putIfAbsent(token, ApiClient.newIdempotencyKey);

    try {
      final membershipId = await _ref
          .read(inviteRepositoryProvider)
          .join(token, idempotencyKey: key);
      // The key is deliberately KEPT on success. Success is exactly when a
      // lost response leaves the caller retrying, and the server's join only
      // flips a PENDING invite — a fresh key would find it ACCEPTED and
      // answer 409, telling someone who has joined that their invitation is
      // dead. Held, the server replays the original 201.
      //
      // Nothing accumulates: a token is used once, and the map dies with the
      // provider.
      return Joined(membershipId);
    } on DioException catch (e) {
      if (_isOffline(e)) {
        return const JoinFailed(
          InviteMessage.offline,
          "You're offline. Connect to the internet, then try again.",
        );
      }
      final status = e.response?.statusCode;
      // 401 is the ordinary case, not a fault: this page is reachable without
      // a session. The idempotency key is kept — the same person will come
      // back to the same invitation after signing in, and that is one attempt.
      if (status == 401) return const JoinNeedsAccount();
      // 409/410 mean the invitation itself is finished, not that the request
      // failed. Retrying will never help, so it is not offered.
      if (status == 409 || status == 410 || status == 404) {
        // Terminal: the invitation itself is finished. Retrying can never
        // help, so no retry is offered. The key goes with it — a new
        // invitation is a new attempt.
        _joinKeys.remove(token);
        return const JoinRefused(
          InviteMessage.joinRefused,
          'This invitation can no longer be used. Ask for a new one.',
        );
      }
      return const JoinFailed(
        InviteMessage.joinFailed,
        "We couldn't complete that just now. Try again.",
      );
    }
  }

  static String? _code(DioException e) {
    final data = e.response?.data;
    return data is Map ? data['code'] as String? : null;
  }

  static bool _isOffline(DioException e) => switch (e.type) {
        DioExceptionType.connectionError ||
        DioExceptionType.connectionTimeout =>
          true,
        _ => false,
      };
}

final inviteActionsProvider = Provider<InviteActions>(InviteActions.new);
