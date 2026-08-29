// QA harness for SCR-01. Renders Today at the reference viewport with the
// bundled fonts and a fixed read model, so the result can be compared with the
// approved design without a running backend.
import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/providers.dart';
import 'domain_client/models/today_view.dart';
import 'domain_client/repositories/today_repository.dart';
import 'features/today/presentation/today_screen.dart';

class _Fixture implements TodayRepository {
  @override
  Future<TodayView> forDynamic(String dynamicId) async => TodayView(
    roleContext: 'PARTNER',
    relationshipDay: DateTime(2026, 8, 29),
    lastConfirmedAt: DateTime(2026, 8, 29, 21, 18),
    totalCount: 8,
    priorityItems: [
      const TodayItem(
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
    ],
    laterItems: const [
      TodayItem(
        occurrenceId: 'o4',
        title: "Read Morgan's note",
        state: 'ACTIVE',
      ),
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
    ],
    recentResponse: RecentResponse(
      occurrenceId: 'o1',
      title: 'Prepare the bedroom',
      type: 'ACKNOWLEDGE',
      text: 'I noticed your care.',
      sentAt: DateTime.now().subtract(const Duration(minutes: 12)),
      senderDisplayName: 'Morgan',
    ),
  );
}

void main() => runApp(
  ProviderScope(
    overrides: [todayRepositoryProvider.overrideWithValue(_Fixture())],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: DsTheme.ritual(),
      home: const TodayScreen(dynamicId: 'qa'),
    ),
  ),
);
