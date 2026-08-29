// GENERATED FROM manifests/assets.json AND manifests/svg-freeze.v1.json.
// DO NOT EDIT BY HAND.

enum DsAssetTone { primary, muted, authority, relationship, decorative }

final class DsAssetId {
  const DsAssetId._(this.id, this.path, this.allowedTones);

  final String id;
  final String path;
  final Set<DsAssetTone> allowedTones;
}

abstract final class DsAssets {
  static const markAuthority = DsAssetId._(
    'mark.authority',
    'assets/svg/mark-authority.svg',
    {DsAssetTone.primary, DsAssetTone.authority},
  );

  static const markPresence = DsAssetId._(
    'mark.presence',
    'assets/svg/mark-presence.svg',
    {DsAssetTone.primary, DsAssetTone.relationship},
  );

  static const markPartnerBond = DsAssetId._(
    'mark.partner-bond',
    'assets/svg/mark-partner-bond.svg',
    {DsAssetTone.primary, DsAssetTone.relationship},
  );

  static const markGuidance = DsAssetId._(
    'mark.guidance',
    'assets/svg/mark-guidance.svg',
    {DsAssetTone.primary, DsAssetTone.authority},
  );

  static const emblemRitualEvening = DsAssetId._(
    'emblem.ritual.evening',
    'assets/svg/emblem-ritual-evening.svg',
    {DsAssetTone.primary, DsAssetTone.muted},
  );

  static const navToday = DsAssetId._(
    'nav.today',
    'assets/svg/nav-today.svg',
    {DsAssetTone.primary, DsAssetTone.muted},
  );

  static const navDynamic = DsAssetId._(
    'nav.dynamic',
    'assets/svg/nav-dynamic.svg',
    {DsAssetTone.primary, DsAssetTone.muted},
  );

  static const navExplore = DsAssetId._(
    'nav.explore',
    'assets/svg/nav-explore.svg',
    {DsAssetTone.primary, DsAssetTone.muted},
  );

  static const navUs = DsAssetId._(
    'nav.us',
    'assets/svg/nav-us.svg',
    {DsAssetTone.primary, DsAssetTone.muted},
  );

  static const stateAcknowledged = DsAssetId._(
    'state.acknowledged',
    'assets/svg/state-acknowledged.svg',
    {DsAssetTone.primary, DsAssetTone.relationship},
  );

  static const stateCompleted = DsAssetId._(
    'state.completed',
    'assets/svg/state-completed.svg',
    {DsAssetTone.primary},
  );

  static const stateWaitingResponse = DsAssetId._(
    'state.waiting-response',
    'assets/svg/state-waiting-response.svg',
    {DsAssetTone.muted, DsAssetTone.relationship},
  );

  static const stateInviteAccepted = DsAssetId._(
    'state.invite-accepted',
    'assets/svg/state-invite-accepted.svg',
    {DsAssetTone.primary, DsAssetTone.relationship},
  );

  static const stateInviteExpired = DsAssetId._(
    'state.invite-expired',
    'assets/svg/state-invite-expired.svg',
    {DsAssetTone.primary, DsAssetTone.muted},
  );

  static const stateInviteRevoked = DsAssetId._(
    'state.invite-revoked',
    'assets/svg/state-invite-revoked.svg',
    {DsAssetTone.primary, DsAssetTone.muted},
  );

  static const stateAuthRestored = DsAssetId._(
    'state.auth-restored',
    'assets/svg/state-auth-restored.svg',
    {DsAssetTone.primary, DsAssetTone.authority},
  );

  static const stateLocked = DsAssetId._(
    'state.locked',
    'assets/svg/state-locked.svg',
    {DsAssetTone.primary, DsAssetTone.muted},
  );

  static const motifBotanicalGoalBranch = DsAssetId._(
    'motif.botanical.goal-branch',
    'assets/svg/motif-botanical-goal-branch.svg',
    {DsAssetTone.decorative},
  );

