import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'refresh_store.dart';

/// Android: the refresh token is a credential, so it goes to the Keystore.
///
/// `SharedPreferences` would be simpler and wrong — it is world-readable on a
/// rooted device and survives in backups. For an app whose mere presence on a
/// phone is private, a leaked refresh token is not just an account risk.
///
/// The defaults are the right ones here: v10 encrypts through the Keystore on
/// its own, and `encryptedSharedPreferences` is deprecated and ignored.
class RefreshStoreImpl implements RefreshStore {
  RefreshStoreImpl({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'session.refresh';

  final FlutterSecureStorage _storage;

  /// A read that throws is treated as "no session", never as a crash.
  /// Keystore access can fail for reasons that have nothing to do with this
  /// app — a restored backup, a changed lock screen — and the correct
  /// response to all of them is the entrance, not a broken launch.
  @override
  Future<String?> read() async {
    try {
      return await _storage.read(key: _key);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> write(String token) async {
    try {
      await _storage.write(key: _key, value: token);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _storage.delete(key: _key);
    } catch (_) {
      // Nothing better to do. The session is already gone in memory, and the
      // server has revoked the token this would have deleted.
    }
  }
}
