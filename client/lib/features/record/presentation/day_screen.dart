import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/shell/ds_glyph.dart';
import '../../../app/shell/ds_refreshable.dart';
import '../../../domain/relationship_day.dart';
import '../../../domain_client/api_client.dart';
import '../../../domain_client/models/record.dart';
import '../../../domain_client/models/today_view.dart';
import '../../../domain_client/repositories/today_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../dynamic/application/dynamic_providers.dart' show dynamicViewerIdProvider;
import '../../today/application/today_providers.dart';
import '../../today/presentation/today_format.dart';
import '../../today/presentation/today_screen.dart';
import '../../today/presentation/widgets/choice_sheet.dart';
import '../../today/presentation/widgets/line_sheet.dart';
import '../../today/presentation/widgets/quiet_line.dart';
import '../../today/presentation/widgets/recovery_scaffold.dart';
import '../../today/presentation/widgets/secondary_button.dart';
import '../../today/presentation/widgets/section_label.dart';
import '../../today/presentation/widgets/today_layout.dart';
import '../../today/presentation/widgets/word_button.dart';
import '../application/record_providers.dart';
import 'widgets/timeline_row.dart';

/// 这一天 (product/02-surfaces.md Tab 3): one relationship day, line by line,
/// in the order things happened. Both people may leave a line on it; each
/// keeps a private note only they can read.
///
/// History is repairable here (product/03-domain.md invariant 5): an s may
/// still deliver or explain a `missed` occurrence, and a D may still answer
/// anything the s said — the answer never expires. Both are the same
/// commands 今天 sends, on the same occurrence.
class DayScreen extends ConsumerStatefulWidget {
  const DayScreen({
    super.key,
    required this.dynamicId,
    required this.day,
    this.onBack,
    this.onSignIn,
    this.onOpenSeries,
  });

  final String dynamicId;

  /// `yyyy-MM-dd`.
  final String day;
  final VoidCallback? onBack;
  final VoidCallback? onSignIn;

  /// Opens the curve of a `kind=measure` task: `(taskId, taskTitle)`.
  final void Function(String taskId, String taskTitle)? onOpenSeries;

  @override
  ConsumerState<DayScreen> createState() => _DayScreenState();
}

class _DayScreenState extends ConsumerState<DayScreen> {
  final _comment = TextEditingController();
  final _note = TextEditingController();
  final _noteFocus = FocusNode();

  /// The note as the server last confirmed it, to know whether to write.
  String? _noteSaved;
  bool _noteSeeded = false;
  String? _noteStatus;
  bool _sendingComment = false;
  String? _commentError;

  /// Occurrences with a write in flight, and why the last one failed.
  final _pending = <String>{};
  final _errors = <String, String>{};

  (String, String) get _key => (widget.dynamicId, widget.day);
  TodayRepository get _today => ref.read(todayRepositoryProvider);
  String get _locale => Localizations.localeOf(context).toString();

  @override
  void initState() {
    super.initState();
    _noteFocus.addListener(() {
      if (!_noteFocus.hasFocus) _saveNote();
    });
    _comment.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _comment.dispose();
    _note.dispose();
    _noteFocus.dispose();
    super.dispose();
  }

  void _reloadAll() {
    ref.invalidate(dayViewProvider(_key));
    ref.invalidate(monthCellsProvider);
    ref.invalidate(factsProvider);
    ref.invalidate(recordSummaryProvider(widget.dynamicId));
    ref.invalidate(todayProvider(widget.dynamicId));
  }

  // ---- names --------------------------------------------------------------

  String _partner(TodayView view, L l) => view.partnerDisplayName ?? l.todayPartnerFallback;

  String _nameOf(String? userId, TodayView view, L l) {
    final me = ref.read(dynamicViewerIdProvider);
    if (userId != null && me != null && userId == me) return l.recordMe;
    return _partner(view, l);
  }

  String _sName(TodayView view, L l) => view.side == 'S' ? l.recordMe : _partner(view, l);
  String _dName(TodayView view, L l) => view.side == 'D' ? l.recordMe : _partner(view, l);

  // ---- writes -------------------------------------------------------------

