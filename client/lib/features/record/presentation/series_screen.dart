import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/shell/ds_glyph.dart';
import '../../../app/shell/ds_skeleton.dart';
import '../../../domain_client/models/record.dart';
import '../../../domain_client/models/today_view.dart';
import '../../../l10n/app_localizations.dart';
import '../../today/application/today_providers.dart';
import '../../today/presentation/today_format.dart';
import '../../today/presentation/widgets/quiet_line.dart';
import '../../today/presentation/widgets/secondary_button.dart';
import '../../today/presentation/widgets/today_layout.dart';
import '../application/calendar_math.dart';
import '../application/record_providers.dart';
import 'widgets/series_chart.dart';

/// One `kind=measure` task's numbers over the last thirty relationship days
/// (product/06-build-order.md Phase 5).
class SeriesScreen extends ConsumerWidget {
  const SeriesScreen({
    super.key,
    required this.dynamicId,
    required this.taskId,
    this.title,
    this.onBack,
  });

  final String dynamicId;
  final String taskId;

  /// The task's title when the caller knows it; the screen says 曲线 otherwise.
  final String? title;
  final VoidCallback? onBack;

  static const days = 30;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context);
    final locale = Localizations.localeOf(context).toString();
    final today = ref.watch(todayProvider(dynamicId));

    return Scaffold(
      backgroundColor: DsColors.canvasRitual,
      body: DsRitualSurface(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _header(l),
              today.when(
                skipLoadingOnReload: true,
                loading: () => const Padding(
                  padding: todayInset,
                  child: DsSkeletonBar(width: 160, height: 16),
                ),
                error: (_, _) => QuietLine(l.recordCouldNotLoad),
                data: (view) {
                  final to = view.day;
                  final from = shiftIsoDay(to, -(days - 1));
                  final series = ref.watch(seriesProvider((dynamicId, taskId, from, to)));
                  return series.when(
                    skipLoadingOnReload: true,
                    loading: () => const Padding(
                      padding: todayInset,
                      child: DsSkeletonBar(width: 160, height: 16),
                    ),
                    error: (_, _) => Padding(
                      padding: todayInset,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            l.recordCouldNotLoad,
                            style: DsTextStyles.bodySecondary.copyWith(color: DsColors.textOnRitualSecondary),
                          ),
                          const SizedBox(height: DsSpacing.space4),
                          SecondaryButton(
                            label: l.recoveryTryAgain,
                            onTap: () => ref.invalidate(seriesProvider((dynamicId, taskId, from, to))),
                          ),
                        ],
                      ),
                    ),
                    data: (s) => _body(s, from, to, locale, l),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body(SeriesView s, String from, String to, String locale, L l) {
    final pts = s.points.where((p) => p.value != null).toList(growable: false);
    final unit = s.unit ?? '';
    String label(double v) => '${formatMeasure(v)} $unit'.trim();
    if (pts.isEmpty) return QuietLine(l.recordSeriesEmpty(days));
    var min = pts.first.value!;
    var max = min;
    for (final p in pts) {
      if (p.value! < min) min = p.value!;
      if (p.value! > max) max = p.value!;
    }
    final muted = DsTextStyles.bodySecondary.copyWith(color: DsColors.textOnRitualMuted);
    return Padding(
      padding: todayInset,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.recordSeriesRange(TodayFormat.day(from, locale), TodayFormat.day(to, locale)),
            style: muted,
          ),
          const SizedBox(height: DsSpacing.space4),
          SeriesChart(key: const ValueKey('series-chart'), points: pts),
          const SizedBox(height: DsSpacing.space3),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l.recordSeriesLow(label(min)), style: muted),
              Text(l.recordSeriesHigh(label(max)), style: muted),
            ],
          ),
          const SizedBox(height: DsSpacing.space6),
          Text(
            l.recordSeriesLatest(TodayFormat.day(pts.last.day, locale), label(pts.last.value!)),
            style: DsTextStyles.bodyPrimary.copyWith(color: DsColors.textOnRitualPrimary),
          ),
          const SizedBox(height: DsSpacing.space2),
          Text(l.recordSeriesCount(pts.length), style: muted),
          const SizedBox(height: DsSpacing.space10),
        ],
      ),
    );
  }

  Widget _header(L l) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DsSpacing.space2,
        DsSpacing.space3,
        DsSpacing.space5,
        DsSpacing.space4,
      ),
      child: Row(
        children: [
          Semantics(
            button: true,
            label: l.recordBack,
            child: InkWell(
              onTap: onBack,
              borderRadius: BorderRadius.circular(24),
              child: const SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: DsGlyphIcon(DsGlyph.back, size: 22, color: DsColors.textOnRitualSecondary),
                ),
              ),
            ),
          ),
          const SizedBox(width: DsSpacing.space1),
          Expanded(
            child: Text(
              title ?? l.recordSeriesTitle,
              style: DsTextStyles.titlePage.copyWith(color: DsColors.textOnRitualPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
