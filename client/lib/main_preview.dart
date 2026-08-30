// Android preview build for SCR-01.
//
// The product entry point does not exist yet: 34 of 35 screens are still
// gated, and there is no navigation to build. This runs the one screen that
// is `ready_for_build` against fixed data, with a switcher so every approved
// state can be seen on a real device.
//
// It is replaced by the real shell when the vertical slice opens.
import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'app/providers.dart';
import 'domain_client/repositories/today_repository.dart';
import 'features/today/fixtures/today_fixtures.dart';
import 'features/today/presentation/today_screen.dart';

void main() {
  tz.initializeTimeZones();
  runApp(const _Preview());
}

class _Preview extends StatefulWidget {
  const _Preview();

  @override
  State<_Preview> createState() => _PreviewState();
}

class _PreviewState extends State<_Preview> {
  TodayFixtureState _state = TodayFixtureState.standard;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: DsTheme.ritual(),
      home: ProviderScope(
        // Keyed so switching state rebuilds the provider rather than serving
        // the previous result.
        key: ValueKey(_state),
        overrides: [
          todayRepositoryProvider.overrideWithValue(
            FixtureTodayRepository(null, _state) as TodayRepository,
          ),
        ],
        child: Stack(
          children: [
            const TodayScreen(dynamicId: 'preview'),
            _StateSwitcher(
              state: _state,
              onChange: (s) => setState(() => _state = s),
            ),
          ],
        ),
      ),
    );
  }
}

/// A preview-only control. Deliberately plain: it must not be mistaken for
/// part of the product, and it must not borrow the design system's marks.
class _StateSwitcher extends StatelessWidget {
  const _StateSwitcher({required this.state, required this.onChange});

  final TodayFixtureState state;
  final ValueChanged<TodayFixtureState> onChange;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 0,
      bottom: MediaQuery.paddingOf(context).bottom + 96,
      child: Material(
        color: DsColors.surfaceRitualRaised,
        borderRadius: const BorderRadius.horizontal(
          left: Radius.circular(DsRadii.control),
        ),
        child: PopupMenuButton<TodayFixtureState>(
          initialValue: state,
          onSelected: onChange,
          color: DsColors.surfaceRitualRaised,
          tooltip: 'Preview state',
          itemBuilder: (context) => [
            for (final s in TodayFixtureState.values)
              PopupMenuItem(
                value: s,
                child: Text(
                  s.name,
                  style: DsTextStyles.bodySecondary.copyWith(
                    color: s == state
                        ? DsColors.relationshipAcknowledgement
                        : DsColors.textOnRitualSecondary,
                  ),
                ),
              ),
          ],
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DsSpacing.space4,
              vertical: DsSpacing.space3,
            ),
            child: Text(
              state.name,
              style: DsTextStyles.bodySecondary.copyWith(
                color: DsColors.textOnRitualMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
