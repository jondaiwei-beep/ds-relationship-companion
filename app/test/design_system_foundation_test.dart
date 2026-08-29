import 'package:flutter_test/flutter_test.dart';

import 'package:ds_relationship_companion/ds_design_system.dart';

void main() {
  test('all frozen SVG asset IDs are unique', () {
    final ids = DsAssets.all.map((asset) => asset.id).toSet();
    expect(ids, hasLength(DsAssets.all.length));
    expect(DsAssets.all, hasLength(33));
  });

  test('B-2 control geometry remains frozen', () {
    expect(DsLayoutSizes.touchTarget, 48);
    expect(DsControlSizes.button, 56);
    expect(DsControlSizes.buttonRitual, 64);
    expect(DsControlSizes.listRow, 72);
    expect(DsControlSizes.bottomNavigation, 80);
  });

  test('eight typography roles use bundled families', () {
    expect(DsTextStyles.displayRitual.fontFamily, DsTextStyles.displayFamily);
    expect(DsTextStyles.displayPartner.fontFamily, DsTextStyles.displayFamily);
    expect(DsTextStyles.titlePage.fontFamily, DsTextStyles.uiFamily);
    expect(DsTextStyles.bodyPrimary.fontFamily, DsTextStyles.uiFamily);
    expect(DsTextStyles.bodySecondary.fontFamily, DsTextStyles.uiFamily);
    expect(DsTextStyles.labelAction.fontFamily, DsTextStyles.uiFamily);
    expect(DsTextStyles.labelRitual.fontFamily, DsTextStyles.uiFamily);
    expect(DsTextStyles.navLabel.fontFamily, DsTextStyles.uiFamily);
  });
}
