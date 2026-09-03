import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'authenticator.dart';
import 'device_lock_gate.dart';
import 'device_lock_store.dart';

final authenticatorProvider = Provider<Authenticator>((ref) => LocalAuthenticator());
final deviceLockStoreProvider = Provider<DeviceLockStore>((ref) => DeviceLockStore());

/// Injected in tests; the wall clock otherwise.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

class DeviceLockState {
  const DeviceLockState({
    required this.ready,
    required this.enabled,
    required this.locked,
    required this.available,
  });

  /// False until the stored preference has been read. Nothing protected is
  /// drawn before then.
  final bool ready;
  final bool enabled;
  final bool locked;

  /// Whether this device can authenticate at all.
  final bool available;

  DeviceLockState copyWith({bool? ready, bool? enabled, bool? locked, bool? available}) =>
      DeviceLockState(
        ready: ready ?? this.ready,
        enabled: enabled ?? this.enabled,
        locked: locked ?? this.locked,
        available: available ?? this.available,
      );
}

/// Owns the gate, listens to the app lifecycle, and talks to the authenticator.
class DeviceLockController extends Notifier<DeviceLockState> with WidgetsBindingObserver {
  final _gate = DeviceLockGate();
  bool _authenticating = false;

  @override
  DeviceLockState build() {
    WidgetsBinding.instance.addObserver(this);
    ref.onDispose(() => WidgetsBinding.instance.removeObserver(this));
    Future<void>.microtask(_load);
    return const DeviceLockState(ready: false, enabled: false, locked: false, available: false);
  }

  Future<void> _load() async {
    final store = ref.read(deviceLockStoreProvider);
    final auth = ref.read(authenticatorProvider);
    final enabled = await store.isEnabled();
    final available = await auth.canAuthenticate();
    // A lock that cannot be opened is a locked-out person. If the device lost
    // the ability to authenticate, the app opens rather than bricks.
    _gate.launch(enabled: enabled && available);
    _publish(ready: true, available: available);
  }

  void _publish({bool? ready, bool? available}) {
    state = DeviceLockState(
      ready: ready ?? state.ready,
      enabled: _gate.enabled,
      locked: _gate.locked,
      available: available ?? state.available,
    );
  }

  // `state` is the notifier's own value here; the lifecycle gets another name.
  @override
  // ignore: avoid_renaming_method_parameters
  void didChangeAppLifecycleState(AppLifecycleState lifecycle) {
    final now = ref.read(clockProvider)();
    switch (lifecycle) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        _gate.hidden(now);
      case AppLifecycleState.resumed:
        _gate.resumed(now);
        _publish();
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        break;
    }
  }

  /// Show the system prompt and open the app if it passes.
  Future<bool> unlock(String reason) async {
    if (_authenticating) return false;
    _authenticating = true;
    try {
      final ok = await ref.read(authenticatorProvider).authenticate(reason);
      if (ok) {
        _gate.unlocked();
        _publish();
      }
      return ok;
    } finally {
      _authenticating = false;
    }
  }

  /// Turning it on asks for authentication first, so nobody locks themselves
  /// out with a method the device will not honour.
  Future<void> setEnabled(bool enabled, {required String reason}) async {
    if (enabled) {
      final ok = await ref.read(authenticatorProvider).authenticate(reason);
      if (!ok) return;
    }
    _gate.setEnabled(enabled);
    _publish();
    await ref.read(deviceLockStoreProvider).setEnabled(enabled);
  }
}

final deviceLockProvider =
    NotifierProvider<DeviceLockController, DeviceLockState>(DeviceLockController.new);
