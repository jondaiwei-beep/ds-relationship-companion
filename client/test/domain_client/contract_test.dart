import 'dart:convert';
import 'package:dsapp/domain_client/models/attention_view.dart';
import 'package:dsapp/domain_client/models/invite_view.dart';
import 'package:dsapp/domain_client/models/occurrence_view.dart';
import 'package:dsapp/domain_client/models/occurrence.dart';
import 'package:dsapp/domain_client/models/today_view.dart';
import 'package:flutter_test/flutter_test.dart';

/// Contract tests against payloads captured from the RUNNING backend.
///
/// M0 exit criterion (Notion 06 §13.2): DTO drift between backend and client
/// must be caught, not discovered by hand.
void main() {
  test('parses a real /v1/invites/resolve NOT_FOUND response', () {
    // Captured live from http://localhost:8082 on 2026-08-27.
    const raw =
        '{"state":"NOT_FOUND","inviteId":null,"dynamicId":null,'
        '"intendedRoleContext":null,"inviterDisplayName":null}';

    final v = InviteView.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    expect(v.state, InviteState.notFound);
    expect(v.inviteId, isNull);
  });

  test('parses a pending invite with the inviter name shown pre-auth', () {
    const raw =
        '{"state":"PENDING","inviteId":"11111111-1111-1111-1111-111111111111",'
        '"dynamicId":"22222222-2222-2222-2222-222222222222",'
        '"intendedRoleContext":"PARTNER","inviterDisplayName":"Alex"}';

    final v = InviteView.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    expect(v.state, InviteState.pending);
    expect(v.inviterDisplayName, 'Alex');
  });

  test('parses an occurrence in WAITING_ACK with no acknowledgement yet', () {
    const raw =
        '{"id":"33333333-3333-3333-3333-333333333333",'
        '"title":"Prepare the evening space","purpose":"A small act of care.",'
        '"state":"WAITING_ACK","dueAt":null,"completedAt":"2026-08-27T19:42:00Z",'
        '"acknowledgement":null,"allowedActions":[]}';

    final v = OccurrenceView.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    expect(v.state, OccurrenceState.waitingAck);
    expect(
      v.acknowledgement,
      isNull,
      reason: 'completion is not acknowledgement',
    );
    expect(v.completedAt, isNotNull);
  });

  test('parses an acknowledged occurrence carrying the human response', () {
    const raw =
        '{"id":"33333333-3333-3333-3333-333333333333",'
        '"title":"Prepare the evening space","purpose":null,'
        '"state":"ACKNOWLEDGED","dueAt":null,"completedAt":"2026-08-27T19:42:00Z",'
        '"acknowledgement":{"type":"PRAISE","text":"I noticed the care you put into this.",'
        '"sentAt":"2026-08-27T20:06:00Z","senderDisplayName":"Alex"},'
        '"allowedActions":[]}';

    final v = OccurrenceView.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    expect(v.state, OccurrenceState.acknowledged);
    expect(v.acknowledgement!.text, 'I noticed the care you put into this.');
    expect(v.acknowledgement!.senderDisplayName, 'Alex');
  });

  test('parses a real /v1/dynamics/{id}/today response', () {
    // Captured live from https://ds-api.beforeweplay.com on 2026-08-27.
    const raw =
        '{"priorityItems":['
        '{"occurrenceId":"0656bbd4-c2e8-4f2e-8342-3193679587ca",'
        '"title":"Evening check-in message","purpose":"A few words before the day closes.",'
        '"state":"ACTIVE","dueAt":null,"fromDisplayName":"alex"}],'
        '"awaitingResponse":[],'
        '"recentResponse":{"occurrenceId":"3b180366-7594-44c5-a85b-156317d11c8c",'
        '"title":"Prepare the evening space","type":"PRAISE",'
        '"text":"I noticed the care you put into this.",'
        '"sentAt":"2026-08-27T04:46:32.214019Z","senderDisplayName":"alex"}}';

    final v = TodayView.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    expect(v.priorityItems, hasLength(1));
    expect(v.priorityItems.first.fromDisplayName, 'alex');
    // An acknowledged item leaves the action list entirely.
    expect(v.awaitingResponse, isEmpty);
    expect(v.recentResponse!.senderDisplayName, 'alex');
  });

  test('parses a real /v1/dynamics/{id}/attention response', () {
    // Captured live from https://ds-api.beforeweplay.com on 2026-08-27.
    const raw =
        '{"items":['
        '{"occurrenceId":"13461cca-8959-438e-b9a3-2ec44c430fd1",'
        '"title":"Prepare the evening space","state":"WAITING_ACK",'
        '"actorDisplayName":"jamie","occurredAt":"2026-08-27T04:11:11.847456Z","priority":2},'
        '{"occurrenceId":"c71c88e2-f5ee-48b5-9a10-5b2e05316b70",'
        '"title":"Evening check-in message","state":"WAITING_ACK",'
        '"actorDisplayName":"jamie","occurredAt":"2026-08-27T04:11:13.467458Z","priority":2}],'
        '"needsResponseCount":2,"needsReviewCount":0}';

    final v = AttentionView.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    expect(v.items, hasLength(2));
    expect(v.needsResponseCount, 2);
    // The actor's name must survive: a response is addressed to a person.
    expect(v.items.first.actorDisplayName, 'jamie');
    expect(v.items.first.occurredAt, isNotNull);
  });

  test('parses allowedActions offering adjustment beside completion', () {
    const raw =
        '{"id":"33333333-3333-3333-3333-333333333333","title":"t",'
        '"purpose":null,"state":"ACTIVE","dueAt":null,"completedAt":null,'
        '"acknowledgement":null,'
        '"allowedActions":["complete","discuss","reschedule","cant_do"]}';

    final v = OccurrenceView.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    // Adjustment is a normal path, never hidden behind completion (red line #3).
    expect(
      v.allowedActions,
      containsAll(['complete', 'discuss', 'reschedule', 'cant_do']),
    );
  });
}
