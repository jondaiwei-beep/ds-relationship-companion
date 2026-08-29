// QA harness for SCR-01. Renders one state at the reference viewport with the
// bundled fonts, so it can be captured and compared with its approved design
// without a running backend.
//
//   flutter build web --target lib/qa_today_main.dart \
//     --dart-define=state=offline
//
// Accepts: standard · empty · solo · loading · offline · authorizationLost ·
// unavailable. Nothing in the product imports this file.
import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/providers.dart';
import 'features/today/fixtures/today_fixtures.dart';
import 'features/today/presentation/today_screen.dart';

void main() {
  const requested = String.fromEnvironment('state', defaultValue: 'standard');
  final state = TodayFixtureState.values.firstWhere(
    (s) => s.name == requested,
    orElse: () => throw ArgumentError.value(
      requested,
      'state',
      'unknown; expected one of '
          '${TodayFixtureState.values.map((s) => s.name).join(', ')}',
    ),
  );

  // Announced so a capture can be traced back to the state it claims to show.
  debugPrint('SCR-01 QA harness rendering: ${state.name}');

  runApp(
    ProviderScope(
      overrides: [
        todayRepositoryProvider.overrideWithValue(
          FixtureTodayRepository(null, state),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: DsTheme.ritual(),
        home: const TodayScreen(dynamicId: 'qa'),
      ),
    ),
  );
}
