/// When the lock screen must stand in front of the app.
///
/// Pure: no clock, no platform. The controller feeds it lifecycle events with
/// the time they happened, and reads [locked].
///
/// Rules: with the lock on, the app opens locked; going to the background and
/// coming back after more than [grace] locks it again; a shorter absence — a
/// notification glanced at, a call declined — does not. Turning the lock off
/// unlocks immediately, since the person just proved themselves to reach the
/// setting.
class DeviceLockGate {
  DeviceLockGate({this.grace = const Duration(seconds: 30)});

  final Duration grace;

  bool _enabled = false;
  bool _locked = false;
  DateTime? _hiddenAt;

  bool get enabled => _enabled;
  bool get locked => _locked;

  /// The stored preference, once read. Locks at once when turned on at launch.
  void launch({required bool enabled}) {
    _enabled = enabled;
    _locked = enabled;
  }

  void setEnabled(bool enabled) {
    _enabled = enabled;
    if (!enabled) _locked = false;
  }

  /// The app left the foreground.
  void hidden(DateTime now) {
    _hiddenAt ??= now;
  }

  /// The app is back in front.
  void resumed(DateTime now) {
    final since = _hiddenAt;
    _hiddenAt = null;
    if (!_enabled || since == null) return;
    if (now.difference(since) > grace) _locked = true;
  }

  /// The person passed the authenticator.
  void unlocked() {
    _locked = false;
  }
}
