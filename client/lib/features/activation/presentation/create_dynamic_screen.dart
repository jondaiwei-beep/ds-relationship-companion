import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../design_system/components/ds_button.dart';
import '../../../design_system/components/ds_page.dart';
import '../../../design_system/components/ds_text.dart';
import '../../../design_system/tokens/colors.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';

/// Start a dynamic — Journey A2 (Notion 02 §A2).
///
/// Deliberately two questions and nothing else. This is the first thing a
/// person does in the product, and a long setup form would teach them that
/// this is an administrative tool. What the dynamic actually becomes is
/// decided later, by two people.
///
/// Nothing chosen here is an agreement about any specific act: it only tells
/// the Starter Rhythm what kind of first suggestions to make.
class CreateDynamicScreen extends ConsumerStatefulWidget {
  const CreateDynamicScreen({super.key, this.onCreated, this.onBack});

  final void Function(String dynamicId)? onCreated;
  final VoidCallback? onBack;

  @override
  ConsumerState<CreateDynamicScreen> createState() => _CreateDynamicState();
}

class _CreateDynamicState extends ConsumerState<CreateDynamicScreen> {
  // The five outcomes are fixed by Notion 02 §2 A1 — the wording is a
  // contract, not a suggestion, and the set feeds the Starter Rhythm.
  static const _outcomes = [
    ('CLOSER', 'Closer', 'More presence in an ordinary week.'),
    ('STRUCTURE', 'Structure', 'A rhythm we can both rely on.'),
    ('SERVICE', 'Service and devotion', 'Small acts, offered and noticed.'),
    ('ACCOUNTABILITY', 'Accountability', 'Someone who actually notices.'),
    ('EXPLORE', 'Explore together', 'Room to find out what fits.'),
  ];

  // Notion 03 §2. Optional, and it grants nothing — this is how they
  // describe themselves, not what they are allowed to do.
  static const _presets = [
    ('DOMINANT', 'I lead', null),
    ('SUBMISSIVE', 'I follow', null),
    ('SWITCH', 'Both, depending', null),
  ];

  static const _levels = [
    ('LIGHT', 'Light', 'A couple of things a week.'),
    ('MEDIUM', 'Steady', 'Something most days.'),
  ];

  String _outcome = 'CLOSER';
  String _level = 'LIGHT';
  String? _preset;
  var _busy = false;
  String? _error;

  // Stable across retries of THIS action, so a double tap cannot create two
  // dynamics; a new attempt after a failure gets a new key.
  late String _key = UniqueKey().toString();

  Future<void> _create() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final id = await ref.read(dynamicRepositoryProvider).create(
            desiredOutcome: _outcome,
            structureLevel: _level,
            rolePreset: _preset,
            // The day boundary and timezone are what "today" means for this
            // couple. Defaulting to the device zone is right for the person
            // starting it; both can change it later.
            referenceTimezone: DateTime.now().timeZoneName,
            idempotencyKey: _key,
          );
      if (mounted) widget.onCreated?.call(id);
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = "That didn't go through. Please try again.";
          _key = UniqueKey().toString();
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DsColors.canvas,
      body: DsPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: DsSpacing.sm),
            const DsAccentRule(),
            const SizedBox(height: DsSpacing.sm),
            Text(
              'What would you like more of right now?',
              style: DsType.h1,
            ),
            const SizedBox(height: DsSpacing.lg),
            Text(
              'Only to shape the first suggestions. You can change all of it.',
              style: DsType.body.copyWith(color: DsColors.muted),
            ),

            const SizedBox(height: DsSpacing.xxl),
            for (final (v, title, note) in _outcomes) ...[
              _Choice(
                title: title,
                note: note,
                selected: _outcome == v,
                onTap: () => setState(() => _outcome = v),
              ),
              const SizedBox(height: DsSpacing.md),
            ],

            const SizedBox(height: DsSpacing.xl),
            const DsEyebrow('Your part (optional)'),
            const SizedBox(height: DsSpacing.md),
            Row(
              children: [
                for (final (v, title, _) in _presets) ...[
                  Expanded(
                    child: _Chip(
                      label: title,
                      selected: _preset == v,
                      // Tapping the chosen one clears it: naming this is
                      // never required, and must stay undoable.
                      onTap: () => setState(
                          () => _preset = _preset == v ? null : v),
                    ),
                  ),
                  if (v != _presets.last.$1)
                    const SizedBox(width: DsSpacing.sm),
                ],
              ],
            ),
            const SizedBox(height: DsSpacing.md),
            Text(
              'Only a starting point. It changes nothing about what either '
              'of you can do.',
              style: DsType.fine.copyWith(color: DsColors.muted),
            ),

            const SizedBox(height: DsSpacing.xl),
            const DsEyebrow('How much'),
            const SizedBox(height: DsSpacing.md),
            for (final (v, title, note) in _levels) ...[
              _Choice(
                title: title,
                note: note,
                selected: _level == v,
                onTap: () => setState(() => _level = v),
              ),
              const SizedBox(height: DsSpacing.md),
            ],

            if (_error != null) ...[
              const SizedBox(height: DsSpacing.lg),
              Text(_error!,
                  style: DsType.fine.copyWith(color: DsColors.critical)),
            ],
            const SizedBox(height: DsSpacing.xxl),
            DsButton(
              label: _busy ? 'Starting…' : 'Start',
              onPressed: _busy ? null : _create,
            ),
            const SizedBox(height: DsSpacing.lg),
            Text(
              // Says plainly that this commits them to nothing.
              'Nothing is shared until you invite someone.',
              style: DsType.fine.copyWith(color: DsColors.muted),
            ),
            const SizedBox(height: DsSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.title,
    required this.note,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String note;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(15, 14, 15, 14),
        decoration: BoxDecoration(
          color: selected ? DsColors.stone : DsColors.surface,
          border: Border.all(
            color: selected ? DsColors.ink : DsColors.line,
          ),
          borderRadius: BorderRadius.circular(DsSpacing.cardRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: DsType.cardTitle),
            const SizedBox(height: DsSpacing.xs),
            Text(note, style: DsType.fine.copyWith(color: DsColors.muted)),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: DsSpacing.sm),
        decoration: BoxDecoration(
          color: selected ? DsColors.stone : Colors.transparent,
          border: Border.all(
            color: selected ? DsColors.ink : DsColors.line,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: DsType.fine.copyWith(
            color: selected ? DsColors.ink : DsColors.muted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
