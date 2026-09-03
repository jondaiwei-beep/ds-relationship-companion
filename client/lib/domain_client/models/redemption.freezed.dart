// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'redemption.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RedemptionView {

 String get id; String get rewardId; String? get rewardTitle; String get subjectUserId;/// `requested | approved | denied | fulfilled`.
 String get status; String? get note; String? get decidedBy; DateTime? get decidedAt; DateTime? get createdAt;
/// Create a copy of RedemptionView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RedemptionViewCopyWith<RedemptionView> get copyWith => _$RedemptionViewCopyWithImpl<RedemptionView>(this as RedemptionView, _$identity);

  /// Serializes this RedemptionView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RedemptionView&&(identical(other.id, id) || other.id == id)&&(identical(other.rewardId, rewardId) || other.rewardId == rewardId)&&(identical(other.rewardTitle, rewardTitle) || other.rewardTitle == rewardTitle)&&(identical(other.subjectUserId, subjectUserId) || other.subjectUserId == subjectUserId)&&(identical(other.status, status) || other.status == status)&&(identical(other.note, note) || other.note == note)&&(identical(other.decidedBy, decidedBy) || other.decidedBy == decidedBy)&&(identical(other.decidedAt, decidedAt) || other.decidedAt == decidedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,rewardId,rewardTitle,subjectUserId,status,note,decidedBy,decidedAt,createdAt);

