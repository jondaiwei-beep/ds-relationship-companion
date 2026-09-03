import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';

import '../../../../app/shell/ds_primary_button.dart';
import '../../../../app/shell/ds_text_field.dart';
import '../../../../domain/relationship_day.dart';
import '../../../../domain_client/models/d_note.dart';
import '../../../../l10n/app_localizations.dart';
import '../today_format.dart';
import 'secondary_button.dart';
import 'word_button.dart';
import 'today_layout.dart';

/// 我要记得的: the D's private notes, with an optional reminder time.
class DNotesSection extends StatefulWidget {
  const DNotesSection({
    super.key,
    required this.notes,
    required this.timezone,
    required this.onAdd,
    required this.onDone,
    required this.onDelete,
  });

  final List<DNote> notes;
  final String timezone;
  final Future<void> Function(String body, DateTime? remindAt) onAdd;
  final Future<void> Function(DNote note) onDone;
  final Future<void> Function(DNote note) onDelete;

  @override
  State<DNotesSection> createState() => _DNotesSectionState();
}

class _DNotesSectionState extends State<DNotesSection> {
  final _body = TextEditingController();
  DateTime? _remindAt;
  bool _busy = false;

  @override
  void dispose() {
    _body.dispose();
    super.dispose();
  }

  Future<void> _pickRemind() async {
    final now = DateTime.now();
    final day = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (day == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time == null || !mounted) return;
    setState(() {
      _remindAt = TodayFormat.instantOf(
        RelationshipDay.isoDay(day),
        time.hour,
        time.minute,
        widget.timezone,
      );
    });
  }

  Future<void> _submit() async {
    final body = _body.text.trim();
    if (body.isEmpty || _busy) return;
    setState(() => _busy = true);
    try {
      await widget.onAdd(body, _remindAt);
      if (!mounted) return;
      _body.clear();
      setState(() => _remindAt = null);
    } on Object {
      // The list simply does not gain the note; the text stays for another try.
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final locale = Localizations.localeOf(context).toString();
    final secondary = DsTextStyles.bodySecondary.copyWith(color: DsColors.textOnRitualSecondary);
    final muted = DsTextStyles.bodySecondary.copyWith(color: DsColors.textOnRitualMuted);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final n in widget.notes)
          Container(
            key: ValueKey('dnote-${n.id}'),
            padding: todayInset.add(const EdgeInsets.symmetric(vertical: DsSpacing.space3)),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: DsColors.borderOnRitualHairline)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        n.body,
                        style: DsTextStyles.bodyPrimary.copyWith(color: DsColors.textOnRitualPrimary),
                      ),
                      if (n.remindAt != null) ...[
                        const SizedBox(height: DsSpacing.space1),
                        Text(
                          l.dTodayNoteRemindAt(
                            TodayFormat.dayClock(n.remindAt!, widget.timezone, locale),
                          ),
                          style: muted,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: DsSpacing.space3),
                WordButton(label: l.dTodayNoteDone, onTap: () => widget.onDone(n)),
                const SizedBox(width: DsSpacing.space2),
                WordButton(label: l.dTodayNoteDelete, onTap: () => widget.onDelete(n)),
              ],
            ),
          ),
        Padding(
          padding: todayInset.add(const EdgeInsets.only(top: DsSpacing.space4)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DsTextField(
                label: l.dTodayNoteBody,
                controller: _body,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: DsSpacing.space3),
              SecondaryButton(
                label: _remindAt == null
                    ? l.dTodayNoteRemind
                    : l.dTodayNoteRemindAt(
                        TodayFormat.dayClock(_remindAt!, widget.timezone, locale),
                      ),
                filled: _remindAt != null,
                onTap: _pickRemind,
              ),
              const SizedBox(height: DsSpacing.space4),
              DsPrimaryButton(label: l.dTodayNoteAdd, onPressed: _submit, busy: _busy),
              const SizedBox(height: DsSpacing.space3),
              Text(l.dTodayNotesPrivate, style: secondary),
            ],
          ),
        ),
      ],
    );
  }
}
