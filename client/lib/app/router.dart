import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/entrance/presentation/auth_callback_screen.dart';
import '../features/entrance/presentation/create_account_screen.dart';
import '../features/entrance/presentation/entrance_screen.dart';
import '../features/activation/presentation/activation_wizard.dart';
import '../features/activation/presentation/timezone_unavailable.dart';
import '../features/rules/presentation/rules_screen.dart';
import '../features/dynamic/presentation/pause_screen.dart';
import '../features/settings/presentation/leave_screen.dart';
import '../features/points/presentation/points_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/explore/presentation/explore_screen.dart';
import '../features/explore/presentation/starter_pack_screen.dart';
import 'home_resolver.dart';
import 'shell/bottom_navigation.dart';
import '../features/entrance/presentation/sign_in_screen.dart';
import '../features/invite/presentation/invite_partner_screen.dart';
import '../features/invite/presentation/join_screen.dart';
import '../platform/time/device_timezone.dart';
import '../features/today/presentation/today_screen.dart';
import '../features/record/presentation/record_screen.dart';
import '../features/record/presentation/day_screen.dart';
import '../features/record/presentation/series_screen.dart';
import '../platform/session/session.dart';
import '../platform/session/session_controller.dart';
import 'session_resolving.dart';
import '../features/dynamic/application/dynamic_providers.dart';
import '../features/today/application/today_providers.dart';

/// Paths, named once. They encode deep-link shape, Web refresh and back
/// behaviour, and the invitation entry point.
abstract final class Routes {
  static const today = '/today';
  static const rules = '/rules';
  static const record = '/record';
  static const points = '/points';

  /// Where a signed-out person lands. SCR-04's contract is explicit — "first
  /// open or signed-out launch" — and SCR-05 is reached by choosing to sign in
  /// from here, not by being sent there.
  static const entrance = '/entrance';
  static const createAccount = '/create-account';
  static const signIn = '/sign-in';
  static const authCallback = '/auth/callback';
  static const invite = '/invite/:token';

  /// The sending side. Authenticated and inside a Dynamic, unlike
  /// `/invite/:token`, which is the public page the link opens.
  static const invitePartner = '/dynamics/:id/invite';

  /// Pausing or returning.
  static const pause = '/dynamics/:id/pause';

  /// Settings (SCR-28/29/34), and ending the pairing (SCR-30).
  static const settings = '/dynamics/:id/settings';
  static const leave = '/dynamics/:id/leave';

  /// The four tabs (product/02-surfaces.md). Explore lives inside Rules.
  static const dynamicPoints = '/dynamics/:id/points';
  static const start = '/start';
  static const dynamicToday = '/dynamics/:id/today';
  static const dynamicRules = '/dynamics/:id/rules';
  static const dynamicRecord = '/dynamics/:id/record';

  /// One day of the record. Also where a `/record/:day` notification lands
  /// once the Dynamic is known.
  static const dynamicRecordDay = '/dynamics/:id/record/:day';

  /// One measure task's curve (Phase 5). `?title=` names it in the header.
  static const dynamicRecordSeries = '/dynamics/:id/record/series/:taskId';

