// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'occurrence.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Occurrence {

 String get id; String get definitionId; String get dynamicId; OccurrenceState get state;/// The relationship day this belongs to, per the Dynamic's day boundary.
 DateTime get relationshipDay; DateTime? get dueAt;/// Server-supplied UX convenience only. Authorization is still enforced
/// server-side on every command endpoint (Notion 06 §7).
 List<String> get allowedActions;
/// Create a copy of Occurrence
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OccurrenceCopyWith<Occurrence> get copyWith => _$OccurrenceCopyWithImpl<Occurrence>(this as Occurrence, _$identity);

  /// Serializes this Occurrence to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Occurrence&&(identical(other.id, id) || other.id == id)&&(identical(other.definitionId, definitionId) || other.definitionId == definitionId)&&(identical(other.dynamicId, dynamicId) || other.dynamicId == dynamicId)&&(identical(other.state, state) || other.state == state)&&(identical(other.relationshipDay, relationshipDay) || other.relationshipDay == relationshipDay)&&(identical(other.dueAt, dueAt) || other.dueAt == dueAt)&&const DeepCollectionEquality().equals(other.allowedActions, allowedActions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,definitionId,dynamicId,state,relationshipDay,dueAt,const DeepCollectionEquality().hash(allowedActions));

@override
String toString() {
  return 'Occurrence(id: $id, definitionId: $definitionId, dynamicId: $dynamicId, state: $state, relationshipDay: $relationshipDay, dueAt: $dueAt, allowedActions: $allowedActions)';
}


}

