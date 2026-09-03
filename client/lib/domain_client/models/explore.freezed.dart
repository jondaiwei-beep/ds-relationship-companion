// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'explore.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PreferenceItem {

 String get id; String get group; String get titleZh; String get titleEn; String? get detailZh; String? get detailEn; bool get custom; String? get myAnswer;
/// Create a copy of PreferenceItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PreferenceItemCopyWith<PreferenceItem> get copyWith => _$PreferenceItemCopyWithImpl<PreferenceItem>(this as PreferenceItem, _$identity);

  /// Serializes this PreferenceItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PreferenceItem&&(identical(other.id, id) || other.id == id)&&(identical(other.group, group) || other.group == group)&&(identical(other.titleZh, titleZh) || other.titleZh == titleZh)&&(identical(other.titleEn, titleEn) || other.titleEn == titleEn)&&(identical(other.detailZh, detailZh) || other.detailZh == detailZh)&&(identical(other.detailEn, detailEn) || other.detailEn == detailEn)&&(identical(other.custom, custom) || other.custom == custom)&&(identical(other.myAnswer, myAnswer) || other.myAnswer == myAnswer));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,group,titleZh,titleEn,detailZh,detailEn,custom,myAnswer);

@override
String toString() {
  return 'PreferenceItem(id: $id, group: $group, titleZh: $titleZh, titleEn: $titleEn, detailZh: $detailZh, detailEn: $detailEn, custom: $custom, myAnswer: $myAnswer)';
}


}

