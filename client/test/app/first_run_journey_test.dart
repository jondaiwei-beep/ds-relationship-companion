import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:dsapp/app/providers.dart';
import 'package:dsapp/app/router.dart';
import 'package:dsapp/domain_client/api_client.dart';
import 'package:dsapp/domain_client/models/dynamic_summary.dart';
import 'package:dsapp/domain_client/repositories/auth_repository.dart';
import 'package:dsapp/domain_client/repositories/dynamic_repository.dart';
import 'package:dsapp/domain_client/repositories/today_repository.dart';
import 'package:dsapp/features/today/fixtures/today_fixtures.dart';
import 'package:dsapp/features/activation/presentation/activation_wizard.dart';
import 'package:dsapp/features/activation/presentation/timezone_unavailable.dart';
import 'package:dsapp/platform/session/refresh_store.dart';
import 'package:dsapp/platform/session/session_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// The journey a real person takes on their first run, through the real
/// router.
///
/// Every screen in this app had passing tests while the journey between them
/// was broken twice over: `/today` passed a placeholder id the server
/// rejected, and `/start` rendered a dead end because the Android timezone
/// lookup was a stub returning null. Both shipped. Neither was catchable by
/// testing screens one at a time, because neither was in a screen.
void main() {
  late ProviderContainer container;
  late _FakeDynamics dynamics;

  ProviderContainer build({List<DynamicSummary> mine = const []}) {
    dynamics = _FakeDynamics(mine);
    return ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(_FakeAuth()),
        refreshStoreProvider.overrideWithValue(_MemoryStore()),
        apiClientProvider.overrideWithValue(ApiClient(baseUrl: 'http://test')),
        autoRefreshProvider.overrideWithValue(false),
        dynamicRepositoryProvider.overrideWithValue(dynamics),
        todayRepositoryProvider.overrideWithValue(
          FixtureTodayRepository(todayFixture()) as TodayRepository,
        ),
      ],
    );
  }

  Future<GoRouter> pump(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    addTearDown(container.dispose);
    await container.read(sessionProvider.notifier).adopt(
          AuthResult(
            accessToken: 'a',
            accessTokenExpiresIn: const Duration(minutes: 15),
          ),
        );
    final router = container.read(routerProvider);
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

  testWidgets('a just-registered account lands somewhere it can act', (
    tester,
  ) async {
    container = build();

    final router = await pump(tester);

    // Not on an error, and not on a placeholder about the build.
    expect(where(router), startsWith(Routes.start));
    for (final deadEnd in [
      'could not be loaded',
      'build gate',
      'route is reserved',
      'Not implemented',
    ]) {
      expect(
        find.textContaining(deadEnd),
        findsNothing,
        reason: '"$deadEnd" is a dead end, and this is a person\'s first '
            'minute in the product',
      );
    }
  });

  testWidgets('the first screen offers something to do', (tester) async {
    container = build();

    await pump(tester);

    // Whichever of the two it is — the wizard when the device reports a zone,
    // the recovery screen when it does not — there is a way forward. A screen
    // with no enabled control is the shape of the bug that shipped.
    final actionable = find.byWidgetPredicate(
      (w) =>
          (w is ButtonStyleButton && w.onPressed != null) ||
          (w is InkWell && w.onTap != null) ||
          (w is GestureDetector && w.onTap != null),
    );
    expect(
      actionable,
      findsWidgets,
      reason: 'a first-run screen with nothing tappable is a dead end',
    );
  });

  testWidgets('an account with a dynamic goes straight to its day', (
    tester,
  ) async {
    container = build(
      mine: [
        DynamicSummary(
          dynamicId: 'd-7',
          state: 'ACTIVE',
          roleContext: 'CREATOR',
        ),
      ],
    );

    final router = await pump(tester);

    expect(where(router), '/dynamics/d-7/today');
  });

  group('when the device will not report its zone', () {
    testWidgets('activation stays recoverable rather than dead-ending', (
      tester,
    ) async {
      container = build();
      final router = await pump(tester);
      await tester.pumpAndSettle();

      // In a test the platform channel is absent, so the zone is null — which
      // is exactly the Android release build's behaviour when the lookup was
      // a stub. It must not be a wall.
      if (find.byType(TimezoneUnavailable).evaluate().isEmpty) {
        expect(find.byType(ActivationWizard), findsOneWidget);
        return;
      }

      expect(find.textContaining('could not read'), findsOneWidget);
      // Two ways forward, and no exit that loops. Leaving for Today would
      // resolve to no Dynamic and come straight back here.
      expect(find.text('Try again'), findsOneWidget);
      expect(find.text('Choose it myself'), findsOneWidget);
      expect(where(router), startsWith(Routes.start));
    });

    testWidgets('a chosen zone carries into the wizard', (tester) async {
      container = build();
      final router = await pump(tester);
      if (find.byType(TimezoneUnavailable).evaluate().isEmpty) return;

      await tester.tap(find.text('Choose it myself'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('China'));
      await tester.pumpAndSettle();

      expect(where(router), contains('tz=Asia%2FShanghai'));
      expect(find.byType(ActivationWizard), findsOneWidget);
      // The zone reaches the wizard as the one the person picked, not a
      // default standing in for it.
      final wizard = tester.widget<ActivationWizard>(
        find.byType(ActivationWizard),
      );
      expect(wizard.timezone, 'Asia/Shanghai');
    });
  });
}

class _FakeDynamics implements DynamicRepository {
  _FakeDynamics(this._mine);

  final List<DynamicSummary> _mine;

  @override
  Future<List<DynamicSummary>> mine() async => _mine;

  @override
  Object noSuchMethod(Invocation i) =>
      throw UnimplementedError('${i.memberName}');
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
