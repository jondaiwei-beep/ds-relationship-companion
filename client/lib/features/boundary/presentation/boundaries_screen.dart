import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/shell/ds_glyph.dart';
import '../../../app/shell/ds_refreshable.dart';
import '../../../app/shell/ds_text_field.dart';
import '../../../domain_client/models/boundary.dart';
import '../../../l10n/app_localizations.dart';
import '../../today/presentation/widgets/today_layout.dart';

/// Both members' limits — REQ-ACT-002, after activation.
///
/// Named during setup and then never seen again would be worse than not
/// asking: a limit is only useful if it stays visible and can be changed. So
/// this is the same list, permanently reachable from Settings.
///
/// The asymmetry is the whole design. Your own entries carry a remove
/// control; the other person's carry none, and say plainly that only they can
/// change them. The server enforces this too — `mine` is computed there
/// rather than worked out here from ids.
class BoundariesScreen extends ConsumerWidget {
  const BoundariesScreen({
    super.key,
    required this.dynamicId,
    required this.onBack,
    this.partnerName,
  });

  final String dynamicId;
  final VoidCallback onBack;
  final String? partnerName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context);
    final limits = ref.watch(boundariesProvider(dynamicId));

    return Scaffold(
      backgroundColor: DsColors.canvasRitual,
      body: SafeArea(
        child: DsRefreshable(
          onRefresh: () async =>
              ref.refresh(boundariesProvider(dynamicId).future),
          child: ListView(
            children: [
              Padding(
                padding: todayInset,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: onBack,
                      icon: DsGlyphIcon(
                        DsGlyph.back,
                        semanticLabel: l.shellBack,
                      ),
                    ),
                    const SizedBox(width: DsSpacing.space2),
                    Text(
                      l.boundaryTitle.toUpperCase(),
                      style: DsTextStyles.labelRitual.copyWith(
                        color: DsColors.textOnRitualPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: DsSpacing.space4),
              switch (limits) {
                AsyncData(:final value) => _Lists(
                  dynamicId: dynamicId,
                  rows: value,
                  partnerName: partnerName,
                ),
                AsyncError() => Padding(
                  padding: todayInset,
                  child: Text(
                    l.boundaryLoadFailed,
                    style: DsTextStyles.bodySecondary.copyWith(
                      color: DsColors.textOnRitualMuted,
                    ),
                  ),
                ),
                _ => const SizedBox(height: 120),
              },
              const SizedBox(height: DsSpacing.space10),
            ],
          ),
        ),
      ),
    );
  }
}

class _Lists extends ConsumerStatefulWidget {
  const _Lists({
    required this.dynamicId,
    required this.rows,
    required this.partnerName,
  });

  final String dynamicId;
  final List<Boundary> rows;
  final String? partnerName;

  @override
  ConsumerState<_Lists> createState() => _ListsState();
}

class _ListsState extends ConsumerState<_Lists> {
  final _label = TextEditingController();
  BoundaryStance _stance = BoundaryStance.off;
  bool _needsLabel = false;
  bool _busy = false;

