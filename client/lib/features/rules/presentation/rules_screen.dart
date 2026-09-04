import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/shell/bottom_navigation.dart';
import '../../../app/shell/ds_refreshable.dart';
import '../../../app/shell/page_hero.dart';
import '../../../domain_client/api_client.dart';
import '../../../domain_client/models/explore.dart';
import '../../../domain_client/models/points.dart';
import '../../../domain_client/models/rule.dart';
import '../../../domain_client/models/task.dart';
import '../../../domain_client/models/today_view.dart';
import '../../../l10n/app_localizations.dart';
import '../../dynamic/application/dynamic_providers.dart';
import '../../explore/application/explore_providers.dart';
import '../../explore/presentation/explore_screen.dart';
import '../../today/application/today_providers.dart';
import '../../today/presentation/today_format.dart';
import '../../today/presentation/today_screen.dart';
import '../../today/presentation/widgets/quiet_line.dart';
import '../../today/presentation/widgets/recovery_scaffold.dart';
import '../../today/presentation/widgets/section_label.dart';
import '../../today/presentation/widgets/secondary_button.dart';
import '../../today/presentation/widgets/today_header.dart';
import '../../today/presentation/widgets/today_layout.dart';
import '../../today/presentation/widgets/today_notice.dart';
import '../../today/presentation/widgets/word_button.dart';
import '../application/rules_providers.dart';
import 'rules_format.dart';
import 'widgets/rules_sheets.dart';

/// Tab 2 · 规矩 (product/02-surfaces.md): the long-lived things, visited when
/// something changes. Standing rules, task definitions, what the s proposed,
/// limits, the reward catalogue, the consequence templates, and the way into
/// explore.
///
/// Skeleton per design/system/redesign-2026-09.md §7: header row · "Rules" as
/// the one large thing · STANDING RULES · RECURRING TASKS · PROPOSED (only when
/// there is one) · LIMITS & SAFEWORD as the one bordered block · REWARDS ·
/// CONSEQUENCES · a quiet row of doors · quiet "Pause the dynamic…" last.
/// "I'm away" is the state of the day and lives on Today now (D-26).
///
/// The D writes; the s reads and proposes (权限 table, D-24). Nothing here
/// runs anything: a template is a template, a rule generates no occurrence.
class RulesScreen extends ConsumerStatefulWidget {
  const RulesScreen({
    super.key,
    required this.dynamicId,
    this.onSignIn,
    this.onSelectTab,
    this.onPause,
    this.onExplore,
    this.onStarterPacks,
  });

  final String dynamicId;
  final VoidCallback? onSignIn;
  final void Function(NavSurface surface)? onSelectTab;

  /// Pausing the whole Dynamic goes through a screen that says what it does.
  final VoidCallback? onPause;

  /// Opens 探索 on one of its sections.
  final void Function(ExploreSection section)? onExplore;

  /// Opens the starter packs — the first-day way to fill an empty 规矩.
  final VoidCallback? onStarterPacks;

  @override
  ConsumerState<RulesScreen> createState() => _RulesScreenState();
}

class _RulesScreenState extends ConsumerState<RulesScreen> {
  String? _notice;
  bool _busy = false;

  String get _id => widget.dynamicId;

  void _reloadAll() {
    ref.invalidate(todayProvider(_id));
    ref.invalidate(dynamicDetailProvider(_id));
    ref.invalidate(rulesProvider(_id));
    ref.invalidate(taskDefinitionsProvider(_id));
    ref.invalidate(rewardsProvider(_id));
    ref.invalidate(agreementsProvider(_id));
    ref.invalidate(compareProvider(_id));
  }

  Future<void> _refresh() async {
    _reloadAll();
    await ref.read(todayProvider(_id).future);
  }

