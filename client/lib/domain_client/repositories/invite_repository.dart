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

  Future<String> join(String token, {required String idempotencyKey}) async {
    final r = await _api.post(
      '/v1/invites/join',
      body: {'token': token},
      idempotencyKey: idempotencyKey,
    );
    return r['membershipId'] as String;
  }
}
