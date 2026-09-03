import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/shell/ds_glyph.dart';
import '../../../app/shell/ds_primary_button.dart';
import '../../../app/shell/ds_skeleton.dart';
import '../../../app/shell/ds_text_field.dart';
import '../../../domain_client/api_client.dart';
import '../../../domain_client/models/explore.dart';
import '../../../l10n/app_localizations.dart';
import '../../rules/application/rules_providers.dart';
import '../../today/application/today_providers.dart';
import '../../today/presentation/widgets/quiet_line.dart';
import '../../today/presentation/widgets/recovery_scaffold.dart';
import '../../today/presentation/widgets/secondary_button.dart';
import '../../today/presentation/widgets/section_label.dart';
import '../../today/presentation/widgets/today_layout.dart';
import '../application/explore_providers.dart';

/// 起步包 (04-explore.md §3): "templates are for changing, not choosing".
/// Pick a pack, then every line is a draft — keep it, reword it, drop it —
/// and one tap creates exactly what is left. Nothing is created before that.
class StarterPackScreen extends ConsumerStatefulWidget {
  const StarterPackScreen({super.key, required this.dynamicId, this.onBack, this.onDone});

  final String dynamicId;
  final VoidCallback? onBack;

  /// After a pack is applied — back to 规矩, where the lines now live.
  final VoidCallback? onDone;

  @override
  ConsumerState<StarterPackScreen> createState() => _StarterPackScreenState();
}

class _StarterPackScreenState extends ConsumerState<StarterPackScreen> {
  StarterPack? _pack;
  PackDraft _draft = const PackDraft();
  bool _busy = false;
  String? _notice;

  void _choose(StarterPack p, String locale) => setState(() {
        _pack = p;
        _draft = p.draft(locale);
        _notice = null;
      });

  Future<String?> _edit(String current) => showModalBottomSheet<String>(
        context: context,
        backgroundColor: DsColors.canvasRitual,
        isScrollControlled: true,
        builder: (_) => _EditLineSheet(initial: current),
      );

