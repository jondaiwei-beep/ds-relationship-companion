import 'package:dsapp/app/providers.dart';
import 'package:dsapp/domain_client/api_client.dart';
import 'package:dsapp/domain_client/repositories/auth_repository.dart';
import 'package:dsapp/platform/session/refresh_store.dart';
import 'package:dsapp/platform/session/session.dart';
import 'package:dsapp/platform/session/session_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// The session decides whether relationship content may render at all, so its
/// behaviour is a safety control rather than plumbing. Each test here states
/// a rule the product depends on, not an implementation detail.
void main() {
  late _FakeAuth auth;
  late _MemoryStore store;
  late ApiClient api;
  late ProviderContainer container;

  setUp(() {
    auth = _FakeAuth();
    store = _MemoryStore();
    api = ApiClient(baseUrl: 'http://test');
    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(auth),
        refreshStoreProvider.overrideWithValue(store),
        apiClientProvider.overrideWithValue(api),
      ],
    );
    addTearDown(container.dispose);
  });

  SessionController controller() => container.read(sessionProvider.notifier);
  Session session() => container.read(sessionProvider);

  group('startup', () {
    test('starts unknown, so the guard never guesses before it can know', () {
      expect(session(), isA<SessionUnknown>());
      expect(
        session().isAuthenticated,
        isFalse,
        reason: 'unknown must not read as signed in',
      );
    });

    test('no stored credential resolves to signed out without a call', () async {
      await controller().restore();

      expect(session(), isA<SignedOut>());
      expect(
        auth.refreshCalls,
        0,
        reason: 'nothing to exchange; asking the server is a wasted round trip',
      );
    });

    test('a stored credential is exchanged and the session opens', () async {
      await store.write('stored-refresh');

      await controller().restore();

      expect(session(), isA<Authenticated>());
      expect(auth.lastRefreshToken, 'stored-refresh');
    });

    test('a rejected credential resolves to signed out and clears it', () async {
      await store.write('stale');
      auth.refreshFails = true;

      await controller().restore();

      expect(session(), isA<SignedOut>());
      expect(
        await store.read(),
        isNull,
        reason: 'a credential the server rejected must not be retried forever',
      );
    });

    test('a failed restore carries no reason: nobody asked for anything', () async {
      await store.write('stale');
      auth.refreshFails = true;

      await controller().restore();

      expect((session() as SignedOut).reason, isNull);
    });
  });

  group('the access token', () {
    test('reaches the API client, so requests are actually authorized', () async {
      await controller().adopt(_result('token-1'));

      expect(api.debugAccessToken, 'token-1');
    });

    test('is cleared from the API client when the session ends', () async {
      await controller().adopt(_result('token-1'));

      await controller().signOut();

      expect(
        api.debugAccessToken,
        isNull,
        reason: 'a stale token would keep authorizing reads after sign-out',
      );
    });

    test('is never written to the refresh store', () async {
      await controller().adopt(_result('access-only', refresh: null));

      expect(
        await store.read(),
        isNull,
        reason: 'the access token lives in memory only',
      );
    });
  });

  group('sign out', () {
    test('clears local state even when the server call fails', () async {
      await controller().adopt(_result('token-1'));
      auth.logoutFails = true;

      await controller().signOut();

      expect(session(), isA<SignedOut>());
      expect(api.debugAccessToken, isNull);
      expect(
        await store.read(),
        isNull,
        reason: 'a network error must not leave someone signed in on a '
            'device they are handing back',
      );
    });

    test('records that it was requested, not that it expired', () async {
      await controller().adopt(_result('token-1'));

      await controller().signOut();

      expect((session() as SignedOut).reason, SignedOutReason.requested);
    });
  });

  group('the refresh schedule', () {
    test('fires ahead of expiry, not at it', () {
      expect(
        SessionController.refreshDelayFor(const Duration(minutes: 15)),
        const Duration(minutes: 14),
        reason: 'a refresh that starts at expiry becomes a 401 on a slow '
            'network, mid-request',
      );
    });

    test('a very short lifetime does not become a request loop', () {
      expect(
        SessionController.refreshDelayFor(const Duration(seconds: 2)),
        const Duration(seconds: 5),
      );
      expect(
        SessionController.refreshDelayFor(Duration.zero),
        const Duration(seconds: 5),
      );
    });
  });

  group('the signed-out reason', () {
    test('distinguishes expiry from a request, and carries nothing else',
        () async {
      // The entrance uses this to say something true, and whoever is holding
      // the phone may not be the account holder — so the reason is coarse by
      // design. If this enum ever grows a case that names a partner or a
      // relationship state, that is a privacy leak, not a better message.
      expect(
        SignedOutReason.values,
        [SignedOutReason.requested, SignedOutReason.expired],
      );
    });
  });
}

AuthResult _result(String access, {String? refresh = 'refresh-1'}) => AuthResult(
      accessToken: access,
      accessTokenExpiresIn: const Duration(minutes: 15),
      refreshToken: refresh,
    );

class _FakeAuth implements AuthRepository {
  int refreshCalls = 0;
  String? lastRefreshToken;
  bool refreshFails = false;
  bool logoutFails = false;

  @override
  Future<AuthResult> refresh({String? refreshToken}) async {
    refreshCalls++;
    lastRefreshToken = refreshToken;
    if (refreshFails) throw StateError('rejected');
    return _result('refreshed-access');
  }

  @override
  Future<void> logout() async {
    if (logoutFails) throw StateError('offline');
  }

  @override
  noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} not used by this test');
}

class _MemoryStore implements RefreshStore {
  String? _token;

  @override
  Future<String?> read() async => _token;

  @override
  Future<void> write(String token) async => _token = token;

  @override
  Future<void> clear() async => _token = null;
}
