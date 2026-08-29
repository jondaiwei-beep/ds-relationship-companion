import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';

/// SCR-01 Today — revision 2, default state.
///
/// Built against `design/screens/SCR-01-today/candidates/rev-2/source.png` and
/// the frozen contracts, not from inference:
///
/// - B-2 geometry: the first priority carries a 56dp primary action and three
///   separate 48dp secondary targets; compact rows use the 72dp operational
///   row; bottom navigation is 80dp before the safe-area inset.
/// - B-2 colour: Terracotta is reserved for marks and large partner-authored
///   copy. It needs 24sp regular or 19sp bold, so the response quotation uses
///   the 28sp display role and small partner labels stay Stone.
/// - SVG Freeze v1: every mark comes from a registered master through
///   `DsAssets`; no path data and no ad-hoc colours in screen code.
///
/// This pass is visual only. Data is fixed so the render can be compared with
/// the approved design before any wiring exists to distract from it.
class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DsColors.canvasRitual,
      body: DsRitualSurface(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: const [
                    _Header(),
                    _SectionLabel('THREE THINGS MATTER'),
                    _PrimaryExpectation(),
                    _CompactRow(
                      index: '02',
                      asset: DsAssets.emblemRitualEvening,
                      title: 'Evening ritual',
                      meta: '8:30 PM · 6 min',
                    ),
                    _CompactRow(
                      index: '03',
                      asset: DsAssets.markCheckIn,
                      title: 'Daily check-in',
                      meta: 'Optional · private until shared',
                      lastInGroup: true,
                    ),
                    _PartnerResponse(),
                    _LaterRow(),
                    _DayBoundary(),
                  ],
                ),
              ),
              const _BottomNavigation(),
            ],
          ),
        ),
      ),
    );
  }
}

const _inset = EdgeInsets.symmetric(horizontal: DsSpacing.space5);

