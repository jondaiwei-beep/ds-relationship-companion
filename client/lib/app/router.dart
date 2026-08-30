import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/entrance/presentation/create_account_screen.dart';
import '../features/entrance/presentation/entrance_screen.dart';
import '../features/entrance/presentation/sign_in_screen.dart';
import '../features/today/presentation/today_screen.dart';
import '../platform/session/session.dart';
import '../platform/session/session_controller.dart';
import 'not_built_yet.dart';
import 'session_resolving.dart';

/// Paths, named once.
///
/// The URLs are not new: they are the contract in
/// `docs/rebuild/route-contract.md`, carried over from the client that was
/// deleted. They encode deep-link shape, Web refresh and back behaviour, and
/// the invitation entry point — none of which is safe to re-invent.
abstract final class Routes {
  static const today = '/today';
  /// Where a signed-out person lands. SCR-04's contract is explicit — "first
  /// open or signed-out launch" — and SCR-05 is reached by choosing to sign in
  /// from here, not by being sent there.
  static const entrance = '/entrance';
  static const createAccount = '/create-account';
  static const signIn = '/sign-in';
  static const authCallback = '/auth/callback';
  static const invite = '/invite/:token';
  static const start = '/start';
  static const dynamicToday = '/dynamics/:id/today';

  /// Where a request waits while the session is still resolving.
  ///
  /// Renders nothing and asks for nothing. Without it, "not known yet" would
  /// have to be expressed as "let it through", and a protected screen would
  /// fetch relationship data before anyone had established a right to read it.
  static const holding = '/holding';

  /// Reachable without a session. Everything else is guarded.
  ///
  /// `/invite/:token` is public on purpose: an invited person must be able to
  /// see *what* they are being asked to join before signing in. Opening the
  /// link is not joining — joining is an explicit act on the page.
  static bool isPublic(String location) =>
      location.startsWith('/invite/') ||
      location == entrance ||
      location == createAccount ||
      location == signIn ||
      location == authCallback;
}

GoRouter createRouter(Ref ref) {
  return GoRouter(
    initialLocation: Routes.today,
    refreshListenable: _SessionListenable(ref),

    // Synchronous, and about authentication only.
    //
    // Resolving an invite or an occurrence here would be race-prone and can
    // produce redirect loops; that work belongs in page state. This rule was
    // learned the hard way in the client this router replaces.
    redirect: (context, state) {
      final session = ref.read(sessionProvider);
      final location = state.matchedLocation;

      // Startup: whether a session can be restored is not known yet.
      //
      // Redirecting now would flash the entrance and, on Web, write the wrong
      // URL into history — then undo both a frame later. But returning `null`
      // is not "wait" either: it lets the protected route build, and a screen
      // that builds fetches. Observed in a browser: `/dynamics/abc/today`
      // issued an unauthenticated read for relationship data before the guard
      // had decided anything.
      //
      // Holding the door means rendering nothing, so `/holding` is a real
      // route with no content and no requests. It is never pushed onto
      // history: the guard replaces it as soon as the session resolves, and
      // the destination is carried in `returnTo` exactly as it is for the
      // entrance.
      if (session is SessionUnknown) {
        // Already waiting, or on a route that needs no session: stay put.
        // Redirecting `/holding` to `/holding` is a loop, and go_router
        // answers a loop with its error screen — which is how this was found.
        if (location == Routes.holding || Routes.isPublic(location)) return null;
        final returnTo = Uri.encodeComponent(state.uri.toString());
        return '${Routes.holding}?returnTo=$returnTo';
      }

      // Leaving the holding route: go where the person was actually heading.
      if (location == Routes.holding) {
        final destination = _destinationFrom(state);
        return session.isAuthenticated
            ? destination
            : '${Routes.entrance}?returnTo=${Uri.encodeComponent(destination)}';
      }

      final public = Routes.isPublic(location);

      if (!session.isAuthenticated && !public) {
        // The destination travels in the URL so it survives a Web refresh and
        // a magic-link callback opened in a new tab.
        final returnTo = Uri.encodeComponent(state.uri.toString());
        return '${Routes.entrance}?returnTo=$returnTo';
      }

      if (session.isAuthenticated &&
          (location == Routes.signIn || location == Routes.entrance)) {
        return _destinationFrom(state);
      }

      return null;
    },

    routes: [
      GoRoute(
        path: Routes.today,
        // Sign-in cannot know a dynamic id and every real screen needs one.
        // Until the resolver screen exists this is the one built surface.
        builder: (context, _) => TodayScreen(
          dynamicId: 'preview',
          onSignIn: () => context.go(Routes.signIn),
        ),
      ),
      GoRoute(
        path: Routes.dynamicToday,
        builder: (context, s) => TodayScreen(
          dynamicId: s.pathParameters['id']!,
          onSignIn: () => context.go(Routes.signIn),
          // `onSelectTab` stays absent: three of the four destinations have
          // no screen. A bar that routes to a placeholder is worse than one
          // that does not respond — it teaches that the app is broken rather
          // than unfinished.
        ),
      ),

      // Named, not stubbed.
      //
      // Each of these is a real route with a design and a closed gate. A
      // placeholder that renders something plausible is worse than one that
      // says what it is: it gets screenshotted, demoed, and mistaken for
      // progress. See `progress/MASTER-PLAN.md` for which sprint opens each.
      GoRoute(
        path: Routes.holding,
        builder: (_, _) => const SessionResolving(),
      ),
      GoRoute(
        path: Routes.entrance,
        builder: (context, state) => EntranceScreen(
          // Registration is its own flow; the entrance only opens the door to
          // it. Wiring `Continue` straight to a network call here would make
          // this screen own a command it cannot show the result of.
          onContinue: () => context.go(Routes.createAccount),
          onSignIn: () => context.go(Routes.signIn),
          notice: _noticeFor(ref.read(sessionProvider)),
        ),
      ),
      GoRoute(
        path: Routes.signIn,
        builder: (context, state) => SignInScreen(
          onSignedIn: () => context.go(_destinationFrom(state)),
          onCreateAccount: () => context.go(Routes.createAccount),
          onBack: () => context.go(Routes.entrance),
          notice: _signInNoticeFor(ref.read(sessionProvider)),
        ),
      ),
      GoRoute(
        path: Routes.createAccount,
        builder: (context, state) => CreateAccountScreen(
          // The session is adopted by `register` before this fires, so the
          // guard sends them on to wherever they were heading.
          onCreated: () => context.go(_destinationFrom(state)),
          onSignIn: () => context.go(Routes.signIn),
          onBack: () => context.go(Routes.entrance),
        ),
      ),
      GoRoute(
        path: Routes.authCallback,
        builder: (_, _) => const NotBuiltYet(screen: 'Magic-link callback'),
      ),
      GoRoute(
        path: Routes.invite,
        builder: (_, _) => const NotBuiltYet(screen: 'SCR-10 Web Join'),
      ),
      GoRoute(
        path: Routes.start,
        builder: (_, _) => const NotBuiltYet(screen: 'SCR-31 Goal Selection'),
      ),
    ],
  );
}

