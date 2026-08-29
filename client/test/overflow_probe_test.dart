import 'package:dsapp/app/providers.dart';
import 'package:dsapp/domain_client/repositories/today_repository.dart';
import 'package:dsapp/features/today/presentation/today_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'support/today_fixtures.dart';
import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Today fits the 390dp reference viewport', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          todayRepositoryProvider.overrideWithValue(
            FixtureTodayRepository() as TodayRepository,
          ),
        ],
        child: MaterialApp(
          theme: DsTheme.ritual(),
          home: const TodayScreen(dynamicId: 'd1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Any RenderBox wider than the viewport is a horizontal overflow.
    final wide = <String>[];
    // Also report any RenderFlex that actually overflowed.

    void walk(Element e) {
      final ro = e.renderObject;
      if (ro is RenderBox && ro.hasSize && ro.size.width > 390.5) {
        final w = e.widget;
        final label = w is Text ? '"${w.data}"' : w.runtimeType.toString();
        wide.add('$label  ${ro.size.width.toStringAsFixed(1)}dp');
      }
      e.visitChildren(walk);
    }

    tester.allElements.first.visitChildren(walk);
    expect(wide, isEmpty, reason: 'wider than viewport:\n${wide.join('\n')}');
  });
}
