import 'dart:convert';
import 'package:dsapp/domain_client/models/invite_view.dart';
import 'package:flutter_test/flutter_test.dart';

/// Contract tests against payloads captured from the RUNNING backend.
///
/// M0 exit criterion (Notion 06 §13.2): DTO drift between backend and client
/// must be caught, not discovered by hand.
void main() {
  test('parses a real /v1/invites/resolve NOT_FOUND response', () {
    // Captured live from http://localhost:8082 on 2026-08-27.
    const raw =
        '{"state":"NOT_FOUND","inviteId":null,"dynamicId":null,'
        '"intendedRoleContext":null,"inviterDisplayName":null}';

    final v = InviteView.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    expect(v.state, InviteState.notFound);
    expect(v.inviteId, isNull);
  });

  test('parses a pending invite with the inviter name shown pre-auth', () {
    const raw =
        '{"state":"PENDING","inviteId":"11111111-1111-1111-1111-111111111111",'
        '"dynamicId":"22222222-2222-2222-2222-222222222222",'
        '"intendedRoleContext":"PARTNER","inviterDisplayName":"Alex"}';

    final v = InviteView.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    expect(v.state, InviteState.pending);
    expect(v.inviterDisplayName, 'Alex');
  });

}
