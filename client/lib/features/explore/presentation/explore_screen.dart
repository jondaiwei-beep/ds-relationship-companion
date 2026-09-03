import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/shell/bottom_navigation.dart';
import '../../../app/shell/ds_glyph.dart';
import '../../../app/shell/ds_refreshable.dart';
import '../../../domain_client/api_client.dart';
import '../../../domain_client/models/explore.dart';
import '../../../domain_client/models/rule.dart';
import '../../../domain_client/models/today_view.dart';
import '../../../l10n/app_localizations.dart';
import '../../rules/application/rules_providers.dart';
import '../../today/application/today_providers.dart';
import '../../today/presentation/today_screen.dart';
import '../../today/presentation/widgets/quiet_line.dart';
import '../../today/presentation/widgets/recovery_scaffold.dart';
import '../../today/presentation/widgets/secondary_button.dart';
import '../../today/presentation/widgets/section_label.dart';
import '../../today/presentation/widgets/today_layout.dart';
import '../../today/presentation/widgets/word_button.dart';
import '../application/explore_providers.dart';
import 'widgets/idea_card_sheet.dart';

/// The three layers of explore, as one screen inside 规矩.
enum ExploreSection {
  prefs,
  compare,
  cards;

  static ExploreSection parse(String? s) => switch (s) {
        'compare' => compare,
        'cards' => cards,
        _ => prefs,
      };
}

