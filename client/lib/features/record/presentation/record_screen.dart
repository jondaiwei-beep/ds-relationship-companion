import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/shell/bottom_navigation.dart';
import '../../../app/shell/ds_refreshable.dart';
import '../../../app/shell/ds_skeleton.dart';
import '../../../domain_client/models/task.dart';
import '../../../domain_client/models/today_view.dart';
import '../../../l10n/app_localizations.dart';
import '../../today/application/today_providers.dart';
import '../../today/presentation/today_screen.dart';
import '../../today/presentation/widgets/recovery_scaffold.dart';
import '../../today/presentation/widgets/section_label.dart';
import '../../today/presentation/widgets/secondary_button.dart';
import '../../today/presentation/widgets/today_header.dart';
import '../../today/presentation/widgets/today_layout.dart';
import '../application/calendar_math.dart';
import '../application/record_providers.dart';
import '../../today/presentation/widgets/word_button.dart';
import 'export_sheet.dart';
import 'widgets/facts_table.dart';
import 'widgets/month_grid.dart';

/// Tab 3 · 记录 (product/02-surfaces.md): the month, one cell a day; the two
/// numbers of D-27; and the week's and month's counts beneath.
///
/// "Today" is the relationship day the server names in `TodayView.day`, in
/// the Dynamic's zone and boundary — never the device clock (invariant 7).
class RecordScreen extends ConsumerStatefulWidget {
  const RecordScreen({
    super.key,
    required this.dynamicId,
    this.onSelectTab,
    this.onOpenDay,
    this.onSignIn,
    this.onOpenSeries,
  });

  final String dynamicId;
  final void Function(NavSurface surface)? onSelectTab;
  final void Function(String isoDay)? onOpenDay;
  final VoidCallback? onSignIn;

  /// Opens the curve of a `kind=measure` task: `(taskId, taskTitle)`.
  final void Function(String taskId, String taskTitle)? onOpenSeries;

