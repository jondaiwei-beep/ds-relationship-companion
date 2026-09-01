import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:dsapp/app/providers.dart';
import 'package:dsapp/app/router.dart';
import 'package:dsapp/app/shell/bottom_navigation.dart';
import 'package:dsapp/domain_client/api_client.dart';
import 'package:dsapp/domain_client/repositories/auth_repository.dart';
import 'package:dsapp/domain_client/models/dynamic_view.dart';
import 'package:dsapp/domain_client/models/explore_view.dart';
import 'package:dsapp/domain_client/repositories/explore_repository.dart';
import 'package:dsapp/domain_client/models/us_view.dart';
import 'package:dsapp/domain_client/repositories/dynamic_repository.dart';
import 'package:dsapp/domain_client/repositories/today_repository.dart';
import 'package:dsapp/features/today/fixtures/today_fixtures.dart';
import 'package:dsapp/features/today/presentation/today_screen.dart';
import 'package:dsapp/platform/session/refresh_store.dart';
import 'package:dsapp/platform/session/session_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// The bar used to ignore every tap, on the theory that silence beat a
/// placeholder. On a real device three dead tabs out of four read as a broken
/// app, which is exactly what was reported. These tests hold the bar to
/// responding.
void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(_FakeAuth()),
        refreshStoreProvider.overrideWithValue(_MemoryStore()),
        apiClientProvider.overrideWithValue(ApiClient(baseUrl: 'http://test')),
        autoRefreshProvider.overrideWithValue(false),
        todayRepositoryProvider.overrideWithValue(
          FixtureTodayRepository(todayFixture()) as TodayRepository,
        ),
        dynamicRepositoryProvider.overrideWithValue(_StubDynamic()),
        exploreRepositoryProvider.overrideWithValue(_StubExplore()),
      ],
    );
    addTearDown(container.dispose);
  });

  Future<GoRouter> pump(WidgetTester tester, String at) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await container.read(sessionProvider.notifier).adopt(
          AuthResult(
            accessToken: 'a',
            accessTokenExpiresIn: const Duration(minutes: 15),
          ),
        );
    final router = container.read(routerProvider);
    router.go(at);
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
    return router;
  }

  String where(GoRouter r) =>
      r.routerDelegate.currentConfiguration.uri.toString();

  testWidgets('every tab responds', (tester) async {
    final router = await pump(tester, '/dynamics/d-1/today');
    expect(find.byType(TodayScreen), findsOneWidget);

    // Every surface is built now, so the invariant is simply that a tap
    // lands where it says it will. `ComingSurface` is gone: it existed to
    // make an unbuilt tab respond honestly, and there are no unbuilt tabs.
    for (final (label, path) in const [
      ('Dynamic', '/dynamics/d-1/dynamic'),
      ('Explore', '/dynamics/d-1/explore'),
      ('Us', '/dynamics/d-1/us'),
    ]) {
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
      expect(where(router), path, reason: '$label must go somewhere');
    }
  });

  testWidgets('the way back to Today is always one tap', (tester) async {
    final router = await pump(tester, '/dynamics/d-1/explore');

    // The bar is on every surface. Without it, tapping Explore would be a
    // one-way trip on a device with gesture navigation.
    await tester.tap(find.text('Today'));
    await tester.pumpAndSettle();

    expect(where(router), '/dynamics/d-1/today');
    expect(find.byType(TodayScreen), findsOneWidget);
  });

  testWidgets('the tab you are on is not re-selectable', (tester) async {
    final router = await pump(tester, '/dynamics/d-1/explore');

    // Re-entering the route you are reading rebuilds it and loses the scroll
    // position, for a tap that meant "I am already here".
    // Scoped to the bar: the surfaces themselves now contain InkWells too,
    // so an unscoped finder matches the tab and the page's own controls.
    final tab = tester.widget<InkWell>(
      find.descendant(
        of: find.descendant(
          of: find.byType(DsBottomNavigation),
          matching: find.ancestor(
            of: find.text('Explore'),
            matching: find.byType(Expanded),
          ),
        ),
        matching: find.byType(InkWell),
      ),
    );
    expect(tab.onTap, isNull);
    expect(where(router), '/dynamics/d-1/explore');
  });

  testWidgets('the bar clears a gesture inset instead of sitting under it', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: DsTheme.ritual(),
        home: const MediaQuery(
          // A Samsung's navigation bar, which is where the labels landed.
          data: MediaQueryData(padding: EdgeInsets.only(bottom: 48)),
          child: Scaffold(
            body: Column(
              children: [
                Spacer(),
                DsBottomNavigation(current: NavSurface.today),
              ],
            ),
          ),
        ),
      ),
    );

    final bar = tester.getRect(find.byType(DsBottomNavigation));
    final label = tester.getRect(find.text('Today'));
    expect(bar.height, DsControlSizes.bottomNavigation + 48);
    expect(
      label.bottom,
      lessThanOrEqualTo(bar.bottom - 48),
      reason: 'a label inside the system inset is under the back button',
    );
  });
}

/// Dynamic and Us both read the server as soon as they build. Without a stub
/// the real client reaches a dead URL, fails, and Riverpod schedules a retry
/// timer that outlives the test — which surfaces as "pending timers", not as
/// a routing failure. These tests are about navigation, so the reads simply
/// have to resolve.
class _StubExplore implements ExploreRepository {
  @override
  Future<ExploreLibraryView> library() async => const ExploreLibraryView();

  @override
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError();
}

class _StubDynamic implements DynamicRepository {
  @override
  Future<DynamicDetail> detail(String id) async => const DynamicDetail(
    dynamicId: 'd-1',
    state: 'ACTIVE',
    desiredOutcome: 'SERVICE',
    structureLevel: 'STEADY',
    referenceTimezone: 'Asia/Shanghai',
  );

  @override
  Future<UsView> us(String id) async => const UsView();

  @override
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError();
}

class _FakeAuth implements AuthRepository {
  @override
  Future<AuthResult> refresh({String? refreshToken, String? csrfToken}) async =>
      throw StateError('no session');

  @override
  Future<void> logout() async {}

  @override
  noSuchMethod(Invocation i) => throw UnimplementedError('${i.memberName}');
}

class _MemoryStore implements RefreshStore {
  String? _token;

  @override
  Future<String?> read() async => _token;

  @override
  Future<bool> write(String token) async {
    _token = token;
    return true;
  }

  @override
  Future<void> clear() async => _token = null;
}
