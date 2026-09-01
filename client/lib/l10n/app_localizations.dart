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

  /// No description provided for @navDynamic.
  ///
  /// In en, this message translates to:
  /// **'Dynamic'**
  String get navDynamic;

  /// No description provided for @navExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get navExplore;

  /// No description provided for @navUs.
  ///
  /// In en, this message translates to:
  /// **'Us'**
  String get navUs;

  /// No description provided for @actionComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get actionComplete;

  /// No description provided for @actionDiscuss.
  ///
  /// In en, this message translates to:
  /// **'Discuss'**
  String get actionDiscuss;

  /// No description provided for @actionNewTime.
  ///
  /// In en, this message translates to:
  /// **'New time'**
  String get actionNewTime;

  /// No description provided for @actionCantDo.
  ///
  /// In en, this message translates to:
  /// **'Can\'t do'**
  String get actionCantDo;

  /// Withdrawing an adjustment you asked for yourself.
  ///
  /// In en, this message translates to:
  /// **'Take it back'**
  String get actionTakeItBack;

  /// No description provided for @activationContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get activationContinue;

  /// No description provided for @activationStepOf.
  ///
  /// In en, this message translates to:
  /// **'{step} of 4'**
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

  /// No description provided for @exploreTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get exploreTitle;

  /// No description provided for @exploreContextIdeas.
  ///
  /// In en, this message translates to:
  /// **'Ideas'**
  String get exploreContextIdeas;

  /// No description provided for @exploreContextReading.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get exploreContextReading;

  /// No description provided for @exploreContextConfirming.
  ///
  /// In en, this message translates to:
  /// **'Confirming context'**
  String get exploreContextConfirming;

  /// No description provided for @exploreContextNotLoaded.
  ///
  /// In en, this message translates to:
  /// **'Not loaded'**
  String get exploreContextNotLoaded;

  /// No description provided for @exploreContextNothingYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing yet'**
  String get exploreContextNothingYet;

  /// No description provided for @exploreSessionLost.
  ///
  /// In en, this message translates to:
  /// **'Your private session needs to be restored.'**
  String get exploreSessionLost;

  /// No description provided for @exploreSignInAgain.
  ///
  /// In en, this message translates to:
  /// **'Sign in again'**
  String get exploreSignInAgain;

  /// No description provided for @exploreLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'The library could not be loaded. Nothing in your day depends on it.'**
  String get exploreLoadFailed;

  /// No description provided for @exploreTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get exploreTryAgain;

  /// No description provided for @exploreEmpty.
  ///
  /// In en, this message translates to:
  /// **'There is nothing in the library yet. Today holds everything that is waiting for you.'**
  String get exploreEmpty;

  /// No description provided for @exploreIntro.
  ///
  /// In en, this message translates to:
  /// **'Things other people have found worth asking for. Nothing here is a suggestion about you.'**
  String get exploreIntro;

  /// No description provided for @exploreAskForThis.
  ///
  /// In en, this message translates to:
  /// **'Ask for this'**
  String get exploreAskForThis;

  /// No description provided for @exploreKindExpectation.
  ///
  /// In en, this message translates to:
  /// **'SOMETHING TO ASK FOR'**
  String get exploreKindExpectation;

  /// No description provided for @exploreKindRitual.
  ///
  /// In en, this message translates to:
  /// **'SOMETHING TO REPEAT'**
  String get exploreKindRitual;

  /// No description provided for @exploreKindCheckIn.
  ///
  /// In en, this message translates to:
  /// **'SOMETHING TO SAY'**
  String get exploreKindCheckIn;

  /// No description provided for @exploreKindOther.
  ///
  /// In en, this message translates to:
  /// **'AN IDEA'**
  String get exploreKindOther;

  /// No description provided for @responseTypeAcknowledge.
  ///
  /// In en, this message translates to:
  /// **'Acknowledge'**
  String get responseTypeAcknowledge;

  /// No description provided for @responseTypePraise.
  ///
  /// In en, this message translates to:
  /// **'Praise'**
  String get responseTypePraise;

  /// No description provided for @responseTypeComment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get responseTypeComment;

  /// No description provided for @responseTypeReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get responseTypeReview;

  /// No description provided for @responseComposerTitle.
  ///
  /// In en, this message translates to:
  /// **'Respond to {name}'**
  String responseComposerTitle(String name);

  /// No description provided for @responseYourWords.
  ///
  /// In en, this message translates to:
  /// **'YOUR WORDS'**
  String get responseYourWords;

  /// No description provided for @responseWordsHint.
  ///
  /// In en, this message translates to:
  /// **'Say what you noticed…'**
  String get responseWordsHint;

  /// Shown beside the field when a Comment or Review was sent empty. {type} is the lowercased response type name.
  ///
  /// In en, this message translates to:
  /// **'A {type} needs your words.'**
  String responseNeedsWords(String type);

  /// No description provided for @responseSendTo.
  ///
  /// In en, this message translates to:
  /// **'Send to {name}'**
  String responseSendTo(String name);

  /// No description provided for @responseSending.
  ///
  /// In en, this message translates to:
  /// **'Sending'**
  String get responseSending;

  /// No description provided for @responseNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get responseNotNow;

  /// No description provided for @responseAttention.
  ///
  /// In en, this message translates to:
  /// **'Attention'**
  String get responseAttention;

  /// No description provided for @responsePartnerPresent.
  ///
  /// In en, this message translates to:
  /// **'{name} is present'**
  String responsePartnerPresent(String name);

  /// No description provided for @responseCompletedAtBy.
  ///
  /// In en, this message translates to:
  /// **'{name} completed\nthis at {time}.'**
  String responseCompletedAtBy(String name, String time);

  /// No description provided for @responseAlreadyAnsweredTitle.
  ///
  /// In en, this message translates to:
  /// **'This has already\nbeen answered.'**
  String get responseAlreadyAnsweredTitle;

  /// No description provided for @responseAlreadyAnsweredDetail.
  ///
  /// In en, this message translates to:
  /// **'{name} has your response.'**
  String responseAlreadyAnsweredDetail(String name);

  /// No description provided for @responseClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get responseClose;

  /// No description provided for @responseErrorOffline.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Connect to the internet, then try again.'**
  String get responseErrorOffline;

  /// No description provided for @responseErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t send that just now. Try again.'**
  String get responseErrorGeneric;

  /// No description provided for @responseAttentionSummaryLabel.
  ///
  /// In en, this message translates to:
  /// **'WHAT NEEDS YOUR ANSWER'**
  String get responseAttentionSummaryLabel;

  /// No description provided for @responseAttentionMoments.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 moment} other{{count} moments}}'**
  String responseAttentionMoments(int count);

  /// No description provided for @responseAttentionAwaiting.
  ///
  /// In en, this message translates to:
  /// **'{count} awaiting your answer'**
  String responseAttentionAwaiting(int count);

  /// No description provided for @responseAttentionToRevisit.
  ///
  /// In en, this message translates to:
  /// **'{count} to revisit'**
  String responseAttentionToRevisit(int count);

  /// Section heading, rendered in upper case. {name} is the partner's display name, already upper-cased by the caller in English.
  ///
  /// In en, this message translates to:
  /// **'{name} IS WAITING'**
  String responseAttentionSectionWaiting(String name);

  /// No description provided for @responseAttentionSectionCompletions.
  ///
  /// In en, this message translates to:
  /// **'COMPLETIONS TO ANSWER'**
  String get responseAttentionSectionCompletions;

  /// No description provided for @responseAttentionSectionLookBack.
  ///
  /// In en, this message translates to:
  /// **'LOOK BACK TOGETHER'**
  String get responseAttentionSectionLookBack;

  /// No description provided for @responseAttentionRespondTo.
  ///
  /// In en, this message translates to:
  /// **'RESPOND TO {name}'**
  String responseAttentionRespondTo(String name);

  /// No description provided for @responseAttentionEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing is waiting\non you.'**
  String get responseAttentionEmptyTitle;

  /// No description provided for @responseAttentionEmptyDetail.
  ///
  /// In en, this message translates to:
  /// **'You\'ll find anything that needs\nyour answer here.'**
  String get responseAttentionEmptyDetail;

  /// No description provided for @responseStateAskedToDiscuss.
  ///
  /// In en, this message translates to:
  /// **'asked to discuss'**
  String get responseStateAskedToDiscuss;

  /// No description provided for @responseStateAskedForNewTime.
  ///
  /// In en, this message translates to:
  /// **'asked for a new time'**
  String get responseStateAskedForNewTime;

  /// No description provided for @responseStateCantDoThis.
  ///
  /// In en, this message translates to:
  /// **'said they can\'t do this'**
  String get responseStateCantDoThis;

  /// No description provided for @responseStateCompleted.
  ///
  /// In en, this message translates to:
  /// **'completed'**
  String get responseStateCompleted;

  /// No description provided for @responseStateStillOpen.
  ///
  /// In en, this message translates to:
  /// **'is still open'**
  String get responseStateStillOpen;

  /// No description provided for @responseStateWaiting.
  ///
  /// In en, this message translates to:
  /// **'is waiting'**
  String get responseStateWaiting;

  /// No description provided for @responseAgoMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String responseAgoMinutes(int count);

  /// No description provided for @responseAgoHours.
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String responseAgoHours(int count);

  /// No description provided for @responseAgoYesterday.
  ///
  /// In en, this message translates to:
  /// **'yesterday'**
  String get responseAgoYesterday;

  /// No description provided for @responseAgoDays.
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String responseAgoDays(int count);

  /// No description provided for @responseWaitingYourPartner.
  ///
  /// In en, this message translates to:
  /// **'your partner'**
  String get responseWaitingYourPartner;

  /// No description provided for @responseWaitingHeaderAnswered.
  ///
  /// In en, this message translates to:
  /// **'Acknowledgement'**
  String get responseWaitingHeaderAnswered;

  /// No description provided for @responseWaitingPresenceWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting for {name}'**
  String responseWaitingPresenceWaiting(String name);

  /// No description provided for @responseWaitingRecorded.
  ///
  /// In en, this message translates to:
  /// **'Your service\nis recorded.'**
  String get responseWaitingRecorded;

  /// No description provided for @responseWaitingCompletedAt.
  ///
  /// In en, this message translates to:
  /// **'COMPLETED AT {time}'**
  String responseWaitingCompletedAt(String time);

  /// No description provided for @responseWaitingNodeCompleted.
  ///
  /// In en, this message translates to:
  /// **'COMPLETED'**
  String get responseWaitingNodeCompleted;

  /// Progress label under the second node. {name} is the partner's display name, upper-cased by the caller in English.
  ///
  /// In en, this message translates to:
  /// **'WAITING FOR {name}'**
  String responseWaitingNodeWaitingFor(String name);

  /// No description provided for @responseWaitingNotYetAnswered.
  ///
  /// In en, this message translates to:
  /// **'Your part is complete.\n{name} has not responded yet.'**
  String responseWaitingNotYetAnswered(String name);

  /// No description provided for @responseWaitingReturnToToday.
  ///
  /// In en, this message translates to:
  /// **'Return to Today'**
  String get responseWaitingReturnToToday;

  /// No description provided for @responseWaitingCloseRitual.
  ///
  /// In en, this message translates to:
  /// **'Close ritual'**
  String get responseWaitingCloseRitual;

  /// No description provided for @responseAnsweredTitle.
  ///
  /// In en, this message translates to:
  /// **'You are seen.'**
  String get responseAnsweredTitle;

  /// No description provided for @responseAnsweredWordlessNamed.
  ///
  /// In en, this message translates to:
  /// **'{name} acknowledged this.'**
  String responseAnsweredWordlessNamed(String name);

  /// No description provided for @responseAnsweredWordlessAnonymous.
  ///
  /// In en, this message translates to:
  /// **'This was acknowledged.'**
  String get responseAnsweredWordlessAnonymous;

  /// No description provided for @responseReceivedAt.
  ///
  /// In en, this message translates to:
  /// **'RECEIVED AT {time}'**
  String responseReceivedAt(String time);

  /// No description provided for @responsePrivateNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'PRIVATE NOTE · ONLY YOU'**
  String get responsePrivateNoteLabel;

  /// No description provided for @dynamicTitle.
  ///
  /// In en, this message translates to:
  /// **'Dynamic'**
  String get dynamicTitle;

  /// No description provided for @dynamicYou.
  ///
  /// In en, this message translates to:
  /// **'YOU'**
  String get dynamicYou;

  /// No description provided for @dynamicNoOneYet.
  ///
  /// In en, this message translates to:
  /// **'NO ONE YET'**
  String get dynamicNoOneYet;

  /// No description provided for @dynamicCurrentStructure.
  ///
  /// In en, this message translates to:
  /// **'CURRENT STRUCTURE'**
  String get dynamicCurrentStructure;

  /// No description provided for @dynamicCurrentRhythm.
  ///
  /// In en, this message translates to:
  /// **'CURRENT RHYTHM'**
  String get dynamicCurrentRhythm;

  /// No description provided for @dynamicCurrentRhythms.
  ///
  /// In en, this message translates to:
  /// **'CURRENT RHYTHMS'**
  String get dynamicCurrentRhythms;

  /// No description provided for @dynamicAskOneThing.
  ///
  /// In en, this message translates to:
  /// **'Ask one thing'**
  String get dynamicAskOneThing;

  /// No description provided for @dynamicThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get dynamicThisWeek;

  /// No description provided for @dynamicPauseThis.
  ///
  /// In en, this message translates to:
  /// **'Pause this Dynamic'**
  String get dynamicPauseThis;

  /// No description provided for @dynamicComeBack.
  ///
  /// In en, this message translates to:
  /// **'Come back'**
  String get dynamicComeBack;

  /// No description provided for @dynamicPaused.
  ///
  /// In en, this message translates to:
  /// **'PAUSED'**
  String get dynamicPaused;

  /// No description provided for @dynamicPausedNothingExpected.
  ///
  /// In en, this message translates to:
  /// **'Nothing is expected of either of you while this is paused.'**
  String get dynamicPausedNothingExpected;

  /// No description provided for @dynamicEitherMayPause.
  ///
  /// In en, this message translates to:
  /// **'Either of you may pause. Nothing is lost while paused.'**
  String get dynamicEitherMayPause;

  /// No description provided for @dynamicNothingWaitingAfterPause.
  ///
  /// In en, this message translates to:
  /// **'Nothing from the paused days is waiting for you.'**
  String get dynamicNothingWaitingAfterPause;

  /// No description provided for @outcomeCloser.
  ///
  /// In en, this message translates to:
  /// **'Closeness-led'**
  String get outcomeCloser;

  /// No description provided for @outcomeStructure.
  ///
  /// In en, this message translates to:
  /// **'Structure-led'**
  String get outcomeStructure;

  /// No description provided for @outcomeService.
  ///
  /// In en, this message translates to:
  /// **'Service-led'**
  String get outcomeService;

  /// No description provided for @outcomeAccountability.
  ///
  /// In en, this message translates to:
  /// **'Accountability-led'**
  String get outcomeAccountability;

  /// No description provided for @outcomeExplore.
  ///
  /// In en, this message translates to:
  /// **'Exploration-led'**
  String get outcomeExplore;

  /// No description provided for @levelLight.
  ///
  /// In en, this message translates to:
  /// **'lightly held'**
  String get levelLight;

  /// No description provided for @levelSteady.
  ///
  /// In en, this message translates to:
  /// **'mutually held'**
  String get levelSteady;

  /// No description provided for @levelDefined.
  ///
  /// In en, this message translates to:
  /// **'clearly defined'**
  String get levelDefined;

  /// No description provided for @structureLine.
  ///
  /// In en, this message translates to:
  /// **'{outcome} · {level}'**
  String structureLine(Object level, Object outcome);

  /// No description provided for @rolePresetDominant.
  ///
  /// In en, this message translates to:
  /// **'Dominant'**
  String get rolePresetDominant;

  /// No description provided for @rolePresetSubmissive.
  ///
  /// In en, this message translates to:
  /// **'Submissive'**
  String get rolePresetSubmissive;

  /// No description provided for @rolePresetSwitch.
  ///
  /// In en, this message translates to:
  /// **'Switch'**
  String get rolePresetSwitch;

  /// No description provided for @rolePresetCustom.
  ///
  /// In en, this message translates to:
  /// **'Their own words'**
  String get rolePresetCustom;

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
  /// **'We couldn\'t reach the server. Try again.'**
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
  /// **'Enter a valid email address.'**
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
  /// **'You choose your own role.'**
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
  /// **'You\'ve joined. Open the app to continue.'**
  String get joinAlreadyJoined;

  /// No description provided for @joinBoundaryIntentionLabel.
  ///
  /// In en, this message translates to:
  /// **'SHARED INTENTION'**
  String get joinBoundaryIntentionLabel;

  /// No description provided for @joinBoundaryIntention.
  ///
  /// In en, this message translates to:
  /// **'More structure and closeness.'**
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

  /// No description provided for @askTitle.
  ///
  /// In en, this message translates to:
  /// **'Ask one thing'**
  String get askTitle;

  /// No description provided for @askCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get askCancel;

  /// No description provided for @askForWhom.
  ///
  /// In en, this message translates to:
  /// **'For {name}'**
  String askForWhom(Object name);

  /// No description provided for @askYourPartnerFallback.
  ///
  /// In en, this message translates to:
  /// **'your partner'**
  String get askYourPartnerFallback;

  /// No description provided for @askWhatStep.
  ///
  /// In en, this message translates to:
  /// **'WHAT YOU ARE ASKING'**
  String get askWhatStep;

  /// No description provided for @askWhatHint.
  ///
  /// In en, this message translates to:
  /// **'Prepare the room before 8:00 PM'**
  String get askWhatHint;

  /// No description provided for @askWhatMissing.
  ///
  /// In en, this message translates to:
  /// **'Say what you are asking for.'**
  String get askWhatMissing;

  /// No description provided for @askWhenStep.
  ///
  /// In en, this message translates to:
  /// **'WHEN'**
  String get askWhenStep;

  /// No description provided for @askWhyStep.
  ///
  /// In en, this message translates to:
  /// **'WHY IT MATTERS (OPTIONAL)'**
  String get askWhyStep;

  /// No description provided for @askWhyHint.
  ///
  /// In en, this message translates to:
  /// **'Create a calm space for our evening ritual'**
  String get askWhyHint;

  /// No description provided for @askSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get askSend;

  /// No description provided for @askSending.
  ///
  /// In en, this message translates to:
  /// **'Sending…'**
  String get askSending;

  /// No description provided for @askAgencyNote.
  ///
  /// In en, this message translates to:
  /// **'{name} can complete this, ask to discuss it, ask for another time, or say they cannot — always.'**
  String askAgencyNote(Object name);

  /// No description provided for @askNoOneYet.
  ///
  /// In en, this message translates to:
  /// **'There is no one to ask yet.'**
  String get askNoOneYet;

  /// No description provided for @askNoOneYetBody.
  ///
  /// In en, this message translates to:
  /// **'Once your invitation is accepted, you can ask them for things here.'**
  String get askNoOneYetBody;

  /// No description provided for @askFailed.
  ///
  /// In en, this message translates to:
  /// **'That did not reach the server. Nothing was sent — try again.'**
  String get askFailed;

  /// No description provided for @askCouldNotOpen.
  ///
  /// In en, this message translates to:
  /// **'This could not be opened. Nothing was sent.'**
  String get askCouldNotOpen;

  /// No description provided for @whenAnytime.
  ///
  /// In en, this message translates to:
  /// **'Anytime'**
  String get whenAnytime;

  /// No description provided for @whenClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get whenClear;

  /// No description provided for @whenToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get whenToday;

  /// No description provided for @detailDue.
  ///
  /// In en, this message translates to:
  /// **'DUE'**
  String get detailDue;

  /// No description provided for @detailSetBy.
  ///
  /// In en, this message translates to:
  /// **'Set by {name}'**
  String detailSetBy(Object name);

  /// No description provided for @detailIntention.
  ///
  /// In en, this message translates to:
  /// **'INTENTION'**
  String get detailIntention;

  /// No description provided for @detailPrivateNote.
  ///
  /// In en, this message translates to:
  /// **'PRIVATE NOTE · ONLY YOU'**
  String get detailPrivateNote;

  /// No description provided for @detailCompletionNote.
  ///
  /// In en, this message translates to:
  /// **'COMPLETION NOTE (OPTIONAL)'**
  String get detailCompletionNote;

  /// No description provided for @detailCompletionHint.
  ///
  /// In en, this message translates to:
  /// **'What did you attend to?'**
  String get detailCompletionHint;

  /// No description provided for @detailMarkComplete.
  ///
  /// In en, this message translates to:
  /// **'Mark complete'**
  String get detailMarkComplete;

  /// No description provided for @detailCompleting.
  ///
  /// In en, this message translates to:
  /// **'Completing…'**
  String get detailCompleting;

  /// No description provided for @detailPartnerWillSee.
  ///
  /// In en, this message translates to:
  /// **'{name} will see this.'**
  String detailPartnerWillSee(Object name);

  /// No description provided for @detailTakeItBack.
  ///
  /// In en, this message translates to:
  /// **'Never mind, take it back'**
  String get detailTakeItBack;

  /// No description provided for @detailTakingItBack.
  ///
  /// In en, this message translates to:
  /// **'Taking it back…'**
  String get detailTakingItBack;

  /// No description provided for @detailTakeItBackNote.
  ///
  /// In en, this message translates to:
  /// **'It goes back to how it was. Nothing is recorded as agreed or refused.'**
  String get detailTakeItBackNote;

  /// No description provided for @detailTheirWords.
  ///
  /// In en, this message translates to:
  /// **'THEIR WORDS'**
  String get detailTheirWords;

  /// No description provided for @detailPersonWrote.
  ///
  /// In en, this message translates to:
  /// **'{name} WROTE'**
  String detailPersonWrote(Object name);

  /// No description provided for @detailConfirming.
  ///
  /// In en, this message translates to:
  /// **'Confirming this with the server.'**
  String get detailConfirming;

  /// No description provided for @detailSessionEnded.
  ///
  /// In en, this message translates to:
  /// **'Your private session needs to be restored. Nothing about this is shown until it is.'**
  String get detailSessionEnded;

  /// No description provided for @detailCouldNotLoad.
  ///
  /// In en, this message translates to:
  /// **'This could not be loaded. Nothing was changed.'**
  String get detailCouldNotLoad;

  /// No description provided for @nothingWaitingAck.
  ///
  /// In en, this message translates to:
  /// **'Done, and waiting for a human response.'**
  String get nothingWaitingAck;

  /// No description provided for @nothingAcknowledged.
  ///
  /// In en, this message translates to:
  /// **'Answered. Nothing more is needed here.'**
  String get nothingAcknowledged;

  /// No description provided for @nothingDiscussing.
  ///
  /// In en, this message translates to:
  /// **'You asked to talk about this.'**
  String get nothingDiscussing;

  /// No description provided for @nothingRescheduling.
  ///
  /// In en, this message translates to:
  /// **'You asked for another time.'**
  String get nothingRescheduling;

  /// No description provided for @nothingExcusing.
  ///
  /// In en, this message translates to:
  /// **'You said you could not do this.'**
  String get nothingExcusing;

  /// No description provided for @nothingCancelled.
  ///
  /// In en, this message translates to:
  /// **'This was cancelled.'**
  String get nothingCancelled;

  /// No description provided for @nothingDefault.
  ///
  /// In en, this message translates to:
  /// **'Nothing is waiting on you here.'**
  String get nothingDefault;

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

  /// No description provided for @recoveryReading.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get recoveryReading;

  /// No description provided for @recoverySessionEnded.
  ///
  /// In en, this message translates to:
  /// **'PRIVATE SESSION ENDED'**
  String get recoverySessionEnded;

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

  /// No description provided for @recoveryNoProtectedContent.
  ///
  /// In en, this message translates to:
  /// **'No protected content remains on this screen.'**
  String get recoveryNoProtectedContent;

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

  /// No description provided for @todayResolving.
  ///
  /// In en, this message translates to:
  /// **'RESOLVING TODAY'**
  String get todayResolving;

  /// No description provided for @todayConfirmingPrivate.
  ///
  /// In en, this message translates to:
  /// **'Confirming your private context…'**
  String get todayConfirmingPrivate;

  /// No description provided for @todayPrivateByDefault.
  ///
  /// In en, this message translates to:
  /// **'PRIVATE BY DEFAULT'**
  String get todayPrivateByDefault;

  /// No description provided for @todayPrivateByDefaultBody.
  ///
  /// In en, this message translates to:
  /// **'Partner details stay hidden until membership and the current relationship day are confirmed.'**
  String get todayPrivateByDefaultBody;

  /// No description provided for @todayCouldNotLoad.
  ///
  /// In en, this message translates to:
  /// **'Today could not be loaded. Nothing was lost.'**
  String get todayCouldNotLoad;

  /// No description provided for @todayOfflineReadOnly.
  ///
  /// In en, this message translates to:
  /// **'Read-only until the server reconnects.'**
  String get todayOfflineReadOnly;

  /// No description provided for @todayActionsPaused.
  ///
  /// In en, this message translates to:
  /// **'Actions are paused offline'**
  String get todayActionsPaused;

  /// No description provided for @todayActionsReturn.
  ///
  /// In en, this message translates to:
  /// **'Complete, Discuss, New Time and Can\'t Do will return after current truth is confirmed.'**
  String get todayActionsReturn;

  /// No description provided for @todayCachedNeverNew.
  ///
  /// In en, this message translates to:
  /// **'Cached content is never treated as a new state.'**
  String get todayCachedNeverNew;

  /// No description provided for @todayHiddenDetails.
  ///
  /// In en, this message translates to:
  /// **'Partner and Dynamic details have been hidden.\nSign in again to confirm current access.'**
  String get todayHiddenDetails;

  /// No description provided for @todayOffline.
  ///
  /// In en, this message translates to:
  /// **'OFFLINE'**
  String get todayOffline;

  /// No description provided for @dynamicConfirmingStructure.
  ///
  /// In en, this message translates to:
  /// **'Nothing about the two of you is shown until the server confirms it.'**
  String get dynamicConfirmingStructure;

  /// No description provided for @dynamicCouldNotConfirm.
  ///
  /// In en, this message translates to:
  /// **'The current structure could not be confirmed.'**
  String get dynamicCouldNotConfirm;

  /// No description provided for @dynamicPauseUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Pause and Resume need the server, so they are unavailable until it reconnects. Whatever was already agreed still stands.'**
  String get dynamicPauseUnavailable;

  /// No description provided for @dynamicCouldNotLoad.
  ///
  /// In en, this message translates to:
  /// **'The Dynamic could not be loaded. Nothing was changed.'**
  String get dynamicCouldNotLoad;

  /// No description provided for @dynamicHiddenDetails.
  ///
  /// In en, this message translates to:
  /// **'Partner, roles and current structure have been hidden.\nSign in again to confirm current access.'**
  String get dynamicHiddenDetails;

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

  /// No description provided for @weeklyTitle.
  ///
  /// In en, this message translates to:
  /// **'THIS WEEK'**
  String get weeklyTitle;

  /// No description provided for @weeklyClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get weeklyClose;

  /// No description provided for @weeklyLoading.
  ///
  /// In en, this message translates to:
  /// **'Gathering what actually happened this week.'**
  String get weeklyLoading;

  /// No description provided for @weeklyLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'This week could not be loaded. Nothing was changed.'**
  String get weeklyLoadFailed;

  /// No description provided for @weeklyTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get weeklyTryAgain;

  /// No description provided for @weeklyTooEarlyHeadline.
  ///
  /// In en, this message translates to:
  /// **'There is not a week to look back on yet.'**
  String get weeklyTooEarlyHeadline;

  /// No description provided for @weeklyTooEarlySupport.
  ///
  /// In en, this message translates to:
  /// **'This comes back once you have some days behind you. Nothing is missing in the meantime.'**
  String get weeklyTooEarlySupport;

  /// No description provided for @weeklyHeadlineQuiet.
  ///
  /// In en, this message translates to:
  /// **'A quiet week.'**
  String get weeklyHeadlineQuiet;

  /// No description provided for @weeklyHeadlineOneDay.
  ///
  /// In en, this message translates to:
  /// **'One day had something on it.'**
  String get weeklyHeadlineOneDay;

  /// No description provided for @weeklyHeadlineDays.
  ///
  /// In en, this message translates to:
  /// **'{count} days had something on them.'**
  String weeklyHeadlineDays(Object count);

  /// No description provided for @weeklyAnsweredOne.
  ///
  /// In en, this message translates to:
  /// **'One thing was answered by a person'**
  String get weeklyAnsweredOne;

  /// No description provided for @weeklyAnsweredMany.
  ///
  /// In en, this message translates to:
  /// **'{count} things were answered by a person'**
  String weeklyAnsweredMany(Object count);

  /// No description provided for @weeklyAdjustedOne.
  ///
  /// In en, this message translates to:
  /// **'one adjustment was worked out together'**
  String get weeklyAdjustedOne;

  /// No description provided for @weeklyAdjustedMany.
  ///
  /// In en, this message translates to:
  /// **'{count} adjustments were worked out together'**
  String weeklyAdjustedMany(Object count);

  /// No description provided for @weeklySupportJoin.
  ///
  /// In en, this message translates to:
  /// **'{first}, and {second}.'**
  String weeklySupportJoin(Object first, Object second);

  /// No description provided for @weeklySupportSingle.
  ///
  /// In en, this message translates to:
  /// **'{only}.'**
  String weeklySupportSingle(Object only);

  /// No description provided for @weeklySupportNothing.
  ///
  /// In en, this message translates to:
  /// **'Nothing was completed or answered. That is a fact about the week, not about either of you.'**
  String get weeklySupportNothing;

  /// No description provided for @weeklyAnsweredSection.
  ///
  /// In en, this message translates to:
  /// **'WHAT WAS ANSWERED'**
  String get weeklyAnsweredSection;

  /// No description provided for @weeklyMomentAttribution.
  ///
  /// In en, this message translates to:
  /// **'— {name}'**
  String weeklyMomentAttribution(Object name);

  /// No description provided for @weeklyNextWeekSection.
  ///
  /// In en, this message translates to:
  /// **'NEXT WEEK'**
  String get weeklyNextWeekSection;

  /// No description provided for @weeklyKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep the current rhythm'**
  String get weeklyKeep;

  /// No description provided for @weeklyPauseInstead.
  ///
  /// In en, this message translates to:
  /// **'Pause instead'**
  String get weeklyPauseInstead;

  /// No description provided for @weeklyKeepSupport.
  ///
  /// In en, this message translates to:
  /// **'Keeping is not a commitment. Either of you may pause at any time, from Dynamic.'**
  String get weeklyKeepSupport;

  /// No description provided for @checkInTitle.
  ///
  /// In en, this message translates to:
  /// **'Check in'**
  String get checkInTitle;

  /// No description provided for @checkInCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get checkInCancel;

  /// No description provided for @checkInHeadline.
  ///
  /// In en, this message translates to:
  /// **'How are you, right now?'**
  String get checkInHeadline;

  /// No description provided for @checkInSupport.
  ///
  /// In en, this message translates to:
  /// **'Answer as much or as little as you want.'**
  String get checkInSupport;

  /// No description provided for @checkInMoodSection.
  ///
  /// In en, this message translates to:
  /// **'MOOD'**
  String get checkInMoodSection;

  /// No description provided for @checkInMoodGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get checkInMoodGood;

  /// No description provided for @checkInMoodSteady.
  ///
  /// In en, this message translates to:
  /// **'Steady'**
  String get checkInMoodSteady;

  /// No description provided for @checkInMoodLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get checkInMoodLow;

  /// No description provided for @checkInMoodTender.
  ///
  /// In en, this message translates to:
  /// **'Tender'**
  String get checkInMoodTender;

  /// No description provided for @checkInMoodRaw.
  ///
  /// In en, this message translates to:
  /// **'Raw'**
  String get checkInMoodRaw;

  /// No description provided for @checkInEnergySection.
  ///
  /// In en, this message translates to:
  /// **'ENERGY'**
  String get checkInEnergySection;

  /// No description provided for @checkInEnergyHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get checkInEnergyHigh;

  /// No description provided for @checkInEnergySteady.
  ///
  /// In en, this message translates to:
  /// **'Steady'**
  String get checkInEnergySteady;

  /// No description provided for @checkInEnergyLow.
  ///
  /// In en, this message translates to:
  /// **'Running low'**
  String get checkInEnergyLow;

  /// No description provided for @checkInNeedSection.
  ///
  /// In en, this message translates to:
  /// **'WHAT WOULD HELP'**
  String get checkInNeedSection;

  /// No description provided for @checkInNeedNothing.
  ///
  /// In en, this message translates to:
  /// **'Nothing'**
  String get checkInNeedNothing;

  /// No description provided for @checkInNeedCloseness.
  ///
  /// In en, this message translates to:
  /// **'Closeness'**
  String get checkInNeedCloseness;

  /// No description provided for @checkInNeedSpace.
  ///
  /// In en, this message translates to:
  /// **'Space'**
  String get checkInNeedSpace;

  /// No description provided for @checkInNeedStructure.
  ///
  /// In en, this message translates to:
  /// **'Structure'**
  String get checkInNeedStructure;

  /// No description provided for @checkInNeedToBeAsked.
  ///
  /// In en, this message translates to:
  /// **'To be asked'**
  String get checkInNeedToBeAsked;

  /// No description provided for @checkInNoteSection.
  ///
  /// In en, this message translates to:
  /// **'ANYTHING ELSE (OPTIONAL)'**
  String get checkInNoteSection;

  /// No description provided for @checkInNoteHint.
  ///
  /// In en, this message translates to:
  /// **'In your own words'**
  String get checkInNoteHint;

  /// No description provided for @checkInVisibilitySection.
  ///
  /// In en, this message translates to:
  /// **'WHO CAN SEE THIS'**
  String get checkInVisibilitySection;

  /// No description provided for @checkInVisibilityPrivate.
  ///
  /// In en, this message translates to:
  /// **'Only me'**
  String get checkInVisibilityPrivate;

  /// No description provided for @checkInVisibilityShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get checkInVisibilityShare;

  /// No description provided for @checkInVisibilityShareWith.
  ///
  /// In en, this message translates to:
  /// **'Share with {name}'**
  String checkInVisibilityShareWith(Object name);

  /// No description provided for @checkInVisibilityPrivateSupport.
  ///
  /// In en, this message translates to:
  /// **'Kept to yourself. Nothing about it reaches anyone else.'**
  String get checkInVisibilityPrivateSupport;

  /// No description provided for @checkInVisibilityNoPartnerSupport.
  ///
  /// In en, this message translates to:
  /// **'There is no one to share with yet.'**
  String get checkInVisibilityNoPartnerSupport;

  /// No description provided for @checkInVisibilitySharedSupport.
  ///
  /// In en, this message translates to:
  /// **'{name} will be able to read this. It cannot be unshared afterwards.'**
  String checkInVisibilitySharedSupport(Object name);

  /// No description provided for @checkInSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get checkInSave;

  /// No description provided for @checkInSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get checkInSaving;

  /// No description provided for @checkInSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'That did not reach the server. Nothing was saved — try again.'**
  String get checkInSaveFailed;

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

  /// No description provided for @usConfirmingContext.
  ///
  /// In en, this message translates to:
  /// **'Confirming context'**
  String get usConfirmingContext;

  /// No description provided for @usNotConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Not confirmed'**
  String get usNotConfirmed;

  /// No description provided for @usSoFar.
  ///
  /// In en, this message translates to:
  /// **'So far'**
  String get usSoFar;

  /// No description provided for @usSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get usSettings;

  /// No description provided for @usTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get usTryAgain;

  /// No description provided for @usCouldNotBeLoaded.
  ///
  /// In en, this message translates to:
  /// **'This could not be loaded. Nothing is missing from your history.'**
  String get usCouldNotBeLoaded;

  /// A count of days where both people did something. Stated as a record, never as a rate, a streak or a target — '4 of 7' would turn a record into a report card.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nothing has landed on the same day yet.} =1{One day you both showed up.} other{{count} days you both showed up.}}'**
  String usConnectedDays(int count);

  /// No description provided for @usConnectedDaysSupport.
  ///
  /// In en, this message translates to:
  /// **'Days you both did something. Nothing the app did on its own is counted here.'**
  String get usConnectedDaysSupport;

  /// No description provided for @usThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get usThisWeek;

  /// No description provided for @usNothingYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing has happened here yet. It fills up as you use it — there is nothing to catch up on.'**
  String get usNothingYet;

  /// No description provided for @usRecently.
  ///
  /// In en, this message translates to:
  /// **'RECENTLY'**
  String get usRecently;

  /// Stands in for an actor whose display name the server did not give.
  ///
  /// In en, this message translates to:
  /// **'Someone'**
  String get usSomeone;

  /// No description provided for @usMomentCompletion.
  ///
  /// In en, this message translates to:
  /// **'{name} did something that was asked'**
  String usMomentCompletion(String name);

  /// No description provided for @usMomentAcknowledgement.
  ///
  /// In en, this message translates to:
  /// **'{name} answered'**
  String usMomentAcknowledgement(String name);

  /// No description provided for @usMomentAdjustmentRequested.
  ///
  /// In en, this message translates to:
  /// **'{name} asked to change something'**
  String usMomentAdjustmentRequested(String name);

  /// No description provided for @usMomentAdjustmentResolved.
  ///
  /// In en, this message translates to:
  /// **'You worked something out'**
  String get usMomentAdjustmentResolved;

  /// No description provided for @usMomentCheckin.
  ///
  /// In en, this message translates to:
  /// **'{name} shared how they were'**
  String usMomentCheckin(String name);

  /// No description provided for @usMomentMemberJoined.
  ///
  /// In en, this message translates to:
  /// **'{name} joined'**
  String usMomentMemberJoined(String name);

  /// An event type this build does not recognise. Never show the raw server enum.
  ///
  /// In en, this message translates to:
  /// **'Something happened'**
  String get usMomentUnknown;

  /// No description provided for @usPrivateSessionEnded.
  ///
  /// In en, this message translates to:
  /// **'PRIVATE SESSION ENDED'**
  String get usPrivateSessionEnded;

  /// No description provided for @usSessionNeedsRestoring.
  ///
  /// In en, this message translates to:
  /// **'Your private session\nneeds to be restored.'**
  String get usSessionNeedsRestoring;

  /// No description provided for @usHistoryHidden.
  ///
  /// In en, this message translates to:
  /// **'Your history together has been hidden.\nSign in again to confirm current access.'**
  String get usHistoryHidden;

  /// No description provided for @usSignInAgain.
  ///
  /// In en, this message translates to:
  /// **'Sign in again'**
  String get usSignInAgain;

  /// No description provided for @usNoProtectedContent.
  ///
  /// In en, this message translates to:
  /// **'No protected content remains on this screen.'**
  String get usNoProtectedContent;

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

  /// No description provided for @todayLaterOptional.
  ///
  /// In en, this message translates to:
  /// **'LATER / OPTIONAL'**
  String get todayLaterOptional;

  /// No description provided for @todayDayEndsAt.
  ///
  /// In en, this message translates to:
  /// **'Relationship day ends at {clock}'**
  String todayDayEndsAt(Object clock);

  /// No description provided for @todayFrom.
  ///
  /// In en, this message translates to:
  /// **'From {name}'**
  String todayFrom(Object name);

  /// No description provided for @todayNothingExpected.
  ///
  /// In en, this message translates to:
  /// **'Nothing is expected of you today.'**
  String get todayNothingExpected;

  /// No description provided for @todayCheckInOffer.
  ///
  /// In en, this message translates to:
  /// **'A check-in is here if you want one.'**
  String get todayCheckInOffer;

  /// No description provided for @todayCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Check in'**
  String get todayCheckIn;

  /// No description provided for @stateOnToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get stateOnToday;

  /// No description provided for @stateWaitingForReply.
  ///
  /// In en, this message translates to:
  /// **'Waiting for a reply'**
  String get stateWaitingForReply;

  /// No description provided for @stateNeedsReview.
  ///
  /// In en, this message translates to:
  /// **'Needs review'**
  String get stateNeedsReview;

  /// No description provided for @stateBeingDiscussed.
  ///
  /// In en, this message translates to:
  /// **'Being discussed'**
  String get stateBeingDiscussed;

  /// No description provided for @stateNewTimeRequested.
  ///
  /// In en, this message translates to:
  /// **'New time requested'**
  String get stateNewTimeRequested;

  /// No description provided for @stateCantDoSent.
  ///
  /// In en, this message translates to:
  /// **'Can\'t do — sent'**
  String get stateCantDoSent;

  /// No description provided for @stateScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get stateScheduled;

  /// No description provided for @kindRitual.
  ///
  /// In en, this message translates to:
  /// **'RITUAL'**
  String get kindRitual;

  /// No description provided for @kindExpectation.
  ///
  /// In en, this message translates to:
  /// **'EXPECTATION'**
  String get kindExpectation;

  /// No description provided for @kindOnToday.
  ///
  /// In en, this message translates to:
  /// **'ON TODAY'**
  String get kindOnToday;

  /// No description provided for @ageJustNow.
  ///
  /// In en, this message translates to:
  /// **'JUST NOW'**
  String get ageJustNow;

  /// No description provided for @ageMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count} MIN AGO'**
  String ageMinutes(Object count);

  /// No description provided for @ageHours.
  ///
  /// In en, this message translates to:
  /// **'{count} HR AGO'**
  String ageHours(Object count);

  /// No description provided for @ageDays.
  ///
  /// In en, this message translates to:
  /// **'{count} DAY AGO'**
  String ageDays(Object count);

  /// No description provided for @actionSending.
  ///
  /// In en, this message translates to:
  /// **'Sending'**
  String get actionSending;

  /// No description provided for @yourPartner.
  ///
  /// In en, this message translates to:
  /// **'YOUR PARTNER'**
  String get yourPartner;

  /// No description provided for @todayResponseHeading.
  ///
  /// In en, this message translates to:
  /// **'{name} RESPONDED · {age}'**
  String todayResponseHeading(Object age, Object name);

  /// No description provided for @todayPriorityHeading.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{ONE THING MATTERS} =2{TWO THINGS MATTER} other{{count} THINGS MATTER}}'**
  String todayPriorityHeading(int count);

  /// No description provided for @todayPriorityHeadingNone.
  ///
  /// In en, this message translates to:
  /// **'NOTHING MATTERS TODAY'**
  String get todayPriorityHeadingNone;

  /// No description provided for @todayPrimaryEyebrow.
  ///
  /// In en, this message translates to:
  /// **'01 · NOW · {kind}'**
  String todayPrimaryEyebrow(String kind);

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

  /// No description provided for @dynamicPartnerFallback.
  ///
  /// In en, this message translates to:
  /// **'PARTNER'**
  String get dynamicPartnerFallback;

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