  @override
  void dispose() {
    _label.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final text = _label.text.trim();
    if (text.isEmpty) {
      setState(() => _needsLabel = true);
      return;
    }
    setState(() => _busy = true);
    await ref
        .read(boundaryRepositoryProvider)
        .add(widget.dynamicId, label: text, stance: _stance);
    _label.clear();
    // A mutation re-reads: the server decided what changed.
    ref.invalidate(boundariesProvider(widget.dynamicId));
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _remove(String id) async {
    await ref.read(boundaryRepositoryProvider).remove(widget.dynamicId, id);
    ref.invalidate(boundariesProvider(widget.dynamicId));
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final mine = widget.rows.where((b) => b.mine).toList();
    final theirs = widget.rows.where((b) => !b.mine).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: todayInset,
          child: Text(
            l.boundaryYours,
            style: DsTextStyles.labelRitual.copyWith(
              color: DsColors.textOnRitualMuted,
              fontSize: 10,
              letterSpacing: 1.9,
            ),
          ),
        ),
        const SizedBox(height: DsSpacing.space3),
        if (mine.isEmpty)
          _Muted(l.boundaryEmptyYours)
        else
          for (final b in mine)
            _Row(
              limit: b,
              onRemove: _busy ? null : () => _remove(b.id),
            ),

        const SizedBox(height: DsSpacing.space6),
        Padding(
          padding: todayInset,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DsTextField(
                label: '',
                controller: _label,
                hint: l.activationBoundaryHint,
                enabled: !_busy,
                error: _needsLabel ? l.activationBoundaryNeedsLabel : null,
              ),
              const SizedBox(height: DsSpacing.space3),
              Row(
                children: [
                  for (final option in BoundaryStance.values) ...[
                    Expanded(
                      child: _StanceChip(
                        label: _stanceLabel(l, option),
                        selected: _stance == option,
                        onTap: () => setState(() => _stance = option),
                      ),
                    ),
                    if (option != BoundaryStance.values.last)
                      const SizedBox(width: DsSpacing.space2),
                  ],
                ],
              ),
              const SizedBox(height: DsSpacing.space3),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: _busy ? null : _add,
                  child: Text(
                    l.activationBoundaryAdd,
                    style: DsTextStyles.labelRitual.copyWith(
                      color: DsPrimitiveColors.terracotta,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: DsSpacing.space10),
        Padding(
          padding: todayInset,
          child: Text(
            widget.partnerName == null
                ? l.boundaryTheirsFallback
                : l.boundaryTheirs(widget.partnerName!).toUpperCase(),
            style: DsTextStyles.labelRitual.copyWith(
              color: DsColors.textOnRitualMuted,
              fontSize: 10,
              letterSpacing: 1.9,
            ),
          ),
        ),
        const SizedBox(height: DsSpacing.space3),
        if (theirs.isEmpty)
          _Muted(l.boundaryEmptyTheirs)
        else ...[
          for (final b in theirs) _Row(limit: b, onRemove: null),
          const SizedBox(height: DsSpacing.space3),
          _Muted(l.boundaryTheirsReadOnly),
        ],
      ],
    );
  }
}

String _stanceLabel(L l, BoundaryStance s) => switch (s) {
  BoundaryStance.off => l.boundaryStanceOff,
  BoundaryStance.ask => l.boundaryStanceAsk,
  BoundaryStance.curious => l.boundaryStanceCurious,
};

class _Row extends StatelessWidget {
  const _Row({required this.limit, required this.onRemove});

  final Boundary limit;

  /// Null for the partner's entries — not disabled, absent. A greyed-out
  /// delete would imply the viewer might one day be allowed to use it.
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Padding(
      padding: todayInset.add(
        const EdgeInsets.only(bottom: DsSpacing.space3),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  limit.label,
                  style: DsTextStyles.bodyPrimary.copyWith(
                    color: DsColors.textOnRitualPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _stanceLabel(l, limit.stance),
                  style: DsTextStyles.bodySecondary.copyWith(
                    color: DsColors.textOnRitualMuted,
                    fontSize: 11,
                  ),
                ),
                if (limit.note != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    limit.note!,
                    style: DsTextStyles.bodySecondary.copyWith(
                      color: DsColors.textOnRitualMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onRemove != null)
            IconButton(
              onPressed: onRemove,
              icon: const DsGlyphIcon(DsGlyph.close, size: 18),
              tooltip: l.activationBoundaryRemove(limit.label),
            ),
        ],
      ),
    );
  }
}

class _StanceChip extends StatelessWidget {
  const _StanceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: DsSpacing.space3),
      decoration: BoxDecoration(
        border: Border.all(
          color: selected
              ? DsPrimitiveColors.terracotta
              : DsColors.textOnRitualMuted.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: DsTextStyles.bodySecondary.copyWith(
          fontSize: 12,
          color: selected
              ? DsPrimitiveColors.terracotta
              : DsColors.textOnRitualMuted,
        ),
      ),
    ),
  );
}

class _Muted extends StatelessWidget {
  const _Muted(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: todayInset,
    child: Text(
      text,
      style: DsTextStyles.bodySecondary.copyWith(
        color: DsColors.textOnRitualMuted,
      ),
    ),
  );
}
