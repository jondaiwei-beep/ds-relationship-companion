/// Spacing rhythm from Warm Authority V5: 6/8/10/12/16/18/22.
abstract final class DsSpacing {
  static const xs = 6.0;
  static const sm = 8.0;
  static const md = 10.0;
  static const lg = 12.0;
  static const xl = 16.0;
  static const xxl = 18.0;
  static const xxxl = 22.0;

  /// Mobile horizontal padding (Notion 05 §8: 20dp).
  static const screenPadding = 20.0;

  /// Rows, groups, response planes, bars and sheets are square.
  /// Direction 02 rule 4: no large-radius cards.
  static const cardRadius = 0.0;
  /// Inputs and buttons only. Nothing else earns a radius.
  static const buttonRadius = 2.0;

  /// ADR-0001 D-2: 48dp, not the mockup's 42px.
  /// Android minimum touch target; Notion 05 states 48–52dp.
  static const buttonHeight = 48.0;

  static const bottomNavHeight = 68.0;
  static const darkRailWidth = 3.0;
}
