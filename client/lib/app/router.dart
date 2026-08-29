import '../design_system/tokens/typography.dart';
import '../design_system/tokens/spacing.dart';
import '../design_system/tokens/colors.dart';
import '../design_system/components/ds_sheet.dart';
import '../design_system/components/ds_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/activation/presentation/auth_callback_screen.dart';
import '../features/activation/presentation/create_dynamic_screen.dart';
import '../features/activation/presentation/home_resolver.dart';
import '../features/activation/presentation/invite_screen.dart';
import '../features/activation/presentation/share_invite_screen.dart';
import '../features/activation/presentation/starter_rhythm_screen.dart';
import '../features/attention/presentation/attention_screen.dart';
import '../features/attention/presentation/new_expectation_screen.dart';
import '../features/dynamic/presentation/dynamic_screen.dart';
import '../features/explore/presentation/explore_screen.dart';
import '../features/dynamic/presentation/quiet_hours_screen.dart';
import '../features/dynamic/presentation/separation_screen.dart';
import '../features/us/presentation/us_screen.dart';
import '../features/activation/presentation/sign_in_screen.dart';
import '../features/today/presentation/occurrence_screen.dart';
import '../features/today/presentation/check_in_sheet.dart';
import '../features/today/presentation/today_screen.dart';
import 'nav_shell.dart';
import 'providers.dart';

/// Bridges a Riverpod provider to go_router's [GoRouter.refreshListenable].
///
/// The router instance must stay STABLE: rebuilding it on auth change resets
/// the Navigator and makes browser Back erratic.
class _AuthListenable extends ChangeNotifier {
  _AuthListenable(this._ref) {
    _ref.listen<bool>(authSessionProvider, (_, _) => notifyListeners());
  }
  final Ref _ref;
}

