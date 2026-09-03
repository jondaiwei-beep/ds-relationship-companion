import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/shell/ds_skeleton.dart';
import '../../../domain/relationship_day.dart';
import '../../../domain_client/api_client.dart';
import '../../../domain_client/models/d_note.dart';
import '../../../domain_client/models/task.dart';
import '../../../domain_client/models/today_view.dart';
import '../../../domain_client/repositories/today_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../application/today_providers.dart';
import 'today_format.dart';
import 'widgets/choice_sheet.dart';
import 'widgets/d_needs_me_row.dart';
import 'widgets/d_notes_section.dart';
import 'widgets/d_quick_add.dart';
import 'widgets/line_sheet.dart';
import 'widgets/quiet_line.dart';
import 'widgets/section_label.dart';
import 'widgets/today_header.dart';
import 'widgets/today_layout.dart';
import 'widgets/today_meta.dart';

/// The D face of 今天 (product/02-surfaces.md §Tab 1, D).
///
/// What waits for the D comes first and stays until the D answers; nothing
/// here expires or is answered on the D's behalf. Then the shape of the s's
/// day, a way to add one thing, and the D's own notes.
class DTodayScreen extends ConsumerStatefulWidget {
  const DTodayScreen({
    super.key,
    required this.view,
    required this.dynamicId,
    this.onSettings,
  });

  final TodayView view;
  final String dynamicId;
  final VoidCallback? onSettings;

  @override
  ConsumerState<DTodayScreen> createState() => _DTodayScreenState();
}

class _DTodayScreenState extends ConsumerState<DTodayScreen> {
  /// Rows the D has just answered, hidden until the next read agrees.
  final _disposed = <String>{};
  final _errors = <String, String>{};

  /// Receipts already sent this session, so opening twice posts once.
  final _seenSent = <String>{};
  String? _expanded;

  TodayRepository get _repo => ref.read(todayRepositoryProvider);
  String get _partner =>
      widget.view.partnerDisplayName ?? L.of(context).todayPartnerFallback;
  String get _locale => Localizations.localeOf(context).toString();
  String get _zone => widget.view.timezone;

  void _reloadNeedsMe() {
    ref.invalidate(needsMeProvider(widget.dynamicId));
    ref.invalidate(todayProvider(widget.dynamicId));
  }

  String _conflictText(Object error) {
    final l = L.of(context);
    return switch (OccurrenceConflict.fromError(error)) {
      OccurrenceConflict.open => l.dTodayConflictOpen,
      OccurrenceConflict.paused => l.dTodayConflictPaused,
      OccurrenceConflict.changed => l.dTodayConflictChanged,
      _ => l.dTodayConflictOther,
    };
  }

  /// Opening the row is the receipt. Sent once, never keyed.
  void _open(OccurrenceView occ) {
    setState(() => _expanded = _expanded == occ.id ? null : occ.id);
    if (occ.seenAt == null && _seenSent.add(occ.id)) {
      _repo.markSeen(occ.id).catchError((Object _) {
        _seenSent.remove(occ.id);
        return null;
      });
    }
  }

