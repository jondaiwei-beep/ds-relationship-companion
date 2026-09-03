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
  String get navRules => 'Rules';

  @override
  String get navRecord => 'Record';

  @override
  String get activationContinue => 'Continue';

  @override
  String activationStepOf(int step) {
    return '$step of 5';
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
  String get entranceNoticeUnreachable => 'Could not connect. Try again.';

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
  String get entranceErrorEmailInvalid => 'That email does not look right.';

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
  String get joinYouChooseYourRole =>
      'Whoever invited you has set which side each of you is on. You will see it inside.';

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
  String get joinAlreadyJoined => 'This invitation has brought you in.';

  @override
  String get joinBoundaryIntentionLabel => 'WHAT YOU ARE STARTING';

  @override
  String get joinBoundaryIntention =>
      'One sets the rules, one delivers; disposing and the record live here.';

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
  String get recoveryConfirmingContext => 'Confirming context';

  @override
  String get recoveryNotConfirmed => 'Not confirmed';

  @override
  String get recoveryOffline => 'Offline';

  @override
  String get recoverySessionRestore =>
      'Your private session\nneeds to be restored.';

  @override
  String get recoverySignInAgain => 'Sign in again';

  @override
  String get recoveryTryAgain => 'Try again';

  @override
  String get recoveryTryToReconnect => 'Try to reconnect';

  @override
  String get todayPrivateByDefault => 'PRIVATE BY DEFAULT';

  @override
  String get todayPrivateByDefaultBody =>
      'Nothing is shown until it is confirmed that this is you, and which day it is.';

  @override
  String get todayCouldNotLoad =>
      'Today could not be opened. Nothing was lost.';

  @override
  String get todayActionsPaused =>
      'No connection, so nothing can be delivered yet.';

  @override
  String get todayActionsReturn =>
      'Deliveries and explanations come back once you are connected.';

  @override
  String get todayHiddenDetails =>
      'Everything about them and the two of you is put away for now.\nSign in again and it comes back.';

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
  String get todayTitle => 'Today';

  @override
  String get todayPrivate => 'Private';

  @override
  String todayPresent(Object name) {
    return '$name is present';
  }

  @override
  String todayDayEndsAt(Object clock) {
    return 'Relationship day ends at $clock';
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
  String get detailClose => 'Close';

  @override
  String get shellBack => 'Back';

  @override
  String get pointsTitle => 'Points';

  @override
  String get settingsPointsSection => 'POINTS';

  @override
  String get settingsPointsOpen => 'Points and rewards';

  @override
  String get settingsPointsSupport =>
      'Points can be switched off entirely. Nothing else changes if you do.';

  @override
  String get navPoints => 'Points';

  @override
  String todayDayStartsAt(String clock) {
    return 'Today counts from $clock';
  }

  @override
  String todayBalance(int count) {
    return '$count points';
  }

  @override
  String todayDaysTogether(int count) {
    return '$count days together';
  }

  @override
  String get todayNoteOptional => 'A line, if you want';

  @override
  String get todaySend => 'Send';

  @override
  String get todayCancel => 'Cancel';

  @override
  String get todayPartnerFallback => 'your partner';

  @override
  String todayDueBy(String time) {
    return 'by $time';
  }

  @override
  String todayPointsEarn(int count) {
    return '+$count';
  }

  @override
  String get sTodayEmpty => 'Nothing is asked of you today.';

  @override
  String get sTodaySectionCheckin => 'Check-in';

  @override
  String get sTodaySectionList => 'Today';

  @override
  String get sTodaySectionOpen => 'When you feel like it';

  @override
  String sTodayDelivered(String name) {
    return 'Delivered · waiting for $name';
  }

  @override
  String sTodayDeliveredLate(String name) {
    return 'Delivered late · waiting for $name';
  }

  @override
  String sTodaySeen(String name, String time) {
    return '$name saw it · $time';
  }

  @override
  String sTodayPraised(String name) {
    return '$name: good';
  }

  @override
  String sTodayPraisedNote(String name, String note) {
    return '$name: $note';
  }

  @override
  String sTodayLetGo(String name) {
    return '$name: let it go';
  }

  @override
  String sTodayMakeUp(String name, String day) {
    return '$name: make it up on $day';
  }

  @override
  String sTodayPunished(String name, String title) {
    return '$name: $title';
  }

  @override
  String sTodayPaused(String name) {
    return '$name is away · paused';
  }

  @override
  String get sTodayMissed => 'Not done';

  @override
  String get sTodayCantDo => 'Can\'t do';

  @override
  String sTodayNewTime(String time) {
    return 'Asked for $time';
  }

  @override
  String get sTodayDiscuss => 'Want to talk';

  @override
  String sTodayYourNote(String note) {
    return 'You: $note';
  }

  @override
  String get sTodayActionDeliver => 'Done';

  @override
  String get sTodayActionCantDo => 'Can\'t do';

  @override
  String get sTodayActionNewTime => 'Ask for a new time';

  @override
  String get sTodayActionDiscuss => 'Want to talk';

  @override
  String get sTodayActionWithdraw => 'Take it back';

  @override
  String get sTodayWriteLine => 'Write a line';

  @override
  String get sTodayPhotoRef => 'Photo';

  @override
  String get sTodayPhotoHint =>
      'Paste a photo reference for now; the camera comes in a later build.';

  @override
  String get sTodayProofCamera => 'Take a photo';

  @override
  String get sTodayProofGallery => 'From the gallery';

  @override
  String get sTodayPhotoFailed => 'The photo did not upload; nothing changed.';

  @override
  String get sTodayPickTime => 'Pick a time';

  @override
  String sTodayConflictPaused(String name) {
    return '$name paused this.';
  }

  @override
  String sTodayConflictDisposed(String name) {
    return '$name already answered this.';
  }

  @override
  String get sTodayConflictChanged => 'This changed elsewhere.';

  @override
  String get sTodayConflictOther => 'Not sent. Try again.';

  @override
  String get dTodayEmpty => 'Nothing waiting for you.';

  @override
  String get dTodaySectionNeedsMe => 'Waiting on me';

  @override
  String dTodaySectionOverview(String name) {
    return 'Today for $name';
  }

  @override
  String dTodayOverviewDelivered(int done, int total) {
    return '$done/$total delivered';
  }

  @override
  String dTodayOverviewFlagged(int count) {
    return '$count said something';
  }

  @override
  String dTodaySaidDelivered(String time) {
    return 'Delivered · $time';
  }

  @override
  String dTodaySaidLate(String time) {
    return 'Delivered late · $time';
  }

  @override
  String get dTodaySaidCantDo => 'Can\'t do';

  @override
  String dTodaySaidNewTime(String time) {
    return 'Asks for $time';
  }

  @override
  String get dTodaySaidDiscuss => 'Wants to talk';

  @override
  String get dTodaySaidMissed => 'Not done';

  @override
  String dTodaySaidNote(String name, String note) {
    return '$name: $note';
  }

  @override
  String dTodayProofPhoto(String ref) {
    return 'Photo: $ref';
  }

  @override
  String dTodayOnDay(String day) {
    return '$day';
  }

  @override
  String get dTodayActionSeen => 'Seen';

  @override
  String get dTodayActionPraise => 'Good';

  @override
  String get dTodayActionLetGo => 'Let it go';

  @override
  String get dTodayActionMakeUp => 'Make it up';

  @override
  String get dTodayActionPunish => 'Consequence';

  @override
  String get dTodayMakeUpWhich => 'Which day?';

  @override
  String get dTodayPunishWhich => 'Which consequence?';

  @override
  String get dTodayPunishOwn => 'Your own words';

  @override
  String get dTodayPunishTitle => 'Consequence';

  @override
  String get dTodayConflictOpen => 'Nothing to answer yet.';

  @override
  String get dTodayConflictPaused => 'This one is paused.';

  @override
  String get dTodayConflictChanged => 'This changed elsewhere.';

  @override
  String get dTodayConflictOther => 'Not sent. Try again.';

  @override
  String get dTodaySectionQuickAdd => 'Add one';

  @override
  String get dTodayQuickTitle => 'What';

  @override
  String get dTodayQuickToday => 'Just today';

  @override
  String get dTodayQuickDaily => 'Every day';

  @override
  String get dTodayQuickPoints => 'Points (optional)';

  @override
  String get dTodayQuickAdd => 'Add';

  @override
  String get dTodayQuickAdded => 'Added.';

  @override
  String get dTodayQuickFailed => 'Not added. Try again.';

  @override
  String get dTodaySectionNotes => 'To remember';

  @override
  String get dTodayNoteBody => 'Note to self';

  @override
  String get dTodayNoteRemind => 'Remind me';

  @override
  String dTodayNoteRemindAt(String time) {
    return 'Remind · $time';
  }

  @override
  String get dTodayNoteDone => 'Done';

  @override
  String get dTodayNoteDelete => 'Delete';

  @override
  String get dTodayNoteAdd => 'Keep it';

  @override
  String get dTodayNotesPrivate => 'Only you see these.';

  @override
  String settingsDayStart(String time) {
    return 'The day starts at $time';
  }

  @override
  String get settingsDayStartReadOnly => 'Changing it comes in a later build.';

  @override
  String get settingsDeviceLock => 'Device lock';

  @override
  String get settingsDeviceLockSupport =>
      'Ask for fingerprint, face or the device PIN when the app opens, or comes back after half a minute away.';

  @override
  String get settingsDeviceLockUnavailable =>
      'This device cannot lock the app.';

  @override
  String get lockTitle => 'Locked';

  @override
  String get lockUnlock => 'Unlock';

  @override
  String get lockReason => 'Unlock to continue';

  @override
  String recordTogether(int days, int streak) {
    return 'Together $days days · $streak in a row';
  }

  @override
  String get recordPrevMonth => 'Previous month';

  @override
  String get recordNextMonth => 'Next month';

  @override
  String get recordFactsTitle => 'This week · this month';

  @override
  String get recordFactsWeek => 'Week';

  @override
  String get recordFactsMonth => 'Month';

  @override
  String get recordFactDelivered => 'Delivered';

  @override
  String get recordFactLate => 'Delivered late';

  @override
  String get recordFactFlagged => 'Explained';

  @override
  String get recordFactMissed => 'Missed';

  @override
  String get recordFactLetGo => 'Let go';

  @override
  String get recordFactPraised => 'Good';

  @override
  String get recordFactMadeUp => 'Make it up';

  @override
  String get recordFactPunished => 'Consequence';

  @override
  String get recordFactComments => 'Comments';

  @override
  String get recordFactPointsEarned => 'Points earned';

  @override
  String get recordFactPointsDeducted => 'Points deducted';

  @override
  String get recordFactRedemptions => 'Redemptions';

  @override
  String get recordCouldNotLoad => 'The record could not be loaded.';

  @override
  String get recordDayCouldNotLoad => 'This day could not be loaded.';

  @override
  String get recordDayEmpty => 'Nothing was written on this day.';

  @override
  String get recordMe => 'You';

  @override
  String get recordBack => 'Back to the record';

  @override
  String recordDelivered(String name, String title) {
    return '$name delivered “$title”';
  }

  @override
  String recordDeliveredLate(String name, String title) {
    return '$name delivered “$title”, late';
  }

  @override
  String recordCantDo(String name, String title) {
    return '$name said “$title” can\'t be done';
  }

  @override
  String recordNewTime(String name, String title) {
    return '$name asked for a new time on “$title”';
  }

  @override
  String recordDiscuss(String name, String title) {
    return '$name wants to talk about “$title”';
  }

  @override
  String recordWithdrew(String name, String title) {
    return '$name took back “$title”';
  }

  @override
  String recordMissed(String title) {
    return '“$title” was not delivered that day';
  }

  @override
  String recordPausedEntry(String title) {
    return '“$title” was paused';
  }

  @override
  String recordSeen(String name, String title) {
    return '$name saw “$title”';
  }

  @override
  String recordPraised(String name, String title) {
    return '$name: good — “$title”';
  }

  @override
  String recordLetGo(String name, String title) {
    return '$name let “$title” go';
  }

  @override
  String recordMakeUp(String name, String title, String day) {
    return '$name: make up “$title” on $day';
  }

  @override
  String recordPunished(String name, String title, String consequence) {
    return '$name: consequence for “$title” — $consequence';
  }

  @override
  String recordDispositionCleared(String name, String title) {
    return '$name took back the answer on “$title”';
  }

  @override
  String recordPhotoRef(String ref) {
    return 'Photo: $ref';
  }

  @override
  String recordCommented(String name) {
    return '$name left a line';
  }

  @override
  String recordPointsEarnedAuto(int amount, String reason) {
    return '+$amount points · $reason';
  }

  @override
  String recordPointsAdded(String name, int amount) {
    return '$name added $amount points';
  }

  @override
  String recordPointsDeducted(String name, int amount) {
    return '$name deducted $amount points';
  }

  @override
  String get recordReasonTaskEarn => 'task';

  @override
  String get recordReasonAward => 'given';

  @override
  String get recordReasonDeduct => 'deducted';

  @override
  String get recordReasonRedemption => 'redeemed';

  @override
  String get recordReasonRefund => 'refunded';

  @override
  String recordRedeemed(String name, String title) {
    return '$name redeemed “$title”';
  }

  @override
  String get recordActionDeliverLate => 'Deliver now';

  @override
  String get recordActionCantDo => 'Explain: can\'t do';

  @override
  String get recordComments => 'A line on this day';

  @override
  String get recordCommentHint => 'Either of you can leave one';

  @override
  String get recordDeleteCommentTitle => 'Remove this line?';

  @override
  String get recordDelete => 'Remove';

  @override
  String get recordPrivateNote => 'Private note';

  @override
  String get recordPrivateNoteHint =>
      'Only you can see this. Saved when you leave the field.';

  @override
  String get recordPrivateNoteSaved => 'Saved';

  @override
  String get recordPrivateNoteFailed => 'Not saved. Try again.';

  @override
  String get recordCommentFailed => 'Not sent. Try again.';

  @override
  String get rulesTitle => 'Rules';

  @override
  String get rulesAwayToggle => 'I\'m away';

  @override
  String rulesAwayUntil(String date) {
    return 'Away until $date';
  }

  @override
  String rulesAwayPartner(String name, String date) {
    return '$name is away until $date';
  }

  @override
  String get rulesBack => 'I\'m back';

  @override
  String get rulesStandingTitle => 'STANDING RULES';

  @override
  String get rulesStandingEmpty => 'No rules yet.';

  @override
  String get ruleGroupProtocol => 'Protocol';

  @override
  String get ruleGroupRitual => 'Ritual';

  @override
  String get ruleGroupRestriction => 'Restrictions';

  @override
  String get ruleGroupAppearance => 'Appearance';

  @override
  String get ruleGroupReporting => 'Reporting';

  @override
  String get ruleGroupOther => 'Other';

  @override
  String get rulesAddRule => 'Add a rule';

  @override
  String get rulesProposeRule => 'Propose a rule';

  @override
  String get rulesProposeChange => 'Propose a change';

  @override
  String get rulesRuleTitleLabel => 'The rule';

  @override
  String get rulesRuleBodyLabel => 'Detail (optional)';

  @override
  String get rulesGroupLabel => 'Group';

  @override
  String get rulesSave => 'Save';

  @override
  String get rulesArchive => 'Archive';

  @override
  String get rulesNeverMind => 'Never mind';

  @override
  String get rulesTasksTitle => 'RECURRING TASKS';

  @override
  String get rulesTasksEmpty => 'No tasks yet.';

  @override
  String get rulesAddTask => 'Add a task';

  @override
  String get rulesProposeTask => 'Propose a task';

  @override
  String get rulesTaskTitleLabel => 'What to do';

  @override
  String get rulesScheduleDaily => 'Every day';

  @override
  String rulesScheduleWeekdays(String days) {
    return 'Weekly $days';
  }

  @override
  String rulesScheduleEveryN(int n) {
    return 'Every $n days';
  }

  @override
  String get rulesScheduleOneOff => 'Once';

  @override
  String get rulesScheduleOpen => 'Any time';

  @override
  String get rulesScheduleCheckin => 'Check-in';

  @override
  String get rulesScheduleMeasure => 'Measure';

  @override
  String get rulesWeekdayNames => 'Mon,Tue,Wed,Thu,Fri,Sat,Sun';

  @override
  String rulesTimesPerDay(int n) {
    return '$n a day';
  }

  @override
  String get rulesProofCheck => 'Tick';

  @override
  String get rulesProofPhoto => 'Photo';

  @override
  String get rulesProofText => 'Words';

  @override
  String get rulesProofAny => 'Any';

  @override
  String rulesPoints(int n) {
    return '$n pts';
  }

  @override
  String rulesNeedsD(String name) {
    return 'Needs $name there';
  }

  @override
  String get rulesPaused => 'Paused';

  @override
  String rulesPausedUntil(String date) {
    return 'Paused until $date';
  }

  @override
  String get rulesPauseUntilDate => 'Pause until a date';

  @override
  String get rulesPauseIndefinite => 'Pause for now';

  @override
  String get rulesUnpause => 'Resume';

  @override
  String get rulesPointsLabel => 'Points (0 = base item)';

  @override
  String rulesRequiresDLabel(String name) {
    return 'Needs $name present';
  }

  @override
  String get rulesEveryNLabel => 'Every N days';

  @override
  String get rulesProposedTitle => 'PROPOSED';

  @override
  String get rulesProposedEmpty => 'Nothing proposed.';

  @override
  String get rulesAccept => 'Accept';

  @override
  String get rulesDecline => 'No';

  @override
  String rulesWaitingFor(String name) {
    return 'Waiting for $name';
  }

  @override
  String get rulesKindTask => 'Task';

  @override
  String get rulesKindRule => 'Rule';

  @override
  String get rulesWithdraw => 'Withdraw';

  @override
  String get rulesRewardsTitle => 'REWARDS';

  @override
  String get rulesRewardsEmpty => 'No rewards yet.';

  @override
  String get rulesAddReward => 'Add a reward';

  @override
  String get rulesRewardTitleLabel => 'Reward';

  @override
  String get rulesRewardCostLabel => 'Cost in points';

  @override
  String get rulesRewardDDecides => 'Decide at the time';

  @override
  String rulesRewardDDecidesName(String name) {
    return '$name decides';
  }

  @override
  String get rulesRewardRetire => 'Retire';

  @override
  String get rulesGoRedeem => 'Redeem';

  @override
  String get rulesConsequencesTitle => 'CONSEQUENCES';

  @override
  String rulesConsequencesIntro(String name) {
    return 'Only $name uses these, when disposing. They are kept here; nothing runs from here.';
  }

  @override
  String get rulesConsequencesEmpty => 'None yet.';

  @override
  String get rulesAddConsequence => 'Add one';

  @override
  String get rulesConsequenceWhen => 'When';

  @override
  String get rulesConsequenceThen => 'Then';

  @override
  String get rulesEndConsequence => 'End';

  @override
  String get rulesLimitsTitle => 'LIMITS & SAFEWORD';

  @override
  String get rulesLimitsLine =>
      'What either of you marked \"no\" in the compare lands here.';

  @override
  String get rulesLimitsGo => 'Compare';

  @override
  String get rulesExploreTitle => 'EXPLORE';

  @override
  String get rulesExploreCompare => 'Compare';

  @override
  String get rulesExploreInspiration => 'Inspiration';

  @override
  String get rulesExploreStarter => 'Starter pack';

  @override
  String get rulesPauseDynamic => 'Pause for a while';

  @override
  String get rulesCouldNotLoad => 'Rules could not be loaded.';

  @override
  String get rulesActionFailed => 'Not saved. Try again.';

  @override
  String rulesProposedSent(String name) {
    return 'Sent to $name.';
  }

  @override
  String get rulesTheD => 'the D';

  @override
  String get rulesTheS => 'the s';

  @override
  String get rulesYou => 'you';

  @override
  String ptsBalanceOf(String name, int n) {
    return '$name has $n';
  }

  @override
  String ptsBalanceMine(int n) {
    return '$n';
  }

  @override
  String get ptsGive => 'Give';

  @override
  String get ptsDeduct => 'Deduct';

  @override
  String get ptsAmountLabel => 'How many';

  @override
  String get ptsWhyLabel => 'Why (optional)';

  @override
  String ptsGiveTitle(String name) {
    return 'Give $name points';
  }

  @override
  String ptsDeductTitle(String name) {
    return 'Deduct from $name';
  }

  @override
  String get ptsRedeemableTitle => 'REDEEMABLE';

  @override
  String ptsRedeemableEmpty(String name) {
    return '$name has not set any rewards.';
  }

  @override
  String ptsShort(int n) {
    return '$n more';
  }

  @override
  String ptsRequestTitle(String title) {
    return 'Ask for \"$title\"';
  }

  @override
  String get ptsRequestNote => 'A word with it (optional)';

  @override
  String get ptsRequestSend => 'Ask';

  @override
  String get ptsRequestsTitle => 'REQUESTS';

  @override
  String get ptsRequestsEmpty => 'No requests.';

  @override
  String ptsStatusRequested(String name) {
    return 'Waiting for $name';
  }

  @override
  String ptsStatusApproved(String name) {
    return '$name approved';
  }

  @override
  String ptsStatusDenied(String name) {
    return '$name said no';
  }

  @override
  String get ptsStatusFulfilled => 'Done';

  @override
  String get ptsApprove => 'Yes';

  @override
  String get ptsDeny => 'No';

  @override
  String get ptsFulfill => 'Done';

  @override
  String get ptsDecideNote => 'A word (optional)';

  @override
  String get ptsDecideCost => 'Set the cost';

  @override
  String get ptsLedgerTitle => 'LEDGER';

  @override
  String get ptsLedgerEmpty => 'Nothing yet.';

  @override
  String get ptsReasonTaskEarn => 'Task';

  @override
  String ptsReasonAward(String name) {
    return '$name gave';
  }

  @override
  String ptsReasonDeduct(String name) {
    return '$name took';
  }

  @override
  String get ptsReasonRedemption => 'Redeemed';

  @override
  String get ptsReasonRefund => 'Returned';

  @override
  String get ptsReasonOther => 'Movement';

  @override
  String get ptsRulesTitle => 'WHAT PAYS';

  @override
  String get ptsRulesEmpty => 'No task pays yet.';

  @override
  String get ptsRulesBase => 'Everything else is a base item at 0.';

  @override
  String get ptsConsequencesTitle => 'CONSEQUENCES';

  @override
  String get ptsConsequencesEmpty => 'None.';

  @override
  String get ptsConsequenceDone => 'Done';

  @override
  String get ptsConsequenceConfirm => 'Confirm';

  @override
  String get ptsConsequenceWaive => 'Let it go';

  @override
  String get ptsConsStatusIssued => 'Not yet done';

  @override
  String ptsConsStatusDoneByS(String name) {
    return 'Done, waiting for $name';
  }

  @override
  String ptsConsStatusConfirmed(String name) {
    return '$name confirmed';
  }

  @override
  String ptsConsStatusWaived(String name) {
    return '$name let it go';
  }

  @override
  String get ptsCouldNotLoad => 'Points could not be loaded.';

  @override
  String get ptsActionFailed => 'Not saved. Try again.';

  @override
  String get exploreTitle => 'Explore';

  @override
  String get exploreBack => 'Back';

  @override
  String get exploreSectionPrefs => 'Preferences';

  @override
  String get exploreSectionCompare => 'Compare';

  @override
  String get exploreSectionCards => 'Idea cards';

  @override
  String get exploreCouldNotLoad => 'Could not be opened.';

  @override
  String get exploreActionFailed => 'That did not land. Try again.';

  @override
  String get explorePrefsIntro =>
      'Answer any three and you can already see where you meet. Only what you both answered is shown to either of you.';

  @override
  String get exploreAnswerWant => 'Want';

  @override
  String get exploreAnswerOk => 'OK';

  @override
  String get exploreAnswerNo => 'No';

  @override
  String get exploreAnswerTalk => 'Talk';

  @override
  String exploreCompareNoPartner(String name) {
    return '$name has not answered yet. Yours are saved.';
  }

  @override
  String get exploreCompareEmpty => 'Nothing you both answered yet.';

  @override
  String get exploreCompareBothWant => 'BOTH WANT';

  @override
  String get exploreCompareWantAndOk => 'ONE WANTS, ONE IS OK';

  @override
  String get exploreCompareTalks => 'SOMEONE WANTS TO TALK';

  @override
  String get exploreCompareNotDoing => 'NOT DOING';

  @override
  String get exploreCompareNotDoingLine =>
      'Marked \"no\" by one of you. Which one is nobody\'s business.';

  @override
  String get exploreCompareAddRule => 'Add to rules';

  @override
  String exploreCompareProposeRule(String name) {
    return 'Propose to $name';
  }

  @override
  String get exploreCardsEmpty => 'No cards fit right now.';

  @override
  String exploreCardIntensity(int n) {
    return 'Intensity $n';
  }

  @override
  String exploreCardNeeds(String needs) {
    return 'Needs: $needs';
  }

  @override
  String get exploreCardSaved => 'saved';

  @override
  String get exploreCardTriedAgain => 'tried · again';

  @override
  String get exploreCardTriedNever => 'tried · not again';

  @override
  String get exploreActAddToday => 'Add to today';

  @override
  String get exploreActAddRule => 'Add to rules';

  @override
  String get exploreActSave => 'Save';

  @override
  String exploreActPropose(String name) {
    return 'Propose to $name';
  }

  @override
  String get exploreActTriedAgain => 'Tried it · again';

  @override
  String get exploreActTriedNever => 'Not again';

  @override
  String get exploreActDone => 'Done.';

  @override
  String get exploreDrawTonight => 'What about tonight?';

  @override
  String get exploreDrawAgain => 'Draw another';

  @override
  String get exploreDrawFailed => 'No card came. Try again.';

  @override
  String get explorePacksTitle => 'Starter packs';

  @override
  String get explorePacksIntro =>
      'Pick one, then change every line to fit the two of you. Nothing is created until you say so.';

  @override
  String get explorePackTasks => 'TASKS';

  @override
  String get explorePackRules => 'RULES';

  @override
  String get explorePackRewards => 'REWARDS';

  @override
  String get explorePackApply => 'Use this set';

  @override
  String get explorePackApplied => 'Done. It is all under Rules now.';

  @override
  String get explorePackEdit => 'Edit this line';

  @override
  String get explorePackLineLabel => 'Line';

  @override
  String get explorePackKeep => 'Keep';

  @override
  String explorePackCount(int tasks, int rules, int rewards) {
    return '$tasks tasks · $rules rules · $rewards rewards';
  }

  @override
  String get explorePackEmptyDraft => 'Nothing left to create.';

  @override
  String get rulesStartFromPack => 'Start from a set';

  @override
  String get rulesExplorePrefs => 'Preferences';

  @override
  String get sTodayMeasureLabel => 'Value';

  @override
  String sTodayMeasureLabelUnit(String unit) {
    return 'Value ($unit)';
  }

  @override
  String get recordSeriesTitle => 'Curve';

  @override
  String get recordSeriesAction => 'Curve';

  @override
  String get recordSeriesSection => 'Curves';

  @override
  String recordSeriesEmpty(int days) {
    return 'No numbers in the last $days days.';
  }

  @override
  String recordSeriesRange(String from, String to) {
    return '$from – $to';
  }

  @override
  String recordSeriesLow(String value) {
    return 'Low $value';
  }

  @override
  String recordSeriesHigh(String value) {
    return 'High $value';
  }

  @override
  String recordSeriesLatest(String day, String value) {
    return '$day · $value';
  }

  @override
  String recordSeriesCount(int count) {
    return '$count days recorded';
  }

  @override
  String get recordExport => 'Export record';

  @override
  String recordExportLastDays(int days) {
    return 'Last $days days';
  }

  @override
  String get recordExportCustom => 'Pick dates…';

  @override
  String recordExported(String filename) {
    return 'Exported $filename';
  }

  @override
  String get recordExportFailed => 'The export did not go through. Try again.';

  @override
  String get rulesEditTask => 'Edit';

  @override
  String get rulesTaskKindLabel => 'Kind';

  @override
  String get rulesTaskKindRecurring => 'Repeats';

  @override
  String get rulesTaskKindOneOff => 'Once';

  @override
  String get rulesTaskKindOpen => 'Whenever';

  @override
  String get rulesTaskKindCheckin => 'Check-in';

  @override
  String get rulesTaskKindMeasure => 'Measure';

  @override
  String get rulesTaskDetailLabel => 'Details (optional)';

  @override
  String get rulesTaskDetailTooLong => 'At most 1000 characters';

  @override
  String get rulesTaskTitleRequired => 'Say what first';

  @override
  String get rulesScheduleLabel => 'When';

  @override
  String get rulesWeekdaysRequired => 'Pick at least one day';

  @override
  String rulesEveryNFrom(String date) {
    return 'from $date';
  }

  @override
  String get rulesEveryNInvalid => '2 to 365';

  @override
  String get rulesTimesPerDayLabel => 'Times a day';

  @override
  String rulesDueTimeLabel(String zone) {
    return 'Due ($zone)';
  }

  @override
  String get rulesDueEndOfDay => 'End of day';

  @override
  String get rulesDueAtLabel => 'Which day, what time';

  @override
  String get rulesDuePickDate => 'Pick a day';

  @override
  String get rulesDueAtRequired => 'A one-off needs a day';

  @override
  String get rulesProofLabel => 'How it is handed in';

  @override
  String get rulesProofCheckinOnly => 'A check-in is always words';

  @override
  String get rulesPointsRange => '0 to 1000';

  @override
  String get rulesPointsHint => 'Basics earn 0; they only cost when missed';

  @override
  String get rulesUnitLabel => 'Unit (kg, ml…)';

  @override
  String get rulesUnitRequired => 'A measure needs a unit';

  @override
  String get dTodayQuickMore => 'More…';

  @override
  String get joinAlreadyInHeadline => 'You are\nalready in.';

  @override
  String get joinOpenApp => 'Go to Today';

  @override
  String get joinUsedGuidance => 'If you are the one who used it, just go in.';

  @override
  String get inviteAlreadyLiveReplace => 'Withdraw it and make a new one';

  @override
  String get inviteAlreadyLiveReplaceNote =>
      'Once withdrawn, the old link stops working. The new one is shown only this once.';

  @override
  String get todayPausedLine =>
      'Paused. Nothing is delivered or disposed while it lasts.';

  @override
  String get todayPausedOpen => 'Have a look';

  @override
  String get todayWaitingPartner => 'Waiting for them to join.';

  @override
  String get todayWaitingPartnerBody =>
      'Nothing is asked here until they are in.';

  @override
  String get todayInviteLink => 'Send the invite link';

  @override
  String get sTodayEmptyRules => 'See the rules';

  @override
  String get todayWaitingPartnerBodyD =>
      'Until they are in, you can start putting rules and tasks in place.';
}
