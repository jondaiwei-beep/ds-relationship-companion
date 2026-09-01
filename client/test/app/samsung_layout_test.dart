import 'package:dsapp/app/providers.dart';
import 'package:dsapp/app/shell/bottom_navigation.dart';
import 'package:dsapp/domain_client/repositories/auth_repository.dart';
import 'package:dsapp/features/entrance/presentation/create_account_screen.dart';
import 'package:dsapp/features/entrance/presentation/entrance_screen.dart';
import 'package:dsapp/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _NoAuth implements AuthRepository {
  @override
  Object noSuchMethod(Invocation i) => throw UnimplementedError();
}

/// A Samsung in gesture navigation, which is where these were found.
///
/// The design is drawn at 390x844 with no system inset. A real phone is
/// shorter and reserves the bottom for its own controls, and a screen that
/// ignores that puts its buttons underneath them.
void main() {
  const size = Size(360, 780);
  const inset = 48.0;

  Future<void> pump(WidgetTester t, Widget w) async {
    await t.binding.setSurfaceSize(size);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(_NoAuth())],
        child: MediaQuery(
          data: const MediaQueryData(
            padding: EdgeInsets.only(top: 32, bottom: inset),
          ),
          child: MaterialApp(
            localizationsDelegates: L.localizationsDelegates,
            supportedLocales: L.supportedLocales,
            home: w,
          ),
        ),
      ),
    );
    await t.pump();
  }

  testWidgets('the bottom navigation sits above the gesture bar', (t) async {
    await pump(
      t,
      const Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(child: SizedBox()),
              DsBottomNavigation(current: NavSurface.today),
            ],
          ),
        ),
      ),
    );

    // Reported from a real device: the labels rendered underneath Samsung's
    // own back and home controls. The bar's fixed height swallowed the inset
    // instead of growing by it.
    final safe = size.height - inset;
    for (final label in ['Today', 'Dynamic', 'Explore', 'Us']) {
      expect(
        t.getBottomLeft(find.text(label)).dy,
        lessThanOrEqualTo(safe),
        reason: '"$label" is underneath the system gesture bar',
      );
    }
  });

  testWidgets('a short screen does not hide the form behind ornament', (
    t,
  ) async {
    await pump(
      t,
      CreateAccountScreen(onCreated: () {}, onSignIn: () {}, onBack: () {}),
    );

    // Both fields reachable without scrolling: someone who opened this came
    // to make an account, and the decoration gives way before the form does.
    expect(find.text('EMAIL'), findsOneWidget);
    expect(find.text('CREATE PASSWORD'), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('the entrance still fits its own composition', (t) async {
    await pump(t, EntranceScreen(onContinue: () {}, onSignIn: () {}));
    expect(t.takeException(), isNull);
    expect(find.text('Continue'), findsOneWidget);
  });
}
