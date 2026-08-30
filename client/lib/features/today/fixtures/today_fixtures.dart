import 'dart:async';

import 'package:dio/dio.dart';

import '../../../domain_client/models/today_view.dart';
import '../../../domain_client/repositories/today_repository.dart';

/// Fixtures for SCR-01, shared by the widget tests and the QA render harness.
///
/// They live in `lib` rather than `test` because the harness builds a real web
/// bundle and cannot import from the test tree. Nothing in the product imports
/// this file.
///
/// A Today matching the approved default composition: three priorities, five
/// later items, one partner response.
TodayView todayFixture({
  List<TodayItem>? priority,
  List<TodayItem>? later,
  RecentResponse? response,
  int? needsMyResponseCount,
}) {
  return TodayView(
    roleContext: 'PARTNER',
    needsMyResponseCount: needsMyResponseCount ?? 0,
    relationshipDay: DateTime(2026, 8, 29),
    lastConfirmedAt: DateTime(2026, 8, 29, 21, 18),
    totalCount: (priority ?? _priority).length + (later ?? _later).length,
    priorityItems: priority ?? _priority,
    laterItems: later ?? _later,
    recentResponse: response ?? _response,
  );
}

final _priority = [
  TodayItem(
    occurrenceId: 'o1',
    title: 'Prepare the bedroom before 9:00 PM.',
    state: 'ACTIVE',
    // What the server returns for an ACTIVE item the partner is assigned:
    // adjustment beside completion, never behind it.
    allowedActions: ['complete', 'discuss', 'reschedule', 'cant_do'],
    fromDisplayName: 'Morgan',
  ),
  TodayItem(
    occurrenceId: 'o2',
    title: 'Evening ritual',
    kind: 'RITUAL',
    state: 'ACTIVE',
    purpose: '6 min',
    dueAt: DateTime(2026, 8, 29, 20, 30).toUtc(),
  ),
  // Not a check-in. A check-in is a separate entity (mood/energy/need, via
  // `POST /v1/dynamics/{id}/check-ins`) and can never arrive as a Today item,
  // so a fixture named like one taught the wrong model to every preview.
  const TodayItem(
    occurrenceId: 'o3',
    title: 'A sentence about today',
    state: 'ACTIVE',
    purpose: 'Optional · private until shared',
  ),
];

const _later = [
  TodayItem(occurrenceId: 'o4', title: "Read Morgan's note", state: 'ACTIVE'),
  TodayItem(
    occurrenceId: 'o5',
    title: "Lay out tomorrow's clothes",
    state: 'ACTIVE',
  ),
  TodayItem(
    occurrenceId: 'o6',
    title: 'One honest journal sentence',
    state: 'ACTIVE',
  ),
  TodayItem(
    occurrenceId: 'o7',
    title: 'Drink water and reset',
    state: 'ACTIVE',
  ),
  TodayItem(
    occurrenceId: 'o8',
    title: 'Review the weekend plan',
    state: 'ACTIVE',
  ),
];

final _response = RecentResponse(
  occurrenceId: 'o1',
  title: 'Prepare the bedroom',
  type: 'ACKNOWLEDGE',
  text: 'I noticed your care.',
  sentAt: DateTime.now().subtract(const Duration(minutes: 12)),
  senderDisplayName: 'Morgan',
);

/// Which approved state to render. Each maps to a distinct outcome the screen
/// must handle, not merely to different content.
enum TodayFixtureState {
  /// Three priorities, five later items, one partner response.
  standard,

  /// The server confirms nothing is actionable today.
  empty,

  /// A Solo Dynamic: same grammar, no partner presence, no partner response.
  solo,

  /// Never completes — the screen must resolve access before revealing
  /// anything.
  loading,

  /// The connection failed. Only the last confirmed list may be shown, and
  /// every mutation is withdrawn.
  offline,

  /// Access can no longer be confirmed. All protected content is removed.
  authorizationLost,

  /// Any other failure.
  unavailable,
}

/// Serves a fixed outcome so a screen can be exercised without a backend.
class FixtureTodayRepository implements TodayRepository {
  FixtureTodayRepository([this.view, this.state = TodayFixtureState.standard]);

  /// Overrides the state's own view when supplied.
  final TodayView? view;

  final TodayFixtureState state;

  @override
  Future<TodayView> forDynamic(String dynamicId) {
    if (view != null) return Future.value(view);
    return switch (state) {
      TodayFixtureState.standard => Future.value(todayFixture()),
      TodayFixtureState.empty => Future.value(
        todayFixture(priority: const [], later: const [], response: null),
      ),
      TodayFixtureState.solo => Future.value(
        todayFixture(later: const [], response: null),
      ),
      // A future that never completes leaves the screen in its loading state.
      TodayFixtureState.loading => Completer<TodayView>().future,
      TodayFixtureState.offline => Future.error(
        DioException.connectionError(
          requestOptions: RequestOptions(path: '/v1/today'),
          reason: 'fixture',
        ),
      ),
      TodayFixtureState.authorizationLost => Future.error(
        DioException(
          requestOptions: RequestOptions(path: '/v1/today'),
          response: Response<void>(
            requestOptions: RequestOptions(path: '/v1/today'),
            statusCode: 401,
          ),
          type: DioExceptionType.badResponse,
        ),
      ),
      TodayFixtureState.unavailable => Future.error(
        DioException(
          requestOptions: RequestOptions(path: '/v1/today'),
          type: DioExceptionType.unknown,
        ),
      ),
    };
  }
}
