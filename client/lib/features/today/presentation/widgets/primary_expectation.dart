import 'package:ds_relationship_companion/ds_design_system.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../../domain_client/models/today_view.dart';
import '../../application/today_actions.dart';
import 'today_layout.dart';
import 'today_meta.dart';

/// The first priority. A vertical authority rule runs the full height of the
/// block, and the four contract actions are reachable here — never behind a
/// detail page.
class PrimaryExpectation extends StatelessWidget {
  const PrimaryExpectation({
    super.key,
    required this.item,
    required this.zone,
    required this.onAction,
    this.busy = false,
    this.onOpen,
  });

  final TodayItem item;

  /// The Dynamic's IANA zone, for rendering the due time (REQ-TIME-001).
  final String? zone;

  /// The four paths are equals: this widget reports which one was chosen and
  /// knows nothing about how it reaches the server.
  final void Function(TodayAction) onAction;

  /// While an attempt is in flight the actions are withdrawn, so a second tap
  /// cannot start a second attempt.
  final bool busy;

  /// Opens SCR-14 for this item. The four actions stay reachable here rather
  /// than behind it — the detail is for reading the whole of something, not a
  /// gate in front of acting on it.
  final VoidCallback? onOpen;

  /// The adjustment paths the server permits, in the order the design fixes.
  List<TodayAction> get _adjustments => _AdjustmentActions._order
      .where((a) => item.allowedActions.contains(a.wire))
      .toList();

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: DsSpacing.space5),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _AuthorityRule(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: DsSpacing.space5,
                  right: DsSpacing.space5,
                  bottom: DsSpacing.space2,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // The mark states identity, not position: SCR-01 §4
                        // registers `mark.authority` as "Priority/expectation
                        // identity" and `emblem.ritual.evening` as "Evening
                        // ritual identity". A ritual in first position drew
                        // the authority mark while its label said RITUAL.
                        DsSvg(
                          asset: assetFor(item),
                          tone: DsAssetTone.primary,
                          width: 26,
                          height: 30,
                        ),
                        const SizedBox(width: DsSpacing.space4),
                        Flexible(
                          child: Text(
                            l.todayPrimaryEyebrow(kindLabel(l, item)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: DsTextStyles.labelRitual.copyWith(
                              color: DsColors.textOnRitualMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: DsSpacing.space4),
                    // The editorial face carries what a person is being asked
                    // to do. UI chrome never borrows it.
                    GestureDetector(
                      onTap: onOpen,
                      behavior: HitTestBehavior.opaque,
                      child: Text(
                        item.title,
                        // Design measures 28px with a 31px line box; the
                        // frozen 34/42 role is the ritual-focus size, not
                        // this one.
                        style: DsTextStyles.displayRitual.copyWith(
                          color: DsColors.textOnRitualPrimary,
                          fontSize: 28,
                          height: 31 / 28,
                        ),
                      ),
                    ),
                    const SizedBox(height: DsSpacing.space4),
                    Text(
                      itemMeta(l, item, zone: zone),
                      style: DsTextStyles.bodySecondary.copyWith(
                        color: DsColors.textOnRitualMuted,
                        fontSize: todaySupportSize,
                        height: todaySupportHeight,
                      ),
                    ),
                    // Only what the server says this person may do. Nothing
                    // is offered that would be refused.
                    if (item.allowedActions.contains(
                      TodayAction.complete.wire,
                    )) ...[
                      const SizedBox(height: DsSpacing.space3),
                      _CompleteButton(
                        busy: busy,
                        onTap: () => onAction(TodayAction.complete),
                      ),
                    ],
                    if (_adjustments.isNotEmpty) ...[
                      const SizedBox(height: DsSpacing.space3),
                      _AdjustmentActions(
                        busy: busy,
                        onAction: onAction,
                        paths: _adjustments,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthorityRule extends StatelessWidget {
  const _AuthorityRule();

  @override
  Widget build(BuildContext context) => const SizedBox(
    width: DsBorderWidths.hairline,
    child: ColoredBox(color: DsColors.borderOnRitualStrong),
  );
}

class _CompleteButton extends StatelessWidget {
  const _CompleteButton({required this.onTap, required this.busy});

  final VoidCallback onTap;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: DsControlSizes.button,
      width: double.infinity,
      child: Material(
        color: DsColors.actionPrimaryBackground,
        borderRadius: BorderRadius.circular(DsRadii.control),
        child: InkWell(
          borderRadius: BorderRadius.circular(DsRadii.control),
          onTap: busy ? null : onTap,
          child: Center(
            child: Text(
              busy ? L.of(context).actionSending : L.of(context).actionComplete,
              style: DsTextStyles.labelAction.copyWith(
                color: DsColors.actionPrimaryForeground,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Discuss, New time and Can't do. Adjustment is a normal path, so these are
/// permanent structural furniture beside Complete — each keeping its own 48dp
/// target even though they are drawn as quiet text.

/// Discuss, New time and Can't do. Adjustment is a normal path, so these are
/// permanent structural furniture beside Complete — each keeping its own 48dp
/// target even though they are drawn as quiet text.
class _AdjustmentActions extends StatelessWidget {
  const _AdjustmentActions({
    required this.onAction,
    required this.busy,
    required this.paths,
  });

  final void Function(TodayAction) onAction;
  final bool busy;

  /// Already filtered to what the server permits, in the order the design
  /// fixes. Adjustment is never presented as a lesser choice than completing.
  final List<TodayAction> paths;

  /// Labels are resolved at build time from [L]; only the actions are fixed
  /// here.
  static const _order = <TodayAction>[
    TodayAction.discuss,
    TodayAction.requestNewTime,
    TodayAction.cantDo,
    // Last, and only ever alone: the server permits `withdraw` exactly when
    // an adjustment is open, which is when it permits nothing else. Before it
    // was implemented this card showed such an item with no action at all.
    TodayAction.withdraw,
  ];

  static String labelFor(L l, TodayAction a) => switch (a) {
    TodayAction.discuss => l.actionDiscuss,
    TodayAction.requestNewTime => l.actionNewTime,
    TodayAction.cantDo => l.actionCantDo,
    TodayAction.withdraw => l.actionTakeItBack,
    TodayAction.complete => l.actionComplete,
  };

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Row(
      children: [
        for (final action in paths)
          Expanded(
            child: SizedBox(
              height: DsLayoutSizes.touchTarget,
              child: InkWell(
                onTap: busy ? null : () => onAction(action),
                child: Center(
                  child: Text(
                    labelFor(l, action),
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.fade,
                    style: DsTextStyles.bodySecondary.copyWith(
                      color: DsColors.textOnRitualPrimary,
                      fontSize: todaySupportSize,
                      height: todaySupportHeight,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