  @override
  ConsumerState<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends ConsumerState<RecordScreen> {
  /// Null until a month has been chosen; the current one is shown meanwhile.
  YearMonth? _month;

  YearMonth _visible(TodayView view) => _month ?? YearMonth.ofIsoDay(view.day);

  void _step(TodayView view, int direction) {
    final current = _visible(view);
    final next = direction > 0 ? current.next : current.previous;
    // Nothing has happened in a month that has not started.
    if (direction > 0 && compareIsoDays(next.firstIsoDay, view.day) > 0) return;
    setState(() => _month = next);
  }

  Future<void> _refresh(TodayView? view) async {
    final id = widget.dynamicId;
    final futures = <Future<void>>[
      ref.refresh(todayProvider(id).future),
      ref.refresh(recordSummaryProvider(id).future),
    ];
    if (view != null) {
      final month = _visible(view);
      final week = weekAround(view.day);
      futures
        ..add(ref.refresh(monthCellsProvider((id, month.wire)).future))
        ..add(ref.refresh(factsProvider((id, week.from, week.to)).future))
        ..add(ref.refresh(factsProvider((id, month.firstIsoDay, month.lastIsoDay)).future));
    }
    await Future.wait(futures);
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final today = ref.watch(todayProvider(widget.dynamicId));
    void reload() => ref.invalidate(todayProvider(widget.dynamicId));

    return Scaffold(
      backgroundColor: DsColors.canvasRitual,
      body: DsRitualSurface(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: DsRefreshable(
                  onRefresh: () => _refresh(today.value),
                  child: today.when(
                    skipLoadingOnReload: true,
                    skipLoadingOnRefresh: true,
                    loading: () => const TodayLoading(),
                    error: (error, _) => switch (classifyFailure(error)) {
                      TodayFailure.authorizationLost => RecoveryScaffold(
                          context_: l.recoveryConfirmingContext,
                          children: [
                            const SizedBox(height: DsSpacing.space8),
                            RecoveryMessage(l.recoverySessionRestore, prominent: true),
                            const SizedBox(height: DsSpacing.space6),
                            Padding(
                              padding: todayInset,
                              child: SecondaryButton(
                                label: l.recoverySignInAgain,
                                onTap: widget.onSignIn ?? () {},
                                filled: true,
                              ),
                            ),
                          ],
                        ),
                      _ => RecoveryScaffold(
                          context_: l.recoveryNotConfirmed,
                          children: [
                            const SizedBox(height: DsSpacing.space8),
                            RecoveryMessage(l.recordCouldNotLoad, prominent: true),
                            const SizedBox(height: DsSpacing.space6),
                            Padding(
                              padding: todayInset,
                              child: SecondaryButton(label: l.recoveryTryAgain, onTap: reload),
                            ),
                          ],
                        ),
                    },
                    data: (view) => _body(view, l),
                  ),
                ),
              ),
              DsBottomNavigation(current: NavSurface.record, onSelect: widget.onSelectTab),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body(TodayView view, L l) {
    final id = widget.dynamicId;
    final month = _visible(view);
    final week = weekAround(view.day);
    final summary = ref.watch(recordSummaryProvider(id));
    final cells = ref.watch(monthCellsProvider((id, month.wire)));
    final weekFacts = ref.watch(factsProvider((id, week.from, week.to)));
    final monthFacts = ref.watch(factsProvider((id, month.firstIsoDay, month.lastIsoDay)));
    final measureTasks = ref.watch(measureTasksProvider(id));
    final canGoForward = compareIsoDays(month.next.firstIsoDay, view.day) <= 0;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        TodayHeader(title: l.navRecord, partnerName: view.partnerDisplayName),
        Padding(
          padding: todayInset,
          child: Row(
            children: [
              WordButton(
                key: const ValueKey('export-record'),
                label: l.recordExport,
                onTap: () => showExportSheet(context, ref, dynamicId: id, today: view.day),
              ),
            ],
          ),
        ),
        const SizedBox(height: DsSpacing.space2),
        Padding(
          padding: todayInset,
          child: summary.when(
            skipLoadingOnReload: true,
            skipLoadingOnRefresh: true,
            loading: () => const DsSkeletonBar(width: 160, height: 16),
            error: (_, _) => const SizedBox(height: 16),
            data: (s) => Text(
              l.recordTogether(s.daysTogether, s.currentStreak),
              style: DsTextStyles.bodySecondary.copyWith(color: DsColors.textOnRitualSecondary),
            ),
          ),
        ),
        const SizedBox(height: DsSpacing.space6),
        MonthNav(
          month: month,
          onPrevious: () => _step(view, -1),
          onNext: canGoForward ? () => _step(view, 1) : null,
        ),
        const SizedBox(height: DsSpacing.space3),
        MonthGrid(
          month: month,
          cells: cells.value ?? const [],
          today: view.day,
          onOpenDay: widget.onOpenDay ?? (_) {},
          onSwipe: (d) => _step(view, d),
        ),
        const SizedBox(height: DsSpacing.space8),
        SectionLabel(l.recordFactsTitle),
        FactsTable(week: weekFacts.value, month: monthFacts.value),
        ..._measureSection(measureTasks.value ?? const [], l),
        const SizedBox(height: DsSpacing.space10),
      ],
    );
  }

  /// The measure tasks, each a way into its curve. Nothing when there are none.
  List<Widget> _measureSection(List<TaskView> tasks, L l) {
    if (tasks.isEmpty) return const [];
    return [
      const SizedBox(height: DsSpacing.space8),
      SectionLabel(l.recordSeriesSection),
      for (final t in tasks)
        InkWell(
          key: ValueKey('measure-${t.id}'),
          onTap: widget.onOpenSeries == null ? null : () => widget.onOpenSeries!(t.id, t.title),
          child: Padding(
            padding: todayInset.add(const EdgeInsets.symmetric(vertical: DsSpacing.space3)),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    t.title,
                    style: DsTextStyles.bodyPrimary.copyWith(color: DsColors.textOnRitualPrimary),
                  ),
                ),
                Text(
                  t.unit == null || t.unit!.isEmpty ? l.recordSeriesAction : '${t.unit} · ${l.recordSeriesAction}',
                  style: DsTextStyles.bodySecondary.copyWith(color: DsColors.textOnRitualMuted),
                ),
              ],
            ),
          ),
        ),
    ];
  }
}
