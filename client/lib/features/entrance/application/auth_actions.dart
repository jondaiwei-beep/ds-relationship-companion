import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../domain_client/repositories/auth_repository.dart';
import '../../../platform/session/session_controller.dart';

/// The outcome of one authentication attempt.
///
/// Sealed so a screen can say what happened without inspecting exceptions —
/// the entrance is the one place where the difference between "wrong password"
/// and "no network" changes what a person should do next.
sealed class AuthOutcome {
  const AuthOutcome();
}

/// Signed in. The session is already open; the guard will move the screen.
class AuthSucceeded extends AuthOutcome {
  const AuthSucceeded();
}

/// A sign-in link was sent, if that address can be used to sign in.
///
/// Deliberately says nothing about whether an account exists. The screen
/// shows the same confirmation either way.
class AuthLinkSent extends AuthOutcome {
  const AuthLinkSent();
}

/// The attempt failed. [message] is already written for a person to read, and
/// [field] names the input to focus, when one is at fault.
class AuthFailed extends AuthOutcome {
  const AuthFailed(this.message, {this.field});

  final String message;
  final AuthField? field;
}

/// The request may or may not have taken effect.
///
/// Distinct from [AuthFailed] because the safe next step is different: a
/// registration that timed out may have created the account, so telling
/// someone to "try again" invites a duplicate attempt against an email that
/// is now taken.
class AuthUncertain extends AuthOutcome {
  const AuthUncertain(this.message);

  final String message;
}

/// Which input an error belongs beside.
enum AuthField { email, password, ageConfirmation }

/// Runs the entrance's commands against the server.
///
/// Knows how a command reaches the server; knows nothing about layout. The
/// screens report which action was chosen and render what comes back.
class AuthActions {
  AuthActions(this._ref);

  final Ref _ref;

  /// Create an account, then adopt the session it returns.
  Future<AuthOutcome> register({
    required String email,
    required String password,
    required bool ageConfirmed,
  }) async {
    // Checked here as well as on the server. Not as a security boundary —
    // it is not one — but so the person is told before a request goes out
    // carrying a password.
    if (!ageConfirmed) {
      return const AuthFailed(
        'Confirm that you are 18 or older to create an account.',
        field: AuthField.ageConfirmation,
      );
    }

    try {
      final result = await _ref
          .read(authRepositoryProvider)
          .register(email: email, password: password, ageConfirmed: true);
      await _ref.read(sessionProvider.notifier).adopt(result);
      return const AuthSucceeded();
    } on DioException catch (e) {
      return _classifyRegister(e);
    } catch (_) {
      return const AuthFailed(_generic);
    }
  }

