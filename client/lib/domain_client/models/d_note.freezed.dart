// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'd_note.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DNote {

 String get id; String get body; DateTime? get remindAt; DateTime? get remindedAt; DateTime? get doneAt; DateTime get createdAt;
/// Create a copy of DNote
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DNoteCopyWith<DNote> get copyWith => _$DNoteCopyWithImpl<DNote>(this as DNote, _$identity);

  /// Serializes this DNote to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DNote&&(identical(other.id, id) || other.id == id)&&(identical(other.body, body) || other.body == body)&&(identical(other.remindAt, remindAt) || other.remindAt == remindAt)&&(identical(other.remindedAt, remindedAt) || other.remindedAt == remindedAt)&&(identical(other.doneAt, doneAt) || other.doneAt == doneAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,body,remindAt,remindedAt,doneAt,createdAt);

@override
String toString() {
  return 'DNote(id: $id, body: $body, remindAt: $remindAt, remindedAt: $remindedAt, doneAt: $doneAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $DNoteCopyWith<$Res>  {
  factory $DNoteCopyWith(DNote value, $Res Function(DNote) _then) = _$DNoteCopyWithImpl;
@useResult
$Res call({
 String id, String body, DateTime? remindAt, DateTime? remindedAt, DateTime? doneAt, DateTime createdAt
});




}
/// @nodoc
class _$DNoteCopyWithImpl<$Res>
    implements $DNoteCopyWith<$Res> {
  _$DNoteCopyWithImpl(this._self, this._then);

  final DNote _self;
  final $Res Function(DNote) _then;

/// Create a copy of DNote
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? body = null,Object? remindAt = freezed,Object? remindedAt = freezed,Object? doneAt = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,remindAt: freezed == remindAt ? _self.remindAt : remindAt // ignore: cast_nullable_to_non_nullable
as DateTime?,remindedAt: freezed == remindedAt ? _self.remindedAt : remindedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,doneAt: freezed == doneAt ? _self.doneAt : doneAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [DNote].
extension DNotePatterns on DNote {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DNote value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DNote() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DNote value)  $default,){
final _that = this;
switch (_that) {
case _DNote():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DNote value)?  $default,){
final _that = this;
switch (_that) {
case _DNote() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String body,  DateTime? remindAt,  DateTime? remindedAt,  DateTime? doneAt,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DNote() when $default != null:
return $default(_that.id,_that.body,_that.remindAt,_that.remindedAt,_that.doneAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String body,  DateTime? remindAt,  DateTime? remindedAt,  DateTime? doneAt,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _DNote():
return $default(_that.id,_that.body,_that.remindAt,_that.remindedAt,_that.doneAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String body,  DateTime? remindAt,  DateTime? remindedAt,  DateTime? doneAt,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _DNote() when $default != null:
return $default(_that.id,_that.body,_that.remindAt,_that.remindedAt,_that.doneAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DNote implements DNote {
  const _DNote({required this.id, required this.body, this.remindAt, this.remindedAt, this.doneAt, required this.createdAt});
  factory _DNote.fromJson(Map<String, dynamic> json) => _$DNoteFromJson(json);

@override final  String id;
@override final  String body;
@override final  DateTime? remindAt;
@override final  DateTime? remindedAt;
@override final  DateTime? doneAt;
@override final  DateTime createdAt;

/// Create a copy of DNote
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DNoteCopyWith<_DNote> get copyWith => __$DNoteCopyWithImpl<_DNote>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DNoteToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DNote&&(identical(other.id, id) || other.id == id)&&(identical(other.body, body) || other.body == body)&&(identical(other.remindAt, remindAt) || other.remindAt == remindAt)&&(identical(other.remindedAt, remindedAt) || other.remindedAt == remindedAt)&&(identical(other.doneAt, doneAt) || other.doneAt == doneAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,body,remindAt,remindedAt,doneAt,createdAt);

@override
String toString() {
  return 'DNote(id: $id, body: $body, remindAt: $remindAt, remindedAt: $remindedAt, doneAt: $doneAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$DNoteCopyWith<$Res> implements $DNoteCopyWith<$Res> {
  factory _$DNoteCopyWith(_DNote value, $Res Function(_DNote) _then) = __$DNoteCopyWithImpl;
@override @useResult
$Res call({
 String id, String body, DateTime? remindAt, DateTime? remindedAt, DateTime? doneAt, DateTime createdAt
});




}
/// @nodoc
class __$DNoteCopyWithImpl<$Res>
    implements _$DNoteCopyWith<$Res> {
  __$DNoteCopyWithImpl(this._self, this._then);

  final _DNote _self;
  final $Res Function(_DNote) _then;

/// Create a copy of DNote
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? body = null,Object? remindAt = freezed,Object? remindedAt = freezed,Object? doneAt = freezed,Object? createdAt = null,}) {
  return _then(_DNote(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,remindAt: freezed == remindAt ? _self.remindAt : remindAt // ignore: cast_nullable_to_non_nullable
as DateTime?,remindedAt: freezed == remindedAt ? _self.remindedAt : remindedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,doneAt: freezed == doneAt ? _self.doneAt : doneAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