/// What the entrance should say about the session, if anything.
///
/// Only an expired session earns a line. Being signed out because you asked to
/// be, or because you have never signed in, is the ordinary case and the
/// entrance says nothing about it — an app that explains your own sign-out back
/// to you is talking about the wrong thing.
EntranceNotice? _noticeFor(Session session) => switch (session) {
  SignedOut(reason: SignedOutReason.expired) => EntranceNotice.sessionEnded,
  _ => null,
};

/// Why sign-in is being shown, when it was not chosen.
///
/// Only an expired session says anything. Arriving here by choosing "I already
/// have an account" is the ordinary case and needs no explanation.
SignInNotice? _signInNoticeFor(Session session) => switch (session) {
  SignedOut(reason: SignedOutReason.expired) => SignInNotice.authorizationLost,
  _ => null,
};

/// Where a redirect should land after the session resolves.
///
/// `Uri.queryParameters` already percent-decodes, so decoding again would
/// corrupt any destination containing an encoded `/`, `&`, `#` or `%`.
///
/// The value is also untrusted — it survives a Web reload, so anyone can put
/// anything in the address bar. Only a path within this app is honoured;
/// anything else falls back to Today rather than becoming an open redirect or
/// a router error.
String _destinationFrom(GoRouterState state) {
  final returnTo = state.uri.queryParameters['returnTo'];
  if (returnTo == null || returnTo.isEmpty) return Routes.today;

  // A local path, not `//host` (protocol-relative) and not `scheme://host`.
  if (!returnTo.startsWith('/') || returnTo.startsWith('//')) {
    return Routes.today;
  }
  // Never bounce back to the waiting room or the entrance: both would loop.
  final path = Uri.tryParse(returnTo)?.path;
  if (path == null ||
      path == Routes.holding ||
      path == Routes.signIn ||
      path == Routes.entrance) {
    return Routes.today;
  }
  return returnTo;
}

/// Bridges the session to `GoRouter`, which predates Riverpod's listeners and
/// wants a [Listenable].
///
/// Only notifies when the guard could decide differently.
///
/// A token refresh produces a new [Authenticated] every few minutes; treating
/// each one as a navigation event would re-run every redirect for nothing.
/// But "is someone signed in" is not enough on its own to compare: leaving
/// [SessionUnknown] for [SignedOut] keeps that answer false while changing
/// the guard's behaviour from "hold the door" to "send them to the entrance".
/// Comparing the decision the guard actually makes covers both.
class _SessionListenable extends ChangeNotifier {
  _SessionListenable(Ref ref) {
    _last = _decision(ref.read(sessionProvider));
    ref.listen<Session>(sessionProvider, (_, next) {
      final decision = _decision(next);
      if (decision == _last) return;
      _last = decision;
      notifyListeners();
    });
  }

  late _GuardDecision _last;

  static _GuardDecision _decision(Session s) => switch (s) {
        SessionUnknown() => _GuardDecision.wait,
        SignedOut() => _GuardDecision.deny,
        Authenticated() => _GuardDecision.allow,
      };
}

enum _GuardDecision { wait, deny, allow }

final routerProvider = Provider<GoRouter>(createRouter);