  /// Every write goes through here: one busy flag, one failure line, and a
  /// reload of what the server would now say.
  Future<void> _run(Future<void> Function() send, {String? success}) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _notice = null;
    });
    try {
      await send();
      _reloadAll();
      if (mounted && success != null) setState(() => _notice = success);
    } on Object {
      if (mounted) setState(() => _notice = L.of(context).rulesActionFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // ── names ────────────────────────────────────────────────────────────────

  /// The D by name: "you" on the D's own face, the partner's name on the s's,
  /// and never a role word as the fallback (§5).
  String _dName(L l, TodayView v) => v.isD ? l.rulesYou : (v.partnerDisplayName ?? l.rulesTheD);

  // ── dates ────────────────────────────────────────────────────────────────

  /// The chosen calendar day at the Dynamic's day boundary, in its zone —
  /// "until that day begins" (invariant 7: never the device date).
  DateTime _dayStartInstant(DateTime picked, TodayView v) {
    final iso = '${picked.year.toString().padLeft(4, '0')}-'
        '${picked.month.toString().padLeft(2, '0')}-'
        '${picked.day.toString().padLeft(2, '0')}';
    final h = v.dayBoundaryMinutes ~/ 60;
    final m = v.dayBoundaryMinutes % 60;
    return TodayFormat.instantOf(iso, h, m, v.timezone);
  }

  Future<DateTime?> _pickDay(TodayView v, {int fromDays = 1}) {
    final today = DateTime.now();
    final first = DateTime(today.year, today.month, today.day).add(Duration(days: fromDays));
    return showDatePicker(
      context: context,
      initialDate: first,
      firstDate: first,
      lastDate: first.add(const Duration(days: 365)),
    );
  }

  // ── rules ────────────────────────────────────────────────────────────────

  Future<void> _addRule(TodayView v) async {
    final l = L.of(context);
    final r = await showRuleSheet(
      context,
      title: v.isD ? l.rulesAddRule : l.rulesProposeRule,
      primaryLabel: v.isD ? null : l.rulesProposeRule,
    );
    if (r is! RuleSheetSave || !mounted) return;
    await _run(
      () => ref.read(ruleRepositoryProvider).create(
            _id,
            NewRule(title: r.title, body: r.body, group: r.group),
            idempotencyKey: ApiClient.newIdempotencyKey(),
          ),
      success: v.isD ? null : l.rulesProposedSent(_dName(l, v)),
    );
  }

  Future<void> _editRule(RuleView rule) async {
    final r = await showRuleSheet(context, title: rule.title, existing: rule, canArchive: true);
    if (r == null || !mounted) return;
    final repo = ref.read(ruleRepositoryProvider);
    switch (r) {
      case RuleSheetArchive():
        await _run(() => repo.archive(_id, rule.id, idempotencyKey: ApiClient.newIdempotencyKey()));
      case RuleSheetSave():
        await _run(
          () => repo.update(_id, rule.id, RuleEdit(title: r.title, body: r.body ?? '', group: r.group)),
        );
    }
  }

  /// s: long-press a rule → the same sheet, prefilled, posting a `proposed`
  /// rule with the edited text. The D sees it under 提议中.
  Future<void> _proposeChange(RuleView rule, TodayView v) async {
    final l = L.of(context);
    final r = await showRuleSheet(
      context,
      title: l.rulesProposeChange,
      existing: rule,
      primaryLabel: l.rulesProposeChange,
    );
    if (r is! RuleSheetSave || !mounted) return;
    await _run(
      () => ref.read(ruleRepositoryProvider).create(
            _id,
            NewRule(title: r.title, body: r.body, group: r.group),
            idempotencyKey: ApiClient.newIdempotencyKey(),
          ),
      success: l.rulesProposedSent(_dName(l, v)),
    );
  }

  Future<void> _acceptRule(String id) => _run(
        () => ref.read(ruleRepositoryProvider).accept(_id, id, idempotencyKey: ApiClient.newIdempotencyKey()),
      );

  Future<void> _archiveRule(String id) => _run(
        () => ref.read(ruleRepositoryProvider).archive(_id, id, idempotencyKey: ApiClient.newIdempotencyKey()),
      );

  // ── tasks ────────────────────────────────────────────────────────────────

  Future<void> _addTask(TodayView v) async {
    final l = L.of(context);
    final t = await showTaskSheet(
      context,
      title: v.isD ? l.rulesAddTask : l.rulesProposeTask,
      dName: _dName(l, v),
      timezone: v.timezone,
      today: v.day,
      dayBoundaryMinutes: v.dayBoundaryMinutes,
      primaryLabel: v.isD ? null : l.rulesProposeTask,
    );
    if (t == null || !mounted) return;
    await _run(
      () => ref.read(taskRepositoryProvider).create(_id, t, idempotencyKey: ApiClient.newIdempotencyKey()),
      success: v.isD ? null : l.rulesProposedSent(_dName(l, v)),
    );
  }

  Future<void> _taskMenu(TaskView t, TodayView v) async {
    final l = L.of(context);
    final paused = t.pausedUntil != null;
    final choice = await showChoiceSheetWords(
      context,
      title: t.title,
      choices: [
        (l.rulesEditTask, 'edit'),
        if (paused) (l.rulesUnpause, 'unpause'),
        if (!paused) (l.rulesPauseIndefinite, 'pause'),
        if (!paused) (l.rulesPauseUntilDate, 'pause_until'),
        (l.rulesArchive, 'archive'),
      ],
    );
    if (choice == null || !mounted) return;
    final repo = ref.read(taskRepositoryProvider);
    final key = ApiClient.newIdempotencyKey();
    switch (choice) {
      case 'edit':
        final edited = await showTaskSheet(
          context,
          title: t.title,
          dName: _dName(l, v),
          timezone: v.timezone,
          today: v.day,
          dayBoundaryMinutes: v.dayBoundaryMinutes,
          existing: t,
        );
        if (edited == null || !mounted) return;
        await _run(() => repo.update(_id, t.id, edited));
      case 'unpause':
        await _run(() => repo.unpause(_id, t.id, idempotencyKey: key));
      case 'pause':
        await _run(() => repo.pause(_id, t.id, idempotencyKey: key));
      case 'pause_until':
        final picked = await _pickDay(v);
        if (picked == null || !mounted) return;
        await _run(() => repo.pause(_id, t.id, until: _dayStartInstant(picked, v), idempotencyKey: key));
      case 'archive':
        await _run(() => repo.archive(_id, t.id, idempotencyKey: key));
    }
  }

  Future<void> _acceptTask(String id) => _run(
        () => ref.read(taskRepositoryProvider).accept(_id, id, idempotencyKey: ApiClient.newIdempotencyKey()),
      );

  Future<void> _declineTask(String id) => _run(
        () => ref.read(taskRepositoryProvider).decline(_id, id, idempotencyKey: ApiClient.newIdempotencyKey()),
      );

  // ── rewards / templates ──────────────────────────────────────────────────

  Future<void> _addReward() async {
    final d = await showRewardSheet(context);
    if (d == null || !mounted) return;
    await _run(() => ref.read(pointsRepositoryProvider).addReward(_id, title: d.title, cost: d.cost));
  }

  Future<void> _retireReward(Reward r) async {
    final l = L.of(context);
    final c = await showChoiceSheetWords(context, title: r.title, choices: [(l.rulesRewardRetire, 'retire')]);
    if (c == null || !mounted) return;
    await _run(() => ref.read(pointsRepositoryProvider).retireReward(_id, r.id));
  }

  Future<void> _addTemplate() async {
    final d = await showTemplateSheet(context);
    if (d == null || !mounted) return;
    await _run(
      () => ref.read(pointsRepositoryProvider).addAgreement(_id, label: d.label, consequence: d.consequence),
    );
  }

  Future<void> _endTemplate(ConsequenceAgreement a) async {
    final l = L.of(context);
    final c = await showChoiceSheetWords(context, title: a.label, choices: [(l.rulesEndConsequence, 'end')]);
    if (c == null || !mounted) return;
    await _run(() => ref.read(pointsRepositoryProvider).endAgreement(_id, a.id));
  }

  // ── build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final today = ref.watch(todayProvider(_id));
    void reload() => ref.invalidate(todayProvider(_id));

    return Scaffold(
      backgroundColor: DsColors.canvasRitual,
      body: DsRitualSurface(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: DsRefreshable(
                  onRefresh: _refresh,
                  child: today.when(
                    skipLoadingOnReload: true,
                    skipLoadingOnRefresh: true,
                    loading: () => const TodayLoading(),
                    error: (error, _) => switch (classifyFailure(error)) {
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
                            RecoveryMessage(l.rulesCouldNotLoad, prominent: true),
                            const SizedBox(height: DsSpacing.space6),
                            Padding(
                              padding: todayInset,
                              child: SecondaryButton(label: l.recoveryTryAgain, onTap: reload),
                            ),
                          ],
                        ),
                    },
                    data: (view) => _body(view, l),
                  ),
                ),
              ),
              DsBottomNavigation(current: NavSurface.rules, onSelect: widget.onSelectTab),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body(TodayView v, L l) {
    final locale = Localizations.localeOf(context).toString();
    final rules = ref.watch(rulesProvider(_id));
    final tasks = ref.watch(taskDefinitionsProvider(_id));
    final rewards = ref.watch(rewardsProvider(_id));
    final agreements = ref.watch(agreementsProvider(_id));
    final compare = ref.watch(compareProvider(_id));
    final detail = ref.watch(dynamicDetailProvider(_id)).value;
    // Not loaded yet reads as not alone: the page must not flash "starts
    // when they join" at a pair (§3).
    final alone = TodayNotice.isAlone(detail);
    final dName = _dName(l, v);
    final isD = v.isD;

    final proposedRules = rules.value?.where((r) => r.isProposed).toList() ?? const <RuleView>[];
    final proposedTasks = tasks.value?.where((t) => t.status == 'proposed').toList() ?? const <TaskView>[];
    final nothingYet = (rules.value?.where((r) => r.isActive).isEmpty ?? false) &&
        (tasks.value?.where((t) => t.status == 'active').isEmpty ?? false);
    // 起步包 is the section's primary only while the page is empty; the rest
    // of the time the Add words are outlined and nothing on the page is filled.
    final packFirst = isD && nothingYet && widget.onStarterPacks != null;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        TodayHeader(partnerName: v.partnerDisplayName),
        PageHero(hero: l.rulesTitle, heroKey: const ValueKey('rules-hero')),
        if (_notice != null) ...[
          const SizedBox(height: DsSpacing.space4),
          Padding(padding: todayInset, child: RecoveryMessage(_notice!)),
        ],

        // ── 常设规矩
        const SizedBox(height: DsSpacing.space10),
        SectionLabel(l.rulesStandingTitle),
        switch (rules) {
          AsyncData(:final value) => _StandingRules(
              rules: value.where((r) => r.isActive).toList(),
              isD: isD,
              onTap: isD ? _editRule : null,
              onLongPress: isD ? null : (r) => _proposeChange(r, v),
            ),
          AsyncError() => QuietLine(l.rulesCouldNotLoad),
          _ => const SizedBox(height: 40),
        },
        _Doors(
          children: [
            if (packFirst)
              WordButton(
                key: const ValueKey('rules-start-pack'),
                label: l.rulesStartFromPack,
                filled: true,
                onTap: widget.onStarterPacks!,
              ),
            WordButton(label: isD ? l.rulesAddRule : l.rulesProposeRule, onTap: () => _addRule(v)),
          ],
        ),

        // ── 循环任务定义
        const SizedBox(height: DsSpacing.space8),
        SectionLabel(l.rulesTasksTitle),
        switch (tasks) {
          AsyncData(:final value) => _TaskDefinitions(
              tasks: value.where((t) => t.status == 'active').toList(),
              view: v,
              locale: locale,
              dName: dName,
              onTap: isD ? (t) => _taskMenu(t, v) : null,
            ),
          AsyncError() => QuietLine(l.rulesCouldNotLoad),
          _ => const SizedBox(height: 40),
        },
        _Doors(children: [WordButton(label: isD ? l.rulesAddTask : l.rulesProposeTask, onTap: () => _addTask(v))]),

        // ── 提议中 — only when there is one (§4: empty and optional → omit).
        if (proposedRules.isNotEmpty || proposedTasks.isNotEmpty) ...[
          const SizedBox(height: DsSpacing.space8),
          SectionLabel(l.rulesProposedTitle),
          _Proposed(
            rules: proposedRules,
            tasks: proposedTasks,
            isD: isD,
            dName: dName,
            onAcceptRule: _acceptRule,
            onDeclineRule: _archiveRule,
            onAcceptTask: _acceptTask,
            onDeclineTask: _declineTask,
          ),
        ],

        // ── 底线与安全词 — the one bordered block on the page.
        const SizedBox(height: DsSpacing.space8),
        _LimitsBlock(
          key: const ValueKey('rules-limits'),
          notDoing: switch (compare) {
            AsyncData(:final value) => value.notDoing,
            _ => const [],
          },
          safeword: detail?.safeword,
          alone: alone,
          onCompare: widget.onExplore == null ? null : () => widget.onExplore!(ExploreSection.compare),
        ),

        // ── 奖励目录
        const SizedBox(height: DsSpacing.space8),
        SectionLabel(l.rulesRewardsTitle),
        switch (rewards) {
          AsyncData(:final value) when value.isEmpty =>
            QuietLine(isD ? l.rulesRewardsEmpty : l.rulesRewardsEmptyS(dName)),
          AsyncData(:final value) => Column(
              children: [
                for (final r in value)
                  _Row(
                    key: ValueKey('reward-${r.id}'),
                    title: r.title,
                    meta: r.cost == null ? l.rulesRewardDDecidesName(dName) : l.rulesPoints(r.cost!),
                    onLongPress: isD ? () => _retireReward(r) : null,
                  ),
              ],
            ),
          AsyncError() => QuietLine(l.rulesCouldNotLoad),
          _ => const SizedBox(height: 40),
        },
        if (isD)
          _Doors(children: [WordButton(label: l.rulesAddReward, onTap: _addReward)])
        else
          // Going to 积分 is navigation, so the word is quiet.
          _Doors(
            children: [
              WordButton(label: l.rulesGoRedeem, quiet: true, onTap: () => widget.onSelectTab?.call(NavSurface.points)),
            ],
          ),

        // ── 惩罚库
        const SizedBox(height: DsSpacing.space8),
        SectionLabel(l.rulesConsequencesTitle),
        Padding(
          padding: todayInset.add(const EdgeInsets.only(bottom: DsSpacing.space4)),
          child: Text(
            isD ? l.rulesConsequencesIntroYou : l.rulesConsequencesIntro(dName),
            style: DsTextStyles.bodySecondary.copyWith(color: DsColors.textOnRitualMuted),
          ),
        ),
        switch (agreements) {
          AsyncData(:final value) when value.isEmpty =>
            QuietLine(isD ? l.rulesConsequencesEmpty : l.rulesConsequencesEmptyS(dName)),
          AsyncData(:final value) => Column(
              children: [
                for (final a in value)
                  _Row(
                    key: ValueKey('template-${a.id}'),
                    title: a.label,
                    meta: a.consequence,
                    onLongPress: isD ? () => _endTemplate(a) : null,
                  ),
              ],
            ),
          AsyncError() => QuietLine(l.rulesCouldNotLoad),
          _ => const SizedBox(height: 40),
        },
        if (isD) _Doors(children: [WordButton(label: l.rulesAddConsequence, onTap: _addTemplate)]),

        // ── the doors out: all navigation, all quiet. Compare is not repeated
        // here; it lives in the limits block.
        const SizedBox(height: DsSpacing.space10),
        Padding(
          padding: todayInset,
          child: Wrap(
            spacing: DsSpacing.space6,
            runSpacing: DsSpacing.space2,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              WordButton(
                label: l.rulesExplorePrefs,
                quiet: true,
                onTap: () => widget.onExplore?.call(ExploreSection.prefs),
              ),
              WordButton(
                label: l.rulesExploreInspiration,
                quiet: true,
                onTap: () => widget.onExplore?.call(ExploreSection.cards),
              ),
              if (widget.onStarterPacks != null)
                WordButton(label: l.rulesExploreStarter, quiet: true, onTap: widget.onStarterPacks!),
            ],
          ),
        ),

        // Pause is agency either member keeps (权限 table). Quiet here; the
        // destructive word is inside the screen it opens.
        if (widget.onPause != null) ...[
          const SizedBox(height: DsSpacing.space8),
          Padding(
            padding: todayInset,
            child: Align(
              alignment: Alignment.centerLeft,
              child: WordButton(
                key: const ValueKey('rules-pause'),
                label: l.rulesPauseDynamic,
                quiet: true,
                onTap: widget.onPause!,
              ),
            ),
          ),
        ],
        const SizedBox(height: DsSpacing.space12),
      ],
    );
  }
}

