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
      expect(result.url, startsWith(webBaseUrl()));
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

    test('offline says so', () async {
      invites.failure = transport(DioExceptionType.connectionError);

      final result = await actions().create('dyn-1') as InviteCreateFailed;

      expect(result.message, contains('offline'));
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

    test('a server error is failed, and may be retried', () async {
      invites.failure = status(500);

      expect(await actions().join('tok'), isA<JoinFailed>());
    });
  });
}

class _FakeInvites implements InviteRepository {
  final keysUsed = <String>[];
  int joinCalls = 0;
  Object? failure;
  InviteState state = InviteState.pending;

  @override
  Future<String> create(String dynamicId, {required String idempotencyKey}) async {
    keysUsed.add(idempotencyKey);
    if (failure != null) throw failure!;
    return 'tok-1';
  }

  @override
  Future<InviteView> resolve(String token) async {
    if (failure != null) throw failure!;
    return InviteView(state: state, inviterDisplayName: 'Morgan');
  }

  @override
  Future<String> join(String token, {required String idempotencyKey}) async {
    joinCalls++;
    if (failure != null) throw failure!;
    return 'membership-1';
  }

  @override
  noSuchMethod(Invocation i) =>
      throw UnimplementedError('${i.memberName} not used by this test');
}
