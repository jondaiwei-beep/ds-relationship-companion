import 'package:dsapp/app/providers.dart';
import 'package:dsapp/domain_client/repositories/today_repository.dart';
import 'package:dsapp/features/today/fixtures/today_fixtures.dart';
import 'package:dsapp/features/today/presentation/today_screen.dart';
import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// No state of SCR-01 may exceed the 390dp reference viewport.
///
/// Rendering shows that something is wrong; this says which widget and by how
/// much. It has caught six real overflows so far, three of which were first
/// misdiagnosed as a screenshot problem.
void main() {
  for (final s in TodayFixtureState.values) {
    testWidgets('$s fits 390dp', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            todayRepositoryProvider.overrideWithValue(
              FixtureTodayRepository(null, s) as TodayRepository,
            ),
          ],
          child: MaterialApp(
            theme: DsTheme.ritual(),
            home: const TodayScreen(dynamicId: 'd1'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final wide = <String>[];
      void walk(Element e) {
        final ro = e.renderObject;
        if (ro is RenderBox && ro.hasSize && ro.size.width > 390.5) {
          wide.add(
            '${e.widget.runtimeType} ${ro.size.width.toStringAsFixed(1)}',
          );
        }
        e.visitChildren(walk);
      }

      tester.allElements.first.visitChildren(walk);
      expect(wide, isEmpty, reason: '$s:\n${wide.join("\n")}');
    });
  }
}