/// One choice among a few words, as a plain string tag. A thin wrapper so the
/// screen reads as a list of doors rather than sheet plumbing.
Future<String?> showChoiceSheetWords(
  BuildContext context, {
  required String title,
  required List<(String, String)> choices,
}) =>
    showModalBottomSheet<String>(
      context: context,
      backgroundColor: DsColors.canvasRitual,
      builder: (sheet) {
        final l = L.of(sheet);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              DsSpacing.space5,
              DsSpacing.space6,
              DsSpacing.space5,
              DsSpacing.space6,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(title, style: DsTextStyles.bodyPrimary.copyWith(color: DsColors.textOnRitualPrimary)),
                const SizedBox(height: DsSpacing.space5),
                for (final (label, value) in choices) ...[
                  SecondaryButton(label: label, onTap: () => Navigator.of(sheet).pop(value)),
                  const SizedBox(height: DsSpacing.space3),
                ],
                SecondaryButton(label: l.rulesNeverMind, onTap: () => Navigator.of(sheet).pop()),
              ],
            ),
          ),
        );
      },
    );

// ── pieces ─────────────────────────────────────────────────────────────────

/// 底线与安全词. Fed by the compare's 「不要」: a title each, no one attached —
/// the server never says who said no, and neither do we. The safeword sits
/// with them when the pair has one (set in 设置 by either). A hairline above
/// and below makes this the one visually distinct block on the page.
class _LimitsBlock extends StatelessWidget {
  const _LimitsBlock({
    super.key,
    required this.notDoing,
    required this.safeword,
    required this.alone,
    required this.onCompare,
  });