/// 探索 (product/04-explore.md): not a content library — the place two
/// people decide what to try next. Answers autosave on tap; only what both
/// answered is shown to either; 「不要」 is never attributed.
class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({
    super.key,
    required this.dynamicId,
    this.initialSection = ExploreSection.prefs,
    this.onSignIn,
    this.onSelectTab,
    this.onBack,
  });

  final String dynamicId;
  final ExploreSection initialSection;
  final VoidCallback? onSignIn;
  final void Function(NavSurface surface)? onSelectTab;
  final VoidCallback? onBack;

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  late ExploreSection _section = widget.initialSection;
  String? _notice;
  bool _busy = false;

  /// Answers the person just tapped, shown until the server's list agrees.
  final _pending = <String, String>{};

  String get _id => widget.dynamicId;

  void _reloadAll() {
    ref.invalidate(preferenceItemsProvider(_id));
    ref.invalidate(compareProvider(_id));
    ref.invalidate(ideaCardsProvider(_id));
  }

  Future<void> _refresh() async {
    ref.invalidate(todayProvider(_id));
    _reloadAll();
    await ref.read(todayProvider(_id).future);
  }

  Future<void> _run(Future<void> Function() send, {String? success}) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _notice = null;
    });
    try {
      await send();
      if (mounted && success != null) setState(() => _notice = success);
    } on Object {
      if (mounted) setState(() => _notice = L.of(context).exploreActionFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // ── preferences ──────────────────────────────────────────────────────────

  /// Autosave on tap. The chip flips at once; the list catches up after.
  Future<void> _answer(PreferenceItem item, String answer) async {
    setState(() {
      _pending[item.id] = answer;
      _notice = null;
    });
    try {
      await ref.read(exploreRepositoryProvider).answer(_id, item.id, answer);
      ref.invalidate(preferenceItemsProvider(_id));
      ref.invalidate(compareProvider(_id));
      ref.invalidate(ideaCardsProvider(_id));
    } on Object {
      if (!mounted) return;
      setState(() {
        _pending.remove(item.id);
        _notice = L.of(context).exploreActionFailed;
      });
    }
  }

  // ── compare ──────────────────────────────────────────────────────────────

  /// A compare row becomes a rule through the ordinary door: D's lands
  /// active, s's lands proposed (D-24). Nothing here decides for them.
  Future<void> _ruleFrom(CompareItem c) => _run(
        () async {
          await ref.read(ruleRepositoryProvider).create(
                _id,
                NewRule(title: c.title),
                idempotencyKey: ApiClient.newIdempotencyKey(),
              );
          ref.invalidate(rulesProvider(_id));
        },
        success: L.of(context).exploreActDone,
      );

  // ── cards ────────────────────────────────────────────────────────────────

  Future<void> _openCard(IdeaCard card, TodayView v, L l) async {
    final action = await showIdeaCardSheet(
      context,
      card: card,
      isD: v.isD,
      dName: v.isD ? l.rulesYou : (v.partnerDisplayName ?? l.rulesTheD),
    );
    if (action == null || !mounted) return;
    await _run(
      () async {
        await ref.read(exploreRepositoryProvider).act(
              _id,
              card.id,
              action,
              idempotencyKey: ApiClient.newIdempotencyKey(),
            );
        ref.invalidate(ideaCardsProvider(_id));
        if (action == IdeaCardAction.addRule) ref.invalidate(rulesProvider(_id));
        if (action == IdeaCardAction.addToday) {
          ref.invalidate(taskDefinitionsProvider(_id));
          ref.invalidate(todayProvider(_id));
        }
      },
      success: l.exploreActDone,
    );
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
                            RecoveryMessage(l.exploreCouldNotLoad, prominent: true),
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
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _Header(title: l.exploreTitle, backLabel: l.exploreBack, onBack: widget.onBack),
        Padding(
          padding: todayInset,
          child: Wrap(
            spacing: DsSpacing.space2,
            runSpacing: DsSpacing.space2,
            children: [
              for (final s in ExploreSection.values)
                WordButton(
                  label: switch (s) {
                    ExploreSection.prefs => l.exploreSectionPrefs,
                    ExploreSection.compare => l.exploreSectionCompare,
                    ExploreSection.cards => l.exploreSectionCards,
                  },
                  filled: s == _section,
                  onTap: () => setState(() => _section = s),
                ),
            ],
          ),
        ),
        if (_notice != null) ...[
          const SizedBox(height: DsSpacing.space4),
          Padding(padding: todayInset, child: RecoveryMessage(_notice!)),
        ],
        const SizedBox(height: DsSpacing.space6),
        switch (_section) {
          ExploreSection.prefs => _prefs(l, locale),
          ExploreSection.compare => _compare(v, l),
          ExploreSection.cards => _cards(v, l, locale),
        },
        const SizedBox(height: DsSpacing.space12),
      ],
    );
  }

  Widget _prefs(L l, String locale) {
    final items = ref.watch(preferenceItemsProvider(_id));
    return switch (items) {
      AsyncData(:final value) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: todayInset.add(const EdgeInsets.only(bottom: DsSpacing.space6)),
              child: Text(
                l.explorePrefsIntro,
                style: DsTextStyles.bodySecondary.copyWith(color: DsColors.textOnRitualMuted),
              ),
            ),
            for (final group in _groups(value)) ...[
              SectionLabel(group),
              for (final item in value.where((i) => i.group == group))
                _PreferenceRow(
                  key: ValueKey('pref-${item.id}'),
                  title: item.title(locale),
                  detail: item.detail(locale),
                  answer: _pending[item.id] ?? item.myAnswer,
                  labels: {
                    'want': l.exploreAnswerWant,
                    'ok': l.exploreAnswerOk,
                    'no': l.exploreAnswerNo,
                    'talk': l.exploreAnswerTalk,
                  },
                  onAnswer: (a) => _answer(item, a),
                ),
              const SizedBox(height: DsSpacing.space6),
            ],
          ],
        ),
      AsyncError() => QuietLine(l.exploreCouldNotLoad),
      _ => const SizedBox(height: 120),
    };
  }

  /// Groups in library order — the server sorts, we keep it.
  List<String> _groups(List<PreferenceItem> items) {
    final seen = <String>[];
    for (final i in items) {
      if (!seen.contains(i.group)) seen.add(i.group);
    }
    return seen;
  }

  Widget _compare(TodayView v, L l) {
    final compare = ref.watch(compareProvider(_id));
    final partner = v.partnerDisplayName ?? l.todayPartnerFallback;
    final dName = v.isD ? l.rulesYou : (v.partnerDisplayName ?? l.rulesTheD);
    final verb = v.isD ? l.exploreCompareAddRule : l.exploreCompareProposeRule(dName);
    return switch (compare) {
      AsyncData(:final value) when !value.partnerAnswered => QuietLine(l.exploreCompareNoPartner(partner)),
      AsyncData(:final value) when value.isEmpty => QuietLine(l.exploreCompareEmpty),
      AsyncData(:final value) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (value.bothWant.isNotEmpty) ...[
              SectionLabel(l.exploreCompareBothWant),
              for (final c in value.bothWant) _CompareRow(item: c, verb: verb, onVerb: _busy ? null : () => _ruleFrom(c)),
              const SizedBox(height: DsSpacing.space6),
            ],
            if (value.wantAndOk.isNotEmpty) ...[
              SectionLabel(l.exploreCompareWantAndOk),
              for (final c in value.wantAndOk) _CompareRow(item: c, verb: verb, onVerb: _busy ? null : () => _ruleFrom(c)),
              const SizedBox(height: DsSpacing.space6),
            ],
            if (value.someoneTalks.isNotEmpty) ...[
              SectionLabel(l.exploreCompareTalks),
              for (final c in value.someoneTalks) _CompareRow(item: c, verb: verb, onVerb: _busy ? null : () => _ruleFrom(c)),
              const SizedBox(height: DsSpacing.space6),
            ],
            // 「不要」: a title and nothing else. No name, no side, no verb.
            if (value.notDoing.isNotEmpty) ...[
              SectionLabel(l.exploreCompareNotDoing),
              Padding(
                padding: todayInset.add(const EdgeInsets.only(bottom: DsSpacing.space3)),
                child: Text(
                  l.exploreCompareNotDoingLine,
                  style: DsTextStyles.bodySecondary.copyWith(color: DsColors.textOnRitualMuted),
                ),
              ),
              for (final c in value.notDoing) _CompareRow(item: c),
            ],
          ],
        ),
      AsyncError() => QuietLine(l.exploreCouldNotLoad),
      _ => const SizedBox(height: 120),
    };
  }

  Widget _cards(TodayView v, L l, String locale) {
    final cards = ref.watch(ideaCardsProvider(_id));
    return switch (cards) {
      AsyncData(:final value) when value.isEmpty => QuietLine(l.exploreCardsEmpty),
      AsyncData(:final value) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tried cards sink to the bottom; the server already puts 想聊 first.
            for (final c in [...value.where((c) => !c.tried), ...value.where((c) => c.tried)])
              _CardRow(
                key: ValueKey('card-${c.id}'),
                title: c.title(locale),
                meta: switch (c.state) {
                  'saved' => l.exploreCardSaved,
                  'tried_again' => l.exploreCardTriedAgain,
                  'tried_never' => l.exploreCardTriedNever,
                  _ => l.exploreCardIntensity(c.intensity),
                },
                muted: c.tried,
                onTap: _busy ? null : () => _openCard(c, v, l),
              ),
          ],
        ),
      AsyncError() => QuietLine(l.exploreCouldNotLoad),
      _ => const SizedBox(height: 120),
    };
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.backLabel, this.onBack});

  final String title;
  final String backLabel;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(DsSpacing.space2, DsSpacing.space3, DsSpacing.space5, DsSpacing.space4),
      child: Row(
        children: [
          if (onBack != null)
            Semantics(
              button: true,
              label: backLabel,
              child: InkWell(
                onTap: onBack,
                borderRadius: BorderRadius.circular(24),
                child: const SizedBox(
                  width: 48,
                  height: 48,
                  child: Center(
                    child: DsGlyphIcon(DsGlyph.back, size: 22, color: DsColors.textOnRitualSecondary),
                  ),
                ),
              ),
            )
          else
            const SizedBox(width: DsSpacing.space3),
          const SizedBox(width: DsSpacing.space1),
          Expanded(
            child: Text(
              title,
              style: DsTextStyles.titlePage.copyWith(color: DsColors.textOnRitualPrimary, fontSize: 23),
            ),
          ),
        ],
      ),
    );
  }
}

