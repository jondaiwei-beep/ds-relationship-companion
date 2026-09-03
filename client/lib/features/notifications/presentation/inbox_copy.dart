import '../../../l10n/app_localizations.dart';

/// The server stores generic English copy per event type (it never names a
/// task, rule or note). The phone speaks the reader's language, so the type
/// is re-rendered here; an event type this build does not know keeps the
/// server's words rather than showing nothing.
({String title, String body})? inboxCopy(L l, String eventType) => switch (eventType) {
      'occurrence_delivered' => (title: l.inboxOccurrenceDeliveredTitle, body: l.inboxOccurrenceDeliveredBody),
      'occurrence_flagged' => (title: l.inboxOccurrenceFlaggedTitle, body: l.inboxOccurrenceFlaggedBody),
      'disposition_set' => (title: l.inboxDispositionSetTitle, body: l.inboxDispositionSetBody),
      'day_comment' => (title: l.inboxDayCommentTitle, body: l.inboxDayCommentBody),
      'rule_proposed' => (title: l.inboxRuleProposedTitle, body: l.inboxRuleProposedBody),
      'rule_accepted' => (title: l.inboxRuleAcceptedTitle, body: l.inboxRuleAcceptedBody),
      'task_proposed' => (title: l.inboxTaskProposedTitle, body: l.inboxTaskProposedBody),
      'task_accepted' => (title: l.inboxTaskAcceptedTitle, body: l.inboxTaskAcceptedBody),
      'redemption_requested' => (title: l.inboxRedemptionRequestedTitle, body: l.inboxRedemptionRequestedBody),
      'redemption_decided' => (title: l.inboxRedemptionDecidedTitle, body: l.inboxRedemptionDecidedBody),
      'redemption_fulfilled' => (title: l.inboxRedemptionFulfilledTitle, body: l.inboxRedemptionFulfilledBody),
      'consequence_issued' => (title: l.inboxConsequenceIssuedTitle, body: l.inboxConsequenceIssuedBody),
      'consequence_done' => (title: l.inboxConsequenceDoneTitle, body: l.inboxConsequenceDoneBody),
      'consequence_decided' => (title: l.inboxConsequenceDecidedTitle, body: l.inboxConsequenceDecidedBody),
      'd_award' => (title: l.inboxDAwardTitle, body: l.inboxDAwardBody),
      'd_note_reminder' => (title: l.inboxDNoteReminderTitle, body: l.inboxDNoteReminderBody),
      _ => null,
    };