  final List<CompareItem> notDoing;
  final String? safeword;
  final bool alone;
  final VoidCallback? onCompare;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final muted = DsTextStyles.bodySecondary.copyWith(color: DsColors.textOnRitualMuted);
    final hasSafeword = safeword != null && safeword!.isNotEmpty;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: DsSpacing.space6),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: DsColors.borderOnRitualHairline),
          bottom: BorderSide(color: DsColors.borderOnRitualHairline),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(l.rulesLimitsTitle),
          Padding(padding: todayInset, child: Text(l.rulesLimitsLine, style: muted)),
          const SizedBox(height: DsSpacing.space2),
          // Two people mark limits; alone there is no "either of you" yet, so
          // the list is named as not started rather than shown (§3).
          if (alone)
            QuietLine(l.todayStartsWhenJoined)
          else if (notDoing.isNotEmpty)
            for (final c in notDoing)
              _Row(key: ValueKey('limit-${c.itemId}'), title: c.title, meta: l.exploreCompareNotDoing)
          else if (!hasSafeword)
            QuietLine(l.rulesLimitsEmpty),
          if (hasSafeword) _Row(key: const ValueKey('safeword'), title: safeword!, meta: l.rulesSafewordMeta),
          if (onCompare != null && !alone)
            Padding(
              padding: todayInset.add(const EdgeInsets.only(top: DsSpacing.space3)),
              child: Align(
                alignment: Alignment.centerLeft,
                child: WordButton(label: l.rulesLimitsGo, quiet: true, onTap: onCompare!),
              ),
            ),
        ],
      ),
    );
  }
}

