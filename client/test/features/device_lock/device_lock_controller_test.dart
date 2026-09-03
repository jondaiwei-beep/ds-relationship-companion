import 'package:dsapp/features/device_lock/application/authenticator.dart';
import 'package:dsapp/features/device_lock/application/device_lock_controller.dart';
import 'package:dsapp/features/device_lock/application/device_lock_store.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _Auth implements Authenticator {
  _Auth({this.available = true, this.passes = true});
  final bool available;
  bool passes;
  int prompts = 0;

  @override
  Future<bool> canAuthenticate() async => available;

  @override
  Future<bool> authenticate(String reason) async {
    prompts++;
    return passes;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  ProviderContainer build({required _Auth auth, required MemoryDeviceLockStore store, DateTime? now}) {
    final c = ProviderContainer(overrides: [
      authenticatorProvider.overrideWithValue(auth),
      deviceLockStoreProvider.overrideWithValue(store),
      clockProvider.overrideWithValue(() => now ?? DateTime.utc(2026, 9, 1, 12)),
    ]);
    addTearDown(c.dispose);
    // The app watches the provider from its first frame; reading it here is
    // that first frame.
    c.read(deviceLockProvider);
    return c;
  }

  test('starts locked when the preference is on, opens when the device vouches', () async {
    final auth = _Auth();
    final c = build(auth: auth, store: MemoryDeviceLockStore(enabled: true));
    expect(c.read(deviceLockProvider).ready, isFalse);
    await Future<void>.delayed(Duration.zero);
    expect(c.read(deviceLockProvider).ready, isTrue);
    expect(c.read(deviceLockProvider).locked, isTrue);

    final ok = await c.read(deviceLockProvider.notifier).unlock('why');
    expect(ok, isTrue);
    expect(c.read(deviceLockProvider).locked, isFalse);
  });

  test('a failed prompt keeps it locked', () async {
    final auth = _Auth(passes: false);
    final c = build(auth: auth, store: MemoryDeviceLockStore(enabled: true));
    await Future<void>.delayed(Duration.zero);
    expect(await c.read(deviceLockProvider.notifier).unlock('why'), isFalse);
    expect(c.read(deviceLockProvider).locked, isTrue);
  });

  test('a device that cannot authenticate never locks the person out', () async {
    final c = build(auth: _Auth(available: false), store: MemoryDeviceLockStore(enabled: true));
    await Future<void>.delayed(Duration.zero);
    final s = c.read(deviceLockProvider);
    expect(s.available, isFalse);
    expect(s.locked, isFalse);
  });

  test('turning it on asks first and persists only on success', () async {
    final auth = _Auth(passes: false);
    final store = MemoryDeviceLockStore();
    final c = build(auth: auth, store: store);
    await Future<void>.delayed(Duration.zero);

    await c.read(deviceLockProvider.notifier).setEnabled(true, reason: 'r');
    expect(store.enabled, isFalse);
    expect(c.read(deviceLockProvider).enabled, isFalse);

    auth.passes = true;
    await c.read(deviceLockProvider.notifier).setEnabled(true, reason: 'r');
    expect(store.enabled, isTrue);
    expect(c.read(deviceLockProvider).enabled, isTrue);
    expect(c.read(deviceLockProvider).locked, isFalse);
  });

  test('coming back after more than 30 seconds locks', () async {
    final store = MemoryDeviceLockStore(enabled: true);
    var now = DateTime.utc(2026, 9, 1, 12);
    final c = ProviderContainer(overrides: [
      authenticatorProvider.overrideWithValue(_Auth()),
      deviceLockStoreProvider.overrideWithValue(store),
      clockProvider.overrideWithValue(() => now),
    ]);
    addTearDown(c.dispose);
    c.read(deviceLockProvider);
    await Future<void>.delayed(Duration.zero);
    final n = c.read(deviceLockProvider.notifier);
    await n.unlock('r');
    expect(c.read(deviceLockProvider).locked, isFalse);

    n.didChangeAppLifecycleState(AppLifecycleState.paused);
    now = now.add(const Duration(seconds: 10));
    n.didChangeAppLifecycleState(AppLifecycleState.resumed);
    expect(c.read(deviceLockProvider).locked, isFalse);

    n.didChangeAppLifecycleState(AppLifecycleState.paused);
    now = now.add(const Duration(seconds: 45));
    n.didChangeAppLifecycleState(AppLifecycleState.resumed);
    expect(c.read(deviceLockProvider).locked, isTrue);
  });
}
