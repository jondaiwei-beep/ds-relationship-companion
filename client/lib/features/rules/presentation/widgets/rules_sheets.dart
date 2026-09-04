import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';

import '../../../../app/shell/ds_primary_button.dart';
import '../../../../app/shell/ds_text_field.dart';
import '../../../../domain_client/models/rule.dart';
import '../../../../domain_client/models/task.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../today/presentation/today_format.dart';
import '../../../today/presentation/widgets/secondary_button.dart';
import '../../../today/presentation/widgets/word_button.dart';
import '../rules_format.dart';

/// The bottom sheets of 规矩. Each returns what the person wrote, or null
/// when they backed out. None of them talks to the server.

Future<T?> _sheet<T>(BuildContext context, Widget child) => showModalBottomSheet<T>(
      context: context,
      backgroundColor: DsColors.canvasRitual,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(DsRadii.control)),
      ),
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
    // The keyboard covers the gesture bar, so whichever is showing is the
    // one to clear; the sheet used to clear only the keyboard and put its
    // last row under the bar.
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final bar = keyboard > 0 ? 0.0 : MediaQuery.viewPaddingOf(context).bottom;
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: DsSpacing.space5,
        right: DsSpacing.space5,
        top: DsSpacing.space6,
        bottom: keyboard + bar + DsSpacing.space6,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: DsTextStyles.titlePage.copyWith(color: DsColors.textOnRitualPrimary)),
          const SizedBox(height: DsSpacing.space5),
          for (final c in children) ...[c, const SizedBox(height: DsSpacing.space4)],
          const SizedBox(height: DsSpacing.space1),
          DsPrimaryButton(key: const ValueKey('sheet-primary'), label: primaryLabel, onPressed: onPrimary),
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

const _taskKinds = ['recurring', 'one_off', 'open', 'checkin', 'measure'];

/// Write or edit a task definition. Returns the body to post (or to PATCH
/// when [existing] is set — every field is pre-filled from it). [draft] seeds
/// a fresh sheet, e.g. from 快速加一条's「更多设置」.
///
/// Clocks are wall time in the Dynamic's [timezone] (invariant 7); [today] is
/// the current relationship day, which seeds 每 N 天's start and a one-off's
/// day.
Future<NewTask?> showTaskSheet(
  BuildContext context, {
  required String title,
  required String dName,
  required String timezone,
  required String today,
  int dayBoundaryMinutes = 240,
  TaskView? existing,
  NewTask? draft,
  String? primaryLabel,
}) =>
    _sheet(
      context,
      _TaskSheet(
        title: title,
        dName: dName,
        timezone: timezone,
        today: today,
        dayBoundaryMinutes: dayBoundaryMinutes,
        existing: existing,
        draft: draft,
        primaryLabel: primaryLabel,
      ),
    );

class _TaskSheet extends StatefulWidget {
  const _TaskSheet({
    required this.title,
    required this.dName,
    required this.timezone,
    required this.today,
    required this.dayBoundaryMinutes,
    required this.existing,
    required this.draft,
    required this.primaryLabel,
  });
  final String title;
  final String dName;
  final String timezone;
  final String today;
  final int dayBoundaryMinutes;
  final TaskView? existing;
  final NewTask? draft;
  final String? primaryLabel;

  @override
  State<_TaskSheet> createState() => _TaskSheetState();
}

class _TaskSheetState extends State<_TaskSheet> {
  static const _maxDetail = 1000;
  static const _maxPoints = 1000;
  static const _maxTimes = 12;

  final _title = TextEditingController();
  final _detail = TextEditingController();
  final _points = TextEditingController();
  final _n = TextEditingController(text: '2');
  final _unit = TextEditingController();

  String _kind = 'recurring';
  _ScheduleKind _schedule = _ScheduleKind.daily;
  final _days = <int>{1, 2, 3, 4, 5};
  late String _from = widget.today;
  int _timesPerDay = 1;
  TimeOfDay? _dueTime;
  late DateTime? _dueDate;
  TimeOfDay? _dueClock;
  String _proof = 'check';
  bool _needsD = false;

