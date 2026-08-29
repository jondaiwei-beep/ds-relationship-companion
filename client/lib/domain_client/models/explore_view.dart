import 'package:freezed_annotation/freezed_annotation.dart';

part 'explore_view.freezed.dart';
part 'explore_view.g.dart';

/// One idea from the reviewed library.
@freezed
abstract class ExploreIdea with _$ExploreIdea {
  const factory ExploreIdea({
    required String id,
    required String kind,
    required String title,
    /// Why it matters — what makes it a request rather than a chore.
    required String purpose,
    /// What it looks like in practice.
    required String detail,
    required String collectionId,
  }) = _ExploreIdea;

  factory ExploreIdea.fromJson(Map<String, dynamic> json) =>
      _$ExploreIdeaFromJson(json);
}

@freezed
abstract class ExploreCollection with _$ExploreCollection {
  const factory ExploreCollection({
    required String id,
    required String title,
    required String blurb,
  }) = _ExploreCollection;

  factory ExploreCollection.fromJson(Map<String, dynamic> json) =>
      _$ExploreCollectionFromJson(json);
}

@freezed
abstract class ExploreLibraryView with _$ExploreLibraryView {
  const factory ExploreLibraryView({
    @Default(<ExploreCollection>[]) List<ExploreCollection> collections,
    @Default(<ExploreIdea>[]) List<ExploreIdea> ideas,
  }) = _ExploreLibraryView;

  factory ExploreLibraryView.fromJson(Map<String, dynamic> json) =>
      _$ExploreLibraryViewFromJson(json);
}
