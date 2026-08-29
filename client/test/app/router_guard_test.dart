import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:dsapp/app/not_built_yet.dart';
import 'package:dsapp/app/providers.dart';
import 'package:dsapp/app/router.dart';
import 'package:dsapp/domain_client/api_client.dart';
import 'package:dsapp/domain_client/models/today_view.dart';
import 'package:dsapp/domain_client/repositories/auth_repository.dart';
import 'package:dsapp/domain_client/repositories/today_repository.dart';
import 'package:dsapp/features/today/fixtures/today_fixtures.dart';
import 'package:go_router/go_router.dart';
import 'package:dsapp/features/today/presentation/today_screen.dart';
import 'package:dsapp/platform/session/refresh_store.dart';
import 'package:dsapp/platform/session/session_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// The guard is the only thing standing between an unauthenticated visitor
/// and relationship content. These tests state what it must do; each was
/// checked by breaking the guard and confirming the test caught it.
void main() {
  late _FakeAuth auth;
  late _MemoryStore store;
  late ProviderContainer container;

  setUp(() {
    auth = _FakeAuth();
    store = _MemoryStore();
    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(auth),
        refreshStoreProvider.overrideWithValue(store),
        apiClientProvider.overrideWithValue(ApiClient(baseUrl: 'http://test')),
        // These tests are about the guard, not the clock. The refresh
        // schedule is covered directly in session_test.dart.
        autoRefreshProvider.overrideWithValue(false),
        todayRepositoryProvider.overrideWithValue(
          FixtureTodayRepository(_view()) as TodayRepository,
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  /// Pumps the real app shell so the guard runs exactly as it does in
  /// production — including `initialLocation` and the refresh listenable.
  Future<GoRouterHarness> pump(WidgetTester tester, {String? at}) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final router = container.read(routerProvider);
    if (at != null) router.go(at);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          theme: DsTheme.ritual(),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
    return GoRouterHarness(router);
  }

  group('before the session is known', () {
    testWidgets('the door is held — nothing protected is built', (tester) async {
      // `restore()` has not run, so the session is SessionUnknown.
      final h = await pump(tester, at: '/dynamics/abc/today');

      expect(h.location, startsWith(Routes.holding));
      expect(
        find.byType(TodayScreen),
        findsNothing,
        reason: 'a protected screen that builds also fetches. Observed in a '
            'browser: Today issued an unauthenticated read for relationship '
            'data while the guard had decided nothing yet',
      );
    });

    testWidgets('the destination is not lost while waiting', (tester) async {
      final h = await pump(tester, at: '/dynamics/abc/today');

      expect(
        Uri.parse(h.location).queryParameters['returnTo'],
        '/dynamics/abc/today',
      );
    });

    testWidgets('an invitation still opens — it is public at every stage',
        (tester) async {
      final h = await pump(tester, at: '/invite/tok123');

      expect(
        h.location,
        '/invite/tok123',
        reason: 'holding the door must not close it on the one route that '
            'exists for someone who has no session yet',
      );
    });

    testWidgets('resolving to signed out moves on to the entrance',
        (tester) async {
      final h = await pump(tester, at: '/dynamics/abc/today');
      expect(h.location, startsWith(Routes.holding));

      await container.read(sessionProvider.notifier).restore();
      await tester.pumpAndSettle();

      expect(h.location, startsWith(Routes.signIn));
      expect(
        Uri.parse(h.location).queryParameters['returnTo'],
        '/dynamics/abc/today',
        reason: 'the destination must survive both hops, not just the first',
      );
    });

    testWidgets('resolving to signed in delivers the original destination',
        (tester) async {
      final h = await pump(tester, at: '/dynamics/abc/today');
      expect(h.location, startsWith(Routes.holding));

      await container.read(sessionProvider.notifier).adopt(
            AuthResult(
              accessToken: 'a',
              accessTokenExpiresIn: const Duration(minutes: 15),
            ),
          );
      await tester.pumpAndSettle();

      expect(h.location, '/dynamics/abc/today');
      expect(find.byType(TodayScreen), findsOneWidget);
    });
  });

  group('signed out', () {
    testWidgets('a protected route sends the visitor to the entrance',
        (tester) async {
      await container.read(sessionProvider.notifier).restore();

      final h = await pump(tester, at: Routes.today);

      expect(h.location, startsWith(Routes.signIn));
      expect(find.byType(TodayScreen), findsNothing);
    });

    testWidgets('the destination survives in the URL', (tester) async {
      await container.read(sessionProvider.notifier).restore();

      final h = await pump(tester, at: '/dynamics/abc/today');

      expect(
        Uri.parse(h.location).queryParameters['returnTo'],
        '/dynamics/abc/today',
        reason: 'it must survive a Web refresh and a magic-link callback '
            'opened in a new tab',
      );
    });

    testWidgets('an invitation is readable without signing in', (tester) async {
      await container.read(sessionProvider.notifier).restore();

      final h = await pump(tester, at: '/invite/tok123');

      expect(
        h.location,
        '/invite/tok123',
        reason: 'an invited person must see WHAT they are joining first; '
            'opening the link is not joining',
      );
      expect(find.byType(NotBuiltYet), findsOneWidget);
    });
  });

  group('signed in', () {
    Future<void> signIn() => container.read(sessionProvider.notifier).adopt(
          AuthResult(
            accessToken: 'a',
            accessTokenExpiresIn: const Duration(minutes: 15),
          ),
        );

    testWidgets('protected content renders', (tester) async {
      await signIn();

      final h = await pump(tester, at: Routes.today);

      expect(h.location, Routes.today);
      expect(find.byType(TodayScreen), findsOneWidget);
    });

    testWidgets('the entrance is not a place to linger', (tester) async {
      await signIn();

      final h = await pump(tester, at: Routes.signIn);

      expect(h.location, Routes.today);
    });

    testWidgets('a returnTo is honoured after signing in', (tester) async {
      await signIn();

      final h = await pump(
        tester,
        at: '${Routes.signIn}?returnTo=${Uri.encodeComponent('/dynamics/x/today')}',
      );

      expect(h.location, '/dynamics/x/today');
    });
  });

  group('losing authorization mid-session', () {
    testWidgets('removes protected content from the screen', (tester) async {
      await container.read(sessionProvider.notifier).adopt(
            AuthResult(
              accessToken: 'a',
              accessTokenExpiresIn: const Duration(minutes: 15),
            ),
          );
      final h = await pump(tester, at: Routes.today);
      expect(find.byType(TodayScreen), findsOneWidget);

      await container.read(sessionProvider.notifier).signOut();
      await tester.pumpAndSettle();

      expect(
        find.byType(TodayScreen),
        findsNothing,
        reason: 'the guard must react to the session ending, not only to '
            'navigation — otherwise content stays on a borrowed device',
      );
      expect(h.location, startsWith(Routes.signIn));
    });
  });

  group('returnTo is untrusted input', () {
    // It survives a Web reload, so it is whatever is in the address bar.
    Future<String> land(WidgetTester tester, String returnTo) async {
      await container.read(sessionProvider.notifier).adopt(
            AuthResult(
              accessToken: 'a',
              accessTokenExpiresIn: const Duration(minutes: 15),
            ),
          );
      final h = await pump(
        tester,
        at: '${Routes.signIn}?returnTo=${Uri.encodeComponent(returnTo)}',
      );
      return h.location;
    }

    testWidgets('an absolute URL does not become an open redirect',
        (tester) async {
      expect(await land(tester, 'https://example.com/phish'), Routes.today);
    });

    testWidgets('a protocol-relative URL is refused too', (tester) async {
      expect(await land(tester, '//example.com/phish'), Routes.today);
    });

    testWidgets('bouncing back to the entrance would loop', (tester) async {
      expect(await land(tester, Routes.signIn), Routes.today);
    });

    testWidgets('bouncing back to the waiting room would loop',
        (tester) async {
      expect(await land(tester, Routes.holding), Routes.today);
    });

    testWidgets('an encoded path survives one decode, not two', (tester) async {
      // `Uri.queryParameters` already decodes. Decoding again would turn
      // `%252F` into a path separator that was never in the destination.
      expect(
        await land(tester, '/dynamics/a%2Fb/today'),
        '/dynamics/a%2Fb/today',
      );
    });
  });

  group('the public list', () {
    test('is exactly the entrance, the callback and an invitation', () {
      expect(Routes.isPublic('/sign-in'), isTrue);
      expect(Routes.isPublic('/auth/callback'), isTrue);
      expect(Routes.isPublic('/invite/anything'), isTrue);

      expect(Routes.isPublic('/today'), isFalse);
      expect(Routes.isPublic('/dynamics/1/today'), isFalse);
      expect(Routes.isPublic('/start'), isFalse);
      expect(
        Routes.isPublic(Routes.holding),
        isFalse,
        reason: 'holding is a waiting room, not an exemption',
      );
      expect(
        Routes.isPublic('/invite'),
        isFalse,
        reason: 'the invitation list, if one ever exists, is not public — '
            'only a specific token is',
      );
    });
  });
}

/// Reads the location the router actually settled on.
///
/// Asks the router rather than a widget context: `GoRouterState.of` only
/// resolves beneath a route builder, and half of what these tests assert is
/// where the guard sent someone *instead of* building the route they asked
/// for.
class GoRouterHarness {
  GoRouterHarness(this.router);

  final GoRouter router;

  String get location =>
      router.routerDelegate.currentConfiguration.uri.toString();
}

TodayView _view() => todayFixture();

class _FakeAuth implements AuthRepository {
  @override
  Future<AuthResult> refresh({String? refreshToken, String? csrfToken}) async =>
      throw StateError('no session');

  @override
  Future<void> logout() async {}

  @override
  noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} not used by this test');
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
