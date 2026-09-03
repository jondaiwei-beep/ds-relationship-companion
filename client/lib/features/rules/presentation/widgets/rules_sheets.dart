import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';

import '../../../../app/shell/ds_primary_button.dart';
import '../../../../app/shell/ds_text_field.dart';
import '../../../../domain_client/models/rule.dart';
import '../../../../domain_client/models/task.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../today/presentation/widgets/secondary_button.dart';
import '../../../today/presentation/widgets/word_button.dart';
import '../rules_format.dart';

/// The bottom sheets of 规矩. Each returns what the person wrote, or null
/// when they backed out. None of them talks to the server.

Future<T?> _sheet<T>(BuildContext context, Widget child) => showModalBottomSheet<T>(
      context: context,
      backgroundColor: DsColors.canvasRitual,
      isScrollControlled: true,
      builder: (_) => child,
    );

/// Shared frame: title, fields, primary, cancel, keyboard-aware bottom.
class _Frame extends StatelessWidget {
  const _Frame({
    required this.title,
    required this.children,
    required this.primaryLabel,
    required this.onPrimary,
    this.extra,
  });

  final String title;
  final List<Widget> children;
  final String primaryLabel;
  final VoidCallback? onPrimary;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return SingleChildScrollView(
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
          Text(title, style: DsTextStyles.bodyPrimary.copyWith(color: DsColors.textOnRitualPrimary)),
          const SizedBox(height: DsSpacing.space5),
          for (final c in children) ...[c, const SizedBox(height: DsSpacing.space4)],
          const SizedBox(height: DsSpacing.space1),
          DsPrimaryButton(label: primaryLabel, onPressed: onPrimary),
          if (extra != null) ...[const SizedBox(height: DsSpacing.space3), extra!],
          const SizedBox(height: DsSpacing.space3),
          SecondaryButton(label: l.rulesNeverMind, onTap: () => Navigator.of(context).pop()),
        ],
      ),
    );
  }
}

/// A row of words, one chosen.
class _Words<T> extends StatelessWidget {
  const _Words({required this.options, required this.value, required this.onPick, this.label});

  final List<(String, T)> options;
  final T value;
  final void Function(T) onPick;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: DsTextStyles.labelRitual.copyWith(color: DsColors.textOnRitualMuted)),
          const SizedBox(height: DsSpacing.space2),
        ],
        Wrap(
          spacing: DsSpacing.space2,
          runSpacing: DsSpacing.space2,
          children: [
            for (final (word, v) in options)
              WordButton(label: word, filled: v == value, onTap: () => onPick(v)),
          ],
        ),
      ],
    );
  }
}

// ── Rules ──────────────────────────────────────────────────────────────────

sealed class RuleSheetResult {
  const RuleSheetResult();
}

class RuleSheetSave extends RuleSheetResult {
  const RuleSheetSave(this.title, this.body, this.group);
  final String title;
  final String? body;
  final String group;
}

class RuleSheetArchive extends RuleSheetResult {
  const RuleSheetArchive();
}

/// Write or edit a standing rule. [canArchive] adds the D's 归档 door.
Future<RuleSheetResult?> showRuleSheet(
  BuildContext context, {
  required String title,
  RuleView? existing,
  String? group,
  bool canArchive = false,
  String? primaryLabel,
}) =>
    _sheet(
      context,
      _RuleSheet(
        title: title,
        existing: existing,
        group: group ?? existing?.group ?? 'other',
        canArchive: canArchive,
        primaryLabel: primaryLabel,
      ),
    );

class _RuleSheet extends StatefulWidget {
  const _RuleSheet({
    required this.title,
    required this.existing,
    required this.group,
    required this.canArchive,
    required this.primaryLabel,
  });

  final String title;
  final RuleView? existing;
  final String group;
  final bool canArchive;
  final String? primaryLabel;

  @override
  State<_RuleSheet> createState() => _RuleSheetState();
}

class _RuleSheetState extends State<_RuleSheet> {
  late final _title = TextEditingController(text: widget.existing?.title ?? '');
  late final _body = TextEditingController(text: widget.existing?.body ?? '');
  late String _group = widget.group;

  @override
  void initState() {
    super.initState();
    _title.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final can = _title.text.trim().isNotEmpty;
    return _Frame(
      title: widget.title,
      primaryLabel: widget.primaryLabel ?? l.rulesSave,
      onPrimary: can
          ? () => Navigator.of(context).pop(
                RuleSheetSave(
                  _title.text.trim(),
                  _body.text.trim().isEmpty ? null : _body.text.trim(),
                  _group,
                ),
              )
          : null,
      extra: widget.canArchive
          ? SecondaryButton(
              label: l.rulesArchive,
              onTap: () => Navigator.of(context).pop(const RuleSheetArchive()),
            )
          : null,
      children: [
        DsTextField(label: l.rulesRuleTitleLabel, controller: _title),
        DsTextField(label: l.rulesRuleBodyLabel, controller: _body),
        _Words<String>(
          label: l.rulesGroupLabel,
          options: [for (final g in ruleGroups) (RulesFormat.group(l, g), g)],
          value: _group,
          onPick: (g) => setState(() => _group = g),
        ),
      ],
    );
  }
}