/// @nodoc
abstract mixin class $PreferenceItemCopyWith<$Res>  {
  factory $PreferenceItemCopyWith(PreferenceItem value, $Res Function(PreferenceItem) _then) = _$PreferenceItemCopyWithImpl;
@useResult
$Res call({
 String id, String group, String titleZh, String titleEn, String? detailZh, String? detailEn, bool custom, String? myAnswer
});




}
/// @nodoc
class _$PreferenceItemCopyWithImpl<$Res>
    implements $PreferenceItemCopyWith<$Res> {
  _$PreferenceItemCopyWithImpl(this._self, this._then);

  final PreferenceItem _self;
  final $Res Function(PreferenceItem) _then;

/// Create a copy of PreferenceItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? group = null,Object? titleZh = null,Object? titleEn = null,Object? detailZh = freezed,Object? detailEn = freezed,Object? custom = null,Object? myAnswer = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,group: null == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as String,titleZh: null == titleZh ? _self.titleZh : titleZh // ignore: cast_nullable_to_non_nullable
as String,titleEn: null == titleEn ? _self.titleEn : titleEn // ignore: cast_nullable_to_non_nullable
as String,detailZh: freezed == detailZh ? _self.detailZh : detailZh // ignore: cast_nullable_to_non_nullable
as String?,detailEn: freezed == detailEn ? _self.detailEn : detailEn // ignore: cast_nullable_to_non_nullable
as String?,custom: null == custom ? _self.custom : custom // ignore: cast_nullable_to_non_nullable
as bool,myAnswer: freezed == myAnswer ? _self.myAnswer : myAnswer // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PreferenceItem].
extension PreferenceItemPatterns on PreferenceItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PreferenceItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PreferenceItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PreferenceItem value)  $default,){
final _that = this;
switch (_that) {
case _PreferenceItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PreferenceItem value)?  $default,){
final _that = this;
switch (_that) {
case _PreferenceItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String group,  String titleZh,  String titleEn,  String? detailZh,  String? detailEn,  bool custom,  String? myAnswer)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PreferenceItem() when $default != null:
return $default(_that.id,_that.group,_that.titleZh,_that.titleEn,_that.detailZh,_that.detailEn,_that.custom,_that.myAnswer);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String group,  String titleZh,  String titleEn,  String? detailZh,  String? detailEn,  bool custom,  String? myAnswer)  $default,) {final _that = this;
switch (_that) {
case _PreferenceItem():
return $default(_that.id,_that.group,_that.titleZh,_that.titleEn,_that.detailZh,_that.detailEn,_that.custom,_that.myAnswer);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String group,  String titleZh,  String titleEn,  String? detailZh,  String? detailEn,  bool custom,  String? myAnswer)?  $default,) {final _that = this;
switch (_that) {
case _PreferenceItem() when $default != null:
return $default(_that.id,_that.group,_that.titleZh,_that.titleEn,_that.detailZh,_that.detailEn,_that.custom,_that.myAnswer);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PreferenceItem extends PreferenceItem {
  const _PreferenceItem({required this.id, required this.group, required this.titleZh, required this.titleEn, this.detailZh, this.detailEn, this.custom = false, this.myAnswer}): super._();
  factory _PreferenceItem.fromJson(Map<String, dynamic> json) => _$PreferenceItemFromJson(json);

@override final  String id;
@override final  String group;
@override final  String titleZh;
@override final  String titleEn;
@override final  String? detailZh;
@override final  String? detailEn;
@override@JsonKey() final  bool custom;
@override final  String? myAnswer;

/// Create a copy of PreferenceItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PreferenceItemCopyWith<_PreferenceItem> get copyWith => __$PreferenceItemCopyWithImpl<_PreferenceItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PreferenceItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PreferenceItem&&(identical(other.id, id) || other.id == id)&&(identical(other.group, group) || other.group == group)&&(identical(other.titleZh, titleZh) || other.titleZh == titleZh)&&(identical(other.titleEn, titleEn) || other.titleEn == titleEn)&&(identical(other.detailZh, detailZh) || other.detailZh == detailZh)&&(identical(other.detailEn, detailEn) || other.detailEn == detailEn)&&(identical(other.custom, custom) || other.custom == custom)&&(identical(other.myAnswer, myAnswer) || other.myAnswer == myAnswer));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,group,titleZh,titleEn,detailZh,detailEn,custom,myAnswer);

@override
String toString() {
  return 'PreferenceItem(id: $id, group: $group, titleZh: $titleZh, titleEn: $titleEn, detailZh: $detailZh, detailEn: $detailEn, custom: $custom, myAnswer: $myAnswer)';
}


}

/// @nodoc
abstract mixin class _$PreferenceItemCopyWith<$Res> implements $PreferenceItemCopyWith<$Res> {
  factory _$PreferenceItemCopyWith(_PreferenceItem value, $Res Function(_PreferenceItem) _then) = __$PreferenceItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String group, String titleZh, String titleEn, String? detailZh, String? detailEn, bool custom, String? myAnswer
});




}
/// @nodoc
class __$PreferenceItemCopyWithImpl<$Res>
    implements _$PreferenceItemCopyWith<$Res> {
  __$PreferenceItemCopyWithImpl(this._self, this._then);

  final _PreferenceItem _self;
  final $Res Function(_PreferenceItem) _then;

/// Create a copy of PreferenceItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? group = null,Object? titleZh = null,Object? titleEn = null,Object? detailZh = freezed,Object? detailEn = freezed,Object? custom = null,Object? myAnswer = freezed,}) {
  return _then(_PreferenceItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,group: null == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as String,titleZh: null == titleZh ? _self.titleZh : titleZh // ignore: cast_nullable_to_non_nullable
as String,titleEn: null == titleEn ? _self.titleEn : titleEn // ignore: cast_nullable_to_non_nullable
as String,detailZh: freezed == detailZh ? _self.detailZh : detailZh // ignore: cast_nullable_to_non_nullable
as String?,detailEn: freezed == detailEn ? _self.detailEn : detailEn // ignore: cast_nullable_to_non_nullable
as String?,custom: null == custom ? _self.custom : custom // ignore: cast_nullable_to_non_nullable
as bool,myAnswer: freezed == myAnswer ? _self.myAnswer : myAnswer // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$CompareItem {

 String get itemId; String get title; String? get wantSide;
/// Create a copy of CompareItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CompareItemCopyWith<CompareItem> get copyWith => _$CompareItemCopyWithImpl<CompareItem>(this as CompareItem, _$identity);

  /// Serializes this CompareItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CompareItem&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.title, title) || other.title == title)&&(identical(other.wantSide, wantSide) || other.wantSide == wantSide));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,itemId,title,wantSide);

@override
String toString() {
  return 'CompareItem(itemId: $itemId, title: $title, wantSide: $wantSide)';
}


}

/// @nodoc
abstract mixin class $CompareItemCopyWith<$Res>  {
  factory $CompareItemCopyWith(CompareItem value, $Res Function(CompareItem) _then) = _$CompareItemCopyWithImpl;
@useResult
$Res call({
 String itemId, String title, String? wantSide
});




}
/// @nodoc
class _$CompareItemCopyWithImpl<$Res>
    implements $CompareItemCopyWith<$Res> {
  _$CompareItemCopyWithImpl(this._self, this._then);

  final CompareItem _self;
  final $Res Function(CompareItem) _then;

/// Create a copy of CompareItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? itemId = null,Object? title = null,Object? wantSide = freezed,}) {
  return _then(_self.copyWith(
itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,wantSide: freezed == wantSide ? _self.wantSide : wantSide // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CompareItem].
extension CompareItemPatterns on CompareItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CompareItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CompareItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CompareItem value)  $default,){
final _that = this;
switch (_that) {
case _CompareItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CompareItem value)?  $default,){
final _that = this;
switch (_that) {
case _CompareItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String itemId,  String title,  String? wantSide)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CompareItem() when $default != null:
return $default(_that.itemId,_that.title,_that.wantSide);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String itemId,  String title,  String? wantSide)  $default,) {final _that = this;
switch (_that) {
case _CompareItem():
return $default(_that.itemId,_that.title,_that.wantSide);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String itemId,  String title,  String? wantSide)?  $default,) {final _that = this;
switch (_that) {
case _CompareItem() when $default != null:
return $default(_that.itemId,_that.title,_that.wantSide);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CompareItem implements CompareItem {
  const _CompareItem({required this.itemId, required this.title, this.wantSide});
  factory _CompareItem.fromJson(Map<String, dynamic> json) => _$CompareItemFromJson(json);

@override final  String itemId;
@override final  String title;
@override final  String? wantSide;

/// Create a copy of CompareItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CompareItemCopyWith<_CompareItem> get copyWith => __$CompareItemCopyWithImpl<_CompareItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CompareItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CompareItem&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.title, title) || other.title == title)&&(identical(other.wantSide, wantSide) || other.wantSide == wantSide));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,itemId,title,wantSide);

@override
String toString() {
  return 'CompareItem(itemId: $itemId, title: $title, wantSide: $wantSide)';
}


}

/// @nodoc
abstract mixin class _$CompareItemCopyWith<$Res> implements $CompareItemCopyWith<$Res> {
  factory _$CompareItemCopyWith(_CompareItem value, $Res Function(_CompareItem) _then) = __$CompareItemCopyWithImpl;
@override @useResult
$Res call({
 String itemId, String title, String? wantSide
});




}
/// @nodoc
class __$CompareItemCopyWithImpl<$Res>
    implements _$CompareItemCopyWith<$Res> {
  __$CompareItemCopyWithImpl(this._self, this._then);

  final _CompareItem _self;
  final $Res Function(_CompareItem) _then;

/// Create a copy of CompareItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? itemId = null,Object? title = null,Object? wantSide = freezed,}) {
  return _then(_CompareItem(
itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,wantSide: freezed == wantSide ? _self.wantSide : wantSide // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$CompareView {

 bool get partnerAnswered; List<CompareItem> get bothWant; List<CompareItem> get wantAndOk; List<CompareItem> get someoneTalks; List<CompareItem> get notDoing;
/// Create a copy of CompareView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CompareViewCopyWith<CompareView> get copyWith => _$CompareViewCopyWithImpl<CompareView>(this as CompareView, _$identity);

  /// Serializes this CompareView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CompareView&&(identical(other.partnerAnswered, partnerAnswered) || other.partnerAnswered == partnerAnswered)&&const DeepCollectionEquality().equals(other.bothWant, bothWant)&&const DeepCollectionEquality().equals(other.wantAndOk, wantAndOk)&&const DeepCollectionEquality().equals(other.someoneTalks, someoneTalks)&&const DeepCollectionEquality().equals(other.notDoing, notDoing));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,partnerAnswered,const DeepCollectionEquality().hash(bothWant),const DeepCollectionEquality().hash(wantAndOk),const DeepCollectionEquality().hash(someoneTalks),const DeepCollectionEquality().hash(notDoing));

@override
String toString() {
  return 'CompareView(partnerAnswered: $partnerAnswered, bothWant: $bothWant, wantAndOk: $wantAndOk, someoneTalks: $someoneTalks, notDoing: $notDoing)';
}


}

/// @nodoc
abstract mixin class $CompareViewCopyWith<$Res>  {
  factory $CompareViewCopyWith(CompareView value, $Res Function(CompareView) _then) = _$CompareViewCopyWithImpl;
@useResult
$Res call({
 bool partnerAnswered, List<CompareItem> bothWant, List<CompareItem> wantAndOk, List<CompareItem> someoneTalks, List<CompareItem> notDoing
});




}
/// @nodoc
class _$CompareViewCopyWithImpl<$Res>
    implements $CompareViewCopyWith<$Res> {
  _$CompareViewCopyWithImpl(this._self, this._then);

  final CompareView _self;
  final $Res Function(CompareView) _then;

/// Create a copy of CompareView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? partnerAnswered = null,Object? bothWant = null,Object? wantAndOk = null,Object? someoneTalks = null,Object? notDoing = null,}) {
  return _then(_self.copyWith(
partnerAnswered: null == partnerAnswered ? _self.partnerAnswered : partnerAnswered // ignore: cast_nullable_to_non_nullable
as bool,bothWant: null == bothWant ? _self.bothWant : bothWant // ignore: cast_nullable_to_non_nullable
as List<CompareItem>,wantAndOk: null == wantAndOk ? _self.wantAndOk : wantAndOk // ignore: cast_nullable_to_non_nullable
as List<CompareItem>,someoneTalks: null == someoneTalks ? _self.someoneTalks : someoneTalks // ignore: cast_nullable_to_non_nullable
as List<CompareItem>,notDoing: null == notDoing ? _self.notDoing : notDoing // ignore: cast_nullable_to_non_nullable
as List<CompareItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [CompareView].
extension CompareViewPatterns on CompareView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CompareView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CompareView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CompareView value)  $default,){
final _that = this;
switch (_that) {
case _CompareView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CompareView value)?  $default,){
final _that = this;
switch (_that) {
case _CompareView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool partnerAnswered,  List<CompareItem> bothWant,  List<CompareItem> wantAndOk,  List<CompareItem> someoneTalks,  List<CompareItem> notDoing)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CompareView() when $default != null:
return $default(_that.partnerAnswered,_that.bothWant,_that.wantAndOk,_that.someoneTalks,_that.notDoing);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool partnerAnswered,  List<CompareItem> bothWant,  List<CompareItem> wantAndOk,  List<CompareItem> someoneTalks,  List<CompareItem> notDoing)  $default,) {final _that = this;
switch (_that) {
case _CompareView():
return $default(_that.partnerAnswered,_that.bothWant,_that.wantAndOk,_that.someoneTalks,_that.notDoing);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool partnerAnswered,  List<CompareItem> bothWant,  List<CompareItem> wantAndOk,  List<CompareItem> someoneTalks,  List<CompareItem> notDoing)?  $default,) {final _that = this;
switch (_that) {
case _CompareView() when $default != null:
return $default(_that.partnerAnswered,_that.bothWant,_that.wantAndOk,_that.someoneTalks,_that.notDoing);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CompareView extends CompareView {
  const _CompareView({this.partnerAnswered = false, final  List<CompareItem> bothWant = const <CompareItem>[], final  List<CompareItem> wantAndOk = const <CompareItem>[], final  List<CompareItem> someoneTalks = const <CompareItem>[], final  List<CompareItem> notDoing = const <CompareItem>[]}): _bothWant = bothWant,_wantAndOk = wantAndOk,_someoneTalks = someoneTalks,_notDoing = notDoing,super._();
  factory _CompareView.fromJson(Map<String, dynamic> json) => _$CompareViewFromJson(json);

@override@JsonKey() final  bool partnerAnswered;
 final  List<CompareItem> _bothWant;
@override@JsonKey() List<CompareItem> get bothWant {
  if (_bothWant is EqualUnmodifiableListView) return _bothWant;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bothWant);
}

 final  List<CompareItem> _wantAndOk;
@override@JsonKey() List<CompareItem> get wantAndOk {
  if (_wantAndOk is EqualUnmodifiableListView) return _wantAndOk;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_wantAndOk);
}

 final  List<CompareItem> _someoneTalks;
@override@JsonKey() List<CompareItem> get someoneTalks {
  if (_someoneTalks is EqualUnmodifiableListView) return _someoneTalks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_someoneTalks);
}

 final  List<CompareItem> _notDoing;
@override@JsonKey() List<CompareItem> get notDoing {
  if (_notDoing is EqualUnmodifiableListView) return _notDoing;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_notDoing);
}


/// Create a copy of CompareView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CompareViewCopyWith<_CompareView> get copyWith => __$CompareViewCopyWithImpl<_CompareView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CompareViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CompareView&&(identical(other.partnerAnswered, partnerAnswered) || other.partnerAnswered == partnerAnswered)&&const DeepCollectionEquality().equals(other._bothWant, _bothWant)&&const DeepCollectionEquality().equals(other._wantAndOk, _wantAndOk)&&const DeepCollectionEquality().equals(other._someoneTalks, _someoneTalks)&&const DeepCollectionEquality().equals(other._notDoing, _notDoing));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,partnerAnswered,const DeepCollectionEquality().hash(_bothWant),const DeepCollectionEquality().hash(_wantAndOk),const DeepCollectionEquality().hash(_someoneTalks),const DeepCollectionEquality().hash(_notDoing));

@override
String toString() {
  return 'CompareView(partnerAnswered: $partnerAnswered, bothWant: $bothWant, wantAndOk: $wantAndOk, someoneTalks: $someoneTalks, notDoing: $notDoing)';
}


}

/// @nodoc
abstract mixin class _$CompareViewCopyWith<$Res> implements $CompareViewCopyWith<$Res> {
  factory _$CompareViewCopyWith(_CompareView value, $Res Function(_CompareView) _then) = __$CompareViewCopyWithImpl;
@override @useResult
$Res call({
 bool partnerAnswered, List<CompareItem> bothWant, List<CompareItem> wantAndOk, List<CompareItem> someoneTalks, List<CompareItem> notDoing
});




}
/// @nodoc
class __$CompareViewCopyWithImpl<$Res>
    implements _$CompareViewCopyWith<$Res> {
  __$CompareViewCopyWithImpl(this._self, this._then);

  final _CompareView _self;
  final $Res Function(_CompareView) _then;

/// Create a copy of CompareView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? partnerAnswered = null,Object? bothWant = null,Object? wantAndOk = null,Object? someoneTalks = null,Object? notDoing = null,}) {
  return _then(_CompareView(
partnerAnswered: null == partnerAnswered ? _self.partnerAnswered : partnerAnswered // ignore: cast_nullable_to_non_nullable
as bool,bothWant: null == bothWant ? _self._bothWant : bothWant // ignore: cast_nullable_to_non_nullable
as List<CompareItem>,wantAndOk: null == wantAndOk ? _self._wantAndOk : wantAndOk // ignore: cast_nullable_to_non_nullable
as List<CompareItem>,someoneTalks: null == someoneTalks ? _self._someoneTalks : someoneTalks // ignore: cast_nullable_to_non_nullable
as List<CompareItem>,notDoing: null == notDoing ? _self._notDoing : notDoing // ignore: cast_nullable_to_non_nullable
as List<CompareItem>,
  ));
}


}


/// @nodoc
mixin _$IdeaCard {

 String get id; String get audience; String get titleZh; String get titleEn; String get howZh; String get howEn; String? get needsZh; String? get needsEn; int get intensity; List<String> get tags; List<String> get relatedItemIds; String? get state;
/// Create a copy of IdeaCard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IdeaCardCopyWith<IdeaCard> get copyWith => _$IdeaCardCopyWithImpl<IdeaCard>(this as IdeaCard, _$identity);

  /// Serializes this IdeaCard to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IdeaCard&&(identical(other.id, id) || other.id == id)&&(identical(other.audience, audience) || other.audience == audience)&&(identical(other.titleZh, titleZh) || other.titleZh == titleZh)&&(identical(other.titleEn, titleEn) || other.titleEn == titleEn)&&(identical(other.howZh, howZh) || other.howZh == howZh)&&(identical(other.howEn, howEn) || other.howEn == howEn)&&(identical(other.needsZh, needsZh) || other.needsZh == needsZh)&&(identical(other.needsEn, needsEn) || other.needsEn == needsEn)&&(identical(other.intensity, intensity) || other.intensity == intensity)&&const DeepCollectionEquality().equals(other.tags, tags)&&const DeepCollectionEquality().equals(other.relatedItemIds, relatedItemIds)&&(identical(other.state, state) || other.state == state));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,audience,titleZh,titleEn,howZh,howEn,needsZh,needsEn,intensity,const DeepCollectionEquality().hash(tags),const DeepCollectionEquality().hash(relatedItemIds),state);

@override
String toString() {
  return 'IdeaCard(id: $id, audience: $audience, titleZh: $titleZh, titleEn: $titleEn, howZh: $howZh, howEn: $howEn, needsZh: $needsZh, needsEn: $needsEn, intensity: $intensity, tags: $tags, relatedItemIds: $relatedItemIds, state: $state)';
}


}

/// @nodoc
abstract mixin class $IdeaCardCopyWith<$Res>  {
  factory $IdeaCardCopyWith(IdeaCard value, $Res Function(IdeaCard) _then) = _$IdeaCardCopyWithImpl;
@useResult
$Res call({
 String id, String audience, String titleZh, String titleEn, String howZh, String howEn, String? needsZh, String? needsEn, int intensity, List<String> tags, List<String> relatedItemIds, String? state
});




}
/// @nodoc
class _$IdeaCardCopyWithImpl<$Res>
    implements $IdeaCardCopyWith<$Res> {
  _$IdeaCardCopyWithImpl(this._self, this._then);

  final IdeaCard _self;
  final $Res Function(IdeaCard) _then;

/// Create a copy of IdeaCard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? audience = null,Object? titleZh = null,Object? titleEn = null,Object? howZh = null,Object? howEn = null,Object? needsZh = freezed,Object? needsEn = freezed,Object? intensity = null,Object? tags = null,Object? relatedItemIds = null,Object? state = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,audience: null == audience ? _self.audience : audience // ignore: cast_nullable_to_non_nullable
as String,titleZh: null == titleZh ? _self.titleZh : titleZh // ignore: cast_nullable_to_non_nullable
as String,titleEn: null == titleEn ? _self.titleEn : titleEn // ignore: cast_nullable_to_non_nullable
as String,howZh: null == howZh ? _self.howZh : howZh // ignore: cast_nullable_to_non_nullable
as String,howEn: null == howEn ? _self.howEn : howEn // ignore: cast_nullable_to_non_nullable
as String,needsZh: freezed == needsZh ? _self.needsZh : needsZh // ignore: cast_nullable_to_non_nullable
as String?,needsEn: freezed == needsEn ? _self.needsEn : needsEn // ignore: cast_nullable_to_non_nullable
as String?,intensity: null == intensity ? _self.intensity : intensity // ignore: cast_nullable_to_non_nullable
as int,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,relatedItemIds: null == relatedItemIds ? _self.relatedItemIds : relatedItemIds // ignore: cast_nullable_to_non_nullable
as List<String>,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [IdeaCard].
extension IdeaCardPatterns on IdeaCard {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IdeaCard value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IdeaCard() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IdeaCard value)  $default,){
final _that = this;
switch (_that) {
case _IdeaCard():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IdeaCard value)?  $default,){
final _that = this;
switch (_that) {
case _IdeaCard() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String audience,  String titleZh,  String titleEn,  String howZh,  String howEn,  String? needsZh,  String? needsEn,  int intensity,  List<String> tags,  List<String> relatedItemIds,  String? state)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IdeaCard() when $default != null:
return $default(_that.id,_that.audience,_that.titleZh,_that.titleEn,_that.howZh,_that.howEn,_that.needsZh,_that.needsEn,_that.intensity,_that.tags,_that.relatedItemIds,_that.state);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String audience,  String titleZh,  String titleEn,  String howZh,  String howEn,  String? needsZh,  String? needsEn,  int intensity,  List<String> tags,  List<String> relatedItemIds,  String? state)  $default,) {final _that = this;
switch (_that) {
case _IdeaCard():
return $default(_that.id,_that.audience,_that.titleZh,_that.titleEn,_that.howZh,_that.howEn,_that.needsZh,_that.needsEn,_that.intensity,_that.tags,_that.relatedItemIds,_that.state);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String audience,  String titleZh,  String titleEn,  String howZh,  String howEn,  String? needsZh,  String? needsEn,  int intensity,  List<String> tags,  List<String> relatedItemIds,  String? state)?  $default,) {final _that = this;
switch (_that) {
case _IdeaCard() when $default != null:
return $default(_that.id,_that.audience,_that.titleZh,_that.titleEn,_that.howZh,_that.howEn,_that.needsZh,_that.needsEn,_that.intensity,_that.tags,_that.relatedItemIds,_that.state);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IdeaCard extends IdeaCard {
  const _IdeaCard({required this.id, required this.audience, required this.titleZh, required this.titleEn, required this.howZh, required this.howEn, this.needsZh, this.needsEn, this.intensity = 1, final  List<String> tags = const <String>[], final  List<String> relatedItemIds = const <String>[], this.state}): _tags = tags,_relatedItemIds = relatedItemIds,super._();
  factory _IdeaCard.fromJson(Map<String, dynamic> json) => _$IdeaCardFromJson(json);

@override final  String id;
@override final  String audience;
@override final  String titleZh;
@override final  String titleEn;
@override final  String howZh;
@override final  String howEn;
@override final  String? needsZh;
@override final  String? needsEn;
@override@JsonKey() final  int intensity;
 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

 final  List<String> _relatedItemIds;
@override@JsonKey() List<String> get relatedItemIds {
  if (_relatedItemIds is EqualUnmodifiableListView) return _relatedItemIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_relatedItemIds);
}

@override final  String? state;

/// Create a copy of IdeaCard
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IdeaCardCopyWith<_IdeaCard> get copyWith => __$IdeaCardCopyWithImpl<_IdeaCard>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IdeaCardToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IdeaCard&&(identical(other.id, id) || other.id == id)&&(identical(other.audience, audience) || other.audience == audience)&&(identical(other.titleZh, titleZh) || other.titleZh == titleZh)&&(identical(other.titleEn, titleEn) || other.titleEn == titleEn)&&(identical(other.howZh, howZh) || other.howZh == howZh)&&(identical(other.howEn, howEn) || other.howEn == howEn)&&(identical(other.needsZh, needsZh) || other.needsZh == needsZh)&&(identical(other.needsEn, needsEn) || other.needsEn == needsEn)&&(identical(other.intensity, intensity) || other.intensity == intensity)&&const DeepCollectionEquality().equals(other._tags, _tags)&&const DeepCollectionEquality().equals(other._relatedItemIds, _relatedItemIds)&&(identical(other.state, state) || other.state == state));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,audience,titleZh,titleEn,howZh,howEn,needsZh,needsEn,intensity,const DeepCollectionEquality().hash(_tags),const DeepCollectionEquality().hash(_relatedItemIds),state);

@override
String toString() {
  return 'IdeaCard(id: $id, audience: $audience, titleZh: $titleZh, titleEn: $titleEn, howZh: $howZh, howEn: $howEn, needsZh: $needsZh, needsEn: $needsEn, intensity: $intensity, tags: $tags, relatedItemIds: $relatedItemIds, state: $state)';
}


}

