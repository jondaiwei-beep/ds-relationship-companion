import 'package:dsapp/domain_client/models/explore.dart';
import 'package:dsapp/domain_client/repositories/explore_repository.dart';

/// A small library across two groups, none answered yet.
const fakeItems = [
  PreferenceItem(id: 'p-1', group: '服务与仪式', titleZh: '早安问安', titleEn: 'Morning greeting'),
  PreferenceItem(id: 'p-2', group: '服务与仪式', titleZh: '进门先跪', titleEn: 'Kneel at the door', myAnswer: 'ok'),
  PreferenceItem(id: 'p-3', group: '感官', titleZh: '蒙眼', titleEn: 'Blindfold'),
];

const fakeCompare = CompareView(
  partnerAnswered: true,
  bothWant: [CompareItem(itemId: 'p-1', title: '早安问安')],
  wantAndOk: [CompareItem(itemId: 'p-2', title: '进门先跪', wantSide: 'D')],
  someoneTalks: [CompareItem(itemId: 'p-4', title: '公开场合的称呼')],
  notDoing: [CompareItem(itemId: 'p-3', title: '蒙眼')],
);

const fakeCards = [
  IdeaCard(
    id: 'c-1',
    audience: 'for_d',
    titleZh: '今晚的三句话',
    titleEn: 'Three lines tonight',
    howZh: '睡前让对方说三句今天做到的事。',
    howEn: 'Before bed, have them name three things they did today.',
    intensity: 1,
  ),
  IdeaCard(
    id: 'c-2',
    audience: 'for_both',
    titleZh: '换个称呼一天',
    titleEn: 'A new name for a day',
    howZh: '一天里只用约定的称呼。',
    howEn: 'For one day, only the agreed name.',
    needsZh: '一天',
    needsEn: 'A day',
    intensity: 2,
    state: 'tried_again',
  ),
];

const fakePacks = [
  StarterPack(
    id: 'daily-greeting',
    titleZh: '日常问安',
    titleEn: 'Daily greeting',
    tasks: [
      StarterPackTask(titleZh: '早安汇报', titleEn: 'Morning report', kind: 'recurring', schedule: {'type': 'daily'}),
      StarterPackTask(titleZh: '晚安汇报', titleEn: 'Evening report', kind: 'recurring', schedule: {'type': 'daily'}),
    ],
    rules: [StarterPackRule(titleZh: '称呼要用「主人」', titleEn: 'Address as "Sir"', group: 'protocol')],
    rewards: [StarterPackReward(titleZh: '一起看电影', titleEn: 'A film together', cost: 20)],
  ),
];

class FakeExploreRepository implements ExploreRepository {
  FakeExploreRepository({
    List<PreferenceItem>? items,
    CompareView? compare,
    List<IdeaCard>? cards,
    List<StarterPack>? packs,
    this.drawn,
  })  : _items = items ?? fakeItems,
        _compare = compare ?? const CompareView(),
        _cards = cards ?? fakeCards,
        _packs = packs ?? fakePacks;

  List<PreferenceItem> _items;
  final CompareView _compare;
  final List<IdeaCard> _cards;
  final List<StarterPack> _packs;
  final IdeaCard? drawn;

  /// (itemId, answer) in the order tapped.
  final answers = <(String, String)>[];

  /// (cardId, action) in the order acted.
  final acts = <(String, String)>[];
  final applied = <(String, PackDraft)>[];
  int draws = 0;

  @override
  Future<List<PreferenceItem>> items(String dynamicId) async => _items;

  @override
  Future<PreferenceItem> answer(String dynamicId, String itemId, String answer) async {
    answers.add((itemId, answer));
    _items = [for (final i in _items) i.id == itemId ? i.copyWith(myAnswer: answer) : i];
    return _items.firstWhere((i) => i.id == itemId);
  }

  @override
  Future<PreferenceItem> addCustom(
    String dynamicId, {
    required String group,
    required String title,
    String? detail,
    required String idempotencyKey,
  }) async {
    final item = PreferenceItem(id: 'custom-${_items.length}', group: group, titleZh: title, titleEn: title, custom: true);
    _items = [..._items, item];
    return item;
  }

  @override
  Future<CompareView> compare(String dynamicId) async => _compare;

  @override
  Future<List<IdeaCard>> cards(String dynamicId, {String? audience}) async =>
      audience == null ? _cards : _cards.where((c) => c.audience == audience).toList();

  @override
  Future<IdeaCard> draw(String dynamicId, {required String idempotencyKey}) async {
    draws++;
    return drawn ?? _cards.first;
  }

  @override
  Future<IdeaCardActResult> act(String dynamicId, String cardId, String action, {required String idempotencyKey}) async {
    acts.add((cardId, action));
    return IdeaCardActResult(state: action == 'save' ? 'saved' : null);
  }

  @override
  Future<List<StarterPack>> packs() async => _packs;

  @override
  Future<PackApplyResult> applyPack(String dynamicId, String packId, PackDraft draft, {required String idempotencyKey}) async {
    applied.add((packId, draft));
    return const PackApplyResult();
  }
}
