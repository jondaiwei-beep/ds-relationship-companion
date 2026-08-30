import 'package:dio/dio.dart';
import 'package:dsapp/app/providers.dart';
import 'package:dsapp/domain_client/models/invite_view.dart';
import 'package:dsapp/domain_client/repositories/invite_repository.dart';
import 'package:dsapp/features/invite/application/invite_actions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// The invitation is where two people's actions meet before a relationship
/// exists. Everything asserted here is a product rule, not plumbing.
void main() {
  late _FakeInvites invites;
  late ProviderContainer container;

  setUp(() {
    invites = _FakeInvites();
    container = ProviderContainer(
      overrides: [inviteRepositoryProvider.overrideWithValue(invites)],
    );
    addTearDown(container.dispose);
  });

  InviteActions actions() => container.read(inviteActionsProvider);

  DioException transport(DioExceptionType type) => DioException(
        requestOptions: RequestOptions(path: '/'),
        type: type,
      );

  DioException status(int code) => DioException(
        requestOptions: RequestOptions(path: '/'),
        response: Response(
          requestOptions: RequestOptions(path: '/'),
          statusCode: code,
        ),
      );

  group('creating a link', () {
    test('points at the Web companion, not the API', () async {
      final result = await actions().create('dyn-1') as InviteLinkReady;

      expect(
        result.url,
        contains('/invite/tok-1'),
        reason: 'the partner opens this on their phone without installing '
            'anything',
      );
      // The URL comes from the server now. The client used to build it from
      // its own `webBaseUrl()`, which meant a build pointed at the wrong
      // origin would mint links nobody could open.
      expect(result.invite.inviteId, 'inv-1');
      expect(result.invite.expiresAt, DateTime.utc(2026, 9, 6));
    });

    test('a retry after a timeout is the same attempt', () async {
      // Otherwise a Creator on a slow connection who taps twice ends up with
      // two live invitations and no way to know which one they sent.
      invites.failure = transport(DioExceptionType.receiveTimeout);
      await actions().create('dyn-1');

      invites.failure = null;
      await actions().create('dyn-1');

      expect(invites.keysUsed.toSet(), hasLength(1));
    });

    test('a new attempt after success is genuinely new', () async {
      await actions().create('dyn-1');
      await actions().create('dyn-1');

      expect(
        invites.keysUsed.toSet(),
        hasLength(2),
        reason: 'revoking a link and issuing another is a real thing to do',
      );
    });

    test('a link that already exists is not a failure', () async {
      // Two taps, or reopening the screen. The server refuses because one
      // live invitation per Dynamic is the rule, not because anything broke.
      invites.failure = DioException(
        requestOptions: RequestOptions(path: '/'),
        response: Response(
          requestOptions: RequestOptions(path: '/'),
          statusCode: 409,
          data: {'code': 'INVITE_ALREADY_PENDING'},
        ),
      );

      expect(await actions().create('dyn-1'), isA<InviteAlreadyExists>());
    });

    test('offline says so', () async {
      invites.failure = transport(DioExceptionType.connectionError);

      final result = await actions().create('dyn-1') as InviteCreateFailed;

      expect(result.message, contains('offline'));
    });
  });

  group('withdrawing', () {
    test('frees the Dynamic for a new invitation', () async {
      // The escape hatch the one-live-invite rule depends on. Creating was
      // refused, so its key was held; after a revoke that attempt is over.
      invites.failure = status(409);
      await actions().create('dyn-1');
      invites.failure = null;

      await actions().revoke('dyn-1', 'inv-1');
      await actions().create('dyn-1');

      expect(invites.revoked, ['inv-1']);
      expect(
        invites.keysUsed.toSet(),
        hasLength(2),
        reason: 'the refused attempt is finished; this is a new one',
      );
    });

    test('a retry after a lost response replays', () async {
      invites.failure = transport(DioExceptionType.receiveTimeout);
      await actions().revoke('dyn-1', 'inv-1');
      invites.failure = null;
      await actions().revoke('dyn-1', 'inv-1');

      expect(invites.revokeKeys.toSet(), hasLength(1));
    });

    test('an already-settled invitation is not a failure', () async {
      // Accepted, expired, or revoked from another device. The person wanted
      // it gone and it is gone.
      invites.failure = DioException(
        requestOptions: RequestOptions(path: '/'),
        response: Response(
          requestOptions: RequestOptions(path: '/'),
          statusCode: 409,
          data: {'code': 'INVITE_NOT_LIVE'},
        ),
      );

      expect(await actions().revoke('dyn-1', 'inv-1'), isA<InviteRevoked>());
    });
  });

  group('resolving', () {
    test('never joins', () async {
      // Mail scanners and link previews issue requests. Only an explicit
      // human action may join.
      await actions().resolve('tok');

      expect(invites.joinCalls, 0);
    });

    test('a finished invitation still resolves, rather than dead-ending',
        () async {
      invites.state = InviteState.expired;

      final view = await actions().resolve('tok');

      expect(view.state, InviteState.expired);
    });
  });

  group('joining', () {
    test('returns the membership on success', () async {
      expect(await actions().join('tok'), isA<Joined>());
    });

    test('a finished invitation is refused, not failed', () async {
      // Retrying can never help, so the distinction decides whether the
      // screen offers a retry the person will keep pressing.
      for (final code in [404, 409, 410]) {
        invites.failure = status(code);
        expect(
          await actions().join('tok'),
          isA<JoinRefused>(),
          reason: '$code means the invitation is finished',
        );
      }
    });

    test('a retry after a lost response replays, it does not re-join',
        () async {
      // The server's join is a guarded update: it only flips an invite still
      // PENDING. A join that succeeded but whose response was lost would, on
      // a fresh key, come back 409 INVITE_ACCEPTED — which reads exactly like
      // a revoked link, telling someone who HAS joined to ask for a new
      // invitation. Holding the key makes the server replay the 201.
      invites.failure = transport(DioExceptionType.receiveTimeout);
      await actions().join('tok');

      invites.failure = null;
      await actions().join('tok');

      expect(invites.joinKeys.toSet(), hasLength(1));
    });

    test('a retry after a SUCCESSFUL join replays too', () async {
      // The case that matters most and the one I originally missed: the
      // response was lost, not the request. The person HAS joined. A fresh
      // key would find the invite ACCEPTED and answer 409 — telling them
      // their invitation is dead at the moment it actually worked.
      //
      // Caught by walking the loop against a real server; the timeout-only
      // test below passed throughout.
      await actions().join('tok');
      await actions().join('tok');

      expect(invites.joinKeys.toSet(), hasLength(1));
    });

    test('a new invitation is a new attempt', () async {
      await actions().join('tok-a');
      await actions().join('tok-b');

      expect(invites.joinKeys.toSet(), hasLength(2));
    });

    test('a server error is failed, and may be retried', () async {
      invites.failure = status(500);

      expect(await actions().join('tok'), isA<JoinFailed>());
    });
  });
}