  String _conflictText(Object error, TodayView view) {
    final l = L.of(context);
    return switch (OccurrenceConflict.fromError(error)) {
      OccurrenceConflict.paused => l.sTodayConflictPaused(_partner(view, l)),
      OccurrenceConflict.disposed => l.sTodayConflictDisposed(_partner(view, l)),
      OccurrenceConflict.open => l.sTodayConflictChanged,
      OccurrenceConflict.changed => l.sTodayConflictChanged,
      _ => l.sTodayConflictOther,
    };
  }

  Future<void> _write(String occurrenceId, TodayView view, Future<void> Function() send) async {
    setState(() {
      _pending.add(occurrenceId);
      _errors.remove(occurrenceId);
    });
    try {
      await send();
      _reloadAll();
    } on Object catch (e) {
      if (!mounted) return;
      setState(() => _errors[occurrenceId] = _conflictText(e, view));
      if (OccurrenceConflict.fromError(e) != null) ref.invalidate(dayViewProvider(_key));
    } finally {
      if (mounted) setState(() => _pending.remove(occurrenceId));
    }
  }

  Future<void> _sRepair(OccurrenceState s, TodayView view, Outcome outcome, String sendLabel) async {
    final l = L.of(context);
    final note = await showLineSheet(
      context,
      title: s.title,
      label: l.todayNoteOptional,
      sendLabel: sendLabel,
    );
    if (note == null || !mounted) return;
    await _write(
      s.occurrenceId,
      view,
      () => _today.setOutcome(
        s.occurrenceId,
        OutcomeChange(outcome: outcome, note: note.isEmpty ? null : note),
        idempotencyKey: ApiClient.newIdempotencyKey(),
      ),
    );
  }

  Future<void> _dispose(OccurrenceState s, TodayView view, DispositionChange change) =>
      _write(
        s.occurrenceId,
        view,
        () => _today.setDisposition(
          s.occurrenceId,
          change,
          idempotencyKey: ApiClient.newIdempotencyKey(),
        ),
      );

  Future<void> _praise(OccurrenceState s, TodayView view) async {
    final l = L.of(context);
    final note = await showLineSheet(context, title: s.title, label: l.todayNoteOptional);
    if (note == null || !mounted) return;
    await _dispose(
      s,
      view,
      DispositionChange(disposition: Disposition.praised, note: note.isEmpty ? null : note),
    );
  }

  Future<void> _makeUp(OccurrenceState s, TodayView view) async {
    final l = L.of(context);
    // Making up happens from today on; the day being read may be long past.
    final today = RelationshipDay.parseIsoDay(view.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: today.add(const Duration(days: 1)),
      firstDate: today,
      lastDate: today.add(const Duration(days: 60)),
      helpText: l.dTodayMakeUpWhich,
    );
    if (picked == null || !mounted) return;
    await _dispose(
      s,
      view,
      DispositionChange(disposition: Disposition.makeUp, makeUpDay: RelationshipDay.isoDay(picked)),
    );
  }

  Future<void> _punish(OccurrenceState s, TodayView view) async {
    final l = L.of(context);
    final templates = ref.read(agreementsProvider(widget.dynamicId)).value ?? const [];
    const own = '__own__';
    final chosen = await showChoiceSheet<String>(
      context,
      title: l.dTodayPunishWhich,
      choices: [
        for (final t in templates) (t.consequence, t.id),
        (l.dTodayPunishOwn, own),
      ],
    );
    if (chosen == null || !mounted) return;
    if (chosen != own) {
      final t = templates.firstWhere((t) => t.id == chosen);
      await _dispose(
        s,
        view,
        DispositionChange(
          disposition: Disposition.punished,
          consequenceTemplateId: t.id,
          consequenceTitle: t.consequence,
        ),
      );
      return;
    }
    final title = await showLineSheet(
      context,
      title: l.dTodayPunishTitle,
      label: l.dTodayPunishTitle,
      required: true,
    );
    if (title == null || title.isEmpty || !mounted) return;
    await _dispose(
      s,
      view,
      DispositionChange(disposition: Disposition.punished, consequenceTitle: title),
    );
  }

