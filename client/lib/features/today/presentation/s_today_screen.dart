import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/shell/page_hero.dart';
import '../../../app/providers.dart';
import '../../../platform/media/proof_picker.dart';
import '../../../domain_client/api_client.dart';
import '../../../domain_client/models/today_view.dart';
import '../../../domain_client/repositories/today_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../application/today_providers.dart';
import 'today_format.dart';
import 'widgets/choice_sheet.dart';
import 'widgets/line_sheet.dart';
import 'widgets/measure_sheet.dart';
import 'widgets/quiet_line.dart';
import 'widgets/s_occurrence_row.dart';
import 'widgets/section_label.dart';
import 'widgets/today_header.dart';
import 'widgets/today_layout.dart';
import 'widgets/word_button.dart';

/// The s face of 今天 (product/02-surfaces.md §Tab 1, s).
///
/// Order: the check-in, then what has a time, then the rest of the day, then
/// the things the s may do whenever. Delivery is optimistic — the row says
/// 已送到 at once and steps back if the server refuses (409).
class STodayScreen extends ConsumerStatefulWidget {
  const STodayScreen({
    super.key,
    required this.view,
    required this.dynamicId,
    this.onSettings,
    this.onNotifications,
    this.unread = 0,
    this.notice,
    this.onRules,
  });

  final TodayView view;
  final String dynamicId;
  final VoidCallback? onSettings;
  final VoidCallback? onNotifications;
  final int unread;

  /// The Dynamic's own state — paused, D away, partner not joined — shown
  /// between the day's meta and its list. Built by the frame, which is the
  /// only place that watches the Dynamic detail.
  final Widget? notice;

  /// An empty day offers the rules as the one place to look.
  final VoidCallback? onRules;

  @override
  ConsumerState<STodayScreen> createState() => _STodayScreenState();
}

class _STodayScreenState extends ConsumerState<STodayScreen> {
  /// What the s just said, shown before the server has confirmed it.
  final _pending = <String, Outcome>{};

  /// Open tasks the s just delivered, until the next read shows them as items.
  final _openDelivered = <String>{};

  /// Why the last attempt on a row did not go through.
  final _errors = <String, String>{};

  String? _expanded;

  @override
  void didUpdateWidget(covariant STodayScreen old) {
    super.didUpdateWidget(old);
    if (old.view != widget.view) {
      _pending.clear();
      _openDelivered.clear();
    }
  }

  TodayRepository get _repo => ref.read(todayRepositoryProvider);
  String get _partner =>
      widget.view.partnerDisplayName ?? L.of(context).todayPartnerFallback;
  String get _locale => Localizations.localeOf(context).toString();

  void _reload() => ref.invalidate(todayProvider(widget.dynamicId));

  String _conflictText(Object error) {
    final l = L.of(context);
    return switch (OccurrenceConflict.fromError(error)) {
      OccurrenceConflict.paused => l.sTodayConflictPaused(_partner),
      OccurrenceConflict.disposed => l.sTodayConflictDisposed(_partner),
      OccurrenceConflict.changed => l.sTodayConflictChanged,
      _ => l.sTodayConflictOther,
    };
  }

