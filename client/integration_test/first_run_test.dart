import 'package:dsapp/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// The app, on a real device runtime, against the real server.
///
/// Every bug the owner found on their phone was invisible to the widget tests:
/// a placeholder dynamic id the server rejected, a nav bar that swallowed
/// taps, an Android timezone lookup that was `return null`, a magic-link flow
/// held in memory, a deep link dropped on the floor. None of them lived in a
/// screen, and none of them could fail a test that never started the app.
///
/// This starts the app. `main()` runs — the same startup that primes the
/// device timezone and the launch link — and the flow talks to production.
///
///   flutter test integration_test/first_run_test.dart -d `<simulator id>` \
///     --dart-define=API_BASE_URL=https://ds-api.beforeweplay.com \
///     --dart-define=WEB_BASE_URL=https://ds-staging.beforeweplay.com
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('a new person can register and reach a screen they can act on', (
    tester,
  ) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // The entrance.
    expect(find.text('Continue'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Registration. A fresh address every run: the server rightly refuses a
    // second account on the same one.
    final email = 'sim-${DateTime.now().millisecondsSinceEpoch}@example.com';
    final fields = find.byType(TextField);
    expect(
      fields,
      findsNWidgets(2),
      reason: 'the create-account screen asks for an address and a password',
    );

    await tester.enterText(fields.at(0), email);
    await tester.pumpAndSettle();
    await tester.enterText(fields.at(1), 'Str0ng!Passw0rd');
    await tester.pumpAndSettle();

    // Age confirmation. The server refuses a registration without it — which
    // is how a probe against production first failed — and the control is the
    // whole row, not a Material Checkbox.
    final confirm = find.textContaining('18');
    expect(
      confirm,
      findsWidgets,
      reason: 'registration cannot be sent without confirming age',
    );
    await tester.tap(confirm.first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Create account').last);
    // A real round trip to production.
    await tester.pumpAndSettle(const Duration(seconds: 15));

    // Whatever screen this is, it must not be the dead end the owner hit.
    for (final deadEnd in [
      'could not be loaded',
      'build gate',
      'route is reserved',
      'Timezone unavailable',
      'Not open yet',
    ]) {
      expect(
        find.textContaining(deadEnd),
        findsNothing,
        reason: '"$deadEnd" is where a real device landed after registering',
      );
    }

    // And it must offer something to do.
    final actionable = find.byWidgetPredicate(
      (w) =>
          (w is ButtonStyleButton && w.onPressed != null) ||
          (w is InkWell && w.onTap != null),
    );
    expect(
      actionable,
      findsWidgets,
      reason: 'a first-run screen with nothing tappable is a dead end',
    );
  });
}
