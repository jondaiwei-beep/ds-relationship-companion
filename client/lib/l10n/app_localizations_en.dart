// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class LEn extends L {
  LEn([String locale = 'en']) : super(locale);

  @override
  String get navToday => 'Today';

  @override
  String get navDynamic => 'Dynamic';

  @override
  String get navExplore => 'Explore';

  @override
  String get navUs => 'Us';

  @override
  String get actionComplete => 'Complete';

  @override
  String get actionDiscuss => 'Discuss';

  @override
  String get actionNewTime => 'New time';

  @override
  String get actionCantDo => 'Can\'t do';

  @override
  String get actionTakeItBack => 'Take it back';

  @override
  String get activationContinue => 'Continue';

  @override
  String activationStepOf(int step) {
    return '$step of 4';
  }

  @override
  String get activationChooseOneToContinue => 'Choose one to continue.';

  @override
  String get activationGoalEyebrow => 'BEGIN WITH INTENTION';

  @override
  String get activationGoalQuestion => 'What would you\nlike more of now?';

  @override
  String get activationGoalSupport =>
      'Choose the feeling you want your\ndynamic to hold. You can change this later.';

  @override
  String get activationGoalFootnote =>
      'This shapes your starting rhythm—not your limits.';

  @override
  String get activationGoalCloser => 'Closer';

  @override
  String get activationGoalStructure => 'Structure';

  @override
  String get activationGoalService => 'Service & devotion';

  @override
  String get activationGoalAccountability => 'Accountability';

  @override
  String get activationGoalExplore => 'Explore together';

  @override
  String get activationRoleEyebrow => 'BEGIN TOGETHER';

  @override
  String get activationRoleQuestion => 'Who is beginning\nthis with you?';

  @override
  String get activationRoleSupport =>
      'Start privately or open this space with a partner.';

  @override
  String get activationRoleFootnote =>
      'A starting point, not a limit.\nYou can change this later.';

  @override
  String get activationRoleWithPartner => 'With a partner';

  @override
  String get activationRoleForMyself => 'For myself';

  @override
  String get activationRoleSectionLabel => 'YOUR STARTING ROLE';

  @override
  String get activationRoleDominant => 'Dominant';

  @override
  String get activationRoleSubmissive => 'submissive';

  @override
  String get activationRoleSwitch => 'Switch';

  @override
  String get activationRoleCustom => 'Custom';

  @override
  String get activationRoleDecline => 'I\'d rather not name one';

  @override
  String get activationStructureEyebrow => 'YOUR STRUCTURE';

  @override
  String get activationStructureQuestion => 'How much structure\nfeels right?';

  @override
  String get activationStructureSupport =>
      'Choose a starting rhythm. Nothing here\nremoves either person\'s voice.';

  @override
  String get activationStructureFootnote =>
      'You can refine this together later.';

  @override
  String get activationStructureLight => 'Light';

  @override
  String get activationStructureLightDetail =>
      'A gentle rhythm with plenty of room.';

  @override
  String get activationStructureSteady => 'Steady';

  @override
  String get activationStructureSteadyDetail =>
      'Clear expectations with room to adjust.';

  @override
  String get activationStructureDefined => 'Defined';

  @override
  String get activationStructureDefinedDetail =>
      'A firm shape you both agreed to.';

  @override
  String get activationContextLabel => 'YOUR CONTEXT';

  @override
  String get activationContextLongDistance => 'Long-distance';

  @override
  String get activationContextTogether => 'Together';

  @override
  String get activationContextTimezone => 'Timezone';

  @override
  String activationContextTimezoneDetected(String zone) {
    return '$zone · detected';
  }

  @override
  String get activationRhythmEyebrow => 'YOUR STARTING RHYTHM';

  @override
  String get activationRhythmQuestion => 'A small rhythm\nto begin.';

  @override
  String get activationRhythmSupport =>
      'Keep what feels right. Replace anything that doesn\'t.';

  @override
  String get activationRhythmFootnoteSolo => 'Start light. Adjust as you go.';

  @override
  String get activationRhythmFootnoteCouple => 'Start light. Adjust together.';

  @override
  String get activationRhythmStart => 'Start this rhythm';

  @override
  String get activationRhythmKindRitual => 'RITUAL';

  @override
  String get activationRhythmKindExpectation => 'EXPECTATION';

  @override
  String get activationRhythmKindCheckIn => 'CHECK-IN';

  @override
  String get activationRhythmEveningTitle => 'Evening check-in';

  @override
  String get activationRhythmEveningDetail =>
      'A pause for presence before the day closes.';

  @override
  String get activationRhythmSentenceTitle => 'One honest sentence';

  @override
  String get activationRhythmSentenceDetailSolo => 'Name what you need today.';

  @override
  String get activationRhythmSentenceDetailCouple =>
      'Share what you need today.';

  @override
  String get activationRhythmCheckInTitle => 'Daily check-in';

  @override
  String get activationRhythmCheckInDetail => 'Mood · Energy · Need';

  @override
  String get activationErrorChooseOutcome =>
      'Choose what you want more of first.';

  @override
  String get activationErrorTimezoneUnreadable =>
      'We couldn\'t read this device\'s timezone. Try again.';

  @override
  String get activationErrorOffline =>
      'You\'re offline. Connect to the internet, then try again.';

  @override
  String get activationErrorInvalidRequest =>
      'Something went wrong setting that up. Try again.';

  @override
  String get activationErrorGeneric =>
      'We couldn\'t set that up right now. Try again.';

  @override
  String get activationErrorSessionEnded =>
      'Your session ended. Sign in again to finish setting this up.';

  @override
  String get activationTimezoneTitle => 'We could not read\nyour time zone.';

  @override
  String get activationTimezoneWhyFirst =>
      'Your day has to be measured somewhere, and guessing would move it later without saying so.';

  @override
  String get activationTimezoneWhyRetried =>
      'Still nothing. Choosing it yourself works just as well — your day is measured in the zone you pick.';

  @override
  String get activationTimezoneTryAgain => 'Try again';

  @override
  String get activationTimezoneTryReadingAgain => 'Try reading it again';

  @override
  String get activationTimezoneChooseMyself => 'Choose it myself';

  @override
  String get activationTimezonePickerTitle => 'WHERE YOUR DAY IS MEASURED';

  @override
  String get activationZoneChina => 'China';

  @override
  String get activationZoneJapan => 'Japan';

  @override
  String get activationZoneSingapore => 'Singapore';

  @override
  String get activationZoneIndia => 'India';

  @override
  String get activationZoneUnitedKingdom => 'United Kingdom';

  @override
  String get activationZoneCentralEurope => 'Central Europe';

  @override
  String get activationZoneUsEastern => 'US Eastern';

  @override
  String get activationZoneUsCentral => 'US Central';

  @override
  String get activationZoneUsMountain => 'US Mountain';

  @override
  String get activationZoneUsPacific => 'US Pacific';

  @override
  String get activationZoneEasternAustralia => 'Eastern Australia';

  @override
  String get exploreTitle => 'Explore';

  @override
  String get exploreContextIdeas => 'Ideas';

  @override
  String get exploreContextReading => 'Reading';

  @override
  String get exploreContextConfirming => 'Confirming context';

  @override
  String get exploreContextNotLoaded => 'Not loaded';

  @override
  String get exploreContextNothingYet => 'Nothing yet';

  @override
  String get exploreSessionLost => 'Your private session needs to be restored.';

  @override
  String get exploreSignInAgain => 'Sign in again';

  @override
  String get exploreLoadFailed =>
      'The library could not be loaded. Nothing in your day depends on it.';

  @override
  String get exploreTryAgain => 'Try again';

  @override
  String get exploreEmpty =>
      'There is nothing in the library yet. Today holds everything that is waiting for you.';

  @override
  String get exploreIntro =>
      'Things other people have found worth asking for. Nothing here is a suggestion about you.';

  @override
  String get exploreAskForThis => 'Ask for this';

  @override
  String get exploreKindExpectation => 'SOMETHING TO ASK FOR';

  @override
  String get exploreKindRitual => 'SOMETHING TO REPEAT';

  @override
  String get exploreKindCheckIn => 'SOMETHING TO SAY';

  @override
  String get exploreKindOther => 'AN IDEA';

  @override
  String get responseTypeAcknowledge => 'Acknowledge';

  @override
  String get responseTypePraise => 'Praise';

  @override
  String get responseTypeComment => 'Comment';

  @override
  String get responseTypeReview => 'Review';

  @override
  String responseComposerTitle(String name) {
    return 'Respond to $name';
  }

  @override
  String get responseYourWords => 'YOUR WORDS';

  @override
  String get responseWordsHint => 'Say what you noticed…';

  @override
  String responseNeedsWords(String type) {
    return 'A $type needs your words.';
  }

  @override
  String responseSendTo(String name) {
    return 'Send to $name';
  }

  @override
  String get responseSending => 'Sending';

  @override
  String get responseNotNow => 'Not now';

  @override
  String get responseAttention => 'Attention';

  @override
  String responsePartnerPresent(String name) {
    return '$name is present';
  }

  @override
  String responseCompletedAtBy(String name, String time) {
    return '$name completed\nthis at $time.';
  }

  @override
  String get responseAlreadyAnsweredTitle => 'This has already\nbeen answered.';

  @override
  String responseAlreadyAnsweredDetail(String name) {
    return '$name has your response.';
  }

  @override
  String get responseClose => 'Close';

  @override
  String get responseErrorOffline =>
      'You\'re offline. Connect to the internet, then try again.';

  @override
  String get responseErrorGeneric =>
      'We couldn\'t send that just now. Try again.';

  @override
  String get responseAttentionSummaryLabel => 'WHAT NEEDS YOUR ANSWER';

  @override
  String responseAttentionMoments(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count moments',
      one: '1 moment',
    );
    return '$_temp0';
  }

  @override
  String responseAttentionAwaiting(int count) {
    return '$count awaiting your answer';
  }

  @override
  String responseAttentionToRevisit(int count) {
    return '$count to revisit';
  }

  @override
  String responseAttentionSectionWaiting(String name) {
    return '$name IS WAITING';
  }

  @override
  String get responseAttentionSectionCompletions => 'COMPLETIONS TO ANSWER';

  @override
  String get responseAttentionSectionLookBack => 'LOOK BACK TOGETHER';

  @override
  String responseAttentionRespondTo(String name) {
    return 'RESPOND TO $name';
  }

  @override
  String get responseAttentionEmptyTitle => 'Nothing is waiting\non you.';

  @override
  String get responseAttentionEmptyDetail =>
      'You\'ll find anything that needs\nyour answer here.';

  @override
  String get responseStateAskedToDiscuss => 'asked to discuss';

  @override
  String get responseStateAskedForNewTime => 'asked for a new time';

  @override
  String get responseStateCantDoThis => 'said they can\'t do this';

  @override
  String get responseStateCompleted => 'completed';

  @override
  String get responseStateStillOpen => 'is still open';

  @override
  String get responseStateWaiting => 'is waiting';

  @override
  String responseAgoMinutes(int count) {
    return '${count}m ago';
  }

  @override
  String responseAgoHours(int count) {
    return '${count}h ago';
  }

  @override
  String get responseAgoYesterday => 'yesterday';

  @override
  String responseAgoDays(int count) {
    return '${count}d ago';
  }

  @override
  String get responseWaitingYourPartner => 'your partner';

  @override
  String get responseWaitingHeaderAnswered => 'Acknowledgement';

  @override
  String responseWaitingPresenceWaiting(String name) {
    return 'Waiting for $name';
  }

  @override
  String get responseWaitingRecorded => 'Your service\nis recorded.';

  @override
  String responseWaitingCompletedAt(String time) {
    return 'COMPLETED AT $time';
  }

  @override
  String get responseWaitingNodeCompleted => 'COMPLETED';

  @override
  String responseWaitingNodeWaitingFor(String name) {
    return 'WAITING FOR $name';
  }

  @override
  String responseWaitingNotYetAnswered(String name) {
    return 'Your part is complete.\n$name has not responded yet.';
  }

  @override
  String get responseWaitingReturnToToday => 'Return to Today';

  @override
  String get responseWaitingCloseRitual => 'Close ritual';

  @override
  String get responseAnsweredTitle => 'You are seen.';

  @override
  String responseAnsweredWordlessNamed(String name) {
    return '$name acknowledged this.';
  }

  @override
  String get responseAnsweredWordlessAnonymous => 'This was acknowledged.';

  @override
  String responseReceivedAt(String time) {
    return 'RECEIVED AT $time';
  }

  @override
  String get responsePrivateNoteLabel => 'PRIVATE NOTE · ONLY YOU';

  @override
  String get dynamicTitle => 'Dynamic';

  @override
  String get dynamicYou => 'YOU';

  @override
  String get dynamicNoOneYet => 'NO ONE YET';

  @override
  String get dynamicCurrentStructure => 'CURRENT STRUCTURE';

  @override
  String get dynamicCurrentRhythm => 'CURRENT RHYTHM';

  @override
  String get dynamicCurrentRhythms => 'CURRENT RHYTHMS';

  @override
  String get dynamicAskOneThing => 'Ask one thing';

  @override
  String get dynamicThisWeek => 'This week';

  @override
  String get dynamicPauseThis => 'Pause this Dynamic';

  @override
  String get dynamicComeBack => 'Come back';

  @override
  String get dynamicPaused => 'PAUSED';

  @override
  String get dynamicPausedNothingExpected =>
      'Nothing is expected of either of you while this is paused.';

  @override
  String get dynamicEitherMayPause =>
      'Either of you may pause. Nothing is lost while paused.';

  @override
  String get dynamicNothingWaitingAfterPause =>
      'Nothing from the paused days is waiting for you.';

  @override
  String get outcomeCloser => 'Closeness-led';

  @override
  String get outcomeStructure => 'Structure-led';

  @override
  String get outcomeService => 'Service-led';

  @override
  String get outcomeAccountability => 'Accountability-led';

  @override
  String get outcomeExplore => 'Exploration-led';

  @override
  String get levelLight => 'lightly held';

  @override
  String get levelSteady => 'mutually held';

  @override
  String get levelDefined => 'clearly defined';

  @override
  String structureLine(Object level, Object outcome) {
    return '$outcome · $level';
  }

  @override
  String get rolePresetDominant => 'Dominant';

  @override
  String get rolePresetSubmissive => 'Submissive';

  @override
  String get rolePresetSwitch => 'Switch';

  @override
  String get rolePresetCustom => 'Their own words';

  @override
  String get entranceWordmark => 'Companion';

  @override
  String get entranceHeadline => 'A private space,\non your terms.';

  @override
  String get entranceTagline => 'Private. Considered. Yours.';

  @override
  String get entranceContinue => 'Continue';

  @override
  String get entranceContinueBusy => 'Opening';

  @override
  String get entranceHaveAccount => 'I already have an account';

  @override
  String get entranceNoticeChecking => 'Checking your session…';

  @override
  String get entranceNoticeSessionEnded =>
      'Your session ended. Enter again when you are ready.';

  @override
  String get entranceNoticeOffline => 'You\'re offline. Connect to continue.';

  @override
  String get entranceNoticeUnreachable =>
      'We couldn\'t reach the server. Try again.';

  @override
  String get entranceTrustFooter =>
      'For adults 18+. Use of this service is subject to our Terms.\nSee how we handle data in our Privacy Policy.\nAccounts are private by default.';

  @override
  String get entranceCreateEyebrow => 'Create an account';

  @override
  String get entranceCreateHeadline => 'Begin privately.';

  @override
  String get entranceFieldEmail => 'EMAIL';

  @override
  String get entranceFieldEmailHint => 'you@example.com';

  @override
  String get entranceFieldCreatePassword => 'CREATE PASSWORD';

  @override
  String entranceFieldPasswordHint(int min, int max) {
    return '$min–$max characters';
  }

  @override
  String get entranceAgeConfirm => 'I confirm that I am 18 or older.';

  @override
  String get entranceCreateAccount => 'Create account';

  @override
  String get entranceCreateAccountBusy => 'Creating account';

  @override
  String get entranceLegalConsent =>
      'By creating an account, you agree to the Terms\nand acknowledge the Privacy Policy.';

  @override
  String get entranceAlreadyHaveAccount => 'Already have an account? Sign in';

  @override
  String get entranceCreateUncertainFallback =>
      'We couldn\'t confirm whether the account was created. Try signing in before creating it again.';

  @override
  String get entranceSignInEyebrow => 'Welcome back';

  @override
  String get entranceSignInHeadline => 'Return to your space.';

  @override
  String get entranceFieldPassword => 'PASSWORD';

  @override
  String get entranceSignIn => 'Sign in';

  @override
  String get entranceSignInBusy => 'Signing in';

  @override
  String get entranceSendLink => 'Send sign-in link';

  @override
  String get entranceSendLinkBusy => 'Sending link';

  @override
  String get entranceLinkModeExplainer =>
      'We\'ll send a one-time sign-in link\nto the email you enter.';

  @override
  String get entranceUsePasswordInstead => 'Use password instead';

  @override
  String get entranceUseEmailLink => 'Use an email sign-in link';

  @override
  String get entranceCreateAccountLink => 'Create an account';

  @override
  String get entranceSignInNoticeAuthorizationLost =>
      'Please sign in to continue.';

  @override
  String get entranceSignInNoticeOffline =>
      'You\'re offline. Connect, then try again.';

  @override
  String get entranceLinkSentEyebrow => 'Check your email';

  @override
  String get entranceLinkSentHeadline => 'A link is on its way.';

  @override
  String get entranceLinkSentBody =>
      'If this email can be used to sign in,\nwe\'ll send a link. Check your inbox\nand spam folder.';

  @override
  String get entranceResendLink => 'Resend link';

  @override
  String get entranceUseDifferentEmail => 'Use a different email';

  @override
  String get entranceCallbackEyebrowBusy => 'Signing you in';

  @override
  String get entranceCallbackEyebrowDone => 'Sign in';

  @override
  String get entranceCallbackHeadlineBusy => 'One moment.';

  @override
  String get entranceCallbackHeadlineDone => 'This link is finished.';

  @override
  String get entranceCallbackIncompleteLink =>
      'That link is incomplete. Request a new one.';

  @override
  String get entranceCallbackUnexpectedLink =>
      'We couldn\'t complete that sign-in. Request a new link.';

  @override
  String get entranceRequestNewLink => 'Request a new link';

  @override
  String get entranceErrorAgeNotConfirmed =>
      'Confirm that you are 18 or older to create an account.';

  @override
  String get entranceErrorOffline =>
      'You\'re offline. Connect to the internet, then try again.';

  @override
  String get entranceErrorGeneric => 'Something went wrong. Try again.';

  @override
  String get entranceErrorUnexpected =>
      'Something unexpected happened. Try again.';

  @override
  String get entranceErrorLinkWrongDevice =>
      'Open the link on the device where you asked for it, or request a new one.';

  @override
  String get entranceErrorLinkExpired =>
      'That link can no longer be used. Request a new one.';

  @override
  String get entranceErrorSignInUncertain =>
      'We couldn\'t confirm the sign-in. Try again.';

  @override
  String get entranceErrorLinkSignInUncertain =>
      'We couldn\'t confirm the sign-in. Try the link again.';

  @override
  String get entranceErrorSignInGeneric =>
      'We couldn\'t sign you in right now. Try again.';

  @override
  String get entranceErrorInvalidCredentials =>
      'We couldn\'t sign you in with those details. Check your email and password, or use an email sign-in link.';

  @override
  String get entranceErrorAccountNotActive =>
      'We can\'t sign you in. Try an email sign-in link or contact support.';

  @override
  String get entranceErrorRegisterUncertain =>
      'We couldn\'t confirm whether the account was created. Try signing in or request an email sign-in link before creating it again.';

  @override
  String get entranceErrorRegisterGeneric =>
      'We couldn\'t create the account right now. Try again.';

  @override
  String get entranceErrorEmailInvalid => 'Enter a valid email address.';

  @override
  String get entranceErrorPasswordMissing => 'Enter your password.';

  @override
  String get entranceErrorCheckDetails => 'Check the details and try again.';

  @override
  String entranceErrorPasswordTooShort(int min) {
    return 'Use at least $min characters.';
  }

  @override
  String entranceErrorPasswordTooLong(int max) {
    return 'Use no more than $max characters.';
  }

  @override
  String get inviteTitle => 'Private invitation';

  @override
  String get inviteStatusChecking => 'CHECKING';

  @override
  String get inviteStatusPending => 'PENDING';

  @override
  String get invitePreparing => 'Preparing a private link…';

  @override
  String get invitePreparingNote => 'Nothing is sent until you share it.';

  @override
  String get inviteReadyHeadline => 'A private space\nis ready to share.';

  @override
  String get inviteWaitingForThem => 'Waiting for them to join';

  @override
  String get inviteNothingBeginsYet =>
      'Nothing begins until both of you agree.';

  @override
  String get inviteLinkLabel => 'PRIVATE LINK / CODE';

  @override
  String get inviteCopyLink => 'Copy invitation link';

  @override
  String get inviteCopyCodeOnly => 'Copy code only';

  @override
  String get inviteRevoke => 'Revoke invitation';

  @override
  String get inviteCopyLinkTooltip => 'Copy link';

  @override
  String get inviteCopied => 'Copied';

  @override
  String get inviteExpired => 'This link has expired.';

  @override
  String get inviteExpiresWithinHour => 'Expires within the hour';

  @override
  String inviteExpiresInHours(int hours) {
    return 'Expires in $hours hours';
  }

  @override
  String inviteExpiresInDays(int days) {
    return 'Expires in $days days';
  }

  @override
  String get inviteAlreadyLiveHeadline => 'An invitation is\nalready waiting.';

  @override
  String get inviteAlreadyLiveDetail =>
      'Only one link can be live at a time, and a link is shown only once when it is made.';

  @override
  String get inviteAlreadyLiveGuidance =>
      'Withdraw the existing one from your Dynamic to make a new link.';

  @override
  String get inviteBackToDynamic => 'Back to your Dynamic';

  @override
  String get inviteClosedHeadline => 'This invitation\nis closed.';

  @override
  String get inviteCreateFailedHeadline => 'We couldn\'t make\na private link.';

  @override
  String get inviteClosedDetail =>
      'The old link can no longer open your Dynamic. Nobody joined through it.';

  @override
  String get inviteCreateNew => 'Create a new invitation';

  @override
  String get inviteCreateNewNote =>
      'Creating a new invitation makes a new private link.';

  @override
  String get inviteErrorOffline =>
      'You\'re offline. Connect to the internet, then try again.';

  @override
  String get inviteErrorCreateFailed =>
      'We couldn\'t create the link right now. Try again.';

  @override
  String get inviteErrorRevokeFailed =>
      'We couldn\'t withdraw that link right now. Try again.';

  @override
  String get inviteErrorJoinRefused =>
      'This invitation can no longer be used. Ask for a new one.';

  @override
  String get inviteErrorJoinFailed =>
      'We couldn\'t complete that just now. Try again.';

  @override
  String get joinWordmark => 'COMPANION';

  @override
  String get joinResolving => 'Checking this invitation…';

  @override
  String get joinResolvingNote => 'Nothing is shown until it is confirmed.';

  @override
  String get joinUnresolvedHeadline => 'We couldn\'t check\nthis invitation.';

  @override
  String get joinUnresolvedDetail =>
      'We couldn\'t determine its status.\nNo join was attempted.';

  @override
  String get joinTryAgain => 'Try again';

  @override
  String get joinUnresolvedPrivacyNote =>
      'This link is still here. Trying again is safe.';

  @override
  String get joinSomeone => 'Someone';

  @override
  String get joinInvitedYou => 'invited you to begin\na private dynamic.';

  @override
  String get joinYouChooseYourRole => 'You choose your own role.';

  @override
  String get joinNotConsentToExpectations =>
      'Joining is not consent to future expectations.';

  @override
  String get joinReviewAndJoin => 'Review and join';

  @override
  String get joinBusy => 'Joining';

  @override
  String get joinNotNow => 'Not now';

  @override
  String get joinPrivacyNote =>
      'You can pause or leave this dynamic at any time.';

  @override
  String get joinAlreadyJoined => 'You\'ve joined. Open the app to continue.';

  @override
  String get joinBoundaryIntentionLabel => 'SHARED INTENTION';

  @override
  String get joinBoundaryIntention => 'More structure and closeness.';

  @override
  String get joinBoundarySharedLabel => 'SHARED TOGETHER';

  @override
  String get joinBoundarySharedItems =>
      'Starter rhythm ·\nresponses ·\nagreed changes';

  @override
  String get joinBoundaryPrivateLabel => 'STAYS YOURS';

  @override
  String get joinBoundaryPrivateItems =>
      'Private notes ·\npersonal settings ·\nyour choice to leave';

  @override
  String get joinUsedHeadline => 'This invitation\nhas been used.';

  @override
  String get joinExpiredHeadline => 'This invitation\nhas expired.';

  @override
  String get joinUnavailableHeadline =>
      'This invitation is\nno longer available.';

  @override
  String get joinClosedPrivacyDetail =>
      'For privacy, no Dynamic\ndetails are shown here.';

  @override
  String get joinUnavailableDetail => 'No invitation details are shown here.';

  @override
  String get joinNotJoinedAnything => 'You have not joined anything.';

  @override
  String get joinAskForNewLink =>
      'Ask the person who invited you\nto create a new private link.';

  @override
  String get joinAskSharer =>
      'If you need a new invitation, ask the\nperson who shared this link.';

  @override
  String get joinReturnToEntrance => 'Return to private entrance';

  @override
  String get joinClosedPrivacyNote =>
      'This link cannot be used to join anything.';

  @override
  String get inviteLifecyclePending => 'Pending';

  @override
  String get inviteLifecycleAccepted => 'Accepted';

  @override
  String get inviteLifecycleExpired => 'Expired';

  @override
  String get inviteLifecycleRevoked => 'Revoked';

  @override
  String get askTitle => 'Ask one thing';

  @override
  String get askCancel => 'Cancel';

  @override
  String askForWhom(Object name) {
    return 'For $name';
  }

  @override
  String get askYourPartnerFallback => 'your partner';

  @override
  String get askWhatStep => 'WHAT YOU ARE ASKING';

  @override
  String get askWhatHint => 'Prepare the room before 8:00 PM';

  @override
  String get askWhatMissing => 'Say what you are asking for.';

  @override
  String get askWhenStep => 'WHEN';

  @override
  String get askWhyStep => 'WHY IT MATTERS (OPTIONAL)';

  @override
  String get askWhyHint => 'Create a calm space for our evening ritual';

  @override
  String get askSend => 'Send';

  @override
  String get askSending => 'Sending…';

  @override
  String askAgencyNote(Object name) {
    return '$name can complete this, ask to discuss it, ask for another time, or say they cannot — always.';
  }

  @override
  String get askNoOneYet => 'There is no one to ask yet.';

  @override
  String get askNoOneYetBody =>
      'Once your invitation is accepted, you can ask them for things here.';

  @override
  String get askFailed =>
      'That did not reach the server. Nothing was sent — try again.';

  @override
  String get askCouldNotOpen => 'This could not be opened. Nothing was sent.';

  @override
  String get whenAnytime => 'Anytime';

  @override
  String get whenClear => 'Clear';

  @override
  String get whenToday => 'Today';

  @override
  String get detailDue => 'DUE';

  @override
  String detailSetBy(Object name) {
    return 'Set by $name';
  }

  @override
  String get detailIntention => 'INTENTION';

  @override
  String get detailPrivateNote => 'PRIVATE NOTE · ONLY YOU';

  @override
  String get detailCompletionNote => 'COMPLETION NOTE (OPTIONAL)';

  @override
  String get detailCompletionHint => 'What did you attend to?';

  @override
  String get detailMarkComplete => 'Mark complete';

  @override
  String get detailCompleting => 'Completing…';

  @override
  String detailPartnerWillSee(Object name) {
    return '$name will see this.';
  }

  @override
  String get detailTakeItBack => 'Never mind, take it back';

  @override
  String get detailTakingItBack => 'Taking it back…';

  @override
  String get detailTakeItBackNote =>
      'It goes back to how it was. Nothing is recorded as agreed or refused.';

  @override
  String get detailTheirWords => 'THEIR WORDS';

  @override
  String detailPersonWrote(Object name) {
    return '$name WROTE';
  }

  @override
  String get detailConfirming => 'Confirming this with the server.';

  @override
  String get detailSessionEnded =>
      'Your private session needs to be restored. Nothing about this is shown until it is.';

  @override
  String get detailCouldNotLoad =>
      'This could not be loaded. Nothing was changed.';

  @override
  String get nothingWaitingAck => 'Done, and waiting for a human response.';

  @override
  String get nothingAcknowledged => 'Answered. Nothing more is needed here.';

  @override
  String get nothingDiscussing => 'You asked to talk about this.';

  @override
  String get nothingRescheduling => 'You asked for another time.';

  @override
  String get nothingExcusing => 'You said you could not do this.';

  @override
  String get nothingCancelled => 'This was cancelled.';

  @override
  String get nothingDefault => 'Nothing is waiting on you here.';

  @override
  String get recoveryConfirmingContext => 'Confirming context';

  @override
  String get recoveryNotConfirmed => 'Not confirmed';

  @override
  String get recoveryOffline => 'Offline';

  @override
  String get recoveryReading => 'Reading';

  @override
  String get recoverySessionEnded => 'PRIVATE SESSION ENDED';

  @override
  String get recoverySessionRestore =>
      'Your private session\nneeds to be restored.';

  @override
  String get recoverySignInAgain => 'Sign in again';

  @override
  String get recoveryNoProtectedContent =>
      'No protected content remains on this screen.';

  @override
  String get recoveryTryAgain => 'Try again';

  @override
  String get recoveryTryToReconnect => 'Try to reconnect';

  @override
  String get todayResolving => 'RESOLVING TODAY';

  @override
  String get todayConfirmingPrivate => 'Confirming your private context…';

  @override
  String get todayPrivateByDefault => 'PRIVATE BY DEFAULT';

  @override
  String get todayPrivateByDefaultBody =>
      'Partner details stay hidden until membership and the current relationship day are confirmed.';

  @override
  String get todayCouldNotLoad =>
      'Today could not be loaded. Nothing was lost.';

  @override
  String get todayOfflineReadOnly => 'Read-only until the server reconnects.';

  @override
  String get todayActionsPaused => 'Actions are paused offline';

  @override
  String get todayActionsReturn =>
      'Complete, Discuss, New Time and Can\'t Do will return after current truth is confirmed.';

  @override
  String get todayCachedNeverNew =>
      'Cached content is never treated as a new state.';

  @override
  String get todayHiddenDetails =>
      'Partner and Dynamic details have been hidden.\nSign in again to confirm current access.';

  @override
  String get todayOffline => 'OFFLINE';

  @override
  String get dynamicConfirmingStructure =>
      'Nothing about the two of you is shown until the server confirms it.';

  @override
  String get dynamicCouldNotConfirm =>
      'The current structure could not be confirmed.';

  @override
  String get dynamicPauseUnavailable =>
      'Pause and Resume need the server, so they are unavailable until it reconnects. Whatever was already agreed still stands.';

  @override
  String get dynamicCouldNotLoad =>
      'The Dynamic could not be loaded. Nothing was changed.';

  @override
  String get dynamicHiddenDetails =>
      'Partner, roles and current structure have been hidden.\nSign in again to confirm current access.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsClose => 'Close';

  @override
  String get settingsLoading => 'Reading your settings.';

  @override
  String get settingsLoadFailed =>
      'Your notification settings could not be loaded.';

  @override
  String get settingsSaveFailed =>
      'That did not reach the server. Nothing changed.';

  @override
  String get settingsNotificationContentSection =>
      'WHAT A NOTIFICATION MAY SAY';

  @override
  String get settingsPreviewNeutralLabel => 'Nothing about the relationship';

  @override
  String get settingsPreviewNeutralSupport =>
      'A lockscreen shows only that the app has something for you. This is the default.';

  @override
  String get settingsPreviewRichLabel => 'Show the detail';

  @override
  String get settingsPreviewRichSupport =>
      'Titles and names may appear on your lockscreen, where anyone holding your phone can read them.';

  @override
  String get settingsQuietHoursSection => 'QUIET HOURS';

  @override
  String get settingsQuietHoursOffLabel => 'Off';

  @override
  String get settingsQuietHoursOffSupport =>
      'Notifications arrive whenever they happen.';

  @override
  String get settingsQuietHoursPresetLabel => '10:00 PM — 7:00 AM';

  @override
  String get settingsQuietHoursPresetSupport =>
      'Anything arriving in this window waits, and comes as one update rather than a replay.';

  @override
  String get settingsSharedDaySection => 'THE DAY YOU SHARE';

  @override
  String settingsDayBoundaryExplain(Object time) {
    return 'Your relationship day ends at $time, in this timezone — not in whichever one your phone is in. Nothing moves when you travel, and daylight saving does not shift the day.';
  }

  @override
  String get settingsPairingSection => 'THIS PAIRING';

  @override
  String get settingsLeaveOrBlock => 'Leave or block';

  @override
  String get settingsLeaveNeedsNoAgreement =>
      'Leaving never needs your partner to agree.';

  @override
  String get settingsDeviceSection => 'THIS DEVICE';

  @override
  String get settingsSignOut => 'Sign out';

  @override
  String get settingsSignOutSupport =>
      'Signing out ends this session here. Nothing about the relationship changes.';

  @override
  String get settingsLeaveHeadline => 'Ending this';

  @override
  String get settingsLeaveIntro =>
      'Both of these end the Dynamic for both of you. Nothing happens until you confirm.';

  @override
  String get settingsLeaveAction => 'Leave';

  @override
  String get settingsLeaveActionSupport =>
      'You stop taking part. No approval is needed.';

  @override
  String get settingsBlockAction => 'Block';

  @override
  String get settingsBlockActionSupportNoPartner =>
      'There is no one here to block yet.';

  @override
  String get settingsBlockActionSupport =>
      'You leave, and they cannot reach you here again.';

  @override
  String get settingsLeaveConfirmTitle => 'Leave this Dynamic';

  @override
  String get settingsLeaveFactEndsForBoth => 'It ends for both of you.';

  @override
  String get settingsLeaveFactNothingAskedAgain =>
      'Neither of you will be asked for anything here again.';

  @override
  String get settingsLeaveFactNoAgreementNeeded =>
      'Your partner is not asked to agree, and cannot stop it.';

  @override
  String get settingsLeaveFactCannotUndo =>
      'This cannot be undone from the app.';

  @override
  String get settingsLeaveBusy => 'Leaving…';

  @override
  String get settingsBlockConfirmTitle => 'Block';

  @override
  String settingsBlockConfirmTitleNamed(Object name) {
    return 'Block $name';
  }

  @override
  String get settingsBlockPartnerFallbackName => 'your partner';

  @override
  String get settingsBlockFactEndsForBoth => 'It ends for both of you.';

  @override
  String get settingsBlockFactNoContact =>
      'They will not be able to reach you here again.';

  @override
  String get settingsBlockFactNoHistory =>
      'Neither of you can read the shared history afterwards.';

  @override
  String get settingsBlockFactNotTold => 'They are not told who did it.';

  @override
  String get settingsBlockFactCannotUndo =>
      'This cannot be undone from the app.';

  @override
  String get settingsBlockBusy => 'Blocking…';

  @override
  String get settingsGoBack => 'Go back';

  @override
  String get settingsNoOneToBlock => 'There is no one here to block.';

  @override
  String get settingsLeaveFailed =>
      'That did not reach the server. Nothing has changed.';

  @override
  String get weeklyTitle => 'THIS WEEK';

  @override
  String get weeklyClose => 'Close';

  @override
  String get weeklyLoading => 'Gathering what actually happened this week.';

  @override
  String get weeklyLoadFailed =>
      'This week could not be loaded. Nothing was changed.';

  @override
  String get weeklyTryAgain => 'Try again';

  @override
  String get weeklyTooEarlyHeadline =>
      'There is not a week to look back on yet.';

  @override
  String get weeklyTooEarlySupport =>
      'This comes back once you have some days behind you. Nothing is missing in the meantime.';

  @override
  String get weeklyHeadlineQuiet => 'A quiet week.';

  @override
  String get weeklyHeadlineOneDay => 'One day had something on it.';

  @override
  String weeklyHeadlineDays(Object count) {
    return '$count days had something on them.';
  }

  @override
  String get weeklyAnsweredOne => 'One thing was answered by a person';

  @override
  String weeklyAnsweredMany(Object count) {
    return '$count things were answered by a person';
  }

  @override
  String get weeklyAdjustedOne => 'one adjustment was worked out together';

  @override
  String weeklyAdjustedMany(Object count) {
    return '$count adjustments were worked out together';
  }

  @override
  String weeklySupportJoin(Object first, Object second) {
    return '$first, and $second.';
  }

  @override
  String weeklySupportSingle(Object only) {
    return '$only.';
  }

  @override
  String get weeklySupportNothing =>
      'Nothing was completed or answered. That is a fact about the week, not about either of you.';

  @override
  String get weeklyAnsweredSection => 'WHAT WAS ANSWERED';

  @override
  String weeklyMomentAttribution(Object name) {
    return '— $name';
  }

  @override
  String get weeklyNextWeekSection => 'NEXT WEEK';

  @override
  String get weeklyKeep => 'Keep the current rhythm';

  @override
  String get weeklyPauseInstead => 'Pause instead';

  @override
  String get weeklyKeepSupport =>
      'Keeping is not a commitment. Either of you may pause at any time, from Dynamic.';

  @override
  String get checkInTitle => 'Check in';

  @override
  String get checkInCancel => 'Cancel';

  @override
  String get checkInHeadline => 'How are you, right now?';

  @override
  String get checkInSupport => 'Answer as much or as little as you want.';

  @override
  String get checkInMoodSection => 'MOOD';

  @override
  String get checkInMoodGood => 'Good';

  @override
  String get checkInMoodSteady => 'Steady';

  @override
  String get checkInMoodLow => 'Low';

  @override
  String get checkInMoodTender => 'Tender';

  @override
  String get checkInMoodRaw => 'Raw';

  @override
  String get checkInEnergySection => 'ENERGY';

  @override
  String get checkInEnergyHigh => 'High';

  @override
  String get checkInEnergySteady => 'Steady';

  @override
  String get checkInEnergyLow => 'Running low';

  @override
  String get checkInNeedSection => 'WHAT WOULD HELP';

  @override
  String get checkInNeedNothing => 'Nothing';

  @override
  String get checkInNeedCloseness => 'Closeness';

  @override
  String get checkInNeedSpace => 'Space';

  @override
  String get checkInNeedStructure => 'Structure';

  @override
  String get checkInNeedToBeAsked => 'To be asked';

  @override
  String get checkInNoteSection => 'ANYTHING ELSE (OPTIONAL)';

  @override
  String get checkInNoteHint => 'In your own words';

  @override
  String get checkInVisibilitySection => 'WHO CAN SEE THIS';

  @override
  String get checkInVisibilityPrivate => 'Only me';

  @override
  String get checkInVisibilityShare => 'Share';

  @override
  String checkInVisibilityShareWith(Object name) {
    return 'Share with $name';
  }

  @override
  String get checkInVisibilityPrivateSupport =>
      'Kept to yourself. Nothing about it reaches anyone else.';

  @override
  String get checkInVisibilityNoPartnerSupport =>
      'There is no one to share with yet.';

  @override
  String checkInVisibilitySharedSupport(Object name) {
    return '$name will be able to read this. It cannot be unshared afterwards.';
  }

  @override
  String get checkInSave => 'Save';

  @override
  String get checkInSaving => 'Saving…';

  @override
  String get checkInSaveFailed =>
      'That did not reach the server. Nothing was saved — try again.';

  @override
  String get shellOpeningYourSpace => 'Opening your space…';

  @override
  String get shellSignInToContinue => 'Sign in to continue.';

  @override
  String get shellCouldNotOpenYourSpace => 'We couldn\'t open\nyour space.';

  @override
  String get shellSessionEndedNothingLost =>
      'Your session ended. Nothing was lost.';

  @override
  String get shellCouldNotReachYourSpace =>
      'We couldn\'t reach your space just now.';

  @override
  String get shellSignIn => 'Sign in';

  @override
  String get shellTryAgain => 'Try again';

  @override
  String shellButtonWorking(String label) {
    return '$label, working';
  }

  @override
  String get shellShow => 'Show';

  @override
  String get shellHide => 'Hide';

  @override
  String get shellShowPassword => 'Show password';

  @override
  String get shellHidePassword => 'Hide password';

  @override
  String get usConfirmingContext => 'Confirming context';

  @override
  String get usNotConfirmed => 'Not confirmed';

  @override
  String get usSoFar => 'So far';

  @override
  String get usSettings => 'Settings';

  @override
  String get usTryAgain => 'Try again';

  @override
  String get usCouldNotBeLoaded =>
      'This could not be loaded. Nothing is missing from your history.';

  @override
  String usConnectedDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days you both showed up.',
      one: 'One day you both showed up.',
      zero: 'Nothing has landed on the same day yet.',
    );
    return '$_temp0';
  }

  @override
  String get usConnectedDaysSupport =>
      'Days you both did something. Nothing the app did on its own is counted here.';

  @override
  String get usThisWeek => 'This week';

  @override
  String get usNothingYet =>
      'Nothing has happened here yet. It fills up as you use it — there is nothing to catch up on.';

  @override
  String get usRecently => 'RECENTLY';

  @override
  String get usSomeone => 'Someone';

  @override
  String usMomentCompletion(String name) {
    return '$name did something that was asked';
  }

  @override
  String usMomentAcknowledgement(String name) {
    return '$name answered';
  }

  @override
  String usMomentAdjustmentRequested(String name) {
    return '$name asked to change something';
  }

  @override
  String get usMomentAdjustmentResolved => 'You worked something out';

  @override
  String usMomentCheckin(String name) {
    return '$name shared how they were';
  }

  @override
  String usMomentMemberJoined(String name) {
    return '$name joined';
  }

  @override
  String get usMomentUnknown => 'Something happened';

  @override
  String get usPrivateSessionEnded => 'PRIVATE SESSION ENDED';

  @override
  String get usSessionNeedsRestoring =>
      'Your private session\nneeds to be restored.';

  @override
  String get usHistoryHidden =>
      'Your history together has been hidden.\nSign in again to confirm current access.';

  @override
  String get usSignInAgain => 'Sign in again';

  @override
  String get usNoProtectedContent =>
      'No protected content remains on this screen.';

  @override
  String get todayTitle => 'Today';

  @override
  String get todayPrivate => 'Private';

  @override
  String todayPresent(Object name) {
    return '$name is present';
  }

  @override
  String get todayLaterOptional => 'LATER / OPTIONAL';

  @override
  String todayDayEndsAt(Object clock) {
    return 'Relationship day ends at $clock';
  }

  @override
  String todayFrom(Object name) {
    return 'From $name';
  }

  @override
  String get todayNothingExpected => 'Nothing is expected of you today.';

  @override
  String get todayCheckInOffer => 'A check-in is here if you want one.';

  @override
  String get todayCheckIn => 'Check in';

  @override
  String get stateOnToday => 'Today';

  @override
  String get stateWaitingForReply => 'Waiting for a reply';

  @override
  String get stateNeedsReview => 'Needs review';

  @override
  String get stateBeingDiscussed => 'Being discussed';

  @override
  String get stateNewTimeRequested => 'New time requested';

  @override
  String get stateCantDoSent => 'Can\'t do — sent';

  @override
  String get stateScheduled => 'Scheduled';

  @override
  String get kindRitual => 'RITUAL';

  @override
  String get kindExpectation => 'EXPECTATION';

  @override
  String get kindOnToday => 'ON TODAY';

  @override
  String get ageJustNow => 'JUST NOW';

  @override
  String ageMinutes(Object count) {
    return '$count MIN AGO';
  }

  @override
  String ageHours(Object count) {
    return '$count HR AGO';
  }

  @override
  String ageDays(Object count) {
    return '$count DAY AGO';
  }

  @override
  String get actionSending => 'Sending';

  @override
  String get yourPartner => 'YOUR PARTNER';

  @override
  String todayResponseHeading(Object age, Object name) {
    return '$name RESPONDED · $age';
  }

  @override
  String todayPriorityHeading(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count THINGS MATTER',
      two: 'TWO THINGS MATTER',
      one: 'ONE THING MATTERS',
    );
    return '$_temp0';
  }

  @override
  String get todayPriorityHeadingNone => 'NOTHING MATTERS TODAY';

  @override
  String todayPrimaryEyebrow(String kind) {
    return '01 · NOW · $kind';
  }

  @override
  String get settingsLanguageSection => 'LANGUAGE';

  @override
  String get settingsLanguageFollowDevice => 'Follow my phone';

  @override
  String get settingsLanguageFollowDeviceSupport =>
      'Changes with your phone\'s language setting.';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageChinese => '中文';

  @override
  String get settingsLanguageNote =>
      'The words this app uses are part of what it means. If a term reads oddly in one language, try the other.';

  @override
  String get pauseConfirming => 'Confirming whether this is paused.';

  @override
  String get pauseCouldNotConfirm =>
      'Whether this is paused could not be confirmed. Nothing was changed.';

  @override
  String get pauseTitle => 'Pause this Dynamic';

  @override
  String get pauseFactNothingExpected =>
      'Nothing will be expected of either of you.';

  @override
  String get pauseFactNothingDeleted => 'Nothing already agreed is deleted.';

  @override
  String get pauseFactNoBacklog =>
      'No backlog builds up while you are paused — you will not come back to a pile of missed days.';

  @override
  String get pauseFactEitherCan =>
      'Either of you can pause. Neither needs the other to agree.';

  @override
  String get pauseAction => 'Pause';

  @override
  String get pauseBusy => 'Pausing…';

  @override
  String get pauseNotNow => 'Not now';

  @override
  String get resumeTitle => 'Come back';

  @override
  String get resumeNothingWaiting =>
      'Nothing from the paused days is waiting. You are not behind.';

  @override
  String get resumeHowMuch => 'HOW MUCH TO COME BACK TO';

  @override
  String get resumeLighter => 'Lighter';

  @override
  String get resumeLighterSupport =>
      'About half the structure you paused under.';

  @override
  String get resumeSame => 'The same as before';

  @override
  String get resumeSameSupport => 'Everything you had, exactly as it was.';

  @override
  String get resumeAction => 'Resume';

  @override
  String get resumeBusy => 'Resuming…';

  @override
  String get resumeStayPaused => 'Stay paused';

  @override
  String get pauseFailed =>
      'That did not reach the server. Nothing changed — try again.';

  @override
  String get resumeFailed =>
      'That did not reach the server. Still paused — try again.';

  @override
  String get dynamicPartnerFallback => 'PARTNER';

  @override
  String get detailClose => 'Close';

  @override
  String get shellBack => 'Back';
}
