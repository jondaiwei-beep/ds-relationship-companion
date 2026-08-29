import 'package:flutter/widgets.dart';
import 'colors.dart';

/// Direction 02 — see docs/DIRECTION_02_HINGE.md §2.
///
/// **The serif is semantic, not atmospheric.** It belongs only to words a
/// person actually wrote and sent. Everything the app itself says — titles,
/// navigation, actions, labels, status, prompts, suggestions — is set in the
/// sans.
///
/// The previous scale used the serif for screen headings, section headings,
/// the app bar, and card titles as well as partner quotes. Because one voice
/// spoke everything, the system, the content and the partner all sounded
/// like the same brand persona — which is most of why the design read as
/// generated.
///
/// If it is not provably human-authored, it is sans. The system must never
/// render its own suggestion in the serif.
abstract final class DsType {
  /// Human words only. Never app chrome.
  static const _serif = 'Lora';
  static const _sans = 'Inter';

  /// Screen headline. 27/1.12.
  static const h1 = TextStyle(
    fontFamily: _sans, fontSize: 28, height: 1.15,
    fontWeight: FontWeight.w600, letterSpacing: -0.3, color: DsColors.ink,
  );

  /// Section headline. 20/1.2.
  static const h2 = TextStyle(
    fontFamily: _sans, fontSize: 20, height: 1.25,
    fontWeight: FontWeight.w600, letterSpacing: -0.2, color: DsColors.ink,
  );

  /// App bar title, on the olive top bar.
  static const appBarTitle = TextStyle(
    fontFamily: _sans, fontSize: 17, height: 1.2,
    fontWeight: FontWeight.w600, color: DsColors.onResponse,
  );

  /// Card headline.
  /// An item title. App chrome, so sans.
  static const cardTitle = TextStyle(
    fontFamily: _sans, fontSize: 17, height: 1.35,
    fontWeight: FontWeight.w600, color: DsColors.ink,
  );

  /// A partner's words, inline. One of only two serif styles.
  static const humanWords = TextStyle(
    fontFamily: _serif, fontSize: 20, height: 1.35,
    fontWeight: FontWeight.w400, color: DsColors.ink,
  );

  /// A partner's words on the reply plane — the emotional peak.
  static const bigQuote = TextStyle(
    fontFamily: _serif, fontSize: 26, height: 1.25,
    fontWeight: FontWeight.w400, color: DsColors.onResponse,
  );

  static const body = TextStyle(
    fontFamily: _sans, fontSize: 15, height: 1.45, color: DsColors.ink,
  );

  /// Section label. Uppercase, tracked out.
  static const eyebrow = TextStyle(
    fontFamily: _sans, fontSize: 11, height: 1.2, letterSpacing: 1.2,
    fontWeight: FontWeight.w700, color: DsColors.muted,
  );

  /// Metadata, timestamps, helper text.
  static const fine = TextStyle(
    fontFamily: _sans, fontSize: 13, height: 1.4, color: DsColors.muted,
  );

  static const button = TextStyle(
    fontFamily: _sans, fontSize: 12, height: 1.2,
    fontWeight: FontWeight.w600, color: DsColors.surface,
  );

  static const navItem = TextStyle(
    fontFamily: _sans, fontSize: 9, height: 1.2, fontWeight: FontWeight.w600,
  );
}