  /// Set on the first save attempt; before that no field is scolded.
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    final d = widget.draft;
    _dueDate = null;
    if (e != null) {
      _title.text = e.title;
      _detail.text = e.detail ?? '';
      _kind = _taskKinds.contains(e.kind) ? e.kind : 'recurring';
      _readSchedule(e.schedule);
      _timesPerDay = e.timesPerDay.clamp(1, _maxTimes);
      _dueTime = _parseClock(e.dueTime);
      if (e.dueAt != null) {
        final local = TodayFormat.inZone(e.dueAt!, widget.timezone);
        _dueDate = DateTime(local.year, local.month, local.day);
        _dueClock = TimeOfDay(hour: local.hour, minute: local.minute);
      }
      _proof = e.proof;
      _points.text = e.pointsEarn == 0 ? '' : '${e.pointsEarn}';
      _needsD = e.requiresDPresent;
      _unit.text = e.unit ?? '';
    } else if (d != null) {
      _title.text = d.title;
      _detail.text = d.detail ?? '';
      _kind = _taskKinds.contains(d.kind) ? d.kind : 'recurring';
      _readSchedule(d.schedule);
      _timesPerDay = d.timesPerDay.clamp(1, _maxTimes);
      _dueTime = _parseClock(d.dueTime);
      _proof = d.proof;
      _points.text = d.pointsEarn == 0 ? '' : '${d.pointsEarn}';
      _needsD = d.requiresDPresent;
      _unit.text = d.unit ?? '';
    }
    if (_kind == 'one_off' && _dueDate == null) {
      _dueDate = _dayOf(widget.today);
    }
    for (final c in [_title, _detail, _points, _n, _unit]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _detail.dispose();
    _points.dispose();
    _n.dispose();
    _unit.dispose();
    super.dispose();
  }

  // ── reading ──────────────────────────────────────────────────────────────

  void _readSchedule(Map<String, dynamic>? s) {
    if (s == null) return;
    switch (s['type']) {
      case 'weekdays':
        _schedule = _ScheduleKind.weekdays;
        final days = (s['days'] as List?)?.map((d) => (d as num).toInt()) ?? const <int>[];
        _days
          ..clear()
          ..addAll(days.where((d) => d >= 1 && d <= 7));
      case 'every_n_days':
        _schedule = _ScheduleKind.everyN;
        _n.text = '${(s['n'] as num?)?.toInt() ?? 2}';
        _from = (s['from'] as String?) ?? widget.today;
      default:
        _schedule = _ScheduleKind.daily;
    }
  }

  static TimeOfDay? _parseClock(String? hhmm) {
    if (hhmm == null) return null;
    final parts = hhmm.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  static DateTime _dayOf(String iso) {
    final p = iso.split('-').map(int.parse).toList(growable: false);
    return DateTime(p[0], p[1], p[2]);
  }

  static String _iso(DateTime d) => '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  static String _hhmm(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  // ── derived ──────────────────────────────────────────────────────────────

  bool get _hasSchedule => _kind == 'recurring';
  bool get _hasTimesPerDay => _kind == 'recurring' || _kind == 'checkin';
  bool get _hasDueTime => _kind == 'recurring' || _kind == 'checkin' || _kind == 'measure';
  bool get _hasDueAt => _kind == 'one_off';
  bool get _hasUnit => _kind == 'measure';
  bool get _proofLocked => _kind == 'checkin';

  int? get _nValue => int.tryParse(_n.text.trim());
  int? get _pointsValue => _points.text.trim().isEmpty ? 0 : int.tryParse(_points.text.trim());

  String? _titleError(L l) => _title.text.trim().isEmpty ? l.rulesTaskTitleRequired : null;
  String? _detailError(L l) => _detail.text.trim().length > _maxDetail ? l.rulesTaskDetailTooLong : null;
  String? _daysError(L l) =>
      _hasSchedule && _schedule == _ScheduleKind.weekdays && _days.isEmpty ? l.rulesWeekdaysRequired : null;
  String? _nError(L l) {
    if (!_hasSchedule || _schedule != _ScheduleKind.everyN) return null;
    final n = _nValue;
    return n == null || n < 2 || n > 365 ? l.rulesEveryNInvalid : null;
  }
  String? _dueAtError(L l) => _hasDueAt && _dueDate == null ? l.rulesDueAtRequired : null;
  String? _pointsError(L l) {
    final p = _pointsValue;
    return p == null || p < 0 || p > _maxPoints ? l.rulesPointsRange : null;
  }
  String? _unitError(L l) => _hasUnit && _unit.text.trim().isEmpty ? l.rulesUnitRequired : null;

  bool _valid(L l) => [
        _titleError(l),
        _detailError(l),
        _daysError(l),
        _nError(l),
        _dueAtError(l),
        _pointsError(l),
        _unitError(l),
      ].every((e) => e == null);

  Map<String, dynamic>? _scheduleJson() {
    if (!_hasSchedule) return null;
    return switch (_schedule) {
      _ScheduleKind.daily => const {'type': 'daily'},
      _ScheduleKind.weekdays => {'type': 'weekdays', 'days': (_days.toList()..sort())},
      _ScheduleKind.everyN => {'type': 'every_n_days', 'n': _nValue ?? 2, 'from': _from},
    };
  }

  /// A one-off's instant: the picked calendar day and clock in the Dynamic's
  /// zone. No clock means the end of that day — one second before the next
  /// day begins at the Dynamic's boundary.
  DateTime? _dueAtInstant() {
    final date = _dueDate;
    if (!_hasDueAt || date == null) return null;
    final clock = _dueClock;
    if (clock != null) {
      return TodayFormat.instantOf(_iso(date), clock.hour, clock.minute, widget.timezone);
    }
    final next = date.add(const Duration(days: 1));
    final h = widget.dayBoundaryMinutes ~/ 60;
    final m = widget.dayBoundaryMinutes % 60;
    return TodayFormat.instantOf(_iso(next), h, m, widget.timezone).subtract(const Duration(seconds: 1));
  }

  NewTask _build() => NewTask(
        title: _title.text.trim(),
        detail: _detail.text.trim().isEmpty ? null : _detail.text.trim(),
        kind: _kind,
        schedule: _scheduleJson(),
        timesPerDay: _hasTimesPerDay ? _timesPerDay : 1,
        dueTime: _hasDueTime && _dueTime != null ? _hhmm(_dueTime!) : null,
        dueAt: _dueAtInstant(),
        proof: _proofLocked ? 'text' : _proof,
        pointsEarn: _pointsValue ?? 0,
        requiresDPresent: _needsD,
        unit: _hasUnit ? _unit.text.trim() : null,
      );

  void _save() {
    final l = L.of(context);
    if (!_valid(l)) {
      setState(() => _checked = true);
      return;
    }
    Navigator.of(context).pop(_build());
  }

  // ── pickers ──────────────────────────────────────────────────────────────

  Future<void> _pickFrom() async {
    final current = _dayOf(_from);
    final first = _dayOf(widget.today).subtract(const Duration(days: 365));
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: first,
      lastDate: first.add(const Duration(days: 730)),
    );
    if (picked == null || !mounted) return;
    setState(() => _from = _iso(picked));
  }

