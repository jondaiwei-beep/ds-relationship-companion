import '../api_client.dart';
import '../models/invite_view.dart';

class InviteRepository {
  InviteRepository(this._api);

  final ApiClient _api;

  /// Create an invite for this dynamic and return the link to share.
  ///
  /// A Creator has no other way into the product: they cannot be handed a
  /// link, because they are the one who makes it.
  Future<String> create(String dynamicId, {required String idempotencyKey}) async {
    final r = await _api.post(
      '/v1/dynamics/$dynamicId/invites',
      idempotencyKey: idempotencyKey,
    );
    return r['token'] as String;
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
