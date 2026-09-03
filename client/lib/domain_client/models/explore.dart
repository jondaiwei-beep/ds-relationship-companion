import 'package:freezed_annotation/freezed_annotation.dart';

part 'explore.freezed.dart';
part 'explore.g.dart';

/// Explore (product/04-explore.md): preference compare, idea cards, starter
/// packs. Content ships in both languages and the client picks by locale —
/// the server never knows which one a person reads.
String pickLang(String locale, String zh, String en) => locale.startsWith('zh') ? zh : en;

String? pickLangOrNull(String locale, String? zh, String? en) => locale.startsWith('zh') ? zh : en;

/// The four answers a person can give to one item. Stored as the server's
/// strings; there is no fifth.
const preferenceAnswers = <String>['want', 'ok', 'no', 'talk'];

/// One question in the library, with only *my* answer. The partner's answer
/// is never in this view — it only exists in [CompareView], and only once
/// both have answered.
@freezed
abstract class PreferenceItem with _$PreferenceItem {
  const PreferenceItem._();

  const factory PreferenceItem({
    required String id,
    required String group,
    required String titleZh,
    required String titleEn,
    String? detailZh,
    String? detailEn,
    @Default(false) bool custom,
    String? myAnswer,
  }) = _PreferenceItem;

  factory PreferenceItem.fromJson(Map<String, dynamic> json) => _$PreferenceItemFromJson(json);

  String title(String locale) => pickLang(locale, titleZh, titleEn);
  String? detail(String locale) => pickLangOrNull(locale, detailZh, detailEn);
}

/// One row of the compare. [wantSide] is present only in the 一个想要、一个可以
/// bucket; the 不要 bucket carries nothing but a title — by contract.
@freezed
abstract class CompareItem with _$CompareItem {
  const factory CompareItem({
    required String itemId,
    required String title,
    String? wantSide,
  }) = _CompareItem;

  factory CompareItem.fromJson(Map<String, dynamic> json) => _$CompareItemFromJson(json);
}

@freezed
abstract class CompareView with _$CompareView {
  const CompareView._();

  const factory CompareView({
    @Default(false) bool partnerAnswered,
    @Default(<CompareItem>[]) List<CompareItem> bothWant,
    @Default(<CompareItem>[]) List<CompareItem> wantAndOk,
    @Default(<CompareItem>[]) List<CompareItem> someoneTalks,
    @Default(<CompareItem>[]) List<CompareItem> notDoing,
  }) = _CompareView;

  factory CompareView.fromJson(Map<String, dynamic> json) => _$CompareViewFromJson(json);

  bool get isEmpty => bothWant.isEmpty && wantAndOk.isEmpty && someoneTalks.isEmpty && notDoing.isEmpty;
}

/// One playable idea. `state` is the pair's mark on it: saved / tried_again /
/// tried_never, or null when untouched.
@freezed
abstract class IdeaCard with _$IdeaCard {
  const IdeaCard._();

  const factory IdeaCard({
    required String id,
    required String audience,
    required String titleZh,
    required String titleEn,
    required String howZh,
    required String howEn,
    String? needsZh,
    String? needsEn,
    @Default(1) int intensity,
    @Default(<String>[]) List<String> tags,
    @Default(<String>[]) List<String> relatedItemIds,
    String? state,
  }) = _IdeaCard;

  factory IdeaCard.fromJson(Map<String, dynamic> json) => _$IdeaCardFromJson(json);

  String title(String locale) => pickLang(locale, titleZh, titleEn);
  String how(String locale) => pickLang(locale, howZh, howEn);
  String? needs(String locale) => pickLangOrNull(locale, needsZh, needsEn);
  bool get tried => state == 'tried_again' || state == 'tried_never';
}

/// The verbs the server accepts on a card (IdeaCardService.act).
abstract final class IdeaCardAction {
  static const addToday = 'add_today';
  static const addRule = 'add_rule';
  static const save = 'save';
  static const triedAgain = 'tried_again';
  static const triedNever = 'tried_never';
}

@freezed
abstract class IdeaCardActResult with _$IdeaCardActResult {
  const factory IdeaCardActResult({
    String? taskId,
    String? ruleId,
    String? noteId,
    String? state,
  }) = _IdeaCardActResult;

  factory IdeaCardActResult.fromJson(Map<String, dynamic> json) => _$IdeaCardActResultFromJson(json);
}

// ── starter packs ──────────────────────────────────────────────────────────

@freezed
abstract class StarterPackTask with _$StarterPackTask {
  const StarterPackTask._();

  const factory StarterPackTask({
    required String titleZh,
    required String titleEn,
    @Default('checkin') String kind,
    Map<String, dynamic>? schedule,
    String? dueTime,
    @Default('check') String proof,
    @Default(0) int pointsEarn,
  }) = _StarterPackTask;

