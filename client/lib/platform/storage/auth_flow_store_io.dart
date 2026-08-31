import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain_client/repositories/auth_repository.dart';
import 'auth_flow_store.dart';

/// Android, iOS and desktop.
///
/// This was a plain in-memory Map, justified by "the app process survives the
/// round trip and the App Link returns to the same instance". That is an
/// assumption about Android, not a fact about it: completing a magic link
/// means leaving for a mail app, and a backgrounded process is killed whenever
/// the system wants the memory. When it is, the flow is gone and the link the
/// person just tapped cannot be completed.
///
/// The same secure storage that already holds the refresh token holds this.
/// It is short-lived by nature — cleared the moment the flow is consumed.
class AuthFlowStoreImpl implements AuthFlowStore {
  AuthFlowStoreImpl({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _prefix = 'auth.flow.';

  /// A Keystore call that never returns must not become a sign-in that never
  /// returns. Found in a widget test whose `pumpAndSettle` timed out — which
  /// on a device is a person watching a spinner forever with nothing to tap.
  /// The in-memory fallback below is what a timeout falls back to.
  static const _patience = Duration(seconds: 3);

  final FlutterSecureStorage _storage;

  @override
  Future<void> save(AuthFlow flow) async {
    try {
      await _storage
          .write(key: '$_prefix${flow.flowId}', value: encodeFlow(flow))
          .timeout(_patience);
      _fallback[flow.flowId] = flow;
    } catch (_) {
      // A Keystore that will not accept a write is not a reason to lose the
      // flow for the common case where the process is never killed.
      _fallback[flow.flowId] = flow;
    }
  }

  @override
  Future<AuthFlow?> load(String flowId) async {
    try {
      final raw =
          await _storage.read(key: '$_prefix$flowId').timeout(_patience);
      if (raw != null) return decodeFlow(raw);
    } catch (_) {
      // fall through to memory
    }
    return _fallback[flowId];
  }

  @override
  Future<void> clear(String flowId) async {
    _fallback.remove(flowId);
    try {
      await _storage.delete(key: '$_prefix$flowId').timeout(_patience);
    } catch (_) {
      // Nothing to do: it either never landed or is already gone.
    }
  }

  /// Also written on the happy path, so a Keystore that accepts a write and
  /// then stalls on the read still completes the round trip in the common
  /// case where the process was never killed.
  static final _fallback = <String, AuthFlow>{};
}