/// One item, four words. The chosen one is filled; tapping another moves it.
class _PreferenceRow extends StatelessWidget {
  const _PreferenceRow({
    super.key,
    required this.title,
    required this.detail,
    required this.answer,
    required this.labels,
    required this.onAnswer,
  });

  final String title;
  final String? detail;
  final String? answer;
  final Map<String, String> labels;
  final void Function(String answer) onAnswer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: todayInset.add(const EdgeInsets.only(bottom: DsSpacing.space4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: DsTextStyles.bodyPrimary.copyWith(color: DsColors.textOnRitualPrimary)),
          if (detail != null && detail!.isNotEmpty) ...[
            const SizedBox(height: DsSpacing.space1),
            Text(detail!, style: DsTextStyles.bodySecondary.copyWith(color: DsColors.textOnRitualMuted)),
          ],
          const SizedBox(height: DsSpacing.space2),
          Wrap(
            spacing: DsSpacing.space2,
            runSpacing: DsSpacing.space2,
            children: [
              for (final a in preferenceAnswers)
                WordButton(label: labels[a]!, filled: answer == a, onTap: () => onAnswer(a)),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompareRow extends StatelessWidget {
  const _CompareRow({required this.item, this.verb, this.onVerb});

  final CompareItem item;
  final String? verb;
  final VoidCallback? onVerb;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: todayInset.add(const EdgeInsets.only(bottom: DsSpacing.space3)),
      child: Row(
        children: [
          Expanded(
            child: Text(item.title, style: DsTextStyles.bodyPrimary.copyWith(color: DsColors.textOnRitualPrimary)),
          ),
          if (verb != null) ...[
            const SizedBox(width: DsSpacing.space3),
            WordButton(label: verb!, onTap: onVerb ?? () {}),
          ],
        ],
      ),
    );
  }
}

class _CardRow extends StatelessWidget {
  const _CardRow({super.key, required this.title, required this.meta, required this.muted, this.onTap});

  final String title;
  final String meta;
  final bool muted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = muted ? DsColors.textOnRitualMuted : DsColors.textOnRitualPrimary;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: todayInset.add(const EdgeInsets.symmetric(vertical: DsSpacing.space3)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: DsTextStyles.bodyPrimary.copyWith(color: color)),
            const SizedBox(height: DsSpacing.space1),
            Text(meta, style: DsTextStyles.bodySecondary.copyWith(color: DsColors.textOnRitualMuted)),
          ],
        ),
      ),
    );
  }
}