  factory StarterPackTask.fromJson(Map<String, dynamic> json) => _$StarterPackTaskFromJson(json);

  String title(String locale) => pickLang(locale, titleZh, titleEn);
}

@freezed
abstract class StarterPackRule with _$StarterPackRule {
  const StarterPackRule._();

  const factory StarterPackRule({
    required String titleZh,
    required String titleEn,
    String? bodyZh,
    String? bodyEn,
    @Default('other') String group,
  }) = _StarterPackRule;

  factory StarterPackRule.fromJson(Map<String, dynamic> json) => _$StarterPackRuleFromJson(json);

  String title(String locale) => pickLang(locale, titleZh, titleEn);
  String? body(String locale) => pickLangOrNull(locale, bodyZh, bodyEn);
}

@freezed
abstract class StarterPackReward with _$StarterPackReward {
  const StarterPackReward._();

  const factory StarterPackReward({
    required String titleZh,
    required String titleEn,
    int? cost,
  }) = _StarterPackReward;

  factory StarterPackReward.fromJson(Map<String, dynamic> json) => _$StarterPackRewardFromJson(json);

  String title(String locale) => pickLang(locale, titleZh, titleEn);
}

@freezed
abstract class StarterPack with _$StarterPack {
  const StarterPack._();

  const factory StarterPack({
    required String id,
    required String titleZh,
    required String titleEn,
    @Default(<StarterPackTask>[]) List<StarterPackTask> tasks,
    @Default(<StarterPackRule>[]) List<StarterPackRule> rules,
    @Default(<StarterPackReward>[]) List<StarterPackReward> rewards,
  }) = _StarterPack;

  factory StarterPack.fromJson(Map<String, dynamic> json) => _$StarterPackFromJson(json);

  String title(String locale) => pickLang(locale, titleZh, titleEn);

  /// The pack as a draft in one language, ready to be edited line by line.
  PackDraft draft(String locale) => PackDraft(
        tasks: [
          for (final t in tasks)
            DraftTask(
              title: t.title(locale),
              kind: t.kind,
              schedule: t.schedule,
              dueTime: t.dueTime,
              proof: t.proof,
              pointsEarn: t.pointsEarn,
            ),
        ],
        rules: [
          for (final r in rules) DraftRule(title: r.title(locale), body: r.body(locale), group: r.group),
        ],
        rewards: [for (final w in rewards) DraftReward(title: w.title(locale), cost: w.cost)],
      );
}

/// What actually gets created: only what the person left in. The server
/// creates exactly these lines and re-reads nothing from the static pack.
@freezed
abstract class DraftTask with _$DraftTask {
  const factory DraftTask({
    required String title,
    String? detail,
    @Default('checkin') String kind,
    Map<String, dynamic>? schedule,
    String? dueTime,
    @Default('check') String proof,
    @Default(0) int pointsEarn,
  }) = _DraftTask;

  factory DraftTask.fromJson(Map<String, dynamic> json) => _$DraftTaskFromJson(json);
}

@freezed
abstract class DraftRule with _$DraftRule {
  const factory DraftRule({
    required String title,
    String? body,
    @Default('other') String group,
  }) = _DraftRule;

  factory DraftRule.fromJson(Map<String, dynamic> json) => _$DraftRuleFromJson(json);
}

@freezed
abstract class DraftReward with _$DraftReward {
  const factory DraftReward({
    required String title,
    String? detail,
    int? cost,
  }) = _DraftReward;

  factory DraftReward.fromJson(Map<String, dynamic> json) => _$DraftRewardFromJson(json);
}

@freezed
abstract class PackDraft with _$PackDraft {
  const PackDraft._();

  const factory PackDraft({
    @Default(<DraftTask>[]) List<DraftTask> tasks,
    @Default(<DraftRule>[]) List<DraftRule> rules,
    @Default(<DraftReward>[]) List<DraftReward> rewards,
  }) = _PackDraft;

  factory PackDraft.fromJson(Map<String, dynamic> json) => _$PackDraftFromJson(json);

  bool get isEmpty => tasks.isEmpty && rules.isEmpty && rewards.isEmpty;
}

@freezed
abstract class PackApplyResult with _$PackApplyResult {
  const factory PackApplyResult({
    @Default(<String>[]) List<String> taskIds,
    @Default(<String>[]) List<String> ruleIds,
    @Default(<String>[]) List<String> rewardIds,
  }) = _PackApplyResult;

  factory PackApplyResult.fromJson(Map<String, dynamic> json) => _$PackApplyResultFromJson(json);
}
