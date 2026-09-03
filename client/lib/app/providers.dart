import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain_client/api_client.dart';
import '../domain_client/models/points.dart';
import '../domain_client/repositories/points_repository.dart';
import '../domain_client/repositories/attention_repository.dart';
import '../domain_client/repositories/adjustment_repository.dart';
import '../domain_client/repositories/auth_repository.dart';
import '../domain_client/repositories/dynamic_repository.dart';
import '../domain_client/repositories/invite_repository.dart';
import '../domain_client/repositories/occurrence_repository.dart';
import '../domain_client/repositories/starter_rhythm_repository.dart';
import '../domain_client/repositories/expectation_repository.dart';
import '../domain_client/repositories/explore_repository.dart';
import '../domain_client/repositories/settings_repository.dart';
import '../domain_client/repositories/today_repository.dart';
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

final occurrenceRepositoryProvider = Provider<OccurrenceRepository>(
  (ref) => OccurrenceRepository(ref.watch(apiClientProvider)),
);

final attentionRepositoryProvider = Provider<AttentionRepository>(
  (ref) => AttentionRepository(ref.watch(apiClientProvider)),
);

final todayRepositoryProvider = Provider<TodayRepository>(
  (ref) => TodayRepository(ref.watch(apiClientProvider)),
);

final dynamicRepositoryProvider = Provider<DynamicRepository>(
  (ref) => DynamicRepository(ref.watch(apiClientProvider)),
);

final pointsRepositoryProvider = Provider<PointsRepository>(
  (ref) => PointsRepository(ref.watch(apiClientProvider)),
);

/// Read once, then only when asked or after a mutation — see `DsRefreshable`.
final pointsProvider = FutureProvider.family<PointsSummary, String>(
  (ref, dynamicId) => ref.watch(pointsRepositoryProvider).summary(dynamicId),
);

final rewardsProvider = FutureProvider.family<List<Reward>, String>(
  (ref, dynamicId) => ref.watch(pointsRepositoryProvider).rewards(dynamicId),
);

final agreementsProvider =
    FutureProvider.family<List<ConsequenceAgreement>, String>(
  (ref, dynamicId) => ref.watch(pointsRepositoryProvider).agreements(dynamicId),
);

final adjustmentRepositoryProvider = Provider<AdjustmentRepository>(
  (ref) => AdjustmentRepository(ref.watch(apiClientProvider)),
);

final starterRhythmRepositoryProvider = Provider<StarterRhythmRepository>(
  (ref) => StarterRhythmRepository(ref.watch(apiClientProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(apiClientProvider)),
);

final expectationRepositoryProvider = Provider<ExpectationRepository>(
  (ref) => ExpectationRepository(ref.watch(apiClientProvider)),
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
