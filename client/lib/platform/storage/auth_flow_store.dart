import 'dart:convert';
import '../../domain_client/repositories/auth_repository.dart';
import 'auth_flow_store_io.dart'
    if (dart.library.js_interop) 'auth_flow_store_web.dart';

/// Persists the in-progress [AuthFlow] across the magic-link round trip.
///
/// Platform difference is real here (Notion 04 §1):
/// - **Web**: the callback may open in a NEW TAB, so `sessionStorage` is
///   unsuitable — `localStorage` is used and cleared on consume.
/// - **Android**: secure storage, not memory. Completing a magic link means
///   leaving for a mail app, and Android kills a backgrounded process whenever
///   it wants the memory — taking an in-memory flow with it, so the link the
///   person just tapped could not be completed.
abstract interface class AuthFlowStore {
  Future<void> save(AuthFlow flow);
  Future<AuthFlow?> load(String flowId);
  Future<void> clear(String flowId);

  factory AuthFlowStore() = AuthFlowStoreImpl;
}

/// Shared (de)serialization so both adapters agree on the format.
String encodeFlow(AuthFlow f) => jsonEncode(f.toJson());
AuthFlow decodeFlow(String s) =>
    AuthFlow.fromJson(jsonDecode(s) as Map<String, dynamic>);
