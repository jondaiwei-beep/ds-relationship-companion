import 'package:dsapp/app/providers.dart';
import 'package:dsapp/domain_client/models/notification_settings.dart';
import 'package:dsapp/domain_client/repositories/settings_repository.dart';
import 'package:dsapp/features/dynamic/presentation/quiet_hours_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _Repo extends Mock implements SettingsRepository {}

void main() {
  late _Repo repo;
  setUp(() => repo = _Repo());

  Future<void> pump(WidgetTester tester, NotificationSettings s) async {
    await tester.binding.setSurfaceSize(const Size(390, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    when(() => repo.notifications()).thenAnswer((_) async => s);
    when(() => repo.update(
          notificationPreview: any(named: 'notificationPreview'),
          quietHoursStartMin: any(named: 'quietHoursStartMin'),
          quietHoursEndMin: any(named: 'quietHoursEndMin'),
        )).thenAnswer((_) async => s);
    await tester.pumpWidget(ProviderScope(
      overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
      child: const MaterialApp(home: QuietHoursScreen()),
    ));
    await tester.pumpAndSettle();
  }

  String allText(WidgetTester tester) => tester
      .widgetList<Text>(find.byType(Text))
      .map((t) => t.data ?? '')
      .join(' | ');

  group('Quiet hours', () {
    testWidgets('states that these settings are the member\'s own',
        (tester) async {
      await pump(tester, const NotificationSettings(timezone: 'Asia/Shanghai'));

      // No role may reach into when a person is reachable, so the screen
      // says so rather than leaving them to wonder.
      expect(find.text('Only you can see or change this.'), findsOneWidget);
    });

    testWidgets('promises nothing is dropped while quiet', (tester) async {
      await pump(tester, const NotificationSettings(
        timezone: 'Asia/Shanghai',
        quietHoursStartMin: 1320,
        quietHoursEndMin: 420,
      ));

      // Going quiet must not feel like it costs you a partner's response.
      expect(allText(tester), contains('Nothing is dropped'));
    });

    testWidgets('shows the window in the member\'s own timezone',
        (tester) async {
      await pump(tester, const NotificationSettings(
        timezone: 'Asia/Shanghai',
        quietHoursStartMin: 22 * 60,
        quietHoursEndMin: 7 * 60,
      ));

      // A window means nothing without the zone it is measured in.
      expect(allText(tester), contains('Asia/Shanghai'));
      expect(find.text('22:00'), findsOneWidget);
      expect(find.text('07:00'), findsOneWidget);
    });

    testWidgets('neutral previews are the default and are described plainly',
        (tester) async {
      await pump(tester, const NotificationSettings());

      final text = allText(tester);
      expect(text, contains('Keep it neutral'));
      expect(text, contains('only that something is waiting'));
      // Red line #5: the safe option is the default, not something the
      // member has to discover and switch on.
      expect(find.text('Show more'), findsOneWidget);
    });

    testWidgets('a saved window is loaded, not overwritten by defaults',
        (tester) async {
      // 23:30 to 06:15 — deliberately not the screen's own default.
      await pump(tester, const NotificationSettings(
        quietHoursStartMin: 23 * 60 + 30,
        quietHoursEndMin: 6 * 60 + 15,
      ));

      expect(find.text('23:30'), findsOneWidget);
      expect(find.text('06:15'), findsOneWidget);

      // Saving without touching anything must round-trip the saved window.
      // Showing defaults over a saved value would silently discard it.
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      verify(() => repo.update(
            notificationPreview: 'NEUTRAL',
            quietHoursStartMin: 23 * 60 + 30,
            quietHoursEndMin: 6 * 60 + 15,
          )).called(1);
    });

    testWidgets('refuses a zero-length window instead of guessing',
        (tester) async {
      await pump(tester, const NotificationSettings(
        quietHoursStartMin: 22 * 60,
        quietHoursEndMin: 22 * 60,
      ));
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // It reads as both "never quiet" and "always quiet"; guessing wrong
      // means a 3am notification, or none ever.
      expect(allText(tester), contains('differ'));
      verifyNever(() => repo.update(
            notificationPreview: any(named: 'notificationPreview'),
            quietHoursStartMin: any(named: 'quietHoursStartMin'),
            quietHoursEndMin: any(named: 'quietHoursEndMin'),
          ));
    });

    testWidgets('turning quiet hours off clears both bounds', (tester) async {
      await pump(tester, const NotificationSettings(
        quietHoursStartMin: 22 * 60,
        quietHoursEndMin: 7 * 60,
      ));
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Half a window would suppress nothing while looking set.
      verify(() => repo.update(
            notificationPreview: 'NEUTRAL',
            quietHoursStartMin: null,
            quietHoursEndMin: null,
          )).called(1);
    });

    testWidgets('no judgemental or gamified vocabulary', (tester) async {
      await pump(tester, const NotificationSettings());
      final text = allText(tester).toLowerCase();
      for (final banned in [
        'disturb', 'ignore', 'mute', 'snooze', 'streak', 'score', 'miss',
      ]) {
        expect(text.contains(banned), isFalse,
            reason: 'quiet hours are a right, not an avoidance: "$banned"');
      }
    });
  });
}
