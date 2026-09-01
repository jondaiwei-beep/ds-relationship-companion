import 'package:dio/dio.dart';
import 'package:dsapp/app/providers.dart';
import 'package:dsapp/domain_client/models/attention_view.dart';
import 'package:dsapp/domain_client/repositories/occurrence_repository.dart';
import 'package:dsapp/features/response/presentation/attention_screen.dart';
import 'package:dsapp/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeOccurrences implements OccurrenceRepository {
  _FakeOccurrences({this.throws});

  final DioException? throws;
  final sends = <({String id, String type})>[];

  @override
  Future<void> acknowledge(
    String occurrenceId, {
    required String type,
    String text = '',
    required String idempotencyKey,
  }) async {
    sends.add((id: occurrenceId, type: type));
    if (throws case final e?) throw e;
  }

  @override
  Object noSuchMethod(Invocation i) => throw UnimplementedError('${i.memberName}');
}

AttentionItem _item(
  String id,
  String state,
  int priority, {
  String title = 'Something',
}) =>
    AttentionItem(
      occurrenceId: id,
      title: title,
      state: state,
      actorDisplayName: 'Morgan',
      occurredAt: DateTime.now().subtract(const Duration(hours: 2)),
      priority: priority,
    );

void main() {
  Future<({_FakeOccurrences repo, List<int> refreshes})> pump(
    WidgetTester tester,
    AttentionView view, {
    DioException? throws,
  }) async {
    final repo = _FakeOccurrences(throws: throws);
    final container = ProviderContainer(
      overrides: [occurrenceRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
    final refreshes = <int>[];
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: L.localizationsDelegates,
          supportedLocales: L.supportedLocales,
          home: AttentionScreen(
            view: view,
            partnerName: 'Morgan',
            onOpen: (_) {},
            onRefresh: () async => refreshes.add(1),
          ),
        ),
      ),
    );
    await tester.pump();
    return (repo: repo, refreshes: refreshes);
  }

  group('priority is the server\'s, and it is not negotiable', () {
    testWidgets('a conversation outranks a completion', (tester) async {
      await pump(
        tester,
        AttentionView(
          items: [
            _item('a', 'NEED_TO_DISCUSS', 1, title: 'Evening ritual'),
            _item('b', 'WAITING_ACK', 2, title: 'One honest sentence'),
            _item('c', 'NEEDS_REVIEW', 3, title: 'Daily check-in'),
          ],
          needsResponseCount: 2,
          needsReviewCount: 1,
        ),
      );

      // REQ-ATTN-001. Someone who asked to discuss is waiting on a
      // conversation, which outranks a completion waiting on a tap.
      final discuss = tester.getTopLeft(find.text('Evening ritual')).dy;
      final completion = tester.getTopLeft(find.text('One honest sentence')).dy;
      final review = tester.getTopLeft(find.text('Daily check-in')).dy;
      expect(discuss, lessThan(completion));
      expect(completion, lessThan(review));
    });

    testWidgets('sections are named for people, not for states', (
      tester,
    ) async {
      await pump(
        tester,
        AttentionView(items: [_item('a', 'NEED_TO_DISCUSS', 1)]),
      );

      expect(find.text('MORGAN IS WAITING'), findsOneWidget);
      // Backend state names never reach a person.
      expect(find.textContaining('NEED_TO_DISCUSS'), findsNothing);
    });

    testWidgets('past due is a prompt to look, not a penalty', (tester) async {
      await pump(
        tester,
        AttentionView(items: [_item('a', 'NEEDS_REVIEW', 3)]),
      );

      // REQ-REVIEW-001: the software assigns no punishment or consequence.
      expect(find.text('LOOK BACK TOGETHER'), findsOneWidget);
      for (final blame in ['Overdue', 'Missed', 'Late', 'Failed']) {
        expect(find.textContaining(blame), findsNothing);
      }
    });
  });

  group('answering inline', () {
    testWidgets('the first completion is answerable in one tap', (
      tester,
    ) async {
      final r = await pump(
        tester,
        AttentionView(items: [_item('a', 'WAITING_ACK', 2)]),
      );

      // REQ-ATTN-001 asks for common responses inline; REQ-ACK-001 puts basic
      // acknowledgement at two taps. Here it is one, because opening the
      // screen was the other.
      await tester.tap(find.text('Acknowledge'));
      await tester.pumpAndSettle();

      expect(r.repo.sends.single.type, 'ACKNOWLEDGE');
      expect(r.repo.sends.single.id, 'a');
    });

    testWidgets('only the first row carries them', (tester) async {
      await pump(
        tester,
        AttentionView(
          items: [
            _item('a', 'WAITING_ACK', 2, title: 'First'),
            _item('b', 'WAITING_ACK', 2, title: 'Second'),
          ],
        ),
      );

      // Offering them on every row turns answering into clearing a queue, and
      // this is the screen that must not read like a task list.
      expect(find.text('Acknowledge'), findsOneWidget);
    });

    testWidgets('a send asks the server again rather than editing the list', (
      tester,
    ) async {
      final r = await pump(
        tester,
        AttentionView(items: [_item('a', 'WAITING_ACK', 2)]),
      );
      await tester.tap(find.text('Praise'));
      await tester.pumpAndSettle();

      // A list that edits itself is a list that can disagree with the truth.
      expect(r.refreshes, hasLength(1));
    });

    testWidgets('an already-answered item refreshes, it does not fail', (
      tester,
    ) async {
      final r = await pump(
        tester,
        AttentionView(items: [_item('a', 'WAITING_ACK', 2)]),
        throws: DioException(
          requestOptions: RequestOptions(path: '/x'),
          response: Response(
            requestOptions: RequestOptions(path: '/x'),
            statusCode: 409,
            data: {'code': 'OCCURRENCE_NOT_WAITING_ACK'},
          ),
          type: DioExceptionType.badResponse,
        ),
      );
      await tester.tap(find.text('Acknowledge'));
      await tester.pumpAndSettle();

      expect(r.refreshes, hasLength(1));
      expect(find.textContaining("couldn't"), findsNothing);
    });
  });

  testWidgets('an empty list is a fact, not an achievement', (tester) async {
    await pump(tester, const AttentionView());

    expect(find.textContaining('Nothing is waiting'), findsOneWidget);
    // No points, streaks, scores or trophies anywhere.
    for (final reward in ['All caught up', 'Great', 'streak', 'Well done']) {
      expect(find.textContaining(reward), findsNothing);
    }
  });

  testWidgets('it fits 390x844 with a full list', (tester) async {
    await pump(
      tester,
      AttentionView(
        items: [
          _item('a', 'NEED_TO_DISCUSS', 1, title: 'Evening ritual'),
          _item('b', 'RESCHEDULE_REQUESTED', 1, title: 'Morning intention'),
          _item('c', 'WAITING_ACK', 2, title: 'One honest sentence'),
          _item('d', 'WAITING_ACK', 2, title: 'Prepare the evening'),
          _item('e', 'NEEDS_REVIEW', 3, title: 'Daily check-in'),
        ],
        needsResponseCount: 4,
        needsReviewCount: 1,
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
