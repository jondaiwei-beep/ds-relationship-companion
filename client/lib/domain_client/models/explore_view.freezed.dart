// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'explore_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ExploreIdea {

 String get id; String get kind; String get title;/// Why it matters — what makes it a request rather than a chore.
 String get purpose;/// What it looks like in practice.
 String get detail; String get collectionId;
/// Create a copy of ExploreIdea
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExploreIdeaCopyWith<ExploreIdea> get copyWith => _$ExploreIdeaCopyWithImpl<ExploreIdea>(this as ExploreIdea, _$identity);

  /// Serializes this ExploreIdea to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExploreIdea&&(identical(other.id, id) || other.id == id)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.title, title) || other.title == title)&&(identical(other.purpose, purpose) || other.purpose == purpose)&&(identical(other.detail, detail) || other.detail == detail)&&(identical(other.collectionId, collectionId) || other.collectionId == collectionId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,kind,title,purpose,detail,collectionId);

@override
String toString() {
  return 'ExploreIdea(id: $id, kind: $kind, title: $title, purpose: $purpose, detail: $detail, collectionId: $collectionId)';
}


}

/// @nodoc
abstract mixin class $ExploreIdeaCopyWith<$Res>  {
  factory $ExploreIdeaCopyWith(ExploreIdea value, $Res Function(ExploreIdea) _then) = _$ExploreIdeaCopyWithImpl;
@useResult
$Res call({
 String id, String kind, String title, String purpose, String detail, String collectionId
});




}
/// @nodoc
class _$ExploreIdeaCopyWithImpl<$Res>
    implements $ExploreIdeaCopyWith<$Res> {
  _$ExploreIdeaCopyWithImpl(this._self, this._then);

  final ExploreIdea _self;
  final $Res Function(ExploreIdea) _then;

/// Create a copy of ExploreIdea
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? kind = null,Object? title = null,Object? purpose = null,Object? detail = null,Object? collectionId = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,purpose: null == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as String,detail: null == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String,collectionId: null == collectionId ? _self.collectionId : collectionId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ExploreIdea].
extension ExploreIdeaPatterns on ExploreIdea {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExploreIdea value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExploreIdea() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExploreIdea value)  $default,){
final _that = this;
switch (_that) {
case _ExploreIdea():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExploreIdea value)?  $default,){
final _that = this;
switch (_that) {
case _ExploreIdea() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String kind,  String title,  String purpose,  String detail,  String collectionId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExploreIdea() when $default != null:
return $default(_that.id,_that.kind,_that.title,_that.purpose,_that.detail,_that.collectionId);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String kind,  String title,  String purpose,  String detail,  String collectionId)  $default,) {final _that = this;
switch (_that) {
case _ExploreIdea():
return $default(_that.id,_that.kind,_that.title,_that.purpose,_that.detail,_that.collectionId);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String kind,  String title,  String purpose,  String detail,  String collectionId)?  $default,) {final _that = this;
switch (_that) {
case _ExploreIdea() when $default != null:
return $default(_that.id,_that.kind,_that.title,_that.purpose,_that.detail,_that.collectionId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExploreIdea implements ExploreIdea {
  const _ExploreIdea({required this.id, required this.kind, required this.title, required this.purpose, required this.detail, required this.collectionId});
  factory _ExploreIdea.fromJson(Map<String, dynamic> json) => _$ExploreIdeaFromJson(json);

@override final  String id;
@override final  String kind;
@override final  String title;
/// Why it matters — what makes it a request rather than a chore.
@override final  String purpose;
/// What it looks like in practice.
@override final  String detail;
@override final  String collectionId;

/// Create a copy of ExploreIdea
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExploreIdeaCopyWith<_ExploreIdea> get copyWith => __$ExploreIdeaCopyWithImpl<_ExploreIdea>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExploreIdeaToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExploreIdea&&(identical(other.id, id) || other.id == id)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.title, title) || other.title == title)&&(identical(other.purpose, purpose) || other.purpose == purpose)&&(identical(other.detail, detail) || other.detail == detail)&&(identical(other.collectionId, collectionId) || other.collectionId == collectionId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,kind,title,purpose,detail,collectionId);

@override
String toString() {
  return 'ExploreIdea(id: $id, kind: $kind, title: $title, purpose: $purpose, detail: $detail, collectionId: $collectionId)';
}


}

/// @nodoc
abstract mixin class _$ExploreIdeaCopyWith<$Res> implements $ExploreIdeaCopyWith<$Res> {
  factory _$ExploreIdeaCopyWith(_ExploreIdea value, $Res Function(_ExploreIdea) _then) = __$ExploreIdeaCopyWithImpl;
@override @useResult
$Res call({
 String id, String kind, String title, String purpose, String detail, String collectionId
});




}
/// @nodoc
class __$ExploreIdeaCopyWithImpl<$Res>
    implements _$ExploreIdeaCopyWith<$Res> {
  __$ExploreIdeaCopyWithImpl(this._self, this._then);

  final _ExploreIdea _self;
  final $Res Function(_ExploreIdea) _then;

/// Create a copy of ExploreIdea
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? kind = null,Object? title = null,Object? purpose = null,Object? detail = null,Object? collectionId = null,}) {
  return _then(_ExploreIdea(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,purpose: null == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as String,detail: null == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String,collectionId: null == collectionId ? _self.collectionId : collectionId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ExploreCollection {

 String get id; String get title; String get blurb;
/// Create a copy of ExploreCollection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExploreCollectionCopyWith<ExploreCollection> get copyWith => _$ExploreCollectionCopyWithImpl<ExploreCollection>(this as ExploreCollection, _$identity);

  /// Serializes this ExploreCollection to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExploreCollection&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.blurb, blurb) || other.blurb == blurb));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,blurb);

@override
String toString() {
  return 'ExploreCollection(id: $id, title: $title, blurb: $blurb)';
}


}

/// @nodoc
abstract mixin class $ExploreCollectionCopyWith<$Res>  {
  factory $ExploreCollectionCopyWith(ExploreCollection value, $Res Function(ExploreCollection) _then) = _$ExploreCollectionCopyWithImpl;
@useResult
$Res call({
 String id, String title, String blurb
});




}
/// @nodoc
class _$ExploreCollectionCopyWithImpl<$Res>
    implements $ExploreCollectionCopyWith<$Res> {
  _$ExploreCollectionCopyWithImpl(this._self, this._then);

  final ExploreCollection _self;
  final $Res Function(ExploreCollection) _then;

/// Create a copy of ExploreCollection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? blurb = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,blurb: null == blurb ? _self.blurb : blurb // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ExploreCollection].
extension ExploreCollectionPatterns on ExploreCollection {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExploreCollection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExploreCollection() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExploreCollection value)  $default,){
final _that = this;
switch (_that) {
case _ExploreCollection():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExploreCollection value)?  $default,){
final _that = this;
switch (_that) {
case _ExploreCollection() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String blurb)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExploreCollection() when $default != null:
return $default(_that.id,_that.title,_that.blurb);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String blurb)  $default,) {final _that = this;
switch (_that) {
case _ExploreCollection():
return $default(_that.id,_that.title,_that.blurb);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String blurb)?  $default,) {final _that = this;
switch (_that) {
case _ExploreCollection() when $default != null:
return $default(_that.id,_that.title,_that.blurb);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExploreCollection implements ExploreCollection {
  const _ExploreCollection({required this.id, required this.title, required this.blurb});
  factory _ExploreCollection.fromJson(Map<String, dynamic> json) => _$ExploreCollectionFromJson(json);

@override final  String id;
@override final  String title;
@override final  String blurb;

/// Create a copy of ExploreCollection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExploreCollectionCopyWith<_ExploreCollection> get copyWith => __$ExploreCollectionCopyWithImpl<_ExploreCollection>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExploreCollectionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExploreCollection&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.blurb, blurb) || other.blurb == blurb));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,blurb);

@override
String toString() {
  return 'ExploreCollection(id: $id, title: $title, blurb: $blurb)';
}


}

/// @nodoc
abstract mixin class _$ExploreCollectionCopyWith<$Res> implements $ExploreCollectionCopyWith<$Res> {
  factory _$ExploreCollectionCopyWith(_ExploreCollection value, $Res Function(_ExploreCollection) _then) = __$ExploreCollectionCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String blurb
});




}
/// @nodoc
class __$ExploreCollectionCopyWithImpl<$Res>
    implements _$ExploreCollectionCopyWith<$Res> {
  __$ExploreCollectionCopyWithImpl(this._self, this._then);

  final _ExploreCollection _self;
  final $Res Function(_ExploreCollection) _then;

/// Create a copy of ExploreCollection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? blurb = null,}) {
  return _then(_ExploreCollection(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,blurb: null == blurb ? _self.blurb : blurb // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ExploreLibraryView {

 List<ExploreCollection> get collections; List<ExploreIdea> get ideas;
/// Create a copy of ExploreLibraryView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExploreLibraryViewCopyWith<ExploreLibraryView> get copyWith => _$ExploreLibraryViewCopyWithImpl<ExploreLibraryView>(this as ExploreLibraryView, _$identity);

  /// Serializes this ExploreLibraryView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExploreLibraryView&&const DeepCollectionEquality().equals(other.collections, collections)&&const DeepCollectionEquality().equals(other.ideas, ideas));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(collections),const DeepCollectionEquality().hash(ideas));

@override
String toString() {
  return 'ExploreLibraryView(collections: $collections, ideas: $ideas)';
}


}

/// @nodoc
abstract mixin class $ExploreLibraryViewCopyWith<$Res>  {
  factory $ExploreLibraryViewCopyWith(ExploreLibraryView value, $Res Function(ExploreLibraryView) _then) = _$ExploreLibraryViewCopyWithImpl;
@useResult
$Res call({
 List<ExploreCollection> collections, List<ExploreIdea> ideas
});




}
/// @nodoc
class _$ExploreLibraryViewCopyWithImpl<$Res>
    implements $ExploreLibraryViewCopyWith<$Res> {
  _$ExploreLibraryViewCopyWithImpl(this._self, this._then);

  final ExploreLibraryView _self;
  final $Res Function(ExploreLibraryView) _then;

/// Create a copy of ExploreLibraryView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? collections = null,Object? ideas = null,}) {
  return _then(_self.copyWith(
collections: null == collections ? _self.collections : collections // ignore: cast_nullable_to_non_nullable
as List<ExploreCollection>,ideas: null == ideas ? _self.ideas : ideas // ignore: cast_nullable_to_non_nullable
as List<ExploreIdea>,
  ));
}

}


/// Adds pattern-matching-related methods to [ExploreLibraryView].
extension ExploreLibraryViewPatterns on ExploreLibraryView {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExploreLibraryView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExploreLibraryView() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExploreLibraryView value)  $default,){
final _that = this;
switch (_that) {
case _ExploreLibraryView():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExploreLibraryView value)?  $default,){
final _that = this;
switch (_that) {
case _ExploreLibraryView() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ExploreCollection> collections,  List<ExploreIdea> ideas)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExploreLibraryView() when $default != null:
return $default(_that.collections,_that.ideas);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ExploreCollection> collections,  List<ExploreIdea> ideas)  $default,) {final _that = this;
switch (_that) {
case _ExploreLibraryView():
return $default(_that.collections,_that.ideas);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ExploreCollection> collections,  List<ExploreIdea> ideas)?  $default,) {final _that = this;
switch (_that) {
case _ExploreLibraryView() when $default != null:
return $default(_that.collections,_that.ideas);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExploreLibraryView implements ExploreLibraryView {
  const _ExploreLibraryView({final  List<ExploreCollection> collections = const <ExploreCollection>[], final  List<ExploreIdea> ideas = const <ExploreIdea>[]}): _collections = collections,_ideas = ideas;
  factory _ExploreLibraryView.fromJson(Map<String, dynamic> json) => _$ExploreLibraryViewFromJson(json);

 final  List<ExploreCollection> _collections;
@override@JsonKey() List<ExploreCollection> get collections {
  if (_collections is EqualUnmodifiableListView) return _collections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_collections);
}

 final  List<ExploreIdea> _ideas;
@override@JsonKey() List<ExploreIdea> get ideas {
  if (_ideas is EqualUnmodifiableListView) return _ideas;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ideas);
}


/// Create a copy of ExploreLibraryView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExploreLibraryViewCopyWith<_ExploreLibraryView> get copyWith => __$ExploreLibraryViewCopyWithImpl<_ExploreLibraryView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExploreLibraryViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExploreLibraryView&&const DeepCollectionEquality().equals(other._collections, _collections)&&const DeepCollectionEquality().equals(other._ideas, _ideas));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_collections),const DeepCollectionEquality().hash(_ideas));

@override
String toString() {
  return 'ExploreLibraryView(collections: $collections, ideas: $ideas)';
}


}

/// @nodoc
abstract mixin class _$ExploreLibraryViewCopyWith<$Res> implements $ExploreLibraryViewCopyWith<$Res> {
  factory _$ExploreLibraryViewCopyWith(_ExploreLibraryView value, $Res Function(_ExploreLibraryView) _then) = __$ExploreLibraryViewCopyWithImpl;
@override @useResult
$Res call({
 List<ExploreCollection> collections, List<ExploreIdea> ideas
});




}
/// @nodoc
class __$ExploreLibraryViewCopyWithImpl<$Res>
    implements _$ExploreLibraryViewCopyWith<$Res> {
  __$ExploreLibraryViewCopyWithImpl(this._self, this._then);

  final _ExploreLibraryView _self;
  final $Res Function(_ExploreLibraryView) _then;

/// Create a copy of ExploreLibraryView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? collections = null,Object? ideas = null,}) {
  return _then(_ExploreLibraryView(
collections: null == collections ? _self._collections : collections // ignore: cast_nullable_to_non_nullable
as List<ExploreCollection>,ideas: null == ideas ? _self._ideas : ideas // ignore: cast_nullable_to_non_nullable
as List<ExploreIdea>,
  ));
}


}

// dart format on
