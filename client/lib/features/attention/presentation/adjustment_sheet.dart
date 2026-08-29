import 'package:flutter/material.dart';

import '../../../design_system/components/ds_button.dart';
import '../../../design_system/components/ds_text.dart';
import '../../../design_system/components/ds_sheet.dart';
import '../../../design_system/tokens/colors.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';
import '../../../domain_client/repositories/adjustment_repository.dart';

/// Ask to discuss, move, or skip — Journey D.
///
/// The tone here is doing real work. Adjustment is the NORMAL path when life
/// gets in the way (red line #3), so this must never read as a confession
/// form: no apology language, no "reason required", no warning about
/// consequences. The note is optional.
class AdjustmentSheet extends StatefulWidget {
  const AdjustmentSheet({super.key, required this.onSubmit});

  final Future<void> Function(AdjustmentType type, String? note) onSubmit;

  static Future<void> show(
    BuildContext context,
    Future<void> Function(AdjustmentType, String?) onSubmit,
  ) =>
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: DsColors.canvas,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (_) => AdjustmentSheet(onSubmit: onSubmit),
      );

  @override
  State<AdjustmentSheet> createState() => _AdjustmentSheetState();
}

class _AdjustmentSheetState extends State<AdjustmentSheet> {
  final _note = TextEditingController();
  AdjustmentType? _type;
  var _busy = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  /// Notion 05 §2 fixes this vocabulary. "I can't do this right now" is
  /// deliberately in the first person and present tense: it is a statement
  /// about today, not an admission about the person.
  static const _options = <(AdjustmentType, String, String)>[
    (AdjustmentType.discuss, 'Need to discuss',
        'Something about this needs a conversation first.'),
    (AdjustmentType.reschedule, 'Request a new time',
        'The intention stands; the timing does not work.'),
    (AdjustmentType.cantDo, "I can't do this right now",
        'Today is not the day. That is allowed.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: DsSpacing.screenPadding,
        right: DsSpacing.screenPadding,
        top: DsSpacing.xxl,
        bottom: MediaQuery.of(context).viewInsets.bottom + DsSpacing.xxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DsSheetHandle(),
          Text('What would help?', style: DsType.h2),
          const SizedBox(height: DsSpacing.sm),
          Text(
            'None of these is a missed expectation.',
            style: DsType.fine.copyWith(color: DsColors.muted),
          ),
          const SizedBox(height: DsSpacing.xl),

          for (final (type, label, detail) in _options) ...[
            InkWell(
              onTap: _busy ? null : () => setState(() => _type = type),
              borderRadius: BorderRadius.circular(DsSpacing.cardRadius),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _type == type ? DsColors.stone : DsColors.surface,
                  borderRadius: BorderRadius.circular(DsSpacing.cardRadius),
                  border: Border.all(
                    color: _type == type ? DsColors.ink : DsColors.line,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: DsType.cardTitle),
                    const SizedBox(height: DsSpacing.xs),
                    Text(detail, style: DsType.fine),
                  ],
                ),
              ),
            ),
            const SizedBox(height: DsSpacing.md),
          ],

          const SizedBox(height: DsSpacing.sm),
          const DsEyebrow('Anything you want to say (optional)'),
          const SizedBox(height: DsSpacing.sm),
          TextField(
            controller: _note,
            maxLines: 3,
            minLines: 2,
            style: DsType.body,
            decoration: InputDecoration(
              // No reason is required. Asking for one would make this a
              // justification form.
              hintText: 'Optional',
              hintStyle: DsType.body.copyWith(color: DsColors.muted),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: DsColors.line),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: DsColors.lineStrong),
              ),
            ),
          ),

          const SizedBox(height: DsSpacing.xxl),
          DsButton(
            label: _busy ? 'Sending…' : 'Send',
            onPressed: (_type == null || _busy) ? null : _submit,
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _busy = true);
    try {
      await widget.onSubmit(_type!, _note.text.trim().isEmpty ? null : _note.text.trim());
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("That didn't go through. Please try again.")),
        );
      }
    }
  }
}
