import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../domain_client/models/record.dart';

/// Reads for 记录. Each is keyed by what it shows, so changing month or day
/// is a different read and an old one stays warm for the way back.

/// The month grid, keyed `(dynamicId, yyyy-MM)`.
final monthCellsProvider = FutureProvider.family<List<MonthCell>, (String, String)>(
  (ref, key) => ref.watch(recordRepositoryProvider).month(key.$1, key.$2),
);

/// One day, keyed `(dynamicId, yyyy-MM-dd)`.
final dayViewProvider = FutureProvider.family<DayView, (String, String)>(
  (ref, key) => ref.watch(recordRepositoryProvider).day(key.$1, key.$2),
);

/// Counts over a range, keyed `(dynamicId, from, to)`.
final factsProvider = FutureProvider.family<FactsView, (String, String, String)>(
  (ref, key) => ref.watch(recordRepositoryProvider).facts(key.$1, from: key.$2, to: key.$3),
);

/// daysTogether + currentStreak (D-27).
final recordSummaryProvider = FutureProvider.family<SummaryView, String>(
  (ref, dynamicId) => ref.watch(recordRepositoryProvider).summary(dynamicId),
);
