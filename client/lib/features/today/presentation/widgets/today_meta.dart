import 'package:ds_relationship_companion/ds_design_system.dart';

import '../../../../domain_client/models/today_view.dart';

/// Backend state names never reach a person. Every state a screen can receive
/// has copy here; an unmapped one falls back to something neutral rather than
/// leaking its identifier.
String stateLabel(String state) => switch (state) {
  'ACTIVE' => 'Today',
  'WAITING_ACK' => 'Waiting for a reply',
  'NEEDS_REVIEW' => 'Needs review',
  'NEED_TO_DISCUSS' => 'Being discussed',
  'RESCHEDULE_REQUESTED' => 'New time requested',
  'EXCUSE_REQUESTED' => "Can't do — sent",
  _ => 'Scheduled',
};

/// Source, then time, then state — the order the design reads in. A row that
/// says only its state has lost the two facts a person scans for.
String itemMeta(TodayItem item) {
  final parts = <String>[
    if (item.fromDisplayName != null) 'From ${item.fromDisplayName}',
    if (item.dueAt != null) _clock(item.dueAt!.toLocal()),
    if (item.purpose?.isNotEmpty ?? false) item.purpose!,
  ];
  // The state is worth saying when it is not simply "on the list today".
  if (item.state != 'ACTIVE' || parts.isEmpty) {
    parts.add(stateLabel(item.state));
  }
  return parts.join(' · ');
}

/// What kind of thing this is, as the server states it.
///
/// REQ-STATE-001. This used to be inferred by substring-matching the title,
/// which let a person's own wording decide their item's identity: an
/// expectation called "ritual coffee" was labelled RITUAL and drew the evening
/// emblem. `expectation_definitions.kind` has been the authority since V1.
/// `TASK` and `RITUAL` are spelled out so a value that is neither is visibly a
/// fallback rather than silently the common kind — the failure this whole fix
/// is about. An unknown kind says the neutral word instead of asserting one:
/// as with [stateLabel], a backend identifier never reaches a person.
String kindLabel(TodayItem item) => switch (item.kind) {
  'RITUAL' => 'RITUAL',
  'TASK' => 'EXPECTATION',
  _ => 'ON TODAY',
};

/// The registered master for this item's kind. SCR-01 §4: every mark states
/// what a thing *is*, so this follows the kind and never the row's position.
///
/// Every registered mark asserts a specific identity, so there is no neutral
/// one to fall back to and the row still has to draw something. An unknown
/// kind therefore borrows the expectation mark while [kindLabel] declines to
/// name it — the picture is the weaker claim of the two.
DsAssetId assetFor(TodayItem item) => switch (item.kind) {
  'RITUAL' => DsAssets.emblemRitualEvening,
  _ => DsAssets.markAuthority,
};

/// How long ago a person responded, in the coarse terms a person would use.
String responseAge(DateTime sentAt) {
  final elapsed = DateTime.now().difference(sentAt);
  if (elapsed.inMinutes < 1) return 'JUST NOW';
  if (elapsed.inMinutes < 60) return '${elapsed.inMinutes} MIN AGO';
  if (elapsed.inHours < 24) return '${elapsed.inHours} HR AGO';
  return '${elapsed.inDays} DAY AGO';
}

String responseHeading(RecentResponse r) =>
    '${r.senderDisplayName?.toUpperCase() ?? 'YOUR PARTNER'} RESPONDED'
    ' · ${responseAge(r.sentAt)}';

String _clock(DateTime t) {
  final hour = t.hour % 12 == 0 ? 12 : t.hour % 12;
  return '$hour:${t.minute.toString().padLeft(2, '0')}'
      ' ${t.hour < 12 ? 'AM' : 'PM'}';
}
