import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of L
/// returned by `L.of(context)`.
///
/// Applications need to include `L.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: L.localizationsDelegates,
///   supportedLocales: L.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the L.supportedLocales
/// property.
abstract class L {
  L(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static L of(BuildContext context) {
    return Localizations.of<L>(context, L)!;
  }

  static const LocalizationsDelegate<L> delegate = _LDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @navToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get navToday;

  /// No description provided for @navRules.
  ///
  /// In en, this message translates to:
  /// **'Rules'**
  String get navRules;

  /// No description provided for @navRecord.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get navRecord;

  /// No description provided for @activationContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get activationContinue;

  /// No description provided for @activationStepOf.
  ///
  /// In en, this message translates to:
  /// **'{step} of 5'**
  String activationStepOf(int step);

  /// No description provided for @activationChooseOneToContinue.
  ///
  /// In en, this message translates to:
  /// **'Choose one to continue.'**
  String get activationChooseOneToContinue;

  /// No description provided for @activationGoalEyebrow.
  ///
  /// In en, this message translates to:
  /// **'BEGIN WITH INTENTION'**
  String get activationGoalEyebrow;

  /// No description provided for @activationGoalQuestion.
  ///
  /// In en, this message translates to:
  /// **'What would you\nlike more of now?'**
  String get activationGoalQuestion;

  /// No description provided for @activationGoalSupport.
  ///
  /// In en, this message translates to:
  /// **'Choose the feeling you want your\ndynamic to hold. You can change this later.'**
  String get activationGoalSupport;

  /// No description provided for @activationGoalFootnote.
  ///
  /// In en, this message translates to:
  /// **'This shapes your starting rhythm—not your limits.'**
  String get activationGoalFootnote;

  /// No description provided for @activationGoalCloser.
  ///
  /// In en, this message translates to:
  /// **'Closer'**
  String get activationGoalCloser;

  /// No description provided for @activationGoalStructure.
  ///
  /// In en, this message translates to:
  /// **'Structure'**
  String get activationGoalStructure;

  /// No description provided for @activationGoalService.
  ///
  /// In en, this message translates to:
  /// **'Service & devotion'**
  String get activationGoalService;

  /// No description provided for @activationGoalAccountability.
  ///
  /// In en, this message translates to:
  /// **'Accountability'**
  String get activationGoalAccountability;

  /// No description provided for @activationGoalExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore together'**
  String get activationGoalExplore;

  /// No description provided for @activationRoleEyebrow.
  ///
  /// In en, this message translates to:
  /// **'BEGIN TOGETHER'**
  String get activationRoleEyebrow;

  /// No description provided for @activationRoleQuestion.
  ///
  /// In en, this message translates to:
  /// **'Who is beginning\nthis with you?'**
  String get activationRoleQuestion;

  /// No description provided for @activationRoleSupport.
  ///
  /// In en, this message translates to:
  /// **'Start privately or open this space with a partner.'**
  String get activationRoleSupport;

  /// No description provided for @activationRoleFootnote.
  ///
  /// In en, this message translates to:
  /// **'A starting point, not a limit.\nYou can change this later.'**
  String get activationRoleFootnote;

  /// No description provided for @activationRoleWithPartner.
  ///
  /// In en, this message translates to:
  /// **'With a partner'**
  String get activationRoleWithPartner;

  /// No description provided for @activationRoleForMyself.
  ///
  /// In en, this message translates to:
  /// **'For myself'**
  String get activationRoleForMyself;

  /// No description provided for @activationRoleSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'YOUR STARTING ROLE'**
  String get activationRoleSectionLabel;

  /// No description provided for @activationRoleDominant.
  ///
  /// In en, this message translates to:
  /// **'Dominant'**
  String get activationRoleDominant;

  /// No description provided for @activationRoleSubmissive.
  ///
  /// In en, this message translates to:
  /// **'submissive'**
  String get activationRoleSubmissive;

  /// No description provided for @activationRoleSwitch.
  ///
  /// In en, this message translates to:
  /// **'Switch'**
  String get activationRoleSwitch;

  /// No description provided for @activationRoleCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get activationRoleCustom;

  /// No description provided for @activationRoleDecline.
  ///
  /// In en, this message translates to:
  /// **'I\'d rather not name one'**
  String get activationRoleDecline;

  /// No description provided for @activationStructureEyebrow.
  ///
  /// In en, this message translates to:
  /// **'YOUR STRUCTURE'**
  String get activationStructureEyebrow;

  /// No description provided for @activationStructureQuestion.
  ///
  /// In en, this message translates to:
  /// **'How much structure\nfeels right?'**
  String get activationStructureQuestion;

  /// No description provided for @activationStructureSupport.
  ///
  /// In en, this message translates to:
  /// **'Choose a starting rhythm. Nothing here\nremoves either person\'s voice.'**
  String get activationStructureSupport;

  /// No description provided for @activationStructureFootnote.
  ///
  /// In en, this message translates to:
  /// **'You can refine this together later.'**
  String get activationStructureFootnote;

  /// No description provided for @activationStructureLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get activationStructureLight;

  /// No description provided for @activationStructureLightDetail.
  ///
  /// In en, this message translates to:
  /// **'A gentle rhythm with plenty of room.'**
  String get activationStructureLightDetail;

  /// No description provided for @activationStructureSteady.
  ///
  /// In en, this message translates to:
  /// **'Steady'**
  String get activationStructureSteady;

  /// No description provided for @activationStructureSteadyDetail.
  ///
  /// In en, this message translates to:
  /// **'Clear expectations with room to adjust.'**
  String get activationStructureSteadyDetail;

  /// No description provided for @activationStructureDefined.
  ///
  /// In en, this message translates to:
  /// **'Defined'**
  String get activationStructureDefined;

  /// No description provided for @activationStructureDefinedDetail.
  ///
  /// In en, this message translates to:
  /// **'A firm shape you both agreed to.'**
  String get activationStructureDefinedDetail;

  /// No description provided for @activationContextLabel.
  ///
  /// In en, this message translates to:
  /// **'YOUR CONTEXT'**
  String get activationContextLabel;

  /// No description provided for @activationContextLongDistance.
  ///
  /// In en, this message translates to:
  /// **'Long-distance'**
  String get activationContextLongDistance;

  /// No description provided for @activationContextTogether.
  ///
  /// In en, this message translates to:
  /// **'Together'**
  String get activationContextTogether;

  /// No description provided for @activationContextTimezone.
  ///
  /// In en, this message translates to:
  /// **'Timezone'**
  String get activationContextTimezone;

  /// No description provided for @activationContextTimezoneDetected.
  ///
  /// In en, this message translates to:
  /// **'{zone} · detected'**
  String activationContextTimezoneDetected(String zone);

  /// No description provided for @activationRhythmEyebrow.
  ///
  /// In en, this message translates to:
  /// **'YOUR STARTING RHYTHM'**
  String get activationRhythmEyebrow;

  /// No description provided for @activationRhythmQuestion.
  ///
  /// In en, this message translates to:
  /// **'A small rhythm\nto begin.'**
  String get activationRhythmQuestion;

  /// No description provided for @activationRhythmSupport.
  ///
  /// In en, this message translates to:
  /// **'Keep what feels right. Replace anything that doesn\'t.'**
  String get activationRhythmSupport;

  /// No description provided for @activationRhythmFootnoteSolo.
  ///
  /// In en, this message translates to:
  /// **'Start light. Adjust as you go.'**
  String get activationRhythmFootnoteSolo;

  /// No description provided for @activationRhythmFootnoteCouple.
  ///
  /// In en, this message translates to:
  /// **'Start light. Adjust together.'**
  String get activationRhythmFootnoteCouple;

  /// No description provided for @activationRhythmStart.
  ///
  /// In en, this message translates to:
  /// **'Start this rhythm'**
  String get activationRhythmStart;

  /// No description provided for @activationRhythmKindRitual.
  ///
  /// In en, this message translates to:
  /// **'RITUAL'**
  String get activationRhythmKindRitual;

  /// No description provided for @activationRhythmKindExpectation.
  ///
  /// In en, this message translates to:
  /// **'EXPECTATION'**
  String get activationRhythmKindExpectation;

  /// No description provided for @activationRhythmKindCheckIn.
  ///
  /// In en, this message translates to:
  /// **'CHECK-IN'**
  String get activationRhythmKindCheckIn;

  /// No description provided for @activationRhythmEveningTitle.
  ///
  /// In en, this message translates to:
  /// **'Evening check-in'**
  String get activationRhythmEveningTitle;

  /// No description provided for @activationRhythmEveningDetail.
  ///
  /// In en, this message translates to:
  /// **'A pause for presence before the day closes.'**
  String get activationRhythmEveningDetail;

  /// No description provided for @activationRhythmSentenceTitle.
  ///
  /// In en, this message translates to:
  /// **'One honest sentence'**
  String get activationRhythmSentenceTitle;

  /// No description provided for @activationRhythmSentenceDetailSolo.
  ///
  /// In en, this message translates to:
  /// **'Name what you need today.'**
  String get activationRhythmSentenceDetailSolo;

  /// No description provided for @activationRhythmSentenceDetailCouple.
  ///
  /// In en, this message translates to:
  /// **'Share what you need today.'**
  String get activationRhythmSentenceDetailCouple;

  /// No description provided for @activationRhythmCheckInTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily check-in'**
  String get activationRhythmCheckInTitle;

  /// No description provided for @activationRhythmCheckInDetail.
  ///
  /// In en, this message translates to:
  /// **'Mood · Energy · Need'**
  String get activationRhythmCheckInDetail;

  /// No description provided for @activationErrorChooseOutcome.
  ///
  /// In en, this message translates to:
  /// **'Choose what you want more of first.'**
  String get activationErrorChooseOutcome;

  /// No description provided for @activationErrorTimezoneUnreadable.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t read this device\'s timezone. Try again.'**
  String get activationErrorTimezoneUnreadable;

  /// No description provided for @activationErrorOffline.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Connect to the internet, then try again.'**
  String get activationErrorOffline;

  /// No description provided for @activationErrorInvalidRequest.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong setting that up. Try again.'**
  String get activationErrorInvalidRequest;

  /// No description provided for @activationErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t set that up right now. Try again.'**
  String get activationErrorGeneric;

  /// No description provided for @activationErrorSessionEnded.
  ///
  /// In en, this message translates to:
  /// **'Your session ended. Sign in again to finish setting this up.'**
  String get activationErrorSessionEnded;

  /// No description provided for @activationTimezoneTitle.
  ///
  /// In en, this message translates to:
  /// **'We could not read\nyour time zone.'**
  String get activationTimezoneTitle;

  /// No description provided for @activationTimezoneWhyFirst.
  ///
  /// In en, this message translates to:
  /// **'Your day has to be measured somewhere, and guessing would move it later without saying so.'**
  String get activationTimezoneWhyFirst;

  /// No description provided for @activationTimezoneWhyRetried.
  ///
  /// In en, this message translates to:
  /// **'Still nothing. Choosing it yourself works just as well — your day is measured in the zone you pick.'**
  String get activationTimezoneWhyRetried;

  /// No description provided for @activationTimezoneTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get activationTimezoneTryAgain;

  /// No description provided for @activationTimezoneTryReadingAgain.
  ///
  /// In en, this message translates to:
  /// **'Try reading it again'**
  String get activationTimezoneTryReadingAgain;

  /// No description provided for @activationTimezoneChooseMyself.
  ///
  /// In en, this message translates to:
  /// **'Choose it myself'**
  String get activationTimezoneChooseMyself;

  /// No description provided for @activationTimezonePickerTitle.
  ///
  /// In en, this message translates to:
  /// **'WHERE YOUR DAY IS MEASURED'**
  String get activationTimezonePickerTitle;

  /// No description provided for @activationZoneChina.
  ///
  /// In en, this message translates to:
  /// **'China'**
  String get activationZoneChina;

  /// No description provided for @activationZoneJapan.
  ///
  /// In en, this message translates to:
  /// **'Japan'**
  String get activationZoneJapan;

  /// No description provided for @activationZoneSingapore.
  ///
  /// In en, this message translates to:
  /// **'Singapore'**
  String get activationZoneSingapore;

  /// No description provided for @activationZoneIndia.
  ///
  /// In en, this message translates to:
  /// **'India'**
  String get activationZoneIndia;

  /// No description provided for @activationZoneUnitedKingdom.
  ///
  /// In en, this message translates to:
  /// **'United Kingdom'**
  String get activationZoneUnitedKingdom;

  /// No description provided for @activationZoneCentralEurope.
  ///
  /// In en, this message translates to:
  /// **'Central Europe'**
  String get activationZoneCentralEurope;

  /// No description provided for @activationZoneUsEastern.
  ///
  /// In en, this message translates to:
  /// **'US Eastern'**
  String get activationZoneUsEastern;

  /// No description provided for @activationZoneUsCentral.
  ///
  /// In en, this message translates to:
  /// **'US Central'**
  String get activationZoneUsCentral;

  /// No description provided for @activationZoneUsMountain.
  ///
  /// In en, this message translates to:
  /// **'US Mountain'**
  String get activationZoneUsMountain;

  /// No description provided for @activationZoneUsPacific.
  ///
  /// In en, this message translates to:
  /// **'US Pacific'**
  String get activationZoneUsPacific;

  /// No description provided for @activationZoneEasternAustralia.
  ///
  /// In en, this message translates to:
  /// **'Eastern Australia'**
  String get activationZoneEasternAustralia;

  /// No description provided for @entranceWordmark.
  ///
  /// In en, this message translates to:
  /// **'Companion'**
  String get entranceWordmark;

  /// No description provided for @entranceHeadline.
  ///
  /// In en, this message translates to:
  /// **'A private space,\non your terms.'**
  String get entranceHeadline;

  /// No description provided for @entranceTagline.
  ///
  /// In en, this message translates to:
  /// **'Private. Considered. Yours.'**
  String get entranceTagline;

  /// No description provided for @entranceContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get entranceContinue;

  /// No description provided for @entranceContinueBusy.
  ///
  /// In en, this message translates to:
  /// **'Opening'**
  String get entranceContinueBusy;

  /// No description provided for @entranceHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get entranceHaveAccount;

  /// No description provided for @entranceNoticeChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking your session…'**
  String get entranceNoticeChecking;

  /// No description provided for @entranceNoticeSessionEnded.
  ///
  /// In en, this message translates to:
  /// **'Your session ended. Enter again when you are ready.'**
  String get entranceNoticeSessionEnded;

  /// No description provided for @entranceNoticeOffline.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Connect to continue.'**
  String get entranceNoticeOffline;

  /// No description provided for @entranceNoticeUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Could not connect. Try again.'**
  String get entranceNoticeUnreachable;

  /// No description provided for @entranceTrustFooter.
  ///
  /// In en, this message translates to:
  /// **'For adults 18+. Use of this service is subject to our Terms.\nSee how we handle data in our Privacy Policy.\nAccounts are private by default.'**
  String get entranceTrustFooter;

  /// No description provided for @entranceCreateEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get entranceCreateEyebrow;

  /// No description provided for @entranceCreateHeadline.
  ///
  /// In en, this message translates to:
  /// **'Begin privately.'**
  String get entranceCreateHeadline;

  /// No description provided for @entranceFieldEmail.
  ///
  /// In en, this message translates to:
  /// **'EMAIL'**
  String get entranceFieldEmail;

  /// No description provided for @entranceFieldEmailHint.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get entranceFieldEmailHint;

  /// No description provided for @entranceFieldCreatePassword.
  ///
  /// In en, this message translates to:
  /// **'CREATE PASSWORD'**
  String get entranceFieldCreatePassword;

  /// Placeholder under the new-password field, stating the server's real length bounds.
  ///
  /// In en, this message translates to:
  /// **'{min}–{max} characters'**
  String entranceFieldPasswordHint(int min, int max);

  /// No description provided for @entranceAgeConfirm.
  ///
  /// In en, this message translates to:
  /// **'I confirm that I am 18 or older.'**
  String get entranceAgeConfirm;

  /// No description provided for @entranceCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get entranceCreateAccount;

  /// No description provided for @entranceCreateAccountBusy.
  ///
  /// In en, this message translates to:
  /// **'Creating account'**
  String get entranceCreateAccountBusy;

  /// No description provided for @entranceLegalConsent.
  ///
  /// In en, this message translates to:
  /// **'By creating an account, you agree to the Terms\nand acknowledge the Privacy Policy.'**
  String get entranceLegalConsent;

  /// No description provided for @entranceAlreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get entranceAlreadyHaveAccount;

  /// No description provided for @entranceCreateUncertainFallback.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t confirm whether the account was created. Try signing in before creating it again.'**
  String get entranceCreateUncertainFallback;

  /// No description provided for @entranceSignInEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get entranceSignInEyebrow;

  /// No description provided for @entranceSignInHeadline.
  ///
  /// In en, this message translates to:
  /// **'Return to your space.'**
  String get entranceSignInHeadline;

  /// No description provided for @entranceFieldPassword.
  ///
  /// In en, this message translates to:
  /// **'PASSWORD'**
  String get entranceFieldPassword;

  /// No description provided for @entranceSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get entranceSignIn;

  /// No description provided for @entranceSignInBusy.
  ///
  /// In en, this message translates to:
  /// **'Signing in'**
  String get entranceSignInBusy;

  /// No description provided for @entranceSendLink.
  ///
  /// In en, this message translates to:
  /// **'Send sign-in link'**
  String get entranceSendLink;

  /// No description provided for @entranceSendLinkBusy.
  ///
  /// In en, this message translates to:
  /// **'Sending link'**
  String get entranceSendLinkBusy;

  /// No description provided for @entranceLinkModeExplainer.
  ///
  /// In en, this message translates to:
  /// **'We\'ll send a one-time sign-in link\nto the email you enter.'**
  String get entranceLinkModeExplainer;

  /// No description provided for @entranceUsePasswordInstead.
  ///
  /// In en, this message translates to:
  /// **'Use password instead'**
  String get entranceUsePasswordInstead;

  /// No description provided for @entranceUseEmailLink.
  ///
  /// In en, this message translates to:
  /// **'Use an email sign-in link'**
  String get entranceUseEmailLink;

  /// No description provided for @entranceCreateAccountLink.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get entranceCreateAccountLink;

  /// No description provided for @entranceSignInNoticeAuthorizationLost.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to continue.'**
  String get entranceSignInNoticeAuthorizationLost;

  /// No description provided for @entranceSignInNoticeOffline.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Connect, then try again.'**
  String get entranceSignInNoticeOffline;

  /// No description provided for @entranceLinkSentEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get entranceLinkSentEyebrow;

  /// No description provided for @entranceLinkSentHeadline.
  ///
  /// In en, this message translates to:
  /// **'A link is on its way.'**
  String get entranceLinkSentHeadline;

  /// No description provided for @entranceLinkSentBody.
  ///
  /// In en, this message translates to:
  /// **'If this email can be used to sign in,\nwe\'ll send a link. Check your inbox\nand spam folder.'**
  String get entranceLinkSentBody;

  /// No description provided for @entranceResendLink.
  ///
  /// In en, this message translates to:
  /// **'Resend link'**
  String get entranceResendLink;

  /// No description provided for @entranceUseDifferentEmail.
  ///
  /// In en, this message translates to:
  /// **'Use a different email'**
  String get entranceUseDifferentEmail;

  /// No description provided for @entranceCallbackEyebrowBusy.
  ///
  /// In en, this message translates to:
  /// **'Signing you in'**
  String get entranceCallbackEyebrowBusy;

  /// No description provided for @entranceCallbackEyebrowDone.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get entranceCallbackEyebrowDone;

  /// No description provided for @entranceCallbackHeadlineBusy.
  ///
  /// In en, this message translates to:
  /// **'One moment.'**
  String get entranceCallbackHeadlineBusy;

  /// No description provided for @entranceCallbackHeadlineDone.
  ///
  /// In en, this message translates to:
  /// **'This link is finished.'**
  String get entranceCallbackHeadlineDone;

  /// No description provided for @entranceCallbackIncompleteLink.
  ///
  /// In en, this message translates to:
  /// **'That link is incomplete. Request a new one.'**
  String get entranceCallbackIncompleteLink;

  /// No description provided for @entranceCallbackUnexpectedLink.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t complete that sign-in. Request a new link.'**
  String get entranceCallbackUnexpectedLink;

  /// No description provided for @entranceRequestNewLink.
  ///
  /// In en, this message translates to:
  /// **'Request a new link'**
  String get entranceRequestNewLink;

  /// No description provided for @entranceErrorAgeNotConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirm that you are 18 or older to create an account.'**
  String get entranceErrorAgeNotConfirmed;

  /// No description provided for @entranceErrorOffline.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Connect to the internet, then try again.'**
  String get entranceErrorOffline;

  /// No description provided for @entranceErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again.'**
  String get entranceErrorGeneric;

  /// No description provided for @entranceErrorUnexpected.
  ///
  /// In en, this message translates to:
  /// **'Something unexpected happened. Try again.'**
  String get entranceErrorUnexpected;

  /// No description provided for @entranceErrorLinkWrongDevice.
  ///
  /// In en, this message translates to:
  /// **'Open the link on the device where you asked for it, or request a new one.'**
  String get entranceErrorLinkWrongDevice;

  /// No description provided for @entranceErrorLinkExpired.
  ///
  /// In en, this message translates to:
  /// **'That link can no longer be used. Request a new one.'**
  String get entranceErrorLinkExpired;

  /// No description provided for @entranceErrorSignInUncertain.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t confirm the sign-in. Try again.'**
  String get entranceErrorSignInUncertain;

  /// No description provided for @entranceErrorLinkSignInUncertain.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t confirm the sign-in. Try the link again.'**
  String get entranceErrorLinkSignInUncertain;

  /// No description provided for @entranceErrorSignInGeneric.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t sign you in right now. Try again.'**
  String get entranceErrorSignInGeneric;

  /// No description provided for @entranceErrorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t sign you in with those details. Check your email and password, or use an email sign-in link.'**
  String get entranceErrorInvalidCredentials;

  /// No description provided for @entranceErrorAccountNotActive.
  ///
  /// In en, this message translates to:
  /// **'We can\'t sign you in. Try an email sign-in link or contact support.'**
  String get entranceErrorAccountNotActive;

  /// No description provided for @entranceErrorRegisterUncertain.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t confirm whether the account was created. Try signing in or request an email sign-in link before creating it again.'**
  String get entranceErrorRegisterUncertain;

  /// No description provided for @entranceErrorRegisterGeneric.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t create the account right now. Try again.'**
  String get entranceErrorRegisterGeneric;

  /// No description provided for @entranceErrorEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'That email does not look right.'**
  String get entranceErrorEmailInvalid;

  /// No description provided for @entranceErrorPasswordMissing.
  ///
  /// In en, this message translates to:
  /// **'Enter your password.'**
  String get entranceErrorPasswordMissing;

  /// No description provided for @entranceErrorCheckDetails.
  ///
  /// In en, this message translates to:
  /// **'Check the details and try again.'**
  String get entranceErrorCheckDetails;

  /// Shown beside the password field when the server rejects it as too short.
  ///
  /// In en, this message translates to:
  /// **'Use at least {min} characters.'**
  String entranceErrorPasswordTooShort(int min);

  /// Shown beside the password field when the server rejects it as too long.
  ///
  /// In en, this message translates to:
  /// **'Use no more than {max} characters.'**
  String entranceErrorPasswordTooLong(int max);

  /// No description provided for @inviteTitle.
  ///
  /// In en, this message translates to:
  /// **'Private invitation'**
  String get inviteTitle;

  /// No description provided for @inviteStatusChecking.
  ///
  /// In en, this message translates to:
  /// **'CHECKING'**
  String get inviteStatusChecking;

  /// No description provided for @inviteStatusPending.
  ///
  /// In en, this message translates to:
  /// **'PENDING'**
  String get inviteStatusPending;

  /// No description provided for @invitePreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing a private link…'**
  String get invitePreparing;

  /// No description provided for @invitePreparingNote.
  ///
  /// In en, this message translates to:
  /// **'Nothing is sent until you share it.'**
  String get invitePreparingNote;

  /// No description provided for @inviteReadyHeadline.
  ///
  /// In en, this message translates to:
  /// **'A private space\nis ready to share.'**
  String get inviteReadyHeadline;

  /// No description provided for @inviteWaitingForThem.
  ///
  /// In en, this message translates to:
  /// **'Waiting for them to join'**
  String get inviteWaitingForThem;

  /// No description provided for @inviteNothingBeginsYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing begins until both of you agree.'**
  String get inviteNothingBeginsYet;

  /// No description provided for @inviteLinkLabel.
  ///
  /// In en, this message translates to:
  /// **'PRIVATE LINK / CODE'**
  String get inviteLinkLabel;

  /// No description provided for @inviteCopyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy invitation link'**
  String get inviteCopyLink;

  /// No description provided for @inviteCopyCodeOnly.
  ///
  /// In en, this message translates to:
  /// **'Copy code only'**
  String get inviteCopyCodeOnly;

  /// No description provided for @inviteRevoke.
  ///
  /// In en, this message translates to:
  /// **'Revoke invitation'**
  String get inviteRevoke;

  /// No description provided for @inviteCopyLinkTooltip.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get inviteCopyLinkTooltip;

  /// No description provided for @inviteCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get inviteCopied;

  /// No description provided for @inviteExpired.
  ///
  /// In en, this message translates to:
  /// **'This link has expired.'**
  String get inviteExpired;

  /// No description provided for @inviteExpiresWithinHour.
  ///
  /// In en, this message translates to:
  /// **'Expires within the hour'**
  String get inviteExpiresWithinHour;

  /// How long a live invitation link has left, in whole hours.
  ///
  /// In en, this message translates to:
  /// **'Expires in {hours} hours'**
  String inviteExpiresInHours(int hours);

  /// How long a live invitation link has left, in whole days.
  ///
  /// In en, this message translates to:
  /// **'Expires in {days} days'**
  String inviteExpiresInDays(int days);

  /// No description provided for @inviteAlreadyLiveHeadline.
  ///
  /// In en, this message translates to:
  /// **'An invitation is\nalready waiting.'**
  String get inviteAlreadyLiveHeadline;

  /// No description provided for @inviteAlreadyLiveDetail.
  ///
  /// In en, this message translates to:
  /// **'Only one link can be live at a time, and a link is shown only once when it is made.'**
  String get inviteAlreadyLiveDetail;

  /// No description provided for @inviteAlreadyLiveGuidance.
  ///
  /// In en, this message translates to:
  /// **'Withdraw the existing one from your Dynamic to make a new link.'**
  String get inviteAlreadyLiveGuidance;

  /// No description provided for @inviteBackToDynamic.
  ///
  /// In en, this message translates to:
  /// **'Back to your Dynamic'**
  String get inviteBackToDynamic;

  /// No description provided for @inviteClosedHeadline.
  ///
  /// In en, this message translates to:
  /// **'This invitation\nis closed.'**
  String get inviteClosedHeadline;

  /// No description provided for @inviteCreateFailedHeadline.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t make\na private link.'**
  String get inviteCreateFailedHeadline;

  /// No description provided for @inviteClosedDetail.
  ///
  /// In en, this message translates to:
  /// **'The old link can no longer open your Dynamic. Nobody joined through it.'**
  String get inviteClosedDetail;

  /// No description provided for @inviteCreateNew.
  ///
  /// In en, this message translates to:
  /// **'Create a new invitation'**
  String get inviteCreateNew;

  /// No description provided for @inviteCreateNewNote.
  ///
  /// In en, this message translates to:
  /// **'Creating a new invitation makes a new private link.'**
  String get inviteCreateNewNote;

  /// No description provided for @inviteErrorOffline.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Connect to the internet, then try again.'**
  String get inviteErrorOffline;

  /// No description provided for @inviteErrorCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t create the link right now. Try again.'**
  String get inviteErrorCreateFailed;

  /// No description provided for @inviteErrorRevokeFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t withdraw that link right now. Try again.'**
  String get inviteErrorRevokeFailed;

  /// No description provided for @inviteErrorJoinRefused.
  ///
  /// In en, this message translates to:
  /// **'This invitation can no longer be used. Ask for a new one.'**
  String get inviteErrorJoinRefused;

  /// No description provided for @inviteErrorJoinFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t complete that just now. Try again.'**
  String get inviteErrorJoinFailed;

  /// No description provided for @joinWordmark.
  ///
  /// In en, this message translates to:
  /// **'COMPANION'**
  String get joinWordmark;

  /// No description provided for @joinResolving.
  ///
  /// In en, this message translates to:
  /// **'Checking this invitation…'**
  String get joinResolving;

  /// No description provided for @joinResolvingNote.
  ///
  /// In en, this message translates to:
  /// **'Nothing is shown until it is confirmed.'**
  String get joinResolvingNote;

  /// No description provided for @joinUnresolvedHeadline.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t check\nthis invitation.'**
  String get joinUnresolvedHeadline;

  /// No description provided for @joinUnresolvedDetail.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t determine its status.\nNo join was attempted.'**
  String get joinUnresolvedDetail;

  /// No description provided for @joinTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get joinTryAgain;

  /// No description provided for @joinUnresolvedPrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'This link is still here. Trying again is safe.'**
  String get joinUnresolvedPrivacyNote;

  /// No description provided for @joinSomeone.
  ///
  /// In en, this message translates to:
  /// **'Someone'**
  String get joinSomeone;

  /// No description provided for @joinInvitedYou.
  ///
  /// In en, this message translates to:
  /// **'invited you to begin\na private dynamic.'**
  String get joinInvitedYou;

  /// No description provided for @joinYouChooseYourRole.
  ///
  /// In en, this message translates to:
  /// **'Whoever invited you has set which side each of you is on. You will see it inside.'**
  String get joinYouChooseYourRole;

  /// No description provided for @joinNotConsentToExpectations.
  ///
  /// In en, this message translates to:
  /// **'Joining is not consent to future expectations.'**
  String get joinNotConsentToExpectations;

  /// No description provided for @joinReviewAndJoin.
  ///
  /// In en, this message translates to:
  /// **'Review and join'**
  String get joinReviewAndJoin;

  /// No description provided for @joinBusy.
  ///
  /// In en, this message translates to:
  /// **'Joining'**
  String get joinBusy;

  /// No description provided for @joinNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get joinNotNow;

  /// No description provided for @joinPrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'You can pause or leave this dynamic at any time.'**
  String get joinPrivacyNote;

  /// No description provided for @joinAlreadyJoined.
  ///
  /// In en, this message translates to:
  /// **'This invitation has brought you in.'**
  String get joinAlreadyJoined;

  /// No description provided for @joinBoundaryIntentionLabel.
  ///
  /// In en, this message translates to:
  /// **'WHAT YOU ARE STARTING'**
  String get joinBoundaryIntentionLabel;

  /// No description provided for @joinBoundaryIntention.
  ///
  /// In en, this message translates to:
  /// **'One sets the rules, one delivers; disposing and the record live here.'**
  String get joinBoundaryIntention;

  /// No description provided for @joinBoundarySharedLabel.
  ///
  /// In en, this message translates to:
  /// **'SHARED TOGETHER'**
  String get joinBoundarySharedLabel;

  /// No description provided for @joinBoundarySharedItems.
  ///
  /// In en, this message translates to:
  /// **'Starter rhythm ·\nresponses ·\nagreed changes'**
  String get joinBoundarySharedItems;

  /// No description provided for @joinBoundaryPrivateLabel.
  ///
  /// In en, this message translates to:
  /// **'STAYS YOURS'**
  String get joinBoundaryPrivateLabel;

  /// No description provided for @joinBoundaryPrivateItems.
  ///
  /// In en, this message translates to:
  /// **'Private notes ·\npersonal settings ·\nyour choice to leave'**
  String get joinBoundaryPrivateItems;

  /// No description provided for @joinUsedHeadline.
  ///
  /// In en, this message translates to:
  /// **'This invitation\nhas been used.'**
  String get joinUsedHeadline;

  /// No description provided for @joinExpiredHeadline.
  ///
  /// In en, this message translates to:
  /// **'This invitation\nhas expired.'**
  String get joinExpiredHeadline;

  /// No description provided for @joinUnavailableHeadline.
  ///
  /// In en, this message translates to:
  /// **'This invitation is\nno longer available.'**
  String get joinUnavailableHeadline;

  /// No description provided for @joinClosedPrivacyDetail.
  ///
  /// In en, this message translates to:
  /// **'For privacy, no Dynamic\ndetails are shown here.'**
  String get joinClosedPrivacyDetail;

  /// No description provided for @joinUnavailableDetail.
  ///
  /// In en, this message translates to:
  /// **'No invitation details are shown here.'**
  String get joinUnavailableDetail;

  /// No description provided for @joinNotJoinedAnything.
  ///
  /// In en, this message translates to:
  /// **'You have not joined anything.'**
  String get joinNotJoinedAnything;

  /// No description provided for @joinAskForNewLink.
  ///
  /// In en, this message translates to:
  /// **'Ask the person who invited you\nto create a new private link.'**
  String get joinAskForNewLink;

  /// No description provided for @joinAskSharer.
  ///
  /// In en, this message translates to:
  /// **'If you need a new invitation, ask the\nperson who shared this link.'**
  String get joinAskSharer;

  /// No description provided for @joinReturnToEntrance.
  ///
  /// In en, this message translates to:
  /// **'Return to private entrance'**
  String get joinReturnToEntrance;

  /// No description provided for @joinClosedPrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'This link cannot be used to join anything.'**
  String get joinClosedPrivacyNote;

  /// No description provided for @inviteLifecyclePending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get inviteLifecyclePending;

  /// No description provided for @inviteLifecycleAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get inviteLifecycleAccepted;

  /// No description provided for @inviteLifecycleExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get inviteLifecycleExpired;

  /// No description provided for @inviteLifecycleRevoked.
  ///
  /// In en, this message translates to:
  /// **'Revoked'**
  String get inviteLifecycleRevoked;

  /// No description provided for @recoveryConfirmingContext.
  ///
  /// In en, this message translates to:
  /// **'Confirming context'**
  String get recoveryConfirmingContext;

  /// No description provided for @recoveryNotConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Not confirmed'**
  String get recoveryNotConfirmed;

  /// No description provided for @recoveryOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get recoveryOffline;

  /// No description provided for @recoverySessionRestore.
  ///
  /// In en, this message translates to:
  /// **'Your private session\nneeds to be restored.'**
  String get recoverySessionRestore;

  /// No description provided for @recoverySignInAgain.
  ///
  /// In en, this message translates to:
  /// **'Sign in again'**
  String get recoverySignInAgain;

  /// No description provided for @recoveryTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get recoveryTryAgain;

  /// No description provided for @recoveryTryToReconnect.
  ///
  /// In en, this message translates to:
  /// **'Try to reconnect'**
  String get recoveryTryToReconnect;

  /// No description provided for @todayPrivateByDefault.
  ///
  /// In en, this message translates to:
  /// **'PRIVATE BY DEFAULT'**
  String get todayPrivateByDefault;

  /// No description provided for @todayPrivateByDefaultBody.
  ///
  /// In en, this message translates to:
  /// **'Nothing is shown until it is confirmed that this is you, and which day it is.'**
  String get todayPrivateByDefaultBody;

  /// No description provided for @todayCouldNotLoad.
  ///
  /// In en, this message translates to:
  /// **'Today could not be opened. Nothing was lost.'**
  String get todayCouldNotLoad;

  /// No description provided for @todayActionsPaused.
  ///
  /// In en, this message translates to:
  /// **'No connection, so nothing can be delivered yet.'**
  String get todayActionsPaused;

  /// No description provided for @todayActionsReturn.
  ///
  /// In en, this message translates to:
  /// **'Deliveries and explanations come back once you are connected.'**
  String get todayActionsReturn;

  /// No description provided for @todayHiddenDetails.
  ///
  /// In en, this message translates to:
  /// **'Everything about them and the two of you is put away for now.\nSign in again and it comes back.'**
  String get todayHiddenDetails;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get settingsClose;

  /// No description provided for @settingsLoading.
  ///
  /// In en, this message translates to:
  /// **'Reading your settings.'**
  String get settingsLoading;

  /// No description provided for @settingsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Your notification settings could not be loaded.'**
  String get settingsLoadFailed;

  /// No description provided for @settingsSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'That did not reach the server. Nothing changed.'**
  String get settingsSaveFailed;

  /// No description provided for @settingsNotificationContentSection.
  ///
  /// In en, this message translates to:
  /// **'WHAT A NOTIFICATION MAY SAY'**
  String get settingsNotificationContentSection;

  /// No description provided for @settingsPreviewNeutralLabel.
  ///
  /// In en, this message translates to:
  /// **'Nothing about the relationship'**
  String get settingsPreviewNeutralLabel;

  /// No description provided for @settingsPreviewNeutralSupport.
  ///
  /// In en, this message translates to:
  /// **'A lockscreen shows only that the app has something for you. This is the default.'**
  String get settingsPreviewNeutralSupport;

  /// No description provided for @settingsPreviewRichLabel.
  ///
  /// In en, this message translates to:
  /// **'Show the detail'**
  String get settingsPreviewRichLabel;

  /// No description provided for @settingsPreviewRichSupport.
  ///
  /// In en, this message translates to:
  /// **'Titles and names may appear on your lockscreen, where anyone holding your phone can read them.'**
  String get settingsPreviewRichSupport;

  /// No description provided for @settingsQuietHoursSection.
  ///
  /// In en, this message translates to:
  /// **'QUIET HOURS'**
  String get settingsQuietHoursSection;

  /// No description provided for @settingsQuietHoursOffLabel.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get settingsQuietHoursOffLabel;

  /// No description provided for @settingsQuietHoursOffSupport.
  ///
  /// In en, this message translates to:
  /// **'Notifications arrive whenever they happen.'**
  String get settingsQuietHoursOffSupport;

  /// No description provided for @settingsQuietHoursPresetLabel.
  ///
  /// In en, this message translates to:
  /// **'10:00 PM — 7:00 AM'**
  String get settingsQuietHoursPresetLabel;

  /// No description provided for @settingsQuietHoursPresetSupport.
  ///
  /// In en, this message translates to:
  /// **'Anything arriving in this window waits, and comes as one update rather than a replay.'**
  String get settingsQuietHoursPresetSupport;

  /// No description provided for @settingsSharedDaySection.
  ///
  /// In en, this message translates to:
  /// **'THE DAY YOU SHARE'**
  String get settingsSharedDaySection;

  /// No description provided for @settingsDayBoundaryExplain.
  ///
  /// In en, this message translates to:
  /// **'Your relationship day ends at {time}, in this timezone — not in whichever one your phone is in. Nothing moves when you travel, and daylight saving does not shift the day.'**
  String settingsDayBoundaryExplain(Object time);

  /// No description provided for @settingsPairingSection.
  ///
  /// In en, this message translates to:
  /// **'THIS PAIRING'**
  String get settingsPairingSection;

  /// No description provided for @settingsLeaveOrBlock.
  ///
  /// In en, this message translates to:
  /// **'Leave or block'**
  String get settingsLeaveOrBlock;

  /// No description provided for @settingsLeaveNeedsNoAgreement.
  ///
  /// In en, this message translates to:
  /// **'Leaving never needs your partner to agree.'**
  String get settingsLeaveNeedsNoAgreement;

  /// No description provided for @settingsDeviceSection.
  ///
  /// In en, this message translates to:
  /// **'THIS DEVICE'**
  String get settingsDeviceSection;

  /// No description provided for @settingsSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get settingsSignOut;

  /// No description provided for @settingsSignOutSupport.
  ///
  /// In en, this message translates to:
  /// **'Signing out ends this session here. Nothing about the relationship changes.'**
  String get settingsSignOutSupport;

  /// No description provided for @settingsLeaveHeadline.
  ///
  /// In en, this message translates to:
  /// **'Ending this'**
  String get settingsLeaveHeadline;

  /// No description provided for @settingsLeaveIntro.
  ///
  /// In en, this message translates to:
  /// **'Both of these end the Dynamic for both of you. Nothing happens until you confirm.'**
  String get settingsLeaveIntro;

  /// No description provided for @settingsLeaveAction.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get settingsLeaveAction;

  /// No description provided for @settingsLeaveActionSupport.
  ///
  /// In en, this message translates to:
  /// **'You stop taking part. No approval is needed.'**
  String get settingsLeaveActionSupport;

  /// No description provided for @settingsBlockAction.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get settingsBlockAction;

  /// No description provided for @settingsBlockActionSupportNoPartner.
  ///
  /// In en, this message translates to:
  /// **'There is no one here to block yet.'**
  String get settingsBlockActionSupportNoPartner;

  /// No description provided for @settingsBlockActionSupport.
  ///
  /// In en, this message translates to:
  /// **'You leave, and they cannot reach you here again.'**
  String get settingsBlockActionSupport;

  /// No description provided for @settingsLeaveConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave this Dynamic'**
  String get settingsLeaveConfirmTitle;

  /// No description provided for @settingsLeaveFactEndsForBoth.
  ///
  /// In en, this message translates to:
  /// **'It ends for both of you.'**
  String get settingsLeaveFactEndsForBoth;

  /// No description provided for @settingsLeaveFactNothingAskedAgain.
  ///
  /// In en, this message translates to:
  /// **'Neither of you will be asked for anything here again.'**
  String get settingsLeaveFactNothingAskedAgain;

  /// No description provided for @settingsLeaveFactNoAgreementNeeded.
  ///
  /// In en, this message translates to:
  /// **'Your partner is not asked to agree, and cannot stop it.'**
  String get settingsLeaveFactNoAgreementNeeded;

  /// No description provided for @settingsLeaveFactCannotUndo.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone from the app.'**
  String get settingsLeaveFactCannotUndo;

  /// No description provided for @settingsLeaveBusy.
  ///
  /// In en, this message translates to:
  /// **'Leaving…'**
  String get settingsLeaveBusy;

  /// No description provided for @settingsBlockConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get settingsBlockConfirmTitle;

  /// No description provided for @settingsBlockConfirmTitleNamed.
  ///
  /// In en, this message translates to:
  /// **'Block {name}'**
  String settingsBlockConfirmTitleNamed(Object name);

  /// No description provided for @settingsBlockPartnerFallbackName.
  ///
  /// In en, this message translates to:
  /// **'your partner'**
  String get settingsBlockPartnerFallbackName;

  /// No description provided for @settingsBlockFactEndsForBoth.
  ///
  /// In en, this message translates to:
  /// **'It ends for both of you.'**
  String get settingsBlockFactEndsForBoth;

  /// No description provided for @settingsBlockFactNoContact.
  ///
  /// In en, this message translates to:
  /// **'They will not be able to reach you here again.'**
  String get settingsBlockFactNoContact;

  /// No description provided for @settingsBlockFactNoHistory.
  ///
  /// In en, this message translates to:
  /// **'Neither of you can read the shared history afterwards.'**
  String get settingsBlockFactNoHistory;

  /// No description provided for @settingsBlockFactNotTold.
  ///
  /// In en, this message translates to:
  /// **'They are not told who did it.'**
  String get settingsBlockFactNotTold;

  /// No description provided for @settingsBlockFactCannotUndo.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone from the app.'**
  String get settingsBlockFactCannotUndo;

  /// No description provided for @settingsBlockBusy.
  ///
  /// In en, this message translates to:
  /// **'Blocking…'**
  String get settingsBlockBusy;

  /// No description provided for @settingsGoBack.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get settingsGoBack;

  /// No description provided for @settingsNoOneToBlock.
  ///
  /// In en, this message translates to:
  /// **'There is no one here to block.'**
  String get settingsNoOneToBlock;

  /// No description provided for @settingsLeaveFailed.
  ///
  /// In en, this message translates to:
  /// **'That did not reach the server. Nothing has changed.'**
  String get settingsLeaveFailed;

  /// No description provided for @shellOpeningYourSpace.
  ///
  /// In en, this message translates to:
  /// **'Opening your space…'**
  String get shellOpeningYourSpace;

  /// No description provided for @shellSignInToContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue.'**
  String get shellSignInToContinue;

  /// No description provided for @shellCouldNotOpenYourSpace.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t open\nyour space.'**
  String get shellCouldNotOpenYourSpace;

  /// No description provided for @shellSessionEndedNothingLost.
  ///
  /// In en, this message translates to:
  /// **'Your session ended. Nothing was lost.'**
  String get shellSessionEndedNothingLost;

  /// No description provided for @shellCouldNotReachYourSpace.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t reach your space just now.'**
  String get shellCouldNotReachYourSpace;

  /// No description provided for @shellSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get shellSignIn;

  /// No description provided for @shellTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get shellTryAgain;

  /// Screen-reader label for a button whose request is in flight, so a working button is not announced as an ordinary one.
  ///
  /// In en, this message translates to:
  /// **'{label}, working'**
  String shellButtonWorking(String label);

  /// No description provided for @shellShow.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get shellShow;

  /// No description provided for @shellHide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get shellHide;

  /// No description provided for @shellShowPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get shellShowPassword;

  /// No description provided for @shellHidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get shellHidePassword;

  /// No description provided for @todayTitle.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayTitle;

  /// No description provided for @todayPrivate.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get todayPrivate;

  /// No description provided for @todayPresent.
  ///
  /// In en, this message translates to:
  /// **'{name} is present'**
  String todayPresent(Object name);

  /// No description provided for @todayDayEndsAt.
  ///
  /// In en, this message translates to:
  /// **'Relationship day ends at {clock}'**
  String todayDayEndsAt(Object clock);

  /// No description provided for @settingsLanguageSection.
  ///
  /// In en, this message translates to:
  /// **'LANGUAGE'**
  String get settingsLanguageSection;

  /// No description provided for @settingsLanguageFollowDevice.
  ///
  /// In en, this message translates to:
  /// **'Follow my phone'**
  String get settingsLanguageFollowDevice;

  /// No description provided for @settingsLanguageFollowDeviceSupport.
  ///
  /// In en, this message translates to:
  /// **'Changes with your phone\'s language setting.'**
  String get settingsLanguageFollowDeviceSupport;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageChinese.
  ///
  /// In en, this message translates to:
  /// **'中文'**
  String get settingsLanguageChinese;

  /// No description provided for @settingsLanguageNote.
  ///
  /// In en, this message translates to:
  /// **'The words this app uses are part of what it means. If a term reads oddly in one language, try the other.'**
  String get settingsLanguageNote;

  /// No description provided for @pauseConfirming.
  ///
  /// In en, this message translates to:
  /// **'Confirming whether this is paused.'**
  String get pauseConfirming;

  /// No description provided for @pauseCouldNotConfirm.
  ///
  /// In en, this message translates to:
  /// **'Whether this is paused could not be confirmed. Nothing was changed.'**
  String get pauseCouldNotConfirm;

  /// No description provided for @pauseTitle.
  ///
  /// In en, this message translates to:
  /// **'Pause this Dynamic'**
  String get pauseTitle;

  /// No description provided for @pauseFactNothingExpected.
  ///
  /// In en, this message translates to:
  /// **'Nothing will be expected of either of you.'**
  String get pauseFactNothingExpected;

  /// No description provided for @pauseFactNothingDeleted.
  ///
  /// In en, this message translates to:
  /// **'Nothing already agreed is deleted.'**
  String get pauseFactNothingDeleted;

  /// No description provided for @pauseFactNoBacklog.
  ///
  /// In en, this message translates to:
  /// **'No backlog builds up while you are paused — you will not come back to a pile of missed days.'**
  String get pauseFactNoBacklog;

  /// No description provided for @pauseFactEitherCan.
  ///
  /// In en, this message translates to:
  /// **'Either of you can pause. Neither needs the other to agree.'**
  String get pauseFactEitherCan;

  /// No description provided for @pauseAction.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pauseAction;

  /// No description provided for @pauseBusy.
  ///
  /// In en, this message translates to:
  /// **'Pausing…'**
  String get pauseBusy;

  /// No description provided for @pauseNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get pauseNotNow;

  /// No description provided for @resumeTitle.
  ///
  /// In en, this message translates to:
  /// **'Come back'**
  String get resumeTitle;

  /// No description provided for @resumeNothingWaiting.
  ///
  /// In en, this message translates to:
  /// **'Nothing from the paused days is waiting. You are not behind.'**
  String get resumeNothingWaiting;

  /// No description provided for @resumeHowMuch.
  ///
  /// In en, this message translates to:
  /// **'HOW MUCH TO COME BACK TO'**
  String get resumeHowMuch;

  /// No description provided for @resumeLighter.
  ///
  /// In en, this message translates to:
  /// **'Lighter'**
  String get resumeLighter;

  /// No description provided for @resumeLighterSupport.
  ///
  /// In en, this message translates to:
  /// **'About half the structure you paused under.'**
  String get resumeLighterSupport;

  /// No description provided for @resumeSame.
  ///
  /// In en, this message translates to:
  /// **'The same as before'**
  String get resumeSame;

  /// No description provided for @resumeSameSupport.
  ///
  /// In en, this message translates to:
  /// **'Everything you had, exactly as it was.'**
  String get resumeSameSupport;

  /// No description provided for @resumeAction.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resumeAction;

  /// No description provided for @resumeBusy.
  ///
  /// In en, this message translates to:
  /// **'Resuming…'**
  String get resumeBusy;

  /// No description provided for @resumeStayPaused.
  ///
  /// In en, this message translates to:
  /// **'Stay paused'**
  String get resumeStayPaused;

  /// No description provided for @pauseFailed.
  ///
  /// In en, this message translates to:
  /// **'That did not reach the server. Nothing changed — try again.'**
  String get pauseFailed;

  /// No description provided for @resumeFailed.
  ///
  /// In en, this message translates to:
  /// **'That did not reach the server. Still paused — try again.'**
  String get resumeFailed;

  /// No description provided for @detailClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get detailClose;

  /// No description provided for @shellBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get shellBack;

  /// No description provided for @pointsTitle.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get pointsTitle;

  /// No description provided for @settingsPointsSection.
  ///
  /// In en, this message translates to:
  /// **'POINTS'**
  String get settingsPointsSection;

  /// No description provided for @settingsPointsOpen.
  ///
  /// In en, this message translates to:
  /// **'Points and rewards'**
  String get settingsPointsOpen;

  /// No description provided for @settingsPointsSupport.
  ///
  /// In en, this message translates to:
  /// **'Points can be switched off entirely. Nothing else changes if you do.'**
  String get settingsPointsSupport;

  /// No description provided for @navPoints.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get navPoints;

  /// No description provided for @todayDayStartsAt.
  ///
  /// In en, this message translates to:
  /// **'Today counts from {clock}'**
  String todayDayStartsAt(String clock);

  /// No description provided for @todayBalance.
  ///
  /// In en, this message translates to:
  /// **'{count} points'**
  String todayBalance(int count);

  /// No description provided for @todayDaysTogether.
  ///
  /// In en, this message translates to:
  /// **'{count} days together'**
  String todayDaysTogether(int count);

  /// No description provided for @todayNoteOptional.
  ///
  /// In en, this message translates to:
  /// **'A line, if you want'**
  String get todayNoteOptional;

  /// No description provided for @todaySend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get todaySend;

  /// No description provided for @todayCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get todayCancel;

  /// No description provided for @todayPartnerFallback.
  ///
  /// In en, this message translates to:
  /// **'your partner'**
  String get todayPartnerFallback;

  /// No description provided for @todayDueBy.
  ///
  /// In en, this message translates to:
  /// **'by {time}'**
  String todayDueBy(String time);

  /// No description provided for @todayPointsEarn.
  ///
  /// In en, this message translates to:
  /// **'+{count}'**
  String todayPointsEarn(int count);

  /// No description provided for @sTodayEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing is asked of you today.'**
  String get sTodayEmpty;

  /// No description provided for @sTodaySectionCheckin.
  ///
  /// In en, this message translates to:
  /// **'Check-in'**
  String get sTodaySectionCheckin;

  /// No description provided for @sTodaySectionList.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get sTodaySectionList;

  /// No description provided for @sTodaySectionOpen.
  ///
  /// In en, this message translates to:
  /// **'When you feel like it'**
  String get sTodaySectionOpen;

  /// No description provided for @sTodayDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered · waiting for {name}'**
  String sTodayDelivered(String name);

  /// No description provided for @sTodayDeliveredLate.
  ///
  /// In en, this message translates to:
  /// **'Delivered late · waiting for {name}'**
  String sTodayDeliveredLate(String name);

  /// No description provided for @sTodaySeen.
  ///
  /// In en, this message translates to:
  /// **'{name} saw it · {time}'**
  String sTodaySeen(String name, String time);

  /// No description provided for @sTodayPraised.
  ///
  /// In en, this message translates to:
  /// **'{name}: good'**
  String sTodayPraised(String name);

  /// No description provided for @sTodayPraisedNote.
  ///
  /// In en, this message translates to:
  /// **'{name}: {note}'**
  String sTodayPraisedNote(String name, String note);

  /// No description provided for @sTodayLetGo.
  ///
  /// In en, this message translates to:
  /// **'{name}: let it go'**
  String sTodayLetGo(String name);

  /// No description provided for @sTodayMakeUp.
  ///
  /// In en, this message translates to:
  /// **'{name}: make it up on {day}'**
  String sTodayMakeUp(String name, String day);

  /// No description provided for @sTodayPunished.
  ///
  /// In en, this message translates to:
  /// **'{name}: {title}'**
  String sTodayPunished(String name, String title);

  /// No description provided for @sTodayPaused.
  ///
  /// In en, this message translates to:
  /// **'{name} is away · paused'**
  String sTodayPaused(String name);

  /// No description provided for @sTodayMissed.
  ///
  /// In en, this message translates to:
  /// **'Not done'**
  String get sTodayMissed;

  /// No description provided for @sTodayCantDo.
  ///
  /// In en, this message translates to:
  /// **'Can\'t do'**
  String get sTodayCantDo;

  /// No description provided for @sTodayNewTime.
  ///
  /// In en, this message translates to:
  /// **'Asked for {time}'**
  String sTodayNewTime(String time);

  /// No description provided for @sTodayDiscuss.
  ///
  /// In en, this message translates to:
  /// **'Want to talk'**
  String get sTodayDiscuss;

  /// No description provided for @sTodayYourNote.
  ///
  /// In en, this message translates to:
  /// **'You: {note}'**
  String sTodayYourNote(String note);

  /// No description provided for @sTodayActionDeliver.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get sTodayActionDeliver;

  /// No description provided for @sTodayActionCantDo.
  ///
  /// In en, this message translates to:
  /// **'Can\'t do'**
  String get sTodayActionCantDo;

  /// No description provided for @sTodayActionNewTime.
  ///
  /// In en, this message translates to:
  /// **'Ask for a new time'**
  String get sTodayActionNewTime;

  /// No description provided for @sTodayActionDiscuss.
  ///
  /// In en, this message translates to:
  /// **'Want to talk'**
  String get sTodayActionDiscuss;

  /// No description provided for @sTodayActionWithdraw.
  ///
  /// In en, this message translates to:
  /// **'Take it back'**
  String get sTodayActionWithdraw;

  /// No description provided for @sTodayWriteLine.
  ///
  /// In en, this message translates to:
  /// **'Write a line'**
  String get sTodayWriteLine;

  /// No description provided for @sTodayPhotoRef.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get sTodayPhotoRef;

  /// No description provided for @sTodayPhotoHint.
  ///
  /// In en, this message translates to:
  /// **'Paste a photo reference for now; the camera comes in a later build.'**
  String get sTodayPhotoHint;

  /// No description provided for @sTodayProofCamera.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get sTodayProofCamera;

  /// No description provided for @sTodayProofGallery.
  ///
  /// In en, this message translates to:
  /// **'From the gallery'**
  String get sTodayProofGallery;

  /// No description provided for @sTodayPhotoFailed.
  ///
  /// In en, this message translates to:
  /// **'The photo did not upload; nothing changed.'**
  String get sTodayPhotoFailed;

  /// No description provided for @sTodayPickTime.
  ///
  /// In en, this message translates to:
  /// **'Pick a time'**
  String get sTodayPickTime;

  /// No description provided for @sTodayConflictPaused.
  ///
  /// In en, this message translates to:
  /// **'{name} paused this.'**
  String sTodayConflictPaused(String name);

  /// No description provided for @sTodayConflictDisposed.
  ///
  /// In en, this message translates to:
  /// **'{name} already answered this.'**
  String sTodayConflictDisposed(String name);

  /// No description provided for @sTodayConflictChanged.
  ///
  /// In en, this message translates to:
  /// **'This changed elsewhere.'**
  String get sTodayConflictChanged;

  /// No description provided for @sTodayConflictOther.
  ///
  /// In en, this message translates to:
  /// **'Not sent. Try again.'**
  String get sTodayConflictOther;

  /// No description provided for @dTodayEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing waiting for you.'**
  String get dTodayEmpty;

  /// No description provided for @dTodaySectionNeedsMe.
  ///
  /// In en, this message translates to:
  /// **'Waiting on me'**
  String get dTodaySectionNeedsMe;

  /// No description provided for @dTodaySectionOverview.
  ///
  /// In en, this message translates to:
  /// **'Today for {name}'**
  String dTodaySectionOverview(String name);

  /// No description provided for @dTodayOverviewDelivered.
  ///
  /// In en, this message translates to:
  /// **'{done}/{total} delivered'**
  String dTodayOverviewDelivered(int done, int total);

  /// No description provided for @dTodayOverviewFlagged.
  ///
  /// In en, this message translates to:
  /// **'{count} said something'**
  String dTodayOverviewFlagged(int count);

  /// No description provided for @dTodaySaidDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered · {time}'**
  String dTodaySaidDelivered(String time);

  /// No description provided for @dTodaySaidLate.
  ///
  /// In en, this message translates to:
  /// **'Delivered late · {time}'**
  String dTodaySaidLate(String time);

  /// No description provided for @dTodaySaidCantDo.
  ///
  /// In en, this message translates to:
  /// **'Can\'t do'**
  String get dTodaySaidCantDo;

  /// No description provided for @dTodaySaidNewTime.
  ///
  /// In en, this message translates to:
  /// **'Asks for {time}'**
  String dTodaySaidNewTime(String time);

  /// No description provided for @dTodaySaidDiscuss.
  ///
  /// In en, this message translates to:
  /// **'Wants to talk'**
  String get dTodaySaidDiscuss;

  /// No description provided for @dTodaySaidMissed.
  ///
  /// In en, this message translates to:
  /// **'Not done'**
  String get dTodaySaidMissed;

  /// No description provided for @dTodaySaidNote.
  ///
  /// In en, this message translates to:
  /// **'{name}: {note}'**
  String dTodaySaidNote(String name, String note);

  /// No description provided for @dTodayProofPhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo: {ref}'**
  String dTodayProofPhoto(String ref);

  /// No description provided for @dTodayOnDay.
  ///
  /// In en, this message translates to:
  /// **'{day}'**
  String dTodayOnDay(String day);

  /// No description provided for @dTodayActionSeen.
  ///
  /// In en, this message translates to:
  /// **'Seen'**
  String get dTodayActionSeen;

  /// No description provided for @dTodayActionPraise.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get dTodayActionPraise;

  /// No description provided for @dTodayActionLetGo.
  ///
  /// In en, this message translates to:
  /// **'Let it go'**
  String get dTodayActionLetGo;

  /// No description provided for @dTodayActionMakeUp.
  ///
  /// In en, this message translates to:
  /// **'Make it up'**
  String get dTodayActionMakeUp;

  /// No description provided for @dTodayActionPunish.
  ///
  /// In en, this message translates to:
  /// **'Consequence'**
  String get dTodayActionPunish;

  /// No description provided for @dTodayMakeUpWhich.
  ///
  /// In en, this message translates to:
  /// **'Which day?'**
  String get dTodayMakeUpWhich;

  /// No description provided for @dTodayPunishWhich.
  ///
  /// In en, this message translates to:
  /// **'Which consequence?'**
  String get dTodayPunishWhich;

  /// No description provided for @dTodayPunishOwn.
  ///
  /// In en, this message translates to:
  /// **'Your own words'**
  String get dTodayPunishOwn;

  /// No description provided for @dTodayPunishTitle.
  ///
  /// In en, this message translates to:
  /// **'Consequence'**
  String get dTodayPunishTitle;

  /// No description provided for @dTodayConflictOpen.
  ///
  /// In en, this message translates to:
  /// **'Nothing to answer yet.'**
  String get dTodayConflictOpen;

  /// No description provided for @dTodayConflictPaused.
  ///
  /// In en, this message translates to:
  /// **'This one is paused.'**
  String get dTodayConflictPaused;

  /// No description provided for @dTodayConflictChanged.
  ///
  /// In en, this message translates to:
  /// **'This changed elsewhere.'**
  String get dTodayConflictChanged;

  /// No description provided for @dTodayConflictOther.
  ///
  /// In en, this message translates to:
  /// **'Not sent. Try again.'**
  String get dTodayConflictOther;

  /// No description provided for @dTodaySectionQuickAdd.
  ///
  /// In en, this message translates to:
  /// **'Add one'**
  String get dTodaySectionQuickAdd;

  /// No description provided for @dTodayQuickTitle.
  ///
  /// In en, this message translates to:
  /// **'What'**
  String get dTodayQuickTitle;

  /// No description provided for @dTodayQuickToday.
  ///
  /// In en, this message translates to:
  /// **'Just today'**
  String get dTodayQuickToday;

  /// No description provided for @dTodayQuickDaily.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get dTodayQuickDaily;

  /// No description provided for @dTodayQuickPoints.
  ///
  /// In en, this message translates to:
  /// **'Points (optional)'**
  String get dTodayQuickPoints;

  /// No description provided for @dTodayQuickAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get dTodayQuickAdd;

  /// No description provided for @dTodayQuickAdded.
  ///
  /// In en, this message translates to:
  /// **'Added.'**
  String get dTodayQuickAdded;

  /// No description provided for @dTodayQuickFailed.
  ///
  /// In en, this message translates to:
  /// **'Not added. Try again.'**
  String get dTodayQuickFailed;

  /// No description provided for @dTodaySectionNotes.
  ///
  /// In en, this message translates to:
  /// **'To remember'**
  String get dTodaySectionNotes;

  /// No description provided for @dTodayNoteBody.
  ///
  /// In en, this message translates to:
  /// **'Note to self'**
  String get dTodayNoteBody;

  /// No description provided for @dTodayNoteRemind.
  ///
  /// In en, this message translates to:
  /// **'Remind me'**
  String get dTodayNoteRemind;

  /// No description provided for @dTodayNoteRemindAt.
  ///
  /// In en, this message translates to:
  /// **'Remind · {time}'**
  String dTodayNoteRemindAt(String time);

  /// No description provided for @dTodayNoteDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get dTodayNoteDone;

  /// No description provided for @dTodayNoteDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get dTodayNoteDelete;

  /// No description provided for @dTodayNoteAdd.
  ///
  /// In en, this message translates to:
  /// **'Keep it'**
  String get dTodayNoteAdd;

  /// No description provided for @dTodayNotesPrivate.
  ///
  /// In en, this message translates to:
  /// **'Only you see these.'**
  String get dTodayNotesPrivate;

  /// No description provided for @settingsDayStart.
  ///
  /// In en, this message translates to:
  /// **'The day starts at {time}'**
  String settingsDayStart(String time);

  /// No description provided for @settingsDayStartReadOnly.
  ///
  /// In en, this message translates to:
  /// **'Changing it comes in a later build.'**
  String get settingsDayStartReadOnly;

  /// No description provided for @settingsDeviceLock.
  ///
  /// In en, this message translates to:
  /// **'Device lock'**
  String get settingsDeviceLock;

  /// No description provided for @settingsDeviceLockSupport.
  ///
  /// In en, this message translates to:
  /// **'Ask for fingerprint, face or the device PIN when the app opens, or comes back after half a minute away.'**
  String get settingsDeviceLockSupport;

  /// No description provided for @settingsDeviceLockUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This device cannot lock the app.'**
  String get settingsDeviceLockUnavailable;

  /// No description provided for @lockTitle.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get lockTitle;

  /// No description provided for @lockUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get lockUnlock;

  /// No description provided for @lockReason.
  ///
  /// In en, this message translates to:
  /// **'Unlock to continue'**
  String get lockReason;

  /// No description provided for @recordTogether.
  ///
  /// In en, this message translates to:
  /// **'Together {days} days · {streak} in a row'**
  String recordTogether(int days, int streak);

  /// No description provided for @recordPrevMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get recordPrevMonth;

  /// No description provided for @recordNextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get recordNextMonth;

  /// No description provided for @recordFactsTitle.
  ///
  /// In en, this message translates to:
  /// **'This week · this month'**
  String get recordFactsTitle;

  /// No description provided for @recordFactsWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get recordFactsWeek;

  /// No description provided for @recordFactsMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get recordFactsMonth;

  /// No description provided for @recordFactDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get recordFactDelivered;

  /// No description provided for @recordFactLate.
  ///
  /// In en, this message translates to:
  /// **'Delivered late'**
  String get recordFactLate;

  /// No description provided for @recordFactFlagged.
  ///
  /// In en, this message translates to:
  /// **'Explained'**
  String get recordFactFlagged;

  /// No description provided for @recordFactMissed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get recordFactMissed;

  /// No description provided for @recordFactLetGo.
  ///
  /// In en, this message translates to:
  /// **'Let go'**
  String get recordFactLetGo;

  /// No description provided for @recordFactPraised.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get recordFactPraised;

  /// No description provided for @recordFactMadeUp.
  ///
  /// In en, this message translates to:
  /// **'Make it up'**
  String get recordFactMadeUp;

  /// No description provided for @recordFactPunished.
  ///
  /// In en, this message translates to:
  /// **'Consequence'**
  String get recordFactPunished;

  /// No description provided for @recordFactComments.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get recordFactComments;

  /// No description provided for @recordFactPointsEarned.
  ///
  /// In en, this message translates to:
  /// **'Points earned'**
  String get recordFactPointsEarned;

  /// No description provided for @recordFactPointsDeducted.
  ///
  /// In en, this message translates to:
  /// **'Points deducted'**
  String get recordFactPointsDeducted;

  /// No description provided for @recordFactRedemptions.
  ///
  /// In en, this message translates to:
  /// **'Redemptions'**
  String get recordFactRedemptions;

  /// No description provided for @recordCouldNotLoad.
  ///
  /// In en, this message translates to:
  /// **'The record could not be loaded.'**
  String get recordCouldNotLoad;

  /// No description provided for @recordDayCouldNotLoad.
  ///
  /// In en, this message translates to:
  /// **'This day could not be loaded.'**
  String get recordDayCouldNotLoad;

  /// No description provided for @recordDayEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing was written on this day.'**
  String get recordDayEmpty;

  /// No description provided for @recordMe.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get recordMe;

  /// No description provided for @recordBack.
  ///
  /// In en, this message translates to:
  /// **'Back to the record'**
  String get recordBack;

  /// No description provided for @recordDelivered.
  ///
  /// In en, this message translates to:
  /// **'{name} delivered “{title}”'**
  String recordDelivered(String name, String title);

  /// No description provided for @recordDeliveredLate.
  ///
  /// In en, this message translates to:
  /// **'{name} delivered “{title}”, late'**
  String recordDeliveredLate(String name, String title);

  /// No description provided for @recordCantDo.
  ///
  /// In en, this message translates to:
  /// **'{name} said “{title}” can\'t be done'**
  String recordCantDo(String name, String title);

  /// No description provided for @recordNewTime.
  ///
  /// In en, this message translates to:
  /// **'{name} asked for a new time on “{title}”'**
  String recordNewTime(String name, String title);

  /// No description provided for @recordDiscuss.
  ///
  /// In en, this message translates to:
  /// **'{name} wants to talk about “{title}”'**
  String recordDiscuss(String name, String title);

  /// No description provided for @recordWithdrew.
  ///
  /// In en, this message translates to:
  /// **'{name} took back “{title}”'**
  String recordWithdrew(String name, String title);

  /// No description provided for @recordMissed.
  ///
  /// In en, this message translates to:
  /// **'“{title}” was not delivered that day'**
  String recordMissed(String title);

  /// No description provided for @recordPausedEntry.
  ///
  /// In en, this message translates to:
  /// **'“{title}” was paused'**
  String recordPausedEntry(String title);

  /// No description provided for @recordSeen.
  ///
  /// In en, this message translates to:
  /// **'{name} saw “{title}”'**
  String recordSeen(String name, String title);

  /// No description provided for @recordPraised.
  ///
  /// In en, this message translates to:
  /// **'{name}: good — “{title}”'**
  String recordPraised(String name, String title);

  /// No description provided for @recordLetGo.
  ///
  /// In en, this message translates to:
  /// **'{name} let “{title}” go'**
  String recordLetGo(String name, String title);

  /// No description provided for @recordMakeUp.
  ///
  /// In en, this message translates to:
  /// **'{name}: make up “{title}” on {day}'**
  String recordMakeUp(String name, String title, String day);

  /// No description provided for @recordPunished.
  ///
  /// In en, this message translates to:
  /// **'{name}: consequence for “{title}” — {consequence}'**
  String recordPunished(String name, String title, String consequence);

  /// No description provided for @recordDispositionCleared.
  ///
  /// In en, this message translates to:
  /// **'{name} took back the answer on “{title}”'**
  String recordDispositionCleared(String name, String title);

  /// No description provided for @recordPhotoRef.
  ///
  /// In en, this message translates to:
  /// **'Photo: {ref}'**
  String recordPhotoRef(String ref);

  /// No description provided for @recordCommented.
  ///
  /// In en, this message translates to:
  /// **'{name} left a line'**
  String recordCommented(String name);

  /// No description provided for @recordPointsEarnedAuto.
  ///
  /// In en, this message translates to:
  /// **'+{amount} points · {reason}'**
  String recordPointsEarnedAuto(int amount, String reason);

  /// No description provided for @recordPointsAdded.
  ///
  /// In en, this message translates to:
  /// **'{name} added {amount} points'**
  String recordPointsAdded(String name, int amount);

  /// No description provided for @recordPointsDeducted.
  ///
  /// In en, this message translates to:
  /// **'{name} deducted {amount} points'**
  String recordPointsDeducted(String name, int amount);

  /// No description provided for @recordReasonTaskEarn.
  ///
  /// In en, this message translates to:
  /// **'task'**
  String get recordReasonTaskEarn;

  /// No description provided for @recordReasonAward.
  ///
  /// In en, this message translates to:
  /// **'given'**
  String get recordReasonAward;

  /// No description provided for @recordReasonDeduct.
  ///
  /// In en, this message translates to:
  /// **'deducted'**
  String get recordReasonDeduct;

  /// No description provided for @recordReasonRedemption.
  ///
  /// In en, this message translates to:
  /// **'redeemed'**
  String get recordReasonRedemption;

  /// No description provided for @recordReasonRefund.
  ///
  /// In en, this message translates to:
  /// **'refunded'**
  String get recordReasonRefund;

  /// No description provided for @recordRedeemed.
  ///
  /// In en, this message translates to:
  /// **'{name} redeemed “{title}”'**
  String recordRedeemed(String name, String title);

  /// No description provided for @recordActionDeliverLate.
  ///
  /// In en, this message translates to:
  /// **'Deliver now'**
  String get recordActionDeliverLate;

  /// No description provided for @recordActionCantDo.
  ///
  /// In en, this message translates to:
  /// **'Explain: can\'t do'**
  String get recordActionCantDo;

  /// No description provided for @recordComments.
  ///
  /// In en, this message translates to:
  /// **'A line on this day'**
  String get recordComments;

  /// No description provided for @recordCommentHint.
  ///
  /// In en, this message translates to:
  /// **'Either of you can leave one'**
  String get recordCommentHint;

  /// No description provided for @recordDeleteCommentTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove this line?'**
  String get recordDeleteCommentTitle;

  /// No description provided for @recordDelete.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get recordDelete;

  /// No description provided for @recordPrivateNote.
  ///
  /// In en, this message translates to:
  /// **'Private note'**
  String get recordPrivateNote;

  /// No description provided for @recordPrivateNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Only you can see this. Saved when you leave the field.'**
  String get recordPrivateNoteHint;

  /// No description provided for @recordPrivateNoteSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get recordPrivateNoteSaved;

  /// No description provided for @recordPrivateNoteFailed.
  ///
  /// In en, this message translates to:
  /// **'Not saved. Try again.'**
  String get recordPrivateNoteFailed;

  /// No description provided for @recordCommentFailed.
  ///
  /// In en, this message translates to:
  /// **'Not sent. Try again.'**
  String get recordCommentFailed;

  /// No description provided for @rulesTitle.
  ///
  /// In en, this message translates to:
  /// **'Rules'**
  String get rulesTitle;

  /// No description provided for @rulesAwayToggle.
  ///
  /// In en, this message translates to:
  /// **'I\'m away'**
  String get rulesAwayToggle;

  /// No description provided for @rulesAwayUntil.
  ///
  /// In en, this message translates to:
  /// **'Away until {date}'**
  String rulesAwayUntil(String date);

  /// No description provided for @rulesAwayPartner.
  ///
  /// In en, this message translates to:
  /// **'{name} is away until {date}'**
  String rulesAwayPartner(String name, String date);

  /// No description provided for @rulesBack.
  ///
  /// In en, this message translates to:
  /// **'I\'m back'**
  String get rulesBack;

  /// No description provided for @rulesStandingTitle.
  ///
  /// In en, this message translates to:
  /// **'STANDING RULES'**
  String get rulesStandingTitle;

  /// No description provided for @rulesStandingEmpty.
  ///
  /// In en, this message translates to:
  /// **'No rules yet.'**
  String get rulesStandingEmpty;

  /// No description provided for @ruleGroupProtocol.
  ///
  /// In en, this message translates to:
  /// **'Protocol'**
  String get ruleGroupProtocol;

  /// No description provided for @ruleGroupRitual.
  ///
  /// In en, this message translates to:
  /// **'Ritual'**
  String get ruleGroupRitual;

  /// No description provided for @ruleGroupRestriction.
  ///
  /// In en, this message translates to:
  /// **'Restrictions'**
  String get ruleGroupRestriction;

  /// No description provided for @ruleGroupAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get ruleGroupAppearance;

  /// No description provided for @ruleGroupReporting.
  ///
  /// In en, this message translates to:
  /// **'Reporting'**
  String get ruleGroupReporting;

  /// No description provided for @ruleGroupOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get ruleGroupOther;

  /// No description provided for @rulesAddRule.
  ///
  /// In en, this message translates to:
  /// **'Add a rule'**
  String get rulesAddRule;

  /// No description provided for @rulesProposeRule.
  ///
  /// In en, this message translates to:
  /// **'Propose a rule'**
  String get rulesProposeRule;

  /// No description provided for @rulesProposeChange.
  ///
  /// In en, this message translates to:
  /// **'Propose a change'**
  String get rulesProposeChange;

  /// No description provided for @rulesRuleTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'The rule'**
  String get rulesRuleTitleLabel;

  /// No description provided for @rulesRuleBodyLabel.
  ///
  /// In en, this message translates to:
  /// **'Detail (optional)'**
  String get rulesRuleBodyLabel;

  /// No description provided for @rulesGroupLabel.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get rulesGroupLabel;

  /// No description provided for @rulesSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get rulesSave;

  /// No description provided for @rulesArchive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get rulesArchive;

  /// No description provided for @rulesNeverMind.
  ///
  /// In en, this message translates to:
  /// **'Never mind'**
  String get rulesNeverMind;

  /// No description provided for @rulesTasksTitle.
  ///
  /// In en, this message translates to:
  /// **'RECURRING TASKS'**
  String get rulesTasksTitle;

  /// No description provided for @rulesTasksEmpty.
  ///
  /// In en, this message translates to:
  /// **'No tasks yet.'**
  String get rulesTasksEmpty;

  /// No description provided for @rulesAddTask.
  ///
  /// In en, this message translates to:
  /// **'Add a task'**
  String get rulesAddTask;

  /// No description provided for @rulesProposeTask.
  ///
  /// In en, this message translates to:
  /// **'Propose a task'**
  String get rulesProposeTask;

  /// No description provided for @rulesTaskTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'What to do'**
  String get rulesTaskTitleLabel;

  /// No description provided for @rulesScheduleDaily.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get rulesScheduleDaily;

  /// No description provided for @rulesScheduleWeekdays.
  ///
  /// In en, this message translates to:
  /// **'Weekly {days}'**
  String rulesScheduleWeekdays(String days);

  /// No description provided for @rulesScheduleEveryN.
  ///
  /// In en, this message translates to:
  /// **'Every {n} days'**
  String rulesScheduleEveryN(int n);

  /// No description provided for @rulesScheduleOneOff.
  ///
  /// In en, this message translates to:
  /// **'Once'**
  String get rulesScheduleOneOff;

  /// No description provided for @rulesScheduleOpen.
  ///
  /// In en, this message translates to:
  /// **'Any time'**
  String get rulesScheduleOpen;

  /// No description provided for @rulesScheduleCheckin.
  ///
  /// In en, this message translates to:
  /// **'Check-in'**
  String get rulesScheduleCheckin;

  /// No description provided for @rulesScheduleMeasure.
  ///
  /// In en, this message translates to:
  /// **'Measure'**
  String get rulesScheduleMeasure;

  /// No description provided for @rulesWeekdayNames.
  ///
  /// In en, this message translates to:
  /// **'Mon,Tue,Wed,Thu,Fri,Sat,Sun'**
  String get rulesWeekdayNames;

  /// No description provided for @rulesTimesPerDay.
  ///
  /// In en, this message translates to:
  /// **'{n} a day'**
  String rulesTimesPerDay(int n);

  /// No description provided for @rulesProofCheck.
  ///
  /// In en, this message translates to:
  /// **'Tick'**
  String get rulesProofCheck;

  /// No description provided for @rulesProofPhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get rulesProofPhoto;

  /// No description provided for @rulesProofText.
  ///
  /// In en, this message translates to:
  /// **'Words'**
  String get rulesProofText;

  /// No description provided for @rulesProofAny.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get rulesProofAny;

  /// No description provided for @rulesPoints.
  ///
  /// In en, this message translates to:
  /// **'{n} pts'**
  String rulesPoints(int n);

  /// No description provided for @rulesNeedsD.
  ///
  /// In en, this message translates to:
  /// **'Needs {name} there'**
  String rulesNeedsD(String name);

  /// No description provided for @rulesPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get rulesPaused;

  /// No description provided for @rulesPausedUntil.
  ///
  /// In en, this message translates to:
  /// **'Paused until {date}'**
  String rulesPausedUntil(String date);

  /// No description provided for @rulesPauseUntilDate.
  ///
  /// In en, this message translates to:
  /// **'Pause until a date'**
  String get rulesPauseUntilDate;

  /// No description provided for @rulesPauseIndefinite.
  ///
  /// In en, this message translates to:
  /// **'Pause for now'**
  String get rulesPauseIndefinite;

  /// No description provided for @rulesUnpause.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get rulesUnpause;

  /// No description provided for @rulesPointsLabel.
  ///
  /// In en, this message translates to:
  /// **'Points (0 = base item)'**
  String get rulesPointsLabel;

  /// No description provided for @rulesRequiresDLabel.
  ///
  /// In en, this message translates to:
  /// **'Needs {name} present'**
  String rulesRequiresDLabel(String name);

  /// No description provided for @rulesEveryNLabel.
  ///
  /// In en, this message translates to:
  /// **'Every N days'**
  String get rulesEveryNLabel;

  /// No description provided for @rulesProposedTitle.
  ///
  /// In en, this message translates to:
  /// **'PROPOSED'**
  String get rulesProposedTitle;

  /// No description provided for @rulesProposedEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing proposed.'**
  String get rulesProposedEmpty;

  /// No description provided for @rulesAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get rulesAccept;

  /// No description provided for @rulesDecline.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get rulesDecline;

  /// No description provided for @rulesWaitingFor.
  ///
  /// In en, this message translates to:
  /// **'Waiting for {name}'**
  String rulesWaitingFor(String name);

  /// No description provided for @rulesKindTask.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get rulesKindTask;

  /// No description provided for @rulesKindRule.
  ///
  /// In en, this message translates to:
  /// **'Rule'**
  String get rulesKindRule;

  /// No description provided for @rulesWithdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get rulesWithdraw;

  /// No description provided for @rulesRewardsTitle.
  ///
  /// In en, this message translates to:
  /// **'REWARDS'**
  String get rulesRewardsTitle;

  /// No description provided for @rulesRewardsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No rewards yet.'**
  String get rulesRewardsEmpty;

  /// No description provided for @rulesAddReward.
  ///
  /// In en, this message translates to:
  /// **'Add a reward'**
  String get rulesAddReward;

  /// No description provided for @rulesRewardTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Reward'**
  String get rulesRewardTitleLabel;

  /// No description provided for @rulesRewardCostLabel.
  ///
  /// In en, this message translates to:
  /// **'Cost in points'**
  String get rulesRewardCostLabel;

  /// No description provided for @rulesRewardDDecides.
  ///
  /// In en, this message translates to:
  /// **'Decide at the time'**
  String get rulesRewardDDecides;

  /// No description provided for @rulesRewardDDecidesName.
  ///
  /// In en, this message translates to:
  /// **'{name} decides'**
  String rulesRewardDDecidesName(String name);

  /// No description provided for @rulesRewardRetire.
  ///
  /// In en, this message translates to:
  /// **'Retire'**
  String get rulesRewardRetire;

  /// No description provided for @rulesGoRedeem.
  ///
  /// In en, this message translates to:
  /// **'Redeem'**
  String get rulesGoRedeem;

  /// No description provided for @rulesConsequencesTitle.
  ///
  /// In en, this message translates to:
  /// **'CONSEQUENCES'**
  String get rulesConsequencesTitle;

  /// No description provided for @rulesConsequencesIntro.
  ///
  /// In en, this message translates to:
  /// **'Only {name} uses these, when disposing. They are kept here; nothing runs from here.'**
  String rulesConsequencesIntro(String name);

  /// No description provided for @rulesConsequencesEmpty.
  ///
  /// In en, this message translates to:
  /// **'None yet.'**
  String get rulesConsequencesEmpty;

  /// No description provided for @rulesAddConsequence.
  ///
  /// In en, this message translates to:
  /// **'Add one'**
  String get rulesAddConsequence;

  /// No description provided for @rulesConsequenceWhen.
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get rulesConsequenceWhen;

  /// No description provided for @rulesConsequenceThen.
  ///
  /// In en, this message translates to:
  /// **'Then'**
  String get rulesConsequenceThen;

  /// No description provided for @rulesEndConsequence.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get rulesEndConsequence;

  /// No description provided for @rulesLimitsTitle.
  ///
  /// In en, this message translates to:
  /// **'LIMITS & SAFEWORD'**
  String get rulesLimitsTitle;

  /// No description provided for @rulesLimitsLine.
  ///
  /// In en, this message translates to:
  /// **'What either of you marked \"no\" in the compare lands here.'**
  String get rulesLimitsLine;

  /// No description provided for @rulesLimitsGo.
  ///
  /// In en, this message translates to:
  /// **'Compare'**
  String get rulesLimitsGo;

  /// No description provided for @rulesExploreTitle.
  ///
  /// In en, this message translates to:
  /// **'EXPLORE'**
  String get rulesExploreTitle;

  /// No description provided for @rulesExploreCompare.
  ///
  /// In en, this message translates to:
  /// **'Compare'**
  String get rulesExploreCompare;

  /// No description provided for @rulesExploreInspiration.
  ///
  /// In en, this message translates to:
  /// **'Inspiration'**
  String get rulesExploreInspiration;

  /// No description provided for @rulesExploreStarter.
  ///
  /// In en, this message translates to:
  /// **'Starter pack'**
  String get rulesExploreStarter;

  /// No description provided for @rulesPauseDynamic.
  ///
  /// In en, this message translates to:
  /// **'Pause for a while'**
  String get rulesPauseDynamic;

  /// No description provided for @rulesCouldNotLoad.
  ///
  /// In en, this message translates to:
  /// **'Rules could not be loaded.'**
  String get rulesCouldNotLoad;

  /// No description provided for @rulesActionFailed.
  ///
  /// In en, this message translates to:
  /// **'Not saved. Try again.'**
  String get rulesActionFailed;

  /// No description provided for @rulesProposedSent.
  ///
  /// In en, this message translates to:
  /// **'Sent to {name}.'**
  String rulesProposedSent(String name);

  /// No description provided for @rulesTheD.
  ///
  /// In en, this message translates to:
  /// **'the D'**
  String get rulesTheD;

  /// No description provided for @rulesTheS.
  ///
  /// In en, this message translates to:
  /// **'the s'**
  String get rulesTheS;

  /// No description provided for @rulesYou.
  ///
  /// In en, this message translates to:
  /// **'you'**
  String get rulesYou;

  /// No description provided for @ptsBalanceOf.
  ///
  /// In en, this message translates to:
  /// **'{name} has {n}'**
  String ptsBalanceOf(String name, int n);

  /// No description provided for @ptsBalanceMine.
  ///
  /// In en, this message translates to:
  /// **'{n}'**
  String ptsBalanceMine(int n);

  /// No description provided for @ptsGive.
  ///
  /// In en, this message translates to:
  /// **'Give'**
  String get ptsGive;

  /// No description provided for @ptsDeduct.
  ///
  /// In en, this message translates to:
  /// **'Deduct'**
  String get ptsDeduct;

  /// No description provided for @ptsAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'How many'**
  String get ptsAmountLabel;

  /// No description provided for @ptsWhyLabel.
  ///
  /// In en, this message translates to:
  /// **'Why (optional)'**
  String get ptsWhyLabel;

  /// No description provided for @ptsGiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Give {name} points'**
  String ptsGiveTitle(String name);

  /// No description provided for @ptsDeductTitle.
  ///
  /// In en, this message translates to:
  /// **'Deduct from {name}'**
  String ptsDeductTitle(String name);

  /// No description provided for @ptsRedeemableTitle.
  ///
  /// In en, this message translates to:
  /// **'REDEEMABLE'**
  String get ptsRedeemableTitle;

  /// No description provided for @ptsRedeemableEmpty.
  ///
  /// In en, this message translates to:
  /// **'{name} has not set any rewards.'**
  String ptsRedeemableEmpty(String name);

  /// No description provided for @ptsShort.
  ///
  /// In en, this message translates to:
  /// **'{n} more'**
  String ptsShort(int n);

  /// No description provided for @ptsRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Ask for \"{title}\"'**
  String ptsRequestTitle(String title);

  /// No description provided for @ptsRequestNote.
  ///
  /// In en, this message translates to:
  /// **'A word with it (optional)'**
  String get ptsRequestNote;

  /// No description provided for @ptsRequestSend.
  ///
  /// In en, this message translates to:
  /// **'Ask'**
  String get ptsRequestSend;

  /// No description provided for @ptsRequestsTitle.
  ///
  /// In en, this message translates to:
  /// **'REQUESTS'**
  String get ptsRequestsTitle;

  /// No description provided for @ptsRequestsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No requests.'**
  String get ptsRequestsEmpty;

  /// No description provided for @ptsStatusRequested.
  ///
  /// In en, this message translates to:
  /// **'Waiting for {name}'**
  String ptsStatusRequested(String name);

  /// No description provided for @ptsStatusApproved.
  ///
  /// In en, this message translates to:
  /// **'{name} approved'**
  String ptsStatusApproved(String name);

  /// No description provided for @ptsStatusDenied.
  ///
  /// In en, this message translates to:
  /// **'{name} said no'**
  String ptsStatusDenied(String name);

  /// No description provided for @ptsStatusFulfilled.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get ptsStatusFulfilled;

  /// No description provided for @ptsApprove.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get ptsApprove;

  /// No description provided for @ptsDeny.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get ptsDeny;

  /// No description provided for @ptsFulfill.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get ptsFulfill;

  /// No description provided for @ptsDecideNote.
  ///
  /// In en, this message translates to:
  /// **'A word (optional)'**
  String get ptsDecideNote;

  /// No description provided for @ptsDecideCost.
  ///
  /// In en, this message translates to:
  /// **'Set the cost'**
  String get ptsDecideCost;

  /// No description provided for @ptsLedgerTitle.
  ///
  /// In en, this message translates to:
  /// **'LEDGER'**
  String get ptsLedgerTitle;

  /// No description provided for @ptsLedgerEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing yet.'**
  String get ptsLedgerEmpty;

  /// No description provided for @ptsReasonTaskEarn.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get ptsReasonTaskEarn;

  /// No description provided for @ptsReasonAward.
  ///
  /// In en, this message translates to:
  /// **'{name} gave'**
  String ptsReasonAward(String name);

  /// No description provided for @ptsReasonDeduct.
  ///
  /// In en, this message translates to:
  /// **'{name} took'**
  String ptsReasonDeduct(String name);

  /// No description provided for @ptsReasonRedemption.
  ///
  /// In en, this message translates to:
  /// **'Redeemed'**
  String get ptsReasonRedemption;

  /// No description provided for @ptsReasonRefund.
  ///
  /// In en, this message translates to:
  /// **'Returned'**
  String get ptsReasonRefund;

  /// No description provided for @ptsReasonOther.
  ///
  /// In en, this message translates to:
  /// **'Movement'**
  String get ptsReasonOther;

  /// No description provided for @ptsRulesTitle.
  ///
  /// In en, this message translates to:
  /// **'WHAT PAYS'**
  String get ptsRulesTitle;

  /// No description provided for @ptsRulesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No task pays yet.'**
  String get ptsRulesEmpty;

  /// No description provided for @ptsRulesBase.
  ///
  /// In en, this message translates to:
  /// **'Everything else is a base item at 0.'**
  String get ptsRulesBase;

  /// No description provided for @ptsConsequencesTitle.
  ///
  /// In en, this message translates to:
  /// **'CONSEQUENCES'**
  String get ptsConsequencesTitle;

  /// No description provided for @ptsConsequencesEmpty.
  ///
  /// In en, this message translates to:
  /// **'None.'**
  String get ptsConsequencesEmpty;

  /// No description provided for @ptsConsequenceDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get ptsConsequenceDone;

  /// No description provided for @ptsConsequenceConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get ptsConsequenceConfirm;

  /// No description provided for @ptsConsequenceWaive.
  ///
  /// In en, this message translates to:
  /// **'Let it go'**
  String get ptsConsequenceWaive;

  /// No description provided for @ptsConsStatusIssued.
  ///
  /// In en, this message translates to:
  /// **'Not yet done'**
  String get ptsConsStatusIssued;

  /// No description provided for @ptsConsStatusDoneByS.
  ///
  /// In en, this message translates to:
  /// **'Done, waiting for {name}'**
  String ptsConsStatusDoneByS(String name);

  /// No description provided for @ptsConsStatusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'{name} confirmed'**
  String ptsConsStatusConfirmed(String name);

  /// No description provided for @ptsConsStatusWaived.
  ///
  /// In en, this message translates to:
  /// **'{name} let it go'**
  String ptsConsStatusWaived(String name);

  /// No description provided for @ptsCouldNotLoad.
  ///
  /// In en, this message translates to:
  /// **'Points could not be loaded.'**
  String get ptsCouldNotLoad;

  /// No description provided for @ptsActionFailed.
  ///
  /// In en, this message translates to:
  /// **'Not saved. Try again.'**
  String get ptsActionFailed;

  /// No description provided for @exploreTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get exploreTitle;

  /// No description provided for @exploreBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get exploreBack;

  /// No description provided for @exploreSectionPrefs.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get exploreSectionPrefs;

  /// No description provided for @exploreSectionCompare.
  ///
  /// In en, this message translates to:
  /// **'Compare'**
  String get exploreSectionCompare;

  /// No description provided for @exploreSectionCards.
  ///
  /// In en, this message translates to:
  /// **'Idea cards'**
  String get exploreSectionCards;

  /// No description provided for @exploreCouldNotLoad.
  ///
  /// In en, this message translates to:
  /// **'Could not be opened.'**
  String get exploreCouldNotLoad;

  /// No description provided for @exploreActionFailed.
  ///
  /// In en, this message translates to:
  /// **'That did not land. Try again.'**
  String get exploreActionFailed;

  /// No description provided for @explorePrefsIntro.
  ///
  /// In en, this message translates to:
  /// **'Answer any three and you can already see where you meet. Only what you both answered is shown to either of you.'**
  String get explorePrefsIntro;

  /// No description provided for @exploreAnswerWant.
  ///
  /// In en, this message translates to:
  /// **'Want'**
  String get exploreAnswerWant;

  /// No description provided for @exploreAnswerOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get exploreAnswerOk;

  /// No description provided for @exploreAnswerNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get exploreAnswerNo;

  /// No description provided for @exploreAnswerTalk.
  ///
  /// In en, this message translates to:
  /// **'Talk'**
  String get exploreAnswerTalk;

  /// No description provided for @exploreCompareNoPartner.
  ///
  /// In en, this message translates to:
  /// **'{name} has not answered yet. Yours are saved.'**
  String exploreCompareNoPartner(String name);

  /// No description provided for @exploreCompareEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing you both answered yet.'**
  String get exploreCompareEmpty;

  /// No description provided for @exploreCompareBothWant.
  ///
  /// In en, this message translates to:
  /// **'BOTH WANT'**
  String get exploreCompareBothWant;

  /// No description provided for @exploreCompareWantAndOk.
  ///
  /// In en, this message translates to:
  /// **'ONE WANTS, ONE IS OK'**
  String get exploreCompareWantAndOk;

  /// No description provided for @exploreCompareTalks.
  ///
  /// In en, this message translates to:
  /// **'SOMEONE WANTS TO TALK'**
  String get exploreCompareTalks;

  /// No description provided for @exploreCompareNotDoing.
  ///
  /// In en, this message translates to:
  /// **'NOT DOING'**
  String get exploreCompareNotDoing;

  /// No description provided for @exploreCompareNotDoingLine.
  ///
  /// In en, this message translates to:
  /// **'Marked \"no\" by one of you. Which one is nobody\'s business.'**
  String get exploreCompareNotDoingLine;

  /// No description provided for @exploreCompareAddRule.
  ///
  /// In en, this message translates to:
  /// **'Add to rules'**
  String get exploreCompareAddRule;

  /// No description provided for @exploreCompareProposeRule.
  ///
  /// In en, this message translates to:
  /// **'Propose to {name}'**
  String exploreCompareProposeRule(String name);

  /// No description provided for @exploreCardsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No cards fit right now.'**
  String get exploreCardsEmpty;

  /// No description provided for @exploreCardIntensity.
  ///
  /// In en, this message translates to:
  /// **'Intensity {n}'**
  String exploreCardIntensity(int n);

  /// No description provided for @exploreCardNeeds.
  ///
  /// In en, this message translates to:
  /// **'Needs: {needs}'**
  String exploreCardNeeds(String needs);

  /// No description provided for @exploreCardSaved.
  ///
  /// In en, this message translates to:
  /// **'saved'**
  String get exploreCardSaved;

  /// No description provided for @exploreCardTriedAgain.
  ///
  /// In en, this message translates to:
  /// **'tried · again'**
  String get exploreCardTriedAgain;

  /// No description provided for @exploreCardTriedNever.
  ///
  /// In en, this message translates to:
  /// **'tried · not again'**
  String get exploreCardTriedNever;

  /// No description provided for @exploreActAddToday.
  ///
  /// In en, this message translates to:
  /// **'Add to today'**
  String get exploreActAddToday;

  /// No description provided for @exploreActAddRule.
  ///
  /// In en, this message translates to:
  /// **'Add to rules'**
  String get exploreActAddRule;

  /// No description provided for @exploreActSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get exploreActSave;

  /// No description provided for @exploreActPropose.
  ///
  /// In en, this message translates to:
  /// **'Propose to {name}'**
  String exploreActPropose(String name);

  /// No description provided for @exploreActTriedAgain.
  ///
  /// In en, this message translates to:
  /// **'Tried it · again'**
  String get exploreActTriedAgain;

  /// No description provided for @exploreActTriedNever.
  ///
  /// In en, this message translates to:
  /// **'Not again'**
  String get exploreActTriedNever;

  /// No description provided for @exploreActDone.
  ///
  /// In en, this message translates to:
  /// **'Done.'**
  String get exploreActDone;

  /// No description provided for @exploreDrawTonight.
  ///
  /// In en, this message translates to:
  /// **'What about tonight?'**
  String get exploreDrawTonight;

  /// No description provided for @exploreDrawAgain.
  ///
  /// In en, this message translates to:
  /// **'Draw another'**
  String get exploreDrawAgain;

  /// No description provided for @exploreDrawFailed.
  ///
  /// In en, this message translates to:
  /// **'No card came. Try again.'**
  String get exploreDrawFailed;

  /// No description provided for @explorePacksTitle.
  ///
  /// In en, this message translates to:
  /// **'Starter packs'**
  String get explorePacksTitle;

  /// No description provided for @explorePacksIntro.
  ///
  /// In en, this message translates to:
  /// **'Pick one, then change every line to fit the two of you. Nothing is created until you say so.'**
  String get explorePacksIntro;

  /// No description provided for @explorePackTasks.
  ///
  /// In en, this message translates to:
  /// **'TASKS'**
  String get explorePackTasks;

  /// No description provided for @explorePackRules.
  ///
  /// In en, this message translates to:
  /// **'RULES'**
  String get explorePackRules;

  /// No description provided for @explorePackRewards.
  ///
  /// In en, this message translates to:
  /// **'REWARDS'**
  String get explorePackRewards;

  /// No description provided for @explorePackApply.
  ///
  /// In en, this message translates to:
  /// **'Use this set'**
  String get explorePackApply;

  /// No description provided for @explorePackApplied.
  ///
  /// In en, this message translates to:
  /// **'Done. It is all under Rules now.'**
  String get explorePackApplied;

  /// No description provided for @explorePackEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit this line'**
  String get explorePackEdit;

  /// No description provided for @explorePackLineLabel.
  ///
  /// In en, this message translates to:
  /// **'Line'**
  String get explorePackLineLabel;

  /// No description provided for @explorePackKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get explorePackKeep;

  /// No description provided for @explorePackCount.
  ///
  /// In en, this message translates to:
  /// **'{tasks} tasks · {rules} rules · {rewards} rewards'**
  String explorePackCount(int tasks, int rules, int rewards);

  /// No description provided for @explorePackEmptyDraft.
  ///
  /// In en, this message translates to:
  /// **'Nothing left to create.'**
  String get explorePackEmptyDraft;

  /// No description provided for @rulesStartFromPack.
  ///
  /// In en, this message translates to:
  /// **'Start from a set'**
  String get rulesStartFromPack;

  /// No description provided for @rulesExplorePrefs.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get rulesExplorePrefs;

  /// No description provided for @sTodayMeasureLabel.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get sTodayMeasureLabel;

  /// No description provided for @sTodayMeasureLabelUnit.
  ///
  /// In en, this message translates to:
  /// **'Value ({unit})'**
  String sTodayMeasureLabelUnit(String unit);

  /// No description provided for @recordSeriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Curve'**
  String get recordSeriesTitle;

  /// No description provided for @recordSeriesAction.
  ///
  /// In en, this message translates to:
  /// **'Curve'**
  String get recordSeriesAction;

  /// No description provided for @recordSeriesSection.
  ///
  /// In en, this message translates to:
  /// **'Curves'**
  String get recordSeriesSection;

  /// No description provided for @recordSeriesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No numbers in the last {days} days.'**
  String recordSeriesEmpty(int days);

  /// No description provided for @recordSeriesRange.
  ///
  /// In en, this message translates to:
  /// **'{from} – {to}'**
  String recordSeriesRange(String from, String to);

  /// No description provided for @recordSeriesLow.
  ///
  /// In en, this message translates to:
  /// **'Low {value}'**
  String recordSeriesLow(String value);

  /// No description provided for @recordSeriesHigh.
  ///
  /// In en, this message translates to:
  /// **'High {value}'**
  String recordSeriesHigh(String value);

  /// No description provided for @recordSeriesLatest.
  ///
  /// In en, this message translates to:
  /// **'{day} · {value}'**
  String recordSeriesLatest(String day, String value);

  /// No description provided for @recordSeriesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} days recorded'**
  String recordSeriesCount(int count);

  /// No description provided for @recordExport.
  ///
  /// In en, this message translates to:
  /// **'Export record'**
  String get recordExport;

  /// No description provided for @recordExportLastDays.
  ///
  /// In en, this message translates to:
  /// **'Last {days} days'**
  String recordExportLastDays(int days);

  /// No description provided for @recordExportCustom.
  ///
  /// In en, this message translates to:
  /// **'Pick dates…'**
  String get recordExportCustom;

  /// No description provided for @recordExported.
  ///
  /// In en, this message translates to:
  /// **'Exported {filename}'**
  String recordExported(String filename);

  /// No description provided for @recordExportFailed.
  ///
  /// In en, this message translates to:
  /// **'The export did not go through. Try again.'**
  String get recordExportFailed;

  /// No description provided for @rulesEditTask.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get rulesEditTask;

  /// No description provided for @rulesTaskKindLabel.
  ///
  /// In en, this message translates to:
  /// **'Kind'**
  String get rulesTaskKindLabel;

  /// No description provided for @rulesTaskKindRecurring.
  ///
  /// In en, this message translates to:
  /// **'Repeats'**
  String get rulesTaskKindRecurring;

  /// No description provided for @rulesTaskKindOneOff.
  ///
  /// In en, this message translates to:
  /// **'Once'**
  String get rulesTaskKindOneOff;

  /// No description provided for @rulesTaskKindOpen.
  ///
  /// In en, this message translates to:
  /// **'Whenever'**
  String get rulesTaskKindOpen;

  /// No description provided for @rulesTaskKindCheckin.
  ///
  /// In en, this message translates to:
  /// **'Check-in'**
  String get rulesTaskKindCheckin;

  /// No description provided for @rulesTaskKindMeasure.
  ///
  /// In en, this message translates to:
  /// **'Measure'**
  String get rulesTaskKindMeasure;

  /// No description provided for @rulesTaskDetailLabel.
  ///
  /// In en, this message translates to:
  /// **'Details (optional)'**
  String get rulesTaskDetailLabel;

  /// No description provided for @rulesTaskDetailTooLong.
  ///
  /// In en, this message translates to:
  /// **'At most 1000 characters'**
  String get rulesTaskDetailTooLong;

  /// No description provided for @rulesTaskTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Say what first'**
  String get rulesTaskTitleRequired;

  /// No description provided for @rulesScheduleLabel.
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get rulesScheduleLabel;

  /// No description provided for @rulesWeekdaysRequired.
  ///
  /// In en, this message translates to:
  /// **'Pick at least one day'**
  String get rulesWeekdaysRequired;

  /// No description provided for @rulesEveryNFrom.
  ///
  /// In en, this message translates to:
  /// **'from {date}'**
  String rulesEveryNFrom(String date);

  /// No description provided for @rulesEveryNInvalid.
  ///
  /// In en, this message translates to:
  /// **'2 to 365'**
  String get rulesEveryNInvalid;

  /// No description provided for @rulesTimesPerDayLabel.
  ///
  /// In en, this message translates to:
  /// **'Times a day'**
  String get rulesTimesPerDayLabel;

  /// No description provided for @rulesDueTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Due ({zone})'**
  String rulesDueTimeLabel(String zone);

  /// No description provided for @rulesDueEndOfDay.
  ///
  /// In en, this message translates to:
  /// **'End of day'**
  String get rulesDueEndOfDay;

  /// No description provided for @rulesDueAtLabel.
  ///
  /// In en, this message translates to:
  /// **'Which day, what time'**
  String get rulesDueAtLabel;

  /// No description provided for @rulesDuePickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick a day'**
  String get rulesDuePickDate;

  /// No description provided for @rulesDueAtRequired.
  ///
  /// In en, this message translates to:
  /// **'A one-off needs a day'**
  String get rulesDueAtRequired;

  /// No description provided for @rulesProofLabel.
  ///
  /// In en, this message translates to:
  /// **'How it is handed in'**
  String get rulesProofLabel;

  /// No description provided for @rulesProofCheckinOnly.
  ///
  /// In en, this message translates to:
  /// **'A check-in is always words'**
  String get rulesProofCheckinOnly;

  /// No description provided for @rulesPointsRange.
  ///
  /// In en, this message translates to:
  /// **'0 to 1000'**
  String get rulesPointsRange;

  /// No description provided for @rulesPointsHint.
  ///
  /// In en, this message translates to:
  /// **'Basics earn 0; they only cost when missed'**
  String get rulesPointsHint;

  /// No description provided for @rulesUnitLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit (kg, ml…)'**
  String get rulesUnitLabel;

  /// No description provided for @rulesUnitRequired.
  ///
  /// In en, this message translates to:
  /// **'A measure needs a unit'**
  String get rulesUnitRequired;

  /// No description provided for @dTodayQuickMore.
  ///
  /// In en, this message translates to:
  /// **'More…'**
  String get dTodayQuickMore;

  /// No description provided for @joinAlreadyInHeadline.
  ///
  /// In en, this message translates to:
  /// **'You are\nalready in.'**
  String get joinAlreadyInHeadline;

  /// No description provided for @joinOpenApp.
  ///
  /// In en, this message translates to:
  /// **'Go to Today'**
  String get joinOpenApp;

  /// No description provided for @joinUsedGuidance.
  ///
  /// In en, this message translates to:
  /// **'If you are the one who used it, just go in.'**
  String get joinUsedGuidance;

  /// No description provided for @inviteAlreadyLiveReplace.
  ///
  /// In en, this message translates to:
  /// **'Withdraw it and make a new one'**
  String get inviteAlreadyLiveReplace;

  /// No description provided for @inviteAlreadyLiveReplaceNote.
  ///
  /// In en, this message translates to:
  /// **'Once withdrawn, the old link stops working. The new one is shown only this once.'**
  String get inviteAlreadyLiveReplaceNote;

  /// No description provided for @todayPausedLine.
  ///
  /// In en, this message translates to:
  /// **'Paused. Nothing is delivered or disposed while it lasts.'**
  String get todayPausedLine;

  /// No description provided for @todayPausedOpen.
  ///
  /// In en, this message translates to:
  /// **'Have a look'**
  String get todayPausedOpen;

  /// No description provided for @todayWaitingPartner.
  ///
  /// In en, this message translates to:
  /// **'Waiting for them to join.'**
  String get todayWaitingPartner;

  /// No description provided for @todayWaitingPartnerBody.
  ///
  /// In en, this message translates to:
  /// **'Nothing is asked here until they are in.'**
  String get todayWaitingPartnerBody;

  /// No description provided for @todayInviteLink.
  ///
  /// In en, this message translates to:
  /// **'Send the invite link'**
  String get todayInviteLink;

  /// No description provided for @sTodayEmptyRules.
  ///
  /// In en, this message translates to:
  /// **'See the rules'**
  String get sTodayEmptyRules;

  /// No description provided for @todayWaitingPartnerBodyD.
  ///
  /// In en, this message translates to:
  /// **'Until they are in, you can start putting rules and tasks in place.'**
  String get todayWaitingPartnerBodyD;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get notificationsTitle;

  /// No description provided for @notificationsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet.'**
  String get notificationsEmpty;

  /// No description provided for @notificationsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Messages could not be read.'**
  String get notificationsLoadFailed;

  /// No description provided for @notificationsReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Companion'**
  String get notificationsReminderTitle;

  /// No description provided for @notificationsReminderDue.
  ///
  /// In en, this message translates to:
  /// **'{title} — it\'s time.'**
  String notificationsReminderDue(String title);

  /// No description provided for @notificationsReminderDayEnd.
  ///
  /// In en, this message translates to:
  /// **'{count} still unsaid before the day ends.'**
  String notificationsReminderDayEnd(int count);

  /// No description provided for @settingsDigestSection.
  ///
  /// In en, this message translates to:
  /// **'Deliveries'**
  String get settingsDigestSection;

  /// No description provided for @settingsDigestOff.
  ///
  /// In en, this message translates to:
  /// **'Each one, at once'**
  String get settingsDigestOff;

  /// No description provided for @settingsDigestOffSupport.
  ///
  /// In en, this message translates to:
  /// **'You hear about every delivery as it lands.'**
  String get settingsDigestOffSupport;

  /// No description provided for @settingsDigestEvery.
  ///
  /// In en, this message translates to:
  /// **'Folded every {hours} hours'**
  String settingsDigestEvery(int hours);

  /// No description provided for @settingsMutedTypesSection.
  ///
  /// In en, this message translates to:
  /// **'What rings'**
  String get settingsMutedTypesSection;

  /// No description provided for @settingsMutedTypesSupport.
  ///
  /// In en, this message translates to:
  /// **'What you turn off still lands in Messages; it just stays quiet.'**
  String get settingsMutedTypesSupport;

  /// No description provided for @settingsTypeDelivered.
  ///
  /// In en, this message translates to:
  /// **'A delivery'**
  String get settingsTypeDelivered;

  /// No description provided for @settingsTypeFlagged.
  ///
  /// In en, this message translates to:
  /// **'Can\'t / new time / talk'**
  String get settingsTypeFlagged;

  /// No description provided for @settingsTypeDisposition.
  ///
  /// In en, this message translates to:
  /// **'Their answer'**
  String get settingsTypeDisposition;

  /// No description provided for @settingsTypeComment.
  ///
  /// In en, this message translates to:
  /// **'A comment'**
  String get settingsTypeComment;

  /// No description provided for @settingsTypeAward.
  ///
  /// In en, this message translates to:
  /// **'Points added'**
  String get settingsTypeAward;

  /// No description provided for @settingsTypeRedemption.
  ///
  /// In en, this message translates to:
  /// **'A redemption request'**
  String get settingsTypeRedemption;

  /// No description provided for @settingsTypeDNote.
  ///
  /// In en, this message translates to:
  /// **'Note reminder'**
  String get settingsTypeDNote;
}

class _LDelegate extends LocalizationsDelegate<L> {
  const _LDelegate();

  @override
  Future<L> load(Locale locale) {
    return SynchronousFuture<L>(lookupL(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_LDelegate old) => false;
}

L lookupL(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return LEn();
    case 'zh':
      return LZh();
  }

  throw FlutterError(
    'L.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
