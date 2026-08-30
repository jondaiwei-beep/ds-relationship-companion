import 'package:dio/dio.dart';
import 'package:dsapp/app/providers.dart';
import 'package:dsapp/domain_client/repositories/occurrence_repository.dart';
import 'package:dsapp/features/response/application/response_actions.dart';
import 'package:dsapp/features/response/presentation/response_composer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeOccurrences implements OccurrenceRepository {
  _FakeOccurrences({this.throws});

  final DioException? throws;
  final sends = <({String type, String text, String key})>[];

  @override
  Future<void> acknowledge(
    String occurrenceId, {
    required String type,
    String text = '',
    required String idempotencyKey,
  }) async {
    sends.add((type: type, text: text, key: idempotencyKey));
    if (throws case final e?) throw e;
  }

  @override
  Object noSuchMethod(Invocation i) => throw UnimplementedError('${i.memberName}');
}

DioException _coded(String code, {int status = 409}) => DioException(
      requestOptions: RequestOptions(path: '/x'),
      response: Response(
        requestOptions: RequestOptions(path: '/x'),
        statusCode: status,
        data: {'code': code},
      ),
      type: DioExceptionType.badResponse,
    );

void main() {
  Future<({_FakeOccurrences repo, List<int> sent})> pump(
    WidgetTester tester, {
    DioException? throws,
  }) async {
    final repo = _FakeOccurrences(throws: throws);
    final container = ProviderContainer(
      overrides: [occurrenceRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
    final sent = <int>[];
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: ResponseComposer(
            occurrenceId: 'occ-1',
            partnerName: 'Morgan',
            expectationTitle: 'Evening ritual',
            completedAt: '9:14 PM',
            onSent: () => sent.add(1),
            onDismiss: () {},
          ),
        ),
      ),
    );
    await tester.pump();
    return (repo: repo, sent: sent);
  }

  group('only an explicit human Send creates an acknowledgement', () {
    testWidgets('the field starts empty — nothing is written for anyone', (
      tester,
    ) async {
      await pump(tester);

      // Red line #1. A person who taps Send on words they did not write has
      // not said anything, and the recipient cannot tell the difference.
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller!.text, isEmpty);
    });

    testWidgets('opening and leaving sends nothing', (tester) async {
      final r = await pump(tester);
      await tester.tap(find.text('Not now'));
      await tester.pump();

      expect(r.repo.sends, isEmpty);
    });

    testWidgets('choosing a type alone sends nothing', (tester) async {
      final r = await pump(tester);
      await tester.tap(find.text('Praise'));
      await tester.pump();

      expect(r.repo.sends, isEmpty);
    });
  });

  group('basic acknowledgement is two taps', () {
    testWidgets('type, then Send — no words needed', (tester) async {
      final r = await pump(tester);

      // REQ-ACK-001's floor. Requiring words would mean someone with nothing
      // to add cannot answer at all, and silence would stand in for an
      // answer. It must not: only a send closes the loop.
      await tester.tap(find.text('Acknowledge'));
      await tester.tap(find.text('Send to Morgan'));
      await tester.pumpAndSettle();

      expect(r.repo.sends.single.type, 'ACKNOWLEDGE');
      expect(r.repo.sends.single.text, isEmpty);
      expect(r.sent, hasLength(1));
    });

    testWidgets('Praise also sends wordlessly', (tester) async {
      final r = await pump(tester);
      await tester.tap(find.text('Praise'));
      await tester.tap(find.text('Send to Morgan'));
      await tester.pumpAndSettle();

      expect(r.repo.sends.single.type, 'PRAISE');
    });
  });

  group('a comment without words is nothing, not a quiet comment', () {
    testWidgets('it is refused before a request goes out', (tester) async {
      final r = await pump(tester);
      await tester.tap(find.text('Comment'));
      await tester.pump();
      await tester.tap(find.text('Send to Morgan'));
      await tester.pumpAndSettle();

      expect(r.repo.sends, isEmpty, reason: 'told beside the field, not by a round trip');
      expect(find.textContaining('needs your words'), findsOneWidget);
    });

    testWidgets('whitespace is not words', (tester) async {
      final r = await pump(tester);
      await tester.tap(find.text('Comment'));
      await tester.pump();
      await tester.enterText(find.byType(TextField), '   ');
      await tester.tap(find.text('Send to Morgan'));
      await tester.pumpAndSettle();

      expect(r.repo.sends, isEmpty);
    });

    testWidgets('with words it sends what the person typed', (tester) async {
      final r = await pump(tester);
      await tester.tap(find.text('Comment'));
      await tester.pump();
      await tester.enterText(find.byType(TextField), '  I noticed your care.  ');
      await tester.tap(find.text('Send to Morgan'));
      await tester.pumpAndSettle();

      expect(r.repo.sends.single.type, 'COMMENT');
      expect(r.repo.sends.single.text, 'I noticed your care.');
    });
  });

  group('an already-answered moment is not a failure', () {
    testWidgets('it says so, and does not invite a second send', (
      tester,
    ) async {
      // The code the server actually sends (`ApiErrors.kt`). An earlier draft
      // guessed `ALREADY_ACKNOWLEDGED`, which exists nowhere — so every real
      // conflict fell through to "couldn't send" and invited a third attempt.
      await pump(tester, throws: _coded('OCCURRENCE_NOT_WAITING_ACK'));
      await tester.tap(find.text('Send to Morgan'));
      await tester.pumpAndSettle();

      expect(find.textContaining('already'), findsOneWidget);
      expect(find.text('Send to Morgan'), findsNothing);
      // Nothing here reads as a mistake the person made.
      expect(find.textContaining("couldn't"), findsNothing);
      expect(find.textContaining('failed'), findsNothing);
    });
  });

  group('the send is deliberate, and retrying is safe', () {
    testWidgets('the same words retry under the same key', (tester) async {
      final r = await pump(tester, throws: _coded('X', status: 500));
      await tester.tap(find.text('Send to Morgan'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Send to Morgan'));
      await tester.pumpAndSettle();

      expect(r.repo.sends, hasLength(2));
      expect(
        r.repo.sends[0].key,
        r.repo.sends[1].key,
        reason: 'a retry of the same words is the same send, not a second one',
      );
    });

    testWidgets('edited words are honestly a different send', (tester) async {
      final r = await pump(tester, throws: _coded('X', status: 500));
      await tester.tap(find.text('Comment'));
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'first');
      await tester.tap(find.text('Send to Morgan'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'second');
      await tester.tap(find.text('Send to Morgan'));
      await tester.pumpAndSettle();

      expect(r.repo.sends[0].key, isNot(r.repo.sends[1].key));
    });
  });

  testWidgets('the system never speaks in the partner\'s voice', (
    tester,
  ) async {
    await pump(tester);

    // Every string on this screen is either a fact about what happened or a
    // label on a control. Nothing is phrased as something Morgan said.
    for (final ghost in ['Morgan says', 'Morgan wrote', 'Morgan felt']) {
      expect(find.textContaining(ghost), findsNothing);
    }
  });

  testWidgets('it fits 390x844 in every type', (tester) async {
    for (final type in HumanResponse.values) {
      await pump(tester);
      await tester.tap(find.text(type.label));
      await tester.pump();
      expect(tester.takeException(), isNull, reason: '${type.label} overflowed');
    }
  });
}
