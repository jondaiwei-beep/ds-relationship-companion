import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';

import '../../../../app/shell/ds_primary_button.dart';
import '../../../../app/shell/ds_text_field.dart';
import '../../../../domain_client/models/task.dart';
import '../../../../l10n/app_localizations.dart';
import 'secondary_button.dart';
import 'today_layout.dart';

/// 快速加一条: a title, today or every day, points if any. Everything else a
/// task can carry is one door away — [onMore] opens the full editor seeded
/// with what was typed here.
class DQuickAdd extends StatefulWidget {
  const DQuickAdd({super.key, required this.onAdd, this.onMore});

  /// Resolves when the server has the task; throws when it does not.
  final Future<void> Function(NewTask task) onAdd;

  /// Opens the full task editor with [draft] pre-filled. Returns true when a
  /// task was made, false when backed out; throws when the server said no.
  final Future<bool> Function(NewTask draft)? onMore;

  @override
  State<DQuickAdd> createState() => _DQuickAddState();
}

class _DQuickAddState extends State<DQuickAdd> {
  final _title = TextEditingController();
  final _points = TextEditingController();
  bool _daily = false;
  bool _busy = false;
  String? _message;

  @override
  void dispose() {
    _title.dispose();
    _points.dispose();
    super.dispose();
  }

  NewTask _draft() {
    final title = _title.text.trim();
    final points = (int.tryParse(_points.text.trim()) ?? 0).clamp(0, 1000);
    return _daily
        ? NewTask(
            title: title,
            kind: 'recurring',
            schedule: const {'type': 'daily'},
            pointsEarn: points,
          )
        : NewTask(title: title, kind: 'one_off', pointsEarn: points);
  }

  Future<void> _more() async {
    final l = L.of(context);
    try {
      final made = await widget.onMore!(_draft());
      if (!mounted || !made) return;
      _title.clear();
      _points.clear();
      setState(() => _message = l.dTodayQuickAdded);
    } on Object {
      if (mounted) setState(() => _message = l.dTodayQuickFailed);
    }
  }

  Future<void> _submit() async {
    final l = L.of(context);
    final title = _title.text.trim();
    if (title.isEmpty || _busy) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    final task = _draft();
    try {
      await widget.onAdd(task);
      if (!mounted) return;
      _title.clear();
      _points.clear();
      setState(() => _message = l.dTodayQuickAdded);
    } on Object {
      if (!mounted) return;
      setState(() => _message = l.dTodayQuickFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Padding(
      padding: todayInset,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DsTextField(
            label: l.dTodayQuickTitle,
            controller: _title,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: DsSpacing.space3),
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  label: l.dTodayQuickToday,
                  filled: !_daily,
                  onTap: () => setState(() => _daily = false),
                ),
              ),
              const SizedBox(width: DsSpacing.space3),
              Expanded(
                child: SecondaryButton(
                  label: l.dTodayQuickDaily,
                  filled: _daily,
                  onTap: () => setState(() => _daily = true),
                ),
              ),
            ],
          ),
          const SizedBox(height: DsSpacing.space3),
          DsTextField(
            label: l.dTodayQuickPoints,
            controller: _points,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: DsSpacing.space4),
          DsPrimaryButton(label: l.dTodayQuickAdd, onPressed: _submit, busy: _busy),
          if (widget.onMore != null) ...[
            const SizedBox(height: DsSpacing.space3),
            SecondaryButton(label: l.dTodayQuickMore, onTap: _busy ? () {} : _more),
          ],
          if (_message != null) ...[
            const SizedBox(height: DsSpacing.space3),
            Text(
              _message!,
              style: DsTextStyles.bodySecondary.copyWith(color: DsColors.textOnRitualSecondary),
            ),
          ],
        ],
      ),
    );
  }
}
