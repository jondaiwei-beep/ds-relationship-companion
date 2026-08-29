import 'dart:async';

import 'package:dio/dio.dart';

import 'package:flutter/foundation.dart' show kIsWeb, visibleForTesting;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../domain_client/api_client.dart';
import '../../domain_client/repositories/auth_repository.dart';
import 'csrf.dart';
import 'refresh_store.dart';
import 'session.dart';

/// Owns the session for the whole app: restores it at launch, keeps the
/// access token fresh, and ends it.
///
/// Everything that needs to know whether someone is signed in reads this.
/// Nothing else writes an access token onto [ApiClient] — a second writer
/// would mean two answers to "who is signed in", and the guard would
/// eventually believe the wrong one.
class SessionController extends Notifier<Session> {
  Timer? _refreshTimer;

  /// Bumped by every deliberate session change.
  ///
  /// Cancelling `_refreshTimer` stops a callback that has not started; it does
  /// nothing to a request already in flight. Without this, a refresh that was
  /// sent before sign-out could return afterwards and re-authenticate someone
  /// who has handed their phone back.
  int _generation = 0;

  /// In-flight refresh, shared by every caller.
  ///
  /// The server keeps one ACTIVE refresh token per session, so two concurrent
  /// exchanges cannot both succeed — the loser is rejected and would read
  /// that rejection as expiry.
  Future<AuthResult>? _inFlightRefresh;

  /// Refresh this far before the token actually expires, so a slow network
  /// does not turn a scheduled refresh into a 401 mid-request.
  static const _refreshMargin = Duration(minutes: 1);

  /// Never schedule a refresh closer than this. A server that returns a very
  /// short lifetime must not turn into a request loop.
  static const _minRefreshDelay = Duration(seconds: 5);

  /// How soon to try again when the server could not be reached at all.
  static const _retryAfterFailure = Duration(seconds: 30);

  @override
  Session build() {
    ref.onDispose(() => _refreshTimer?.cancel());
    return const SessionUnknown();
  }

  AuthRepository get _auth => ref.read(authRepositoryProvider);
  RefreshStore get _store => ref.read(refreshStoreProvider);
  CsrfTokens get _csrf => ref.read(csrfTokensProvider);
  ApiClient get _api => ref.read(apiClientProvider);

  /// Try to restore a session at launch.
  ///
  /// Called once, before the first frame that could show protected content.
  /// Until it completes the session is [SessionUnknown] and the guard holds
  /// the door rather than guessing.
  Future<void> restore() async {
    // Web always has a cookie worth trying; Android needs a stored token.
    if (!kIsWeb && await _store.read() == null) {
      state = const SignedOut();
      return;
    }

    final generation = _generation;
    try {
      final result = await _exchange();
      await _adopt(result, generation);
    } on _CredentialRejected {
      // The credential is genuinely no good. Nobody asked for anything yet,
      // so this carries no reason to explain.
      await _store.clear();
      if (generation == _generation) state = const SignedOut();
    } catch (_) {
      // Could not ask, as opposed to asked and refused. Deleting a refresh
      // token because the airport wifi was down would sign someone out
      // permanently for a temporary problem.
      if (generation == _generation) state = const SignedOut();
    }
  }

  /// Adopt the result of a successful register / sign-in / magic-link consume.
  Future<void> adopt(AuthResult result) => _adopt(result, _generation);

  /// Exchange the refresh credential, coalescing concurrent callers.
  Future<AuthResult> _exchange() {
    final existing = _inFlightRefresh;
    if (existing != null) return existing;

    final attempt = () async {
      try {
        return await _auth.refresh(
          refreshToken: await _store.read(),
          csrfToken: _csrf.read(),
        );
      } on DioException catch (e) {
        final status = e.response?.statusCode;
        // 401/403 is the server saying the credential is no good. Anything
        // else — timeout, DNS, offline, a 5xx — means the question never got
        // an answer, which is a different fact about the session.
        if (status == 401 || status == 403) throw const _CredentialRejected();
        rethrow;
      }
    }();

    _inFlightRefresh = attempt;
    attempt.whenComplete(() {
      if (identical(_inFlightRefresh, attempt)) _inFlightRefresh = null;
    }).ignore();
    return attempt;
  }

