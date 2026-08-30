import 'package:dio/dio.dart';
import 'package:dsapp/app/providers.dart';
import 'package:dsapp/domain_client/repositories/auth_repository.dart';
import 'package:dsapp/features/entrance/presentation/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuth implements AuthRepository {
  _FakeAuth({this.signInThrows});

  final DioException? signInThrows;
  final signInCalls = <({String email, String password})>[];
  final linkCalls = <String>[];

  @override
  Future<AuthResult> signInWithPassword({
    required String email,
    required String password,
  }) async {
    signInCalls.add((email: email, password: password));
    if (signInThrows case final e?) throw e;
    return AuthResult(
      accessToken: 'a',
      accessTokenExpiresIn: const Duration(minutes: 15),
    );
  }

  @override
  Future<void> requestMagicLink({
    required String email,
    required Object flow,
    String? inviteToken,
  }) async {
    linkCalls.add(email);
  }

  @override
  Object noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} is not used here');
}

DioException _refused() => DioException(
      requestOptions: RequestOptions(path: '/v1/auth/sign-in'),
      response: Response(
        requestOptions: RequestOptions(path: '/v1/auth/sign-in'),
        statusCode: 401,
        data: {'code': 'INVALID_CREDENTIALS'},
      ),
      type: DioExceptionType.badResponse,
    );

void main() {
  Future<_FakeAuth> pump(
    WidgetTester tester, {
    DioException? signInThrows,
    SignInNotice? notice,
    VoidCallback? onSignedIn,
  }) async {
    final auth = _FakeAuth(signInThrows: signInThrows);
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(auth)],
    );
    addTearDown(container.dispose);
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: SignInScreen(
            onSignedIn: onSignedIn ?? () {},
            onCreateAccount: () {},
            onBack: () {},
            notice: notice,
          ),
        ),
      ),
    );
    await tester.pump();
    return auth;
  }

  group('the email link is a peer, not a failure', () {
    testWidgets('it is never called "forgot password"', (tester) async {
      await pump(tester);

      // There is no password-reset endpoint in this product. The link is a
      // way in — and the only way in for accounts made before password
      // sign-in existed (decision D8).
      expect(find.textContaining('Forgot'), findsNothing);
      expect(find.text('Use an email sign-in link'), findsOneWidget);
    });

    testWidgets('choosing it removes the password field entirely', (
      tester,
    ) async {
      await pump(tester);
      await tester.tap(find.text('Use an email sign-in link'));
      await tester.pump();

      expect(find.text('PASSWORD'), findsNothing);
      expect(find.text('Send sign-in link'), findsOneWidget);
      expect(find.text('Use password instead'), findsOneWidget);
    });
  });

  group('an unknown address is indistinguishable from a known one', () {
    testWidgets('the confirmation is conditional, always', (tester) async {
      final auth = await pump(tester);
      await tester.tap(find.text('Use an email sign-in link'));
      await tester.pump();
      await tester.enterText(find.byType(TextField).first, 'nobody@nowhere.co');
      await tester.tap(find.text('Send sign-in link'));
      await tester.pumpAndSettle();

      expect(auth.linkCalls, ['nobody@nowhere.co']);
      // "If this email can be used to sign in" — never "we sent it". Saying
      // an address has an account lets anyone test who is a member, and on
      // this product membership is a disclosure about someone's private life.
      expect(find.textContaining('If this email can be used'), findsOneWidget);
      expect(find.textContaining('No account'), findsNothing);
    });
  });

  group('a refusal never says which half was wrong', () {
    testWidgets('a rejected pair gets one message, not a field error', (
      tester,
    ) async {
      await pump(tester, signInThrows: _refused());
      await tester.enterText(find.byType(TextField).first, 'a@b.co');
      await tester.enterText(find.byType(TextField).last, 'wrong');
      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();

      // Naming the email as the problem confirms the account exists.
      expect(find.textContaining('No account with that email'), findsNothing);
      expect(find.textContaining('wrong password'), findsNothing);
      expect(
        find.textContaining("We couldn't sign you in with those details"),
        findsOneWidget,
      );
    });
  });

  group('the password never outlives the attempt', () {
    testWidgets('a refusal clears it, and keeps the email', (tester) async {
      await pump(tester, signInThrows: _refused());
      await tester.enterText(find.byType(TextField).first, 'a@b.co');
      await tester.enterText(find.byType(TextField).last, 'wrong');
      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();

      // `entrance-state-family.md`: keep the email, clear the password.
      // Retyping an email is friction; a password left on screen is a
      // credential sitting on a device someone else may be holding.
      final fields = tester.widgetList<TextField>(find.byType(TextField));
      expect(fields.first.controller!.text, 'a@b.co');
      expect(fields.last.controller!.text, isEmpty);
    });

    testWidgets('leaving the password flow clears it', (tester) async {
      await pump(tester);
      await tester.enterText(find.byType(TextField).last, 'a real password');
      await tester.tap(find.text('Use an email sign-in link'));
      await tester.pump();
      await tester.tap(find.text('Use password instead'));
      await tester.pump();

      // Otherwise a round trip through link mode resurrects it.
      final fields = tester.widgetList<TextField>(find.byType(TextField));
      expect(fields.last.controller!.text, isEmpty);
    });
  });

  testWidgets('an expired session asks rather than accuses', (tester) async {
    await pump(tester, notice: SignInNotice.authorizationLost);

    expect(find.text('Please sign in to continue.'), findsOneWidget);
    // And it does not also say "Welcome back": that would be the screen
    // saying two different things about why the person is here.
    expect(find.text('Welcome back'), findsNothing);
  });

  testWidgets('a signed-in result is reported once', (tester) async {
    var signedIn = 0;
    final auth = await pump(tester, onSignedIn: () => signedIn++);
    await tester.enterText(find.byType(TextField).first, ' a@b.co ');
    await tester.enterText(find.byType(TextField).last, 'a real password');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(auth.signInCalls.single.email, 'a@b.co');
    expect(signedIn, 1);
    // Adopting a session schedules a refresh; let it fire and be discarded.
    await tester.binding.delayed(const Duration(minutes: 20));
  });

  testWidgets('every mode fits 390x844', (tester) async {
    await pump(tester);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Use an email sign-in link'));
    await tester.pump();
    expect(tester.takeException(), isNull);

    await tester.enterText(find.byType(TextField).first, 'a@b.co');
    await tester.tap(find.text('Send sign-in link'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
