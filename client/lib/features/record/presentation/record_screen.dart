import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';

import '../../../app/shell/bottom_navigation.dart';
import '../../../l10n/app_localizations.dart';
import '../../today/presentation/widgets/today_header.dart';
import '../../today/presentation/widgets/today_layout.dart';

/// The Record tab (product/02-surfaces.md §3): calendar, one day's timeline,
/// comments by both members. Built in Phase 2 of product/06-build-order.md;
/// until then this says so instead of pretending.
class RecordScreen extends StatelessWidget {
  const RecordScreen({
    super.key,
    required this.dynamicId,
    this.onSelectTab,
  });

  final String dynamicId;
  final void Function(NavSurface surface)? onSelectTab;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Scaffold(
      backgroundColor: DsColors.canvasRitual,
      body: DsRitualSurface(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    TodayHeader(title: l.navRecord, context_: l.recordComingSoon),
                    Padding(
                      padding: todayInset,
                      child: Text(
                        l.recordComingSoonBody,
                        style: DsTextStyles.bodySecondary.copyWith(
                          color: DsColors.textOnRitualMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              DsBottomNavigation(
                current: NavSurface.record,
                onSelect: onSelectTab ?? (_) {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
