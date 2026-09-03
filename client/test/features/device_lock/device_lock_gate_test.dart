import 'package:dsapp/features/device_lock/application/device_lock_gate.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final t0 = DateTime.utc(2026, 9, 1, 12);

  group('device lock gate', () {
    test('off: never locks', () {
      final gate = DeviceLockGate()..launch(enabled: false);
      expect(gate.locked, isFalse);
      gate.hidden(t0);
      gate.resumed(t0.add(const Duration(hours: 2)));
      expect(gate.locked, isFalse);
    });

    test('on: the app opens locked', () {
      final gate = DeviceLockGate()..launch(enabled: true);
      expect(gate.locked, isTrue);
      gate.unlocked();
      expect(gate.locked, isFalse);
    });

    test('a short absence does not lock', () {
      final gate = DeviceLockGate()
        ..launch(enabled: true)
        ..unlocked();
      gate.hidden(t0);
      gate.resumed(t0.add(const Duration(seconds: 30)));
      expect(gate.locked, isFalse, reason: 'exactly the grace is still inside it');
    });

    test('more than 30 seconds away locks again', () {
      final gate = DeviceLockGate()
        ..launch(enabled: true)
        ..unlocked();
      gate.hidden(t0);
      gate.resumed(t0.add(const Duration(seconds: 31)));
      expect(gate.locked, isTrue);
    });

    test('the first hide counts, not a later repeated one', () {
      final gate = DeviceLockGate()
        ..launch(enabled: true)
        ..unlocked();
      gate.hidden(t0);
      gate.hidden(t0.add(const Duration(seconds: 25)));
      gate.resumed(t0.add(const Duration(seconds: 40)));
      expect(gate.locked, isTrue);
    });

    test('resuming without having hidden does nothing', () {
      final gate = DeviceLockGate()
        ..launch(enabled: true)
        ..unlocked();
      gate.resumed(t0.add(const Duration(days: 1)));
      expect(gate.locked, isFalse);
    });

    test('turning the lock off unlocks; turning it on does not lock the open app', () {
      final gate = DeviceLockGate()..launch(enabled: true);
      gate.setEnabled(false);
      expect(gate.locked, isFalse);
      gate.setEnabled(true);
      expect(gate.locked, isFalse, reason: 'the person is here; they just chose it');
      gate.hidden(t0);
      gate.resumed(t0.add(const Duration(minutes: 1)));
      expect(gate.locked, isTrue);
    });
  });
}
