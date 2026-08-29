// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'invite_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InviteView {

 InviteState get state; String? get inviteId; String? get dynamicId; String? get intendedRoleContext;/// Shown before authentication so the invitee knows who invited them.
 String? get inviterDisplayName;
/// Create a copy of InviteView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InviteViewCopyWith<InviteView> get copyWith => _$InviteViewCopyWithImpl<InviteView>(this as InviteView, _$identity);

  /// Serializes this InviteView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InviteView&&(identical(other.state, state) || other.state == state)&&(identical(other.inviteId, inviteId) || other.inviteId == inviteId)&&(identical(other.dynamicId, dynamicId) || other.dynamicId == dynamicId)&&(identical(other.intendedRoleContext, intendedRoleContext) || other.intendedRoleContext == intendedRoleContext)&&(identical(other.inviterDisplayName, inviterDisplayName) || other.inviterDisplayName == inviterDisplayName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,state,inviteId,dynamicId,intendedRoleContext,inviterDisplayName);

@override
String toString() {
  return 'InviteView(state: $state, inviteId: $inviteId, dynamicId: $dynamicId, intendedRoleContext: $intendedRoleContext, inviterDisplayName: $inviterDisplayName)';
}


}

/// @nodoc
abstract mixin class $InviteViewCopyWith<$Res>  {
  factory $InviteViewCopyWith(InviteView value, $Res Function(InviteView) _then) = _$InviteViewCopyWithImpl;
@useResult
$Res call({
 InviteState state, String? inviteId, String? dynamicId, String? intendedRoleContext, String? inviterDisplayName
});




}
/// @nodoc
class _$InviteViewCopyWithImpl<$Res>
    implements $InviteViewCopyWith<$Res> {
  _$InviteViewCopyWithImpl(this._self, this._then);

  final InviteView _self;
  final $Res Function(InviteView) _then;

/// Create a copy of InviteView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? state = null,Object? inviteId = freezed,Object? dynamicId = freezed,Object? intendedRoleContext = freezed,Object? inviterDisplayName = freezed,}) {
  return _then(_self.copyWith(
state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as InviteState,inviteId: freezed == inviteId ? _self.inviteId : inviteId // ignore: cast_nullable_to_non_nullable
as String?,dynamicId: freezed == dynamicId ? _self.dynamicId : dynamicId // ignore: cast_nullable_to_non_nullable
as String?,intendedRoleContext: freezed == intendedRoleContext ? _self.intendedRoleContext : intendedRoleContext // ignore: cast_nullable_to_non_nullable
as String?,inviterDisplayName: freezed == inviterDisplayName ? _self.inviterDisplayName : inviterDisplayName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [InviteView].
extension InviteViewPatterns on InviteView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InviteView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InviteView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InviteView value)  $default,){
final _that = this;
switch (_that) {
case _InviteView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InviteView value)?  $default,){
final _that = this;
switch (_that) {
case _InviteView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( InviteState state,  String? inviteId,  String? dynamicId,  String? intendedRoleContext,  String? inviterDisplayName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InviteView() when $default != null:
return $default(_that.state,_that.inviteId,_that.dynamicId,_that.intendedRoleContext,_that.inviterDisplayName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( InviteState state,  String? inviteId,  String? dynamicId,  String? intendedRoleContext,  String? inviterDisplayName)  $default,) {final _that = this;
switch (_that) {
case _InviteView():
return $default(_that.state,_that.inviteId,_that.dynamicId,_that.intendedRoleContext,_that.inviterDisplayName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( InviteState state,  String? inviteId,  String? dynamicId,  String? intendedRoleContext,  String? inviterDisplayName)?  $default,) {final _that = this;
switch (_that) {
case _InviteView() when $default != null:
return $default(_that.state,_that.inviteId,_that.dynamicId,_that.intendedRoleContext,_that.inviterDisplayName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InviteView implements InviteView {
  const _InviteView({required this.state, this.inviteId, this.dynamicId, this.intendedRoleContext, this.inviterDisplayName});
  factory _InviteView.fromJson(Map<String, dynamic> json) => _$InviteViewFromJson(json);

@override final  InviteState state;
@override final  String? inviteId;
@override final  String? dynamicId;
@override final  String? intendedRoleContext;
/// Shown before authentication so the invitee knows who invited them.
@override final  String? inviterDisplayName;

/// Create a copy of InviteView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InviteViewCopyWith<_InviteView> get copyWith => __$InviteViewCopyWithImpl<_InviteView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InviteViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InviteView&&(identical(other.state, state) || other.state == state)&&(identical(other.inviteId, inviteId) || other.inviteId == inviteId)&&(identical(other.dynamicId, dynamicId) || other.dynamicId == dynamicId)&&(identical(other.intendedRoleContext, intendedRoleContext) || other.intendedRoleContext == intendedRoleContext)&&(identical(other.inviterDisplayName, inviterDisplayName) || other.inviterDisplayName == inviterDisplayName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,state,inviteId,dynamicId,intendedRoleContext,inviterDisplayName);

@override
String toString() {
  return 'InviteView(state: $state, inviteId: $inviteId, dynamicId: $dynamicId, intendedRoleContext: $intendedRoleContext, inviterDisplayName: $inviterDisplayName)';
}


}

/// @nodoc
abstract mixin class _$InviteViewCopyWith<$Res> implements $InviteViewCopyWith<$Res> {
  factory _$InviteViewCopyWith(_InviteView value, $Res Function(_InviteView) _then) = __$InviteViewCopyWithImpl;
@override @useResult
$Res call({
 InviteState state, String? inviteId, String? dynamicId, String? intendedRoleContext, String? inviterDisplayName
});




}
/// @nodoc
class __$InviteViewCopyWithImpl<$Res>
    implements _$InviteViewCopyWith<$Res> {
  __$InviteViewCopyWithImpl(this._self, this._then);

  final _InviteView _self;
  final $Res Function(_InviteView) _then;

/// Create a copy of InviteView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? state = null,Object? inviteId = freezed,Object? dynamicId = freezed,Object? intendedRoleContext = freezed,Object? inviterDisplayName = freezed,}) {
  return _then(_InviteView(
state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as InviteState,inviteId: freezed == inviteId ? _self.inviteId : inviteId // ignore: cast_nullable_to_non_nullable
as String?,dynamicId: freezed == dynamicId ? _self.dynamicId : dynamicId // ignore: cast_nullable_to_non_nullable
as String?,intendedRoleContext: freezed == intendedRoleContext ? _self.intendedRoleContext : intendedRoleContext // ignore: cast_nullable_to_non_nullable
as String?,inviterDisplayName: freezed == inviterDisplayName ? _self.inviterDisplayName : inviterDisplayName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