// ── Tasks ──────────────────────────────────────────────────────────────────

enum _ScheduleKind { daily, weekdays, everyN }

/// A new recurring task definition. Returns the body to post.
Future<NewTask?> showTaskSheet(
  BuildContext context, {
  required String title,
  required String dName,
  String? primaryLabel,
}) =>
    _sheet(context, _TaskSheet(title: title, dName: dName, primaryLabel: primaryLabel));

class _TaskSheet extends StatefulWidget {
  const _TaskSheet({required this.title, required this.dName, required this.primaryLabel});
  final String title;
  final String dName;
  final String? primaryLabel;

  @override
  State<_TaskSheet> createState() => _TaskSheetState();
}

class _TaskSheetState extends State<_TaskSheet> {
  final _title = TextEditingController();
  final _points = TextEditingController();
  final _n = TextEditingController(text: '2');
  _ScheduleKind _kind = _ScheduleKind.daily;
  final _days = <int>{1, 2, 3, 4, 5};
  String _proof = 'check';
  bool _needsD = false;

  @override
  void initState() {
    super.initState();
    _title.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _title.dispose();
    _points.dispose();
    _n.dispose();
    super.dispose();
  }

  Map<String, dynamic> _schedule() => switch (_kind) {
        _ScheduleKind.daily => const {'type': 'daily'},
        _ScheduleKind.weekdays => {'type': 'weekdays', 'days': (_days.toList()..sort())},
        _ScheduleKind.everyN => {'type': 'every_n_days', 'n': int.tryParse(_n.text.trim()) ?? 2},
      };

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final names = l.rulesWeekdayNames.split(',');
    final can = _title.text.trim().isNotEmpty && (_kind != _ScheduleKind.weekdays || _days.isNotEmpty);
    return _Frame(
      title: widget.title,
      primaryLabel: widget.primaryLabel ?? l.rulesSave,
      onPrimary: can
          ? () => Navigator.of(context).pop(
                NewTask(
                  title: _title.text.trim(),
                  kind: 'recurring',
                  schedule: _schedule(),
                  proof: _proof,
                  pointsEarn: int.tryParse(_points.text.trim()) ?? 0,
                  requiresDPresent: _needsD,
                ),
              )
          : null,
      children: [
        DsTextField(label: l.rulesTaskTitleLabel, controller: _title),
        _Words<_ScheduleKind>(
          options: [
            (l.rulesScheduleDaily, _ScheduleKind.daily),
            (l.rulesScheduleWeekdays('').trim(), _ScheduleKind.weekdays),
            (l.rulesEveryNLabel, _ScheduleKind.everyN),
          ],
          value: _kind,
          onPick: (k) => setState(() => _kind = k),
        ),
        if (_kind == _ScheduleKind.weekdays)
          Wrap(
            spacing: DsSpacing.space2,
            runSpacing: DsSpacing.space2,
            children: [
              for (var d = 1; d <= 7; d++)
                WordButton(
                  label: names[d - 1],
                  filled: _days.contains(d),
                  onTap: () => setState(() => _days.contains(d) ? _days.remove(d) : _days.add(d)),
                ),
            ],
          ),
        if (_kind == _ScheduleKind.everyN)
          DsTextField(label: l.rulesEveryNLabel, controller: _n, keyboardType: TextInputType.number),
        _Words<String>(
          options: [
            (l.rulesProofCheck, 'check'),
            (l.rulesProofPhoto, 'photo'),
            (l.rulesProofText, 'text'),
            (l.rulesProofAny, 'any'),
          ],
          value: _proof,
          onPick: (p) => setState(() => _proof = p),
        ),
        DsTextField(label: l.rulesPointsLabel, controller: _points, keyboardType: TextInputType.number),
        Row(
          children: [
            Expanded(
              child: Text(
                l.rulesRequiresDLabel(widget.dName),
                style: DsTextStyles.bodyPrimary.copyWith(color: DsColors.textOnRitualPrimary),
              ),
            ),
            Switch.adaptive(value: _needsD, onChanged: (v) => setState(() => _needsD = v)),
          ],
        ),
      ],
    );
  }
}

// ── Rewards ────────────────────────────────────────────────────────────────

class RewardDraft {
  const RewardDraft(this.title, this.cost);
  final String title;
  /// Null =「D 决定」.
  final int? cost;
}

Future<RewardDraft?> showRewardSheet(BuildContext context) => _sheet(context, const _RewardSheet());

