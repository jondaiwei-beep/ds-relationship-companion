// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'check_in_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CheckInView {

 String get id; DateTime get relationshipDay; String? get mood; String? get energy; String? get need; String? get note; String get visibility; DateTime get createdAt; String? get creatorDisplayName;/// True when the viewer wrote it.
 bool get isMine;
/// Create a copy of CheckInView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckInViewCopyWith<CheckInView> get copyWith => _$CheckInViewCopyWithImpl<CheckInView>(this as CheckInView, _$identity);

  /// Serializes this CheckInView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckInView&&(identical(other.id, id) || other.id == id)&&(identical(other.relationshipDay, relationshipDay) || other.relationshipDay == relationshipDay)&&(identical(other.mood, mood) || other.mood == mood)&&(identical(other.energy, energy) || other.energy == energy)&&(identical(other.need, need) || other.need == need)&&(identical(other.note, note) || other.note == note)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.creatorDisplayName, creatorDisplayName) || other.creatorDisplayName == creatorDisplayName)&&(identical(other.isMine, isMine) || other.isMine == isMine));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,relationshipDay,mood,energy,need,note,visibility,createdAt,creatorDisplayName,isMine);

@override
String toString() {
  return 'CheckInView(id: $id, relationshipDay: $relationshipDay, mood: $mood, energy: $energy, need: $need, note: $note, visibility: $visibility, createdAt: $createdAt, creatorDisplayName: $creatorDisplayName, isMine: $isMine)';
}


}

