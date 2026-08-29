import 'package:dsapp/domain_client/models/occurrence.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Occurrence deserialization', () {
    test('parses server state and does not infer it locally', () {
      final o = Occurrence.fromJson({
        'id': 'occ_1',
        'definitionId': 'def_1',
        'dynamicId': 'dyn_1',
        'state': 'WAITING_ACK',
        'relationshipDay': '2026-08-27T00:00:00.000Z',
        'dueAt': null,
        'allowedActions': ['acknowledge', 'praise'],
      });

      expect(o.state, OccurrenceState.waitingAck);
      expect(o.allowedActions, ['acknowledge', 'praise']);
      expect(o.dueAt, isNull);
    });

    test('allowedActions defaults to empty, never null', () {
      final o = Occurrence.fromJson({
        'id': 'occ_2',
        'definitionId': 'def_1',
        'dynamicId': 'dyn_1',
        'state': 'SCHEDULED',
        'relationshipDay': '2026-08-27T00:00:00.000Z',
      });

      expect(o.allowedActions, isEmpty);
    });

    test('every server state string maps to an enum value', () {
      // SCREAMING_SNAKE_CASE — verified against the running backend on
      // 2026-08-27. The Kotlin enum name is the wire format.
      const serverStates = [
        'SCHEDULED', 'ACTIVE', 'WAITING_ACK', 'ACKNOWLEDGED',
        'NEEDS_REVIEW', 'REVIEWED', 'NEED_TO_DISCUSS',
        'RESCHEDULE_REQUESTED', 'EXCUSE_REQUESTED', 'EXCUSED', 'CANCELLED',
      ];

      for (final s in serverStates) {
        final o = Occurrence.fromJson({
          'id': 'occ_x',
          'definitionId': 'def_1',
          'dynamicId': 'dyn_1',
          'state': s,
          'relationshipDay': '2026-08-27T00:00:00.000Z',
        });
        expect(o.state, isA<OccurrenceState>(), reason: 'unmapped state: $s');
      }

      expect(serverStates.length, OccurrenceState.values.length);
    });

    test('waitingAck is distinct from acknowledged (red line #2)', () {
      expect(OccurrenceState.waitingAck, isNot(OccurrenceState.acknowledged));
    });
  });
}