  /// The deep link a notification carries has no Dynamic in it; this resolves
  /// one the way `/today` does and goes on to the day.
  static const recordDay = '/record/:day';
  static const dynamicExplore = '/dynamics/:id/explore';
  static const dynamicExplorePacks = '/dynamics/:id/explore/packs';

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
        if (location == Routes.holding || Routes.isPublic(location)) {
          return null;
        }
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
      // The four tabs. One navigator per tab, kept alive while another tab is
      // showing, so a scroll position or a half-read day survives a trip to
      // 规矩 and back. Sub-screens live in the tab they belong to; leaving the
      // shell (settings, invite, leave) is a different kind of move.
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => shell,
        branches: [
          // A branch's first route may not carry a parameter, so each tab
          // opens with its bare resolver — which also gives notifications a
          // Dynamic-free deep link per tab, the way `/today` already did.
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.today,
                // Nobody can know a dynamic id at sign-in, and a fresh account has no
                // Dynamic at all. This used to pass the literal string 'preview',
                // which the server rejected as an invalid UUID — so a person who had
                // just registered was told "Today could not be loaded".
                builder: (context, _) => HomeResolver(
                  onDynamic: (id) => context.go('/dynamics/$id/today'),
                  onNoDynamic: () => context.go(Routes.start),
                  onSignIn: () => context.go(Routes.signIn),
                ),
              ),
              GoRoute(
                path: Routes.dynamicToday,
                builder: (context, s) {
                  final dynamicId = s.pathParameters['id']!;
                  return TodayScreen(
                    dynamicId: dynamicId,
                    onSignIn: () => context.go(Routes.signIn),
                    onSelectTab: (surface) =>
                        context.go(_navPath(dynamicId, surface)),
                    onSettings: () =>
                        context.go('/dynamics/$dynamicId/settings'),
                    onInvite: () => context.go('/dynamics/$dynamicId/invite'),
                    onPause: () => context.go('/dynamics/$dynamicId/pause'),
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.rules,
                builder: (context, _) => HomeResolver(
                  onDynamic: (id) => context.go(_navPath(id, NavSurface.rules)),
                  onNoDynamic: () => context.go(Routes.start),
                  onSignIn: () => context.go(Routes.signIn),
                ),
              ),
              GoRoute(
                path: _navPath(':id', NavSurface.rules),
                builder: (context, s) {
                  final dynamicId = s.pathParameters['id']!;
                  return RulesScreen(
                    dynamicId: dynamicId,
                    onSignIn: () => context.go(Routes.signIn),
                    onSelectTab: (next) =>
                        context.go(_navPath(dynamicId, next)),
                    onPause: () => context.go('/dynamics/$dynamicId/pause'),
                    onExplore: (section) => context.go(
                      '/dynamics/$dynamicId/explore?section=${section.name}',
                    ),
                    onStarterPacks: () =>
                        context.go('/dynamics/$dynamicId/explore/packs'),
                  );
                },
              ),
              GoRoute(
                path: Routes.pause,
                builder: (context, s) {
                  final dynamicId = s.pathParameters['id']!;
                  return PauseScreen(
                    dynamicId: dynamicId,
                    onDone: () =>
                        context.go(_navPath(dynamicId, NavSurface.rules)),
                  );
                },
              ),
              GoRoute(
                path: Routes.dynamicExplore,
                builder: (context, s) {
                  final dynamicId = s.pathParameters['id']!;
                  return ExploreScreen(
                    dynamicId: dynamicId,
                    initialSection: ExploreSection.parse(
                      s.uri.queryParameters['section'],
                    ),
                    onSignIn: () => context.go(Routes.signIn),
                    onSelectTab: (next) =>
                        context.go(_navPath(dynamicId, next)),
                    onBack: () =>
                        context.go(_navPath(dynamicId, NavSurface.rules)),
                  );
                },
              ),
              GoRoute(
                path: Routes.dynamicExplorePacks,
                builder: (context, s) {
                  final dynamicId = s.pathParameters['id']!;
                  return StarterPackScreen(
                    dynamicId: dynamicId,
                    onBack: () =>
                        context.go(_navPath(dynamicId, NavSurface.rules)),
                    onDone: () =>
                        context.go(_navPath(dynamicId, NavSurface.rules)),
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.record,
                builder: (context, _) => HomeResolver(
                  onDynamic: (id) =>
                      context.go(_navPath(id, NavSurface.record)),
                  onNoDynamic: () => context.go(Routes.start),
                  onSignIn: () => context.go(Routes.signIn),
                ),
              ),
              GoRoute(
                path: _navPath(':id', NavSurface.record),
                builder: (context, s) {
                  final dynamicId = s.pathParameters['id']!;
                  return RecordScreen(
                    dynamicId: dynamicId,
                    onSignIn: () => context.go(Routes.signIn),
                    onSelectTab: (next) =>
                        context.go(_navPath(dynamicId, next)),
                    onOpenDay: (day) =>
                        context.go('/dynamics/$dynamicId/record/$day'),
                    onOpenSeries: (taskId, title) =>
                        context.push(_seriesPath(dynamicId, taskId, title)),
                  );
                },
              ),
              GoRoute(
                path: Routes.dynamicRecordDay,
                builder: (context, s) {
                  final dynamicId = s.pathParameters['id']!;
                  final day = s.pathParameters['day']!;
                  return DayScreen(
                    dynamicId: dynamicId,
                    day: day,
                    onSignIn: () => context.go(Routes.signIn),
                    onBack: () =>
                        context.go(_navPath(dynamicId, NavSurface.record)),
                    onOpenSeries: (taskId, title) =>
                        context.push(_seriesPath(dynamicId, taskId, title)),
                  );
                },
              ),
              GoRoute(
                path: Routes.dynamicRecordSeries,
                builder: (context, s) {
                  final dynamicId = s.pathParameters['id']!;
                  final taskId = s.pathParameters['taskId']!;
                  return SeriesScreen(
                    dynamicId: dynamicId,
                    taskId: taskId,
                    title: s.uri.queryParameters['title'],
                    onBack: () => context.canPop()
                        ? context.pop()
                        : context.go(_navPath(dynamicId, NavSurface.record)),
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.points,
                builder: (context, _) => HomeResolver(
                  onDynamic: (id) =>
                      context.go(_navPath(id, NavSurface.points)),
                  onNoDynamic: () => context.go(Routes.start),
                  onSignIn: () => context.go(Routes.signIn),
                ),
              ),
              GoRoute(
                path: Routes.dynamicPoints,
                builder: (context, state) {
                  final dynamicId = state.pathParameters['id']!;
                  return PointsScreen(
                    dynamicId: dynamicId,
                    onSignIn: () => context.go(Routes.signIn),
                    onSelectTab: (surface) =>
                        context.go(_navPath(dynamicId, surface)),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: Routes.settings,
        builder: (context, s) {
          final dynamicId = s.pathParameters['id']!;
          return SettingsScreen(
            dynamicId: dynamicId,
            onClose: () => context.go(_navPath(dynamicId, NavSurface.today)),
            onSignOut: () => ref.read(sessionProvider.notifier).signOut(),
            onLeave: () => context.go('/dynamics/$dynamicId/leave'),
            onPoints: () => context.go('/dynamics/$dynamicId/points'),
          );
        },
      ),
      GoRoute(
        path: Routes.leave,
        builder: (context, s) {
          final dynamicId = s.pathParameters['id']!;
          return LeaveScreen(
            dynamicId: dynamicId,
            // Back to the root: the Dynamic may no longer exist to return to,
            // and the guard sends a signed-in person wherever they now belong.
            onDone: () {
              // Whatever was read about this Dynamic is now someone else's.
              ref.invalidate(todayProvider(dynamicId));
              ref.invalidate(dynamicDetailProvider(dynamicId));
              context.go(Routes.today);
            },
          );
        },
      ),
      GoRoute(
        path: Routes.recordDay,
        builder: (context, s) {
          final day = s.pathParameters['day']!;
          return HomeResolver(
            onDynamic: (id) => context.go('/dynamics/$id/record/$day'),
            onNoDynamic: () => context.go(Routes.start),
            onSignIn: () => context.go(Routes.signIn),
          );
        },
      ),
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
        builder: (context, state) => AuthCallbackScreen(
          onSignedIn: () => context.go(_destinationFrom(state)),
          onRequestNewLink: () => context.go(Routes.signIn),
        ),
      ),
      GoRoute(
        path: Routes.invitePartner,
        builder: (context, state) {
          final dynamicId = state.pathParameters['id']!;
          return InvitePartnerScreen(
            dynamicId: dynamicId,
            onDone: () => context.go('/dynamics/$dynamicId/today'),
            onBack: () => context.go('/dynamics/$dynamicId/today'),
          );
        },
      ),
      GoRoute(
        path: Routes.invite,
        builder: (context, state) {
          final token = state.pathParameters['token'] ?? '';
          return JoinScreen(
            token: token,
            onJoined: (dynamicId) => context.go('/dynamics/$dynamicId/today'),
            onDecline: () => context.go(Routes.entrance),
            // Joined, or already in: the root works out which Dynamic. Signed
            // out, the guard turns this into the entrance on its own.
            onAlreadyIn: () => context.go(Routes.today),
            // The invitation travels with them so they land back here rather
            // than in an empty Today after signing in.
            onSignIn: () => context.go(
              '${Routes.entrance}?returnTo='
              '${Uri.encodeComponent('/invite/$token')}',
            ),
          );
        },
      ),
      GoRoute(
        path: Routes.start,
        builder: (context, state) {
          // REQ-TIME-001 will not accept a guess, and a Dynamic created in
          // the wrong zone moves someone's relationship day months later. But
          // "cannot read it" must stay recoverable: this used to render a
          // placeholder with no way forward, which is where every newly
          // registered Android account landed.
          final zone = deviceTimezone() ?? state.uri.queryParameters['tz'];
          if (zone == null) {
            return TimezoneUnavailable(
              onResolved: (tz) =>
                  context.go('${Routes.start}?tz=${Uri.encodeComponent(tz)}'),
            );
          }
          return ActivationWizard(
            timezone: zone,
            // 首日路线 (product/02-surfaces.md): the invitation comes before
            // Today. A day with nobody on the other side has nothing in it.
            onStarted: (dynamicId) => context.go('/dynamics/$dynamicId/today'),
            onStartedNeedsPartner: (dynamicId) =>
                context.go('/dynamics/$dynamicId/invite'),
            onLeave: () => context.go(Routes.today),
          );
        },
      ),
    ],
  );
}

/// The route behind each tab of the bottom bar.
///
/// One function so the bar and the routes cannot disagree: every caller that
/// navigates and every route that registers reads the same mapping.
String _navPath(String dynamicId, NavSurface surface) => switch (surface) {
  NavSurface.today => '/dynamics/$dynamicId/today',
  NavSurface.rules => '/dynamics/$dynamicId/rules',
  NavSurface.record => '/dynamics/$dynamicId/record',
  NavSurface.points => '/dynamics/$dynamicId/points',
};

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

String _seriesPath(String dynamicId, String taskId, String title) => Uri(
  path: '/dynamics/$dynamicId/record/series/$taskId',
  queryParameters: {'title': title},
).toString();
