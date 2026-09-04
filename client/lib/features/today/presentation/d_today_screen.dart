import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/shell/ds_skeleton.dart';
import '../../../app/shell/page_hero.dart';
import '../../../domain/relationship_day.dart';
import '../../../domain_client/api_client.dart';
import '../../../domain_client/models/d_note.dart';
import '../../../domain_client/models/task.dart';
import '../../../domain_client/models/today_view.dart';
import '../../../domain_client/repositories/today_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../../domain_client/models/explore.dart';
import '../../dynamic/application/dynamic_providers.dart';
import '../../explore/application/explore_providers.dart';
import '../../explore/presentation/widgets/idea_card_sheet.dart';
import '../../rules/application/rules_providers.dart';
import '../../rules/presentation/widgets/rules_sheets.dart';
import 'widgets/word_button.dart';
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
    this.onNotifications,
    this.unread = 0,
    this.notice,
    this.alone = false,
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

  /// The partner has not joined. Nothing that needs two people is shown as a
  /// zero; it is named as not started (redesign-2026-09 §3).
  final bool alone;

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

  /// 「今晚要什么？」 in flight. Drawing tells the s nothing; only turning the
  /// card into a task does, through the ordinary task path.
  bool _drawing = false;
  String? _drawNotice;

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
      proof: occ.proofKind == 'text' ? occ.proofRef : null,
      photoId: occ.proofKind == 'photo' ? occ.proofRef : null,
      error: _errors[occ.id],
      expanded: _expanded == occ.id,
      actions: _actionsFor(occ, l),
      onTap: () => _open(occ),
    );
  }

  String _stateWord(OccurrenceView occ, L l) =>
      occ.outcome == Outcome.open || occ.outcome == Outcome.paused ? l.dTodayItemOpen : _saidOf(occ, l);

  /// The shape of the s's day: every item by name with one word of state, and
  /// the count under it. A count alone ("0/2 delivered") told the D nothing
  /// about what the two were.
  Widget _overview(L l) {
    final items = widget.view.items;
    if (items.isEmpty) return const SizedBox.shrink();
    final delivered = items.where((o) => o.outcome.isDelivered).length;
    final title = DsTextStyles.bodyPrimary.copyWith(color: DsColors.textOnRitualPrimary);
    final state = DsTextStyles.bodySecondary.copyWith(color: DsColors.textOnRitualMuted);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(l.dTodaySectionOverview(_partner)),
        for (final o in items)
          Padding(
            padding: todayInset.add(const EdgeInsets.symmetric(vertical: DsSpacing.space2)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Text(o.title, style: title)),
                const SizedBox(width: DsSpacing.space3),
                Text(_stateWord(o, l), style: state),
              ],
            ),
          ),
        Padding(
          padding: todayInset.add(const EdgeInsets.only(top: DsSpacing.space2)),
          child: Text(l.dTodayOverviewDelivered(delivered, items.length), style: state),
        ),
        const SizedBox(height: DsSpacing.space8),
      ],
    );
  }

  /// 更多设置: the full editor from 规矩, seeded with the quick line.
  Future<bool> _addTaskFully(TodayView view, NewTask draft) async {
    final l = L.of(context);
    final task = await showTaskSheet(
      context,
      title: l.rulesAddTask,
      dName: l.rulesYou,
      timezone: view.timezone,
      today: view.day,
      dayBoundaryMinutes: view.dayBoundaryMinutes,
      draft: draft,
    );
    if (task == null || !mounted) return false;
    await _addTask(task);
    return true;
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

  // ── away (D-26) ──────────────────────────────────────────────────────────
  // Moved here from 规矩: it is the state of the day, not a rule.

  Future<void> _away() async {
    final v = widget.view;
    final now = DateTime.now();
    final first = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    final picked = await showDatePicker(
      context: context,
      initialDate: first,
      firstDate: first,
      lastDate: first.add(const Duration(days: 365)),
    );
    if (picked == null || !mounted) return;
    final iso = RelationshipDay.isoDay(picked);
    final until = TodayFormat.instantOf(
      iso,
      v.dayBoundaryMinutes ~/ 60,
      v.dayBoundaryMinutes % 60,
      v.timezone,
    );
    await _dynamicChange(() => ref.read(dynamicRepositoryProvider).away(
          widget.dynamicId,
          until: until,
          idempotencyKey: ApiClient.newIdempotencyKey(),
        ));
  }

  Future<void> _back() => _dynamicChange(
        () => ref.read(dynamicRepositoryProvider).back(widget.dynamicId, idempotencyKey: ApiClient.newIdempotencyKey()),
      );

  Future<void> _dynamicChange(Future<void> Function() call) async {
    try {
      await call();
      ref.invalidate(todayProvider(widget.dynamicId));
      ref.invalidate(dynamicDetailProvider(widget.dynamicId));
    } on Object {
      if (mounted) setState(() => _drawNotice = L.of(context).dTodayConflictOther);
    }
  }

  Future<void> _drawTonight() async {
    if (_drawing) return;
    final l = L.of(context);
    setState(() {
      _drawing = true;
      _drawNotice = null;
    });
    final repo = ref.read(exploreRepositoryProvider);
    try {
      var again = true;
      while (again && mounted) {
        final card = await repo.draw(widget.dynamicId, idempotencyKey: ApiClient.newIdempotencyKey());
        if (!mounted) return;
        final action = await showIdeaCardSheet(
          context,
          card: card,
          isD: true,
          dName: l.rulesYou,
          canDrawAgain: true,
        );
        again = action == drawAgainSentinel;
        if (action == null || again) continue;
        await repo.act(widget.dynamicId, card.id, action, idempotencyKey: ApiClient.newIdempotencyKey());
        ref.invalidate(ideaCardsProvider(widget.dynamicId));
        if (action == IdeaCardAction.addToday) {
          ref.invalidate(todayProvider(widget.dynamicId));
          ref.invalidate(taskDefinitionsProvider(widget.dynamicId));
        }
        if (action == IdeaCardAction.addRule) ref.invalidate(rulesProvider(widget.dynamicId));
        if (action == IdeaCardAction.save) ref.invalidate(dNotesProvider(widget.dynamicId));
        if (mounted) setState(() => _drawNotice = l.exploreActDone);
      }
    } on Object {
      if (mounted) setState(() => _drawNotice = l.exploreDrawFailed);
    } finally {
      if (mounted) setState(() => _drawing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final view = widget.view;
    final locale = _locale;
    final needsMe = ref.watch(needsMeProvider(widget.dynamicId));
    final notes = ref.watch(dNotesProvider(widget.dynamicId));
    final away = view.dAwayUntil != null && view.dAwayUntil!.isAfter(DateTime.now());
    final quiet = DsTextStyles.bodySecondary.copyWith(color: DsColors.textOnRitualMuted);

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
            TodayFormat.weekday(view.day, locale),
            TodayFormat.minutesClock(view.dayBoundaryMinutes, locale),
          ),
          hero: TodayFormat.dayHero(view.day, locale),
          heroKey: const ValueKey('today-hero'),
          // Balance and days are facts about two people; alone there are none.
          support: widget.alone
              ? null
              : '${l.todayBalance(view.balance)} · ${l.todayDaysTogether(view.daysTogether)}',
        ),
        const SizedBox(height: DsSpacing.space6),
        ?widget.notice,
        Padding(
          padding: todayInset,
          child: Wrap(
            spacing: DsSpacing.space6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              WordButton(label: l.exploreDrawTonight, quiet: true, onTap: _drawTonight),
              // D-26: the state of the day, so it lives with the day.
              WordButton(
                key: const ValueKey('today-away'),
                label: away ? l.rulesBack : l.rulesAwayToggle,
                quiet: true,
                onTap: away ? _back : _away,
              ),
            ],
          ),
        ),
        if (_drawNotice != null)
          Padding(
            padding: todayInset.add(const EdgeInsets.only(top: DsSpacing.space2)),
            child: Text(_drawNotice!, style: quiet),
          ),
        const SizedBox(height: DsSpacing.space10),
        SectionLabel(l.dTodaySectionNeedsMe),
        if (widget.alone)
          QuietLine(l.todayStartsWhenJoined)
        else
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
        if (!widget.alone) _overview(l),
        SectionLabel(l.dTodaySectionQuickAdd),
        DQuickAdd(onAdd: _addTask, onMore: (draft) => _addTaskFully(view, draft)),
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
