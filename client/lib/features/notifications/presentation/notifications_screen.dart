import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/shell/ds_glyph.dart';
import '../../../app/shell/ds_refreshable.dart';
import '../../../domain_client/models/notification.dart';
import '../../../l10n/app_localizations.dart';
import '../../../platform/push/notification_sync.dart';
import '../../../platform/time/device_timezone.dart';
import '../../today/presentation/today_format.dart';
import '../../today/presentation/widgets/quiet_line.dart';
import '../../today/presentation/widgets/today_layout.dart';
import '../application/notification_providers.dart';

/// The inbox: what happened, newest first. Opening it reads everything —
/// a badge that lingers after the person has looked is a nag.
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key, this.onClose, this.onOpen});

  final VoidCallback? onClose;

  /// Where a tapped item goes; the path is already resolved for this app.
  final void Function(String route)? onOpen;

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  bool _marked = false;

  Future<void> _markAllRead(NotificationInbox inbox) async {
    if (_marked || inbox.unreadCount == 0) return;
    _marked = true;
    try {
      await ref.read(notificationRepositoryProvider).markRead(allBefore: DateTime.now().toUtc());
    } on Object {
      // The badge will say so next time; nothing else to do.
    }
    ref.invalidate(unreadCountProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final inbox = ref.watch(inboxProvider);
    ref.listen(inboxProvider, (_, next) {
      final value = next.value;
      if (value != null) _markAllRead(value);
    });
    final locale = Localizations.localeOf(context).toString();

    return Scaffold(
      backgroundColor: DsColors.canvasRitual,
      body: DsRitualSurface(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: todayInset.add(const EdgeInsets.symmetric(vertical: DsSpacing.space4)),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l.notificationsTitle,
                        style: DsTextStyles.bodyPrimary.copyWith(color: DsColors.textOnRitualPrimary),
                      ),
                    ),
                    if (widget.onClose != null)
                      GestureDetector(
                        onTap: widget.onClose,
                        behavior: HitTestBehavior.opaque,
                        child: DsGlyphIcon(DsGlyph.close, semanticLabel: l.settingsClose),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: DsRefreshable(
                  onRefresh: () => ref.refresh(inboxProvider.future),
                  child: inbox.when(
                    skipLoadingOnRefresh: true,
                    loading: () => const SizedBox.shrink(),
                    error: (_, _) => ListView(children: [QuietLine(l.notificationsLoadFailed)]),
                    data: (value) => value.items.isEmpty
                        ? ListView(children: [QuietLine(l.notificationsEmpty)])
                        : ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: value.items.length,
                            itemBuilder: (_, i) => _Item(
                              item: value.items[i],
                              locale: locale,
                              onTap: widget.onOpen == null
                                  ? null
                                  : () => widget.onOpen!(value.items[i].route),
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.item, required this.locale, this.onTap});

  final AppNotification item;
  final String locale;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final primary = item.unread ? DsColors.textOnRitualPrimary : DsColors.textOnRitualSecondary;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: todayInset.add(const EdgeInsets.symmetric(vertical: DsSpacing.space4)),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: DsColors.borderOnRitualHairline)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(item.title, style: DsTextStyles.bodyPrimary.copyWith(color: primary)),
                ),
                const SizedBox(width: DsSpacing.space3),
                Text(
                  TodayFormat.clock(item.createdAt, deviceTimezone() ?? 'UTC', locale),
                  style: DsTextStyles.bodySecondary.copyWith(color: DsColors.textOnRitualMuted),
                ),
              ],
            ),
            if (item.body.isNotEmpty) ...[
              const SizedBox(height: DsSpacing.space1),
              Text(
                item.body,
                style: DsTextStyles.bodySecondary.copyWith(color: DsColors.textOnRitualSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
