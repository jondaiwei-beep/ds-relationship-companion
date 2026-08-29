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

/// What kind of thing this is. A ritual and a check-in are not the same and do
/// not share an identity.
String kindLabel(TodayItem item) => switch (_kind(item)) {
  _Kind.checkIn => 'CHECK-IN',
  _Kind.ritual => 'RITUAL',
  _Kind.expectation => 'EXPECTATION',
};

/// The registered master for this item's kind.
DsAssetId assetFor(TodayItem item) => switch (_kind(item)) {
  _Kind.checkIn => DsAssets.markCheckIn,
  _Kind.ritual => DsAssets.emblemRitualEvening,
  _Kind.expectation => DsAssets.markAuthority,
};

enum _Kind { checkIn, ritual, expectation }

_Kind _kind(TodayItem item) {
  final title = item.title.toLowerCase();
  if (title.contains('check-in') || title.contains('check in')) {
    return _Kind.checkIn;
  }
  if (title.contains('ritual')) {
    return _Kind.ritual;
  }
  return _Kind.expectation;
}

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
