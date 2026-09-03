import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';

import '../../../../app/shell/ds_primary_button.dart';
import '../../../../app/shell/ds_text_field.dart';
import '../../../../l10n/app_localizations.dart';
import 'secondary_button.dart';

/// The number a `kind=measure` task asks for. Returns `null` when the s
/// backed out.
Future<double?> showMeasureSheet(
  BuildContext context, {
  required String title,
  String? unit,
}) {
  return showModalBottomSheet<double>(
    context: context,
    backgroundColor: DsColors.canvasRitual,
    isScrollControlled: true,
    builder: (_) => _MeasureSheet(title: title, unit: unit),
  );
}

class _MeasureSheet extends StatefulWidget {
  const _MeasureSheet({required this.title, this.unit});

  final String title;
  final String? unit;

  @override
  State<_MeasureSheet> createState() => _MeasureSheetState();
}

class _MeasureSheetState extends State<_MeasureSheet> {
  final _controller = TextEditingController();
  double? _value;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final parsed = double.tryParse(_controller.text.trim().replaceAll(',', '.'));
      final next = parsed != null && parsed.isFinite ? parsed : null;
      if (next != _value) setState(() => _value = next);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final v = _value;
    if (v != null) Navigator.of(context).pop(v);
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final unit = widget.unit;
    return Padding(
      padding: EdgeInsets.only(
        left: DsSpacing.space5,
        right: DsSpacing.space5,
        top: DsSpacing.space6,
        bottom: MediaQuery.viewInsetsOf(context).bottom + DsSpacing.space6,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.title,
            style: DsTextStyles.bodyPrimary.copyWith(color: DsColors.textOnRitualPrimary),
          ),
          const SizedBox(height: DsSpacing.space5),
          DsTextField(
            key: const ValueKey('measure-field'),
            label: unit == null || unit.isEmpty ? l.sTodayMeasureLabel : l.sTodayMeasureLabelUnit(unit),
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _send(),
          ),
          const SizedBox(height: DsSpacing.space5),
          DsPrimaryButton(
            label: l.todaySend,
            onPressed: _value == null ? null : _send,
          ),
          const SizedBox(height: DsSpacing.space3),
          SecondaryButton(label: l.todayCancel, onTap: () => Navigator.of(context).pop()),
        ],
      ),
    );
  }
}