/// Supporting copy on this screen: item metadata and the quiet adjustment
/// actions. The frozen 14px secondary role reads too heavy against the 28px
/// headline, so these step down one level while staying well above the
/// minimum legible size.
const _supportSize = 12.0;
const _supportHeight = 17 / 12;

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _inset.add(
        const EdgeInsets.only(top: DsSpacing.space5, bottom: DsSpacing.space6),
      ),
      child: Row(
        children: [
          Text(
            'Today',
            style: DsTextStyles.titlePage.copyWith(
              color: DsColors.textOnRitualPrimary,
              fontSize: 23,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: DsSpacing.space4),
          // Presence is a mark plus neutral copy. Terracotta carries the mark;
          // the label stays Stone because it sits below the Terracotta text
          // size floor. A long display name shrinks the label rather than
          // pushing the row past the viewport.
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const DsSvg(
                  asset: DsAssets.markPresence,
                  tone: DsAssetTone.relationship,
                  width: 22,
                  height: 22,
                ),
                const SizedBox(width: DsSpacing.space2),
                Flexible(
                  child: Text(
                    'Morgan is present',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: DsTextStyles.bodySecondary.copyWith(
                      color: DsColors.textOnRitualSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _inset.add(const EdgeInsets.only(bottom: DsSpacing.space4)),
      child: Text(
        text,
        style: DsTextStyles.labelRitual.copyWith(
          color: DsColors.textOnRitualMuted,
        ),
      ),
    );
  }
}

/// The first priority. A vertical authority rule runs the full height of the
/// block, and the four contract actions are reachable here — never behind a
/// detail page.
class _PrimaryExpectation extends StatelessWidget {
  const _PrimaryExpectation();

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
                            '01 · NOW · EXPECTATION',
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
                      'Prepare the bedroom\nbefore 9:00 PM.',
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
                      'From Morgan · due 9:00 PM',
                      style: DsTextStyles.bodySecondary.copyWith(
                        color: DsColors.textOnRitualMuted,
                        fontSize: _supportSize,
                        height: _supportHeight,
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
                      fontSize: _supportSize,
                      height: _supportHeight,
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

class _CompactRow extends StatelessWidget {
  const _CompactRow({
    required this.index,
    required this.asset,
    required this.title,
    required this.meta,
    this.lastInGroup = false,
  });

  final String index;
  final DsAssetId asset;
  final String title;
  final String meta;
  final bool lastInGroup;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _inset,
      child: Container(
        height: DsControlSizes.listRow,
        decoration: BoxDecoration(
          border: Border(
            // The last row in the group closes against the response module's
            // own top border, so it does not draw its own.
            bottom: BorderSide(
              color: lastInGroup
                  ? DsPrimitiveColors.transparent
                  : DsColors.borderOnRitualHairline,
              width: DsBorderWidths.hairline,
            ),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 34,
              child: Text(
                index,
                style: DsTextStyles.labelRitual.copyWith(
                  color: DsColors.textOnRitualMuted,
                ),
              ),
            ),
            DsSvg(asset: asset, tone: DsAssetTone.muted, width: 26, height: 26),
            const SizedBox(width: DsSpacing.space4),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: DsTextStyles.bodyPrimary.copyWith(
                      color: DsColors.textOnRitualPrimary,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: DsSpacing.space1),
                  Text(
                    meta,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: DsTextStyles.bodySecondary.copyWith(
                      color: DsColors.textOnRitualMuted,
                      fontSize: _supportSize,
                      height: _supportHeight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Words a person wrote and sent. The display face and Terracotta appear here
/// and, on this screen, only here.
class _PartnerResponse extends StatelessWidget {
  const _PartnerResponse();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: DsSpacing.space2),
      padding: _inset.add(
        const EdgeInsets.symmetric(vertical: DsSpacing.space4),
      ),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: DsColors.borderOnRitualHairline),
          bottom: BorderSide(color: DsColors.borderOnRitualHairline),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const DsSvg(
                asset: DsAssets.stateAcknowledged,
                tone: DsAssetTone.relationship,
                width: 26,
                height: 26,
              ),
              const SizedBox(width: DsSpacing.space3),
              // labelRitual carries 2.4 tracking, so this line is wider than
              // it reads. It shrinks rather than pushing the row off-screen.
              Flexible(
                child: Text(
                  'MORGAN RESPONDED · 12 MIN AGO',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DsTextStyles.labelRitual.copyWith(
                    color: DsColors.textOnRitualSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DsSpacing.space3),
          Padding(
            padding: const EdgeInsets.only(left: DsSpacing.space10),
            child: Text(
              '“I noticed your care.”',
              style: DsTextStyles.displayPartner.copyWith(
                color: DsColors.relationshipAcknowledgement,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LaterRow extends StatelessWidget {
  const _LaterRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _inset,
      child: SizedBox(
        height: DsControlSizes.listRow,
        child: Row(
          children: [
            Text(
              'LATER / OPTIONAL',
              style: DsTextStyles.labelRitual.copyWith(
                color: DsColors.textOnRitualMuted,
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: () {},
              child: SizedBox(
                height: DsLayoutSizes.touchTarget,
                child: Row(
                  children: [
                    Text(
                      'Show',
                      style: DsTextStyles.bodyPrimary.copyWith(
                        color: DsColors.textOnRitualPrimary,
                      ),
                    ),
                    const SizedBox(width: DsSpacing.space3),
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: DsColors.surfaceRitualRaised,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '5',
                        style: DsTextStyles.bodySecondary.copyWith(
                          color: DsColors.textOnRitualSecondary,
                        ),
                      ),
                    ),
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

/// The relationship day, stated by the server in the Dynamic's own timezone.
class _DayBoundary extends StatelessWidget {
  const _DayBoundary();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _inset.add(
        const EdgeInsets.only(top: DsSpacing.space2, bottom: DsSpacing.space4),
      ),
      child: Text(
        'Relationship day ends at 2:00 AM',
        style: DsTextStyles.bodySecondary.copyWith(
          color: DsColors.textOnRitualMuted,
        ),
      ),
    );
  }
}

class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: DsControlSizes.bottomNavigation,
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: DsColors.borderOnRitualHairline)),
      ),
      child: Row(
        children: const [
          _NavTab(asset: DsAssets.navToday, label: 'Today', active: true),
          _NavTab(asset: DsAssets.navDynamic, label: 'Dynamic'),
          _NavTab(asset: DsAssets.navExplore, label: 'Explore'),
          _NavTab(asset: DsAssets.navUs, label: 'Us'),
        ],
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.asset,
    required this.label,
    this.active = false,
  });

  final DsAssetId asset;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final colour = active
        ? DsColors.textOnRitualPrimary
        : DsColors.textOnRitualMuted;
    return Expanded(
      child: InkWell(
        onTap: () {},
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DsSvg(
              asset: asset,
              tone: active ? DsAssetTone.primary : DsAssetTone.muted,
              width: 24,
              height: 24,
            ),
            const SizedBox(height: DsSpacing.space1),
            Text(label, style: DsTextStyles.navLabel.copyWith(color: colour)),
          ],
        ),
      ),
    );
  }
}