  List<(String, VoidCallback)> _actionsFor(OccurrenceState s, TodayView view, L l) {
    if (_pending.contains(s.occurrenceId)) return const [];
    if (view.isD) {
      if (!s.dMayDispose) return const [];
      return [
        (
          l.dTodayActionSeen,
          () => _dispose(s, view, const DispositionChange(disposition: Disposition.seen)),
        ),
        (l.dTodayActionPraise, () => _praise(s, view)),
        (
          l.dTodayActionLetGo,
          () => _dispose(s, view, const DispositionChange(disposition: Disposition.letGo)),
        ),
        (l.dTodayActionMakeUp, () => _makeUp(s, view)),
        (l.dTodayActionPunish, () => _punish(s, view)),
      ];
    }
    if (!s.sMayRepair) return const [];
    return [
      (
        l.recordActionDeliverLate,
        () => _sRepair(s, view, Outcome.delivered, l.recordActionDeliverLate),
      ),
      (
        l.recordActionCantDo,
        () => _sRepair(s, view, Outcome.cantDo, l.recordActionCantDo),
      ),
    ];
  }

  Future<void> _sendComment() async {
    final body = _comment.text.trim();
    if (body.isEmpty || _sendingComment) return;
    setState(() {
      _sendingComment = true;
      _commentError = null;
    });
    try {
      await ref.read(recordRepositoryProvider).addComment(
            widget.dynamicId,
            day: widget.day,
            body: body,
            idempotencyKey: ApiClient.newIdempotencyKey(),
          );
      _comment.clear();
      ref.invalidate(dayViewProvider(_key));
      ref.invalidate(monthCellsProvider);
      ref.invalidate(factsProvider);
    } on Object {
      if (!mounted) return;
      setState(() => _commentError = L.of(context).recordCommentFailed);
    } finally {
      if (mounted) setState(() => _sendingComment = false);
    }
  }

  Future<void> _confirmDelete(CommentEntry c) async {
    final l = L.of(context);
    final yes = await showChoiceSheet<bool>(
      context,
      title: l.recordDeleteCommentTitle,
      choices: [(l.recordDelete, true)],
    );
    if (yes != true || !mounted) return;
    try {
      await ref.read(recordRepositoryProvider).deleteComment(c.id);
      ref.invalidate(dayViewProvider(_key));
      ref.invalidate(monthCellsProvider);
      ref.invalidate(factsProvider);
    } on Object {
      if (!mounted) return;
      setState(() => _commentError = L.of(context).sTodayConflictOther);
    }
  }

  Future<void> _saveNote() async {
    if (!_noteSeeded) return;
    final body = _note.text.trim();
    if (body == (_noteSaved ?? '')) return;
    try {
      final stored = await ref
          .read(recordRepositoryProvider)
          .putPrivateNote(widget.dynamicId, day: widget.day, body: body);
      if (!mounted) return;
      setState(() {
        _noteSaved = stored;
        _noteStatus = L.of(context).recordPrivateNoteSaved;
      });
      ref.invalidate(monthCellsProvider);
    } on Object {
      if (!mounted) return;
      setState(() => _noteStatus = L.of(context).recordPrivateNoteFailed);
    }
  }

  void _seedNote(DayView day) {
    if (_noteSeeded) return;
    _noteSeeded = true;
    _noteSaved = day.myPrivateNote;
    _note.text = day.myPrivateNote ?? '';
  }

  // ---- text ---------------------------------------------------------------

  String _reasonText(String reason, L l) => switch (reason) {
        'task_earn' => l.recordReasonTaskEarn,
        'd_award' => l.recordReasonAward,
        'd_deduct' => l.recordReasonDeduct,
        'redemption' => l.recordReasonRedemption,
        'redemption_refund' => l.recordReasonRefund,
        _ => reason,
      };

