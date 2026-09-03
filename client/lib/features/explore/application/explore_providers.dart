import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../domain_client/models/explore.dart';

/// Kept alive across tab switches (see today_providers.dart for why); a
/// command invalidates what it changed, pull-to-refresh invalidates all.
final preferenceItemsProvider = FutureProvider.family<List<PreferenceItem>, String>(
  (ref, dynamicId) => ref.watch(exploreRepositoryProvider).items(dynamicId),
);

final compareProvider = FutureProvider.family<CompareView, String>(
  (ref, dynamicId) => ref.watch(exploreRepositoryProvider).compare(dynamicId),
);

final ideaCardsProvider = FutureProvider.family<List<IdeaCard>, String>(
  (ref, dynamicId) => ref.watch(exploreRepositoryProvider).cards(dynamicId),
);

final starterPacksProvider = FutureProvider<List<StarterPack>>(
  (ref) => ref.watch(exploreRepositoryProvider).packs(),
);