/// @nodoc
abstract mixin class $OccurrenceCopyWith<$Res>  {
  factory $OccurrenceCopyWith(Occurrence value, $Res Function(Occurrence) _then) = _$OccurrenceCopyWithImpl;
@useResult
$Res call({
 String id, String definitionId, String dynamicId, OccurrenceState state, DateTime relationshipDay, DateTime? dueAt, List<String> allowedActions
});




}
/// @nodoc
class _$OccurrenceCopyWithImpl<$Res>
    implements $OccurrenceCopyWith<$Res> {
  _$OccurrenceCopyWithImpl(this._self, this._then);

  final Occurrence _self;
  final $Res Function(Occurrence) _then;

/// Create a copy of Occurrence
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? definitionId = null,Object? dynamicId = null,Object? state = null,Object? relationshipDay = null,Object? dueAt = freezed,Object? allowedActions = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,definitionId: null == definitionId ? _self.definitionId : definitionId // ignore: cast_nullable_to_non_nullable
as String,dynamicId: null == dynamicId ? _self.dynamicId : dynamicId // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as OccurrenceState,relationshipDay: null == relationshipDay ? _self.relationshipDay : relationshipDay // ignore: cast_nullable_to_non_nullable
as DateTime,dueAt: freezed == dueAt ? _self.dueAt : dueAt // ignore: cast_nullable_to_non_nullable
as DateTime?,allowedActions: null == allowedActions ? _self.allowedActions : allowedActions // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [Occurrence].
extension OccurrencePatterns on Occurrence {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Occurrence value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Occurrence() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Occurrence value)  $default,){
final _that = this;
switch (_that) {
case _Occurrence():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Occurrence value)?  $default,){
final _that = this;
switch (_that) {
case _Occurrence() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String definitionId,  String dynamicId,  OccurrenceState state,  DateTime relationshipDay,  DateTime? dueAt,  List<String> allowedActions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Occurrence() when $default != null:
return $default(_that.id,_that.definitionId,_that.dynamicId,_that.state,_that.relationshipDay,_that.dueAt,_that.allowedActions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String definitionId,  String dynamicId,  OccurrenceState state,  DateTime relationshipDay,  DateTime? dueAt,  List<String> allowedActions)  $default,) {final _that = this;
switch (_that) {
case _Occurrence():
return $default(_that.id,_that.definitionId,_that.dynamicId,_that.state,_that.relationshipDay,_that.dueAt,_that.allowedActions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String definitionId,  String dynamicId,  OccurrenceState state,  DateTime relationshipDay,  DateTime? dueAt,  List<String> allowedActions)?  $default,) {final _that = this;
switch (_that) {
case _Occurrence() when $default != null:
return $default(_that.id,_that.definitionId,_that.dynamicId,_that.state,_that.relationshipDay,_that.dueAt,_that.allowedActions);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Occurrence implements Occurrence {
  const _Occurrence({required this.id, required this.definitionId, required this.dynamicId, required this.state, required this.relationshipDay, this.dueAt, final  List<String> allowedActions = const <String>[]}): _allowedActions = allowedActions;
  factory _Occurrence.fromJson(Map<String, dynamic> json) => _$OccurrenceFromJson(json);

@override final  String id;
@override final  String definitionId;
@override final  String dynamicId;
@override final  OccurrenceState state;
/// The relationship day this belongs to, per the Dynamic's day boundary.
@override final  DateTime relationshipDay;
@override final  DateTime? dueAt;
/// Server-supplied UX convenience only. Authorization is still enforced
/// server-side on every command endpoint (Notion 06 §7).
 final  List<String> _allowedActions;
/// Server-supplied UX convenience only. Authorization is still enforced
/// server-side on every command endpoint (Notion 06 §7).
@override@JsonKey() List<String> get allowedActions {
  if (_allowedActions is EqualUnmodifiableListView) return _allowedActions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allowedActions);
}


/// Create a copy of Occurrence
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OccurrenceCopyWith<_Occurrence> get copyWith => __$OccurrenceCopyWithImpl<_Occurrence>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OccurrenceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Occurrence&&(identical(other.id, id) || other.id == id)&&(identical(other.definitionId, definitionId) || other.definitionId == definitionId)&&(identical(other.dynamicId, dynamicId) || other.dynamicId == dynamicId)&&(identical(other.state, state) || other.state == state)&&(identical(other.relationshipDay, relationshipDay) || other.relationshipDay == relationshipDay)&&(identical(other.dueAt, dueAt) || other.dueAt == dueAt)&&const DeepCollectionEquality().equals(other._allowedActions, _allowedActions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,definitionId,dynamicId,state,relationshipDay,dueAt,const DeepCollectionEquality().hash(_allowedActions));

@override
String toString() {
  return 'Occurrence(id: $id, definitionId: $definitionId, dynamicId: $dynamicId, state: $state, relationshipDay: $relationshipDay, dueAt: $dueAt, allowedActions: $allowedActions)';
}


}

/// @nodoc
abstract mixin class _$OccurrenceCopyWith<$Res> implements $OccurrenceCopyWith<$Res> {
  factory _$OccurrenceCopyWith(_Occurrence value, $Res Function(_Occurrence) _then) = __$OccurrenceCopyWithImpl;
@override @useResult
$Res call({
 String id, String definitionId, String dynamicId, OccurrenceState state, DateTime relationshipDay, DateTime? dueAt, List<String> allowedActions
});




}
/// @nodoc
class __$OccurrenceCopyWithImpl<$Res>
    implements _$OccurrenceCopyWith<$Res> {
  __$OccurrenceCopyWithImpl(this._self, this._then);

  final _Occurrence _self;
  final $Res Function(_Occurrence) _then;

/// Create a copy of Occurrence
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? definitionId = null,Object? dynamicId = null,Object? state = null,Object? relationshipDay = null,Object? dueAt = freezed,Object? allowedActions = null,}) {
  return _then(_Occurrence(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,definitionId: null == definitionId ? _self.definitionId : definitionId // ignore: cast_nullable_to_non_nullable
as String,dynamicId: null == dynamicId ? _self.dynamicId : dynamicId // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as OccurrenceState,relationshipDay: null == relationshipDay ? _self.relationshipDay : relationshipDay // ignore: cast_nullable_to_non_nullable
as DateTime,dueAt: freezed == dueAt ? _self.dueAt : dueAt // ignore: cast_nullable_to_non_nullable
as DateTime?,allowedActions: null == allowedActions ? _self._allowedActions : allowedActions // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