/// @nodoc
abstract mixin class $CheckInViewCopyWith<$Res>  {
  factory $CheckInViewCopyWith(CheckInView value, $Res Function(CheckInView) _then) = _$CheckInViewCopyWithImpl;
@useResult
$Res call({
 String id, DateTime relationshipDay, String? mood, String? energy, String? need, String? note, String visibility, DateTime createdAt, String? creatorDisplayName, bool isMine
});




}
/// @nodoc
class _$CheckInViewCopyWithImpl<$Res>
    implements $CheckInViewCopyWith<$Res> {
  _$CheckInViewCopyWithImpl(this._self, this._then);

  final CheckInView _self;
  final $Res Function(CheckInView) _then;

/// Create a copy of CheckInView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? relationshipDay = null,Object? mood = freezed,Object? energy = freezed,Object? need = freezed,Object? note = freezed,Object? visibility = null,Object? createdAt = null,Object? creatorDisplayName = freezed,Object? isMine = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,relationshipDay: null == relationshipDay ? _self.relationshipDay : relationshipDay // ignore: cast_nullable_to_non_nullable
as DateTime,mood: freezed == mood ? _self.mood : mood // ignore: cast_nullable_to_non_nullable
as String?,energy: freezed == energy ? _self.energy : energy // ignore: cast_nullable_to_non_nullable
as String?,need: freezed == need ? _self.need : need // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,creatorDisplayName: freezed == creatorDisplayName ? _self.creatorDisplayName : creatorDisplayName // ignore: cast_nullable_to_non_nullable
as String?,isMine: null == isMine ? _self.isMine : isMine // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CheckInView].
extension CheckInViewPatterns on CheckInView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CheckInView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CheckInView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CheckInView value)  $default,){
final _that = this;
switch (_that) {
case _CheckInView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CheckInView value)?  $default,){
final _that = this;
switch (_that) {
case _CheckInView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime relationshipDay,  String? mood,  String? energy,  String? need,  String? note,  String visibility,  DateTime createdAt,  String? creatorDisplayName,  bool isMine)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CheckInView() when $default != null:
return $default(_that.id,_that.relationshipDay,_that.mood,_that.energy,_that.need,_that.note,_that.visibility,_that.createdAt,_that.creatorDisplayName,_that.isMine);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime relationshipDay,  String? mood,  String? energy,  String? need,  String? note,  String visibility,  DateTime createdAt,  String? creatorDisplayName,  bool isMine)  $default,) {final _that = this;
switch (_that) {
case _CheckInView():
return $default(_that.id,_that.relationshipDay,_that.mood,_that.energy,_that.need,_that.note,_that.visibility,_that.createdAt,_that.creatorDisplayName,_that.isMine);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime relationshipDay,  String? mood,  String? energy,  String? need,  String? note,  String visibility,  DateTime createdAt,  String? creatorDisplayName,  bool isMine)?  $default,) {final _that = this;
switch (_that) {
case _CheckInView() when $default != null:
return $default(_that.id,_that.relationshipDay,_that.mood,_that.energy,_that.need,_that.note,_that.visibility,_that.createdAt,_that.creatorDisplayName,_that.isMine);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CheckInView implements CheckInView {
  const _CheckInView({required this.id, required this.relationshipDay, this.mood, this.energy, this.need, this.note, required this.visibility, required this.createdAt, this.creatorDisplayName, this.isMine = false});
  factory _CheckInView.fromJson(Map<String, dynamic> json) => _$CheckInViewFromJson(json);

@override final  String id;
@override final  DateTime relationshipDay;
@override final  String? mood;
@override final  String? energy;
@override final  String? need;
@override final  String? note;
@override final  String visibility;
@override final  DateTime createdAt;
@override final  String? creatorDisplayName;
/// True when the viewer wrote it.
@override@JsonKey() final  bool isMine;

/// Create a copy of CheckInView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CheckInViewCopyWith<_CheckInView> get copyWith => __$CheckInViewCopyWithImpl<_CheckInView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CheckInViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CheckInView&&(identical(other.id, id) || other.id == id)&&(identical(other.relationshipDay, relationshipDay) || other.relationshipDay == relationshipDay)&&(identical(other.mood, mood) || other.mood == mood)&&(identical(other.energy, energy) || other.energy == energy)&&(identical(other.need, need) || other.need == need)&&(identical(other.note, note) || other.note == note)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.creatorDisplayName, creatorDisplayName) || other.creatorDisplayName == creatorDisplayName)&&(identical(other.isMine, isMine) || other.isMine == isMine));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,relationshipDay,mood,energy,need,note,visibility,createdAt,creatorDisplayName,isMine);

@override
String toString() {
  return 'CheckInView(id: $id, relationshipDay: $relationshipDay, mood: $mood, energy: $energy, need: $need, note: $note, visibility: $visibility, createdAt: $createdAt, creatorDisplayName: $creatorDisplayName, isMine: $isMine)';
}


}

/// @nodoc
abstract mixin class _$CheckInViewCopyWith<$Res> implements $CheckInViewCopyWith<$Res> {
  factory _$CheckInViewCopyWith(_CheckInView value, $Res Function(_CheckInView) _then) = __$CheckInViewCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime relationshipDay, String? mood, String? energy, String? need, String? note, String visibility, DateTime createdAt, String? creatorDisplayName, bool isMine
});




}
/// @nodoc
class __$CheckInViewCopyWithImpl<$Res>
    implements _$CheckInViewCopyWith<$Res> {
  __$CheckInViewCopyWithImpl(this._self, this._then);

  final _CheckInView _self;
  final $Res Function(_CheckInView) _then;

/// Create a copy of CheckInView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? relationshipDay = null,Object? mood = freezed,Object? energy = freezed,Object? need = freezed,Object? note = freezed,Object? visibility = null,Object? createdAt = null,Object? creatorDisplayName = freezed,Object? isMine = null,}) {
  return _then(_CheckInView(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,relationshipDay: null == relationshipDay ? _self.relationshipDay : relationshipDay // ignore: cast_nullable_to_non_nullable
as DateTime,mood: freezed == mood ? _self.mood : mood // ignore: cast_nullable_to_non_nullable
as String?,energy: freezed == energy ? _self.energy : energy // ignore: cast_nullable_to_non_nullable
as String?,need: freezed == need ? _self.need : need // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,creatorDisplayName: freezed == creatorDisplayName ? _self.creatorDisplayName : creatorDisplayName // ignore: cast_nullable_to_non_nullable
as String?,isMine: null == isMine ? _self.isMine : isMine // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
