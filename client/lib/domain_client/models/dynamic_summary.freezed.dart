// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dynamic_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DynamicSummary {

 String get dynamicId; String get state; String get roleContext; String? get partnerDisplayName;
/// Create a copy of DynamicSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DynamicSummaryCopyWith<DynamicSummary> get copyWith => _$DynamicSummaryCopyWithImpl<DynamicSummary>(this as DynamicSummary, _$identity);

  /// Serializes this DynamicSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DynamicSummary&&(identical(other.dynamicId, dynamicId) || other.dynamicId == dynamicId)&&(identical(other.state, state) || other.state == state)&&(identical(other.roleContext, roleContext) || other.roleContext == roleContext)&&(identical(other.partnerDisplayName, partnerDisplayName) || other.partnerDisplayName == partnerDisplayName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,dynamicId,state,roleContext,partnerDisplayName);

@override
String toString() {
  return 'DynamicSummary(dynamicId: $dynamicId, state: $state, roleContext: $roleContext, partnerDisplayName: $partnerDisplayName)';
}


}

/// @nodoc
abstract mixin class $DynamicSummaryCopyWith<$Res>  {
  factory $DynamicSummaryCopyWith(DynamicSummary value, $Res Function(DynamicSummary) _then) = _$DynamicSummaryCopyWithImpl;
@useResult
$Res call({
 String dynamicId, String state, String roleContext, String? partnerDisplayName
});




}
/// @nodoc
class _$DynamicSummaryCopyWithImpl<$Res>
    implements $DynamicSummaryCopyWith<$Res> {
  _$DynamicSummaryCopyWithImpl(this._self, this._then);

  final DynamicSummary _self;
  final $Res Function(DynamicSummary) _then;

/// Create a copy of DynamicSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? dynamicId = null,Object? state = null,Object? roleContext = null,Object? partnerDisplayName = freezed,}) {
  return _then(_self.copyWith(
dynamicId: null == dynamicId ? _self.dynamicId : dynamicId // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,roleContext: null == roleContext ? _self.roleContext : roleContext // ignore: cast_nullable_to_non_nullable
as String,partnerDisplayName: freezed == partnerDisplayName ? _self.partnerDisplayName : partnerDisplayName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DynamicSummary].
extension DynamicSummaryPatterns on DynamicSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DynamicSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DynamicSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DynamicSummary value)  $default,){
final _that = this;
switch (_that) {
case _DynamicSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DynamicSummary value)?  $default,){
final _that = this;
switch (_that) {
case _DynamicSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String dynamicId,  String state,  String roleContext,  String? partnerDisplayName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DynamicSummary() when $default != null:
return $default(_that.dynamicId,_that.state,_that.roleContext,_that.partnerDisplayName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String dynamicId,  String state,  String roleContext,  String? partnerDisplayName)  $default,) {final _that = this;
switch (_that) {
case _DynamicSummary():
return $default(_that.dynamicId,_that.state,_that.roleContext,_that.partnerDisplayName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String dynamicId,  String state,  String roleContext,  String? partnerDisplayName)?  $default,) {final _that = this;
switch (_that) {
case _DynamicSummary() when $default != null:
return $default(_that.dynamicId,_that.state,_that.roleContext,_that.partnerDisplayName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DynamicSummary implements DynamicSummary {
  const _DynamicSummary({required this.dynamicId, required this.state, required this.roleContext, this.partnerDisplayName});
  factory _DynamicSummary.fromJson(Map<String, dynamic> json) => _$DynamicSummaryFromJson(json);

@override final  String dynamicId;
@override final  String state;
@override final  String roleContext;
@override final  String? partnerDisplayName;

/// Create a copy of DynamicSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DynamicSummaryCopyWith<_DynamicSummary> get copyWith => __$DynamicSummaryCopyWithImpl<_DynamicSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DynamicSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DynamicSummary&&(identical(other.dynamicId, dynamicId) || other.dynamicId == dynamicId)&&(identical(other.state, state) || other.state == state)&&(identical(other.roleContext, roleContext) || other.roleContext == roleContext)&&(identical(other.partnerDisplayName, partnerDisplayName) || other.partnerDisplayName == partnerDisplayName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,dynamicId,state,roleContext,partnerDisplayName);

@override
String toString() {
  return 'DynamicSummary(dynamicId: $dynamicId, state: $state, roleContext: $roleContext, partnerDisplayName: $partnerDisplayName)';
}


}

/// @nodoc
abstract mixin class _$DynamicSummaryCopyWith<$Res> implements $DynamicSummaryCopyWith<$Res> {
  factory _$DynamicSummaryCopyWith(_DynamicSummary value, $Res Function(_DynamicSummary) _then) = __$DynamicSummaryCopyWithImpl;
@override @useResult
$Res call({
 String dynamicId, String state, String roleContext, String? partnerDisplayName
});




}
/// @nodoc
class __$DynamicSummaryCopyWithImpl<$Res>
    implements _$DynamicSummaryCopyWith<$Res> {
  __$DynamicSummaryCopyWithImpl(this._self, this._then);

  final _DynamicSummary _self;
  final $Res Function(_DynamicSummary) _then;

/// Create a copy of DynamicSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dynamicId = null,Object? state = null,Object? roleContext = null,Object? partnerDisplayName = freezed,}) {
  return _then(_DynamicSummary(
dynamicId: null == dynamicId ? _self.dynamicId : dynamicId // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,roleContext: null == roleContext ? _self.roleContext : roleContext // ignore: cast_nullable_to_non_nullable
as String,partnerDisplayName: freezed == partnerDisplayName ? _self.partnerDisplayName : partnerDisplayName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