  Future<void> _pickDueTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? const TimeOfDay(hour: 21, minute: 0),
    );
    if (picked == null || !mounted) return;
    setState(() => _dueTime = picked);
  }

  Future<void> _pickDueDate() async {
    final today = _dayOf(widget.today);
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? today,
      firstDate: today.subtract(const Duration(days: 7)),
      lastDate: today.add(const Duration(days: 365)),
    );
    if (picked == null || !mounted) return;
    setState(() => _dueDate = picked);
  }

  Future<void> _pickDueClock() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _dueClock ?? const TimeOfDay(hour: 21, minute: 0),
    );
    if (picked == null || !mounted) return;
    setState(() => _dueClock = picked);
  }

  // ── build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final locale = Localizations.localeOf(context).toString();
    final names = l.rulesWeekdayNames.split(',');
    String? err(String? Function(L) f) => _checked ? f(l) : null;

    return _Frame(
      title: widget.title,
      primaryLabel: widget.primaryLabel ?? l.rulesSave,
      onPrimary: _save,
      children: [
        _Words<String>(
          label: l.rulesTaskKindLabel,
          options: [
            (l.rulesTaskKindRecurring, 'recurring'),
            (l.rulesTaskKindOneOff, 'one_off'),
            (l.rulesTaskKindOpen, 'open'),
            (l.rulesTaskKindCheckin, 'checkin'),
            (l.rulesTaskKindMeasure, 'measure'),
          ],
          value: _kind,
          onPick: (k) => setState(() {
            _kind = k;
            if (k == 'one_off') _dueDate ??= _dayOf(widget.today);
          }),
        ),
        DsTextField(key: const ValueKey('task-title'), label: l.rulesTaskTitleLabel, controller: _title, error: err(_titleError)),
        DsTextField(label: l.rulesTaskDetailLabel, controller: _detail, error: err(_detailError)),

        // ── when
        if (_hasSchedule) ...[
          _Words<_ScheduleKind>(
            label: l.rulesScheduleLabel,
            options: [
              (l.rulesScheduleDaily, _ScheduleKind.daily),
              (l.rulesScheduleWeekdays('').trim(), _ScheduleKind.weekdays),
              (l.rulesEveryNLabel, _ScheduleKind.everyN),
            ],
            value: _schedule,
            onPick: (k) => setState(() => _schedule = k),
          ),
          if (_schedule == _ScheduleKind.weekdays)
            _Field(
              error: err(_daysError),
              child: Wrap(
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
            ),
          if (_schedule == _ScheduleKind.everyN) ...[
            DsTextField(
              label: l.rulesEveryNLabel,
              controller: _n,
              keyboardType: TextInputType.number,
              error: err(_nError),
            ),
            _PickRow(
              label: l.rulesEveryNFrom(TodayFormat.day(_from, locale)),
              onTap: _pickFrom,
            ),
          ],
        ],
        if (_hasTimesPerDay)
          _Stepper(
            label: l.rulesTimesPerDayLabel,
            value: _timesPerDay,
            min: 1,
            max: _maxTimes,
            onChanged: (v) => setState(() => _timesPerDay = v),
          ),
        if (_hasDueTime)
          _PickRow(
            label: l.rulesDueTimeLabel(widget.timezone),
            value: _dueTime == null ? l.rulesDueEndOfDay : _hhmm(_dueTime!),
            onTap: _pickDueTime,
            onClear: _dueTime == null ? null : () => setState(() => _dueTime = null),
            clearLabel: l.rulesDueEndOfDay,
          ),
        if (_hasDueAt)
          _Field(
            error: err(_dueAtError),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.rulesDueAtLabel, style: DsTextStyles.labelRitual.copyWith(color: DsColors.textOnRitualMuted)),
                const SizedBox(height: DsSpacing.space2),
                Wrap(
                  spacing: DsSpacing.space2,
                  runSpacing: DsSpacing.space2,
                  children: [
                    WordButton(
                      label: _dueDate == null ? l.rulesDuePickDate : TodayFormat.day(_iso(_dueDate!), locale),
                      filled: _dueDate != null,
                      onTap: _pickDueDate,
                    ),
                    WordButton(
                      label: _dueClock == null ? l.rulesDueEndOfDay : _hhmm(_dueClock!),
                      filled: _dueClock != null,
                      onTap: _pickDueClock,
                    ),
                    if (_dueClock != null)
                      WordButton(label: l.rulesDueEndOfDay, onTap: () => setState(() => _dueClock = null)),
                  ],
                ),
              ],
            ),
          ),

        // ── how it is handed in
        if (_proofLocked)
          Text(l.rulesProofCheckinOnly, style: DsTextStyles.bodySecondary.copyWith(color: DsColors.textOnRitualMuted))
        else
          _Words<String>(
            label: l.rulesProofLabel,
            options: [
              (l.rulesProofCheck, 'check'),
              (l.rulesProofPhoto, 'photo'),
              (l.rulesProofText, 'text'),
              (l.rulesProofAny, 'any'),
            ],
            value: _proof,
            onPick: (p) => setState(() => _proof = p),
          ),
        if (_hasUnit) DsTextField(label: l.rulesUnitLabel, controller: _unit, error: err(_unitError)),

        // ── points
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DsTextField(
              key: const ValueKey('task-points'),
              label: l.rulesPointsLabel,
              controller: _points,
              keyboardType: TextInputType.number,
              error: err(_pointsError),
            ),
            const SizedBox(height: DsSpacing.space2),
            Text(l.rulesPointsHint, style: DsTextStyles.bodySecondary.copyWith(color: DsColors.textOnRitualMuted)),
          ],
        ),
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

