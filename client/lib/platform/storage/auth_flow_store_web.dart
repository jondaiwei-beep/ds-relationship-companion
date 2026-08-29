import 'package:web/web.dart' as web;
import '../../domain_client/repositories/auth_repository.dart';
import 'auth_flow_store.dart';

/// Web: the magic-link callback may open in a NEW TAB, which does not share
/// `sessionStorage`. `localStorage` is used instead and cleared immediately on
/// consume so the verifier does not linger.
class AuthFlowStoreImpl implements AuthFlowStore {
  static const _prefix = 'auth.flow.';

  @override
  Future<void> save(AuthFlow flow) async =>
      web.window.localStorage.setItem('$_prefix${flow.flowId}', encodeFlow(flow));

  @override
  Future<AuthFlow?> load(String flowId) async {
    final raw = web.window.localStorage.getItem('$_prefix$flowId');
    return raw == null ? null : decodeFlow(raw);
  }

  @override
  Future<void> clear(String flowId) async =>
      web.window.localStorage.removeItem('$_prefix$flowId');
}