class _StandingRules extends StatelessWidget {
  const _StandingRules({required this.rules, required this.isD, this.onTap, this.onLongPress});

  final List<RuleView> rules;
  final bool isD;
  final void Function(RuleView)? onTap;
  final void Function(RuleView)? onLongPress;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    if (rules.isEmpty) return QuietLine(isD ? l.rulesStandingEmpty : l.rulesStandingEmptyS);
    final byGroup = <String, List<RuleView>>{};
    for (final r in rules) {
      (byGroup[r.group] ??= []).add(r);
    }
    final order = [...ruleGroups, ...byGroup.keys.where((g) => !ruleGroups.contains(g))];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final g in order)
          if (byGroup[g] case final list?) ...[
            Padding(
              padding: todayInset.add(const EdgeInsets.only(top: DsSpacing.space2, bottom: DsSpacing.space2)),
              child: Text(
                RulesFormat.group(l, g),
                key: ValueKey('group-$g'),
                style: DsTextStyles.bodySecondary.copyWith(color: DsColors.textOnRitualMuted, fontSize: 11),
              ),
            ),
            for (final r in list..sort((a, b) => a.position.compareTo(b.position)))
              _Row(
                key: ValueKey('rule-${r.id}'),
                title: r.title,
                meta: r.body,
                onTap: onTap == null ? null : () => onTap!(r),
                onLongPress: onLongPress == null ? null : () => onLongPress!(r),
              ),
          ],
      ],
    );
  }
}

