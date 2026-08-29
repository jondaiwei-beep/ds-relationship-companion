import 'package:dsapp/domain_client/repositories/adjustment_repository.dart';
import 'package:dsapp/features/attention/presentation/adjustment_sheet.dart';
import 'package:dsapp/features/attention/presentation/resolve_adjustment_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The adjustment UI — Journey D, red line #3.
///
/// The tone is the feature here. Asking to adjust must never read as a
/// confession, and answering must never read as granting permission.
void main() {
  Future<void> pumpAsk(WidgetTester tester,
      {Future<void> Function(AdjustmentType, String?)? onSubmit}) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AdjustmentSheet(onSubmit: onSubmit ?? (_, _) async {}),
      ),
    ));
    await tester.pumpAndSettle();
  }

  Future<void> pumpResolve(WidgetTester tester,
      {String type = 'EXCUSE_REQUESTED',
      String? note,
      Future<void> Function(AdjustmentResolution, String?)? onResolve}) async {
    await tester.binding.setSurfaceSize(const Size(390, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ResolveAdjustmentSheet(
          requesterName: 'Jamie',
          requestType: type,
          requestNote: note,
          onResolve: onResolve ?? (_, _) async {},
        ),
      ),
    ));
    await tester.pumpAndSettle();
  }

  group('Asking to adjust', () {
    testWidgets('all three asks are offered together', (tester) async {
      await pumpAsk(tester);

      // Notion 05 §2 fixes this vocabulary.
      expect(find.text('Need to discuss'), findsOneWidget);
      expect(find.text('Request a new time'), findsOneWidget);
      expect(find.text("I can't do this right now"), findsOneWidget);
    });

    testWidgets('it states plainly that none of this is a miss', (tester) async {
      await pumpAsk(tester);
      expect(find.textContaining('None of these is a missed expectation'), findsOneWidget);
    });

    testWidgets('the note is OPTIONAL - no reason is demanded', (tester) async {
      await pumpAsk(tester);

      // Requiring a reason would make this a justification form.
      expect(find.textContaining('OPTIONAL'), findsWidgets);   // the eyebrow
      expect(find.text('Optional'), findsOneWidget);            // the hint
      expect(find.textContaining('required'), findsNothing);
      expect(find.textContaining('Why'), findsNothing);
    });

    testWidgets('no apology or failure language anywhere', (tester) async {
      await pumpAsk(tester);

      final banned = RegExp(
        r'\b(sorry|apolog\w*|fail\w*|late|behind|owe)\b',
        caseSensitive: false,
      );
      expect(
        find.byWidgetPredicate((w) =>
            w is Text &&
            w.data != null &&
            // "None of these is a missed expectation" contains "missed"
            // precisely in order to deny it.
            !w.data!.contains('None of these') &&
            banned.hasMatch(w.data!)),
        findsNothing,
        reason: 'asking to adjust must not read as a confession',
      );
    });

    testWidgets('sending requires choosing something first', (tester) async {
      var sent = false;
      await pumpAsk(tester, onSubmit: (_, _) async => sent = true);

      await tester.tap(find.text('Send'));
      await tester.pumpAndSettle();
      expect(sent, isFalse);

      await tester.tap(find.text("I can't do this right now"));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Send'));
      await tester.pumpAndSettle();
      expect(sent, isTrue);
    });

    testWidgets('the chosen type reaches the caller', (tester) async {
      AdjustmentType? got;
      await pumpAsk(tester, onSubmit: (t, _) async => got = t);

      await tester.tap(find.text('Request a new time'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Send'));
      await tester.pumpAndSettle();

      expect(got, AdjustmentType.reschedule);
    });
  });

  group('Answering an adjustment', () {
    testWidgets('never uses approve or reject language', (tester) async {
      await pumpResolve(tester);

      // Framing this as permission would turn an ask about real life into a
      // request the other person may refuse.
      final banned = RegExp(r'\b(approve|approved|reject|deny|denied|permission|allow)\b',
          caseSensitive: false);
      expect(
        find.byWidgetPredicate((w) => w is Text && w.data != null && banned.hasMatch(w.data!)),
        findsNothing,
      );
    });

    testWidgets('the requester is named and their words shown verbatim',
        (tester) async {
      await pumpResolve(tester, note: 'I am ill today.');

      expect(find.textContaining('JAMIE'), findsWidgets);
      expect(find.text('I am ill today.'), findsOneWidget);
    });

    testWidgets('backend state names never leak', (tester) async {
      await pumpResolve(tester, type: 'RESCHEDULE_REQUESTED');

      expect(find.textContaining('JAMIE ASKED FOR A NEW TIME'), findsOneWidget);
      expect(find.textContaining('RESCHEDULE_REQUESTED'), findsNothing);
    });

    testWidgets('letting it go is offered as a clean ending', (tester) async {
      await pumpResolve(tester);

      expect(find.text('Let it go this time'), findsOneWidget);
      // "Owed" introduced a debt the product promises does not exist.
      expect(find.textContaining('Nothing carries over'), findsOneWidget);
      expect(find.textContaining('owed'), findsNothing);
    });

    testWidgets('rescheduling says the original stays on the record',
        (tester) async {
      await pumpResolve(tester);
      // The original is stored CANCELLED, so the copy must prevent it reading
      // as a failure the person caused.
      expect(find.textContaining('rescheduled'), findsOneWidget);
    });

    testWidgets('the chosen resolution reaches the caller', (tester) async {
      AdjustmentResolution? got;
      await pumpResolve(tester, onResolve: (r, _) async => got = r);

      await tester.tap(find.text('Let it go this time'));
      await tester.pumpAndSettle();
      // The final action names what will happen. A generic Send made the
      // choice read as a ruling awaiting confirmation.
      await tester.tap(find.text('Let it go'));
      await tester.pumpAndSettle();

      expect(got, AdjustmentResolution.excuse);
    });

    testWidgets('the answer matching the request comes first', (tester) async {
      await pumpResolve(tester);

      // A fixed order that always led with "Keep it as it is" meant the
      // first answer visually privileged not accommodating someone who had
      // specifically asked for a new time.
      final newTime = tester.getTopLeft(find.text('Give it a new time')).dy;
      final keep = tester.getTopLeft(find.text('Keep it as it is')).dy;
      expect(newTime < keep, isTrue,
          reason: 'they asked for a new time; offer it first');
    });
  });
}
