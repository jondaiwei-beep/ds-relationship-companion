import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';

import '../../../../app/shell/ds_primary_button.dart';
import '../../../../app/shell/ds_text_field.dart';
import '../../../../l10n/app_localizations.dart';
import 'secondary_button.dart';

/// One line from a person, optionally. Returns `null` when they backed out;
/// an empty string when they chose to say nothing.
Future<String?> showLineSheet(
  BuildContext context, {
  required String title,
  required String label,
  String? hint,
  String? sendLabel,
  bool required = false,
}) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: DsColors.canvasRitual,
    isScrollControlled: true,
    builder: (_) => _LineSheet(
      title: title,
      label: label,
      hint: hint,
      sendLabel: sendLabel,
      required: required,
    ),
  );
}

class _LineSheet extends StatefulWidget {
  const _LineSheet({
    required this.title,
    required this.label,
    this.hint,
    this.sendLabel,
    required this.required,
  });

  final String title;
  final String label;
  final String? hint;
  final String? sendLabel;
  final bool required;

  @override
  State<_LineSheet> createState() => _LineSheetState();
}

class _LineSheetState extends State<_LineSheet> {
  final _controller = TextEditingController();
  bool _canSend = false;

  @override
  void initState() {
    super.initState();
    _canSend = !widget.required;
    _controller.addListener(() {
      final can = !widget.required || _controller.text.trim().isNotEmpty;
      if (can != _canSend) setState(() => _canSend = can);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
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
          if (widget.hint != null) ...[
            const SizedBox(height: DsSpacing.space2),
            Text(
              widget.hint!,
              style: DsTextStyles.bodySecondary.copyWith(color: DsColors.textOnRitualMuted),
            ),
          ],
          const SizedBox(height: DsSpacing.space5),
          DsTextField(
            label: widget.label,
            controller: _controller,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) {
              if (_canSend) Navigator.of(context).pop(_controller.text.trim());
            },
          ),
          const SizedBox(height: DsSpacing.space5),
          DsPrimaryButton(
            label: widget.sendLabel ?? l.todaySend,
            onPressed: _canSend ? () => Navigator.of(context).pop(_controller.text.trim()) : null,
          ),
          const SizedBox(height: DsSpacing.space3),
          SecondaryButton(label: l.todayCancel, onTap: () => Navigator.of(context).pop()),
        ],
      ),
    );
  }
}
