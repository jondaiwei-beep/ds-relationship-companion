import 'package:dio/dio.dart';
import 'package:dsapp/app/providers.dart';
import 'package:dsapp/domain_client/api_client.dart';
import 'package:dsapp/domain_client/repositories/auth_repository.dart';
import 'package:dsapp/features/entrance/application/auth_actions.dart';
import 'package:dsapp/platform/session/csrf.dart';
import 'package:dsapp/platform/session/refresh_store.dart';
import 'package:dsapp/platform/session/session.dart';
import 'package:dsapp/platform/session/session_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// The entrance is the one surface an unauthenticated stranger can reach, so
/// what it says back is a security property, not only a usability one.
void main() {
  late _FakeAuth auth;
  late ProviderContainer container;

  setUp(() {
    auth = _FakeAuth();
    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(auth),
        refreshStoreProvider.overrideWithValue(_MemoryStore()),
        csrfTokensProvider.overrideWithValue(_NoCsrf()),
        apiClientProvider.overrideWithValue(ApiClient(baseUrl: 'http://test')),
        autoRefreshProvider.overrideWithValue(false),
      ],
    );
    addTearDown(container.dispose);
  });

  AuthActions actions() => container.read(authActionsProvider);

  DioException serverError(String code, {int status = 400}) => DioException(
        requestOptions: RequestOptions(path: '/'),
        response: Response(
          requestOptions: RequestOptions(path: '/'),
          statusCode: status,
          data: {'code': code},
        ),
      );

  group('signing in', () {
    test('opens the session on success', () async {
      final outcome = await actions().signIn(email: 'a@b.com', password: 'x');

      expect(outcome, isA<AuthSucceeded>());
      expect(container.read(sessionProvider), isA<Authenticated>());
    });

    test('a wrong password and an unknown address read identically', () async {
      // The difference tells an attacker which addresses have accounts here,
      // and on this product having an account is itself sensitive.
      auth.failure = serverError('INVALID_CREDENTIALS', status: 401);

      final outcome = await actions().signIn(email: 'a@b.com', password: 'x');

      final message = (outcome as AuthFailed).message;
      expect(message, isNot(contains('exist')));
      expect(message, isNot(contains('registered')));
      expect(message, isNot(contains('found')));
      expect(message, contains('email sign-in link'),
          reason: 'the recovery route must stay reachable from the failure');
    });

    test('offline is not reported as a credential problem', () async {
      auth.failure = DioException.connectionError(
        requestOptions: RequestOptions(path: '/'),
        reason: 'offline',
      );

      final outcome = await actions().signIn(email: 'a@b.com', password: 'x');

      expect((outcome as AuthFailed).message, contains('offline'));
    });

    test('a timeout is uncertain, not failed', () async {
      auth.failure = DioException.receiveTimeout(
        timeout: const Duration(seconds: 1),
        requestOptions: RequestOptions(path: '/'),
      );

      expect(
        await actions().signIn(email: 'a@b.com', password: 'x'),
        isA<AuthUncertain>(),
      );
    });
  });

  group('creating an account', () {
    test('is refused before a request goes out when age is unconfirmed',
        () async {
      final outcome = await actions()
          .register(email: 'a@b.com', password: 'x' * 10, ageConfirmed: false);

      expect((outcome as AuthFailed).field, AuthField.ageConfirmation);
      expect(
        auth.registerCalls,
        0,
        reason: 'no request should carry a password when we already know the '
            'server will refuse it',
      );
    });

    test('a short password points at the password field', () async {
      auth.failure = serverError('PASSWORD_TOO_SHORT');

      final outcome = await actions()
          .register(email: 'a@b.com', password: 'short', ageConfirmed: true);

      expect((outcome as AuthFailed).field, AuthField.password);
      expect(outcome.message, contains('$minPasswordLength'));
    });

    test('an uncertain result does not tell them to try again', () async {
      // The account may exist now. "Try again" would send them at an email
      // that is already taken and read as their own mistake.
      auth.failure = DioException.receiveTimeout(
        timeout: const Duration(seconds: 1),
        requestOptions: RequestOptions(path: '/'),
      );

      final outcome = await actions()
          .register(email: 'a@b.com', password: 'x' * 10, ageConfirmed: true);

      final message = (outcome as AuthUncertain).message;
      expect(message, contains('signing in'));
      expect(message, contains("couldn't confirm"));
    });
  });

  group('completing a sign-in link', () {
    test('a link opened on a device that did not ask for it is refused',
        () async {
      // The verifier never leaves the device that started the flow, so an
      // unknown flow here means the link was forwarded or intercepted.
      final outcome = await actions()
          .completeSignInLink(token: 'tok', flowId: 'never-started');

      expect(outcome, isA<AuthFailed>());
      expect(
        auth.consumeCalls,
        0,
        reason: 'no request should go out for a flow this device never began',
      );
    });

    test('a link from this device opens the session', () async {
      final flow = AuthFlow.start();
      await container.read(authFlowStoreProvider).save(flow);

      final outcome = await actions()
          .completeSignInLink(token: 'tok', flowId: flow.flowId);

      expect(outcome, isA<AuthSucceeded>());
      expect(container.read(sessionProvider), isA<Authenticated>());
    });

    test('the verifier is cleared once it has been used', () async {
      final flow = AuthFlow.start();
      final store = container.read(authFlowStoreProvider);
      await store.save(flow);

      await actions().completeSignInLink(token: 'tok', flowId: flow.flowId);

      expect(await store.load(flow.flowId), isNull);
    });

    test('a failure keeps the verifier, because a retry may still work',
        () async {
      final flow = AuthFlow.start();
      final store = container.read(authFlowStoreProvider);
      await store.save(flow);
      auth.failure = DioException.connectionError(
        requestOptions: RequestOptions(path: '/'),
        reason: 'offline',
      );

      await actions().completeSignInLink(token: 'tok', flowId: flow.flowId);

      expect(await store.load(flow.flowId), isNotNull);
    });

    test('an expired link says so and points at a new one', () async {
      final flow = AuthFlow.start();
      await container.read(authFlowStoreProvider).save(flow);
      auth.failure = serverError('INVALID_OR_EXPIRED_MAGIC_LINK');

      final outcome = await actions()
          .completeSignInLink(token: 'tok', flowId: flow.flowId);

      expect((outcome as AuthFailed).message, contains('Request a new one'));
    });
  });

  group('the email sign-in link', () {
    test('answers the same whether or not the address has an account',
        () async {
      auth.failure = serverError('NO_SUCH_ACCOUNT', status: 404);

      expect(
        await actions().requestSignInLink(email: 'stranger@b.com'),
        isA<AuthLinkSent>(),
        reason: 'a 4xx here would confirm which addresses can sign in',
      );
    });

    test('but offline is still reported, because nothing was sent', () async {
      auth.failure = DioException.connectionError(
        requestOptions: RequestOptions(path: '/'),
        reason: 'offline',
      );

      expect(
        await actions().requestSignInLink(email: 'a@b.com'),
        isA<AuthFailed>(),
      );
    });
  });
}

