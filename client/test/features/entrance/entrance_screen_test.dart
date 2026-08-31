import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:dsapp/features/entrance/presentation/widgets/trust_footer.dart';
import 'package:dsapp/features/entrance/presentation/entrance_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The invariants SCR-04 must hold. These are product rules in executable
/// form, not styling preferences.
void main() {
  Future<void> pump(
    WidgetTester tester, {
    EntranceNotice? notice,
    bool busy = false,
    VoidCallback? onContinue,
    VoidCallback? onSignIn,
  }) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: EntranceScreen(
          onContinue: onContinue ?? () {},
          onSignIn: onSignIn ?? () {},
          notice: notice,
          busy: busy,
        ),
      ),
    );
    // Not `pumpAndSettle`: the busy state carries a CircularProgressIndicator,
    // which never stops animating, so settling would time out rather than
    // report anything about the screen.
    await tester.pump();
  }

  group('the entrance discloses nothing', () {
    testWidgets('it never names the product category', (tester) async {
      await pump(tester);

      // REQ-TRUST-001. This screen can be over someone's shoulder on a train,
      // and it is the one surface a person cannot choose not to show.
      for (final leak in [
        'relationship', 'partner', 'dynamic', 'submissive', 'dominant', 'D/s',
      ]) {
        expect(
          find.textContaining(leak, findRichText: true, skipOffstage: false),
          findsNothing,
          reason: '"$leak" names what this product is to anyone looking',
        );
      }
    });

    testWidgets('the footer states facts, never a privacy promise', (
      tester,
    ) async {
      await pump(tester);

      // An earlier draft said "Your space stays between you." The product
      // cannot speak for the device, the browser, or anyone nearby, so it
      // says only what is verifiably true (decision D8).
      expect(find.textContaining('For adults 18+'), findsOneWidget);
      expect(find.textContaining('stays between you'), findsNothing);
    });
  });

  group('recovery lands here, and never accuses', () {
    testWidgets('an ordinary signed-out open says nothing about it', (
      tester,
    ) async {
      await pump(tester);

      // Being signed out is the common case, not an event. An app that
      // explains your own sign-out back to you is talking about the wrong
      // thing.
      expect(find.textContaining('session'), findsNothing);
      expect(find.textContaining('offline'), findsNothing);
    });

    testWidgets('an ended session is stated without blame', (tester) async {
      await pump(tester, notice: EntranceNotice.sessionEnded);

      expect(find.textContaining('Your session ended'), findsOneWidget);
      // Still the entrance, still openable — a recovery state is not a wall.
      expect(find.text('Continue'), findsOneWidget);
      expect(find.text('I already have an account'), findsOneWidget);
    });

    testWidgets('only a real failure is coloured as one', (tester) async {
      for (final notice in EntranceNotice.values) {
        expect(
          notice.isFailure,
          notice == EntranceNotice.unreachable,
          reason: '${notice.name}: offline and an ended session are facts '
              'about the world, not mistakes anyone made',
        );
      }
    });
  });

  group('both doors stay reachable', () {
    testWidgets('continue and sign in each report their own tap', (
      tester,
    ) async {
      var continued = 0;
      var signedIn = 0;
      await pump(
        tester,
        onContinue: () => continued++,
        onSignIn: () => signedIn++,
      );

      await tester.tap(find.text('Continue'));
      await tester.tap(find.text('I already have an account'));
      await tester.pump();

      expect(continued, 1);
      expect(signedIn, 1);
    });

    testWidgets('while working, neither door accepts a second tap', (
      tester,
    ) async {
      var continued = 0;
      var signedIn = 0;
      await pump(
        tester,
        busy: true,
        onContinue: () => continued++,
        onSignIn: () => signedIn++,
      );

      await tester.tap(find.text('Opening'), warnIfMissed: false);
      await tester.tap(
        find.text('I already have an account'),
        warnIfMissed: false,
      );
      await tester.pump();

      // The entrance is where a person is least sure anything happened, so a
      // second tap must not start a second registration.
      expect(continued, 0);
      expect(signedIn, 0);
    });
  });

  testWidgets('every state fits 390x844 without overflow', (tester) async {
    for (final notice in [null, ...EntranceNotice.values]) {
      await pump(tester, notice: notice);
      expect(
        tester.takeException(),
        isNull,
        reason: 'notice ${notice?.name ?? "none"} overflowed the viewport',
      );
    }
  });

  group('the whole entrance is visible without scrolling', () {
    // The fixed spacings come from a design render at a fixed canvas height.
    // Measured against a real viewport they totalled 975dp, so the legal
    // footer sat 101dp below the fold on an iPhone 17 and 131dp below it on a
    // 390x844 phone — with no cue that anything was there. Nothing overflowed
    // and no test failed, because the page scrolls. It was found by looking at
    // a simulator.
    for (final size in [
      const Size(360, 740),
      const Size(390, 844),
      const Size(402, 874), // iPhone 17
      const Size(430, 932),
    ]) {
      testWidgets('at ${size.width.toInt()}x${size.height.toInt()}', (
        tester,
      ) async {
        await tester.binding.setSurfaceSize(size);
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(
          MaterialApp(
            theme: DsTheme.ritual(),
            home: EntranceScreen(onContinue: () {}, onSignIn: () {}),
          ),
        );
        await tester.pumpAndSettle();

        final footer = tester.getRect(find.byType(TrustFooter));
        expect(
          footer.bottom,
          lessThanOrEqualTo(size.height),
          reason: 'the legal footer is below the fold',
        );
        // And the primary action, which matters more.
        expect(
          tester.getRect(find.text('Continue')).bottom,
          lessThanOrEqualTo(size.height),
        );
      });
    }
  });

}
