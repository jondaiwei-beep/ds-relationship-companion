import 'package:ds_relationship_companion/ds_design_system.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../../../domain_client/models/today_view.dart';
import '../../../../l10n/app_localizations.dart';

/// Backend state names never reach a person. Every state a screen can receive
/// has copy here; an unmapped one falls back to something neutral rather than
/// leaking its identifier.
///
/// Takes [l] rather than a BuildContext: these are pure mappings from a server
/// enum to a sentence, and keeping them context-free lets the callers that are
/// not widgets keep using them.
String stateLabel(L l, String state) => switch (state) {
  'ACTIVE' => l.stateOnToday,
  'WAITING_ACK' => l.stateWaitingForReply,
  'NEEDS_REVIEW' => l.stateNeedsReview,
  'NEED_TO_DISCUSS' => l.stateBeingDiscussed,
  'RESCHEDULE_REQUESTED' => l.stateNewTimeRequested,
  'EXCUSE_REQUESTED' => l.stateCantDoSent,
  _ => l.stateScheduled,
};

/// Source, then time, then state — the order the design reads in. A row that
/// says only its state has lost the two facts a person scans for.
String itemMeta(L l, TodayItem item, {String? zone}) {
  final parts = <String>[
    if (item.fromDisplayName != null) l.todayFrom(item.fromDisplayName!),
    if (item.dueAt != null) _clock(_inZone(item.dueAt!, zone)),
    if (item.purpose?.isNotEmpty ?? false) item.purpose!,
  ];
  // The state is worth saying when it is not simply "on the list today".
  if (item.state != 'ACTIVE' || parts.isEmpty) {
    parts.add(stateLabel(l, item.state));
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
String kindLabel(L l, TodayItem item) => switch (item.kind) {
  'RITUAL' => l.kindRitual,
  'TASK' => l.kindExpectation,
  _ => l.kindOnToday,
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
String responseAge(L l, DateTime sentAt) {
  final elapsed = DateTime.now().difference(sentAt);
  if (elapsed.inMinutes < 1) return l.ageJustNow;
  if (elapsed.inMinutes < 60) return l.ageMinutes(elapsed.inMinutes);
  if (elapsed.inHours < 24) return l.ageHours(elapsed.inHours);
  return l.ageDays(elapsed.inDays);
}

String responseHeading(L l, RecentResponse r) =>
    // gen-l10n orders positional parameters alphabetically, not in the order
    // they appear in the sentence: the signature is (age, name).
    l.todayResponseHeading(
      responseAge(l, r.sentAt),
      r.senderDisplayName?.toUpperCase() ?? l.yourPartner,
    );

/// The due time as the Dynamic reads it.
///
/// REQ-TIME-001: "device timezone changes do not silently move a relationship
/// day". `toLocal()` showed a partner in another zone a different hour than
/// the one their partner set — the failure the requirement names, and the case
/// this product is built for. Falls back to the device only when the server
/// did not state a zone, or named one this build's database does not know.
DateTime _inZone(DateTime utc, String? zone) {
  if (zone == null) return utc.toLocal();
  try {
    return tz.TZDateTime.from(utc, tz.getLocation(zone));
  } on tz.LocationNotFoundException {
    return utc.toLocal();
  }
}

String _clock(DateTime t) {
  final hour = t.hour % 12 == 0 ? 12 : t.hour % 12;
  return '$hour:${t.minute.toString().padLeft(2, '0')}'
      ' ${t.hour < 12 ? 'AM' : 'PM'}';
}
