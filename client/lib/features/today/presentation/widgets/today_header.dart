import 'package:ds_relationship_companion/ds_design_system.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../../app/shell/ds_glyph.dart';
import 'today_layout.dart';

/// A surface header: the surface name, and partner presence when there is a
/// partner to name.
///
/// Shared with Dynamic rather than copied. Presence is the one thing on this
/// row carrying a privacy rule — Terracotta only when a partner is really
/// there, hidden entirely while access is unconfirmed — and two copies of that
/// rule would eventually disagree about it.
class TodayHeader extends StatelessWidget {
  const TodayHeader({
    super.key,
    required this.title,
    this.partnerName,
    this.context_,
    this.editorialTitle = false,
    this.onSettings,
    this.onNotifications,
    this.unread = 0,
  });

  /// The surface name shown at the left.
  final String title;

  /// Sets the surface name in Cormorant at display size instead of the
  /// operational Inter title.
  ///
  /// Off by default, and on for exactly one surface. SCR-01 and SCR-17 set
  /// "Today" and "Us" in small Inter semibold; SCR-13 sets "Dynamic" in
  /// Cormorant at roughly three times the cap height — measured off the
  /// approved previews, not guessed. The B-2 rule that Cormorant is
  /// "selective editorial/ritual typography" is what makes this a per-surface
  /// choice rather than a global one: Dynamic opens on the shape of the
  /// relationship, and its own name is part of that statement in a way a
  /// task list's is not.

  /// Null when no partner presence may be shown — a Solo Dynamic, or a session
  /// whose authorization has not been confirmed.
  final String? partnerName;

  /// Replaces the presence line while the server is still being consulted.
  final String? context_;

  final bool editorialTitle;

  /// When set, a settings mark sits at the trailing edge.
  final VoidCallback? onSettings;

  /// When set, a bell sits before the settings mark, with [unread] on it
  /// while there is anything unread.
  final VoidCallback? onNotifications;
  final int unread;

  /// A named context wins over presence: while access is unconfirmed the
  /// header must say so rather than imply a partner is there.
  String _label(L l) =>
      context_ ??
      (partnerName == null ? l.todayPrivate : l.todayPresent(partnerName!));

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: todayInset.add(
        const EdgeInsets.only(top: DsSpacing.space5, bottom: DsSpacing.space6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: editorialTitle
                ? DsTextStyles.displayRitual.copyWith(
                    color: DsColors.textOnRitualPrimary,
                  )
                : DsTextStyles.titlePage.copyWith(
                    color: DsColors.textOnRitualPrimary,
                    fontSize: 23,
                    fontWeight: FontWeight.w600,
                  ),
          ),
          const SizedBox(width: DsSpacing.space4),
          // Presence is a mark plus neutral copy. Terracotta carries the mark
          // only when a partner is actually present; the label stays Stone
          // because it sits below the Terracotta text size floor. A long
          // display name shrinks the label rather than pushing the row past
          // the viewport.
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                DsSvg(
                  asset: DsAssets.markPresence,
                  // mark.presence licenses primary and relationship only.
                  // Relationship — the Terracotta — is reserved for a partner
                  // who is actually there.
                  tone: partnerName == null
                      ? DsAssetTone.primary
                      : DsAssetTone.relationship,
                  width: 22,
                  height: 22,
                ),
                const SizedBox(width: DsSpacing.space2),
                Flexible(
                  child: Text(
                    _label(L.of(context)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: DsTextStyles.bodySecondary.copyWith(
                      color: partnerName == null
                          ? DsColors.textOnRitualMuted
                          : DsColors.textOnRitualSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (onNotifications != null) ...[
            const SizedBox(width: DsSpacing.space2),
            Semantics(
              button: true,
              label: L.of(context).notificationsTitle,
              value: unread > 0 ? '$unread' : null,
              child: InkWell(
                onTap: onNotifications,
                borderRadius: BorderRadius.circular(24),
                child: SizedBox(
                  width: 44,
                  height: 48,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(
                        Icons.notifications_none_outlined,
                        size: 22,
                        color: DsColors.textOnRitualSecondary,
                      ),
                      if (unread > 0)
                        Positioned(
                          top: 8,
                          right: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: DsColors.textOnRitualPrimary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              unread > 99 ? '99+' : '$unread',
                              key: const ValueKey('unread-badge'),
                              style: DsTextStyles.bodySecondary.copyWith(
                                color: DsColors.canvasRitual,
                                fontSize: 11,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          if (onSettings != null) ...[
            const SizedBox(width: DsSpacing.space2),
            Semantics(
              button: true,
              label: L.of(context).settingsTitle,
              child: InkWell(
                onTap: onSettings,
                borderRadius: BorderRadius.circular(24),
                child: const SizedBox(
                  width: 48,
                  height: 48,
                  child: Center(
                    child: DsGlyphIcon(
                      DsGlyph.settings,
                      size: 22,
                      color: DsColors.textOnRitualSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
