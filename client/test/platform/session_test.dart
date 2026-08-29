import 'dart:async';

import 'package:dio/dio.dart';
import 'package:dsapp/app/providers.dart';
import 'package:dsapp/domain_client/api_client.dart';
import 'package:dsapp/domain_client/repositories/auth_repository.dart';
import 'package:dsapp/platform/session/csrf.dart';
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
  late _FakeCsrf csrf;
  late ApiClient api;
  late ProviderContainer container;

  setUp(() {
    auth = _FakeAuth();
    store = _MemoryStore();
    csrf = _FakeCsrf();
    api = ApiClient(baseUrl: 'http://test');
    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(auth),
        refreshStoreProvider.overrideWithValue(store),
        csrfTokensProvider.overrideWithValue(csrf),
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
      auth.refreshRejected = true;

      await controller().restore();

      expect(session(), isA<SignedOut>());
      expect(
        await store.read(),
        isNull,
        reason: 'a credential the server rejected must not be retried forever',
      );
    });

    test('being offline does not destroy a credential that may be good',
        () async {
      await store.write('maybe-fine');
      auth.refreshUnreachable = true;

      await controller().restore();

      expect(session(), isA<SignedOut>());
      expect(
        await store.read(),
        'maybe-fine',
        reason: 'deleting it because the wifi was down would sign someone out '
            'permanently for a temporary problem',
      );
    });

    test('a failed restore carries no reason: nobody asked for anything', () async {
      await store.write('stale');
      auth.refreshRejected = true;

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

  group('sign out is a safety control', () {
    test('denies locally before waiting on the network', () async {
      await controller().adopt(_result('token-1'));
      final gate = Completer<void>();
      auth.logoutGate = gate;

      final signingOut = controller().signOut();
      await pumpEventQueue();

      // The server has not answered yet, and must not need to.
      expect(
        session(),
        isA<SignedOut>(),
        reason: 'awaiting logout first would keep protected content on screen '
            'for the whole connect timeout of a device being handed back',
      );
      expect(api.debugAccessToken, isNull);

      gate.complete();
      await signingOut;
    });
  });

  group('races', () {
    test('a refresh in flight cannot resurrect a session after sign-out',
        () async {
      await controller().adopt(_result('token-1'));
      final gate = Completer<AuthResult>();
      auth.refreshGate = gate;

      final refreshing = controller().debugRefreshNow();
      await pumpEventQueue();
      await controller().signOut();

      // The refresh the server was already processing now comes back.
      gate.complete(_result('too-late'));
      await refreshing;

      expect(
        session(),
        isA<SignedOut>(),
        reason: 'cancelling a timer does nothing to a request already sent',
      );
      expect(api.debugAccessToken, isNull);
    });

    test('concurrent refreshes are coalesced into one exchange', () async {
      // The server keeps one ACTIVE refresh token per session, so a second
      // concurrent exchange is guaranteed to lose — and would read its own
      // rejection as the session expiring.
      await store.write('r1');
      final gate = Completer<AuthResult>();
      auth.refreshGate = gate;

      final a = controller().restore();
      final b = controller().debugRefreshNow();
      await pumpEventQueue();

      gate.complete(_result('shared'));
      await Future.wait([a, b]);

      expect(auth.refreshCalls, 1);
    });
  });

  group('rotation', () {
    test('a rotated token that cannot be saved ends the session', () async {
      // The server has rotated: only the new token works now. Carrying on
      // would look healthy until the next refresh presented the dead one.
      await controller().adopt(_result('token-1'));
      store.writable = false;

      await controller().adopt(_result('token-2', refresh: 'rotated'));

      expect(session(), isA<SignedOut>());
      expect((session() as SignedOut).reason, SignedOutReason.expired);
    });
  });

  group('CSRF', () {
    test('the token accompanies a refresh when the platform has one', () async {
      // The server rejects a Web refresh that arrives without this header, so
      // omitting it does not merely weaken a defence — it makes session
      // restore fail with 401 on every Web launch.
      csrf.token = 'csrf-abc';
      await store.write('stored');

      await controller().restore();

      expect(auth.lastCsrfToken, 'csrf-abc');
    });

    test('nothing is invented when the platform has no token', () async {
      // Android sends the refresh token in the body; there is no ambient
      // credential to defend and the server does not check.
      csrf.token = null;
      await store.write('stored');

      await controller().restore();

      expect(auth.lastCsrfToken, isNull);
    });
  });

  group('a rejected token ends the session', () {
    test('a 401 on an authenticated request signs the person out', () async {
      // Otherwise each screen discovers the dead token separately, shows its
      // own recovery state, and Session goes on claiming Authenticated
      // behind them.
      await controller().adopt(_result('token-1'));
      expect(session(), isA<Authenticated>());

      api.debugSimulateAuthenticationLoss();

      expect(session(), isA<SignedOut>());
      expect((session() as SignedOut).reason, SignedOutReason.expired);
      expect(api.debugAccessToken, isNull);
    });

    test('it does nothing when no session was open', () async {
      await controller().restore();
      expect(session(), isA<SignedOut>());

      api.debugSimulateAuthenticationLoss();

      // Still signed out, and with no reason invented for it.
      expect((session() as SignedOut).reason, isNull);
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
  String? lastCsrfToken;
  /// The server answered and refused: a 401, as it does for a dead credential.
  bool refreshRejected = false;

  /// The server never answered: offline, DNS, timeout.
  bool refreshUnreachable = false;

  bool logoutFails = false;

  /// Held open to keep a call in flight while the test does something else.
  Completer<AuthResult>? refreshGate;
  Completer<void>? logoutGate;

  @override
  Future<AuthResult> refresh({String? refreshToken, String? csrfToken}) async {
    refreshCalls++;
    lastRefreshToken = refreshToken;
    lastCsrfToken = csrfToken;
    if (refreshRejected) {
      throw DioException(
        requestOptions: RequestOptions(path: '/v1/auth/refresh'),
        response: Response<void>(
          requestOptions: RequestOptions(path: '/v1/auth/refresh'),
          statusCode: 401,
        ),
      );
    }
    final gate = refreshGate;
    if (gate != null) {
      refreshGate = null;
      return gate.future;
    }
    if (refreshUnreachable) {
      throw DioException.connectionError(
        requestOptions: RequestOptions(path: '/v1/auth/refresh'),
        reason: 'offline',
      );
    }
    return _result('refreshed-access');
  }

  @override
  Future<void> logout() async {
    await logoutGate?.future;
    if (logoutFails) throw StateError('offline');
  }

  @override
  noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} not used by this test');
}

class _FakeCsrf implements CsrfTokens {
  String? token;

  @override
  String? read() => token;
}

class _MemoryStore implements RefreshStore {
  String? _token;

  @override
  Future<String?> read() async => _token;

  /// Set false to simulate a Keystore that will not accept a write.
  bool writable = true;

  @override
  Future<bool> write(String token) async {
    if (!writable) return false;
    _token = token;
    return true;
  }

  @override
  Future<void> clear() async => _token = null;
}
