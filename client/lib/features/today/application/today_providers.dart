import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../domain_client/models/d_note.dart';
import '../../../domain_client/models/today_view.dart';

/// The day as the server tells it. Reads happen when a person pulls, or when
/// a command they issued changes what the server would say.
final todayProvider = FutureProvider.family<TodayView, String>(
  (ref, dynamicId) => ref.watch(todayRepositoryProvider).today(dynamicId),
);

/// D face: what the s has said that has no answer yet, across all days.
final needsMeProvider = FutureProvider.family<List<OccurrenceView>, String>(
  (ref, dynamicId) => ref.watch(todayRepositoryProvider).needsMe(dynamicId),
);

/// D face: the D's own notes. Never shown to the s.
final dNotesProvider = FutureProvider.family<List<DNote>, String>(
  (ref, dynamicId) => ref.watch(dNoteRepositoryProvider).list(dynamicId),
);
