import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../domain_client/models/consequence.dart';
import '../../../domain_client/models/points.dart';
import '../../../domain_client/models/redemption.dart';

/// Every ask, in every state. Both faces see the same list.
final redemptionsProvider = FutureProvider.family<List<RedemptionView>, String>(
  (ref, dynamicId) => ref.watch(pointsRepositoryProvider).redemptions(dynamicId),
);

/// 「规则可见」: which tasks pay.
final pointsRulesProvider = FutureProvider.family<List<PointsRule>, String>(
  (ref, dynamicId) => ref.watch(pointsRepositoryProvider).pointsRules(dynamicId),
);

/// 罚: what the D issued and where each stands. No clock on any of it.
final consequencesProvider = FutureProvider.family<List<ConsequenceView>, String>(
  (ref, dynamicId) => ref.watch(consequenceRepositoryProvider).list(dynamicId),
);
