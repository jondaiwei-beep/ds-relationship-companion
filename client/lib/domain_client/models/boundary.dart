/// A limit one person has named — REQ-ACT-002 "boundaries lite".
///
/// [mine] comes from the server rather than being worked out here by
/// comparing [id]s against a members list. That comparison is what once
/// showed a person their own name as their partner's, and the same mistake
/// here would put an edit control on a limit that is not the viewer's.
class Boundary {
  const Boundary({
    required this.id,
    required this.label,
    required this.stance,
    required this.mine,
    this.note,
  });

  factory Boundary.fromJson(Map<String, dynamic> json) => Boundary(
        id: json['id'] as String,
        label: json['label'] as String,
        stance: BoundaryStance.fromWire(json['stance'] as String),
        note: json['note'] as String?,
        mine: json['mine'] as bool? ?? false,
      );

  final String id;
  final String label;
  final BoundaryStance stance;
  final String? note;

  /// Whether the viewer wrote it. Only their own may be changed.
  final bool mine;
}

/// Three positions, deliberately unranked.
///
/// Not a 1–10 intensity: a number would be a compliance score under another
/// name, which the product's non-goals rule out, and it would claim precision
/// about something people are usually still working out.
enum BoundaryStance {
  /// A no. It needs no reason.
  off,

  /// Possible, but not without talking first.
  ask,

  /// Open to discussing. Explicitly not a yes.
  curious;

  static BoundaryStance fromWire(String w) => switch (w) {
        'OFF' => BoundaryStance.off,
        'ASK' => BoundaryStance.ask,
        _ => BoundaryStance.curious,
      };

  String get wire => switch (this) {
        BoundaryStance.off => 'OFF',
        BoundaryStance.ask => 'ASK',
        BoundaryStance.curious => 'CURIOUS',
      };
}
