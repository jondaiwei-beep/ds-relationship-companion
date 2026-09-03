import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../domain/relationship_day.dart';
import '../../../l10n/app_localizations.dart';
import '../../today/presentation/widgets/choice_sheet.dart';
import '../application/calendar_math.dart';
import '../application/record_export.dart';

/// 导出记录: pick a range (the last 90 days first), fetch the CSV, hand it on.
///
/// [today] is the relationship day the server named, `yyyy-MM-dd`; the ranges
/// end there, not at the device clock.
Future<void> showExportSheet(
  BuildContext context,
  WidgetRef ref, {
  required String dynamicId,
  required String today,
}) async {
  final l = L.of(context);
  final chosen = await showChoiceSheet<int>(
    context,
    title: l.recordExport,
    choices: [
      (l.recordExportLastDays(90), 90),
      (l.recordExportLastDays(30), 30),
      (l.recordExportLastDays(365), 365),
      (l.recordExportCustom, 0),
    ],
  );
  if (chosen == null || !context.mounted) return;

  String from;
  String to;
  if (chosen > 0) {
    to = today;
    from = shiftIsoDay(today, -(chosen - 1));
  } else {
    final last = RelationshipDay.parseIsoDay(today);
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime.utc(2020),
      lastDate: last,
      initialDateRange: DateTimeRange(
        start: RelationshipDay.parseIsoDay(shiftIsoDay(today, -89)),
        end: last,
      ),
      helpText: l.recordExport,
    );
    if (range == null || !context.mounted) return;
    from = RelationshipDay.isoDay(range.start);
    to = RelationshipDay.isoDay(range.end);
    if (range.end.difference(range.start).inDays >= 366) {
      from = shiftIsoDay(to, -365);
    }
  }

  final messenger = ScaffoldMessenger.of(context);
  void say(String text) => messenger.showSnackBar(
        SnackBar(
          content: Text(text),
          backgroundColor: DsColors.surfaceRitualRaised,
          duration: const Duration(seconds: 3),
        ),
      );
  try {
    final csv = await ref.read(recordRepositoryProvider).exportCsv(dynamicId, from: from, to: to);
    final filename = 'record-$from-$to.csv';
    await ref.read(exportSinkProvider)(filename, csv);
    say(l.recordExported(filename));
  } on Object catch (_) {
    say(l.recordExportFailed);
  }
}
