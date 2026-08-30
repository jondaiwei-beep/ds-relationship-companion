import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:dsapp/domain_client/models/occurrence.dart';
import 'package:dsapp/domain_client/models/occurrence_view.dart';
import 'package:dsapp/features/response/presentation/waiting_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

OccurrenceView _occurrence({
  AcknowledgementView? acknowledgement,
  String? privateNote,
}) =>
    OccurrenceView(
      id: 'occ-1',
      title: 'Evening ritual',
      state: OccurrenceState.waitingAck,
      completedAt: DateTime.utc(2026, 8, 30, 21, 14),
      partnerDisplayName: 'Morgan',
      acknowledgement: acknowledgement,
      privateNote: privateNote,
    );

void main() {
  Future<void> pump(WidgetTester tester, OccurrenceView occurrence) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: WaitingScreen(occurrence: occurrence, onClose: () {}),
      ),
    );
    await tester.pump();
  }

  group('completion is never acknowledgement', () {
    testWidgets('a completed moment reads as unfinished', (tester) async {
      await pump(tester, _occurrence());

      // REQ-COMPLETE-001. The screen must say the moment is still open and
      // who closes it — never anything that reads as done.
      expect(find.textContaining('Your part is complete'), findsOneWidget);
      expect(find.textContaining('has not responded yet'), findsOneWidget);
      expect(find.textContaining('WAITING FOR MORGAN'), findsOneWidget);
      // Present tense only. "Morgan will respond" commits another human to an
      // action they have not taken — the app speaking for them.
      expect(find.textContaining('will respond'), findsNothing);
    });

    testWidgets('it never claims the partner has responded', (tester) async {
      await pump(tester, _occurrence());

      for (final closure in [
        'Done', 'Complete!', 'acknowledged', 'You are seen',
      ]) {
        expect(
          find.textContaining(closure),
          findsNothing,
          reason: '"$closure" would say the loop closed when it has not',
        );
      }
    });

    testWidgets('the second node is empty until a human answers', (
      tester,
    ) async {
      await pump(tester, _occurrence());
      final waiting = tester.widgetList<Container>(find.byType(Container));

      // Drawn rather than argued: completion is one node, and it is not the
      // last one. Two nodes exist and only one is filled.
      expect(find.textContaining('COMPLETED'), findsWidgets);
      expect(find.textContaining('WAITING FOR'), findsOneWidget);
      expect(waiting, isNotEmpty);
    });
  });

  group('the answer is the partner\'s, and looks like it', () {
    testWidgets('their words are visually distinct from system copy', (
      tester,
    ) async {
      await pump(
        tester,
        _occurrence(
          acknowledgement: AcknowledgementView(
            type: 'PRAISE',
            text: 'I noticed your care and intention tonight.',
            sentAt: DateTime.utc(2026, 8, 30, 21, 26),
            senderDisplayName: 'Morgan',
          ),
        ),
      );

      final words = tester.widget<Text>(
        find.text('I noticed your care and intention tonight.'),
      );
      // REQ-ACK-001: partner-authored content is visually distinct. Cormorant
      // in Terracotta, which nothing the system says ever uses.
      expect(words.style!.fontFamily, contains('Cormorant'));
      expect(words.style!.color, DsColors.textOnRitualRelationshipLarge);
      expect(find.text('You are seen.'), findsOneWidget);
    });

    testWidgets('a wordless acknowledgement is not filled in', (tester) async {
      await pump(
        tester,
        _occurrence(
          acknowledgement: AcknowledgementView(
            type: 'ACKNOWLEDGE',
            text: '',
            sentAt: DateTime.utc(2026, 8, 30, 21, 26),
            senderDisplayName: 'Morgan',
          ),
        ),
      );

      // A wordless acknowledgement is a real human response. The screen
      // reports and attributes it; it does not invent a sentence Morgan did
      // not say (red line #1).
      expect(find.text('Morgan acknowledged this.'), findsOneWidget);
      expect(find.textContaining('I noticed'), findsNothing);
      expect(find.textContaining('felt'), findsNothing);
    });
  });

  testWidgets('the words are attributed to their real sender', (tester) async {
    await pump(
      tester,
      _occurrence(
        acknowledgement: AcknowledgementView(
          type: 'ACKNOWLEDGE',
          text: '',
          sentAt: DateTime.utc(2026, 8, 30, 21, 26),
          // Deliberately not the occurrence's partnerDisplayName. On a Dynamic
          // these are the same person today; attributing by role rather than
          // by record is how a screen names the wrong human the first time
          // they are not (`ui-invariants.md`).
          senderDisplayName: 'Sam',
        ),
      ),
    );

    expect(find.text('Sam acknowledged this.'), findsOneWidget);
    expect(find.textContaining('Morgan acknowledged'), findsNothing);
  });

  group('the private note stays private', () {
    testWidgets('it is labelled as only the author sees it', (tester) async {
      await pump(tester, _occurrence(privateNote: 'I felt calm and focused.'));

      // The server returns this only to its author, so the label is true of
      // everyone who can read the screen.
      expect(find.text('PRIVATE NOTE · ONLY YOU'), findsOneWidget);
      expect(find.text('I felt calm and focused.'), findsOneWidget);
    });

    testWidgets('no note means no empty box', (tester) async {
      await pump(tester, _occurrence());

      expect(find.textContaining('PRIVATE NOTE'), findsNothing);
    });
  });

  testWidgets('both ends fit 390x844', (tester) async {
    await pump(tester, _occurrence(privateNote: 'A note.'));
    expect(tester.takeException(), isNull);

    await pump(
      tester,
      _occurrence(
        acknowledgement: AcknowledgementView(
          type: 'COMMENT',
          text: 'A much longer response that runs onto several lines, as a '
              'real person writing something considered would.',
          sentAt: DateTime.utc(2026, 8, 30, 21, 26),
          senderDisplayName: 'Morgan',
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
