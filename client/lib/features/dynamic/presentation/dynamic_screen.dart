import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../design_system/components/ds_button.dart';
import '../../../design_system/components/ds_card.dart';
import '../../../design_system/components/ds_page.dart';
import '../../../design_system/components/ds_text.dart';
import '../../../design_system/tokens/colors.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';
import '../../../domain_client/api_client.dart';
import '../../../domain_client/models/dynamic_view.dart';

final dynamicDetailProvider =
    FutureProvider.autoDispose.family<DynamicDetail, String>((ref, id) async {
  return ref.watch(dynamicRepositoryProvider).detail(id);
});

/// Dynamic — the rhythm we are currently running (Notion 02 §10).
///
/// Core Beta shows ONLY: partner/role context, current structure, basic
/// settings, Pause/Resume and the privacy entry points. Agreement, Rules and a
/// permissions matrix are deliberately absent — we prove two people use the
/// loop daily before building governance.
class DynamicScreen extends ConsumerStatefulWidget {
  const DynamicScreen({
    super.key,
    required this.dynamicId,
    this.onSeparate,
    this.onNotifications,
    this.onInvite,
  });

  final String dynamicId;

  /// Opens the Leave-or-separate screen. Always offered.
  final VoidCallback? onSeparate;

  /// The member's own notification settings — quiet hours and lockscreen
  /// privacy. Reachable from here because this is where a person looks for
  /// their own controls, but the settings themselves belong to the User.
  final VoidCallback? onNotifications;

  /// Re-open the invite while nobody has joined — a Creator who closed the
  /// invite screen must be able to find the link again.
  final VoidCallback? onInvite;

  @override
  ConsumerState<DynamicScreen> createState() => _DynamicScreenState();
}

