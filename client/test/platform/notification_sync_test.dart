import 'package:dsapp/domain_client/models/notification.dart';
import 'package:dsapp/domain_client/repositories/notification_repository.dart';
import 'package:dsapp/platform/push/local_notifier.dart';
import 'package:dsapp/platform/push/notification_sync.dart';
import 'package:dsapp/platform/push/sync_store.dart';
import 'package:flutter_test/flutter_test.dart';

AppNotification _n(String id, {DateTime? readAt, bool muted = false}) => AppNotification(
      id: id,
      dynamicId: 'dyn-1',
      eventType: 'occurrence_delivered',
      title: 'Mara 交了「洗碗」',
      body: '今晚 21:10，已经交了。',
      neutralBody: '有新动态。',
      deepLink: '/record/2026-09-01',
      createdAt: DateTime.utc(2026, 9, 1, 13),
      readAt: readAt,
      muted: muted,
    );

class _Repo implements NotificationRepository {
  _Repo(this.settings, this.items);
  final NotificationMuteSettings settings;
  final List<AppNotification> items;
  DateTime? sinceAsked;

  @override
  Future<NotificationMuteSettings> muteSettings() async => settings;
  @override
  Future<NotificationInbox> inbox({DateTime? since, int limit = 50}) async {
    sinceAsked = since;
    return NotificationInbox(items: items, unreadCount: items.where((i) => i.unread).length);
  }

  @override
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError('${i.memberName}');
}

class _Store extends NotificationSyncStore {
  DateTime? seen;
  @override
  Future<DateTime?> lastSeen() async => seen;
  @override
  Future<void> setLastSeen(DateTime at) async => seen = at;
}

class _Tray extends NoopLocalNotifier {
  final shown = <(String, String)>[];
  @override
  Future<void> show(int id, {required String title, required String body, String? payload}) async =>
      shown.add((title, body));
}

void main() {
  test('bodyFor picks the neutral line only when asked', () {
    final n = _n('1');
    expect(n.bodyFor(neutralLockscreen: false), '今晚 21:10，已经交了。');
    expect(n.bodyFor(neutralLockscreen: true), '有新动态。');
  });

  test('sync shows the real title and body by default', () async {
    final tray = _Tray();
    final store = _Store();
    final shown = await syncNewNotifications(
      repo: _Repo(const NotificationMuteSettings(), [_n('1')]),
      store: store,
      notifier: tray,
    );
    expect(shown, 1);
    expect(tray.shown.single, ('Mara 交了「洗碗」', '今晚 21:10，已经交了。'));
    expect(store.seen, DateTime.utc(2026, 9, 1, 13));
  });

  test('neutral lockscreen blanks the title and swaps the body', () async {
    final tray = _Tray();
    await syncNewNotifications(
      repo: _Repo(const NotificationMuteSettings(neutralLockscreen: true), [_n('1')]),
      store: _Store(),
      notifier: tray,
    );
    expect(tray.shown.single, ('', '有新动态。'));
  });

  test('read, muted, and already-seen items stay out of the tray', () async {
    final tray = _Tray();
    final store = _Store()..seen = DateTime.utc(2026, 9, 1, 13);
    final repo = _Repo(const NotificationMuteSettings(), [
      _n('1'),
      _n('2', readAt: DateTime.utc(2026, 9, 1, 14)),
      _n('3', muted: true),
    ]);
    expect(await syncNewNotifications(repo: repo, store: store, notifier: tray), 0);
    expect(repo.sinceAsked, DateTime.utc(2026, 9, 1, 13));
  });

  test('deep links land inside the Dynamic', () {
    expect(routeForDeepLink('/today', 'd1'), '/dynamics/d1/today');
    expect(routeForDeepLink('/rules', 'd1'), '/dynamics/d1/rules');
    expect(routeForDeepLink('/points', 'd1'), '/dynamics/d1/points');
    expect(routeForDeepLink('/record/2026-09-01', 'd1'), '/dynamics/d1/record/2026-09-01');
    expect(routeForDeepLink('/occurrences/x', 'd1'), '/dynamics/d1/today');
    expect(parseTrayPayload('d1|/rules'), ('d1', '/rules'));
  });
}
