import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain_client/api_client.dart';
import '../domain_client/models/points.dart';
import '../domain_client/repositories/points_repository.dart';
import '../domain_client/repositories/auth_repository.dart';
import '../domain_client/repositories/dynamic_repository.dart';
import '../domain_client/repositories/invite_repository.dart';
import '../domain_client/repositories/starter_rhythm_repository.dart';
import '../domain_client/repositories/explore_repository.dart';
import '../domain_client/repositories/settings_repository.dart';
import '../domain_client/repositories/task_repository.dart';
import '../domain_client/repositories/d_note_repository.dart';
import '../domain_client/repositories/today_repository.dart';
import '../domain_client/repositories/record_repository.dart';
import '../domain_client/repositories/rule_repository.dart';
import '../domain_client/repositories/consequence_repository.dart';
import '../domain_client/repositories/media_repository.dart';
import '../domain_client/repositories/notification_repository.dart';
import '../features/dynamic/application/dynamic_providers.dart';
import '../platform/storage/auth_flow_store.dart';

/// Backend base URL. Overridden at build time with --dart-define.
const kApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8082',
);

/// Where the Web companion is served. An invite link must point at the
/// browser app, not at the API host — the partner opens it on their phone
/// without installing anything.
const kWebBaseUrl = String.fromEnvironment(
  'WEB_BASE_URL',
  defaultValue: 'http://localhost:8080',
);

String webBaseUrl() => kWebBaseUrl;

final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(baseUrl: kApiBaseUrl),
);

final inviteRepositoryProvider = Provider<InviteRepository>(
  (ref) => InviteRepository(ref.watch(apiClientProvider)),
);

final todayRepositoryProvider = Provider<TodayRepository>(
  (ref) => TodayRepository(ref.watch(apiClientProvider)),
);

final recordRepositoryProvider = Provider<RecordRepository>(
  (ref) => RecordRepository(ref.watch(apiClientProvider)),
);

final taskRepositoryProvider = Provider<TaskRepository>(
  (ref) => TaskRepository(ref.watch(apiClientProvider)),
);

final dNoteRepositoryProvider = Provider<DNoteRepository>(
  (ref) => DNoteRepository(ref.watch(apiClientProvider)),
);

final dynamicRepositoryProvider = Provider<DynamicRepository>(
  (ref) => DynamicRepository(ref.watch(apiClientProvider)),
);

final mediaRepositoryProvider = Provider<MediaRepository>(
  (ref) => MediaRepository(ref.watch(apiClientProvider)),
);

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => NotificationRepository(ref.watch(apiClientProvider)),
);

final pointsRepositoryProvider = Provider<PointsRepository>(
  (ref) => PointsRepository(ref.watch(apiClientProvider)),
);

final ruleRepositoryProvider = Provider<RuleRepository>(
  (ref) => RuleRepository(ref.watch(apiClientProvider)),
);

final consequenceRepositoryProvider = Provider<ConsequenceRepository>(
  (ref) => ConsequenceRepository(ref.watch(apiClientProvider)),
);

/// The s's balance and ledger, whichever face asks. Read once, then only when
/// asked or after a mutation — see `DsRefreshable`.
final pointsProvider = FutureProvider.family<PointsSummary, String>((ref, dynamicId) async {
  final subject = await ref.watch(sUserIdProvider(dynamicId).future);
  return ref.watch(pointsRepositoryProvider).summary(dynamicId, subjectUserId: subject);
});

/// Rewards with affordability answered against the s's balance.
final rewardsProvider = FutureProvider.family<List<Reward>, String>((ref, dynamicId) async {
  final subject = await ref.watch(sUserIdProvider(dynamicId).future);
  return ref.watch(pointsRepositoryProvider).rewards(dynamicId, subjectUserId: subject);
});

/// 惩罚库 — templates only. Nothing here is ever executed from here.
final agreementsProvider =
    FutureProvider.family<List<ConsequenceAgreement>, String>(
  (ref, dynamicId) => ref.watch(pointsRepositoryProvider).agreements(dynamicId),
);

final starterRhythmRepositoryProvider = Provider<StarterRhythmRepository>(
  (ref) => StarterRhythmRepository(ref.watch(apiClientProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(apiClientProvider)),
);

final exploreRepositoryProvider = Provider<ExploreRepository>(
  (ref) => ExploreRepository(ref.watch(apiClientProvider)),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(apiClientProvider)),
);

/// Platform-specific: localStorage on Web (the magic-link callback may open a
/// new tab), in-memory on Android.
final authFlowStoreProvider = Provider<AuthFlowStore>((ref) => AuthFlowStore());

// Who is signed in is owned by `sessionProvider` in
// platform/session/session_controller.dart. It is the only writer of the
// access token, so there is exactly one answer to that question.