  Future<void> _apply() async {
    final pack = _pack;
    if (pack == null || _busy || _draft.isEmpty) return;
    final l = L.of(context);
    setState(() {
      _busy = true;
      _notice = null;
    });
    try {
      await ref.read(exploreRepositoryProvider).applyPack(
            widget.dynamicId,
            pack.id,
            _draft,
            idempotencyKey: ApiClient.newIdempotencyKey(),
          );
      ref.invalidate(rulesProvider(widget.dynamicId));
      ref.invalidate(taskDefinitionsProvider(widget.dynamicId));
      ref.invalidate(rewardsProvider(widget.dynamicId));
      ref.invalidate(todayProvider(widget.dynamicId));
      if (!mounted) return;
      setState(() => _notice = l.explorePackApplied);
      widget.onDone?.call();
    } on Object {
      if (mounted) setState(() => _notice = l.exploreActionFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final locale = Localizations.localeOf(context).toString();
    final packs = ref.watch(starterPacksProvider);

    return Scaffold(
      backgroundColor: DsColors.canvasRitual,
      body: DsRitualSurface(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _Header(
                title: _pack?.title(locale) ?? l.explorePacksTitle,
                backLabel: l.exploreBack,
                onBack: _pack == null ? widget.onBack : () => setState(() => _pack = null),
              ),
              Padding(
                padding: todayInset,
                child: Text(
                  l.explorePacksIntro,
                  style: DsTextStyles.bodySecondary.copyWith(color: DsColors.textOnRitualMuted),
                ),
              ),
              if (_notice != null) ...[
                const SizedBox(height: DsSpacing.space4),
                Padding(padding: todayInset, child: RecoveryMessage(_notice!)),
              ],
              const SizedBox(height: DsSpacing.space6),
              if (_pack == null)
                switch (packs) {
                  AsyncData(:final value) => Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final p in value)
                          _PackRow(
                            key: ValueKey('pack-${p.id}'),
                            title: p.title(locale),
                            meta: l.explorePackCount(p.tasks.length, p.rules.length, p.rewards.length),
                            onTap: () => _choose(p, locale),
                          ),
                      ],
                    ),
                  AsyncError() => QuietLine(l.exploreCouldNotLoad),
                  _ => const Padding(padding: todayInset, child: DsSkeletonCard(lines: [0.6, 0.4])),
                }
              else
                _draftBody(l),
              const SizedBox(height: DsSpacing.space12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _draftBody(L l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionLabel(l.explorePackTasks),
        for (final (i, t) in _draft.tasks.indexed)
          _DraftLine(
            key: ValueKey('task-$i'),
            title: t.title,
            onRemove: () => setState(() => _draft = _draft.copyWith(tasks: [..._draft.tasks]..removeAt(i))),
            onEdit: () async {
              final s = await _edit(t.title);
              if (s == null || s.trim().isEmpty || !mounted) return;
              setState(() {
                final list = [..._draft.tasks];
                list[i] = t.copyWith(title: s.trim());
                _draft = _draft.copyWith(tasks: list);
              });
            },
          ),
        const SizedBox(height: DsSpacing.space6),
        SectionLabel(l.explorePackRules),
        for (final (i, r) in _draft.rules.indexed)
          _DraftLine(
            key: ValueKey('rule-$i'),
            title: r.title,
            detail: r.body,
            onRemove: () => setState(() => _draft = _draft.copyWith(rules: [..._draft.rules]..removeAt(i))),
            onEdit: () async {
              final s = await _edit(r.title);
              if (s == null || s.trim().isEmpty || !mounted) return;
              setState(() {
                final list = [..._draft.rules];
                list[i] = r.copyWith(title: s.trim());
                _draft = _draft.copyWith(rules: list);
              });
            },
          ),
        const SizedBox(height: DsSpacing.space6),
        SectionLabel(l.explorePackRewards),
        for (final (i, w) in _draft.rewards.indexed)
          _DraftLine(
            key: ValueKey('reward-$i'),
            title: w.title,
            detail: w.cost == null ? null : l.rulesPoints(w.cost!),
            onRemove: () => setState(() => _draft = _draft.copyWith(rewards: [..._draft.rewards]..removeAt(i))),
            onEdit: () async {
              final s = await _edit(w.title);
              if (s == null || s.trim().isEmpty || !mounted) return;
              setState(() {
                final list = [..._draft.rewards];
                list[i] = w.copyWith(title: s.trim());
                _draft = _draft.copyWith(rewards: list);
              });
            },
          ),
        const SizedBox(height: DsSpacing.space8),
        Padding(
          padding: todayInset,
          child: _draft.isEmpty
              ? QuietLine(l.explorePackEmptyDraft)
              : DsPrimaryButton(label: l.explorePackApply, onPressed: _busy ? null : _apply, busy: _busy),
        ),
      ],
    );
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

class _PackRow extends StatelessWidget {
  const _PackRow({super.key, required this.title, required this.meta, required this.onTap});

  final String title;
  final String meta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: todayInset.add(const EdgeInsets.symmetric(vertical: DsSpacing.space3)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: DsTextStyles.bodyPrimary.copyWith(color: DsColors.textOnRitualPrimary)),
            const SizedBox(height: DsSpacing.space1),
            Text(meta, style: DsTextStyles.bodySecondary.copyWith(color: DsColors.textOnRitualMuted)),
          ],
        ),
      ),
    );
  }
}

/// One draft line: tap to reword, the cross to drop it.
class _DraftLine extends StatelessWidget {
  const _DraftLine({
    super.key,
    required this.title,
    this.detail,
    required this.onEdit,
    required this.onRemove,
  });

  final String title;
  final String? detail;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Padding(
      padding: todayInset.add(const EdgeInsets.only(bottom: DsSpacing.space2)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: InkWell(
              onTap: onEdit,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: DsSpacing.space2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: DsTextStyles.bodyPrimary.copyWith(color: DsColors.textOnRitualPrimary)),
                    if (detail != null && detail!.isNotEmpty)
                      Text(detail!, style: DsTextStyles.bodySecondary.copyWith(color: DsColors.textOnRitualMuted)),
                  ],
                ),
              ),
            ),
          ),
          Semantics(
            button: true,
            label: l.rulesRewardRetire,
            child: InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(24),
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Center(child: DsGlyphIcon(DsGlyph.close, size: 18, color: DsColors.textOnRitualMuted)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditLineSheet extends StatefulWidget {
  const _EditLineSheet({required this.initial});
  final String initial;

  @override
  State<_EditLineSheet> createState() => _EditLineSheetState();
}

class _EditLineSheetState extends State<_EditLineSheet> {
  late final _c = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

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
          Text(l.explorePackEdit, style: DsTextStyles.bodyPrimary.copyWith(color: DsColors.textOnRitualPrimary)),
          const SizedBox(height: DsSpacing.space5),
          DsTextField(label: l.explorePackLineLabel, controller: _c),
          const SizedBox(height: DsSpacing.space5),
          DsPrimaryButton(label: l.explorePackKeep, onPressed: () => Navigator.of(context).pop(_c.text)),
          const SizedBox(height: DsSpacing.space3),
          SecondaryButton(label: l.todayCancel, onTap: () => Navigator.of(context).pop()),
        ],
      ),
    );
  }
}
