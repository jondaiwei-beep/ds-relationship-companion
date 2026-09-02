/// The points surfaces — owner decision 2026-09-02.
///
/// See `product/design/points-with-authority-and-warmth.md`. The design rules
/// that reach into these types: a balance never goes negative, and every entry
/// names a person rather than reading as a system event.
class PointsSummary {
  const PointsSummary({
    required this.balance,
    required this.entries,
    this.daysTogether = 0,
  });

  factory PointsSummary.fromJson(Map<String, dynamic> json) => PointsSummary(
        daysTogether: (json['daysTogether'] as num?)?.toInt() ?? 0,
        // Floored server-side too. Clamped here as well because a negative
        // balance must be unrepresentable on screen, not merely unlikely.
        balance: ((json['balance'] as num?)?.toInt() ?? 0).clamp(0, 1 << 30),
        entries: ((json['entries'] as List?) ?? const [])
            .cast<Map<String, dynamic>>()
            .map(PointEntry.fromJson)
            .toList(growable: false),
      );

  /// What is available to spend. Never a score, never shown beside a name.
  final int balance;

  /// Days this couple showed up, ever.
  ///
  /// Not a streak in the usual sense: it never resets. Kneel counts
  /// consecutive days and Obedience draws a row of × marks, and breaking one
  /// of those is documented to cause all-at-once abandonment. A gap here
  /// simply does not add.
  final int daysTogether;

  final List<PointEntry> entries;
}

class PointEntry {
  const PointEntry({
    required this.id,
    required this.amount,
    required this.reason,
    this.note,
  });

  factory PointEntry.fromJson(Map<String, dynamic> json) => PointEntry(
        id: json['id'] as String,
        amount: (json['amount'] as num).toInt(),
        reason: PointReason.fromWire(json['reason'] as String),
        note: json['note'] as String?,
      );

  final String id;
  final int amount;
  final PointReason reason;

  /// What was bought, or why it was given.
  final String? note;
}

/// Why a movement happened. Each renders as a sentence with a person in it —
/// "Alex noticed", not "+1 COMPLETION".
enum PointReason {
  completion,
  manualAward,
  manualDeduct,
  rewardPurchase,
  consequence;

  static PointReason fromWire(String w) => switch (w) {
        'COMPLETION' => PointReason.completion,
        'MANUAL_AWARD' => PointReason.manualAward,
        'MANUAL_DEDUCT' => PointReason.manualDeduct,
        'REWARD_PURCHASE' => PointReason.rewardPurchase,
        _ => PointReason.consequence,
      };
}

class Reward {
  const Reward({
    required this.id,
    required this.title,
    required this.cost,
    required this.affordable,
    this.detail,
  });

  factory Reward.fromJson(Map<String, dynamic> json) => Reward(
        id: json['id'] as String,
        title: json['title'] as String,
        detail: json['detail'] as String?,
        cost: (json['cost'] as num).toInt(),
        affordable: json['affordable'] as bool? ?? false,
      );

  final String id;
  final String title;
  final String? detail;
  final int cost;

  /// Answered by the server from the viewer's own balance.
  final bool affordable;
}

class ConsequenceAgreement {
  const ConsequenceAgreement({
    required this.id,
    required this.label,
    required this.consequence,
    required this.pointCost,
  });

  factory ConsequenceAgreement.fromJson(Map<String, dynamic> json) =>
      ConsequenceAgreement(
        id: json['id'] as String,
        label: json['label'] as String,
        consequence: json['consequence'] as String,
        pointCost: (json['pointCost'] as num?)?.toInt() ?? 0,
      );

  final String id;

  /// When this happens — the couple's own words.
  final String label;

  /// Then this — also their words. The app never adds to either.
  final String consequence;

  final int pointCost;
}

class ConsequenceEvent {
  const ConsequenceEvent({
    required this.id,
    required this.waived,
    required this.issuedByUserId,
    this.consequence,
    this.note,
  });

  factory ConsequenceEvent.fromJson(Map<String, dynamic> json) =>
      ConsequenceEvent(
        id: json['id'] as String,
        waived: (json['outcome'] as String?) == 'WAIVED',
        issuedByUserId: json['issuedByUserId'] as String,
        consequence: json['consequence'] as String?,
        note: json['note'] as String?,
      );

  final String id;

  /// Being let off is recorded and shown as prominently as being held to it.
  final bool waived;

  /// Always a real person. The software never issues one.
  final String issuedByUserId;

  final String? consequence;
  final String? note;
}