final routerProvider = Provider<GoRouter>((ref) {
  final listenable = _AuthListenable(ref);
  ref.onDispose(listenable.dispose);

  return GoRouter(
    initialLocation: '/today',
    refreshListenable: listenable,

    // Redirect stays SYNCHRONOUS and handles authentication only.
    // Resolving an invite or occurrence here would be race-prone and can
    // produce redirect loops — those belong in page state.
    redirect: (context, state) {
      final signedIn = ref.read(authSessionProvider);
      final loc = state.matchedLocation;

      // /invite/{token} is reachable unauthenticated: the invitee must be able
      // to see WHAT they are joining before signing in (Notion 02 §A5).
      final isPublic = loc.startsWith('/invite/') ||
          loc == '/sign-in' ||
          loc == '/auth/callback';

      if (!signedIn && !isPublic) {
        // Continuation travels in the URL so it survives a Web refresh and a
        // magic-link callback opened in a NEW tab.
        final returnTo = Uri.encodeComponent(state.uri.toString());
        return '/sign-in?returnTo=$returnTo';
      }
      if (signedIn && loc == '/sign-in') {
        final returnTo = state.uri.queryParameters['returnTo'];
        return (returnTo != null && returnTo.isNotEmpty)
            ? Uri.decodeComponent(returnTo)
            : '/today';
      }
      return null;
    },

    routes: [
      GoRoute(
        // Sign-in cannot know a dynamic id, and every real screen needs one.
        // This resolves it, and offers a genuine next step when there is
        // none yet — rather than a page with nothing on it.
        path: '/today',
        builder: (context, _) => HomeResolver(
          onOpen: (id) => context.go('/dynamics/$id/today'),
          onCreate: () => context.go('/start'),
        ),
      ),
      GoRoute(
        path: '/start',
        builder: (context, _) => CreateDynamicScreen(
          // Straight to the invite: a dynamic with nobody in it can do
          // nothing, so leaving the Creator on an empty Today was the
          // moment the product stopped making sense.
          onCreated: (id) => context.go('/dynamics/$id/invite'),
          onBack: () => context.go('/today'),
        ),
      ),
      GoRoute(
        // Journey B: what is expected of me today.
        path: '/dynamics/:id/today',
        builder: (context, s) => NavShell(
          current: NavTab.today,
          dynamicId: s.pathParameters['id'],
          child: _TodayHost(dynamicId: s.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/sign-in',
        builder: (_, s) => SignInScreen(returnTo: s.uri.queryParameters['returnTo']),
      ),
      GoRoute(
        // Opening this URL must NEVER join. Mail scanners and link previews
        // issue GETs; joining requires an explicit human action on the page.
        path: '/invite/:token',
        builder: (_, s) => InviteScreen(token: s.pathParameters['token']!),
      ),
      GoRoute(
        // What rhythm we are currently running.
        path: '/dynamics/:id',
        builder: (context, s) => NavShell(
          current: NavTab.dynamic,
          dynamicId: s.pathParameters['id'],
          child: DynamicScreen(
            dynamicId: s.pathParameters['id']!,
            onSeparate: () =>
                context.go('/dynamics/${s.pathParameters['id']}/separate'),
            onNotifications: () => context.push('/settings/notifications'),
            onInvite: () =>
                context.go('/dynamics/${s.pathParameters['id']}/invite'),
          ),
        ),
      ),
      GoRoute(
        // Leave or separate — always reachable (Notion 04 §4).
        path: '/dynamics/:id/separate',
        builder: (context, s) => SeparationScreen(
          dynamicId: s.pathParameters['id']!,
          partnerUserId: s.uri.queryParameters['partner'] ?? '',
          partnerName: s.uri.queryParameters['name'] ?? 'Your partner',
          // Return to a plain, unremarkable screen: a dramatic success page
          // would itself be evidence to anyone looking over a shoulder.
          onDone: () => context.go('/today'),
        ),
      ),
      GoRoute(
        // What recently happened between us.
        path: '/dynamics/:id/us',
        builder: (context, s) => NavShell(
          current: NavTab.us,
          dynamicId: s.pathParameters['id'],
          child: UsScreen(
            dynamicId: s.pathParameters['id']!,
            // Adjusting the rhythm happens where the rhythm lives, rather
            // than in a second editor that could drift from it.
            onAdjust: () => context.go('/dynamics/${s.pathParameters['id']}'),
            // Pause is the real command, not a navigation. Confirmed first,
            // because it stops the other person's week too.
            onPause: () => _confirmPause(context, ref, s.pathParameters['id']!),
          ),
        ),
      ),
      GoRoute(
        // Journey C: what needs this person's human response.
        path: '/dynamics/:id/attention',
        // Attention is NOT a tab: Today already means "what needs me today".
        // It is a surface Today leads into for the direction-giving side.
        builder: (context, s) => NavShell(
          current: NavTab.today,
          dynamicId: s.pathParameters['id'],
          child: AttentionScreen(
            dynamicId: s.pathParameters['id']!,
            onOpen: (occurrenceId) => context.go('/occurrences/$occurrenceId'),
            onBack: () => context.go('/dynamics/${s.pathParameters['id']}/today'),
          ),
        ),
      ),
      GoRoute(
        // The direction-giving half of the loop. Until this existed it could
        // not be started from the app at all.
        path: '/dynamics/:id/ask',
        builder: (context, s) => NewExpectationScreen(
          dynamicId: s.pathParameters['id']!,
          onCreated: () => context.go('/dynamics/${s.pathParameters['id']}/today'),
          onBack: () => context.go('/dynamics/${s.pathParameters['id']}/today'),
        ),
      ),
      GoRoute(
        // How a Creator brings the other person in. They cannot be handed a
        // link — they are the one who makes it.
        path: '/dynamics/:id/invite',
        builder: (context, s) => ShareInviteScreen(
          dynamicId: s.pathParameters['id']!,
          onDone: () => context.go('/dynamics/${s.pathParameters['id']}/today'),
          onBack: () => context.go('/dynamics/${s.pathParameters['id']}/today'),
        ),
      ),
      GoRoute(
        // The Starter Rhythm: built and tested, but until now not routed
        // from anywhere, so nobody could reach it.
        path: '/dynamics/:id/rhythm',
        builder: (context, s) => StarterRhythmScreen(
          dynamicId: s.pathParameters['id']!,
          assigneeUserId: s.uri.queryParameters['for'] ?? '',
          onStarted: () =>
              context.go('/dynamics/${s.pathParameters['id']}/today'),
        ),
      ),
      GoRoute(
        // Explore keeps its slot so the IA stays stable, but the full
        // library is out of Core Beta (Notion 01 §7) — this is an honest
        // placeholder, not a teaser for something we are not building.
        path: '/dynamics/:id/explore',
        builder: (_, s) => NavShell(
          current: NavTab.explore,
          dynamicId: s.pathParameters['id'],
          child: const ExploreScreen(),
        ),
      ),
      GoRoute(
        // A member's own notification settings — never a partner's to reach.
        path: '/settings/notifications',
        builder: (context, _) => QuietHoursScreen(onDone: () => context.pop()),
      ),
      GoRoute(
        // The magic token arrives in the FRAGMENT (#ml=…&flow=…) so it never
        // reaches the web server, access logs, or the Referer header.
        path: '/auth/callback',
        builder: (_, s) {
          final frag = Uri.splitQueryString(s.uri.fragment);
          return AuthCallbackScreen(
            token: frag['ml'] ?? s.uri.queryParameters['ml'] ?? '',
            flowId: frag['flow'] ?? s.uri.queryParameters['flow'] ?? '',
          );
        },
      ),
      GoRoute(
        // A push deep link lands here and re-resolves server state before
        // rendering — the payload is never trusted (Notion 04 §6).
        path: '/occurrences/:id',
        builder: (context, s) => OccurrenceScreen(
          occurrenceId: s.pathParameters['id']!,
          // A push deep link can land here with no history, so "back" must
          // resolve somewhere real rather than popping an empty stack.
          onBack: () => context.canPop() ? context.pop() : context.go('/today'),
        ),
      ),
    ],

    // No dead ends (Notion 02 §11): an unknown URL explains itself and offers
    // a way back rather than showing a raw error.
    errorBuilder: (_, s) => _NotFoundScreen(location: s.uri.toString()),
  );
});

class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen({required this.location});
  final String location;

  @override
  Widget build(BuildContext context) => TodayScreen(notice: 'That link no longer works.');
}

/// Today needs two facts the Today payload does not carry: whether anyone has
/// joined, and whether a rhythm exists. Both come from the dynamic itself, so
/// they are read here rather than guessed in the screen.
class _TodayHost extends ConsumerWidget {
  const _TodayHost({required this.dynamicId});

  final String dynamicId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(dynamicDetailProvider(dynamicId)).value;
    final joined = (detail?.members.length ?? 0) >= 2;

    return TodayScreen(
      dynamicId: dynamicId,
      onOpen: (occurrenceId) => context.go('/occurrences/$occurrenceId'),
      onOpenAttention: () => context.go('/dynamics/$dynamicId/attention'),
      onInvite: () => context.go('/dynamics/$dynamicId/invite'),
      onStartRhythm: () => context.go('/dynamics/$dynamicId/rhythm'),
      // Asking is only offered once there is someone to ask.
      onAsk: joined ? () => context.go('/dynamics/$dynamicId/ask') : null,
      onCheckIn: () => CheckInSheet.show(
        context,
        framing: 'How is today sitting with you?',
        onSubmit: ({mood, energy, need, note, required visibility}) async {
          await ref.read(checkInRepositoryProvider).create(
                dynamicId,
                mood: mood,
                energy: energy,
                need: need,
                note: note,
                visibility: visibility,
                idempotencyKey: UniqueKey().toString(),
              );
          if (context.mounted) Navigator.of(context).pop();
        },
      ),
      // PENDING_PARTNER is the server's word for "nobody has joined".
      waitingForPartner: detail?.state == 'PENDING_PARTNER' || !joined,
      hasRhythm: (detail?.structure.isNotEmpty) ?? true,
    );
  }
}