class _FakeAuth implements AuthRepository {
  int registerCalls = 0;
  int consumeCalls = 0;
  Object? failure;

  AuthResult _ok() => AuthResult(
        accessToken: 'token',
        accessTokenExpiresIn: const Duration(minutes: 15),
      );

  @override
  Future<AuthResult> register({
    required String email,
    required String password,
    required bool ageConfirmed,
  }) async {
    registerCalls++;
    if (failure != null) throw failure!;
    return _ok();
  }

  @override
  Future<AuthResult> signInWithPassword({
    required String email,
    required String password,
  }) async {
    if (failure != null) throw failure!;
    return _ok();
  }

  @override
  Future<AuthResult> consume({
    required String token,
    required AuthFlow flow,
    required String clientType,
  }) async {
    consumeCalls++;
    if (failure != null) throw failure!;
    return _ok();
  }

  @override
  Future<void> requestMagicLink({
    required String email,
    required AuthFlow flow,
    String? inviteToken,
  }) async {
    if (failure != null) throw failure!;
  }

  @override
  noSuchMethod(Invocation i) =>
      throw UnimplementedError('${i.memberName} not used by this test');
}

class _MemoryStore implements RefreshStore {
  String? _t;
  @override
  Future<String?> read() async => _t;
  @override
  Future<bool> write(String token) async {
    _t = token;
    return true;
  }

  @override
  Future<void> clear() async => _t = null;
}

class _NoCsrf implements CsrfTokens {
  @override
  String? read() => null;
}