@override
String toString() {
  return 'RedemptionView(id: $id, rewardId: $rewardId, rewardTitle: $rewardTitle, subjectUserId: $subjectUserId, status: $status, note: $note, decidedBy: $decidedBy, decidedAt: $decidedAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $RedemptionViewCopyWith<$Res>  {
  factory $RedemptionViewCopyWith(RedemptionView value, $Res Function(RedemptionView) _then) = _$RedemptionViewCopyWithImpl;
@useResult
$Res call({
 String id, String rewardId, String? rewardTitle, String subjectUserId, String status, String? note, String? decidedBy, DateTime? decidedAt, DateTime? createdAt
});




}
/// @nodoc
class _$RedemptionViewCopyWithImpl<$Res>
    implements $RedemptionViewCopyWith<$Res> {
  _$RedemptionViewCopyWithImpl(this._self, this._then);

  final RedemptionView _self;
  final $Res Function(RedemptionView) _then;

/// Create a copy of RedemptionView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? rewardId = null,Object? rewardTitle = freezed,Object? subjectUserId = null,Object? status = null,Object? note = freezed,Object? decidedBy = freezed,Object? decidedAt = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,rewardId: null == rewardId ? _self.rewardId : rewardId // ignore: cast_nullable_to_non_nullable
as String,rewardTitle: freezed == rewardTitle ? _self.rewardTitle : rewardTitle // ignore: cast_nullable_to_non_nullable
as String?,subjectUserId: null == subjectUserId ? _self.subjectUserId : subjectUserId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,decidedBy: freezed == decidedBy ? _self.decidedBy : decidedBy // ignore: cast_nullable_to_non_nullable
as String?,decidedAt: freezed == decidedAt ? _self.decidedAt : decidedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [RedemptionView].
extension RedemptionViewPatterns on RedemptionView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RedemptionView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RedemptionView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RedemptionView value)  $default,){
final _that = this;
switch (_that) {
case _RedemptionView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RedemptionView value)?  $default,){
final _that = this;
switch (_that) {
case _RedemptionView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String rewardId,  String? rewardTitle,  String subjectUserId,  String status,  String? note,  String? decidedBy,  DateTime? decidedAt,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RedemptionView() when $default != null:
return $default(_that.id,_that.rewardId,_that.rewardTitle,_that.subjectUserId,_that.status,_that.note,_that.decidedBy,_that.decidedAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String rewardId,  String? rewardTitle,  String subjectUserId,  String status,  String? note,  String? decidedBy,  DateTime? decidedAt,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _RedemptionView():
return $default(_that.id,_that.rewardId,_that.rewardTitle,_that.subjectUserId,_that.status,_that.note,_that.decidedBy,_that.decidedAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String rewardId,  String? rewardTitle,  String subjectUserId,  String status,  String? note,  String? decidedBy,  DateTime? decidedAt,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _RedemptionView() when $default != null:
return $default(_that.id,_that.rewardId,_that.rewardTitle,_that.subjectUserId,_that.status,_that.note,_that.decidedBy,_that.decidedAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RedemptionView extends RedemptionView {
  const _RedemptionView({required this.id, required this.rewardId, this.rewardTitle, required this.subjectUserId, required this.status, this.note, this.decidedBy, this.decidedAt, this.createdAt}): super._();
  factory _RedemptionView.fromJson(Map<String, dynamic> json) => _$RedemptionViewFromJson(json);

@override final  String id;
@override final  String rewardId;
@override final  String? rewardTitle;
@override final  String subjectUserId;
/// `requested | approved | denied | fulfilled`.
@override final  String status;
@override final  String? note;
@override final  String? decidedBy;
@override final  DateTime? decidedAt;
@override final  DateTime? createdAt;

/// Create a copy of RedemptionView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RedemptionViewCopyWith<_RedemptionView> get copyWith => __$RedemptionViewCopyWithImpl<_RedemptionView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RedemptionViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RedemptionView&&(identical(other.id, id) || other.id == id)&&(identical(other.rewardId, rewardId) || other.rewardId == rewardId)&&(identical(other.rewardTitle, rewardTitle) || other.rewardTitle == rewardTitle)&&(identical(other.subjectUserId, subjectUserId) || other.subjectUserId == subjectUserId)&&(identical(other.status, status) || other.status == status)&&(identical(other.note, note) || other.note == note)&&(identical(other.decidedBy, decidedBy) || other.decidedBy == decidedBy)&&(identical(other.decidedAt, decidedAt) || other.decidedAt == decidedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,rewardId,rewardTitle,subjectUserId,status,note,decidedBy,decidedAt,createdAt);

@override
String toString() {
  return 'RedemptionView(id: $id, rewardId: $rewardId, rewardTitle: $rewardTitle, subjectUserId: $subjectUserId, status: $status, note: $note, decidedBy: $decidedBy, decidedAt: $decidedAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$RedemptionViewCopyWith<$Res> implements $RedemptionViewCopyWith<$Res> {
  factory _$RedemptionViewCopyWith(_RedemptionView value, $Res Function(_RedemptionView) _then) = __$RedemptionViewCopyWithImpl;
@override @useResult
$Res call({
 String id, String rewardId, String? rewardTitle, String subjectUserId, String status, String? note, String? decidedBy, DateTime? decidedAt, DateTime? createdAt
});




}
/// @nodoc
class __$RedemptionViewCopyWithImpl<$Res>
    implements _$RedemptionViewCopyWith<$Res> {
  __$RedemptionViewCopyWithImpl(this._self, this._then);

  final _RedemptionView _self;
  final $Res Function(_RedemptionView) _then;

/// Create a copy of RedemptionView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? rewardId = null,Object? rewardTitle = freezed,Object? subjectUserId = null,Object? status = null,Object? note = freezed,Object? decidedBy = freezed,Object? decidedAt = freezed,Object? createdAt = freezed,}) {
  return _then(_RedemptionView(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,rewardId: null == rewardId ? _self.rewardId : rewardId // ignore: cast_nullable_to_non_nullable
as String,rewardTitle: freezed == rewardTitle ? _self.rewardTitle : rewardTitle // ignore: cast_nullable_to_non_nullable
as String?,subjectUserId: null == subjectUserId ? _self.subjectUserId : subjectUserId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,decidedBy: freezed == decidedBy ? _self.decidedBy : decidedBy // ignore: cast_nullable_to_non_nullable
as String?,decidedAt: freezed == decidedAt ? _self.decidedAt : decidedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
