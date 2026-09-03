import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// Proves the person holding the phone is its owner — fingerprint, face, or
/// the device PIN. Injected so the gate can be tested without a device.
abstract interface class Authenticator {
  /// Whether this device can vouch for its owner at all.
  Future<bool> canAuthenticate();

  /// True when the person passed. False when they did not, or gave up.
  Future<bool> authenticate(String reason);
}

/// `local_auth`, with every platform refusal read as "no".
class LocalAuthenticator implements Authenticator {
  LocalAuthenticator([LocalAuthentication? auth]) : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  @override
  Future<bool> canAuthenticate() async {
    try {
      return await _auth.isDeviceSupported();
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  @override
  Future<bool> authenticate(String reason) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(stickyAuth: true),
      );
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }
}