class _TaskDefinitions extends StatelessWidget {
  const _TaskDefinitions({
    required this.tasks,
    required this.view,
    required this.locale,
    required this.dName,
    this.onTap,
  });

  final List<TaskView> tasks;
  final TodayView view;
  final String locale;
  final String dName;
  final void Function(TaskView)? onTap;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    if (tasks.isEmpty) return QuietLine(view.isD ? l.rulesTasksEmpty : l.rulesTasksEmptyS);
    return Column(
      children: [
        for (final t in tasks..sort((a, b) => a.position.compareTo(b.position)))
          _Row(
            key: ValueKey('task-${t.id}'),
            title: t.title,
            meta: [
              RulesFormat.schedule(l, t),
              RulesFormat.proof(l, t.proof),
              if (t.pointsEarn > 0) l.rulesPoints(t.pointsEarn),
              if (t.requiresDPresent) l.rulesNeedsD(dName),
            ].join(' · '),
            trailing: _pausedWord(l, t),
            dimmed: t.pausedUntil != null,
            onTap: onTap == null ? null : () => onTap!(t),
          ),
      ],
    );
  }

  String? _pausedWord(L l, TaskView t) {
    final until = t.pausedUntil;
    if (until == null) return null;
    // A far-future instant is "indefinitely"; a date is a date.
    if (until.year > DateTime.now().year + 50) return l.rulesPaused;
    return l.rulesPausedUntil(TodayFormat.dayOfInstant(until, view.timezone, locale));
  }
}

