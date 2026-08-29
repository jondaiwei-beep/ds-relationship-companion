import 'package:flutter/widgets.dart';

/// Direction 02 — "Hinge / Reply". See docs/DIRECTION_02_HINGE.md.
///
/// Replaces Warm Authority V5, which the product owner rejected as generic:
/// cream ground + warm orange accent + retro serif headings is the current
/// house style of AI-generated design, and it read as exactly that.
///
/// The palette is **mineral white, graphite, and sharp lichen** — cool
/// neutral rather than beige, and deliberately neither warm-orange nor
/// blue/purple.
///
/// Identity is carried by structure (the hinge grid) and by one semantic
/// rule — a serif belongs only to words a person actually wrote — not by an
/// accent colour. `accent` is a mark, never a surface: current position,
/// focus, unread, selected nav. It never fills an area and never sets text.
///
/// The retired palette's names (bone, olive, terracotta) are gone entirely.
/// Keeping them as aliases would have let that vocabulary back in — a
/// reader seeing `DsColors.olive` would believe this app is olive and cream.
abstract final class DsColors {
  // ── Ground and ink ───────────────────────────────────────────────
  /// Page ground. Cool mineral gray, never tinted beige.
  static const canvas = Color(0xFFF2F4F1);
  /// Fields, sheets, the rare raised control. NOT a card fill for rows.
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF171917);
  static const inkSoft = Color(0xFF454A45);
  static const muted = Color(0xFF6B716B);

  // ── Structure ────────────────────────────────────────────────────
  static const line = Color(0xFFC9CEC8);
  static const lineStrong = Color(0xFF8E968E);

  // ── Marks ────────────────────────────────────────────────────────
  /// Sharp lichen. A mark only: current position, focus, unread, selected
  /// nav. Never paragraph text, never a fill.
  static const accent = Color(0xFFBDD72A);
  static const accentInk = Color(0xFF354200);
  static const accentWash = Color(0xFFEAF2BB);
  /// Destructive and validation only. Not a brand colour.
  static const critical = Color(0xFFA23B47);

  /// A quiet raised band — a selected option, a soft secondary block.
  /// Not a card fill for ordinary rows.
  static const stone = Color(0xFFE7EAE6);

  // ── The reply plane ──────────────────────────────────────────────
  /// Reserved for words a partner actually wrote, and for authority bars.
  /// Nothing else may take this fill.
  static const response = Color(0xFF101210);
  static const onResponse = Color(0xFFF6F7F3);
  static const onResponseMuted = Color(0xFFADB4AC);

}
