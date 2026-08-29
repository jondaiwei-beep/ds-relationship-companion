import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';

import '../../../../domain_client/models/today_view.dart';
import 'today_layout.dart';
import 'today_meta.dart';

/// The first priority. A vertical authority rule runs the full height of the
/// block, and the four contract actions are reachable here — never behind a
/// detail page.
class PrimaryExpectation extends StatelessWidget {
  const PrimaryExpectation({super.key, required this.item});

  final TodayItem item;

  @override
  Widget build(BuildContext context) {
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
                        const DsSvg(
                          asset: DsAssets.markAuthority,
                          tone: DsAssetTone.primary,
                          width: 26,
                          height: 30,
                        ),
                        const SizedBox(width: DsSpacing.space4),
                        Flexible(
                          child: Text(
                            '01 · NOW · ${kindLabel(item)}',
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
                    Text(
                      item.title,
                      // Design measures 28px with a 31px line box; the frozen
                      // 34/42 role is the ritual-focus size, not this one.
                      style: DsTextStyles.displayRitual.copyWith(
                        color: DsColors.textOnRitualPrimary,
                        fontSize: 28,
                        height: 31 / 28,
                      ),
                    ),
                    const SizedBox(height: DsSpacing.space4),
                    Text(
                      itemMeta(item),
                      style: DsTextStyles.bodySecondary.copyWith(
                        color: DsColors.textOnRitualMuted,
                        fontSize: todaySupportSize,
                        height: todaySupportHeight,
                      ),
                    ),
                    const SizedBox(height: DsSpacing.space3),
                    const _CompleteButton(),
                    const SizedBox(height: DsSpacing.space3),
                    const _AdjustmentActions(),
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
  const _CompleteButton();

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
          onTap: () {},
          child: Center(
            child: Text(
              'Complete',
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
  const _AdjustmentActions();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final label in ['Discuss', 'New time', "Can't do"])
          Expanded(
            child: SizedBox(
              height: DsLayoutSizes.touchTarget,
              child: InkWell(
                onTap: () {},
                child: Center(
                  child: Text(
                    label,
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
