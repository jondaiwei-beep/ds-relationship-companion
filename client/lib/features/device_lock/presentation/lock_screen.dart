import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/shell/ds_primary_button.dart';
import '../../../l10n/app_localizations.dart';
import '../application/device_lock_controller.dart';

/// Stands in front of everything while the gate is closed. Asks the device
/// once on arrival; the button asks again.
class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _unlock());
  }

  Future<void> _unlock() async {
    if (_busy || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref.read(deviceLockProvider.notifier).unlock(L.of(context).lockReason);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Scaffold(
      backgroundColor: DsColors.canvasRitual,
      body: DsRitualSurface(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: DsSpacing.space5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(
                  child: DsSvg(
                    asset: DsAssets.stateLocked,
                    tone: DsAssetTone.primary,
                    width: 44,
                    height: 44,
                  ),
                ),
                const SizedBox(height: DsSpacing.space8),
                Text(
                  l.lockTitle,
                  textAlign: TextAlign.center,
                  style: DsTextStyles.bodyPrimary.copyWith(color: DsColors.textOnRitualPrimary),
                ),
                const SizedBox(height: DsSpacing.space8),
                DsPrimaryButton(label: l.lockUnlock, onPressed: _unlock, busy: _busy),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Wraps the router's page tree. While the preference is being read nothing
/// is drawn; while locked, only the lock screen is.
class DeviceLockShell extends ConsumerWidget {
  const DeviceLockShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lock = ref.watch(deviceLockProvider);
    if (!lock.ready) {
      return const Scaffold(backgroundColor: DsColors.canvasRitual, body: DsRitualSurface(child: SizedBox.expand()));
    }
    return Stack(
      children: [
        child,
        if (lock.locked) const Positioned.fill(child: LockScreen()),
      ],
    );
  }
}