class _FakeInvites implements InviteRepository {
  final keysUsed = <String>[];
  final joinKeys = <String>[];
  final revokeKeys = <String>[];
  final revoked = <String>[];
  int joinCalls = 0;
  Object? failure;
  InviteState state = InviteState.pending;

  @override
  Future<CreatedInvite> create(
    String dynamicId, {
    required String idempotencyKey,
  }) async {
    keysUsed.add(idempotencyKey);
    if (failure != null) throw failure!;
    return CreatedInvite(
      inviteId: 'inv-1',
      token: 'tok-1',
      // The server builds this, not the client — it knows the Web origin the
      // link must point at.
      url: 'https://ds.example.com/invite/tok-1',
      expiresAt: DateTime.utc(2026, 9, 6),
    );
  }

  @override
  Future<void> revoke(
    String dynamicId,
    String inviteId, {
    required String idempotencyKey,
  }) async {
    revokeKeys.add(idempotencyKey);
    if (failure != null) throw failure!;
    revoked.add(inviteId);
  }

  @override
  Future<InviteView> resolve(String token) async {
    if (failure != null) throw failure!;
    return InviteView(state: state, inviterDisplayName: 'Morgan');
  }

  @override
  Future<String> join(String token, {required String idempotencyKey}) async {
    joinCalls++;
    joinKeys.add(idempotencyKey);
    if (failure != null) throw failure!;
    return 'membership-1';
  }

  @override
  noSuchMethod(Invocation i) =>
      throw UnimplementedError('${i.memberName} not used by this test');
}
