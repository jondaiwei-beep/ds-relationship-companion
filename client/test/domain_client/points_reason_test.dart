import 'package:dsapp/domain_client/models/points.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('point reasons on the wire', () {
    test('every lowercase reason the ledger writes is known', () {
      expect(PointReason.fromWire('task_earn'), PointReason.taskEarn);
      expect(PointReason.fromWire('d_award'), PointReason.dAward);
      expect(PointReason.fromWire('d_deduct'), PointReason.dDeduct);
      expect(PointReason.fromWire('redemption'), PointReason.redemption);
      expect(PointReason.fromWire('redemption_refund'), PointReason.redemptionRefund);
    });

    test('a reason this build does not know is kept, not dropped', () {
      expect(PointReason.fromWire('something_new'), PointReason.unknown);
      // The old uppercase spellings are gone from the server; they must not
      // silently map to a meaning they no longer carry.
      expect(PointReason.fromWire('TASK_COMPLETED'), PointReason.unknown);
    });

    test('an entry parses with its reason', () {
      final e = PointEntry.fromJson({'id': 'e1', 'amount': -3, 'reason': 'd_deduct', 'note': null});
      expect(e.reason, PointReason.dDeduct);
      expect(e.amount, -3);
    });
  });
}
