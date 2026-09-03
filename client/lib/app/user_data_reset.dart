import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/dynamic/application/dynamic_providers.dart';
import '../features/explore/application/explore_providers.dart';
import '../features/notifications/application/notification_providers.dart';
import '../features/points/application/points_providers.dart';
import '../features/record/application/record_providers.dart';
import '../features/rules/application/rules_providers.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/today/application/today_providers.dart';
import '../platform/session/session.dart';
import '../platform/session/session_controller.dart';
import 'providers.dart';

/// Forget everything read on behalf of the last person.
///
/// The data providers are kept alive across tab switches on purpose, which
/// also keeps them alive across a sign-out. On one phone passed between two
/// people that showed the second person the first one's Today — "waiting for
/// them to join" on the screen of the partner who had just joined — and would
/// show anything else the first person had loaded until each fetch came back.
/// A different person is a different world; nothing cached carries over.
void resetUserData(WidgetRef ref) {
  ref.invalidate(dynamicDetailProvider);
  ref.invalidate(sUserIdProvider);
  ref.invalidate(todayProvider);
  ref.invalidate(needsMeProvider);
  ref.invalidate(dNotesProvider);
  ref.invalidate(rulesProvider);
  ref.invalidate(taskDefinitionsProvider);
  ref.invalidate(pointsProvider);
  ref.invalidate(rewardsProvider);
  ref.invalidate(redemptionsProvider);
  ref.invalidate(pointsRulesProvider);
  ref.invalidate(consequencesProvider);
  ref.invalidate(monthCellsProvider);
  ref.invalidate(dayViewProvider);
  ref.invalidate(factsProvider);
  ref.invalidate(recordSummaryProvider);
  ref.invalidate(seriesProvider);
  ref.invalidate(measureTasksProvider);
  ref.invalidate(preferenceItemsProvider);
  ref.invalidate(compareProvider);
  ref.invalidate(ideaCardsProvider);
  ref.invalidate(unreadCountProvider);
  ref.invalidate(inboxProvider);
  ref.invalidate(muteSettingsProvider);
  ref.invalidate(notificationSettingsProvider);
}

/// Who is signed in, or null. Two [Authenticated] states for the same person
/// (a token refresh) are the same identity; a sign-out or a different person
/// is a change.
String? sessionIdentity(Session s) => s is Authenticated ? s.userId : null;

/// Wire [resetUserData] to the session: whenever the identity changes, the
/// caches go. Call once from the app root.
void watchIdentityForReset(WidgetRef ref) {
  ref.listenManual<Session>(sessionProvider, (previous, next) {
    final before = previous == null ? null : sessionIdentity(previous);
    final after = sessionIdentity(next);
    if (before != after) resetUserData(ref);
  });
}
