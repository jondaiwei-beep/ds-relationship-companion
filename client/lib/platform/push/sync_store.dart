import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// What the background fetch needs to know between runs, kept where the
/// refresh credential already lives. Both isolates read and write it.
class NotificationSyncStore {
  NotificationSyncStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _lastSeen = 'notif.lastSeen';
  static const _foreground = 'notif.foreground';

  /// The newest `createdAt` already announced on this device.
  Future<DateTime?> lastSeen() async {
    try {
      final raw = await _storage.read(key: _lastSeen);
      return raw == null ? null : DateTime.tryParse(raw);
    } catch (_) {
      return null;
    }
  }

  Future<void> setLastSeen(DateTime at) async {
    try {
      await _storage.write(key: _lastSeen, value: at.toUtc().toIso8601String());
    } catch (_) {}
  }

  /// Whether the app is on screen. The background fetch stands down while it
  /// is: the person can see the bell, and two isolates refreshing the same
  /// session at once would race over the rotated token.
  Future<bool> isForeground() async {
    try {
      return await _storage.read(key: _foreground) == '1';
    } catch (_) {
      return false;
    }
  }

  Future<void> setForeground(bool on) async {
    try {
      await _storage.write(key: _foreground, value: on ? '1' : '0');
    } catch (_) {}
  }
}
