import 'package:flutter/material.dart';

import '../../../design_system/components/ds_button.dart';
import '../../../design_system/components/ds_text.dart';
import '../../../design_system/components/ds_sheet.dart';
import '../../../design_system/tokens/colors.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';
import '../../../domain_client/models/check_in_view.dart';

/// Check-in — "What context do I want to share?" (Notion 02 §9).
///
/// This is how someone says *I'm low today, I can continue but gently*
/// without it being a failure to report. Two things carry that:
///
/// 1. Visibility is an explicit, visible choice, defaulting to PRIVATE.
///    Notion 04 §3 forbids "you're in a dynamic so it's obviously shared".
/// 2. Nothing is required. A check-in with only an energy level is complete.
class CheckInSheet extends StatefulWidget {
  const CheckInSheet({super.key, required this.framing, required this.onSubmit});

  /// One of the rotating framings from the content library, so the first
  /// check-in does not feel like a form.
  final String framing;

  final Future<void> Function({
    String? mood,
    String? energy,
    String? need,
    String? note,
    required CheckInVisibility visibility,
  }) onSubmit;

  static Future<void> show(
    BuildContext context, {
    required String framing,
    required Future<void> Function({
      String? mood,
      String? energy,
      String? need,
      String? note,
      required CheckInVisibility visibility,
    }) onSubmit,
  }) =>
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: DsColors.canvas,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (_) => CheckInSheet(framing: framing, onSubmit: onSubmit),
      );

  @override
  State<CheckInSheet> createState() => _CheckInSheetState();
}

class _CheckInSheetState extends State<CheckInSheet> {
  final _note = TextEditingController();
  String? _energy;
  // Private is the default. Sharing is a deliberate act.
  var _visibility = CheckInVisibility.private;
  var _busy = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  static const _energies = <(String, String)>[
    ('LOW', 'Low'),
    ('STEADY', 'Steady'),
    ('HIGH', 'High'),
  ];

  @override
  Widget build(BuildContext context) {
    final shared = _visibility == CheckInVisibility.shared;

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
            Text(widget.framing, style: DsType.h2),
            const SizedBox(height: DsSpacing.xxl),

            const DsEyebrow('Energy'),
            const SizedBox(height: DsSpacing.sm),
            Wrap(
              spacing: DsSpacing.sm,
              children: [
                for (final (value, label) in _energies)
                  ChoiceChip(
                    label: Text(label, style: DsType.fine),
                    selected: _energy == value,
                    selectedColor: DsColors.stone,
                    backgroundColor: DsColors.surface,
                    side: const BorderSide(color: DsColors.lineStrong),
                    onSelected: (_) => setState(
                      () => _energy = _energy == value ? null : value,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: DsSpacing.xl),
            const DsEyebrow('Anything else (optional)'),
            const SizedBox(height: DsSpacing.sm),
            TextField(
              controller: _note,
              maxLines: 4,
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
            // The privacy choice is a visible, explicit control — never a
            // buried setting and never a silent default to shared.
            const DsEyebrow('Who can see this'),
            const SizedBox(height: DsSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _VisibilityOption(
                    label: 'Just me',
                    detail: 'Kept private.',
                    selected: !shared,
                    onTap: () => setState(() => _visibility = CheckInVisibility.private),
                  ),
                ),
                const SizedBox(width: DsSpacing.sm),
                Expanded(
                  child: _VisibilityOption(
                    label: 'Share',
                    detail: 'Your partner sees it.',
                    selected: shared,
                    onTap: () => setState(() => _visibility = CheckInVisibility.shared),
                  ),
                ),
              ],
            ),

            const SizedBox(height: DsSpacing.xxl),
            DsButton(
              label: _busy ? 'Saving…' : (shared ? 'Share' : 'Keep private'),
              onPressed: _busy ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _busy = true);
    try {
      await widget.onSubmit(
        energy: _energy,
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
        visibility: _visibility,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("That didn't save. Please try again.")),
        );
      }
    }
  }
}

class _VisibilityOption extends StatelessWidget {
  const _VisibilityOption({
    required this.label,
    required this.detail,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String detail;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DsSpacing.cardRadius),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected ? DsColors.stone : DsColors.surface,
            borderRadius: BorderRadius.circular(DsSpacing.cardRadius),
            border: Border.all(
              color: selected ? DsColors.ink : DsColors.line,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: DsType.cardTitle.copyWith(fontSize: 15)),
              const SizedBox(height: DsSpacing.xs),
              Text(detail, style: DsType.fine),
            ],
          ),
        ),
      );
}
