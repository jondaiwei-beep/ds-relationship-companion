import 'package:dsapp/app/providers.dart';
import 'package:dsapp/domain_client/models/invite_view.dart';
import 'package:dsapp/domain_client/repositories/invite_repository.dart';
import 'package:dsapp/features/activation/presentation/invite_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _Repo extends Mock implements InviteRepository {}

void main() {
  late _Repo repo;
  setUp(() => repo = _Repo());

  Future<void> pump(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    when(() => repo.resolve(any())).thenAnswer((_) async => const InviteView(
          state: InviteState.pending,
          inviteId: 'i1',
          dynamicId: 'd1',
          intendedRoleContext: 'PARTNER',
          inviterDisplayName: 'Alex',
        ));
    await tester.pumpWidget(ProviderScope(
      overrides: [inviteRepositoryProvider.overrideWithValue(repo)],
      child: const MaterialApp(home: InviteScreen(token: 'iv1.demo')),
    ));
    await tester.pumpAndSettle();
  }

  String allText(WidgetTester tester) => tester
      .widgetList<Text>(find.byType(Text))
      .map((t) => t.data ?? '')
      .join(' | ');

  group('The invited partner never leaves the invitation', () {
    testWidgets('signing in happens on the invitation itself', (tester) async {
      await pump(tester);

      // Routing an invited partner to the generic sign-in screen showed them
      // a headline about building a dynamic — not what they were invited to,
      // by someone they trust, about something intimate.
      expect(find.text('CONTINUE PRIVATELY'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Send me a sign-in link'), findsOneWidget);
      expect(allText(tester).contains('Build a dynamic'), isFalse);
    });

    testWidgets('it says plainly that signing in is not joining',
        (tester) async {
      await pump(tester);

      // Notion 04 §2: the token locates an invite; it never grants access.
      // Authenticating and joining must stay two separate human decisions.
      expect(allText(tester),
          contains('Signing in does not join this space'));
    });

    testWidgets('the trust answers still come before the threshold',
        (tester) async {
      await pump(tester);

      // Who invited me, what is shared, what stays mine, can I leave — all
      // answered above the point where anything is asked of the visitor.
      final rights = tester.getTopLeft(find.text('WHAT JOINING MEANS')).dy;
      final threshold = tester.getTopLeft(find.text('CONTINUE PRIVATELY')).dy;
      expect(rights < threshold, isTrue);
      expect(allText(tester),
          contains('Joining is not agreement to any future expectation.'));
    });

    testWidgets('opening the invitation never joins by itself', (tester) async {
      await pump(tester);
      // Mail scanners and link previews issue GETs.
      verifyNever(() => repo.join(any(),
          idempotencyKey: any(named: 'idempotencyKey')));
    });
  });
}
