import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import 'secondary_button.dart';

/// One choice among a few words. Returns `null` when the person backs out.
Future<T?> showChoiceSheet<T>(
  BuildContext context, {
  required String title,
  required List<(String, T)> choices,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: DsColors.canvasRitual,
    builder: (sheet) {
      final l = L.of(sheet);
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            DsSpacing.space5,
            DsSpacing.space6,
            DsSpacing.space5,
            DsSpacing.space6,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: DsTextStyles.bodyPrimary.copyWith(color: DsColors.textOnRitualPrimary),
              ),
              const SizedBox(height: DsSpacing.space5),
              for (final (label, value) in choices) ...[
                SecondaryButton(label: label, onTap: () => Navigator.of(sheet).pop(value)),
                const SizedBox(height: DsSpacing.space3),
              ],
              SecondaryButton(label: l.todayCancel, onTap: () => Navigator.of(sheet).pop()),
            ],
          ),
        ),
      );
    },
  );
}
