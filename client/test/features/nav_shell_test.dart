import 'package:dsapp/app/nav_shell.dart';
import 'package:dsapp/design_system/tokens/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  Future<String> tapAndSee(WidgetTester tester, String label,
      {String? dynamicId = 'd1'}) async {
    var landed = '';
    final router = GoRouter(
      initialLocation: '/start',
      routes: [
        GoRoute(
          path: '/start',
          builder: (_, _) => NavShell(
            current: NavTab.today,
            dynamicId: dynamicId,
            child: const SizedBox.shrink(),
          ),
        ),
        GoRoute(
          path: '/:a/:b/:c',
          builder: (_, s) {
            landed = s.uri.toString();
            return const SizedBox.shrink();
          },
        ),
        GoRoute(
          path: '/:a/:b',
          builder: (_, s) {
            landed = s.uri.toString();
            return const SizedBox.shrink();
          },
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
    return landed;
  }

  setUp(() => TestWidgetsFlutterBinding.ensureInitialized());

  group('Bottom navigation', () {
    testWidgets('every Core Beta surface is reachable', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      expect(await tapAndSee(tester, 'Dynamic'), '/dynamics/d1');
      expect(await tapAndSee(tester, 'Explore'), '/dynamics/d1/explore');
      expect(await tapAndSee(tester, 'Us'), '/dynamics/d1/us');
    });

    testWidgets('the tabs are the canonical four, in order', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(MaterialApp(
        home: NavShell(
          current: NavTab.today,
          dynamicId: 'd1',
          child: const SizedBox.shrink(),
        ),
      ));
      await tester.pumpAndSettle();

      // Today · Dynamic · Explore · Us, fixed by Notion 02 §2 and V5.
      // Attention is NOT a tab: Today already means "what needs me today",
      // and promoting it would change the IA for an MVP convenience — then
      // force a rebuild when the Explore library lands.
      final labels = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data)
          .toList();
      expect(labels, ['Today', 'Dynamic', 'Explore', 'Us']);
      expect(find.text('Attention'), findsNothing);

      for (final banned in ['Points', 'Rewards', 'Proof', 'Rules']) {
        expect(find.text(banned), findsNothing);
      }
    });

    testWidgets('the active tab is marked, and only one is', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(MaterialApp(
        home: NavShell(
          current: NavTab.us,
          dynamicId: 'd1',
          child: const SizedBox.shrink(),
        ),
      ));
      await tester.pumpAndSettle();

      // The active marker is a 28x2 terracotta rule — scarce accent, never
      // a filled tab (DESIGN_SYSTEM §1).
      final marks = tester
          .widgetList<Container>(find.byType(Container))
          .where((c) => c.color == DsColors.accent)
          .length;
      expect(marks, 1, reason: 'exactly one tab may be marked active');

      final us = tester.widget<Text>(find.text('Us'));
      expect(us.style?.color, DsColors.surface);
    });

    testWidgets('before a dynamic exists the bar still renders',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(MaterialApp(
        home: NavShell(
          current: NavTab.today,
          dynamicId: null,
          child: const SizedBox.shrink(),
        ),
      ));
      await tester.pumpAndSettle();

      // A missing bar would read as a broken app; a dimmed tab reads as
      // "not yet".
      expect(find.text('Explore'), findsOneWidget);
      final t = tester.widget<Text>(find.text('Explore'));
      expect(t.style?.color, DsColors.muted);
    });
  });
}
