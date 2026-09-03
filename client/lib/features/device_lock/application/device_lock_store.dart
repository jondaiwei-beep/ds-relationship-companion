import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Whether the person turned the device lock on. Kept in the keystore because
/// the flag guards everything else; a plain preference could be flipped by
/// anything that can write to app storage.
abstract interface class DeviceLockStore {
  Future<bool> isEnabled();
  Future<void> setEnabled(bool enabled);

  factory DeviceLockStore() = SecureDeviceLockStore;
}

const deviceLockStorageKey = 'app.deviceLock';

class SecureDeviceLockStore implements DeviceLockStore {
  SecureDeviceLockStore([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<bool> isEnabled() async {
    try {
      return await _storage.read(key: deviceLockStorageKey) == 'on';
    } on Object {
      return false;
    }
  }

  @override
  Future<void> setEnabled(bool enabled) async {
    try {
      if (enabled) {
        await _storage.write(key: deviceLockStorageKey, value: 'on');
      } else {
        await _storage.delete(key: deviceLockStorageKey);
      }
    } on Object {
      // The choice applies to this session; persistence is what was lost.
    }
  }
}

/// For tests and previews.
class MemoryDeviceLockStore implements DeviceLockStore {
  MemoryDeviceLockStore({this.enabled = false});
  bool enabled;

  @override
  Future<bool> isEnabled() async => enabled;

  @override
  Future<void> setEnabled(bool value) async => enabled = value;
}
