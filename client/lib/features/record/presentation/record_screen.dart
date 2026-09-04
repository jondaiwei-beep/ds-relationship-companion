import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/shell/bottom_navigation.dart';
import '../../../app/shell/ds_refreshable.dart';
import '../../../app/shell/ds_skeleton.dart';
import '../../../app/shell/page_hero.dart';
import '../../../domain_client/models/record.dart';
import '../../../domain_client/models/task.dart';
import '../../../domain_client/models/today_view.dart';
import '../../../l10n/app_localizations.dart';
import '../../dynamic/application/dynamic_providers.dart';
import '../../today/application/today_providers.dart';
import '../../today/presentation/today_format.dart';
import '../../today/presentation/today_screen.dart';
import '../../today/presentation/widgets/recovery_scaffold.dart';
import '../../today/presentation/widgets/section_label.dart';
import '../../today/presentation/widgets/secondary_button.dart';
import '../../today/presentation/widgets/today_header.dart';
import '../../today/presentation/widgets/today_layout.dart';
import '../../today/presentation/widgets/today_notice.dart';
import '../application/calendar_math.dart';
import '../application/record_providers.dart';
import '../../today/presentation/widgets/word_button.dart';
import 'export_sheet.dart';
import 'widgets/facts_table.dart';
import 'widgets/month_grid.dart';

/// Tab 3 · 记录 (product/02-surfaces.md; redesign-2026-09 §7): the day as the
/// anchor, one line on it and a way in; the month as navigation, one cell a
/// day; the week's and month's counts beneath; export at the very bottom.
///
/// Streak is not shown (D-31). Days together only once there are two people.
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
    final locale = Localizations.localeOf(context).toString();
    final month = _visible(view);
    final thisMonth = YearMonth.ofIsoDay(view.day);
    final week = weekAround(view.day);
    // Read alongside, never awaited: the record must not wait on its frame.
    final alone = TodayNotice.isAlone(ref.watch(dynamicDetailProvider(id)).value);
    final summary = ref.watch(recordSummaryProvider(id)).value;
    final cells = ref.watch(monthCellsProvider((id, month.wire)));
    // Today's own cell lives in its own month, whichever month is being looked at.
    final todayCells = ref.watch(monthCellsProvider((id, thisMonth.wire)));
    final weekFacts = ref.watch(factsProvider((id, week.from, week.to)));
    final monthFacts = ref.watch(factsProvider((id, month.firstIsoDay, month.lastIsoDay)));
    final measureTasks = ref.watch(measureTasksProvider(id));
    final canGoForward = compareIsoDays(month.next.firstIsoDay, view.day) <= 0;
    final quiet = DsTextStyles.bodySecondary.copyWith(color: DsColors.textOnRitualSecondary);

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        TodayHeader(partnerName: view.partnerDisplayName),
        PageHero(
          eyebrow: l.recordHeroEyebrow(TodayFormat.weekday(view.day, locale)),
          hero: TodayFormat.dayHero(view.day, locale),
          heroKey: const ValueKey('record-hero'),
          // Days together are a fact about two people; alone there is none.
          support: alone || summary == null ? null : l.recordTogether(summary.daysTogether),
        ),
        const SizedBox(height: DsSpacing.space6),
        Padding(
          padding: todayInset,
          // Expected-of-whom? Alone there is nobody, so the day is not counted.
          child: alone
              ? Text(l.todayStartsWhenJoined, key: const ValueKey('record-today-line'), style: quiet)
              : todayCells.when(
                  skipLoadingOnReload: true,
                  skipLoadingOnRefresh: true,
                  loading: () => const DsSkeletonBar(width: 160, height: 16),
                  error: (_, _) => Text(l.recordTodayNothing, style: quiet),
                  data: (list) =>
                      Text(_todayLine(list, view.day, l), key: const ValueKey('record-today-line'), style: quiet),
                ),
        ),
        Padding(
          padding: todayInset,
          child: Align(
            alignment: Alignment.centerLeft,
            child: WordButton(
              key: const ValueKey('open-today'),
              label: l.recordOpenDay(TodayFormat.dayHero(view.day, locale)),
              quiet: true,
              onTap: () => (widget.onOpenDay ?? (_) {})(view.day),
            ),
          ),
        ),
        const SizedBox(height: DsSpacing.space8),
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
        // Facts and export are about a shared record; alone there is none yet.
        if (!alone) ...[
          const SizedBox(height: DsSpacing.space10),
          SectionLabel(l.recordFactsTitle),
          FactsTable(week: weekFacts.value, month: monthFacts.value),
          ..._measureSection(measureTasks.value ?? const [], l),
          const SizedBox(height: DsSpacing.space10),
          Padding(
            padding: todayInset,
            child: Align(
              alignment: Alignment.centerLeft,
              child: WordButton(
                key: const ValueKey('export-record'),
                label: l.recordExport,
                quiet: true,
                onTap: () => showExportSheet(context, ref, dynamicId: id, today: view.day),
              ),
            ),
          ),
        ],
        const SizedBox(height: DsSpacing.space10),
      ],
    );
  }

  /// One line on today from what the month already carries: how many were
  /// expected, and how many of those the D has answered. `undisposed` counts
  /// deliveries (and misses) still waiting on the D, so the D's answers are
  /// everything the s has closed less those.
  String _todayLine(List<MonthCell> cells, String day, L l) {
    final c = cells.where((c) => c.day == day).firstOrNull;
    if (c == null || c.due == 0) return l.recordTodayNothing;
    final closed = c.delivered + c.flagged + c.missed;
    final answered = (closed - c.undisposed).clamp(0, c.due);
    return l.recordTodayLine(c.due, answered);
  }

  /// The measure tasks, each a way into its curve. Nothing when there are none.
  List<Widget> _measureSection(List<TaskView> tasks, L l) {
    if (tasks.isEmpty) return const [];
    return [
      const SizedBox(height: DsSpacing.space10),
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
