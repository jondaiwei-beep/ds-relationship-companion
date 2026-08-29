import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb, visibleForTesting;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../domain_client/api_client.dart';
import '../../domain_client/repositories/auth_repository.dart';
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

  /// Refresh this far before the token actually expires, so a slow network
  /// does not turn a scheduled refresh into a 401 mid-request.
  static const _refreshMargin = Duration(minutes: 1);

  /// Never schedule a refresh closer than this. A server that returns a very
  /// short lifetime must not turn into a request loop.
  static const _minRefreshDelay = Duration(seconds: 5);

  @override
  Session build() {
    ref.onDispose(() => _refreshTimer?.cancel());
    return const SessionUnknown();
  }

  AuthRepository get _auth => ref.read(authRepositoryProvider);
  RefreshStore get _store => ref.read(refreshStoreProvider);
  ApiClient get _api => ref.read(apiClientProvider);

  /// Try to restore a session at launch.
  ///
  /// Called once, before the first frame that could show protected content.
  /// Until it completes the session is [SessionUnknown] and the guard holds
  /// the door rather than guessing.
  Future<void> restore() async {
    // Web always has a cookie worth trying; Android needs a stored token.
    final stored = await _store.read();
    if (!kIsWeb && stored == null) {
      state = const SignedOut();
      return;
    }

    try {
      await _adopt(await _auth.refresh(refreshToken: stored));
    } catch (_) {
      // A refresh that fails at launch means there is no session to restore.
      // It is not an error to show anyone: nobody asked for anything yet.
      await _store.clear();
      state = const SignedOut();
    }
  }

  /// Adopt the result of a successful register / sign-in / magic-link consume.
  Future<void> adopt(AuthResult result) => _adopt(result);

  Future<void> _adopt(AuthResult result) async {
    final refresh = result.refreshToken;
    if (refresh != null) await _store.write(refresh);

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

  Future<void> _refreshNow() async {
    try {
      await _adopt(await _auth.refresh(refreshToken: await _store.read()));
    } catch (_) {
      // The credential was rejected. This is the authorization-loss path, and
      // the person is mid-session: the guard sends them to the entrance, and
      // the reason is what lets it say something true when it gets there.
      await _endSession(SignedOutReason.expired);
    }
  }

  /// The person asked to sign out.
  ///
  /// A shared or borrowed device is the ordinary case for a private app, so
  /// this is a safety control. Local state is cleared even if the server call
  /// fails — a network error must never leave someone signed in on a device
  /// they are handing back.
  Future<void> signOut() async {
    try {
      await _auth.logout();
    } catch (_) {
      // Deliberately ignored; see above.
    }
    await _endSession(SignedOutReason.requested);
  }

  Future<void> _endSession(SignedOutReason reason) async {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    _api.accessToken = null;
    await _store.clear();
    state = SignedOut(reason: reason);
  }
}

final refreshStoreProvider = Provider<RefreshStore>((_) => RefreshStore());

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