/// Pausing stops generating for BOTH people, so it is confirmed before it
/// runs. The sheet states what pausing does and what it does not do —
/// nothing is deleted, and coming back means no backlog (Notion 02 §6).
Future<void> _confirmPause(BuildContext context, Ref ref, String dynamicId) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: DsColors.canvas,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DsSheetHandle(),
          Text('Pause this dynamic?', style: DsType.h2),
          const SizedBox(height: DsSpacing.sm),
          Text(
            'Nothing new is scheduled while you are paused. '
            'Nothing is deleted, and there is nothing to catch up on '
            'when you come back.',
            style: DsType.body.copyWith(color: DsColors.muted),
          ),
          const SizedBox(height: DsSpacing.xxl),
          DsButton(
            label: 'Pause',
            onPressed: () async {
              await ref.read(dynamicRepositoryProvider).pause(
                    dynamicId,
                    idempotencyKey: UniqueKey().toString(),
                  );
              ref.invalidate(dynamicDetailProvider(dynamicId));
              if (sheetContext.mounted) Navigator.of(sheetContext).pop();
            },
          ),
          const SizedBox(height: DsSpacing.md),
          DsButton(
            label: 'Not now',
            outline: true,
            onPressed: () => Navigator.of(sheetContext).pop(),
          ),
        ],
      ),
    ),
  );
}
