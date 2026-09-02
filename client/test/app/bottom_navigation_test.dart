import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:dsapp/app/shell/bottom_navigation.dart';
import 'package:dsapp/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The navigation set is a product decision, not a layout choice, so it is
/// asserted rather than left to whoever edits the file next.
void main() {
  Future<void> pump(
    WidgetTester tester, {
    required NavSurface current,
    void Function(NavSurface)? onSelect,
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
          body: Column(
            children: [
              const Spacer(),
              DsBottomNavigation(current: current, onSelect: onSelect),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('is exactly five surfaces, in the product order', (tester) async {
    await pump(tester, current: NavSurface.today);

    final l = L.of(
      tester.element(find.byType(DsBottomNavigation)),
    );
    expect(
      NavSurface.values.map((s) => s.label(l)),
      // Points sits second, beside the Dynamic it belongs to, rather than
      // last: all three competitors give it a bottom tab and it is a
      // daily-use surface, not an afterthought.
      ['Today', 'Dynamic', 'Points', 'Explore', 'Us'],
    );
    for (final surface in NavSurface.values) {
      expect(find.text(surface.label(l)), findsOneWidget);
    }
  });

  testWidgets('Attention is not a tab — it is reached from Today',
      (tester) async {
    await pump(tester, current: NavSurface.today);

    expect(find.text('Attention'), findsNothing);
  });

  testWidgets('renders but does not respond when destinations do not exist',
      (tester) async {
    await pump(tester, current: NavSurface.today);

    await tester.tap(find.text('Explore'));
    await tester.pumpAndSettle();
    // Nothing to assert beyond not throwing: an inert bar is the point.
    expect(find.text('Explore'), findsOneWidget);
  });

  testWidgets('reports which surface was chosen', (tester) async {
    final chosen = <NavSurface>[];
    await pump(
      tester,
      current: NavSurface.today,
      onSelect: chosen.add,
    );

    await tester.tap(find.text('Us'));
    await tester.pumpAndSettle();

    expect(chosen, [NavSurface.us]);
  });

  testWidgets('the current surface is not re-selectable', (tester) async {
    final chosen = <NavSurface>[];
    await pump(
      tester,
      current: NavSurface.today,
      onSelect: chosen.add,
    );

    await tester.tap(find.text('Today'));
    await tester.pumpAndSettle();

    expect(
      chosen,
      isEmpty,
      reason: 'rebuilding the screen someone is already reading loses their '
          'scroll position for nothing',
    );
  });

  testWidgets('the current surface is announced as selected', (tester) async {
    await pump(tester, current: NavSurface.us);

    // Which tab is active is carried by colour and icon tone alone, so
    // without this a screen reader gives no way to tell where you are.
    expect(
      tester.getSemantics(find.text('Us')),
      matchesSemantics(
        label: 'Us',
        hasSelectedState: true,
        isSelected: true,
        isButton: true,
      ),
    );
    expect(
      tester.getSemantics(find.text('Today')),
      matchesSemantics(
        label: 'Today',
        hasSelectedState: true,
        isButton: true,
      ),
    );
  });
}
