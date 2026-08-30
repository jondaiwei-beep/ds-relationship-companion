import '../api_client.dart';
import '../models/invite_view.dart';

/// A newly created invitation, as the server describes it.
///
/// The repository used to keep only the token and throw the rest away, which
/// left the sending screen unable to revoke — that needs the `inviteId` — and
/// unable to state an expiry without inventing one.
class CreatedInvite {
  const CreatedInvite({
    required this.inviteId,
    required this.token,
    required this.url,
    required this.expiresAt,
  });

  final String inviteId;

  /// Returned exactly once. Only its hash is persisted server-side, so it
  /// cannot be recovered by asking again.
  final String token;

  /// Points at the Web companion, not the API: the person opening it has not
  /// installed anything.
  final String url;

  final DateTime expiresAt;
}

class InviteRepository {
  InviteRepository(this._api);

  final ApiClient _api;

  /// Create an invite for this dynamic and return the link to share.
  ///
  /// A Creator has no other way into the product: they cannot be handed a
  /// link, because they are the one who makes it.
  Future<CreatedInvite> create(
    String dynamicId, {
    required String idempotencyKey,
  }) async {
    final r = await _api.post(
      '/v1/dynamics/$dynamicId/invites',
      idempotencyKey: idempotencyKey,
    );
    return CreatedInvite(
      inviteId: r['inviteId'] as String,
      token: r['token'] as String,
      url: r['inviteUrl'] as String,
      expiresAt: DateTime.parse(r['expiresAt'] as String),
    );
  }

  /// Anonymous pre-auth resolve. Never 404s — every terminal state is explicit,
  /// so the join page can explain itself (Notion 02 §A4).
  Future<InviteView> resolve(String token) async => InviteView.fromJson(
        await _api.post(
          '/v1/invites/resolve',
          body: {'token': token},
          authenticated: false,
        ),
      );

  /// Withdraw a live invitation.
  ///
  /// The escape hatch the one-live-invite rule depends on: a Creator who
  /// wants a different link revokes this one first. Until this existed, the
  /// only thing that revoked an invite was Block, which is a safety action
  /// about a person and far too large a hammer for a link sent to the wrong
  /// address.
  Future<void> revoke(
    String dynamicId,
    String inviteId, {
    required String idempotencyKey,
  }) =>
      _api.post(
        '/v1/dynamics/$dynamicId/invites/$inviteId/revoke',
        idempotencyKey: idempotencyKey,
      );

  Future<String> join(String token, {required String idempotencyKey}) async {
    final r = await _api.post(
      '/v1/invites/join',
      body: {'token': token},
      idempotencyKey: idempotencyKey,
    );
    return r['membershipId'] as String;
  }
}