  /// What the line says, and the words that went with it.
  (String, String?) _textOf(TimelineEntry e, TodayView view, L l) {
    final o = e.outcome;
    if (o != null) {
      final name = _sName(view, l);
      final t = o.taskTitle;
      final text = switch (o.outcome) {
        Outcome.delivered => l.recordDelivered(name, t),
        Outcome.deliveredLate => l.recordDeliveredLate(name, t),
        Outcome.cantDo => l.recordCantDo(name, t),
        Outcome.newTimeRequested => l.recordNewTime(name, t),
        Outcome.discussRequested => l.recordDiscuss(name, t),
        Outcome.open => l.recordWithdrew(name, t),
        Outcome.missed => l.recordMissed(t),
        Outcome.paused => l.recordPausedEntry(t),
      };
      final parts = <String>[];
      if (o.outcome.isDelivered && o.value != null) {
        parts.add('${formatMeasure(o.value!)} ${o.unit ?? ''}'.trim());
      }
      if (o.outcome.isDelivered && o.proofRef != null && o.proofRef!.isNotEmpty) {
        parts.add(o.proofKind == 'photo' ? l.recordPhotoRef(o.proofRef!) : o.proofRef!);
      }
      if (o.note != null && o.note!.isNotEmpty) parts.add(o.note!);
      return (text, parts.isEmpty ? null : parts.join('\n'));
    }
    final d = e.disposition;
    if (d != null) {
      final name = _dName(view, l);
      final t = d.taskTitle;
      final text = switch (d.disposition) {
        Disposition.seen => l.recordSeen(name, t),
        Disposition.praised => l.recordPraised(name, t),
        Disposition.letGo => l.recordLetGo(name, t),
        Disposition.makeUp => l.recordMakeUp(
            name,
            t,
            d.makeUpDay == null ? '' : TodayFormat.day(d.makeUpDay!, _locale),
          ),
        Disposition.punished => l.recordPunished(name, t, d.consequenceTitle ?? ''),
        Disposition.none => l.recordDispositionCleared(name, t),
      };
      return (text, d.note);
    }
    final c = e.comment;
    if (c != null) return (l.recordCommented(_nameOf(c.authorId, view, l)), c.body);
    final p = e.points;
    if (p != null) {
      final reason = _reasonText(p.reason, l);
      if (p.actorUserId == null && p.amount > 0) {
        return (l.recordPointsEarnedAuto(p.amount, reason), p.note);
      }
      final name = _nameOf(p.actorUserId, view, l);
      final text = p.amount >= 0
          ? l.recordPointsAdded(name, p.amount)
          : l.recordPointsDeducted(name, -p.amount);
      return (text, [reason, if (p.note != null && p.note!.isNotEmpty) p.note!].join(' · '));
    }
    final r = e.redemption;
    if (r != null) return (l.recordRedeemed(_nameOf(r.subjectUserId, view, l), r.rewardTitle), null);
    return (e.kind, null);
  }

  // ---- build --------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final today = ref.watch(todayProvider(widget.dynamicId));
    final day = ref.watch(dayViewProvider(_key));

    Future<void> refresh() => Future.wait([
          ref.refresh(todayProvider(widget.dynamicId).future),
          ref.refresh(dayViewProvider(_key).future),
        ]);

    Widget body;
    if (today.hasValue && day.hasValue) {
      _seedNote(day.value!);
      body = _body(today.value!, day.value!, l);
    } else if (today.hasError || day.hasError) {
      final error = today.error ?? day.error!;
      body = switch (classifyFailure(error)) {
        TodayFailure.authorizationLost => RecoveryScaffold(
            context_: l.recoveryConfirmingContext,
            children: [
              const SizedBox(height: DsSpacing.space8),
              RecoveryMessage(l.recoverySessionRestore, prominent: true),
              const SizedBox(height: DsSpacing.space6),
              Padding(
                padding: todayInset,
                child: SecondaryButton(
                  label: l.recoverySignInAgain,
                  onTap: widget.onSignIn ?? () {},
                  filled: true,
                ),
              ),
            ],
          ),
        _ => RecoveryScaffold(
            context_: l.recoveryNotConfirmed,
            children: [
              const SizedBox(height: DsSpacing.space8),
              RecoveryMessage(l.recordDayCouldNotLoad, prominent: true),
              const SizedBox(height: DsSpacing.space6),
              Padding(
                padding: todayInset,
                child: SecondaryButton(
                  label: l.recoveryTryAgain,
                  onTap: () {
                    ref.invalidate(todayProvider(widget.dynamicId));
                    ref.invalidate(dayViewProvider(_key));
                  },
                ),
              ),
            ],
          ),
      };
    } else {
      body = const TodayLoading();
    }