  static const iconTimezone = DsAssetId._(
    'icon.timezone',
    'assets/svg/icon-timezone.svg',
    {DsAssetTone.primary, DsAssetTone.muted},
  );

  static const iconBoundaries = DsAssetId._(
    'icon.boundaries',
    'assets/svg/icon-boundaries.svg',
    {DsAssetTone.primary, DsAssetTone.muted},
  );

  static const markCheckIn = DsAssetId._(
    'mark.check-in',
    'assets/svg/mark-check-in.svg',
    {DsAssetTone.primary, DsAssetTone.muted},
  );

  static const iconShare = DsAssetId._(
    'icon.share',
    'assets/svg/icon-share.svg',
    {DsAssetTone.primary},
  );

  static const iconCopy = DsAssetId._(
    'icon.copy',
    'assets/svg/icon-copy.svg',
    {DsAssetTone.primary, DsAssetTone.muted},
  );

  static const iconRevoke = DsAssetId._(
    'icon.revoke',
    'assets/svg/icon-revoke.svg',
    {DsAssetTone.primary, DsAssetTone.muted},
  );

  static const iconSharedSpace = DsAssetId._(
    'icon.shared-space',
    'assets/svg/icon-shared-space.svg',
    {DsAssetTone.primary, DsAssetTone.muted},
  );

  static const iconPrivateSpace = DsAssetId._(
    'icon.private-space',
    'assets/svg/icon-private-space.svg',
    {DsAssetTone.primary, DsAssetTone.muted},
  );

  static const iconLeaveRight = DsAssetId._(
    'icon.leave-right',
    'assets/svg/icon-leave-right.svg',
    {DsAssetTone.primary, DsAssetTone.muted},
  );

  static const responseAcknowledge = DsAssetId._(
    'response.acknowledge',
    'assets/svg/response-acknowledge.svg',
    {DsAssetTone.muted, DsAssetTone.relationship},
  );

  static const responsePraise = DsAssetId._(
    'response.praise',
    'assets/svg/response-praise.svg',
    {DsAssetTone.muted, DsAssetTone.relationship},
  );

  static const responseComment = DsAssetId._(
    'response.comment',
    'assets/svg/response-comment.svg',
    {DsAssetTone.muted, DsAssetTone.relationship},
  );

  static const responseReview = DsAssetId._(
    'response.review',
    'assets/svg/response-review.svg',
    {DsAssetTone.muted, DsAssetTone.relationship},
  );

  static const motifBotanicalInviteBranch = DsAssetId._(
    'motif.botanical.invite-branch',
    'assets/svg/motif-botanical-invite-branch.svg',
    {DsAssetTone.decorative},
  );

  static const motifBotanicalNoteSprig = DsAssetId._(
    'motif.botanical.note-sprig',
    'assets/svg/motif-botanical-note-sprig.svg',
    {DsAssetTone.decorative},
  );

  static const all = <DsAssetId>[
    markAuthority,
    markPresence,
    markPartnerBond,
    markGuidance,
    emblemRitualEvening,
    navToday,
    navDynamic,
    navExplore,
    navUs,
    stateAcknowledged,
    stateCompleted,
    stateWaitingResponse,
    stateInviteAccepted,
    stateInviteExpired,
    stateInviteRevoked,
    stateAuthRestored,
    stateLocked,
    motifBotanicalGoalBranch,
    iconTimezone,
    iconBoundaries,
    markCheckIn,
    iconShare,
    iconCopy,
    iconRevoke,
    iconSharedSpace,
    iconPrivateSpace,
    iconLeaveRight,
    responseAcknowledge,
    responsePraise,
    responseComment,
    responseReview,
    motifBotanicalInviteBranch,
    motifBotanicalNoteSprig,
  ];

  static DsAssetId byId(String id) => all.singleWhere((asset) => asset.id == id);
}

abstract final class DsTextureAssets {
  static const ritualGrain = 'assets/textures/ritual-grain-128.png';
}