  Future<AuthOutcome> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _ref
          .read(authRepositoryProvider)
          .signInWithPassword(email: email, password: password);
      await _ref.read(sessionProvider.notifier).adopt(result);
      return const AuthSucceeded();
    } on DioException catch (e) {
      return _classifySignIn(e);
    } catch (_) {
      return const AuthFailed(_generic);
    }
  }

  /// Ask for a one-time sign-in link.
  ///
  /// The recovery path, and the only path for accounts created before
  /// password sign-in existed. There is no password-reset endpoint, and this
  /// is not one: it authenticates rather than changing a credential.
  Future<AuthOutcome> requestSignInLink({
    required String email,
    String? inviteToken,
  }) async {
    try {
      final flow = AuthFlow.start();
      await _ref.read(authFlowStoreProvider).save(flow);
      await _ref.read(authRepositoryProvider).requestMagicLink(
            email: email,
            flow: flow,
            inviteToken: inviteToken,
          );
      return const AuthLinkSent();
    } on DioException catch (e) {
      // A 4xx here would reveal whether the address can sign in, so only
      // transport failures are reported. Anything else answers as if sent.
      return _isOffline(e) ? const AuthFailed(_offline) : const AuthLinkSent();
    } catch (_) {
      return const AuthLinkSent();
    }
  }

  /// Complete a magic-link sign-in from the callback URL.
  ///
  /// The verifier never left this device, so a link forwarded to someone else
  /// — or intercepted — cannot authenticate in a browser that did not start
  /// the flow. If the flow is unknown here, that is exactly what happened,
  /// and it is refused without a request.
  Future<AuthOutcome> completeSignInLink({
    required String token,
    required String flowId,
  }) async {
    final store = _ref.read(authFlowStoreProvider);
    final flow = await store.load(flowId);
    if (flow == null) {
      return const AuthFailed(
        'Open the link on the device where you asked for it, or request a '
        'new one.',
      );
    }

    try {
      final result = await _ref.read(authRepositoryProvider).consume(
            token: token,
            flow: flow,
            clientType: kIsWeb ? 'WEB' : 'ANDROID',
          );
      // Cleared on success so the verifier does not linger. A failure keeps
      // it: the same link may still be retried on a flaky network.
      await store.clear(flowId);
      await _ref.read(sessionProvider.notifier).adopt(result);
      return const AuthSucceeded();
    } on DioException catch (e) {
      if (_isOffline(e)) return const AuthFailed(_offline);
      if (_isUncertain(e)) {
        return const AuthUncertain(
          "We couldn't confirm the sign-in. Try the link again.",
        );
      }
      return switch (_code(e)) {
        'INVALID_OR_EXPIRED_MAGIC_LINK' => const AuthFailed(
            'That link can no longer be used. Request a new one.',
          ),
        _ => const AuthFailed("We couldn't sign you in right now. Try again."),
      };
    } catch (_) {
      return const AuthFailed(_generic);
    }
  }

  AuthOutcome _classifySignIn(DioException e) {
    if (_isOffline(e)) return const AuthFailed(_offline);
    if (_isUncertain(e)) {
      return const AuthUncertain("We couldn't confirm the sign-in. Try again.");
    }
    return switch (_code(e)) {
      // Never distinguishes a wrong password from an unknown address: that
      // difference tells an attacker which emails have accounts here, and on
      // this product an account is itself sensitive.
      'INVALID_CREDENTIALS' => const AuthFailed(
          "We couldn't sign you in with those details. Check your email and "
          'password, or use an email sign-in link.',
        ),
      'ACCOUNT_NOT_ACTIVE' => const AuthFailed(
          "We can't sign you in. Try an email sign-in link or contact support.",
        ),
      _ => const AuthFailed("We couldn't sign you in right now. Try again."),
    };
  }

  AuthOutcome _classifyRegister(DioException e) {
    if (_isOffline(e)) return const AuthFailed(_offline);
    if (_isUncertain(e)) {
      // The account may exist now. "Try again" would send them at an email
      // that is already taken and read as their own mistake.
      return const AuthUncertain(
        "We couldn't confirm whether the account was created. Try signing in "
        'or request an email sign-in link before creating it again.',
      );
    }
    return switch (_code(e)) {
      'AGE_NOT_CONFIRMED' => const AuthFailed(
          'Confirm that you are 18 or older to create an account.',
          field: AuthField.ageConfirmation,
        ),
      'PASSWORD_TOO_SHORT' => const AuthFailed(
          'Use at least $minPasswordLength characters.',
          field: AuthField.password,
        ),
      'PASSWORD_TOO_LONG' => const AuthFailed(
          'Use no more than $maxPasswordLength characters.',
          field: AuthField.password,
        ),
      _ => const AuthFailed("We couldn't create the account right now. Try again."),
    };
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

  /// The request went out and no answer came back, so whether it took effect
  /// is unknown.
  static bool _isUncertain(DioException e) => switch (e.type) {
        DioExceptionType.sendTimeout || DioExceptionType.receiveTimeout => true,
        _ => e.response == null && !_isOffline(e),
      };

  static const _offline =
      "You're offline. Connect to the internet, then try again.";
  static const _generic = "Something went wrong. Try again.";
}

/// The server's rule, restated here so the form can say it before submitting
/// rather than after. `AuthServices.requireUsablePassword` is authoritative;
/// if it changes, this is wrong and the register error path is the backstop.
const minPasswordLength = 10;
const maxPasswordLength = 256;

final authActionsProvider = Provider<AuthActions>(AuthActions.new);
