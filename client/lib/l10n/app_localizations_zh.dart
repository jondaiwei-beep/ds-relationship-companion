// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class LZh extends L {
  LZh([String locale = 'zh']) : super(locale);

  @override
  String get navToday => '今天';

  @override
  String get navRules => '规矩';

  @override
  String get navRecord => '记录';

  @override
  String get activationContinue => '继续';

  @override
  String activationStepOf(int step) {
    return '第 $step 步，共 5 步';
  }

  @override
  String get activationChooseOneToContinue => '先选一个，再继续。';

  @override
  String get activationGoalEyebrow => '从心意开始';

  @override
  String get activationGoalQuestion => '你现在\n想多一些什么？';

  @override
  String get activationGoalSupport => '选一种你希望这段关系\n带来的感觉。以后随时可以改。';

  @override
  String get activationGoalFootnote => '这只是给你们的起点定个调子，不是给你划界限。';

  @override
  String get activationGoalCloser => '更亲近';

  @override
  String get activationGoalStructure => '更有相处方式';

  @override
  String get activationGoalService => '付出与用心';

  @override
  String get activationGoalAccountability => '彼此有交代';

  @override
  String get activationGoalExplore => '一起探索';

  @override
  String get activationRoleEyebrow => '一起开始';

  @override
  String get activationRoleQuestion => '谁和你\n一起开始？';

  @override
  String get activationRoleSupport => '可以先自己开始，也可以把这个空间对伴侣打开。';

  @override
  String get activationRoleFootnote => '这只是起点，不是界限。\n以后随时可以改。';

  @override
  String get activationRoleWithPartner => '和伴侣一起';

  @override
  String get activationRoleForMyself => '先自己';

  @override
  String get activationRoleSectionLabel => '你此刻怎么形容自己';

  @override
  String get activationRoleDominant => '偏主导';

  @override
  String get activationRoleSubmissive => '偏顺从';

  @override
  String get activationRoleSwitch => '两边都有';

  @override
  String get activationRoleCustom => '我自己说';

  @override
  String get activationRoleDecline => '先不说这个';

  @override
  String get activationStructureEyebrow => '你们的相处方式';

  @override
  String get activationStructureQuestion => '多少约定\n让你觉得舒服？';

  @override
  String get activationStructureSupport => '选一个开始的节奏。这里的任何选择\n都不会让谁少一分说话的份。';

  @override
  String get activationStructureFootnote => '以后你们可以一起慢慢调。';

  @override
  String get activationStructureLight => '轻一点';

  @override
  String get activationStructureLightDetail => '节奏松一些，留很多余地。';

  @override
  String get activationStructureSteady => '稳一点';

  @override
  String get activationStructureSteadyDetail => '心意说得清楚，也留得下商量的余地。';

  @override
  String get activationStructureDefined => '明确一点';

  @override
  String get activationStructureDefinedDetail => '一个你们都点头的、清楚的形状。';

  @override
  String get activationContextLabel => '你们的情况';

  @override
  String get activationContextLongDistance => '异地';

  @override
  String get activationContextTogether => '在一起';

  @override
  String get activationContextTimezone => '时区';

  @override
  String activationContextTimezoneDetected(String zone) {
    return '$zone · 自动读到的';
  }

  @override
  String get activationRhythmEyebrow => '你们开始时的节奏';

  @override
  String get activationRhythmQuestion => '先从一件\n小事开始。';

  @override
  String get activationRhythmSupport => '觉得合适的就留下，不合适的换掉。';

  @override
  String get activationRhythmFootnoteSolo => '先轻一点开始，边走边调。';

  @override
  String get activationRhythmFootnoteCouple => '先轻一点开始，之后一起调。';

  @override
  String get activationRhythmStart => '就从这个节奏开始';

  @override
  String get activationRhythmKindRitual => '日常';

  @override
  String get activationRhythmKindExpectation => '心意';

  @override
  String get activationRhythmKindCheckIn => '说说今天';

  @override
  String get activationRhythmEveningTitle => '晚上说说今天';

  @override
  String get activationRhythmEveningDetail => '一天结束前，停一下，陪对方一会儿。';

  @override
  String get activationRhythmSentenceTitle => '一句真心话';

  @override
  String get activationRhythmSentenceDetailSolo => '说出你今天需要什么。';

  @override
  String get activationRhythmSentenceDetailCouple => '把你今天需要什么告诉对方。';

  @override
  String get activationRhythmCheckInTitle => '每天说说今天';

  @override
  String get activationRhythmCheckInDetail => '心情 · 状态 · 需要';

  @override
  String get activationErrorChooseOutcome => '先选一个你想多一些的方向。';

  @override
  String get activationErrorTimezoneUnreadable => '读不到这台设备的时区。再试一次。';

  @override
  String get activationErrorOffline => '你现在没联网。连上网络，然后再试一次。';

  @override
  String get activationErrorInvalidRequest => '刚才没弄好。再试一次。';

  @override
  String get activationErrorGeneric => '现在还弄不好。再试一次。';

  @override
  String get activationErrorSessionEnded => '你的登录已经过期了。重新登录，就能把这一步做完。';

  @override
  String get activationTimezoneTitle => '我们读不到\n你所在的时区。';

  @override
  String get activationTimezoneWhyFirst => '你的一天总得按某个地方来算。随便猜一个，会在以后悄悄把它挪走。';

  @override
  String get activationTimezoneWhyRetried => '还是读不到。你自己选一个也一样好用——你的一天就按你选的这个算。';

  @override
  String get activationTimezoneTryAgain => '再试一次';

  @override
  String get activationTimezoneTryReadingAgain => '再读一次看看';

  @override
  String get activationTimezoneChooseMyself => '我自己选';

  @override
  String get activationTimezonePickerTitle => '你的一天按哪里算';

  @override
  String get activationZoneChina => '中国';

  @override
  String get activationZoneJapan => '日本';

  @override
  String get activationZoneSingapore => '新加坡';

  @override
  String get activationZoneIndia => '印度';

  @override
  String get activationZoneUnitedKingdom => '英国';

  @override
  String get activationZoneCentralEurope => '中欧';

  @override
  String get activationZoneUsEastern => '美国东部';

  @override
  String get activationZoneUsCentral => '美国中部';

  @override
  String get activationZoneUsMountain => '美国山地';

  @override
  String get activationZoneUsPacific => '美国西部';

  @override
  String get activationZoneEasternAustralia => '澳大利亚东部';

  @override
  String get entranceWordmark => 'Companion';

  @override
  String get entranceHeadline => '一个只属于你的\n安静角落。';

  @override
  String get entranceTagline => '私密。从容。属于你。';

  @override
  String get entranceContinue => '继续';

  @override
  String get entranceContinueBusy => '正在打开';

  @override
  String get entranceHaveAccount => '我已经有账号了';

  @override
  String get entranceNoticeChecking => '正在看看你的登录状态…';

  @override
  String get entranceNoticeSessionEnded => '登录状态到期了。想进来的时候再进来。';

  @override
  String get entranceNoticeOffline => '现在没有网络。连上网就可以继续。';

  @override
  String get entranceNoticeUnreachable => '连不上。再试一次。';

  @override
  String get entranceTrustFooter =>
      '仅限 18 岁以上使用。使用本服务即适用我们的服务条款。\n我们如何处理数据，写在隐私政策里。\n账号默认是私密的。';

  @override
  String get entranceCreateEyebrow => '创建账号';

  @override
  String get entranceCreateHeadline => '安静地开始。';

  @override
  String get entranceFieldEmail => '邮箱';

  @override
  String get entranceFieldEmailHint => 'you@example.com';

  @override
  String get entranceFieldCreatePassword => '设置密码';

  @override
  String entranceFieldPasswordHint(int min, int max) {
    return '$min–$max 个字符';
  }

  @override
  String get entranceAgeConfirm => '我确认自己已满 18 岁。';

  @override
  String get entranceCreateAccount => '创建账号';

  @override
  String get entranceCreateAccountBusy => '正在创建';

  @override
  String get entranceLegalConsent => '创建账号即表示你同意服务条款，\n并已知悉隐私政策。';

  @override
  String get entranceAlreadyHaveAccount => '已经有账号了？去登录';

  @override
  String get entranceCreateUncertainFallback =>
      '我们没能确定账号有没有创建成功。先试试登录，再考虑重新创建。';

  @override
  String get entranceSignInEyebrow => '欢迎回来';

  @override
  String get entranceSignInHeadline => '回到你的空间。';

  @override
  String get entranceFieldPassword => '密码';

  @override
  String get entranceSignIn => '登录';

  @override
  String get entranceSignInBusy => '正在登录';

  @override
  String get entranceSendLink => '发送登录链接';

  @override
  String get entranceSendLinkBusy => '正在发送';

  @override
  String get entranceLinkModeExplainer => '我们会给你填的这个邮箱\n发一条一次性的登录链接。';

  @override
  String get entranceUsePasswordInstead => '改用密码登录';

  @override
  String get entranceUseEmailLink => '改用邮箱链接登录';

  @override
  String get entranceCreateAccountLink => '创建一个账号';

  @override
  String get entranceSignInNoticeAuthorizationLost => '先登录一下，就可以继续。';

  @override
  String get entranceSignInNoticeOffline => '现在没有网络。连上网再试一次。';

  @override
  String get entranceLinkSentEyebrow => '去看看邮箱';

  @override
  String get entranceLinkSentHeadline => '链接已经在路上了。';

  @override
  String get entranceLinkSentBody =>
      '如果这个邮箱可以用来登录，\n我们就会发一条链接过去。看看收件箱，\n也看看垃圾邮件。';

  @override
  String get entranceResendLink => '重新发一条';

  @override
  String get entranceUseDifferentEmail => '换一个邮箱';

  @override
  String get entranceCallbackEyebrowBusy => '正在带你进来';

  @override
  String get entranceCallbackEyebrowDone => '登录';

  @override
  String get entranceCallbackHeadlineBusy => '稍等一下。';

  @override
  String get entranceCallbackHeadlineDone => '这条链接已经用完了。';

  @override
  String get entranceCallbackIncompleteLink => '这条链接不完整。重新要一条吧。';

  @override
  String get entranceCallbackUnexpectedLink => '这次登录没能完成。重新要一条链接吧。';

  @override
  String get entranceRequestNewLink => '重新要一条链接';

  @override
  String get entranceErrorAgeNotConfirmed => '确认你已满 18 岁，才能创建账号。';

  @override
  String get entranceErrorOffline => '连不上服务器。检查一下网络再试；如果这个网络访问部分网站不稳定，换个网络试试。';

  @override
  String get entranceErrorGeneric => '出了点问题。再试一次。';

  @override
  String get entranceErrorUnexpected => '发生了意料之外的情况。再试一次。';

  @override
  String get entranceErrorLinkWrongDevice => '在你当初索取这条链接的那台设备上打开它，或者重新要一条。';

  @override
  String get entranceErrorLinkExpired => '这条链接已经不能用了。重新要一条吧。';

  @override
  String get entranceErrorSignInUncertain => '我们没能确定这次登录的结果。再试一次。';

  @override
  String get entranceErrorLinkSignInUncertain => '我们没能确定这次登录的结果。再点一次链接试试。';

  @override
  String get entranceErrorSignInGeneric => '现在没能让你登录进来。再试一次。';

  @override
  String get entranceErrorInvalidCredentials =>
      '用这些信息没能登录进来。看看邮箱和密码，或者改用邮箱链接登录。';

  @override
  String get entranceErrorAccountNotActive => '现在没办法让你登录。试试邮箱链接登录，或者联系我们。';

  @override
  String get entranceErrorRegisterUncertain =>
      '我们没能确定账号有没有创建成功。先试试登录，或者要一条邮箱登录链接，再考虑重新创建。';

  @override
  String get entranceErrorRegisterGeneric => '现在没能创建这个账号。再试一次。';

  @override
  String get entranceErrorEmailInvalid => '这个邮箱看起来不对。';

  @override
  String get entranceErrorPasswordMissing => '填一下你的密码。';

  @override
  String get entranceErrorCheckDetails => '看看填的内容，再试一次。';

  @override
  String entranceErrorPasswordTooShort(int min) {
    return '至少要 $min 个字符。';
  }

  @override
  String entranceErrorPasswordTooLong(int max) {
    return '最多 $max 个字符。';
  }

  @override
  String get inviteTitle => '私密邀请';

  @override
  String get inviteStatusChecking => '查看中';

  @override
  String get inviteStatusPending => '等待中';

  @override
  String get invitePreparing => '正在准备一条私密链接…';

  @override
  String get invitePreparingNote => '在你把它发出去之前，什么都不会送出。';

  @override
  String get inviteReadyHeadline => '一个私密的空间，\n可以分享出去了。';

  @override
  String get inviteWaitingForThem => '等对方进来';

  @override
  String get inviteNothingBeginsYet => '要你们两个人都愿意，才会开始。';

  @override
  String get inviteLinkLabel => '私密链接 / 邀请码';

  @override
  String get inviteCopyLink => '复制邀请链接';

  @override
  String get inviteCopyCodeOnly => '只复制邀请码';

  @override
  String get inviteRevoke => '收回这条邀请';

  @override
  String get inviteCopyLinkTooltip => '复制链接';

  @override
  String get inviteCopied => '已复制';

  @override
  String get inviteExpired => '这条链接过期了。';

  @override
  String get inviteExpiresWithinHour => '一小时内过期';

  @override
  String inviteExpiresInHours(int hours) {
    return '$hours 小时后过期';
  }

  @override
  String inviteExpiresInDays(int days) {
    return '$days 天后过期';
  }

  @override
  String get inviteAlreadyLiveHeadline => '已经有一条邀请\n在等着了。';

  @override
  String get inviteAlreadyLiveDetail => '同一时间只能有一条链接是活的，而链接只在生成的那一刻显示一次。';

  @override
  String get inviteAlreadyLiveGuidance => '先在你们的关系里收回原来那条，才能做一条新的。';

  @override
  String get inviteBackToDynamic => '回到你们的关系';

  @override
  String get inviteClosedHeadline => '这条邀请\n已经关上了。';

  @override
  String get inviteCreateFailedHeadline => '没能做出\n这条私密链接。';

  @override
  String get inviteClosedDetail => '原来那条链接已经打不开你们的关系了。没有人通过它进来过。';

  @override
  String get inviteCreateNew => '重新做一条邀请';

  @override
  String get inviteCreateNewNote => '重新做一条邀请，会生成一条新的私密链接。';

  @override
  String get inviteErrorOffline => '现在没有网络。连上网，再试一次。';

  @override
  String get inviteErrorCreateFailed => '现在没能做出这条链接。再试一次。';

  @override
  String get inviteErrorRevokeFailed => '现在没能收回这条链接。再试一次。';

  @override
  String get inviteErrorJoinRefused => '这条邀请已经不能用了。找对方再要一条。';

  @override
  String get inviteErrorJoinFailed => '这件事刚才没能完成。再试一次。';

  @override
  String get joinWordmark => 'COMPANION';

  @override
  String get joinResolving => '正在看看这条邀请…';

  @override
  String get joinResolvingNote => '没确认之前，什么都不会显示。';

  @override
  String get joinUnresolvedHeadline => '我们没能查到\n这条邀请。';

  @override
  String get joinUnresolvedDetail => '我们没能确定它现在的状态。\n也没有替你加入任何东西。';

  @override
  String get joinTryAgain => '再试一次';

  @override
  String get joinUnresolvedPrivacyNote => '这条链接还在。再试一次是安全的。';

  @override
  String get joinSomeone => '有人';

  @override
  String get joinInvitedYou => '邀请你开始\n一段私密的关系。';

  @override
  String get joinYouChooseYourRole => '邀请你的人已经定好了你们各自的位置，进去就看得到。';

  @override
  String get joinNotConsentToExpectations => '加入，不等于答应了以后的任何心意。';

  @override
  String get joinReviewAndJoin => '看一看，然后加入';

  @override
  String get joinBusy => '正在加入';

  @override
  String get joinNotNow => '现在先不';

  @override
  String get joinPrivacyNote => '你随时可以暂停，也随时可以离开这段关系。';

  @override
  String get joinAlreadyJoined => '这条邀请已经把你带进来了。';

  @override
  String get joinBoundaryIntentionLabel => '你们要开始的';

  @override
  String get joinBoundaryIntention => '一个定规矩，一个交付；处置和记录，都在这里。';

  @override
  String get joinBoundarySharedLabel => '你们一起看得到';

  @override
  String get joinBoundarySharedItems => '最初的日常 ·\n回应 ·\n商量好的改动';

  @override
  String get joinBoundaryPrivateLabel => '只属于你';

  @override
  String get joinBoundaryPrivateItems => '私人笔记 ·\n个人设置 ·\n你随时可以离开';

  @override
  String get joinUsedHeadline => '这条邀请\n已经被用过了。';

  @override
  String get joinExpiredHeadline => '这条邀请\n已经过期了。';

  @override
  String get joinUnavailableHeadline => '这条邀请\n已经不在了。';

  @override
  String get joinClosedPrivacyDetail => '出于隐私，这里不显示\n关系的任何细节。';

  @override
  String get joinUnavailableDetail => '这里不显示这条邀请的任何细节。';

  @override
  String get joinNotJoinedAnything => '你没有加入任何东西。';

  @override
  String get joinAskForNewLink => '找邀请你的那个人，\n请他重新做一条私密链接。';

  @override
  String get joinAskSharer => '如果你还需要一条邀请，\n找分享这条链接给你的人要。';

  @override
  String get joinReturnToEntrance => '回到私密入口';

  @override
  String get joinClosedPrivacyNote => '这条链接没法用来加入任何东西。';

  @override
  String get inviteLifecyclePending => '等待中';

  @override
  String get inviteLifecycleAccepted => '已加入';

  @override
  String get inviteLifecycleExpired => '已过期';

  @override
  String get inviteLifecycleRevoked => '已收回';

  @override
  String get recoveryConfirmingContext => '正在确认';

  @override
  String get recoveryNotConfirmed => '没能确认';

  @override
  String get recoveryOffline => '离线';

  @override
  String get recoverySessionRestore => '需要重新登录\n才能继续。';

  @override
  String get recoverySignInAgain => '重新登录';

  @override
  String get recoveryTryAgain => '再试一次';

  @override
  String get recoveryTryToReconnect => '尝试重新连接';

  @override
  String get todayPrivateByDefault => '默认私密';

  @override
  String get todayPrivateByDefaultBody => '确认是你、也确认今天是哪一天之前，先什么都不显示。';

  @override
  String get todayCouldNotLoad => '今天没能打开。什么都没丢。';

  @override
  String get todayActionsPaused => '没有网络，先交付不了。';

  @override
  String get todayActionsReturn => '连上之后，交付和说明都会回来。';

  @override
  String get todayHiddenDetails => '和 TA、和你们有关的，先都收起来了。\n重新登录就回来。';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsClose => '关闭';

  @override
  String get settingsLoading => '正在读你的设置。';

  @override
  String get settingsLoadFailed => '没能读到你的通知设置。';

  @override
  String get settingsSaveFailed => '没能送到服务器，什么都没有改。';

  @override
  String get settingsNotificationContentSection => '通知里可以写什么';

  @override
  String get settingsPreviewNeutralLabel => '不提你们之间的事';

  @override
  String get settingsPreviewNeutralSupport => '锁屏上只会显示这个 app 有事找你。默认是这样。';

  @override
  String get settingsPreviewRichLabel => '显示具体内容';

  @override
  String get settingsPreviewRichSupport => '标题和名字会出现在锁屏上，拿到你手机的人都能看见。';

  @override
  String get settingsQuietHoursSection => '安静时段';

  @override
  String get settingsQuietHoursOffLabel => '不设';

  @override
  String get settingsQuietHoursOffSupport => '通知什么时候来就什么时候到。';

  @override
  String get settingsQuietHoursPresetLabel => '晚上 10:00 — 早上 7:00';

  @override
  String get settingsQuietHoursPresetSupport =>
      '这段时间里到的都会等着，之后合成一条给你，不会一条条补上来。';

  @override
  String get settingsSharedDaySection => '你们共用的一天';

  @override
  String settingsDayBoundaryExplain(Object time) {
    return '你们的一天在这个时区的 $time 结束，不看你手机在哪个时区。你出门在外这一天也不会跟着挪，夏令时也不会把它推走。';
  }

  @override
  String get settingsPairingSection => '你们两个';

  @override
  String get settingsLeaveOrBlock => '离开或拉黑';

  @override
  String get settingsLeaveNeedsNoAgreement => '离开从来不需要对方同意。';

  @override
  String get settingsDeviceSection => '这台设备';

  @override
  String get settingsSignOut => '退出登录';

  @override
  String get settingsSignOutSupport => '退出登录只是结束这台设备上的这次登录。你们的关系不受影响。';

  @override
  String get settingsLeaveHeadline => '结束这段';

  @override
  String get settingsLeaveIntro => '这两样都会为你们两个人结束这段关系。在你点下去之前，什么都不会发生。';

  @override
  String get settingsLeaveAction => '离开';

  @override
  String get settingsLeaveActionSupport => '你不再参与。不需要谁点头。';

  @override
  String get settingsBlockAction => '拉黑';

  @override
  String get settingsBlockActionSupportNoPartner => '现在还没有人可以拉黑。';

  @override
  String get settingsBlockActionSupport => '你离开，而且对方之后不能再在这里找到你。';

  @override
  String get settingsLeaveConfirmTitle => '离开这段关系';

  @override
  String get settingsLeaveFactEndsForBoth => '这段关系对你们两个人都结束。';

  @override
  String get settingsLeaveFactNothingAskedAgain => '这里不会再有事情找你们两个中的任何一个。';

  @override
  String get settingsLeaveFactNoAgreementNeeded => '不会去问对方同不同意，对方也拦不住。';

  @override
  String get settingsLeaveFactCannotUndo => '在 app 里没法撤回。';

  @override
  String get settingsLeaveBusy => '正在离开…';

  @override
  String get settingsBlockConfirmTitle => '拉黑';

  @override
  String settingsBlockConfirmTitleNamed(Object name) {
    return '拉黑 $name';
  }

  @override
  String get settingsBlockPartnerFallbackName => '对方';

  @override
  String get settingsBlockFactEndsForBoth => '这段关系对你们两个人都结束。';

  @override
  String get settingsBlockFactNoContact => '对方之后不能再在这里找到你。';

  @override
  String get settingsBlockFactNoHistory => '之后你们两个都看不到共同的记录了。';

  @override
  String get settingsBlockFactNotTold => '不会告诉对方是谁做的。';

  @override
  String get settingsBlockFactCannotUndo => '在 app 里没法撤回。';

  @override
  String get settingsBlockBusy => '正在拉黑…';

  @override
  String get settingsGoBack => '先不了';

  @override
  String get settingsNoOneToBlock => '这里没有人可以拉黑。';

  @override
  String get settingsLeaveFailed => '没能送到服务器，什么都没有改。';

  @override
  String get shellOpeningYourSpace => '正在打开你们的空间…';

  @override
  String get shellSignInToContinue => '登录后继续。';

  @override
  String get shellCouldNotOpenYourSpace => '打不开\n你们的空间。';

  @override
  String get shellSessionEndedNothingLost => '这次登录结束了。什么都没丢。';

  @override
  String get shellCouldNotReachYourSpace => '这会儿连不上你们的空间。';

  @override
  String get shellSignIn => '登录';

  @override
  String get shellTryAgain => '再试一次';

  @override
  String shellButtonWorking(String label) {
    return '$label，正在进行';
  }

  @override
  String get shellShow => '显示';

  @override
  String get shellHide => '隐藏';

  @override
  String get shellShowPassword => '显示密码';

  @override
  String get shellHidePassword => '隐藏密码';

  @override
  String get todayTitle => '今天';

  @override
  String get todayPrivate => '私密';

  @override
  String todayPresent(Object name) {
    return '$name 在';
  }

  @override
  String todayDayEndsAt(Object clock) {
    return '你们的一天在 $clock 结束';
  }

  @override
  String get settingsLanguageSection => '语言';

  @override
  String get settingsLanguageFollowDevice => '跟随手机设置';

  @override
  String get settingsLanguageFollowDeviceSupport => '手机语言变了，这里也跟着变。';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageChinese => '中文';

  @override
  String get settingsLanguageNote =>
      '这个 app 用的词本身就是它的一部分意思。某个词读起来别扭的话，可以换另一种语言看看。';

  @override
  String get pauseConfirming => '正在确认现在是不是暂停中。';

  @override
  String get pauseCouldNotConfirm => '没能确认现在是不是暂停中。什么都没有改动。';

  @override
  String get pauseTitle => '暂停这段关系';

  @override
  String get pauseFactNothingExpected => '你们谁都不需要做什么。';

  @override
  String get pauseFactNothingDeleted => '已经约定好的事不会被删掉。';

  @override
  String get pauseFactNoBacklog => '暂停期间不会堆积待办 —— 回来的时候不会有一堆没做的事等着你。';

  @override
  String get pauseFactEitherCan => '你们任何一个人都可以暂停，不需要对方同意。';

  @override
  String get pauseAction => '暂停';

  @override
  String get pauseBusy => '正在暂停…';

  @override
  String get pauseNotNow => '先不了';

  @override
  String get resumeTitle => '回来';

  @override
  String get resumeNothingWaiting => '暂停这几天的事不会等着你。你没有落下什么。';

  @override
  String get resumeHowMuch => '回来多少';

  @override
  String get resumeLighter => '轻一点';

  @override
  String get resumeLighterSupport => '大约是你暂停时的一半。';

  @override
  String get resumeSame => '和之前一样';

  @override
  String get resumeSameSupport => '原来有什么，就还是什么。';

  @override
  String get resumeAction => '回来';

  @override
  String get resumeBusy => '正在恢复…';

  @override
  String get resumeStayPaused => '先继续暂停';

  @override
  String get pauseFailed => '没能发到服务端。什么都没有改动 —— 再试一次。';

  @override
  String get resumeFailed => '没能发到服务端。还是暂停中 —— 再试一次。';

  @override
  String get detailClose => '关闭';

  @override
  String get shellBack => '返回';

  @override
  String get pointsTitle => '分';

  @override
  String get settingsPointsSection => '积分';

  @override
  String get settingsPointsOpen => '积分和奖励';

  @override
  String get settingsPointsSupport => '积分可以整个关掉。关了之后其他一切照旧。';

  @override
  String get navPoints => '分';

  @override
  String todayDayStartsAt(String clock) {
    return '今天从 $clock 算';
  }

  @override
  String todayBalance(int count) {
    return '$count 分';
  }

  @override
  String todayDaysTogether(int count) {
    return '在一起 $count 天';
  }

  @override
  String get todayNoteOptional => '附一句（可不写）';

  @override
  String get todaySend => '送出';

  @override
  String get todayCancel => '取消';

  @override
  String get todayPartnerFallback => '对方';

  @override
  String todayDueBy(String time) {
    return '$time 前';
  }

  @override
  String todayPointsEarn(int count) {
    return '+$count 分';
  }

  @override
  String get sTodayEmpty => '今天没有要求你什么。';

  @override
  String get sTodaySectionCheckin => '问安';

  @override
  String get sTodaySectionList => '今日清单';

  @override
  String get sTodaySectionOpen => '想做就做';

  @override
  String sTodayDelivered(String name) {
    return '已送到 · 等 $name 看';
  }

  @override
  String sTodayDeliveredLate(String name) {
    return '晚送到 · 等 $name 看';
  }

  @override
  String sTodaySeen(String name, String time) {
    return '$name 看到了 · $time';
  }

  @override
  String sTodayPraised(String name) {
    return '$name：很好';
  }

  @override
  String sTodayPraisedNote(String name, String note) {
    return '$name：$note';
  }

  @override
  String sTodayLetGo(String name) {
    return '$name：算了';
  }

  @override
  String sTodayMakeUp(String name, String day) {
    return '$name：$day 补上';
  }

  @override
  String sTodayPunished(String name, String title) {
    return '$name：罚 · $title';
  }

  @override
  String sTodayPaused(String name) {
    return '$name 不在，先停';
  }

  @override
  String get sTodayMissed => '没做';

  @override
  String get sTodayCantDo => '做不了';

  @override
  String sTodayNewTime(String time) {
    return '求个新时间 · $time';
  }

  @override
  String get sTodayDiscuss => '想谈谈';

  @override
  String sTodayYourNote(String note) {
    return '你：$note';
  }

  @override
  String get sTodayActionDeliver => '交付';

  @override
  String get sTodayActionCantDo => '做不了';

  @override
  String get sTodayActionNewTime => '求个新时间';

  @override
  String get sTodayActionDiscuss => '想谈谈';

  @override
  String get sTodayActionWithdraw => '撤回';

  @override
  String get sTodayWriteLine => '写一句';

  @override
  String get sTodayPhotoRef => '照片';

  @override
  String get sTodayPhotoHint => '先填一个照片引用；拍照下个版本加。';

  @override
  String get sTodayProofCamera => '拍照';

  @override
  String get sTodayProofGallery => '从相册选';

  @override
  String get sTodayPhotoFailed => '照片没传上去，什么都没有改。';

  @override
  String get sTodayPickTime => '选时间';

  @override
  String sTodayConflictPaused(String name) {
    return '$name 停了这条。';
  }

  @override
  String sTodayConflictDisposed(String name) {
    return '$name 已经处置了这条。';
  }

  @override
  String get sTodayConflictChanged => '这条在别处改过了。';

  @override
  String get sTodayConflictOther => '没送出去，再试一次。';

  @override
  String get dTodayEmpty => '没有等你的。';

  @override
  String get dTodaySectionNeedsMe => '等我处置的';

  @override
  String dTodaySectionOverview(String name) {
    return '今天 $name 的概况';
  }

  @override
  String dTodayOverviewDelivered(int done, int total) {
    return '$done/$total 已交付';
  }

  @override
  String dTodayOverviewFlagged(int count) {
    return '$count 条说了情况';
  }

  @override
  String dTodaySaidDelivered(String time) {
    return '已交付 · $time';
  }

  @override
  String dTodaySaidLate(String time) {
    return '晚交付 · $time';
  }

  @override
  String get dTodaySaidCantDo => '说做不了';

  @override
  String dTodaySaidNewTime(String time) {
    return '求新时间 · $time';
  }

  @override
  String get dTodaySaidDiscuss => '想谈谈';

  @override
  String get dTodaySaidMissed => '没做';

  @override
  String dTodaySaidNote(String name, String note) {
    return '$name：$note';
  }

  @override
  String dTodayProofPhoto(String ref) {
    return '照片：$ref';
  }

  @override
  String dTodayOnDay(String day) {
    return '$day';
  }

  @override
  String get dTodayActionSeen => '看到了';

  @override
  String get dTodayActionPraise => '很好';

  @override
  String get dTodayActionLetGo => '算了';

  @override
  String get dTodayActionMakeUp => '补上';

  @override
  String get dTodayActionPunish => '罚';

  @override
  String get dTodayMakeUpWhich => '哪天补？';

  @override
  String get dTodayPunishWhich => '罚什么？';

  @override
  String get dTodayPunishOwn => '自己写';

  @override
  String get dTodayPunishTitle => '罚什么';

  @override
  String get dTodayConflictOpen => '还没说什么，不用处置。';

  @override
  String get dTodayConflictPaused => '这条停着。';

  @override
  String get dTodayConflictChanged => '这条在别处改过了。';

  @override
  String get dTodayConflictOther => '没送出去，再试一次。';

  @override
  String get dTodaySectionQuickAdd => '快速加一条';

  @override
  String get dTodayQuickTitle => '做什么';

  @override
  String get dTodayQuickToday => '只今天';

  @override
  String get dTodayQuickDaily => '每天';

  @override
  String get dTodayQuickPoints => '分（可不填）';

  @override
  String get dTodayQuickAdd => '加上';

  @override
  String get dTodayQuickAdded => '加上了。';

  @override
  String get dTodayQuickFailed => '没加上，再试一次。';

  @override
  String get dTodaySectionNotes => '我要记得的';

  @override
  String get dTodayNoteBody => '记一句';

  @override
  String get dTodayNoteRemind => '提醒我';

  @override
  String dTodayNoteRemindAt(String time) {
    return '提醒 · $time';
  }

  @override
  String get dTodayNoteDone => '好了';

  @override
  String get dTodayNoteDelete => '删掉';

  @override
  String get dTodayNoteAdd => '记下';

  @override
  String get dTodayNotesPrivate => '只有你看得到。';

  @override
  String get settingsTimezoneLabel => '时区';

  @override
  String get settingsTimezoneSearch => '找一个城市或时区';

  @override
  String get settingsDayStartLabel => '一天从几点开始';

  @override
  String get settingsHonorificD => '你们叫 D 什么';

  @override
  String get settingsHonorificS => '你们叫 S 什么';

  @override
  String get settingsSafeword => '安全词';

  @override
  String get settingsSafewordSupport => '说出来就全停。两个人都能看、都能改。';

  @override
  String get settingsUnset => '还没定';

  @override
  String get settingsEditSave => '保存';

  @override
  String get settingsEditCancel => '取消';

  @override
  String get settingsEditClear => '清掉';

  @override
  String get rulesSafewordMeta => '安全词';

  @override
  String get settingsDeviceLock => '设备锁';

  @override
  String get settingsDeviceLockSupport => '打开时、或离开半分钟再回来时，先验指纹、面容或设备密码。';

  @override
  String get settingsDeviceLockUnavailable => '这台设备不支持设备锁。';

  @override
  String get lockTitle => '已锁定';

  @override
  String get lockUnlock => '解锁';

  @override
  String get lockReason => '解锁后继续';

  @override
  String recordTogether(int days, int streak) {
    return '在一起 $days 天 · 连续 $streak 天';
  }

  @override
  String get recordPrevMonth => '上个月';

  @override
  String get recordNextMonth => '下个月';

  @override
  String get recordFactsTitle => '这周 · 这月';

  @override
  String get recordFactsWeek => '本周';

  @override
  String get recordFactsMonth => '本月';

  @override
  String get recordFactDelivered => '交付';

  @override
  String get recordFactLate => '晚交';

  @override
  String get recordFactFlagged => '说明';

  @override
  String get recordFactMissed => '没交';

  @override
  String get recordFactLetGo => '算了';

  @override
  String get recordFactPraised => '很好';

  @override
  String get recordFactMadeUp => '补上';

  @override
  String get recordFactPunished => '罚';

  @override
  String get recordFactComments => '留言';

  @override
  String get recordFactPointsEarned => '得分';

  @override
  String get recordFactPointsDeducted => '扣分';

  @override
  String get recordFactRedemptions => '兑换';

  @override
  String get recordCouldNotLoad => '记录没能读到。';

  @override
  String get recordDayCouldNotLoad => '这一天没能读到。';

  @override
  String get recordDayEmpty => '这一天没写下什么。';

  @override
  String get recordMe => '你';

  @override
  String get recordBack => '回到记录';

  @override
  String recordDelivered(String name, String title) {
    return '$name 交付了「$title」';
  }

  @override
  String recordDeliveredLate(String name, String title) {
    return '$name 交付了「$title」，晚了';
  }

  @override
  String recordCantDo(String name, String title) {
    return '$name 说「$title」做不了';
  }

  @override
  String recordNewTime(String name, String title) {
    return '$name 想给「$title」换个时间';
  }

  @override
  String recordDiscuss(String name, String title) {
    return '$name 想谈谈「$title」';
  }

  @override
  String recordWithdrew(String name, String title) {
    return '$name 撤回了「$title」';
  }

  @override
  String recordMissed(String title) {
    return '「$title」当天没交';
  }

  @override
  String recordPausedEntry(String title) {
    return '「$title」停了';
  }

  @override
  String recordSeen(String name, String title) {
    return '$name 看到了「$title」';
  }

  @override
  String recordPraised(String name, String title) {
    return '$name：很好——「$title」';
  }

  @override
  String recordLetGo(String name, String title) {
    return '$name 算了：「$title」';
  }

  @override
  String recordMakeUp(String name, String title, String day) {
    return '$name：「$title」$day 补上';
  }

  @override
  String recordPunished(String name, String title, String consequence) {
    return '$name：罚「$title」——$consequence';
  }

  @override
  String recordDispositionCleared(String name, String title) {
    return '$name 收回了对「$title」的处置';
  }

  @override
  String recordPhotoRef(String ref) {
    return '照片：$ref';
  }

  @override
  String recordCommented(String name) {
    return '$name 留了一句';
  }

  @override
  String recordPointsEarnedAuto(int amount, String reason) {
    return '+$amount 分 · $reason';
  }

  @override
  String recordPointsAdded(String name, int amount) {
    return '$name 加了 $amount 分';
  }

  @override
  String recordPointsDeducted(String name, int amount) {
    return '$name 扣了 $amount 分';
  }

  @override
  String get recordReasonTaskEarn => '任务';

  @override
  String get recordReasonAward => '加分';

  @override
  String get recordReasonDeduct => '扣分';

  @override
  String get recordReasonRedemption => '兑换';

  @override
  String get recordReasonRefund => '退回';

  @override
  String recordRedeemed(String name, String title) {
    return '$name 兑换了「$title」';
  }

  @override
  String get recordActionDeliverLate => '补交付';

  @override
  String get recordActionCantDo => '说明做不了';

  @override
  String get recordComments => '给这一天留一句';

  @override
  String get recordCommentHint => '两个人都可以写';

  @override
  String get recordDeleteCommentTitle => '删掉这句？';

  @override
  String get recordDelete => '删掉';

  @override
  String get recordPrivateNote => '私人备注';

  @override
  String get recordPrivateNoteHint => '只有你看得到。离开输入框时保存。';

  @override
  String get recordPrivateNoteSaved => '已保存';

  @override
  String get recordPrivateNoteFailed => '没保存上，再试一次。';

  @override
  String get recordCommentFailed => '没送出去，再试一次。';

  @override
  String get rulesTitle => '规矩';

  @override
  String get rulesAwayToggle => '我不在';

  @override
  String rulesAwayUntil(String date) {
    return '不在，到 $date';
  }

  @override
  String rulesAwayPartner(String name, String date) {
    return '$name 不在，到 $date';
  }

  @override
  String get rulesBack => '回来了';

  @override
  String get rulesStandingTitle => '常设规矩';

  @override
  String get rulesStandingEmpty => '还没有规矩。';

  @override
  String get ruleGroupProtocol => '礼节';

  @override
  String get ruleGroupRitual => '仪式';

  @override
  String get ruleGroupRestriction => '禁止';

  @override
  String get ruleGroupAppearance => '着装';

  @override
  String get ruleGroupReporting => '汇报';

  @override
  String get ruleGroupOther => '其他';

  @override
  String get rulesAddRule => '加一条规矩';

  @override
  String get rulesProposeRule => '提议一条规矩';

  @override
  String get rulesProposeChange => '提议改一条';

  @override
  String get rulesRuleTitleLabel => '一句话';

  @override
  String get rulesRuleBodyLabel => '细说（可选）';

  @override
  String get rulesGroupLabel => '分组';

  @override
  String get rulesSave => '记下';

  @override
  String get rulesArchive => '归档';

  @override
  String get rulesNeverMind => '不改了';

  @override
  String get rulesTasksTitle => '循环任务';

  @override
  String get rulesTasksEmpty => '还没有任务。';

  @override
  String get rulesAddTask => '加一条任务';

  @override
  String get rulesProposeTask => '提议一条任务';

  @override
  String get rulesTaskTitleLabel => '做什么';

  @override
  String get rulesScheduleDaily => '每天';

  @override
  String rulesScheduleWeekdays(String days) {
    return '每周$days';
  }

  @override
  String rulesScheduleEveryN(int n) {
    return '每 $n 天';
  }

  @override
  String get rulesScheduleOneOff => '一次';

  @override
  String get rulesScheduleOpen => '随时';

  @override
  String get rulesScheduleCheckin => '问安';

  @override
  String get rulesScheduleMeasure => '记数值';

  @override
  String get rulesWeekdayNames => '一,二,三,四,五,六,日';

  @override
  String rulesTimesPerDay(int n) {
    return '一天 $n 次';
  }

  @override
  String get rulesProofCheck => '勾';

  @override
  String get rulesProofPhoto => '照片';

  @override
  String get rulesProofText => '文字';

  @override
  String get rulesProofAny => '任意';

  @override
  String rulesPoints(int n) {
    return '$n 分';
  }

  @override
  String rulesNeedsD(String name) {
    return '要 $name 在';
  }

  @override
  String get rulesPaused => '暂停中';

  @override
  String rulesPausedUntil(String date) {
    return '暂停中，到 $date';
  }

  @override
  String get rulesPauseUntilDate => '暂停到某天';

  @override
  String get rulesPauseIndefinite => '先停着';

  @override
  String get rulesUnpause => '恢复';

  @override
  String get rulesPointsLabel => '分（0 = 基础项）';

  @override
  String rulesRequiresDLabel(String name) {
    return '要 $name 在场';
  }

  @override
  String get rulesEveryNLabel => '每几天';

  @override
  String get rulesProposedTitle => '提议中';

  @override
  String get rulesProposedEmpty => '没有待看的提议。';

  @override
  String get rulesAccept => '接受';

  @override
  String get rulesDecline => '不要';

  @override
  String rulesWaitingFor(String name) {
    return '等 $name 看';
  }

  @override
  String get rulesKindTask => '任务';

  @override
  String get rulesKindRule => '规矩';

  @override
  String get rulesWithdraw => '撤回';

  @override
  String get rulesRewardsTitle => '奖励目录';

  @override
  String get rulesRewardsEmpty => '还没有奖励。';

  @override
  String get rulesAddReward => '加一条奖励';

  @override
  String get rulesRewardTitleLabel => '奖励';

  @override
  String get rulesRewardCostLabel => '多少分';

  @override
  String get rulesRewardDDecides => '到时候再定';

  @override
  String rulesRewardDDecidesName(String name) {
    return '$name 定';
  }

  @override
  String get rulesRewardRetire => '撤下';

  @override
  String get rulesGoRedeem => '去兑换';

  @override
  String get rulesConsequencesTitle => '惩罚库';

  @override
  String rulesConsequencesIntro(String name) {
    return '只有 $name 处置的时候用得上；放在这里，不从这里执行。';
  }

  @override
  String get rulesConsequencesEmpty => '还没有。';

  @override
  String get rulesAddConsequence => '加一条';

  @override
  String get rulesConsequenceWhen => '什么时候';

  @override
  String get rulesConsequenceThen => '罚什么';

  @override
  String get rulesEndConsequence => '结束';

  @override
  String get rulesLimitsTitle => '底线与安全词';

  @override
  String get rulesLimitsLine => '两人在比对里标「不要」的项，会列在这里。';

  @override
  String get rulesLimitsGo => '去比对';

  @override
  String get rulesExploreTitle => '探索';

  @override
  String get rulesExploreCompare => '两人比对';

  @override
  String get rulesExploreInspiration => '灵感';

  @override
  String get rulesExploreStarter => '起步包';

  @override
  String get rulesPauseDynamic => '暂停一下';

  @override
  String get rulesCouldNotLoad => '规矩没能读到。';

  @override
  String get rulesActionFailed => '没记上。再试一次。';

  @override
  String rulesProposedSent(String name) {
    return '提议送到了，等 $name 看。';
  }

  @override
  String get rulesTheD => 'D';

  @override
  String get rulesTheS => 's';

  @override
  String get rulesYou => '你';

  @override
  String ptsBalanceOf(String name, int n) {
    return '$name · $n 分';
  }

  @override
  String ptsBalanceMine(int n) {
    return '$n';
  }

  @override
  String get ptsGive => '给分';

  @override
  String get ptsDeduct => '扣分';

  @override
  String get ptsAmountLabel => '多少';

  @override
  String get ptsWhyLabel => '一句为什么（可选）';

  @override
  String ptsGiveTitle(String name) {
    return '给 $name 分';
  }

  @override
  String ptsDeductTitle(String name) {
    return '扣 $name 的分';
  }

  @override
  String get ptsRedeemableTitle => '可兑换';

  @override
  String get ptsRedeemableEmpty => '还没定奖励。';

  @override
  String ptsShort(int n) {
    return '还差 $n 分';
  }

  @override
  String ptsRequestTitle(String title) {
    return '申请兑换「$title」';
  }

  @override
  String get ptsRequestNote => '想说一句（可选）';

  @override
  String get ptsRequestSend => '申请';

  @override
  String get ptsRequestsTitle => '兑换申请';

  @override
  String get ptsRequestsEmpty => '没有申请。';

  @override
  String ptsStatusRequested(String name) {
    return '等 $name 看';
  }

  @override
  String ptsStatusApproved(String name) {
    return '$name 同意了';
  }

  @override
  String ptsStatusDenied(String name) {
    return '$name 说不行';
  }

  @override
  String get ptsStatusFulfilled => '完成了';

  @override
  String get ptsApprove => '同意';

  @override
  String get ptsDeny => '不行';

  @override
  String get ptsFulfill => '完成了';

  @override
  String get ptsDecideNote => '一句话（可选）';

  @override
  String get ptsDecideCost => '定多少分';

  @override
  String get ptsLedgerTitle => '流水';

  @override
  String get ptsLedgerEmpty => '还没有流水。';

  @override
  String get ptsReasonTaskEarn => '任务';

  @override
  String ptsReasonAward(String name) {
    return '$name 给';
  }

  @override
  String ptsReasonDeduct(String name) {
    return '$name 扣';
  }

  @override
  String get ptsReasonRedemption => '兑换';

  @override
  String get ptsReasonRefund => '退回';

  @override
  String get ptsReasonOther => '变动';

  @override
  String get ptsRulesTitle => '哪些任务给分';

  @override
  String get ptsRulesEmpty => '还没有给分的任务。';

  @override
  String get ptsRulesBase => '其余基础项 0 分。';

  @override
  String get ptsConsequencesTitle => '罚';

  @override
  String get ptsConsequencesEmpty => '没有。';

  @override
  String get ptsConsequenceDone => '做完了';

  @override
  String get ptsConsequenceConfirm => '确认';

  @override
  String get ptsConsequenceWaive => '算了';

  @override
  String get ptsConsStatusIssued => '还没做';

  @override
  String ptsConsStatusDoneByS(String name) {
    return '做完了，等 $name';
  }

  @override
  String ptsConsStatusConfirmed(String name) {
    return '$name 确认了';
  }

  @override
  String ptsConsStatusWaived(String name) {
    return '$name 算了';
  }

  @override
  String get ptsCouldNotLoad => '分没能读到。';

  @override
  String get ptsActionFailed => '没记上。再试一次。';

  @override
  String get exploreTitle => '探索';

  @override
  String get exploreBack => '返回';

  @override
  String get exploreSectionPrefs => '偏好';

  @override
  String get exploreSectionCompare => '对照';

  @override
  String get exploreSectionCards => '灵感卡';

  @override
  String get exploreCouldNotLoad => '没能打开。';

  @override
  String get exploreActionFailed => '没记上。再试一次。';

  @override
  String get explorePrefsIntro => '答三条就能看交集。只有两人都答过的，才互相看得见。';

  @override
  String get exploreAnswerWant => '想要';

  @override
  String get exploreAnswerOk => '可以';

  @override
  String get exploreAnswerNo => '不要';

  @override
  String get exploreAnswerTalk => '想聊';

  @override
  String exploreCompareNoPartner(String name) {
    return '$name 还没答。你的答案已经存好。';
  }

  @override
  String get exploreCompareEmpty => '还没有两人都答过的条目。';

  @override
  String get exploreCompareBothWant => '都想要';

  @override
  String get exploreCompareWantAndOk => '一个想要、一个可以';

  @override
  String get exploreCompareTalks => '有人想聊';

  @override
  String get exploreCompareNotDoing => '这条不做';

  @override
  String get exploreCompareNotDoingLine => '两人里有人标了「不要」。是谁，不显示。';

  @override
  String get exploreCompareAddRule => '加到规矩';

  @override
  String exploreCompareProposeRule(String name) {
    return '提议给 $name';
  }

  @override
  String get exploreCardsEmpty => '现在没有合适的卡。';

  @override
  String exploreCardIntensity(int n) {
    return '强度 $n';
  }

  @override
  String exploreCardNeeds(String needs) {
    return '需要：$needs';
  }

  @override
  String get exploreCardSaved => '存了';

  @override
  String get exploreCardTriedAgain => '试过了·再来';

  @override
  String get exploreCardTriedNever => '试过了·不再';

  @override
  String get exploreActAddToday => '加到今天';

  @override
  String get exploreActAddRule => '加到规矩';

  @override
  String get exploreActSave => '存起来';

  @override
  String exploreActPropose(String name) {
    return '提议给 $name';
  }

  @override
  String get exploreActTriedAgain => '试过了·再来';

  @override
  String get exploreActTriedNever => '不再';

  @override
  String get exploreActDone => '记上了。';

  @override
  String get exploreDrawTonight => '今晚要什么？';

  @override
  String get exploreDrawAgain => '再抽一张';

  @override
  String get exploreDrawFailed => '没抽到。再试一次。';

  @override
  String get explorePacksTitle => '起步包';

  @override
  String get explorePacksIntro => '选一套，再逐条改成你们的样子。你说启用之前，什么都不会建。';

  @override
  String get explorePackTasks => '任务';

  @override
  String get explorePackRules => '规矩';

  @override
  String get explorePackRewards => '奖励';

  @override
  String get explorePackApply => '启用这一套';

  @override
  String get explorePackApplied => '建好了，都在「规矩」里。';

  @override
  String get explorePackEdit => '改这一条';

  @override
  String get explorePackLineLabel => '内容';

  @override
  String get explorePackKeep => '好';

  @override
  String explorePackCount(int tasks, int rules, int rewards) {
    return '$tasks 条任务 · $rules 条规矩 · $rewards 条奖励';
  }

  @override
  String get explorePackEmptyDraft => '没有要建的了。';

  @override
  String get rulesStartFromPack => '从一套开始';

  @override
  String get rulesExplorePrefs => '偏好';

  @override
  String get sTodayMeasureLabel => '数值';

  @override
  String sTodayMeasureLabelUnit(String unit) {
    return '数值（$unit）';
  }

  @override
  String get recordSeriesTitle => '曲线';

  @override
  String get recordSeriesAction => '曲线';

  @override
  String get recordSeriesSection => '曲线';

  @override
  String recordSeriesEmpty(int days) {
    return '最近 $days 天还没有数字。';
  }

  @override
  String recordSeriesRange(String from, String to) {
    return '$from – $to';
  }

  @override
  String recordSeriesLow(String value) {
    return '最低 $value';
  }

  @override
  String recordSeriesHigh(String value) {
    return '最高 $value';
  }

  @override
  String recordSeriesLatest(String day, String value) {
    return '$day · $value';
  }

  @override
  String recordSeriesCount(int count) {
    return '记了 $count 天';
  }

  @override
  String get recordExport => '导出记录';

  @override
  String recordExportLastDays(int days) {
    return '最近 $days 天';
  }

  @override
  String get recordExportCustom => '自选日期…';

  @override
  String recordExported(String filename) {
    return '已导出 $filename';
  }

  @override
  String get recordExportFailed => '没导出成，再试一次。';

  @override
  String get rulesEditTask => '改一下';

  @override
  String get rulesTaskKindLabel => '哪一种';

  @override
  String get rulesTaskKindRecurring => '循环';

  @override
  String get rulesTaskKindOneOff => '一次';

  @override
  String get rulesTaskKindOpen => '想做就做';

  @override
  String get rulesTaskKindCheckin => '问安';

  @override
  String get rulesTaskKindMeasure => '记数值';

  @override
  String get rulesTaskDetailLabel => '细说（可选）';

  @override
  String get rulesTaskDetailTooLong => '最多 1000 字';

  @override
  String get rulesTaskTitleRequired => '先写做什么';

  @override
  String get rulesScheduleLabel => '什么时候';

  @override
  String get rulesWeekdaysRequired => '至少选一天';

  @override
  String rulesEveryNFrom(String date) {
    return '从 $date 起';
  }

  @override
  String get rulesEveryNInvalid => '填 2 到 365';

  @override
  String get rulesTimesPerDayLabel => '一天几次';

  @override
  String rulesDueTimeLabel(String zone) {
    return '截止（$zone）';
  }

  @override
  String get rulesDueEndOfDay => '日终';

  @override
  String get rulesDueAtLabel => '哪天、几点';

  @override
  String get rulesDuePickDate => '选一天';

  @override
  String get rulesDueAtRequired => '一次性的要选哪天';

  @override
  String get rulesProofLabel => '怎么交';

  @override
  String get rulesProofCheckinOnly => '问安只收文字';

  @override
  String get rulesPointsRange => '0 到 1000';

  @override
  String get rulesPointsHint => '基础项 0 分，没做才扣';

  @override
  String get rulesUnitLabel => '单位（kg、ml…）';

  @override
  String get rulesUnitRequired => '记数值要有单位';

  @override
  String get dTodayQuickMore => '更多设置…';

  @override
  String get joinAlreadyInHeadline => '你已经\n在里面了。';

  @override
  String get joinOpenApp => '去今天';

  @override
  String get joinUsedGuidance => '如果用它的人是你，直接进去就行。';

  @override
  String get inviteAlreadyLiveReplace => '收回旧的，重新做一条';

  @override
  String get inviteAlreadyLiveReplaceNote => '收回后，原来那条链接就打不开了；新链接只显示这一次。';

  @override
  String get todayPausedLine => '暂停中。这段时间没有交付，也没有处置。';

  @override
  String get todayPausedOpen => '去看看';

  @override
  String get todayWaitingPartner => '等 TA 加入。';

  @override
  String get todayWaitingPartnerBody => 'TA 进来之前，这里不会有任何要求。';

  @override
  String get todayInviteLink => '发邀请链接';

  @override
  String get sTodayEmptyRules => '去看规矩';

  @override
  String get todayWaitingPartnerBodyD => 'TA 进来之前，你可以先把规矩和任务立起来。';

  @override
  String get notificationsTitle => '消息';

  @override
  String get notificationsEmpty => '这里还没有什么。';

  @override
  String get notificationsLoadFailed => '没能读到消息。';

  @override
  String get notificationsReminderTitle => 'Companion';

  @override
  String notificationsReminderDue(String title) {
    return '$title，到点了。';
  }

  @override
  String notificationsReminderDayEnd(int count) {
    return '这一天还有 $count 项没说。';
  }

  @override
  String get settingsDigestSection => '交付通知';

  @override
  String get settingsDigestOff => '每条即时';

  @override
  String get settingsDigestOffSupport => '对方每送到一项，你都会立刻知道。';

  @override
  String settingsDigestEvery(int hours) {
    return '每 $hours 小时合并一次';
  }

  @override
  String get settingsMutedTypesSection => '哪些事要通知';

  @override
  String get settingsMutedTypesSupport => '关掉的还会留在消息里，只是不会响。';

  @override
  String get settingsTypeDelivered => '对方送到了';

  @override
  String get settingsTypeFlagged => '做不了 / 求新时间 / 想谈谈';

  @override
  String get settingsTypeDisposition => '对方的处置';

  @override
  String get settingsTypeComment => '留言';

  @override
  String get settingsTypeAward => '加分';

  @override
  String get settingsTypeRedemption => '兑换申请';

  @override
  String get settingsTypeDNote => '备忘提醒';

  @override
  String get inboxOccurrenceDeliveredTitle => '交了';

  @override
  String get inboxOccurrenceDeliveredBody => '有一项标记为已交。';

  @override
  String get inboxOccurrenceFlaggedTitle => '有更新';

  @override
  String get inboxOccurrenceFlaggedBody => '今天有一项有了新情况。';

  @override
  String get inboxDispositionSetTitle => '有回应';

  @override
  String get inboxDispositionSetBody => '有一条回应在等你看。';

  @override
  String get inboxDayCommentTitle => '留言';

  @override
  String get inboxDayCommentBody => '有人在某一天留了言。';

  @override
  String get inboxRuleProposedTitle => '有提议';

  @override
  String get inboxRuleProposedBody => '有一条提议等你决定。';

  @override
  String get inboxRuleAcceptedTitle => '通过了';

  @override
  String get inboxRuleAcceptedBody => '你的提议通过了。';

  @override
  String get inboxTaskProposedTitle => '有提议';

  @override
  String get inboxTaskProposedBody => '有一条提议等你决定。';

  @override
  String get inboxTaskAcceptedTitle => '通过了';

  @override
  String get inboxTaskAcceptedBody => '你的提议通过了。';

  @override
  String get inboxRedemptionRequestedTitle => '有申请';

  @override
  String get inboxRedemptionRequestedBody => '有人申请兑换一项奖励。';

  @override
  String get inboxRedemptionDecidedTitle => '有决定';

  @override
  String get inboxRedemptionDecidedBody => '你的申请有了决定。';

  @override
  String get inboxRedemptionFulfilledTitle => '兑现了';

  @override
  String get inboxRedemptionFulfilledBody => '一项奖励标记为已兑现。';

  @override
  String get inboxConsequenceIssuedTitle => '新的一项';

  @override
  String get inboxConsequenceIssuedBody => '有一项给到了你。';

  @override
  String get inboxConsequenceDoneTitle => '做完了';

  @override
  String get inboxConsequenceDoneBody => '有一项标记为做完了。';

  @override
  String get inboxConsequenceDecidedTitle => '有决定';

  @override
  String get inboxConsequenceDecidedBody => '有一条决定在等你。';

  @override
  String get inboxDAwardTitle => '积分';

  @override
  String get inboxDAwardBody => '你收到了积分。';

  @override
  String get inboxDNoteReminderTitle => '提醒';

  @override
  String get inboxDNoteReminderBody => '一条提醒到时间了。';

  @override
  String get entranceErrorRegisterConflict => '这个邮箱没能用来创建账号。如果你之前注册过，直接登录。';
}
