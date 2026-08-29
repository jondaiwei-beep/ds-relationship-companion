import 'package:dsapp/domain_client/models/occurrence.dart';
import 'package:dsapp/domain_client/models/occurrence_view.dart';
import 'package:dsapp/features/attention/presentation/respond_screen.dart';
import 'package:dsapp/features/today/presentation/acknowledgement_received_screen.dart';
import 'package:dsapp/features/today/presentation/waiting_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// UI-level defence of the product red lines.
///
/// The backend already enforces these structurally; these tests stop the UI
/// from *implying* something the domain forbids.
void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  /// The default 800x600 test surface is not a phone: content that scrolls on
  /// a real device sits off-screen here and cannot be tapped.
  Future<void> phone(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }

  final waiting = OccurrenceView(
    id: 'o1',
    title: 'Prepare the evening space',
    state: OccurrenceState.waitingAck,
    completedAt: DateTime(2026, 8, 27, 19, 42),
  );

  group('Red line #2 — Completion is not Acknowledgement', () {
    testWidgets('waiting screen says the moment is unfinished until a human responds',
        (tester) async {
      await tester.pumpWidget(wrap(WaitingScreen(occurrence: waiting)));

      // The distinction is now structural rather than repeated in prose:
      // the completed action is one settled line, and the largest region is
      // a space held open for words that have not arrived.
      expect(find.textContaining('You completed this'), findsOneWidget);
      expect(find.textContaining("Waiting for your partner's words"),
          findsOneWidget);
      expect(find.textContaining("We'll let you know when"), findsOneWidget);

      // Saying it four times across four containers made the screen anxious
      // and, worse, ended in a dark card that read as a status receipt —
      // closing the loop the copy insisted was open.
      expect(find.textContaining('Done —'), findsNothing);
      expect(find.textContaining('Nothing else is required'), findsNothing);
    });

    testWidgets('the waiting screen names the person, not a workflow state',
        (tester) async {
      await tester.pumpWidget(
          wrap(WaitingScreen(occurrence: waiting, partnerName: 'Alex')));

      // "Waiting for human response" sounds like a queue. This is one
      // person waiting on another.
      expect(find.textContaining("Waiting for Alex's words"), findsOneWidget);
      expect(find.textContaining('human response'), findsNothing);
    });

    testWidgets('waiting screen never claims the partner has already responded',
        (tester) async {
      await tester.pumpWidget(wrap(WaitingScreen(occurrence: waiting)));

      expect(find.textContaining('acknowledged'), findsNothing);
      expect(find.textContaining('Acknowledged'), findsNothing);
      expect(find.textContaining('You were seen'), findsNothing);
    });
  });

  group('Red line #1 — Automation prepares; the partner responds', () {
    testWidgets('respond screen starts EMPTY — no pre-filled system words',
        (tester) async {
      await tester.pumpWidget(
        wrap(RespondScreen(occurrence: waiting, partnerName: 'Jamie')),
      );

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(
        field.controller!.text, isEmpty,
        reason: 'pre-filling would make the default action "send words the system wrote"',
      );
    });

    testWidgets('send is disabled until the human writes something', (tester) async {
      await phone(tester);
      var sent = false;
      await tester.pumpWidget(wrap(RespondScreen(
        occurrence: waiting,
        partnerName: 'Jamie',
        onSend: (_, _) => sent = true,
      )));

      await tester.tap(find.textContaining('Send to'));
      await tester.pump();
      expect(sent, isFalse, reason: 'empty acknowledgement must not be sendable');

      await tester.enterText(find.byType(TextField), 'I saw this.');
      await tester.pump();
      await tester.tap(find.textContaining('Send to'));
      await tester.pump();
      expect(sent, isTrue);
    });

    testWidgets('suggestions are labelled as suggestions and only fill the field',
        (tester) async {
      await phone(tester);
      var sent = false;
      await tester.pumpWidget(wrap(RespondScreen(
        occurrence: waiting,
        partnerName: 'Jamie',
        onSend: (_, _) => sent = true,
      )));

      // Collapsed by default: rendered open, the panel was physically
      // larger than the writing surface.
      expect(find.text('Wording suggestion'), findsNothing);
      await tester.tap(find.text('Need a starting point?'));
      await tester.pumpAndSettle();
      expect(find.text('Wording suggestion'), findsOneWidget);
      expect(
        find.textContaining('your partner should still hear from you'),
        findsOneWidget,
      );

      await tester.tap(find.text('I noticed the care you put into this.'));
      await tester.pump();

      // Tapping a suggestion must NEVER send — it only fills the field.
      expect(sent, isFalse);
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller!.text, 'I noticed the care you put into this.');
    });

    testWidgets('the person is never asked to classify their own words',
        (tester) async {
      await phone(tester);
      await tester.pumpWidget(wrap(RespondScreen(
        occurrence: waiting,
        partnerName: 'Jamie',
        onSend: (_, _) {},
      )));

      // Filing your own sentence as Acknowledge / Praise / Comment is
      // administrative work, and "Praise" makes intimacy feel like picking
      // a system mode. The person writes what they mean.
      for (final mode in ['Acknowledge', 'Praise', 'Comment']) {
        expect(find.text(mode), findsNothing,
            reason: 'response type is a container value, not a choice');
      }
      // And the action names the person, not the system's word for it.
      expect(find.text('Send to Jamie'), findsOneWidget);
    });

    testWidgets('an untouched suggestion cannot be sent as your own words',
        (tester) async {
      await phone(tester);
      var sent = false;
      String? body;
      await tester.pumpWidget(wrap(RespondScreen(
        occurrence: waiting,
        partnerName: 'Jamie',
        onSend: (_, t) {
          sent = true;
          body = t;
        },
      )));

      await tester.tap(find.text('Need a starting point?'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('I noticed the care you put into this.'));
      await tester.pumpAndSettle();

      // Filling the field is not authorship. Pressing Send on words nobody
      // touched would put a sentence in a partner's mouth that no person
      // wrote — the exact thing red line #1 forbids.
      await tester.tap(find.textContaining('Send to'));
      await tester.pumpAndSettle();
      expect(sent, isFalse,
          reason: 'an unedited suggestion must not be sendable');

      // Once a human actually writes something, it goes.
      await tester.enterText(
          find.byType(TextField), 'I noticed the care you put into this. Thank you.');
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Send to'));
      await tester.pumpAndSettle();
      expect(sent, isTrue);
      expect(body, 'I noticed the care you put into this. Thank you.');
    });

    testWidgets('editing a suggestion down to nothing is not sendable either',
        (tester) async {
      await phone(tester);
      var sent = false;
      await tester.pumpWidget(wrap(RespondScreen(
        occurrence: waiting,
        partnerName: 'Jamie',
        onSend: (_, _) => sent = true,
      )));

      await tester.tap(find.text('Need a starting point?'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('I noticed the care you put into this.'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '   ');
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Send to'));
      await tester.pumpAndSettle();
      expect(sent, isFalse);
    });
  });

  group('Human response is visibly human', () {
    testWidgets('received screen attributes the words to the real sender',
        (tester) async {
      final acked = OccurrenceView(
        id: 'o1',
        title: 'Prepare the evening space',
        state: OccurrenceState.acknowledged,
        acknowledgement: AcknowledgementView(
          type: 'PRAISE',
          text: 'I noticed the care you put into this.',
          sentAt: DateTime(2026, 8, 27, 20, 6),
          senderDisplayName: 'Alex',
        ),
      );

      await tester.pumpWidget(wrap(AcknowledgementReceivedScreen(occurrence: acked)));

      expect(find.text('You were seen.'), findsOneWidget);
      expect(find.text('From Alex'.toUpperCase()), findsOneWidget);
      // Their words, verbatim.
      expect(find.text('I noticed the care you put into this.'), findsOneWidget);
    });
  });

  group('No gamification', () {
    testWidgets('no points, streaks, scores or trophies anywhere', (tester) async {
      for (final screen in [
        WaitingScreen(occurrence: waiting),
        RespondScreen(occurrence: waiting, partnerName: 'Jamie'),
      ]) {
        await tester.pumpWidget(wrap(screen));
        // Whole-word match: "starting point" is legitimate copy, "points" is not.
        final banned = RegExp(
          r'\b(points|streaks?|scores?|trophy|trophies|badges?|level up)\b',
          caseSensitive: false,
        );
        expect(
          find.byWidgetPredicate(
            (w) => w is Text && w.data != null && banned.hasMatch(w.data!),
          ),
          findsNothing,
          reason: 'gamification language must not appear',
        );
      }
    });
  });
}
