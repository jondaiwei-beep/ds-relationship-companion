import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../domain_client/models/dynamic_view.dart';
import '../../../platform/session/session.dart';
import '../../../platform/session/session_controller.dart';

/// Kept alive across tab switches: `autoDispose` meant leaving a surface
/// destroyed its data, so coming back always refetched. Fetching is something
/// a person asks for — pull to refresh — or something a command causes.
final dynamicDetailProvider = FutureProvider.family<DynamicDetail, String>(
  (ref, dynamicId) => ref.watch(dynamicRepositoryProvider).detail(dynamicId),
);

/// Who the viewer is, from the `sub` in their own session token.
///
/// Not from the members list's order: it comes back CREATOR-first whatever
/// the caller's role, so position says nothing about who is asking.
final dynamicViewerIdProvider = Provider<String?>((ref) {
  final session = ref.watch(sessionProvider);
  return session is Authenticated ? session.userId : null;
});

/// The s member's user id, or null while nobody sits on that side.
///
/// Points belong to the s (product/03-domain.md · PointsLedger.member_id),
/// so every points read and every award names them, whichever face is asking.
final sUserIdProvider = FutureProvider.family<String?, String>((ref, dynamicId) async {
  final detail = await ref.watch(dynamicDetailProvider(dynamicId).future);
  for (final m in detail.members) {
    if (m.side == 'S') return m.userId;
  }
  return null;
});