/// The s's proposals waiting on the D. Accept and decline are both outlined:
/// a filled word per row would put several primaries in one section (§2).
class _Proposed extends StatelessWidget {
  const _Proposed({
    required this.rules,
    required this.tasks,
    required this.isD,
    required this.dName,
    required this.onAcceptRule,
    required this.onDeclineRule,
    required this.onAcceptTask,
    required this.onDeclineTask,
  });

  final List<RuleView> rules;
  final List<TaskView> tasks;
  final bool isD;
  final String dName;
  final void Function(String id) onAcceptRule;
  final void Function(String id) onDeclineRule;
  final void Function(String id) onAcceptTask;
  final void Function(String id) onDeclineTask;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Column(
      children: [
        for (final t in tasks)
          _Row(
            key: ValueKey('proposed-task-${t.id}'),
            title: t.title,
            meta: '${l.rulesKindTask} · ${RulesFormat.schedule(l, t)}',
            trailing: isD ? null : l.rulesWaitingFor(dName),
            actions: isD
                ? [
                    WordButton(label: l.rulesAccept, onTap: () => onAcceptTask(t.id)),
                    WordButton(label: l.rulesDecline, onTap: () => onDeclineTask(t.id)),
                  ]
                : const [],
          ),
        for (final r in rules)
          _Row(
            key: ValueKey('proposed-rule-${r.id}'),
            title: r.title,
            meta: '${l.rulesKindRule} · ${RulesFormat.group(l, r.group)}${r.body == null ? '' : ' · ${r.body}'}',
            trailing: isD ? null : l.rulesWaitingFor(dName),
            actions: isD
                ? [
                    WordButton(label: l.rulesAccept, onTap: () => onAcceptRule(r.id)),
                    WordButton(label: l.rulesDecline, onTap: () => onDeclineRule(r.id)),
                  ]
                : [WordButton(label: l.rulesWithdraw, onTap: () => onDeclineRule(r.id))],
          ),
      ],
    );
  }
}