  Future<void> _say(OccurrenceView occ, OutcomeChange change) async {
    setState(() {
      _pending[occ.id] = change.outcome;
      _errors.remove(occ.id);
      _expanded = null;
    });
    try {
      await _repo.setOutcome(
        occ.id,
        change,
        idempotencyKey: ApiClient.newIdempotencyKey(),
      );
      _reload();
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _pending.remove(occ.id);
        _errors[occ.id] = _conflictText(e);
      });
      if (OccurrenceConflict.fromError(e) != null) _reload();
    }
  }

  /// Proof, when the task asks for it.
  ///
  /// `photo` offers the camera or the gallery; the picture is uploaded first
  /// and the delivery carries its media id. `text` needs a line, sent as the
  /// note. `any` lets the s choose either. Null means they backed out.
  Future<_Proof?> _proofFor(String proof, String title) async {
    final l = L.of(context);
    switch (proof) {
      case 'text':
        final line = await showLineSheet(
          context,
          title: title,
          label: l.sTodayWriteLine,
          required: true,
        );
        return line == null ? null : _Proof.text(line);
      case 'photo':
      case 'any':
        final chosen = await showChoiceSheet<_ProofChoice>(
          context,
          title: title,
          choices: [
            (l.sTodayProofCamera, _ProofChoice.camera),
            (l.sTodayProofGallery, _ProofChoice.gallery),
            if (proof == 'any') (l.sTodayWriteLine, _ProofChoice.text),
          ],
        );
        if (chosen == null || !mounted) return null;
        if (chosen == _ProofChoice.text) return _proofFor('text', title);
        return _photoProof(
          chosen == _ProofChoice.camera ? ProofSource.camera : ProofSource.gallery,
        );
      default:
        return const _Proof.none();
    }
  }

  Future<_Proof?> _photoProof(ProofSource source) async {
    final bytes = await ref.read(proofPickerProvider).pick(source);
    if (bytes == null || !mounted) return null;
    final upload = await ref.read(mediaRepositoryProvider).upload(widget.dynamicId, bytes);
    return _Proof.photo(upload.id);
  }

  Future<void> _deliver(OccurrenceView occ) async {
    double? value;
    if (occ.isMeasure) {
      value = await showMeasureSheet(context, title: occ.title, unit: occ.unit);
      if (value == null || !mounted) return;
    }
    final _Proof? proof;
    try {
      proof = await _proofFor(occ.proof, occ.title);
    } on Object {
      if (!mounted) return;
      setState(() => _errors[occ.id] = L.of(context).sTodayPhotoFailed);
      return;
    }
    if (proof == null || !mounted) return;
    await _say(
      occ,
      OutcomeChange(
        outcome: Outcome.delivered,
        note: proof.note,
        proofKind: proof.kind,
        proofRef: proof.ref,
        value: value,
      ),
    );
  }

  Future<void> _deliverOpen(OpenTaskView task) async {
    final _Proof? proof;
    try {
      proof = await _proofFor(task.proof, task.title);
    } on Object {
      if (!mounted) return;
      setState(() => _errors[task.id] = L.of(context).sTodayPhotoFailed);
      return;
    }
    if (proof == null || !mounted) return;
    setState(() {
      _openDelivered.add(task.id);
      _errors.remove(task.id);
    });
    try {
      await ref.read(taskRepositoryProvider).deliverOpen(
            widget.dynamicId,
            task.id,
            note: proof.note,
            proofKind: proof.kind,
            proofRef: proof.ref,
            idempotencyKey: ApiClient.newIdempotencyKey(),
          );
      _reload();
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _openDelivered.remove(task.id);
        _errors[task.id] = _conflictText(e);
      });
    }
  }

  Future<void> _sayWithNote(OccurrenceView occ, Outcome outcome) async {
    final l = L.of(context);
    final note = await showLineSheet(
      context,
      title: occ.title,
      label: l.todayNoteOptional,
    );
    if (note == null || !mounted) return;
    await _say(
      occ,
      OutcomeChange(outcome: outcome, note: note.isEmpty ? null : note),
    );
  }

  Future<void> _askNewTime(OccurrenceView occ) async {
    final l = L.of(context);
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: l.sTodayPickTime,
    );
    if (picked == null || !mounted) return;
    final proposed = TodayFormat.instantOf(
      occ.day,
      picked.hour,
      picked.minute,
      widget.view.timezone,
    );
    await _say(
      occ,
      OutcomeChange(outcome: Outcome.newTimeRequested, proposedTime: proposed),
    );
  }

  Future<void> _showActions(OccurrenceView occ) async {
    final l = L.of(context);
    final choices = _actionsFor(occ, l);
    if (choices.isEmpty) return;
    final chosen = await showChoiceSheet<VoidCallback>(
      context,
      title: occ.title,
      choices: choices,
    );
    chosen?.call();
  }

  List<(String, VoidCallback)> _actionsFor(OccurrenceView occ, L l) {
    final outcome = _pending[occ.id] ?? occ.outcome;
    if (_pending.containsKey(occ.id)) return const [];
    if (occ.disposition != Disposition.none) return const [];
    if (outcome == Outcome.paused) return const [];
    if (outcome.saidByS) {
      return [
        (
          l.sTodayActionWithdraw,
          () => _say(occ, const OutcomeChange(outcome: Outcome.open)),
        ),
      ];
    }
    return [
      (l.sTodayActionDeliver, () => _deliver(occ)),
      (l.sTodayActionCantDo, () => _sayWithNote(occ, Outcome.cantDo)),
      (l.sTodayActionNewTime, () => _askNewTime(occ)),
      (l.sTodayActionDiscuss, () => _sayWithNote(occ, Outcome.discussRequested)),
    ];
  }

  /// What the row says beneath the title: the D's word if there is one, else
  /// the s's own.
  String? _statusOf(OccurrenceView occ, L l) {
    final zone = widget.view.timezone;
    final name = _partner;
    switch (occ.disposition) {
      case Disposition.seen:
        final at = occ.dispositionAt ?? occ.seenAt;
        return l.sTodaySeen(
          name,
          at == null ? '' : TodayFormat.clock(at, zone, _locale),
        );
      case Disposition.praised:
        final note = occ.dispositionNote;
        return note == null || note.isEmpty
            ? l.sTodayPraised(name)
            : l.sTodayPraisedNote(name, note);
      case Disposition.letGo:
        return l.sTodayLetGo(name);
      case Disposition.makeUp:
        final day = occ.makeUpDay;
        return l.sTodayMakeUp(
          name,
          day == null ? '' : TodayFormat.day(day, _locale),
        );
      case Disposition.punished:
        return l.sTodayPunished(name, occ.consequence?.title ?? '');
      case Disposition.none:
        break;
    }
    final outcome = _pending[occ.id] ?? occ.outcome;
    return switch (outcome) {
      Outcome.open => null,
      Outcome.delivered => l.sTodayDelivered(name),
      Outcome.deliveredLate => l.sTodayDeliveredLate(name),
      Outcome.cantDo => l.sTodayCantDo,
      Outcome.newTimeRequested => l.sTodayNewTime(
          occ.proposedTime == null
              ? ''
              : TodayFormat.clock(occ.proposedTime!, zone, _locale),
        ),
      Outcome.discussRequested => l.sTodayDiscuss,
      Outcome.missed => l.sTodayMissed,
      Outcome.paused => l.sTodayPaused(name),
    };
  }

  String? _metaOf(OccurrenceView occ, L l) {
    final parts = <String>[];
    if (occ.dueAt != null) {
      parts.add(l.todayDueBy(TodayFormat.clock(occ.dueAt!, widget.view.timezone, _locale)));
    }
    if (occ.pointsEarn > 0) parts.add(l.todayPointsEarn(occ.pointsEarn));
    return parts.isEmpty ? null : parts.join(' · ');
  }

  Widget _row(OccurrenceView occ, L l) {
    final outcome = _pending[occ.id] ?? occ.outcome;
    final paused = outcome == Outcome.paused;
    final actionable = !paused && occ.disposition == Disposition.none && !_pending.containsKey(occ.id);
    final canDeliver = actionable && (outcome == Outcome.open || outcome == Outcome.missed);
    final status = _statusOf(occ, l);
    final value = occ.value;
    final measured = value == null || !outcome.isDelivered
        ? null
        : '${formatMeasure(value)} ${occ.unit ?? ''}'.trim();
    return SOccurrenceRow(
      key: ValueKey(occ.id),
      title: occ.title,
      detail: occ.detail,
      meta: _metaOf(occ, l),
      status: measured == null ? status : [?status, measured].join(' · '),
      note: occ.outcomeNote == null || occ.outcomeNote!.isEmpty
          ? null
          : l.sTodayYourNote(occ.outcomeNote!),
      error: _errors[occ.id],
      photoId: occ.proofKind == 'photo' && outcome.isDelivered ? occ.proofRef : null,
      muted: paused,
      expanded: _expanded == occ.id,
      actions: _actionsFor(occ, l),
      onTap: !actionable
          ? null
          : canDeliver
              ? () => _deliver(occ)
              : () => setState(() => _expanded = _expanded == occ.id ? null : occ.id),
      onLongPress: actionable ? () => _showActions(occ) : null,
    );
  }

  Widget _openRow(OpenTaskView task, L l) {
    final delivered = _openDelivered.contains(task.id);
    return SOccurrenceRow(
      key: ValueKey('open-${task.id}'),
      title: task.title,
      detail: task.detail,
      meta: task.pointsEarn > 0 ? l.todayPointsEarn(task.pointsEarn) : null,
      status: delivered ? l.sTodayDelivered(_partner) : null,
      error: _errors[task.id],
      onTap: delivered ? null : () => _deliverOpen(task),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final view = widget.view;

    final checkins = view.items.where((o) => o.isCheckin).toList();
    final timed = view.items.where((o) => !o.isCheckin && o.dueAt != null).toList()
      ..sort((a, b) => a.dueAt!.compareTo(b.dueAt!));
    final rest = view.items.where((o) => !o.isCheckin && o.dueAt == null).toList();
    final empty = view.items.isEmpty && view.openTasks.isEmpty;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        TodayHeader(
          partnerName: view.partnerDisplayName,
          onSettings: widget.onSettings,
          onNotifications: widget.onNotifications,
          unread: widget.unread,
        ),
        PageHero(
          eyebrow: l.todayHeroEyebrow(
            TodayFormat.weekday(view.day, _locale),
            TodayFormat.minutesClock(view.dayBoundaryMinutes, _locale),
          ),
          hero: TodayFormat.dayHero(view.day, _locale),
          heroKey: const ValueKey('today-hero'),
          support: '${l.todayBalance(view.balance)} · ${l.todayDaysTogether(view.daysTogether)}',
        ),
        const SizedBox(height: DsSpacing.space8),
        ?widget.notice,
        if (empty) ...[
          QuietLine(l.sTodayEmpty),
          if (widget.onRules case final rules?)
            Padding(
              padding: todayInset,
              child: Align(
                alignment: Alignment.centerLeft,
                child: WordButton(label: l.sTodayEmptyRules, onTap: rules),
              ),
            ),
        ],
        if (checkins.isNotEmpty) ...[
          SectionLabel(l.sTodaySectionCheckin),
          for (final o in checkins) _row(o, l),
          const SizedBox(height: DsSpacing.space6),
        ],
        if (timed.isNotEmpty || rest.isNotEmpty) ...[
          SectionLabel(l.sTodaySectionList),
          for (final o in timed) _row(o, l),
          for (final o in rest) _row(o, l),
          const SizedBox(height: DsSpacing.space6),
        ],
        if (view.openTasks.isNotEmpty) ...[
          SectionLabel(l.sTodaySectionOpen),
          for (final t in view.openTasks) _openRow(t, l),
        ],
        const SizedBox(height: DsSpacing.space10),
      ],
    );
  }
}

enum _ProofChoice { camera, gallery, text }

/// What goes with a delivery: a media id, a line, or nothing.
class _Proof {
  const _Proof.none() : kind = null, ref = null, note = null;
  const _Proof.photo(String mediaId) : kind = 'photo', ref = mediaId, note = null;
  const _Proof.text(String line) : kind = 'text', ref = null, note = line;

  final String? kind;
  final String? ref;
  final String? note;
}