  Future<void> _dispose(OccurrenceView occ, DispositionChange change) async {
    setState(() {
      _disposed.add(occ.id);
      _errors.remove(occ.id);
      _expanded = null;
    });
    try {
      await _repo.setDisposition(
        occ.id,
        change,
        idempotencyKey: ApiClient.newIdempotencyKey(),
      );
      _reloadNeedsMe();
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _disposed.remove(occ.id);
        _errors[occ.id] = _conflictText(e);
      });
      if (OccurrenceConflict.fromError(e) != null) _reloadNeedsMe();
    }
  }

  Future<void> _praise(OccurrenceView occ) async {
    final l = L.of(context);
    final note = await showLineSheet(context, title: occ.title, label: l.todayNoteOptional);
    if (note == null || !mounted) return;
    await _dispose(
      occ,
      DispositionChange(disposition: Disposition.praised, note: note.isEmpty ? null : note),
    );
  }

  Future<void> _makeUp(OccurrenceView occ) async {
    final l = L.of(context);
    final today = RelationshipDay.parseIsoDay(widget.view.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: today.add(const Duration(days: 1)),
      firstDate: today,
      lastDate: today.add(const Duration(days: 60)),
      helpText: l.dTodayMakeUpWhich,
    );
    if (picked == null || !mounted) return;
    await _dispose(
      occ,
      DispositionChange(
        disposition: Disposition.makeUp,
        makeUpDay: RelationshipDay.isoDay(picked),
      ),
    );
  }

  Future<void> _punish(OccurrenceView occ) async {
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
        occ,
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
      occ,
      DispositionChange(disposition: Disposition.punished, consequenceTitle: title),
    );
  }

  List<(String, VoidCallback)> _actionsFor(OccurrenceView occ, L l) => [
        (
          l.dTodayActionSeen,
          () => _dispose(occ, const DispositionChange(disposition: Disposition.seen)),
        ),
        (l.dTodayActionPraise, () => _praise(occ)),
        (
          l.dTodayActionLetGo,
          () => _dispose(occ, const DispositionChange(disposition: Disposition.letGo)),
        ),
        (l.dTodayActionMakeUp, () => _makeUp(occ)),
        (l.dTodayActionPunish, () => _punish(occ)),
      ];

  String _saidOf(OccurrenceView occ, L l) {
    String clock(DateTime? t) => t == null ? '' : TodayFormat.clock(t, _zone, _locale);
    return switch (occ.outcome) {
      Outcome.delivered => l.dTodaySaidDelivered(clock(occ.outcomeAt)),
      Outcome.deliveredLate => l.dTodaySaidLate(clock(occ.outcomeAt)),
      Outcome.cantDo => l.dTodaySaidCantDo,
      Outcome.newTimeRequested => l.dTodaySaidNewTime(clock(occ.proposedTime)),
      Outcome.discussRequested => l.dTodaySaidDiscuss,
      Outcome.missed => l.dTodaySaidMissed,
      Outcome.open || Outcome.paused => '',
    };
  }

  Widget _needsMeRow(OccurrenceView occ, L l) {
    return DNeedsMeRow(
      key: ValueKey(occ.id),
      title: occ.title,
      said: _saidOf(occ, l),
      day: occ.day == widget.view.day ? null : l.dTodayOnDay(TodayFormat.day(occ.day, _locale)),
      note: occ.outcomeNote == null || occ.outcomeNote!.isEmpty
          ? null
          : l.dTodaySaidNote(_partner, occ.outcomeNote!),
      proof: occ.proofKind == 'photo' && occ.proofRef != null
          ? l.dTodayProofPhoto(occ.proofRef!)
          : (occ.proofKind == 'text' ? occ.proofRef : null),
      error: _errors[occ.id],
      expanded: _expanded == occ.id,
      actions: _actionsFor(occ, l),
      onTap: () => _open(occ),
    );
  }

  Widget _overview(L l) {
    final items = widget.view.items;
    if (items.isEmpty) return const SizedBox.shrink();
    final delivered = items.where((o) => o.outcome.isDelivered).length;
    final flagged = items
        .where((o) =>
            o.outcome == Outcome.cantDo ||
            o.outcome == Outcome.newTimeRequested ||
            o.outcome == Outcome.discussRequested)
        .length;
    final style = DsTextStyles.bodyPrimary.copyWith(color: DsColors.textOnRitualSecondary);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(l.dTodaySectionOverview(_partner)),
        Padding(
          padding: todayInset,
          child: Text(l.dTodayOverviewDelivered(delivered, items.length), style: style),
        ),
        if (flagged > 0)
          Padding(
            padding: todayInset.add(const EdgeInsets.only(top: DsSpacing.space1)),
            child: Text(l.dTodayOverviewFlagged(flagged), style: style),
          ),
        const SizedBox(height: DsSpacing.space8),
      ],
    );
  }

  Future<void> _addTask(NewTask task) async {
    await ref.read(taskRepositoryProvider).create(
          widget.dynamicId,
          task,
          idempotencyKey: ApiClient.newIdempotencyKey(),
        );
    ref.invalidate(todayProvider(widget.dynamicId));
  }

  Future<void> _addNote(String body, DateTime? remindAt) async {
    await ref.read(dNoteRepositoryProvider).create(
          widget.dynamicId,
          body: body,
          remindAt: remindAt,
          idempotencyKey: ApiClient.newIdempotencyKey(),
        );
    ref.invalidate(dNotesProvider(widget.dynamicId));
  }

  Future<void> _noteDone(DNote n) async {
    try {
      await ref.read(dNoteRepositoryProvider).done(n.id);
    } finally {
      ref.invalidate(dNotesProvider(widget.dynamicId));
    }
  }

  Future<void> _noteDelete(DNote n) async {
    try {
      await ref.read(dNoteRepositoryProvider).delete(n.id);
    } finally {
      ref.invalidate(dNotesProvider(widget.dynamicId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final view = widget.view;
    final needsMe = ref.watch(needsMeProvider(widget.dynamicId));
    final notes = ref.watch(dNotesProvider(widget.dynamicId));

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        TodayHeader(
          title: l.todayTitle,
          partnerName: view.partnerDisplayName,
          onSettings: widget.onSettings,
        ),
        const SizedBox(height: DsSpacing.space4),
        TodayMeta(view: view),
        const SizedBox(height: DsSpacing.space8),
        SectionLabel(l.dTodaySectionNeedsMe),
        needsMe.when(
          skipLoadingOnReload: true,
          skipLoadingOnRefresh: true,
          loading: () => const Padding(
            padding: todayInset,
            child: DsSkeletonCard(lines: [0.7, 0.4]),
          ),
          error: (_, _) => QuietLine(l.dTodayConflictOther),
          data: (rows) {
            final visible = rows.where((o) => !_disposed.contains(o.id)).toList();
            if (visible.isEmpty) return QuietLine(l.dTodayEmpty);
            return Column(children: [for (final o in visible) _needsMeRow(o, l)]);
          },
        ),
        const SizedBox(height: DsSpacing.space8),
        _overview(l),
        SectionLabel(l.dTodaySectionQuickAdd),
        DQuickAdd(onAdd: _addTask),
        const SizedBox(height: DsSpacing.space8),
        SectionLabel(l.dTodaySectionNotes),
        notes.when(
          skipLoadingOnReload: true,
          skipLoadingOnRefresh: true,
          loading: () => const Padding(padding: todayInset, child: DsSkeletonBar(widthFactor: 0.5)),
          error: (_, _) => const SizedBox.shrink(),
          data: (list) => DNotesSection(
            notes: list,
            timezone: view.timezone,
            onAdd: _addNote,
            onDone: _noteDone,
            onDelete: _noteDelete,
          ),
        ),
        const SizedBox(height: DsSpacing.space10),
      ],
    );
  }
}
