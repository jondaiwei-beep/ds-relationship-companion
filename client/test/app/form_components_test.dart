import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:dsapp/app/shell/ds_primary_button.dart';
import 'package:dsapp/app/shell/ds_text_field.dart';
import 'package:dsapp/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The entrance is where a person is least sure anything happened, so these
/// two controls carry more than their appearance: whether a request can be
/// sent twice, and whether a password can be typed at all.
void main() {
  /// [settle] is false while a spinner is on screen: it animates forever, so
  /// `pumpAndSettle` would never return. That is the harness, not the widget.
  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    bool settle = true,
  }) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        theme: DsTheme.ritual(),
        home: Scaffold(
          backgroundColor: DsColors.canvasRitual,
          body: Padding(
            padding: const EdgeInsets.all(DsSpacing.space4),
            child: child,
          ),
        ),
      ),
    );
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
    }
  }

  group('the primary action', () {
    testWidgets('does nothing while a request is in flight', (tester) async {
      var taps = 0;
      await pump(
        tester,
        DsPrimaryButton(label: 'Enter', busy: true, onPressed: () => taps++),
        settle: false,
      );

      await tester.tap(find.byType(DsPrimaryButton));
      await tester.pump();

      expect(
        taps,
        0,
        reason: 'a second tap during sign-in is the ordinary way to get two '
            'requests out of one intention',
      );
    });

    testWidgets('a screen reader hears that it is working', (tester) async {
      await pump(
        tester,
        DsPrimaryButton(label: 'Enter', busy: true, onPressed: () {}),
        settle: false,
      );

      expect(
        tester.getSemantics(find.byType(DsPrimaryButton)),
        matchesSemantics(
          label: 'Enter, working',
          isButton: true,
          hasEnabledState: true,
        ),
      );
    });

    testWidgets('unavailable means unavailable', (tester) async {
      await pump(
        tester,
        const DsPrimaryButton(label: 'Create account', onPressed: null),
      );

      expect(
        tester.getSemantics(find.byType(DsPrimaryButton)),
        matchesSemantics(
          label: 'Create account',
          isButton: true,
          hasEnabledState: true,
        ),
      );
    });

    testWidgets('works when it is meant to', (tester) async {
      var taps = 0;
      await pump(
        tester,
        DsPrimaryButton(label: 'Enter', onPressed: () => taps++),
      );

      await tester.tap(find.byType(DsPrimaryButton));
      await tester.pumpAndSettle();

      expect(taps, 1);
    });
  });

  group('a field', () {
    testWidgets('offers no reveal control unless it can be revealed',
        (tester) async {
      await pump(
        tester,
        DsTextField(label: 'Email', controller: TextEditingController()),
      );

      expect(
        find.text('Show'),
        findsNothing,
        reason: 'a control that does nothing is worse than no control',
      );
    });

    testWidgets('a password can be revealed and hidden again', (tester) async {
      var hidden = true;
      await pump(
        tester,
        StatefulBuilder(
          builder: (context, setState) => DsTextField(
            label: 'Password',
            controller: TextEditingController(),
            obscure: hidden,
            onToggleObscure: () => setState(() => hidden = !hidden),
          ),
        ),
      );

      expect(find.text('Show'), findsOneWidget);
      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();
      expect(find.text('Hide'), findsOneWidget);
    });

    testWidgets('an error is stated in words, never colour alone',
        (tester) async {
      await pump(
        tester,
        DsTextField(
          label: 'Email',
          controller: TextEditingController(),
          error: 'Enter an email address.',
        ),
      );

      expect(find.text('Enter an email address.'), findsOneWidget);
    });

    testWidgets('the value cannot change while a request is in flight',
        (tester) async {
      final controller = TextEditingController(text: 'a@b.com');
      await pump(
        tester,
        DsTextField(
          label: 'Email',
          controller: controller,
          enabled: false,
        ),
      );

      await tester.enterText(find.byType(TextField), 'changed@b.com');
      await tester.pumpAndSettle();

      expect(
        controller.text,
        'a@b.com',
        reason: 'editing under a submitted request means the person is no '
            'longer looking at what they sent',
      );
    });
  });
}