/// A title, a fact line under it, and optionally a word at the end or a row
/// of actions beneath.
class _Row extends StatelessWidget {
  const _Row({
    super.key,
    required this.title,
    this.meta,
    this.trailing,
    this.actions = const [],
    this.dimmed = false,
    this.onTap,
    this.onLongPress,
  });

  final String title;
  final String? meta;
  final String? trailing;
  final List<Widget> actions;
  final bool dimmed;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final titleColor = dimmed ? DsColors.textOnRitualMuted : DsColors.textOnRitualPrimary;
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: todayInset.add(const EdgeInsets.symmetric(vertical: DsSpacing.space3)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(title, style: DsTextStyles.bodyPrimary.copyWith(color: titleColor)),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: DsSpacing.space3),
                  Text(
                    trailing!,
                    style: DsTextStyles.bodySecondary.copyWith(color: DsColors.textOnRitualMuted, fontSize: 11),
                  ),
                ],
              ],
            ),
            if (meta != null && meta!.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                meta!,
                style: DsTextStyles.bodySecondary.copyWith(color: DsColors.textOnRitualMuted, fontSize: 12),
              ),
            ],
            if (actions.isNotEmpty) ...[
              const SizedBox(height: DsSpacing.space3),
              Wrap(spacing: DsSpacing.space2, runSpacing: DsSpacing.space2, children: actions),
            ],
          ],
        ),
      ),
    );
  }
}

/// The ways in under a section, each sized to its word, left-aligned.
class _Doors extends StatelessWidget {
  const _Doors({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: todayInset.add(const EdgeInsets.only(top: DsSpacing.space3)),
      child: Wrap(spacing: DsSpacing.space3, runSpacing: DsSpacing.space2, children: children),
    );
  }
}
