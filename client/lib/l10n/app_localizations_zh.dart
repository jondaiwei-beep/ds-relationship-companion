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
  String get rulesExplore => '探索';

  @override
  String get recordComingSoon => '还没做';

  @override
  String get recordComingSoonBody => '每一天一页：交了什么、说了什么、怎么处置的。下一阶段。';

  @override
  String get navRecord => '记录';

  @override
  String get actionReceived => '看到了';

  @override
  String get actionComplete => '做好了';

  @override
  String get actionDiscuss => '想聊聊';

  @override
  String get actionNewTime => '换个时间';

  @override
  String get actionCantDo => '这次做不到';

  @override
  String get actionTakeItBack => '算了，收回';

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
  String get responseTypeAcknowledge => '我看到了';

  @override
  String get responseTypePraise => '夸夸你';

  @override
  String get responseTypeComment => '说两句';

  @override
  String get responseTypeReview => '回头看看';

  @override
  String responseComposerTitle(String name) {
    return '回应 $name';
  }

  @override
  String get responseYourWords => '你想说的话';

  @override
  String get responseWordsHint => '写下你看到的……';

  @override
  String responseNeedsWords(String type) {
    return '「$type」要写下你自己的话。';
  }

  @override
  String responseSendTo(String name) {
    return '发给 $name';
  }

  @override
  String get responseSending => '正在发送';

  @override
  String get responseNotNow => '现在先不';

  @override
  String get responseAttention => '等你的';

  @override
  String responsePartnerPresent(String name) {
    return '$name 在';
  }

  @override
  String responseCompletedAtBy(String name, String time) {
    return '$name 在 $time\n把这件事做好了。';
  }

  @override
  String get responseAlreadyAnsweredTitle => '这件事\n已经回应过了。';

  @override
  String responseAlreadyAnsweredDetail(String name) {
    return '$name 已经收到你的回应了。';
  }

  @override
  String get responseClose => '关掉';

  @override
  String get responseErrorOffline => '你现在没联网。连上网络，然后再试一次。';

  @override
  String get responseErrorGeneric => '刚才没发出去。再试一次。';

  @override
  String get responseAttentionSummaryLabel => '在等你回应的';

  @override
  String responseAttentionMoments(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件',
    );
    return '$_temp0';
  }

  @override
  String responseAttentionAwaiting(int count) {
    return '$count 件在等你回应';
  }

  @override
  String responseAttentionToRevisit(int count) {
    return '$count 件可以回头看看';
  }

  @override
  String responseAttentionSectionWaiting(String name) {
    return '$name 在等你';
  }

  @override
  String get responseAttentionSectionCompletions => '做好了，等你回应';

  @override
  String get responseAttentionSectionLookBack => '一起回头看看';

  @override
  String responseAttentionRespondTo(String name) {
    return '回应 $name';
  }

  @override
  String get responseAttentionEmptyTitle => '现在没有\n在等你的事。';

  @override
  String get responseAttentionEmptyDetail => '需要你回应的事，\n以后都会出现在这里。';

  @override
  String get responseStateAskedToDiscuss => '想聊聊';

  @override
  String get responseStateAskedForNewTime => '想换个时间';

  @override
  String get responseStateCantDoThis => '说这次做不到';

  @override
  String get responseStateCompleted => '做好了';

  @override
  String get responseStateStillOpen => '还没做完';

  @override
  String get responseStateWaiting => '在等你';

  @override
  String responseAgoMinutes(int count) {
    return '$count 分钟前';
  }

  @override
  String responseAgoHours(int count) {
    return '$count 小时前';
  }

  @override
  String get responseAgoYesterday => '昨天';

  @override
  String responseAgoDays(int count) {
    return '$count 天前';
  }

  @override
  String get responseWaitingYourPartner => '对方';

  @override
  String get responseWaitingHeaderAnswered => '回应';

  @override
  String responseWaitingPresenceWaiting(String name) {
    return '在等 $name';
  }

  @override
  String get responseWaitingRecorded => '你做的\n已经记下了。';

  @override
  String responseWaitingCompletedAt(String time) {
    return '$time 做好的';
  }

  @override
  String get responseWaitingNodeCompleted => '已经做好';

  @override
  String responseWaitingNodeWaitingFor(String name) {
    return '在等 $name';
  }

  @override
  String responseWaitingNotYetAnswered(String name) {
    return '你这边做好了。\n$name 还没有回应。';
  }

  @override
  String get responseWaitingReturnToToday => '回到今天';

  @override
  String get responseWaitingCloseRitual => '收起这件日常';

  @override
  String get responseAnsweredTitle => '有人看见你了。';

  @override
  String responseAnsweredWordlessNamed(String name) {
    return '$name 回应了这件事。';
  }

  @override
  String get responseAnsweredWordlessAnonymous => '这件事被回应了。';

  @override
  String responseReceivedAt(String time) {
    return '$time 收到';
  }

  @override
  String get responsePrivateNoteLabel => '私人笔记 · 只有你看得到';

  @override
  String get dynamicTitle => '关系';

  @override
  String get dynamicYou => '你';

  @override
  String get dynamicNoOneYet => '还没有人';

  @override
  String get dynamicCurrentStructure => '现在的相处方式';

  @override
  String get dynamicCurrentRhythm => '现在的日常';

  @override
  String get dynamicCurrentRhythms => '现在的日常';

  @override
  String get dynamicAskOneThing => '交代一件事';

  @override
  String get dynamicThisWeek => '这一周';

  @override
  String get dynamicPauseThis => '暂停这段关系';

  @override
  String get dynamicComeBack => '回来';

  @override
  String get dynamicPaused => '暂停中';

  @override
  String get dynamicPausedNothingExpected => '暂停期间，你们谁都不需要做什么。';

  @override
  String get dynamicEitherMayPause => '你们任何一个人都可以暂停。暂停期间什么都不会丢。';

  @override
  String get dynamicNothingWaitingAfterPause => '暂停这几天的事不会堆着等你。';

  @override
  String get outcomeCloser => '想更亲近';

  @override
  String get outcomeStructure => '想要有秩序';

  @override
  String get outcomeService => '以照顾对方为主';

  @override
  String get outcomeAccountability => '想互相督促';

  @override
  String get outcomeExplore => '想一起探索';

  @override
  String get levelLight => '松一点';

  @override
  String get levelSteady => '两个人一起把着';

  @override
  String get levelDefined => '说得比较清楚';

  @override
  String structureLine(Object level, Object outcome) {
    return '$outcome · $level';
  }

  @override
  String get rolePresetDominant => '主导的一方';

  @override
  String get rolePresetSubmissive => '顺从的一方';

  @override
  String get rolePresetSwitch => '两边都可以';

  @override
  String get rolePresetCustom => '他们自己的说法';

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
  String get entranceNoticeUnreachable => '连不上服务器。再试一次。';

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
  String get entranceErrorOffline => '现在没有网络。连上网，再试一次。';

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
  String get entranceErrorEmailInvalid => '填一个有效的邮箱地址。';

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
  String get joinYouChooseYourRole => '你自己选择你的角色。';

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
  String get joinAlreadyJoined => '你已经加入了。打开 app 继续。';

  @override
  String get joinBoundaryIntentionLabel => '共同的心意';

  @override
  String get joinBoundaryIntention => '多一点相处方式，多一点亲近。';

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
  String get askTitle => '交代一件事';

  @override
  String get askCancel => '取消';

  @override
  String askForWhom(Object name) {
    return '想请 $name';
  }

  @override
  String get askYourPartnerFallback => '对方';

  @override
  String get askWhatStep => '你要对方做什么';

  @override
  String get askWhatHint => '八点前把房间准备好';

  @override
  String get askWhatMissing => '说说你想请对方做什么。';

  @override
  String get askWhenStep => '什么时候';

  @override
  String get askWhyStep => '为什么这件事重要（可不填）';

  @override
  String get askWhyHint => '想让我们晚上待着的地方安静一点';

  @override
  String get askSend => '发送';

  @override
  String get askSending => '正在发送…';

  @override
  String askAgencyNote(Object name) {
    return '$name 可以做好、可以说想聊聊、可以换个时间、也可以说这次做不到 —— 什么时候都可以。';
  }

  @override
  String get askNoOneYet => '现在还没有人可以请。';

  @override
  String get askNoOneYetBody => '等对方接受你的邀请之后，就可以在这里跟他说了。';

  @override
  String get askFailed => '没能发到服务端。什么都没有发出去 —— 再试一次。';

  @override
  String get askCouldNotOpen => '这个页面没能打开。什么都没有发出去。';

  @override
  String get whenAnytime => '什么时候都行';

  @override
  String get whenClear => '清除';

  @override
  String get whenToday => '今天';

  @override
  String get detailDue => '希望在';

  @override
  String detailSetBy(Object name) {
    return '$name 说的';
  }

  @override
  String get detailIntention => '为什么交代这件事';

  @override
  String get detailPrivateNote => '私密笔记 · 只有你看得到';

  @override
  String get detailCompletionNote => '想说点什么（可不填）';

  @override
  String get detailCompletionHint => '你做了什么？';

  @override
  String get detailMarkComplete => '我做好了';

  @override
  String get detailCompleting => '正在提交…';

  @override
  String detailPartnerWillSee(Object name) {
    return '$name 会看到。';
  }

  @override
  String get detailTakeItBack => '算了，收回';

  @override
  String get detailTakingItBack => '正在收回…';

  @override
  String get detailTakeItBackNote => '会回到原来的样子。不会记成同意了，也不会记成拒绝了。';

  @override
  String get detailTheirWords => '对方写的';

  @override
  String detailPersonWrote(Object name) {
    return '$name 写的';
  }

  @override
  String get detailConfirming => '正在和服务端确认…';

  @override
  String get detailSessionEnded => '需要重新登录才能继续。在那之前这里的内容都不会显示。';

  @override
  String get detailCouldNotLoad => '这个页面没能加载出来。什么都没有改动。';

  @override
  String get nothingWaitingAck => '做好了，在等对方回应。';

  @override
  String get nothingAcknowledged => '对方回应过了，这件事到这儿就好了。';

  @override
  String get nothingDiscussing => '你说想聊聊这件事。';

  @override
  String get nothingRescheduling => '你说想换个时间。';

  @override
  String get nothingExcusing => '你说这次做不到。';

  @override
  String get nothingCancelled => '已经取消了。';

  @override
  String get nothingDefault => '这里没有等着你的事。';

  @override
  String get recoveryConfirmingContext => '正在确认';

  @override
  String get recoveryNotConfirmed => '没能确认';

  @override
  String get recoveryOffline => '离线';

  @override
  String get recoveryReading => '正在读取';

  @override
  String get recoverySessionEnded => '私密会话已结束';

  @override
  String get recoverySessionRestore => '需要重新登录\n才能继续。';

  @override
  String get recoverySignInAgain => '重新登录';

  @override
  String get recoveryNoProtectedContent => '这个页面上没有留下任何私密内容。';

  @override
  String get recoveryTryAgain => '再试一次';

  @override
  String get recoveryTryToReconnect => '尝试重新连接';

  @override
  String get todayResolving => '正在确认今天';

  @override
  String get todayConfirmingPrivate => '正在确认你的私密内容…';

  @override
  String get todayPrivateByDefault => '默认私密';

  @override
  String get todayPrivateByDefaultBody => '在确认成员身份和今天是哪一天之前，不会显示任何和对方有关的内容。';

  @override
  String get todayCouldNotLoad => '今天的内容没能加载出来。什么都没丢。';

  @override
  String get todayOfflineReadOnly => '重新连上之前只能看，不能操作。';

  @override
  String get todayActionsPaused => '离线时暂时不能操作';

  @override
  String get todayActionsReturn => '确认到最新内容之后，做好了、想聊聊、换个时间、这次做不到都会回来。';

  @override
  String get todayCachedNeverNew => '缓存的内容不会被当成最新状态。';

  @override
  String get todayHiddenDetails => '和对方、和这段关系有关的内容都已隐藏。\n重新登录后才会显示。';

  @override
  String get todayOffline => '离线';

  @override
  String get dynamicConfirmingStructure => '在服务端确认之前，不会显示你们两个人的任何信息。';

  @override
  String get dynamicCouldNotConfirm => '没能确认现在的相处方式。';

  @override
  String get dynamicPauseUnavailable =>
      '暂停和回来都需要连上服务端，重新连上之前用不了。你们已经约定好的事不受影响。';

  @override
  String get dynamicCouldNotLoad => '这段关系的内容没能加载出来。什么都没有改动。';

  @override
  String get dynamicHiddenDetails => '对方、角色和现在的相处方式都已隐藏。\n重新登录后才会显示。';

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
  String get weeklyTitle => '这一周';

  @override
  String get weeklyClose => '关闭';

  @override
  String get weeklyLoading => '正在把这一周真的发生过的事找出来。';

  @override
  String get weeklyLoadFailed => '这一周没能读出来。什么都没有改动。';

  @override
  String get weeklyTryAgain => '再试一次';

  @override
  String get weeklyTooEarlyHeadline => '还没有攒够一周可以回头看。';

  @override
  String get weeklyTooEarlySupport => '等你们走过几天，它会自己回来。这期间不缺什么。';

  @override
  String get weeklyHeadlineQuiet => '安静的一周。';

  @override
  String get weeklyHeadlineOneDay => '有一天，上面有点事。';

  @override
  String weeklyHeadlineDays(Object count) {
    return '有 $count 天，上面有点事。';
  }

  @override
  String get weeklyAnsweredOne => '有一件事，是人回应的';

  @override
  String weeklyAnsweredMany(Object count) {
    return '有 $count 件事，是人回应的';
  }

  @override
  String get weeklyAdjustedOne => '有一件事你们商量好了';

  @override
  String weeklyAdjustedMany(Object count) {
    return '有 $count 件事你们商量好了';
  }

  @override
  String weeklySupportJoin(Object first, Object second) {
    return '$first；$second。';
  }

  @override
  String weeklySupportSingle(Object only) {
    return '$only。';
  }

  @override
  String get weeklySupportNothing => '这一周没有做好的事，也没有回应。这是这一周的事实，不是关于你们任何一个人的。';

  @override
  String get weeklyAnsweredSection => '被回应的';

  @override
  String weeklyMomentAttribution(Object name) {
    return '—— $name';
  }

  @override
  String get weeklyNextWeekSection => '下一周';

  @override
  String get weeklyKeep => '就照现在这样';

  @override
  String get weeklyPauseInstead => '先暂停一下';

  @override
  String get weeklyKeepSupport => '照现在这样也不是许下什么承诺。你们任何一个人，随时都可以在「关系」里暂停。';

  @override
  String get checkInTitle => '说说今天';

  @override
  String get checkInCancel => '取消';

  @override
  String get checkInHeadline => '你现在怎么样？';

  @override
  String get checkInSupport => '想说多少说多少，不想说也没关系。';

  @override
  String get checkInMoodSection => '心情';

  @override
  String get checkInMoodGood => '挺好';

  @override
  String get checkInMoodSteady => '还平稳';

  @override
  String get checkInMoodLow => '有点低';

  @override
  String get checkInMoodTender => '有点脆弱';

  @override
  String get checkInMoodRaw => '很难受';

  @override
  String get checkInEnergySection => '精力';

  @override
  String get checkInEnergyHigh => '很足';

  @override
  String get checkInEnergySteady => '还平稳';

  @override
  String get checkInEnergyLow => '快没电了';

  @override
  String get checkInNeedSection => '什么会让你好受一点';

  @override
  String get checkInNeedNothing => '不用什么';

  @override
  String get checkInNeedCloseness => '想靠近一点';

  @override
  String get checkInNeedSpace => '想有点空间';

  @override
  String get checkInNeedStructure => '想有个相处方式';

  @override
  String get checkInNeedToBeAsked => '想被问一句';

  @override
  String get checkInNoteSection => '还想说点什么（可以不写）';

  @override
  String get checkInNoteHint => '用你自己的话';

  @override
  String get checkInVisibilitySection => '谁能看到';

  @override
  String get checkInVisibilityPrivate => '只有我';

  @override
  String get checkInVisibilityShare => '给对方看';

  @override
  String checkInVisibilityShareWith(Object name) {
    return '给 $name 看';
  }

  @override
  String get checkInVisibilityPrivateSupport => '留给你自己。这件事不会传到任何人那里。';

  @override
  String get checkInVisibilityNoPartnerSupport => '现在还没有人可以一起看。';

  @override
  String checkInVisibilitySharedSupport(Object name) {
    return '$name 可以读到这段话。写出去之后就收不回来了。';
  }

  @override
  String get checkInSave => '存下来';

  @override
  String get checkInSaving => '正在存…';

  @override
  String get checkInSaveFailed => '没能送到服务器，什么都没存下来 —— 再试一次。';

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
  String get usConfirmingContext => '正在核对访问权限';

  @override
  String get usNotConfirmed => '访问权限还没核对上';

  @override
  String get usSoFar => '到目前为止';

  @override
  String get usSettings => '设置';

  @override
  String get usTryAgain => '再试一次';

  @override
  String get usCouldNotBeLoaded => '这些没能加载出来。你们的过往一件都没少。';

  @override
  String usConnectedDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '你们都在的日子，到现在是 $count 天。',
    );
    return '$_temp0';
  }

  @override
  String get usConnectedDaysSupport => '你们都做了点什么的那些天。app 自己做的事不算在里面。';

  @override
  String get usThisWeek => '这一周';

  @override
  String get usNothingYet => '这里还没有发生过什么。你们用起来它就会慢慢长出来 —— 没有什么落下的需要补。';

  @override
  String get usRecently => '最近';

  @override
  String get usSomeone => '有人';

  @override
  String usMomentCompletion(String name) {
    return '$name 做好了一件对方想请他做的事';
  }

  @override
  String usMomentAcknowledgement(String name) {
    return '$name 回应了';
  }

  @override
  String usMomentAdjustmentRequested(String name) {
    return '$name 想商量换个做法';
  }

  @override
  String get usMomentAdjustmentResolved => '你们把这件事商量好了';

  @override
  String usMomentCheckin(String name) {
    return '$name 说了说自己那天怎么样';
  }

  @override
  String usMomentMemberJoined(String name) {
    return '$name 来了';
  }

  @override
  String get usMomentUnknown => '发生了一件事';

  @override
  String get usPrivateSessionEnded => '私密会话已结束';

  @override
  String get usSessionNeedsRestoring => '你的私密会话\n需要重新打开。';

  @override
  String get usHistoryHidden => '你们一起走过的记录先藏起来了。\n重新登录一下，让我们知道还是你。';

  @override
  String get usSignInAgain => '重新登录';

  @override
  String get usNoProtectedContent => '这个页面上没有留下任何受保护的内容。';

  @override
  String get todayTitle => '今天';

  @override
  String get todayPrivate => '私密';

  @override
  String todayPresent(Object name) {
    return '$name 在';
  }

  @override
  String get todayLaterOptional => '稍后 / 可选';

  @override
  String todayDayEndsAt(Object clock) {
    return '你们的一天在 $clock 结束';
  }

  @override
  String todayFrom(Object name) {
    return '来自 $name';
  }

  @override
  String get todayNothingExpected => '今天没有交代你的事。';

  @override
  String get todayCheckInOffer => '想说说今天的话，随时可以。';

  @override
  String get todayCheckIn => '说说今天';

  @override
  String get stateOnToday => '今天';

  @override
  String get stateWaitingForReply => '等对方回应';

  @override
  String get stateNeedsReview => '过时间了，看一眼';

  @override
  String get stateBeingDiscussed => '在聊这件事';

  @override
  String get stateNewTimeRequested => '想换个时间';

  @override
  String get stateCantDoSent => '说了这次做不到';

  @override
  String get stateScheduled => '还没开始';

  @override
  String get kindRitual => '日常';

  @override
  String get kindExpectation => '约定';

  @override
  String get kindOnToday => '今天';

  @override
  String get ageJustNow => '刚刚';

  @override
  String ageMinutes(Object count) {
    return '$count 分钟前';
  }

  @override
  String ageHours(Object count) {
    return '$count 小时前';
  }

  @override
  String ageDays(Object count) {
    return '$count 天前';
  }

  @override
  String get actionSending => '正在发送';

  @override
  String get yourPartner => '对方';

  @override
  String todayResponseHeading(Object age, Object name) {
    return '$name 回应了 · $age';
  }

  @override
  String todayPriorityHeading(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '今天有 $count 件事',
    );
    return '$_temp0';
  }

  @override
  String get todayPriorityHeadingNone => '今天没有交代的事';

  @override
  String todayPrimaryEyebrow(String kind) {
    return '01 · 现在 · $kind';
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
  String get dynamicPartnerFallback => '对方';

  @override
  String get detailClose => '关闭';

  @override
  String get shellBack => '返回';

  @override
  String get activationBoundaryEyebrow => '哪些事不做';

  @override
  String get activationBoundaryQuestion => '有哪些事是不做的？';

  @override
  String get activationBoundarySupport => '只有你能写、能改自己这一份。对方看得到，但改不了。';

  @override
  String get activationBoundaryFootnote => '现在可以跳过，之后随时能加。';

  @override
  String get activationBoundaryAdd => '加一条';

  @override
  String get activationBoundaryHint => '当着别人的面做任何事';

  @override
  String get activationBoundaryNoteHint => '想让对方知道的话（可不填）';

  @override
  String get activationBoundaryEmpty => '还没写。';

  @override
  String get activationBoundarySave => '加上';

  @override
  String activationBoundaryRemove(String label) {
    return '删掉 $label';
  }

  @override
  String get activationBoundaryNeedsLabel => '先写清楚是哪件事。';

  @override
  String get activationBoundarySkip => '先跳过';

  @override
  String get boundaryStanceOff => '不做';

  @override
  String get boundaryStanceAsk => '先问我';

  @override
  String get boundaryStanceCurious => '可以聊聊';

  @override
  String get boundaryStanceOffDetail => '就是不做，不需要给理由。';

  @override
  String get boundaryStanceAskDetail => '可以，但要先跟我说。';

  @override
  String get boundaryStanceCuriousDetail => '愿意聊聊，但不等于答应。';

  @override
  String get boundaryTitle => '界限';

  @override
  String get boundaryYours => '你写的';

  @override
  String boundaryTheirs(String name) {
    return '$name 写的';
  }

  @override
  String get boundaryTheirsFallback => '对方写的';

  @override
  String get boundaryEmptyYours => '你还没写过。';

  @override
  String get boundaryEmptyTheirs => '对方还没写过。';

  @override
  String get boundaryTheirsReadOnly => '这些只有对方能改。';

  @override
  String get boundaryLoadFailed => '界限没加载出来。';

  @override
  String get settingsBoundariesSection => '界限';

  @override
  String get settingsBoundariesOpen => '界限';

  @override
  String get settingsBoundariesSupport => '只有你能改自己写的。对方看得到，但改不了。';

  @override
  String get pointsTitle => '积分';

  @override
  String pointsToSpend(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '可用 $count 分',
      one: '可用 1 分',
      zero: '还没有可用的',
    );
    return '$_temp0';
  }

  @override
  String get pointsNoneYet => '还没有记录。';

  @override
  String get pointsHistory => '发生了什么';

  @override
  String pointsEntryNoticed(String name) {
    return '$name 看到了';
  }

  @override
  String pointsEntryGave(String name, int count) {
    return '$name 给了你 $count 分';
  }

  @override
  String get pointsEntryTook => '你换了';

  @override
  String pointsEntryHeld(String name) {
    return '$name 让你照约定来';
  }

  @override
  String pointsEntryLetGo(String name) {
    return '$name 免了这一次';
  }

  @override
  String pointsEntryGift(String name) {
    return '$name 送给你的';
  }

  @override
  String get pointsGiveTitle => '给分';

  @override
  String get pointsGiveHint => '为什么？（可不填）';

  @override
  String get pointsGiveAction => '给';

  @override
  String get pointsTakeAction => '收回';

  @override
  String get pointsAmount => '多少';

  @override
  String get rewardsTitle => '奖励';

  @override
  String rewardsIntro(String name) {
    return '$name 可以送你的，你也可以用分换。';
  }

  @override
  String rewardsIntroSub(String name) {
    return '你可以用分换，$name 也可以直接送你。';
  }

  @override
  String get rewardsEmpty => '还没有放东西上来。';

  @override
  String rewardsCost(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 分',
      one: '1 分',
      zero: '不用分',
    );
    return '$_temp0';
  }

  @override
  String get rewardsTake => '换这个';

  @override
  String get rewardsGive => '送给他';

  @override
  String rewardsNotYet(int count) {
    return '还差 $count 分';
  }

  @override
  String get rewardsAdd => '加一个奖励';

  @override
  String get rewardsAddTitle => '是什么';

  @override
  String get rewardsAddHint => '一次按摩';

  @override
  String get rewardsAddDetail => '想让对方知道的（可不填）';

  @override
  String get rewardsAddCost => '换它要多少分';

  @override
  String rewardsRemove(String title) {
    return '把 $title 撤下来';
  }

  @override
  String get rewardsGivenByYou => '你送的。';

  @override
  String get rewardsNeedsTitle => '先写清楚是什么。';

  @override
  String get agreementsTitle => '你们的约定';

  @override
  String get agreementsIntro => '你们两个人事先一起写的。这里没有任何事会自动发生 —— 每一次都由你们其中一个人来决定。';

  @override
  String get agreementsEmpty => '还没有约定。';

  @override
  String get agreementsAdd => '加一条约定';

  @override
  String get agreementsWhen => '如果出现这种情况';

  @override
  String get agreementsWhenHint => '晚上的事没做';

  @override
  String get agreementsThen => '那么';

  @override
  String get agreementsThenHint => '第二天早睡一小时';

  @override
  String get agreementsCost => '要扣的分（可不填）';

  @override
  String agreementsEnd(String label) {
    return '结束「$label」';
  }

  @override
  String get agreementsEitherCanEnd => '你们任何一个人都可以单方面结束其中任何一条。';

  @override
  String get agreementsNeedsBoth => '把情况和后果都写上。';

  @override
  String get consequenceHeading => '你们约定过';

  @override
  String get consequenceHold => '就这么办';

  @override
  String get consequenceLetGo => '这次算了';

  @override
  String get consequenceTalk => '聊聊';

  @override
  String get consequenceNoteHint => '想说的话（可不填）';

  @override
  String consequenceHeld(String name) {
    return '$name 让你照约定来。';
  }

  @override
  String consequenceWaived(String name) {
    return '$name 免了这一次。';
  }

  @override
  String consequenceYouHeld(String name) {
    return '你让 $name 照约定来。';
  }

  @override
  String get consequenceYouWaived => '你免了这一次。';

  @override
  String get consequenceNothingHappens => '你不选，就什么都不会发生。';

  @override
  String get settingsPointsSection => '积分';

  @override
  String get settingsPointsOpen => '积分和奖励';

  @override
  String get settingsPointsSupport => '积分可以整个关掉。关了之后其他一切照旧。';

  @override
  String get settingsPointsEnabled => '使用积分';

  @override
  String get settingsPointsPerCompletion => '做好一件事得几分';

  @override
  String get navPoints => '分';

  @override
  String pointsDaysTogether(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '一起 $count 天',
      one: '一起 1 天',
      zero: '还没有开始',
    );
    return '$_temp0';
  }

  @override
  String get pointsDaysNeverResets => '这个数字只会往上走。安静的一天不会拿走任何东西。';

  @override
  String get consequenceChance => '交给运气';

  @override
  String get consequenceChanceNote => '运气决定是哪一条。是不是要罚，是你定的。';

  @override
  String get proofAdd => '加一张照片';

  @override
  String get proofAdded => '照片已附上';

  @override
  String get proofRemove => '去掉照片';

  @override
  String get proofOptional => '只有你想让对方看到时才加。';

  @override
  String get rewardsAddOpen => '放一个上来';

  @override
  String get rewardsAddCancel => '算了';

  @override
  String get rewardsAddSave => '放上去';

  @override
  String get agreementsAddOpen => '写一条约定';

  @override
  String get agreementsAddCancel => '算了';

  @override
  String get agreementsAddSave => '就这么定';

  @override
  String get pointsSpendable => '可用';

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
  String get todayProofPhotoNote => '照片';

  @override
  String get todayRefreshed => '已刷新。';

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
  String get sTodayPickTime => '选时间';

  @override
  String sTodayNewTimeAt(String time) {
    return '新时间：$time';
  }

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
  String get pointsEntryRefunded => '退回给你';

  @override
  String pointsEntryMoved(int amount) {
    return '$amount';
  }

  @override
  String settingsDayStart(String time) {
    return '一天从 $time 开始';
  }

  @override
  String get settingsDayStartReadOnly => '改这个要等下个版本。';

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
  String get recordCommentLabel => '你的一句';

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
    return '只在处置里由 $name 手动使用，这里不能执行。';
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
    return '$name 有 $n 分';
  }

  @override
  String ptsBalanceMine(int n) {
    return '$n 分';
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
  String ptsRedeemableEmpty(String name) {
    return '$name 还没定奖励。';
  }

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
  String get exploreCouldNotLoad => '没加载出来。';

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
}
