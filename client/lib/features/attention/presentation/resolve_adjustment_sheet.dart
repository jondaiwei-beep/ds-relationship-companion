import 'package:flutter/material.dart';

import '../../../design_system/components/ds_button.dart';
import '../../../design_system/components/ds_text.dart';
import '../../../design_system/components/ds_sheet.dart';
import '../../../design_system/tokens/colors.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';
import '../../../domain_client/repositories/adjustment_repository.dart';

/// The partner answers an adjustment — Journey D.
///
/// The vocabulary is Continue / Adjust / Reschedule / Excuse / Cancel, never
/// approve / reject. Framing this as granting permission would turn an ask
/// about real life into a request the other person may refuse.
class ResolveAdjustmentSheet extends StatefulWidget {
  const ResolveAdjustmentSheet({
    super.key,
    required this.requesterName,
    required this.requestType,
    this.requestNote,
    required this.onResolve,
  });

  final String requesterName;

  /// The backend state: NEED_TO_DISCUSS / RESCHEDULE_REQUESTED / EXCUSE_REQUESTED.
  final String requestType;
  final String? requestNote;
  final Future<void> Function(AdjustmentResolution, String? note) onResolve;

  static Future<void> show(
    BuildContext context, {
    required String requesterName,
    required String requestType,
    String? requestNote,
    required Future<void> Function(AdjustmentResolution, String?) onResolve,
  }) =>
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: DsColors.canvas,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (_) => ResolveAdjustmentSheet(
          requesterName: requesterName,
          requestType: requestType,
          requestNote: requestNote,
          onResolve: onResolve,
        ),
      );

  @override
  State<ResolveAdjustmentSheet> createState() => _ResolveAdjustmentSheetState();
}

class _ResolveAdjustmentSheetState extends State<ResolveAdjustmentSheet> {
  final _note = TextEditingController();
  AdjustmentResolution? _choice;
  var _busy = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  /// Backend state names never reach the user (Notion 05 §12).
  String get _asked => switch (widget.requestType) {
        'NEED_TO_DISCUSS' => '${widget.requesterName} wants to discuss this',
        'RESCHEDULE_REQUESTED' => '${widget.requesterName} asked for a new time',
        'EXCUSE_REQUESTED' => "${widget.requesterName} can't do this right now",
        _ => '${widget.requesterName} asked to adjust this',
      };

  /// The answer that matches what they actually asked comes first.
  ///
  /// A fixed order that always led with "Keep it as it is" meant the first
  /// answer visually privileged not accommodating them — even when they had
  /// specifically asked for a new time. Ordering follows the request.
  List<(AdjustmentResolution, String, String)> get _options {
    const keep = (AdjustmentResolution.cont, 'Keep it as it is',
        'Nothing changes. They do it when they can.');
    const newTime = (AdjustmentResolution.reschedule, 'Give it a new time',
        'Move it. The original stays, marked as rescheduled.');
    const letGo = (AdjustmentResolution.excuse, 'Let it go this time',
        'Closed. Nothing carries over.');
    const cancel = (AdjustmentResolution.cancel, 'Take it off the rhythm',
        'It stops being part of what you do.');

    return switch (widget.requestType) {
      'RESCHEDULE_REQUESTED' => [newTime, letGo, keep, cancel],
      'EXCUSE_REQUESTED' => [letGo, newTime, keep, cancel],
      // A discussion has not asked for an outcome yet, so nothing is
      // privileged: keeping it while you talk is the honest first answer.
      _ => [keep, newTime, letGo, cancel],
    };
  }

  /// The final action names what will happen, rather than committing a
  /// ruling. A generic Send made the choice feel like a decision awaiting
  /// confirmation.
  String get _sendLabel => switch (_choice) {
        AdjustmentResolution.cont => 'Keep it and reply',
        AdjustmentResolution.reschedule => 'Give it a new time',
        AdjustmentResolution.excuse => 'Let it go',
        AdjustmentResolution.cancel => 'Take it off',
        _ => 'Reply',
      };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: DsSpacing.screenPadding,
        right: DsSpacing.screenPadding,
        top: DsSpacing.xxl,
        bottom: MediaQuery.of(context).viewInsets.bottom + DsSpacing.xxl,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const DsSheetHandle(),
            DsEyebrow(_asked, terra: true),
            const SizedBox(height: DsSpacing.md),

            if (widget.requestNote != null && widget.requestNote!.isNotEmpty) ...[
              // Their words, verbatim — this is a person speaking, not a form.
              DsQuote(widget.requestNote!),
              const SizedBox(height: DsSpacing.xl),
            ],

            Text('How would you like to answer?', style: DsType.h2),
            const SizedBox(height: DsSpacing.xl),

            for (final (choice, label, detail) in _options) ...[
              InkWell(
                onTap: _busy ? null : () => setState(() => _choice = choice),
                borderRadius: BorderRadius.circular(DsSpacing.cardRadius),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _choice == choice ? DsColors.stone : DsColors.surface,
                    borderRadius: BorderRadius.circular(DsSpacing.cardRadius),
                    border: Border.all(
                      color: _choice == choice ? DsColors.ink : DsColors.line,
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
            const DsEyebrow('Say something back (optional)'),
            const SizedBox(height: DsSpacing.sm),
            TextField(
              controller: _note,
              maxLines: 3,
              minLines: 2,
              style: DsType.body,
              decoration: InputDecoration(
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
              label: _busy ? 'Sending…' : _sendLabel,
              onPressed: (_choice == null || _busy) ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _busy = true);
    try {
      await widget.onResolve(_choice!, _note.text.trim().isEmpty ? null : _note.text.trim());
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