  Future<void> _adopt(AuthResult result, int generation) async {
    // The session changed while this was in flight — signed out, or replaced
    // by a newer sign-in. Adopting now would resurrect it.
    if (generation != _generation) return;

    final refresh = result.refreshToken;
    if (refresh != null && !await _store.write(refresh)) {
      // The server has rotated: only the new token works now, and it could
      // not be saved. Carrying on would look healthy until the next refresh
      // presented the old token and failed. Better to end it here, while the
      // person can see why.
      await _endSession(SignedOutReason.expired);
      return;
    }

    if (generation != _generation) return;

    _api.accessToken = result.accessToken;
    state = Authenticated(accessToken: result.accessToken);
    _scheduleRefresh(result.accessTokenExpiresIn);
  }

  void _scheduleRefresh(Duration lifetime) {
    _refreshTimer?.cancel();
    if (!ref.read(autoRefreshProvider)) return;
    _refreshTimer = Timer(refreshDelayFor(lifetime), _refreshNow);
  }

  /// When to refresh, given how long the token lives.
  ///
  /// Ahead of expiry, so a slow network does not turn a scheduled refresh
  /// into a 401 mid-request — but never so soon that a server returning a
  /// very short lifetime turns this into a request loop.
  @visibleForTesting
  static Duration refreshDelayFor(Duration lifetime) {
    final delay = lifetime - _refreshMargin;
    return delay < _minRefreshDelay ? _minRefreshDelay : delay;
  }

  /// Drives a refresh now, for tests that need one in flight.
  @visibleForTesting
  Future<void> debugRefreshNow() => _refreshNow();

  Future<void> _refreshNow() async {
    final generation = _generation;
    try {
      await _adopt(await _exchange(), generation);
    } on _CredentialRejected {
      // Rejected mid-session: this is the authorization-loss path. The guard
      // sends them to the entrance, and the reason is what lets it say
      // something true when it gets there.
      if (generation == _generation) {
        await _endSession(SignedOutReason.expired);
      }
    } catch (_) {
      // Could not reach the server. The access token is still valid for the
      // margin we refreshed inside, so keep the session and try again rather
      // than signing someone out over a tunnel.
      if (generation == _generation) _scheduleRefresh(_retryAfterFailure);
    }
  }

  /// The person asked to sign out.
  ///
  /// A shared or borrowed device is the ordinary case for a private app, so
  /// this is a safety control. Local state is cleared even if the server call
  /// fails — a network error must never leave someone signed in on a device
  /// they are handing back.
  Future<void> signOut() async {
    // Local denial first, server revocation second. Awaiting the network
    // before clearing would leave the session `Authenticated` — protected
    // content on screen, bearer token on new requests, refresh timer armed —
    // for the whole connect timeout of a device being handed back.
    await _endSession(SignedOutReason.requested);

    try {
      await _auth.logout();
    } catch (_) {
      // On Android the stored token is already gone, so the session is over.
      //
      // On Web the httpOnly cookie survives, and this process cannot reach
      // it: a reload would restore the session. Revocation is the server's
      // job and it did not happen. Surfacing that is a real gap, tracked in
      // progress/STATE.md rather than hidden behind a swallowed error.
    }
  }

  Future<void> _endSession(SignedOutReason reason) async {
    // Invalidate anything in flight before touching state, so a refresh that
    // is already on the wire cannot adopt its result after this returns.
    _generation++;
    _refreshTimer?.cancel();
    _refreshTimer = null;
    _inFlightRefresh = null;
    _api.accessToken = null;
    state = SignedOut(reason: reason);
    await _store.clear();
  }
}

/// The server refused the credential, as opposed to never answering.
class _CredentialRejected implements Exception {
  const _CredentialRejected();
}

final refreshStoreProvider = Provider<RefreshStore>((_) => RefreshStore());

final csrfTokensProvider = Provider<CsrfTokens>((_) => CsrfTokens());

/// Whether the session keeps its token fresh on a timer.
///
/// Always true in the app. Widget tests turn it off: a pending timer fails
/// the framework's post-test invariant check, and a test asserting where the
/// guard sent someone should not also be asserting about the clock. The
/// schedule itself is covered directly through [SessionController.refreshDelayFor].
final autoRefreshProvider = Provider<bool>((_) => true);

final sessionProvider = NotifierProvider<SessionController, Session>(
  SessionController.new,
);
