import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:dsapp/app/providers.dart';
import 'package:dsapp/domain_client/models/notification.dart';
import 'package:dsapp/domain_client/repositories/notification_repository.dart';
import 'package:dsapp/features/notifications/presentation/notifications_screen.dart';
import 'package:dsapp/features/today/presentation/today_screen.dart';
import 'package:dsapp/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tz;

import '../../support/phase3_fakes.dart';
import '../../support/today_fakes.dart';

class _Repo implements NotificationRepository {
  _Repo({this.unread = 0, this.items = const []});
  int unread;
  List<AppNotification> items;
  final readCalls = <DateTime?>[];

  @override
  Future<int> unreadCount() async => unread;
  @override
  Future<NotificationInbox> inbox({DateTime? since, int limit = 50}) async =>
      NotificationInbox(items: items, unreadCount: unread);
  @override
  Future<int> markRead({List<String>? ids, DateTime? allBefore}) async {
    readCalls.add(allBefore);
    final n = unread;
    unread = 0;
    return n;
  }

  @override
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError('${i.memberName}');
}

Widget _app(Widget home, _Repo repo) => ProviderScope(
      overrides: [
        notificationRepositoryProvider.overrideWithValue(repo),
        todayRepositoryProvider.overrideWithValue(FakeTodayRepository(view: sView())),
        dynamicRepositoryProvider.overrideWithValue(FakeDynamicRepository()),
        taskRepositoryProvider.overrideWithValue(FakeTaskRepository()),
      ],
      child: MaterialApp(
        theme: DsTheme.ritual(),
        locale: const Locale('zh'),
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        home: home,
      ),
    );

void main() {
  setUpAll(tz.initializeTimeZones);

  testWidgets('the bell on 今天 carries the unread count', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    var opened = 0;
    final repo = _Repo(unread: 3);
    await tester.pumpWidget(_app(
      TodayScreen(dynamicId: 'dyn-1', onSelectTab: (_) {}, onNotifications: () => opened++),
      repo,
    ));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('unread-badge')), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('unread-badge')));
    expect(opened, 1);
    // Tear down so the 60 s poll timer is disposed with the scope.
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('opening the inbox lists items and marks everything read', (tester) async {
    final repo = _Repo(unread: 2, items: [
      AppNotification(
        id: 'n1',
        dynamicId: 'dyn-1',
        eventType: 'occurrence_delivered',
        // The server's copy is generic English; the tile re-renders known
        // types in the reader's language.
        title: 'Delivered',
        body: 'Something was marked delivered.',
        neutralBody: '有新动态。',
        deepLink: '/record/2026-09-01',
        createdAt: DateTime.utc(2026, 9, 1, 13),
      ),
    ]);
    String? route;
    await tester.pumpWidget(_app(NotificationsScreen(onOpen: (r) => route = r), repo));
    await tester.pumpAndSettle();
    final l = L.of(tester.element(find.byType(NotificationsScreen)));
    expect(find.text(l.inboxOccurrenceDeliveredTitle), findsOneWidget);
    expect(find.text(l.inboxOccurrenceDeliveredBody), findsOneWidget);
    expect(repo.readCalls, hasLength(1));
    expect(repo.readCalls.single, isNotNull);
    await tester.tap(find.text(l.inboxOccurrenceDeliveredTitle));
    expect(route, '/dynamics/dyn-1/record/2026-09-01');
  });
}
