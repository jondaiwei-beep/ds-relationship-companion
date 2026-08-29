import 'package:dsapp/domain_client/models/today_view.dart';
import 'package:dsapp/domain_client/repositories/today_repository.dart';

/// A Today matching the approved SCR-01 default composition: three priorities,
/// five later items, one partner response.
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
    fromDisplayName: 'Morgan',
  ),
  TodayItem(
    occurrenceId: 'o2',
    title: 'Evening ritual',
    state: 'ACTIVE',
    purpose: '6 min',
    dueAt: DateTime(2026, 8, 29, 20, 30).toUtc(),
  ),
  const TodayItem(
    occurrenceId: 'o3',
    title: 'Daily check-in',
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

/// Serves a fixed Today so a screen can be rendered without a backend.
class FixtureTodayRepository implements TodayRepository {
  FixtureTodayRepository([this.view]);

  final TodayView? view;

  @override
  Future<TodayView> forDynamic(String dynamicId) async =>
      view ?? todayFixture();
}