/// @nodoc
abstract mixin class _$IdeaCardCopyWith<$Res> implements $IdeaCardCopyWith<$Res> {
  factory _$IdeaCardCopyWith(_IdeaCard value, $Res Function(_IdeaCard) _then) = __$IdeaCardCopyWithImpl;
@override @useResult
$Res call({
 String id, String audience, String titleZh, String titleEn, String howZh, String howEn, String? needsZh, String? needsEn, int intensity, List<String> tags, List<String> relatedItemIds, String? state
});




}
/// @nodoc
class __$IdeaCardCopyWithImpl<$Res>
    implements _$IdeaCardCopyWith<$Res> {
  __$IdeaCardCopyWithImpl(this._self, this._then);

  final _IdeaCard _self;
  final $Res Function(_IdeaCard) _then;

/// Create a copy of IdeaCard
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? audience = null,Object? titleZh = null,Object? titleEn = null,Object? howZh = null,Object? howEn = null,Object? needsZh = freezed,Object? needsEn = freezed,Object? intensity = null,Object? tags = null,Object? relatedItemIds = null,Object? state = freezed,}) {
  return _then(_IdeaCard(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,audience: null == audience ? _self.audience : audience // ignore: cast_nullable_to_non_nullable
as String,titleZh: null == titleZh ? _self.titleZh : titleZh // ignore: cast_nullable_to_non_nullable
as String,titleEn: null == titleEn ? _self.titleEn : titleEn // ignore: cast_nullable_to_non_nullable
as String,howZh: null == howZh ? _self.howZh : howZh // ignore: cast_nullable_to_non_nullable
as String,howEn: null == howEn ? _self.howEn : howEn // ignore: cast_nullable_to_non_nullable
as String,needsZh: freezed == needsZh ? _self.needsZh : needsZh // ignore: cast_nullable_to_non_nullable
as String?,needsEn: freezed == needsEn ? _self.needsEn : needsEn // ignore: cast_nullable_to_non_nullable
as String?,intensity: null == intensity ? _self.intensity : intensity // ignore: cast_nullable_to_non_nullable
as int,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,relatedItemIds: null == relatedItemIds ? _self._relatedItemIds : relatedItemIds // ignore: cast_nullable_to_non_nullable
as List<String>,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$IdeaCardActResult {

 String? get taskId; String? get ruleId; String? get noteId; String? get state;
/// Create a copy of IdeaCardActResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IdeaCardActResultCopyWith<IdeaCardActResult> get copyWith => _$IdeaCardActResultCopyWithImpl<IdeaCardActResult>(this as IdeaCardActResult, _$identity);

  /// Serializes this IdeaCardActResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IdeaCardActResult&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.ruleId, ruleId) || other.ruleId == ruleId)&&(identical(other.noteId, noteId) || other.noteId == noteId)&&(identical(other.state, state) || other.state == state));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,taskId,ruleId,noteId,state);

@override
String toString() {
  return 'IdeaCardActResult(taskId: $taskId, ruleId: $ruleId, noteId: $noteId, state: $state)';
}


}

/// @nodoc
abstract mixin class $IdeaCardActResultCopyWith<$Res>  {
  factory $IdeaCardActResultCopyWith(IdeaCardActResult value, $Res Function(IdeaCardActResult) _then) = _$IdeaCardActResultCopyWithImpl;
@useResult
$Res call({
 String? taskId, String? ruleId, String? noteId, String? state
});




}
/// @nodoc
class _$IdeaCardActResultCopyWithImpl<$Res>
    implements $IdeaCardActResultCopyWith<$Res> {
  _$IdeaCardActResultCopyWithImpl(this._self, this._then);

  final IdeaCardActResult _self;
  final $Res Function(IdeaCardActResult) _then;

/// Create a copy of IdeaCardActResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? taskId = freezed,Object? ruleId = freezed,Object? noteId = freezed,Object? state = freezed,}) {
  return _then(_self.copyWith(
taskId: freezed == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String?,ruleId: freezed == ruleId ? _self.ruleId : ruleId // ignore: cast_nullable_to_non_nullable
as String?,noteId: freezed == noteId ? _self.noteId : noteId // ignore: cast_nullable_to_non_nullable
as String?,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [IdeaCardActResult].
extension IdeaCardActResultPatterns on IdeaCardActResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IdeaCardActResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IdeaCardActResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IdeaCardActResult value)  $default,){
final _that = this;
switch (_that) {
case _IdeaCardActResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IdeaCardActResult value)?  $default,){
final _that = this;
switch (_that) {
case _IdeaCardActResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? taskId,  String? ruleId,  String? noteId,  String? state)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IdeaCardActResult() when $default != null:
return $default(_that.taskId,_that.ruleId,_that.noteId,_that.state);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? taskId,  String? ruleId,  String? noteId,  String? state)  $default,) {final _that = this;
switch (_that) {
case _IdeaCardActResult():
return $default(_that.taskId,_that.ruleId,_that.noteId,_that.state);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? taskId,  String? ruleId,  String? noteId,  String? state)?  $default,) {final _that = this;
switch (_that) {
case _IdeaCardActResult() when $default != null:
return $default(_that.taskId,_that.ruleId,_that.noteId,_that.state);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IdeaCardActResult implements IdeaCardActResult {
  const _IdeaCardActResult({this.taskId, this.ruleId, this.noteId, this.state});
  factory _IdeaCardActResult.fromJson(Map<String, dynamic> json) => _$IdeaCardActResultFromJson(json);

@override final  String? taskId;
@override final  String? ruleId;
@override final  String? noteId;
@override final  String? state;

/// Create a copy of IdeaCardActResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IdeaCardActResultCopyWith<_IdeaCardActResult> get copyWith => __$IdeaCardActResultCopyWithImpl<_IdeaCardActResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IdeaCardActResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IdeaCardActResult&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.ruleId, ruleId) || other.ruleId == ruleId)&&(identical(other.noteId, noteId) || other.noteId == noteId)&&(identical(other.state, state) || other.state == state));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,taskId,ruleId,noteId,state);

@override
String toString() {
  return 'IdeaCardActResult(taskId: $taskId, ruleId: $ruleId, noteId: $noteId, state: $state)';
}


}

/// @nodoc
abstract mixin class _$IdeaCardActResultCopyWith<$Res> implements $IdeaCardActResultCopyWith<$Res> {
  factory _$IdeaCardActResultCopyWith(_IdeaCardActResult value, $Res Function(_IdeaCardActResult) _then) = __$IdeaCardActResultCopyWithImpl;
@override @useResult
$Res call({
 String? taskId, String? ruleId, String? noteId, String? state
});




}
/// @nodoc
class __$IdeaCardActResultCopyWithImpl<$Res>
    implements _$IdeaCardActResultCopyWith<$Res> {
  __$IdeaCardActResultCopyWithImpl(this._self, this._then);

  final _IdeaCardActResult _self;
  final $Res Function(_IdeaCardActResult) _then;

/// Create a copy of IdeaCardActResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? taskId = freezed,Object? ruleId = freezed,Object? noteId = freezed,Object? state = freezed,}) {
  return _then(_IdeaCardActResult(
taskId: freezed == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String?,ruleId: freezed == ruleId ? _self.ruleId : ruleId // ignore: cast_nullable_to_non_nullable
as String?,noteId: freezed == noteId ? _self.noteId : noteId // ignore: cast_nullable_to_non_nullable
as String?,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$StarterPackTask {

 String get titleZh; String get titleEn; String get kind; Map<String, dynamic>? get schedule; String? get dueTime; String get proof; int get pointsEarn;
/// Create a copy of StarterPackTask
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StarterPackTaskCopyWith<StarterPackTask> get copyWith => _$StarterPackTaskCopyWithImpl<StarterPackTask>(this as StarterPackTask, _$identity);

  /// Serializes this StarterPackTask to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StarterPackTask&&(identical(other.titleZh, titleZh) || other.titleZh == titleZh)&&(identical(other.titleEn, titleEn) || other.titleEn == titleEn)&&(identical(other.kind, kind) || other.kind == kind)&&const DeepCollectionEquality().equals(other.schedule, schedule)&&(identical(other.dueTime, dueTime) || other.dueTime == dueTime)&&(identical(other.proof, proof) || other.proof == proof)&&(identical(other.pointsEarn, pointsEarn) || other.pointsEarn == pointsEarn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,titleZh,titleEn,kind,const DeepCollectionEquality().hash(schedule),dueTime,proof,pointsEarn);

@override
String toString() {
  return 'StarterPackTask(titleZh: $titleZh, titleEn: $titleEn, kind: $kind, schedule: $schedule, dueTime: $dueTime, proof: $proof, pointsEarn: $pointsEarn)';
}


}

/// @nodoc
abstract mixin class $StarterPackTaskCopyWith<$Res>  {
  factory $StarterPackTaskCopyWith(StarterPackTask value, $Res Function(StarterPackTask) _then) = _$StarterPackTaskCopyWithImpl;
@useResult
$Res call({
 String titleZh, String titleEn, String kind, Map<String, dynamic>? schedule, String? dueTime, String proof, int pointsEarn
});




}
/// @nodoc
class _$StarterPackTaskCopyWithImpl<$Res>
    implements $StarterPackTaskCopyWith<$Res> {
  _$StarterPackTaskCopyWithImpl(this._self, this._then);

  final StarterPackTask _self;
  final $Res Function(StarterPackTask) _then;

/// Create a copy of StarterPackTask
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? titleZh = null,Object? titleEn = null,Object? kind = null,Object? schedule = freezed,Object? dueTime = freezed,Object? proof = null,Object? pointsEarn = null,}) {
  return _then(_self.copyWith(
titleZh: null == titleZh ? _self.titleZh : titleZh // ignore: cast_nullable_to_non_nullable
as String,titleEn: null == titleEn ? _self.titleEn : titleEn // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,schedule: freezed == schedule ? _self.schedule : schedule // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,dueTime: freezed == dueTime ? _self.dueTime : dueTime // ignore: cast_nullable_to_non_nullable
as String?,proof: null == proof ? _self.proof : proof // ignore: cast_nullable_to_non_nullable
as String,pointsEarn: null == pointsEarn ? _self.pointsEarn : pointsEarn // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [StarterPackTask].
extension StarterPackTaskPatterns on StarterPackTask {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StarterPackTask value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StarterPackTask() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StarterPackTask value)  $default,){
final _that = this;
switch (_that) {
case _StarterPackTask():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StarterPackTask value)?  $default,){
final _that = this;
switch (_that) {
case _StarterPackTask() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String titleZh,  String titleEn,  String kind,  Map<String, dynamic>? schedule,  String? dueTime,  String proof,  int pointsEarn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StarterPackTask() when $default != null:
return $default(_that.titleZh,_that.titleEn,_that.kind,_that.schedule,_that.dueTime,_that.proof,_that.pointsEarn);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String titleZh,  String titleEn,  String kind,  Map<String, dynamic>? schedule,  String? dueTime,  String proof,  int pointsEarn)  $default,) {final _that = this;
switch (_that) {
case _StarterPackTask():
return $default(_that.titleZh,_that.titleEn,_that.kind,_that.schedule,_that.dueTime,_that.proof,_that.pointsEarn);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String titleZh,  String titleEn,  String kind,  Map<String, dynamic>? schedule,  String? dueTime,  String proof,  int pointsEarn)?  $default,) {final _that = this;
switch (_that) {
case _StarterPackTask() when $default != null:
return $default(_that.titleZh,_that.titleEn,_that.kind,_that.schedule,_that.dueTime,_that.proof,_that.pointsEarn);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StarterPackTask extends StarterPackTask {
  const _StarterPackTask({required this.titleZh, required this.titleEn, this.kind = 'checkin', final  Map<String, dynamic>? schedule, this.dueTime, this.proof = 'check', this.pointsEarn = 0}): _schedule = schedule,super._();
  factory _StarterPackTask.fromJson(Map<String, dynamic> json) => _$StarterPackTaskFromJson(json);

@override final  String titleZh;
@override final  String titleEn;
@override@JsonKey() final  String kind;
 final  Map<String, dynamic>? _schedule;
@override Map<String, dynamic>? get schedule {
  final value = _schedule;
  if (value == null) return null;
  if (_schedule is EqualUnmodifiableMapView) return _schedule;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  String? dueTime;
@override@JsonKey() final  String proof;
@override@JsonKey() final  int pointsEarn;

/// Create a copy of StarterPackTask
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StarterPackTaskCopyWith<_StarterPackTask> get copyWith => __$StarterPackTaskCopyWithImpl<_StarterPackTask>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StarterPackTaskToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StarterPackTask&&(identical(other.titleZh, titleZh) || other.titleZh == titleZh)&&(identical(other.titleEn, titleEn) || other.titleEn == titleEn)&&(identical(other.kind, kind) || other.kind == kind)&&const DeepCollectionEquality().equals(other._schedule, _schedule)&&(identical(other.dueTime, dueTime) || other.dueTime == dueTime)&&(identical(other.proof, proof) || other.proof == proof)&&(identical(other.pointsEarn, pointsEarn) || other.pointsEarn == pointsEarn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,titleZh,titleEn,kind,const DeepCollectionEquality().hash(_schedule),dueTime,proof,pointsEarn);

@override
String toString() {
  return 'StarterPackTask(titleZh: $titleZh, titleEn: $titleEn, kind: $kind, schedule: $schedule, dueTime: $dueTime, proof: $proof, pointsEarn: $pointsEarn)';
}


}

/// @nodoc
abstract mixin class _$StarterPackTaskCopyWith<$Res> implements $StarterPackTaskCopyWith<$Res> {
  factory _$StarterPackTaskCopyWith(_StarterPackTask value, $Res Function(_StarterPackTask) _then) = __$StarterPackTaskCopyWithImpl;
@override @useResult
$Res call({
 String titleZh, String titleEn, String kind, Map<String, dynamic>? schedule, String? dueTime, String proof, int pointsEarn
});




}
/// @nodoc
class __$StarterPackTaskCopyWithImpl<$Res>
    implements _$StarterPackTaskCopyWith<$Res> {
  __$StarterPackTaskCopyWithImpl(this._self, this._then);

  final _StarterPackTask _self;
  final $Res Function(_StarterPackTask) _then;

/// Create a copy of StarterPackTask
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? titleZh = null,Object? titleEn = null,Object? kind = null,Object? schedule = freezed,Object? dueTime = freezed,Object? proof = null,Object? pointsEarn = null,}) {
  return _then(_StarterPackTask(
titleZh: null == titleZh ? _self.titleZh : titleZh // ignore: cast_nullable_to_non_nullable
as String,titleEn: null == titleEn ? _self.titleEn : titleEn // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,schedule: freezed == schedule ? _self._schedule : schedule // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,dueTime: freezed == dueTime ? _self.dueTime : dueTime // ignore: cast_nullable_to_non_nullable
as String?,proof: null == proof ? _self.proof : proof // ignore: cast_nullable_to_non_nullable
as String,pointsEarn: null == pointsEarn ? _self.pointsEarn : pointsEarn // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$StarterPackRule {

 String get titleZh; String get titleEn; String? get bodyZh; String? get bodyEn; String get group;
/// Create a copy of StarterPackRule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StarterPackRuleCopyWith<StarterPackRule> get copyWith => _$StarterPackRuleCopyWithImpl<StarterPackRule>(this as StarterPackRule, _$identity);

  /// Serializes this StarterPackRule to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StarterPackRule&&(identical(other.titleZh, titleZh) || other.titleZh == titleZh)&&(identical(other.titleEn, titleEn) || other.titleEn == titleEn)&&(identical(other.bodyZh, bodyZh) || other.bodyZh == bodyZh)&&(identical(other.bodyEn, bodyEn) || other.bodyEn == bodyEn)&&(identical(other.group, group) || other.group == group));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,titleZh,titleEn,bodyZh,bodyEn,group);

@override
String toString() {
  return 'StarterPackRule(titleZh: $titleZh, titleEn: $titleEn, bodyZh: $bodyZh, bodyEn: $bodyEn, group: $group)';
}


}

/// @nodoc
abstract mixin class $StarterPackRuleCopyWith<$Res>  {
  factory $StarterPackRuleCopyWith(StarterPackRule value, $Res Function(StarterPackRule) _then) = _$StarterPackRuleCopyWithImpl;
@useResult
$Res call({
 String titleZh, String titleEn, String? bodyZh, String? bodyEn, String group
});




}
/// @nodoc
class _$StarterPackRuleCopyWithImpl<$Res>
    implements $StarterPackRuleCopyWith<$Res> {
  _$StarterPackRuleCopyWithImpl(this._self, this._then);

  final StarterPackRule _self;
  final $Res Function(StarterPackRule) _then;

/// Create a copy of StarterPackRule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? titleZh = null,Object? titleEn = null,Object? bodyZh = freezed,Object? bodyEn = freezed,Object? group = null,}) {
  return _then(_self.copyWith(
titleZh: null == titleZh ? _self.titleZh : titleZh // ignore: cast_nullable_to_non_nullable
as String,titleEn: null == titleEn ? _self.titleEn : titleEn // ignore: cast_nullable_to_non_nullable
as String,bodyZh: freezed == bodyZh ? _self.bodyZh : bodyZh // ignore: cast_nullable_to_non_nullable
as String?,bodyEn: freezed == bodyEn ? _self.bodyEn : bodyEn // ignore: cast_nullable_to_non_nullable
as String?,group: null == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [StarterPackRule].
extension StarterPackRulePatterns on StarterPackRule {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StarterPackRule value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StarterPackRule() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StarterPackRule value)  $default,){
final _that = this;
switch (_that) {
case _StarterPackRule():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StarterPackRule value)?  $default,){
final _that = this;
switch (_that) {
case _StarterPackRule() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String titleZh,  String titleEn,  String? bodyZh,  String? bodyEn,  String group)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StarterPackRule() when $default != null:
return $default(_that.titleZh,_that.titleEn,_that.bodyZh,_that.bodyEn,_that.group);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String titleZh,  String titleEn,  String? bodyZh,  String? bodyEn,  String group)  $default,) {final _that = this;
switch (_that) {
case _StarterPackRule():
return $default(_that.titleZh,_that.titleEn,_that.bodyZh,_that.bodyEn,_that.group);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String titleZh,  String titleEn,  String? bodyZh,  String? bodyEn,  String group)?  $default,) {final _that = this;
switch (_that) {
case _StarterPackRule() when $default != null:
return $default(_that.titleZh,_that.titleEn,_that.bodyZh,_that.bodyEn,_that.group);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StarterPackRule extends StarterPackRule {
  const _StarterPackRule({required this.titleZh, required this.titleEn, this.bodyZh, this.bodyEn, this.group = 'other'}): super._();
  factory _StarterPackRule.fromJson(Map<String, dynamic> json) => _$StarterPackRuleFromJson(json);

@override final  String titleZh;
@override final  String titleEn;
@override final  String? bodyZh;
@override final  String? bodyEn;
@override@JsonKey() final  String group;

/// Create a copy of StarterPackRule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StarterPackRuleCopyWith<_StarterPackRule> get copyWith => __$StarterPackRuleCopyWithImpl<_StarterPackRule>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StarterPackRuleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StarterPackRule&&(identical(other.titleZh, titleZh) || other.titleZh == titleZh)&&(identical(other.titleEn, titleEn) || other.titleEn == titleEn)&&(identical(other.bodyZh, bodyZh) || other.bodyZh == bodyZh)&&(identical(other.bodyEn, bodyEn) || other.bodyEn == bodyEn)&&(identical(other.group, group) || other.group == group));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,titleZh,titleEn,bodyZh,bodyEn,group);

@override
String toString() {
  return 'StarterPackRule(titleZh: $titleZh, titleEn: $titleEn, bodyZh: $bodyZh, bodyEn: $bodyEn, group: $group)';
}


}

/// @nodoc
abstract mixin class _$StarterPackRuleCopyWith<$Res> implements $StarterPackRuleCopyWith<$Res> {
  factory _$StarterPackRuleCopyWith(_StarterPackRule value, $Res Function(_StarterPackRule) _then) = __$StarterPackRuleCopyWithImpl;
@override @useResult
$Res call({
 String titleZh, String titleEn, String? bodyZh, String? bodyEn, String group
});




}
/// @nodoc
class __$StarterPackRuleCopyWithImpl<$Res>
    implements _$StarterPackRuleCopyWith<$Res> {
  __$StarterPackRuleCopyWithImpl(this._self, this._then);

  final _StarterPackRule _self;
  final $Res Function(_StarterPackRule) _then;

/// Create a copy of StarterPackRule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? titleZh = null,Object? titleEn = null,Object? bodyZh = freezed,Object? bodyEn = freezed,Object? group = null,}) {
  return _then(_StarterPackRule(
titleZh: null == titleZh ? _self.titleZh : titleZh // ignore: cast_nullable_to_non_nullable
as String,titleEn: null == titleEn ? _self.titleEn : titleEn // ignore: cast_nullable_to_non_nullable
as String,bodyZh: freezed == bodyZh ? _self.bodyZh : bodyZh // ignore: cast_nullable_to_non_nullable
as String?,bodyEn: freezed == bodyEn ? _self.bodyEn : bodyEn // ignore: cast_nullable_to_non_nullable
as String?,group: null == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$StarterPackReward {

 String get titleZh; String get titleEn; int? get cost;
/// Create a copy of StarterPackReward
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StarterPackRewardCopyWith<StarterPackReward> get copyWith => _$StarterPackRewardCopyWithImpl<StarterPackReward>(this as StarterPackReward, _$identity);

  /// Serializes this StarterPackReward to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StarterPackReward&&(identical(other.titleZh, titleZh) || other.titleZh == titleZh)&&(identical(other.titleEn, titleEn) || other.titleEn == titleEn)&&(identical(other.cost, cost) || other.cost == cost));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,titleZh,titleEn,cost);

@override
String toString() {
  return 'StarterPackReward(titleZh: $titleZh, titleEn: $titleEn, cost: $cost)';
}


}

/// @nodoc
abstract mixin class $StarterPackRewardCopyWith<$Res>  {
  factory $StarterPackRewardCopyWith(StarterPackReward value, $Res Function(StarterPackReward) _then) = _$StarterPackRewardCopyWithImpl;
@useResult
$Res call({
 String titleZh, String titleEn, int? cost
});




}
/// @nodoc
class _$StarterPackRewardCopyWithImpl<$Res>
    implements $StarterPackRewardCopyWith<$Res> {
  _$StarterPackRewardCopyWithImpl(this._self, this._then);

  final StarterPackReward _self;
  final $Res Function(StarterPackReward) _then;

/// Create a copy of StarterPackReward
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? titleZh = null,Object? titleEn = null,Object? cost = freezed,}) {
  return _then(_self.copyWith(
titleZh: null == titleZh ? _self.titleZh : titleZh // ignore: cast_nullable_to_non_nullable
as String,titleEn: null == titleEn ? _self.titleEn : titleEn // ignore: cast_nullable_to_non_nullable
as String,cost: freezed == cost ? _self.cost : cost // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [StarterPackReward].
extension StarterPackRewardPatterns on StarterPackReward {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StarterPackReward value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StarterPackReward() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StarterPackReward value)  $default,){
final _that = this;
switch (_that) {
case _StarterPackReward():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StarterPackReward value)?  $default,){
final _that = this;
switch (_that) {
case _StarterPackReward() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String titleZh,  String titleEn,  int? cost)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StarterPackReward() when $default != null:
return $default(_that.titleZh,_that.titleEn,_that.cost);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String titleZh,  String titleEn,  int? cost)  $default,) {final _that = this;
switch (_that) {
case _StarterPackReward():
return $default(_that.titleZh,_that.titleEn,_that.cost);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String titleZh,  String titleEn,  int? cost)?  $default,) {final _that = this;
switch (_that) {
case _StarterPackReward() when $default != null:
return $default(_that.titleZh,_that.titleEn,_that.cost);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StarterPackReward extends StarterPackReward {
  const _StarterPackReward({required this.titleZh, required this.titleEn, this.cost}): super._();
  factory _StarterPackReward.fromJson(Map<String, dynamic> json) => _$StarterPackRewardFromJson(json);

@override final  String titleZh;
@override final  String titleEn;
@override final  int? cost;

/// Create a copy of StarterPackReward
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StarterPackRewardCopyWith<_StarterPackReward> get copyWith => __$StarterPackRewardCopyWithImpl<_StarterPackReward>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StarterPackRewardToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StarterPackReward&&(identical(other.titleZh, titleZh) || other.titleZh == titleZh)&&(identical(other.titleEn, titleEn) || other.titleEn == titleEn)&&(identical(other.cost, cost) || other.cost == cost));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,titleZh,titleEn,cost);

@override
String toString() {
  return 'StarterPackReward(titleZh: $titleZh, titleEn: $titleEn, cost: $cost)';
}


}

/// @nodoc
abstract mixin class _$StarterPackRewardCopyWith<$Res> implements $StarterPackRewardCopyWith<$Res> {
  factory _$StarterPackRewardCopyWith(_StarterPackReward value, $Res Function(_StarterPackReward) _then) = __$StarterPackRewardCopyWithImpl;
@override @useResult
$Res call({
 String titleZh, String titleEn, int? cost
});




}
/// @nodoc
class __$StarterPackRewardCopyWithImpl<$Res>
    implements _$StarterPackRewardCopyWith<$Res> {
  __$StarterPackRewardCopyWithImpl(this._self, this._then);

  final _StarterPackReward _self;
  final $Res Function(_StarterPackReward) _then;

/// Create a copy of StarterPackReward
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? titleZh = null,Object? titleEn = null,Object? cost = freezed,}) {
  return _then(_StarterPackReward(
titleZh: null == titleZh ? _self.titleZh : titleZh // ignore: cast_nullable_to_non_nullable
as String,titleEn: null == titleEn ? _self.titleEn : titleEn // ignore: cast_nullable_to_non_nullable
as String,cost: freezed == cost ? _self.cost : cost // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$StarterPack {

 String get id; String get titleZh; String get titleEn; List<StarterPackTask> get tasks; List<StarterPackRule> get rules; List<StarterPackReward> get rewards;
/// Create a copy of StarterPack
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StarterPackCopyWith<StarterPack> get copyWith => _$StarterPackCopyWithImpl<StarterPack>(this as StarterPack, _$identity);

  /// Serializes this StarterPack to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StarterPack&&(identical(other.id, id) || other.id == id)&&(identical(other.titleZh, titleZh) || other.titleZh == titleZh)&&(identical(other.titleEn, titleEn) || other.titleEn == titleEn)&&const DeepCollectionEquality().equals(other.tasks, tasks)&&const DeepCollectionEquality().equals(other.rules, rules)&&const DeepCollectionEquality().equals(other.rewards, rewards));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,titleZh,titleEn,const DeepCollectionEquality().hash(tasks),const DeepCollectionEquality().hash(rules),const DeepCollectionEquality().hash(rewards));

@override
String toString() {
  return 'StarterPack(id: $id, titleZh: $titleZh, titleEn: $titleEn, tasks: $tasks, rules: $rules, rewards: $rewards)';
}


}

/// @nodoc
abstract mixin class $StarterPackCopyWith<$Res>  {
  factory $StarterPackCopyWith(StarterPack value, $Res Function(StarterPack) _then) = _$StarterPackCopyWithImpl;
@useResult
$Res call({
 String id, String titleZh, String titleEn, List<StarterPackTask> tasks, List<StarterPackRule> rules, List<StarterPackReward> rewards
});




}
/// @nodoc
class _$StarterPackCopyWithImpl<$Res>
    implements $StarterPackCopyWith<$Res> {
  _$StarterPackCopyWithImpl(this._self, this._then);

  final StarterPack _self;
  final $Res Function(StarterPack) _then;

/// Create a copy of StarterPack
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? titleZh = null,Object? titleEn = null,Object? tasks = null,Object? rules = null,Object? rewards = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,titleZh: null == titleZh ? _self.titleZh : titleZh // ignore: cast_nullable_to_non_nullable
as String,titleEn: null == titleEn ? _self.titleEn : titleEn // ignore: cast_nullable_to_non_nullable
as String,tasks: null == tasks ? _self.tasks : tasks // ignore: cast_nullable_to_non_nullable
as List<StarterPackTask>,rules: null == rules ? _self.rules : rules // ignore: cast_nullable_to_non_nullable
as List<StarterPackRule>,rewards: null == rewards ? _self.rewards : rewards // ignore: cast_nullable_to_non_nullable
as List<StarterPackReward>,
  ));
}

}


/// Adds pattern-matching-related methods to [StarterPack].
extension StarterPackPatterns on StarterPack {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StarterPack value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StarterPack() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StarterPack value)  $default,){
final _that = this;
switch (_that) {
case _StarterPack():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StarterPack value)?  $default,){
final _that = this;
switch (_that) {
case _StarterPack() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String titleZh,  String titleEn,  List<StarterPackTask> tasks,  List<StarterPackRule> rules,  List<StarterPackReward> rewards)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StarterPack() when $default != null:
return $default(_that.id,_that.titleZh,_that.titleEn,_that.tasks,_that.rules,_that.rewards);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String titleZh,  String titleEn,  List<StarterPackTask> tasks,  List<StarterPackRule> rules,  List<StarterPackReward> rewards)  $default,) {final _that = this;
switch (_that) {
case _StarterPack():
return $default(_that.id,_that.titleZh,_that.titleEn,_that.tasks,_that.rules,_that.rewards);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String titleZh,  String titleEn,  List<StarterPackTask> tasks,  List<StarterPackRule> rules,  List<StarterPackReward> rewards)?  $default,) {final _that = this;
switch (_that) {
case _StarterPack() when $default != null:
return $default(_that.id,_that.titleZh,_that.titleEn,_that.tasks,_that.rules,_that.rewards);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StarterPack extends StarterPack {
  const _StarterPack({required this.id, required this.titleZh, required this.titleEn, final  List<StarterPackTask> tasks = const <StarterPackTask>[], final  List<StarterPackRule> rules = const <StarterPackRule>[], final  List<StarterPackReward> rewards = const <StarterPackReward>[]}): _tasks = tasks,_rules = rules,_rewards = rewards,super._();
  factory _StarterPack.fromJson(Map<String, dynamic> json) => _$StarterPackFromJson(json);

@override final  String id;
@override final  String titleZh;
@override final  String titleEn;
 final  List<StarterPackTask> _tasks;
@override@JsonKey() List<StarterPackTask> get tasks {
  if (_tasks is EqualUnmodifiableListView) return _tasks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tasks);
}

 final  List<StarterPackRule> _rules;
@override@JsonKey() List<StarterPackRule> get rules {
  if (_rules is EqualUnmodifiableListView) return _rules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rules);
}

 final  List<StarterPackReward> _rewards;
@override@JsonKey() List<StarterPackReward> get rewards {
  if (_rewards is EqualUnmodifiableListView) return _rewards;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rewards);
}


/// Create a copy of StarterPack
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StarterPackCopyWith<_StarterPack> get copyWith => __$StarterPackCopyWithImpl<_StarterPack>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StarterPackToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StarterPack&&(identical(other.id, id) || other.id == id)&&(identical(other.titleZh, titleZh) || other.titleZh == titleZh)&&(identical(other.titleEn, titleEn) || other.titleEn == titleEn)&&const DeepCollectionEquality().equals(other._tasks, _tasks)&&const DeepCollectionEquality().equals(other._rules, _rules)&&const DeepCollectionEquality().equals(other._rewards, _rewards));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,titleZh,titleEn,const DeepCollectionEquality().hash(_tasks),const DeepCollectionEquality().hash(_rules),const DeepCollectionEquality().hash(_rewards));

@override
String toString() {
  return 'StarterPack(id: $id, titleZh: $titleZh, titleEn: $titleEn, tasks: $tasks, rules: $rules, rewards: $rewards)';
}


}

/// @nodoc
abstract mixin class _$StarterPackCopyWith<$Res> implements $StarterPackCopyWith<$Res> {
  factory _$StarterPackCopyWith(_StarterPack value, $Res Function(_StarterPack) _then) = __$StarterPackCopyWithImpl;
@override @useResult
$Res call({
 String id, String titleZh, String titleEn, List<StarterPackTask> tasks, List<StarterPackRule> rules, List<StarterPackReward> rewards
});




}
/// @nodoc
class __$StarterPackCopyWithImpl<$Res>
    implements _$StarterPackCopyWith<$Res> {
  __$StarterPackCopyWithImpl(this._self, this._then);

  final _StarterPack _self;
  final $Res Function(_StarterPack) _then;

/// Create a copy of StarterPack
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? titleZh = null,Object? titleEn = null,Object? tasks = null,Object? rules = null,Object? rewards = null,}) {
  return _then(_StarterPack(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,titleZh: null == titleZh ? _self.titleZh : titleZh // ignore: cast_nullable_to_non_nullable
as String,titleEn: null == titleEn ? _self.titleEn : titleEn // ignore: cast_nullable_to_non_nullable
as String,tasks: null == tasks ? _self._tasks : tasks // ignore: cast_nullable_to_non_nullable
as List<StarterPackTask>,rules: null == rules ? _self._rules : rules // ignore: cast_nullable_to_non_nullable
as List<StarterPackRule>,rewards: null == rewards ? _self._rewards : rewards // ignore: cast_nullable_to_non_nullable
as List<StarterPackReward>,
  ));
}


}


/// @nodoc
mixin _$DraftTask {

 String get title; String? get detail; String get kind; Map<String, dynamic>? get schedule; String? get dueTime; String get proof; int get pointsEarn;
/// Create a copy of DraftTask
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DraftTaskCopyWith<DraftTask> get copyWith => _$DraftTaskCopyWithImpl<DraftTask>(this as DraftTask, _$identity);

  /// Serializes this DraftTask to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DraftTask&&(identical(other.title, title) || other.title == title)&&(identical(other.detail, detail) || other.detail == detail)&&(identical(other.kind, kind) || other.kind == kind)&&const DeepCollectionEquality().equals(other.schedule, schedule)&&(identical(other.dueTime, dueTime) || other.dueTime == dueTime)&&(identical(other.proof, proof) || other.proof == proof)&&(identical(other.pointsEarn, pointsEarn) || other.pointsEarn == pointsEarn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,detail,kind,const DeepCollectionEquality().hash(schedule),dueTime,proof,pointsEarn);

@override
String toString() {
  return 'DraftTask(title: $title, detail: $detail, kind: $kind, schedule: $schedule, dueTime: $dueTime, proof: $proof, pointsEarn: $pointsEarn)';
}


}

/// @nodoc
abstract mixin class $DraftTaskCopyWith<$Res>  {
  factory $DraftTaskCopyWith(DraftTask value, $Res Function(DraftTask) _then) = _$DraftTaskCopyWithImpl;
@useResult
$Res call({
 String title, String? detail, String kind, Map<String, dynamic>? schedule, String? dueTime, String proof, int pointsEarn
});




}
/// @nodoc
class _$DraftTaskCopyWithImpl<$Res>
    implements $DraftTaskCopyWith<$Res> {
  _$DraftTaskCopyWithImpl(this._self, this._then);

  final DraftTask _self;
  final $Res Function(DraftTask) _then;

/// Create a copy of DraftTask
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? detail = freezed,Object? kind = null,Object? schedule = freezed,Object? dueTime = freezed,Object? proof = null,Object? pointsEarn = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,detail: freezed == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String?,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,schedule: freezed == schedule ? _self.schedule : schedule // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,dueTime: freezed == dueTime ? _self.dueTime : dueTime // ignore: cast_nullable_to_non_nullable
as String?,proof: null == proof ? _self.proof : proof // ignore: cast_nullable_to_non_nullable
as String,pointsEarn: null == pointsEarn ? _self.pointsEarn : pointsEarn // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DraftTask].
extension DraftTaskPatterns on DraftTask {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DraftTask value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DraftTask() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DraftTask value)  $default,){
final _that = this;
switch (_that) {
case _DraftTask():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DraftTask value)?  $default,){
final _that = this;
switch (_that) {
case _DraftTask() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String? detail,  String kind,  Map<String, dynamic>? schedule,  String? dueTime,  String proof,  int pointsEarn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DraftTask() when $default != null:
return $default(_that.title,_that.detail,_that.kind,_that.schedule,_that.dueTime,_that.proof,_that.pointsEarn);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String? detail,  String kind,  Map<String, dynamic>? schedule,  String? dueTime,  String proof,  int pointsEarn)  $default,) {final _that = this;
switch (_that) {
case _DraftTask():
return $default(_that.title,_that.detail,_that.kind,_that.schedule,_that.dueTime,_that.proof,_that.pointsEarn);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String? detail,  String kind,  Map<String, dynamic>? schedule,  String? dueTime,  String proof,  int pointsEarn)?  $default,) {final _that = this;
switch (_that) {
case _DraftTask() when $default != null:
return $default(_that.title,_that.detail,_that.kind,_that.schedule,_that.dueTime,_that.proof,_that.pointsEarn);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DraftTask implements DraftTask {
  const _DraftTask({required this.title, this.detail, this.kind = 'checkin', final  Map<String, dynamic>? schedule, this.dueTime, this.proof = 'check', this.pointsEarn = 0}): _schedule = schedule;
  factory _DraftTask.fromJson(Map<String, dynamic> json) => _$DraftTaskFromJson(json);

@override final  String title;
@override final  String? detail;
@override@JsonKey() final  String kind;
 final  Map<String, dynamic>? _schedule;
@override Map<String, dynamic>? get schedule {
  final value = _schedule;
  if (value == null) return null;
  if (_schedule is EqualUnmodifiableMapView) return _schedule;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  String? dueTime;
@override@JsonKey() final  String proof;
@override@JsonKey() final  int pointsEarn;

/// Create a copy of DraftTask
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DraftTaskCopyWith<_DraftTask> get copyWith => __$DraftTaskCopyWithImpl<_DraftTask>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DraftTaskToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DraftTask&&(identical(other.title, title) || other.title == title)&&(identical(other.detail, detail) || other.detail == detail)&&(identical(other.kind, kind) || other.kind == kind)&&const DeepCollectionEquality().equals(other._schedule, _schedule)&&(identical(other.dueTime, dueTime) || other.dueTime == dueTime)&&(identical(other.proof, proof) || other.proof == proof)&&(identical(other.pointsEarn, pointsEarn) || other.pointsEarn == pointsEarn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,detail,kind,const DeepCollectionEquality().hash(_schedule),dueTime,proof,pointsEarn);

@override
String toString() {
  return 'DraftTask(title: $title, detail: $detail, kind: $kind, schedule: $schedule, dueTime: $dueTime, proof: $proof, pointsEarn: $pointsEarn)';
}


}

/// @nodoc
abstract mixin class _$DraftTaskCopyWith<$Res> implements $DraftTaskCopyWith<$Res> {
  factory _$DraftTaskCopyWith(_DraftTask value, $Res Function(_DraftTask) _then) = __$DraftTaskCopyWithImpl;
@override @useResult
$Res call({
 String title, String? detail, String kind, Map<String, dynamic>? schedule, String? dueTime, String proof, int pointsEarn
});




}
/// @nodoc
class __$DraftTaskCopyWithImpl<$Res>
    implements _$DraftTaskCopyWith<$Res> {
  __$DraftTaskCopyWithImpl(this._self, this._then);

  final _DraftTask _self;
  final $Res Function(_DraftTask) _then;

/// Create a copy of DraftTask
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? detail = freezed,Object? kind = null,Object? schedule = freezed,Object? dueTime = freezed,Object? proof = null,Object? pointsEarn = null,}) {
  return _then(_DraftTask(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,detail: freezed == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String?,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,schedule: freezed == schedule ? _self._schedule : schedule // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,dueTime: freezed == dueTime ? _self.dueTime : dueTime // ignore: cast_nullable_to_non_nullable
as String?,proof: null == proof ? _self.proof : proof // ignore: cast_nullable_to_non_nullable
as String,pointsEarn: null == pointsEarn ? _self.pointsEarn : pointsEarn // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$DraftRule {

 String get title; String? get body; String get group;
/// Create a copy of DraftRule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DraftRuleCopyWith<DraftRule> get copyWith => _$DraftRuleCopyWithImpl<DraftRule>(this as DraftRule, _$identity);

  /// Serializes this DraftRule to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DraftRule&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.group, group) || other.group == group));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,body,group);

@override
String toString() {
  return 'DraftRule(title: $title, body: $body, group: $group)';
}


}

/// @nodoc
abstract mixin class $DraftRuleCopyWith<$Res>  {
  factory $DraftRuleCopyWith(DraftRule value, $Res Function(DraftRule) _then) = _$DraftRuleCopyWithImpl;
@useResult
$Res call({
 String title, String? body, String group
});




}
/// @nodoc
class _$DraftRuleCopyWithImpl<$Res>
    implements $DraftRuleCopyWith<$Res> {
  _$DraftRuleCopyWithImpl(this._self, this._then);

  final DraftRule _self;
  final $Res Function(DraftRule) _then;

/// Create a copy of DraftRule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? body = freezed,Object? group = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,group: null == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DraftRule].
extension DraftRulePatterns on DraftRule {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DraftRule value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DraftRule() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DraftRule value)  $default,){
final _that = this;
switch (_that) {
case _DraftRule():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DraftRule value)?  $default,){
final _that = this;
switch (_that) {
case _DraftRule() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String? body,  String group)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DraftRule() when $default != null:
return $default(_that.title,_that.body,_that.group);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String? body,  String group)  $default,) {final _that = this;
switch (_that) {
case _DraftRule():
return $default(_that.title,_that.body,_that.group);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String? body,  String group)?  $default,) {final _that = this;
switch (_that) {
case _DraftRule() when $default != null:
return $default(_that.title,_that.body,_that.group);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DraftRule implements DraftRule {
  const _DraftRule({required this.title, this.body, this.group = 'other'});
  factory _DraftRule.fromJson(Map<String, dynamic> json) => _$DraftRuleFromJson(json);

@override final  String title;
@override final  String? body;
@override@JsonKey() final  String group;

/// Create a copy of DraftRule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DraftRuleCopyWith<_DraftRule> get copyWith => __$DraftRuleCopyWithImpl<_DraftRule>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DraftRuleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DraftRule&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.group, group) || other.group == group));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,body,group);

@override
String toString() {
  return 'DraftRule(title: $title, body: $body, group: $group)';
}


}

/// @nodoc
abstract mixin class _$DraftRuleCopyWith<$Res> implements $DraftRuleCopyWith<$Res> {
  factory _$DraftRuleCopyWith(_DraftRule value, $Res Function(_DraftRule) _then) = __$DraftRuleCopyWithImpl;
@override @useResult
$Res call({
 String title, String? body, String group
});




}
/// @nodoc
class __$DraftRuleCopyWithImpl<$Res>
    implements _$DraftRuleCopyWith<$Res> {
  __$DraftRuleCopyWithImpl(this._self, this._then);

  final _DraftRule _self;
  final $Res Function(_DraftRule) _then;

/// Create a copy of DraftRule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? body = freezed,Object? group = null,}) {
  return _then(_DraftRule(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,group: null == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$DraftReward {

 String get title; String? get detail; int? get cost;
/// Create a copy of DraftReward
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DraftRewardCopyWith<DraftReward> get copyWith => _$DraftRewardCopyWithImpl<DraftReward>(this as DraftReward, _$identity);

  /// Serializes this DraftReward to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DraftReward&&(identical(other.title, title) || other.title == title)&&(identical(other.detail, detail) || other.detail == detail)&&(identical(other.cost, cost) || other.cost == cost));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,detail,cost);

@override
String toString() {
  return 'DraftReward(title: $title, detail: $detail, cost: $cost)';
}


}

/// @nodoc
abstract mixin class $DraftRewardCopyWith<$Res>  {
  factory $DraftRewardCopyWith(DraftReward value, $Res Function(DraftReward) _then) = _$DraftRewardCopyWithImpl;
@useResult
$Res call({
 String title, String? detail, int? cost
});




}
/// @nodoc
class _$DraftRewardCopyWithImpl<$Res>
    implements $DraftRewardCopyWith<$Res> {
  _$DraftRewardCopyWithImpl(this._self, this._then);

  final DraftReward _self;
  final $Res Function(DraftReward) _then;

/// Create a copy of DraftReward
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? detail = freezed,Object? cost = freezed,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,detail: freezed == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String?,cost: freezed == cost ? _self.cost : cost // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [DraftReward].
extension DraftRewardPatterns on DraftReward {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DraftReward value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DraftReward() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DraftReward value)  $default,){
final _that = this;
switch (_that) {
case _DraftReward():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DraftReward value)?  $default,){
final _that = this;
switch (_that) {
case _DraftReward() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String? detail,  int? cost)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DraftReward() when $default != null:
return $default(_that.title,_that.detail,_that.cost);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String? detail,  int? cost)  $default,) {final _that = this;
switch (_that) {
case _DraftReward():
return $default(_that.title,_that.detail,_that.cost);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String? detail,  int? cost)?  $default,) {final _that = this;
switch (_that) {
case _DraftReward() when $default != null:
return $default(_that.title,_that.detail,_that.cost);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DraftReward implements DraftReward {
  const _DraftReward({required this.title, this.detail, this.cost});
  factory _DraftReward.fromJson(Map<String, dynamic> json) => _$DraftRewardFromJson(json);

@override final  String title;
@override final  String? detail;
@override final  int? cost;

/// Create a copy of DraftReward
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DraftRewardCopyWith<_DraftReward> get copyWith => __$DraftRewardCopyWithImpl<_DraftReward>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DraftRewardToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DraftReward&&(identical(other.title, title) || other.title == title)&&(identical(other.detail, detail) || other.detail == detail)&&(identical(other.cost, cost) || other.cost == cost));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,detail,cost);

@override
String toString() {
  return 'DraftReward(title: $title, detail: $detail, cost: $cost)';
}


}

/// @nodoc
abstract mixin class _$DraftRewardCopyWith<$Res> implements $DraftRewardCopyWith<$Res> {
  factory _$DraftRewardCopyWith(_DraftReward value, $Res Function(_DraftReward) _then) = __$DraftRewardCopyWithImpl;
@override @useResult
$Res call({
 String title, String? detail, int? cost
});




}
/// @nodoc
class __$DraftRewardCopyWithImpl<$Res>
    implements _$DraftRewardCopyWith<$Res> {
  __$DraftRewardCopyWithImpl(this._self, this._then);

  final _DraftReward _self;
  final $Res Function(_DraftReward) _then;

/// Create a copy of DraftReward
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? detail = freezed,Object? cost = freezed,}) {
  return _then(_DraftReward(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,detail: freezed == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String?,cost: freezed == cost ? _self.cost : cost // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$PackDraft {

 List<DraftTask> get tasks; List<DraftRule> get rules; List<DraftReward> get rewards;
/// Create a copy of PackDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PackDraftCopyWith<PackDraft> get copyWith => _$PackDraftCopyWithImpl<PackDraft>(this as PackDraft, _$identity);

  /// Serializes this PackDraft to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PackDraft&&const DeepCollectionEquality().equals(other.tasks, tasks)&&const DeepCollectionEquality().equals(other.rules, rules)&&const DeepCollectionEquality().equals(other.rewards, rewards));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(tasks),const DeepCollectionEquality().hash(rules),const DeepCollectionEquality().hash(rewards));

@override
String toString() {
  return 'PackDraft(tasks: $tasks, rules: $rules, rewards: $rewards)';
}


}

/// @nodoc
abstract mixin class $PackDraftCopyWith<$Res>  {
  factory $PackDraftCopyWith(PackDraft value, $Res Function(PackDraft) _then) = _$PackDraftCopyWithImpl;
@useResult
$Res call({
 List<DraftTask> tasks, List<DraftRule> rules, List<DraftReward> rewards
});




}
/// @nodoc
class _$PackDraftCopyWithImpl<$Res>
    implements $PackDraftCopyWith<$Res> {
  _$PackDraftCopyWithImpl(this._self, this._then);

  final PackDraft _self;
  final $Res Function(PackDraft) _then;

/// Create a copy of PackDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tasks = null,Object? rules = null,Object? rewards = null,}) {
  return _then(_self.copyWith(
tasks: null == tasks ? _self.tasks : tasks // ignore: cast_nullable_to_non_nullable
as List<DraftTask>,rules: null == rules ? _self.rules : rules // ignore: cast_nullable_to_non_nullable
as List<DraftRule>,rewards: null == rewards ? _self.rewards : rewards // ignore: cast_nullable_to_non_nullable
as List<DraftReward>,
  ));
}

}


/// Adds pattern-matching-related methods to [PackDraft].
extension PackDraftPatterns on PackDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PackDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PackDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PackDraft value)  $default,){
final _that = this;
switch (_that) {
case _PackDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PackDraft value)?  $default,){
final _that = this;
switch (_that) {
case _PackDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<DraftTask> tasks,  List<DraftRule> rules,  List<DraftReward> rewards)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PackDraft() when $default != null:
return $default(_that.tasks,_that.rules,_that.rewards);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<DraftTask> tasks,  List<DraftRule> rules,  List<DraftReward> rewards)  $default,) {final _that = this;
switch (_that) {
case _PackDraft():
return $default(_that.tasks,_that.rules,_that.rewards);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<DraftTask> tasks,  List<DraftRule> rules,  List<DraftReward> rewards)?  $default,) {final _that = this;
switch (_that) {
case _PackDraft() when $default != null:
return $default(_that.tasks,_that.rules,_that.rewards);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PackDraft extends PackDraft {
  const _PackDraft({final  List<DraftTask> tasks = const <DraftTask>[], final  List<DraftRule> rules = const <DraftRule>[], final  List<DraftReward> rewards = const <DraftReward>[]}): _tasks = tasks,_rules = rules,_rewards = rewards,super._();
  factory _PackDraft.fromJson(Map<String, dynamic> json) => _$PackDraftFromJson(json);

 final  List<DraftTask> _tasks;
@override@JsonKey() List<DraftTask> get tasks {
  if (_tasks is EqualUnmodifiableListView) return _tasks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tasks);
}

 final  List<DraftRule> _rules;
@override@JsonKey() List<DraftRule> get rules {
  if (_rules is EqualUnmodifiableListView) return _rules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rules);
}

 final  List<DraftReward> _rewards;
@override@JsonKey() List<DraftReward> get rewards {
  if (_rewards is EqualUnmodifiableListView) return _rewards;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rewards);
}


/// Create a copy of PackDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PackDraftCopyWith<_PackDraft> get copyWith => __$PackDraftCopyWithImpl<_PackDraft>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PackDraftToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PackDraft&&const DeepCollectionEquality().equals(other._tasks, _tasks)&&const DeepCollectionEquality().equals(other._rules, _rules)&&const DeepCollectionEquality().equals(other._rewards, _rewards));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_tasks),const DeepCollectionEquality().hash(_rules),const DeepCollectionEquality().hash(_rewards));

@override
String toString() {
  return 'PackDraft(tasks: $tasks, rules: $rules, rewards: $rewards)';
}


}

/// @nodoc
abstract mixin class _$PackDraftCopyWith<$Res> implements $PackDraftCopyWith<$Res> {
  factory _$PackDraftCopyWith(_PackDraft value, $Res Function(_PackDraft) _then) = __$PackDraftCopyWithImpl;
@override @useResult
$Res call({
 List<DraftTask> tasks, List<DraftRule> rules, List<DraftReward> rewards
});




}
/// @nodoc
class __$PackDraftCopyWithImpl<$Res>
    implements _$PackDraftCopyWith<$Res> {
  __$PackDraftCopyWithImpl(this._self, this._then);

  final _PackDraft _self;
  final $Res Function(_PackDraft) _then;

/// Create a copy of PackDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tasks = null,Object? rules = null,Object? rewards = null,}) {
  return _then(_PackDraft(
tasks: null == tasks ? _self._tasks : tasks // ignore: cast_nullable_to_non_nullable
as List<DraftTask>,rules: null == rules ? _self._rules : rules // ignore: cast_nullable_to_non_nullable
as List<DraftRule>,rewards: null == rewards ? _self._rewards : rewards // ignore: cast_nullable_to_non_nullable
as List<DraftReward>,
  ));
}


}


/// @nodoc
mixin _$PackApplyResult {

 List<String> get taskIds; List<String> get ruleIds; List<String> get rewardIds;
/// Create a copy of PackApplyResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PackApplyResultCopyWith<PackApplyResult> get copyWith => _$PackApplyResultCopyWithImpl<PackApplyResult>(this as PackApplyResult, _$identity);

  /// Serializes this PackApplyResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PackApplyResult&&const DeepCollectionEquality().equals(other.taskIds, taskIds)&&const DeepCollectionEquality().equals(other.ruleIds, ruleIds)&&const DeepCollectionEquality().equals(other.rewardIds, rewardIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(taskIds),const DeepCollectionEquality().hash(ruleIds),const DeepCollectionEquality().hash(rewardIds));

@override
String toString() {
  return 'PackApplyResult(taskIds: $taskIds, ruleIds: $ruleIds, rewardIds: $rewardIds)';
}


}

/// @nodoc
abstract mixin class $PackApplyResultCopyWith<$Res>  {
  factory $PackApplyResultCopyWith(PackApplyResult value, $Res Function(PackApplyResult) _then) = _$PackApplyResultCopyWithImpl;
@useResult
$Res call({
 List<String> taskIds, List<String> ruleIds, List<String> rewardIds
});




}
/// @nodoc
class _$PackApplyResultCopyWithImpl<$Res>
    implements $PackApplyResultCopyWith<$Res> {
  _$PackApplyResultCopyWithImpl(this._self, this._then);

  final PackApplyResult _self;
  final $Res Function(PackApplyResult) _then;

/// Create a copy of PackApplyResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? taskIds = null,Object? ruleIds = null,Object? rewardIds = null,}) {
  return _then(_self.copyWith(
taskIds: null == taskIds ? _self.taskIds : taskIds // ignore: cast_nullable_to_non_nullable
as List<String>,ruleIds: null == ruleIds ? _self.ruleIds : ruleIds // ignore: cast_nullable_to_non_nullable
as List<String>,rewardIds: null == rewardIds ? _self.rewardIds : rewardIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [PackApplyResult].
extension PackApplyResultPatterns on PackApplyResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PackApplyResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PackApplyResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PackApplyResult value)  $default,){
final _that = this;
switch (_that) {
case _PackApplyResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PackApplyResult value)?  $default,){
final _that = this;
switch (_that) {
case _PackApplyResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> taskIds,  List<String> ruleIds,  List<String> rewardIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PackApplyResult() when $default != null:
return $default(_that.taskIds,_that.ruleIds,_that.rewardIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> taskIds,  List<String> ruleIds,  List<String> rewardIds)  $default,) {final _that = this;
switch (_that) {
case _PackApplyResult():
return $default(_that.taskIds,_that.ruleIds,_that.rewardIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> taskIds,  List<String> ruleIds,  List<String> rewardIds)?  $default,) {final _that = this;
switch (_that) {
case _PackApplyResult() when $default != null:
return $default(_that.taskIds,_that.ruleIds,_that.rewardIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PackApplyResult implements PackApplyResult {
  const _PackApplyResult({final  List<String> taskIds = const <String>[], final  List<String> ruleIds = const <String>[], final  List<String> rewardIds = const <String>[]}): _taskIds = taskIds,_ruleIds = ruleIds,_rewardIds = rewardIds;
  factory _PackApplyResult.fromJson(Map<String, dynamic> json) => _$PackApplyResultFromJson(json);

 final  List<String> _taskIds;
@override@JsonKey() List<String> get taskIds {
  if (_taskIds is EqualUnmodifiableListView) return _taskIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_taskIds);
}

 final  List<String> _ruleIds;
@override@JsonKey() List<String> get ruleIds {
  if (_ruleIds is EqualUnmodifiableListView) return _ruleIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ruleIds);
}

 final  List<String> _rewardIds;
@override@JsonKey() List<String> get rewardIds {
  if (_rewardIds is EqualUnmodifiableListView) return _rewardIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rewardIds);
}


/// Create a copy of PackApplyResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PackApplyResultCopyWith<_PackApplyResult> get copyWith => __$PackApplyResultCopyWithImpl<_PackApplyResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PackApplyResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PackApplyResult&&const DeepCollectionEquality().equals(other._taskIds, _taskIds)&&const DeepCollectionEquality().equals(other._ruleIds, _ruleIds)&&const DeepCollectionEquality().equals(other._rewardIds, _rewardIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_taskIds),const DeepCollectionEquality().hash(_ruleIds),const DeepCollectionEquality().hash(_rewardIds));

@override
String toString() {
  return 'PackApplyResult(taskIds: $taskIds, ruleIds: $ruleIds, rewardIds: $rewardIds)';
}


}

/// @nodoc
abstract mixin class _$PackApplyResultCopyWith<$Res> implements $PackApplyResultCopyWith<$Res> {
  factory _$PackApplyResultCopyWith(_PackApplyResult value, $Res Function(_PackApplyResult) _then) = __$PackApplyResultCopyWithImpl;
@override @useResult
$Res call({
 List<String> taskIds, List<String> ruleIds, List<String> rewardIds
});




}
/// @nodoc
class __$PackApplyResultCopyWithImpl<$Res>
    implements _$PackApplyResultCopyWith<$Res> {
  __$PackApplyResultCopyWithImpl(this._self, this._then);

  final _PackApplyResult _self;
  final $Res Function(_PackApplyResult) _then;

/// Create a copy of PackApplyResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? taskIds = null,Object? ruleIds = null,Object? rewardIds = null,}) {
  return _then(_PackApplyResult(
taskIds: null == taskIds ? _self._taskIds : taskIds // ignore: cast_nullable_to_non_nullable
as List<String>,ruleIds: null == ruleIds ? _self._ruleIds : ruleIds // ignore: cast_nullable_to_non_nullable
as List<String>,rewardIds: null == rewardIds ? _self._rewardIds : rewardIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