class _DynamicScreenState extends ConsumerState<DynamicScreen> {
  var _busy = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DsColors.canvas,
      body: ref.watch(dynamicDetailProvider(widget.dynamicId)).when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => DsPage(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: DsSpacing.xxxl),
                  Text("We couldn't load this just now.", style: DsType.h2),
                ],
              ),
            ),
            data: (d) => DsPage(child: _body(d)),
          ),
    );
  }

  VoidCallback? get onSeparate => widget.onSeparate;
  VoidCallback? get onNotifications => widget.onNotifications;
  VoidCallback? get onInvite => widget.onInvite;

  Widget _body(DynamicDetail d) {
    final paused = d.state == 'PAUSED';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: DsSpacing.sm),
        Text('Our dynamic', style: DsType.h1),

        if (paused) ...[
          const SizedBox(height: DsSpacing.xl),
          DsNote(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Paused', style: DsType.fine.copyWith(
                  color: DsColors.inkSoft, fontWeight: FontWeight.w700)),
                const SizedBox(height: DsSpacing.xs),
                // Journey E: returning must never require making up what was
                // missed. Say so, so nobody dreads coming back.
                Text(
                  'Nothing new is being created. When you return, there is '
                  'nothing to catch up on.',
                  style: DsType.fine,
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: DsSpacing.xxl),
        const DsEyebrow('Between'),
        const SizedBox(height: DsSpacing.md),
        DsCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final m in d.members) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(m.displayName ?? 'Partner', style: DsType.cardTitle),
                    Text(_role(m.roleContext), style: DsType.fine),
                  ],
                ),
                if (m != d.members.last) const SizedBox(height: DsSpacing.md),
              ],
            ],
          ),
        ),

        if (d.structure.isNotEmpty) ...[
          const SizedBox(height: DsSpacing.xxl),
          const DsEyebrow('Current rhythm'),
          const SizedBox(height: DsSpacing.md),
          for (final s in d.structure) ...[
            DsCard(
              tone: DsCardTone.stone,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(s.title, style: DsType.cardTitle)),
                  Text(s.kind == 'RITUAL' ? 'Ritual' : 'Expectation',
                      style: DsType.fine),
                ],
              ),
            ),
            const SizedBox(height: DsSpacing.sm),
          ],
        ],

        // Immediately under who this is between: these are part of the
        // relationship's shape, not a footnote to its settings.
        _alwaysYoursBlock(),

        const SizedBox(height: DsSpacing.xxl),
        if (paused) ...[
          // Journey E: coming back is a choice, not a switch. Being handed
          // the same load you paused under is how people leave again.
          const DsEyebrow('Coming back'),
          const SizedBox(height: DsSpacing.md),
          // Equal weight on purpose. A filled/outlined pair would say that
          // coming back lighter is the lesser choice — and being handed the
          // load you paused under is how people leave for good.
          DsButton(
            label: _busy ? '...' : 'Pick up where we left off',
            outline: true,
            onPressed: _busy ? null : () => _resume(lighter: false),
          ),
          const SizedBox(height: DsSpacing.md),
          DsButton(
            label: _busy ? '...' : 'Come back lighter',
            outline: true,
            onPressed: _busy ? null : () => _resume(lighter: true),
          ),
          const SizedBox(height: DsSpacing.sm),
          Text(
            'Lighter keeps about half of the rhythm. Nothing is deleted — '
            'the rest is still here when you want it.',
            style: DsType.fine.copyWith(color: DsColors.muted),
          ),
        ] else
          DsButton(
            label: _busy ? '...' : 'Pause this dynamic',
            outline: true,
            onPressed: _busy ? null : () => _togglePause(false),
          ),

        if (onInvite != null && d.state == 'PENDING_PARTNER') ...[
          const SizedBox(height: DsSpacing.lg),
          DsButton(label: 'Invite your partner', onPressed: onInvite),
        ],

        if (onNotifications != null) ...[
          const SizedBox(height: DsSpacing.lg),
          DsButton(
            label: 'Notifications and quiet hours',
            outline: true,
            onPressed: onNotifications,
          ),
        ],

        const SizedBox(height: DsSpacing.xl),
        // Leaving and blocking are always reachable — never behind a role
        // check or a partner-controlled setting (Notion 04 §4).
        if (onSeparate != null)
          Center(
            child: TextButton(
              onPressed: onSeparate,
              child: Text(
                'Leave or separate',
                style: DsType.fine.copyWith(
                  color: DsColors.response, fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

      ],
    );
  }

  /// Red line #4: what no role can ever take away.
  ///
  /// The list is CLIENT-OWNED and rendered unconditionally. Deriving it from
  /// the server payload meant an empty or partial response would silently
  /// remove rights that are supposed to be inviolable — the one thing on
  /// this screen that must not depend on a network answer being complete.
  ///
  /// It sits directly under who this is between, not at the bottom: these
  /// are part of the relationship's shape, not a footnote to its settings.
  static const _alwaysYours = [
    'Ask to discuss anything',
    'Request a new time',
    "Say you can't do something",
    'Pause this dynamic',
    'Leave at any time',
    'Block and cut off contact',
  ];

  Widget _alwaysYoursBlock() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: DsSpacing.xl),
          const DsEyebrow('Always yours'),
          const SizedBox(height: DsSpacing.sm),
          DsNote(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final a in _alwaysYours)
                  Padding(
                    padding: const EdgeInsets.only(bottom: DsSpacing.xs),
                    child: Text('· $a', style: DsType.fine),
                  ),
              ],
            ),
          ),
        ],
      );

  /// The third option — adjust — is the rhythm list on this same screen,
  /// so it is not offered here as a mode that would need its own editor.
  Future<void> _resume({required bool lighter}) async {
    setState(() => _busy = true);
    try {
      await ref.read(dynamicRepositoryProvider).resume(
            widget.dynamicId,
            lighter: lighter,
            idempotencyKey: ApiClient.newIdempotencyKey(),
          );
      ref.invalidate(dynamicDetailProvider(widget.dynamicId));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("That didn't go through. Please try again.")),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _togglePause(bool paused) async {
    setState(() => _busy = true);
    final repo = ref.read(dynamicRepositoryProvider);
    try {
      if (paused) {
        await repo.resume(widget.dynamicId, idempotencyKey: ApiClient.newIdempotencyKey());
      } else {
        await repo.pause(widget.dynamicId, idempotencyKey: ApiClient.newIdempotencyKey());
      }
      ref.invalidate(dynamicDetailProvider(widget.dynamicId));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("That didn't go through. Please try again.")),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Backend names never reach a person (Notion 05 §12). An unrecognised
  /// value falls back to nothing rather than leaking itself — the day the
  /// server adds a role, a raw enum would otherwise ship to users.
  String _role(String r) => switch (r) {
        'CREATOR' => 'Set the rhythm',
        'PARTNER' => 'Receives',
        _ => '',
      };

}