/// A non-text control with the same error line a [DsTextField] has.
class _Field extends StatelessWidget {
  const _Field({required this.child, this.error});
  final Widget child;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        child,
        if (error != null) ...[
          const SizedBox(height: DsSpacing.space2),
          Text(error!, style: DsTextStyles.bodySecondary.copyWith(color: DsColors.stateError)),
        ],
      ],
    );
  }
}

/// A label and, beside it, the current value as a word that opens a picker.
class _PickRow extends StatelessWidget {
  const _PickRow({required this.label, required this.onTap, this.value, this.onClear, this.clearLabel});
  final String label;
  final String? value;
  final VoidCallback onTap;
  final VoidCallback? onClear;
  final String? clearLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: DsTextStyles.labelRitual.copyWith(color: DsColors.textOnRitualMuted)),
        const SizedBox(height: DsSpacing.space2),
        Wrap(
          spacing: DsSpacing.space2,
          runSpacing: DsSpacing.space2,
          children: [
            WordButton(label: value ?? label, filled: value != null, onTap: onTap),
            if (onClear != null && clearLabel != null) WordButton(label: clearLabel!, onTap: onClear!),
          ],
        ),
      ],
    );
  }
}

/// − n +, clamped.
class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });
  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: DsTextStyles.bodyPrimary.copyWith(color: DsColors.textOnRitualPrimary)),
        ),
        WordButton(label: '−', onTap: () => onChanged((value - 1).clamp(min, max))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: DsSpacing.space3),
          child: Text('$value', style: DsTextStyles.bodyPrimary.copyWith(color: DsColors.textOnRitualPrimary)),
        ),
        WordButton(label: '+', onTap: () => onChanged((value + 1).clamp(min, max))),
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
