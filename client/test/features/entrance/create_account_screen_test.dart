import 'package:dsapp/app/providers.dart';
import 'package:dsapp/l10n/app_localizations.dart';
import 'package:dsapp/domain_client/repositories/auth_repository.dart';
import 'package:dsapp/features/entrance/presentation/create_account_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// A repository that records what reached it and answers as told.
class _FakeAuth implements AuthRepository {
  final calls = <({String email, String password, bool ageConfirmed})>[];

  @override
  Future<AuthResult> register({
    required String email,
    required String password,
    required bool ageConfirmed,
  }) async {
    calls.add((email: email, password: password, ageConfirmed: ageConfirmed));
    return AuthResult(
      accessToken: 'a',
      accessTokenExpiresIn: const Duration(minutes: 15),
    );
  }

  @override
  Object noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} is not used here');
}

void main() {
  late _FakeAuth auth;
  late ProviderContainer container;

  setUp(() {
    auth = _FakeAuth();
    container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(auth)],
    );
    addTearDown(container.dispose);
  });

  Future<void> pump(WidgetTester tester, {VoidCallback? onCreated}) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: L.localizationsDelegates,
          supportedLocales: L.supportedLocales,
          home: CreateAccountScreen(
            onCreated: onCreated ?? () {},
            onSignIn: () {},
            onBack: () {},
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> fill(WidgetTester tester) async {
    await tester.enterText(find.byType(TextField).first, 'a@b.co');
    await tester.enterText(
      find.byType(TextField).last,
      'correct horse battery staple',
    );
    await tester.pump();
  }

  group('age confirmation is given, never assumed', () {
    testWidgets('it starts unchecked', (tester) async {
      await pump(tester);

      // Consent to a legal statement is never pre-given. A pre-ticked box is
      // the app confirming someone's age on their behalf.
      expect(find.byIcon(Icons.check), findsNothing);
    });

    testWidgets('submitting without it sends nothing and says why', (
      tester,
    ) async {
      await pump(tester);
      await fill(tester);

      await tester.tap(find.text('Create account'));
      await tester.pump();

      expect(
        auth.calls,
        isEmpty,
        reason: 'a password must not leave the device before the person has '
            'confirmed they may create an account at all',
      );
      expect(
        find.textContaining('18 or older'),
        findsNWidgets(2), // the checkbox label, and the error beneath it
      );
    });

    testWidgets('the button is pressable while unconfirmed', (tester) async {
      await pump(tester);
      await fill(tester);
      await tester.tap(find.text('Create account'));
      await tester.pump();

      // Not disabled: pressing it explains what is missing. A silently dead
      // control is unreachable for a screen-reader user and tells a sighted
      // one nothing either.
      expect(find.textContaining('Confirm that you are 18'), findsOneWidget);
    });

    testWidgets('confirmed, the request carries it', (tester) async {
      var created = 0;
      await pump(tester, onCreated: () => created++);
      await fill(tester);
      await tester.tap(find.textContaining('I confirm that I am 18'));
      await tester.pump();
      await tester.tap(find.text('Create account'));
      await tester.pump();

      expect(auth.calls, hasLength(1));
      expect(auth.calls.single.ageConfirmed, isTrue);
      expect(auth.calls.single.email, 'a@b.co');
      expect(created, 1);

      // Adopting a session schedules a refresh ahead of expiry — right in
      // production, a pending timer here. Let it fire and be discarded.
      await tester.binding.delayed(const Duration(minutes: 20));
    });
  });

  testWidgets('the password rule is stated, not discovered by refusal', (
    tester,
  ) async {
    await pump(tester);

    // The server's real bound. A field that says "at least 8" makes the
    // person find the truth by being rejected.
    expect(find.text('10–256 characters'), findsOneWidget);
  });

  testWidgets('it discloses no more than the entrance does', (tester) async {
    await pump(tester);

    for (final leak in ['relationship', 'partner', 'dynamic', 'D/s']) {
      expect(
        find.textContaining(leak, skipOffstage: false),
        findsNothing,
        reason: 'creating an account grants no membership — and says so by '
            'not naming one',
      );
    }
  });

  testWidgets('the email is trimmed before it is sent', (tester) async {
    await pump(tester);
    await tester.enterText(find.byType(TextField).first, '  a@b.co ');
    await tester.enterText(find.byType(TextField).last, 'a password here');
    await tester.tap(find.textContaining('I confirm that I am 18'));
    await tester.pump();
    await tester.tap(find.text('Create account'));
    await tester.pump();

    // A trailing space from a keyboard autocomplete is not a different
    // account, and the server would answer 400 rather than explain that.
    expect(auth.calls.single.email, 'a@b.co');
    await tester.binding.delayed(const Duration(minutes: 20));
  });
}