    return Scaffold(
      backgroundColor: DsColors.canvasRitual,
      body: DsRitualSurface(
        child: SafeArea(
          child: DsRefreshable(onRefresh: refresh, child: body),
        ),
      ),
    );
  }

  Widget _header(L l) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DsSpacing.space2,
        DsSpacing.space3,
        DsSpacing.space5,
        DsSpacing.space4,
      ),
      child: Row(
        children: [
          Semantics(
            button: true,
            label: l.recordBack,
            child: InkWell(
              onTap: widget.onBack,
              borderRadius: BorderRadius.circular(24),
              child: const SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: DsGlyphIcon(DsGlyph.back, size: 22, color: DsColors.textOnRitualSecondary),
                ),
              ),
            ),
          ),
          const SizedBox(width: DsSpacing.space1),
          Expanded(
            child: Text(
              TodayFormat.dayLong(widget.day, _locale),
              style: DsTextStyles.titlePage.copyWith(
                color: DsColors.textOnRitualPrimary,
                fontSize: 23,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _body(TodayView view, DayView day, L l) {
    final states = day.occurrenceStates;
    final lastIndex = day.lastEntryIndexByOccurrence;
    final me = ref.watch(dynamicViewerIdProvider);

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _header(l),
        if (day.timeline.isEmpty) QuietLine(l.recordDayEmpty),
        for (var i = 0; i < day.timeline.length; i++)
          () {
            final e = day.timeline[i];
            final (text, sub) = _textOf(e, view, l);
            final occId = e.outcome?.occurrenceId ?? e.disposition?.occurrenceId;
            final state = occId != null && lastIndex[occId] == i ? states[occId] : null;
            final comment = e.comment;
            final o = e.outcome;
            final openSeries = widget.onOpenSeries;
            return TimelineRow(
              key: ValueKey('tl-$i'),
              clock: TodayFormat.clock(e.at, view.timezone, _locale),
              text: text,
              sub: sub,
              error: occId == null ? null : _errors[occId],
              actions: [
                if (state != null) ..._actionsFor(state, view, l),
                if (o != null && o.value != null && o.outcome.isDelivered && openSeries != null)
                  (l.recordSeriesAction, () => openSeries(o.taskId, o.taskTitle)),
              ],
              onLongPress: comment != null && me != null && comment.authorId == me
                  ? () => _confirmDelete(comment)
                  : null,
            );
          }(),
        const SizedBox(height: DsSpacing.space8),
        SectionLabel(l.recordComments),
        Padding(
          padding: todayInset,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  key: const ValueKey('comment-field'),
                  controller: _comment,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendComment(),
                  style: DsTextStyles.bodyPrimary.copyWith(color: DsColors.textOnRitualPrimary),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: l.recordCommentHint,
                    hintStyle: DsTextStyles.bodySecondary.copyWith(color: DsColors.textOnRitualMuted),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: DsColors.borderOnRitualHairline),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: DsColors.borderOnRitualStrong),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: DsSpacing.space3),
              if (_comment.text.trim().isNotEmpty && !_sendingComment)
                WordButton(label: l.todaySend, onTap: _sendComment, filled: true),
            ],
          ),
        ),
        if (_commentError != null)
          Padding(
            padding: todayInset.add(const EdgeInsets.only(top: DsSpacing.space2)),
            child: Text(
              _commentError!,
              style: DsTextStyles.bodySecondary.copyWith(color: DsColors.stateError),
            ),
          ),
        const SizedBox(height: DsSpacing.space8),
        SectionLabel(l.recordPrivateNote),
        Padding(
          padding: todayInset,
          child: TextField(
            key: const ValueKey('private-note-field'),
            controller: _note,
            focusNode: _noteFocus,
            minLines: 2,
            maxLines: 8,
            style: DsTextStyles.bodyPrimary.copyWith(color: DsColors.textOnRitualPrimary),
            decoration: InputDecoration(
              isDense: true,
              hintText: l.recordPrivateNoteHint,
              hintStyle: DsTextStyles.bodySecondary.copyWith(color: DsColors.textOnRitualMuted),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: DsColors.borderOnRitualHairline),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: DsColors.borderOnRitualStrong),
              ),
            ),
          ),
        ),
        if (_noteStatus != null)
          Padding(
            padding: todayInset.add(const EdgeInsets.only(top: DsSpacing.space2)),
            child: Text(
              _noteStatus!,
              style: DsTextStyles.bodySecondary.copyWith(color: DsColors.textOnRitualMuted),
            ),
          ),
        const SizedBox(height: DsSpacing.space10),
      ],
    );
  }
}
