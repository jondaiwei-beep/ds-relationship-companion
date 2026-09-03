import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../domain_client/models/rule.dart';
import '../../../domain_client/models/task.dart';

/// Standing rules, proposed ones included; archived left out.
final rulesProvider = FutureProvider.family<List<RuleView>, String>(
  (ref, dynamicId) => ref.watch(ruleRepositoryProvider).list(dynamicId),
);

/// Task definitions, proposed ones included; archived left out.
final taskDefinitionsProvider = FutureProvider.family<List<TaskView>, String>(
  (ref, dynamicId) => ref.watch(taskRepositoryProvider).list(dynamicId),
);
