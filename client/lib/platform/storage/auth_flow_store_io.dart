import '../../domain_client/repositories/auth_repository.dart';
import 'auth_flow_store.dart';

/// Android / desktop: the process survives the magic-link round trip, so an
/// in-memory flow is sufficient and keeps the verifier off disk entirely.
class AuthFlowStoreImpl implements AuthFlowStore {
  final _flows = <String, AuthFlow>{};

  @override
  Future<void> save(AuthFlow flow) async => _flows[flow.flowId] = flow;

  @override
  Future<AuthFlow?> load(String flowId) async => _flows[flowId];

  @override
  Future<void> clear(String flowId) async => _flows.remove(flowId);
}