class _RewardSheet extends StatefulWidget {
  const _RewardSheet();

  @override
  State<_RewardSheet> createState() => _RewardSheetState();
}

class _RewardSheetState extends State<_RewardSheet> {
  final _title = TextEditingController();
  final _cost = TextEditingController();
  bool _dDecides = false;

  @override
  void initState() {
    super.initState();
    _title.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _title.dispose();
    _cost.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final can = _title.text.trim().isNotEmpty;
    return _Frame(
      title: l.rulesAddReward,
      primaryLabel: l.rulesSave,
      onPrimary: can
          ? () => Navigator.of(context).pop(
                RewardDraft(
                  _title.text.trim(),
                  _dDecides ? null : (int.tryParse(_cost.text.trim()) ?? 0),
                ),
              )
          : null,
      children: [
        DsTextField(label: l.rulesRewardTitleLabel, controller: _title),
        if (!_dDecides)
          DsTextField(label: l.rulesRewardCostLabel, controller: _cost, keyboardType: TextInputType.number),
        Row(
          children: [
            Expanded(
              child: Text(
                l.rulesRewardDDecides,
                style: DsTextStyles.bodyPrimary.copyWith(color: DsColors.textOnRitualPrimary),
              ),
            ),
            Switch.adaptive(value: _dDecides, onChanged: (v) => setState(() => _dDecides = v)),
          ],
        ),
      ],
    );
  }
}

// ── Consequence templates ──────────────────────────────────────────────────

class TemplateDraft {
  const TemplateDraft(this.label, this.consequence);
  final String label;
  final String consequence;
}

Future<TemplateDraft?> showTemplateSheet(BuildContext context) =>
    _sheet(context, const _TemplateSheet());

class _TemplateSheet extends StatefulWidget {
  const _TemplateSheet();

  @override
  State<_TemplateSheet> createState() => _TemplateSheetState();
}

class _TemplateSheetState extends State<_TemplateSheet> {
  final _label = TextEditingController();
  final _then = TextEditingController();

  @override
  void initState() {
    super.initState();
    _label.addListener(() => setState(() {}));
    _then.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _label.dispose();
    _then.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final can = _label.text.trim().isNotEmpty && _then.text.trim().isNotEmpty;
    return _Frame(
      title: l.rulesAddConsequence,
      primaryLabel: l.rulesSave,
      onPrimary: can
          ? () => Navigator.of(context).pop(TemplateDraft(_label.text.trim(), _then.text.trim()))
          : null,
      children: [
        DsTextField(label: l.rulesConsequenceWhen, controller: _label),
        DsTextField(label: l.rulesConsequenceThen, controller: _then),
      ],
    );
  }
}

/// A number and, optionally, a line. Used by 分 for 给分 / 扣分 and for the
/// D naming a cost on a「D 决定」reward. Returns null when backed out.
class NumberNote {
  const NumberNote({this.amount, this.note});
  final int? amount;
  final String? note;
}

Future<NumberNote?> showNumberNoteSheet(
  BuildContext context, {
  required String title,
  required String amountLabel,
  required String noteLabel,
  required String primaryLabel,
  bool amountRequired = true,
}) =>
    _sheet<NumberNote>(
      context,
      _NumberNoteSheet(
        title: title,
        amountLabel: amountLabel,
        noteLabel: noteLabel,
        primaryLabel: primaryLabel,
        amountRequired: amountRequired,
      ),
    );

class _NumberNoteSheet extends StatefulWidget {
  const _NumberNoteSheet({
    required this.title,
    required this.amountLabel,
    required this.noteLabel,
    required this.primaryLabel,
    required this.amountRequired,
  });
  final String title;
  final String amountLabel;
  final String noteLabel;
  final String primaryLabel;
  final bool amountRequired;

  @override
  State<_NumberNoteSheet> createState() => _NumberNoteSheetState();
}

class _NumberNoteSheetState extends State<_NumberNoteSheet> {
  final _amount = TextEditingController();
  final _note = TextEditingController();

  @override
  void initState() {
    super.initState();
    _amount.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  int? get _parsed => int.tryParse(_amount.text.trim());

  @override
  Widget build(BuildContext context) {
    final ok = !widget.amountRequired || (_parsed != null && _parsed! > 0);
    return _Frame(
      title: widget.title,
      primaryLabel: widget.primaryLabel,
      onPrimary: ok
          ? () => Navigator.of(context).pop(NumberNote(
                amount: _parsed,
                note: _note.text.trim().isEmpty ? null : _note.text.trim(),
              ))
          : null,
      children: [
        DsTextField(
          label: widget.amountLabel,
          controller: _amount,
          keyboardType: TextInputType.number,
        ),
        DsTextField(label: widget.noteLabel, controller: _note),
      ],
    );
  }
}
