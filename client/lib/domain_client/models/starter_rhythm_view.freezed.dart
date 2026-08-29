// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'starter_rhythm_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StarterRhythmProposal {

 String get ritualTitle; String get ritualPurpose; String get expectationTitle; String get expectationPurpose; String get checkInFraming;/// Offered, not included. The creator opts in (Notion 05 §4).
 String get optionalSecondTitle; String get optionalSecondPurpose;
/// Create a copy of StarterRhythmProposal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StarterRhythmProposalCopyWith<StarterRhythmProposal> get copyWith => _$StarterRhythmProposalCopyWithImpl<StarterRhythmProposal>(this as StarterRhythmProposal, _$identity);

  /// Serializes this StarterRhythmProposal to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StarterRhythmProposal&&(identical(other.ritualTitle, ritualTitle) || other.ritualTitle == ritualTitle)&&(identical(other.ritualPurpose, ritualPurpose) || other.ritualPurpose == ritualPurpose)&&(identical(other.expectationTitle, expectationTitle) || other.expectationTitle == expectationTitle)&&(identical(other.expectationPurpose, expectationPurpose) || other.expectationPurpose == expectationPurpose)&&(identical(other.checkInFraming, checkInFraming) || other.checkInFraming == checkInFraming)&&(identical(other.optionalSecondTitle, optionalSecondTitle) || other.optionalSecondTitle == optionalSecondTitle)&&(identical(other.optionalSecondPurpose, optionalSecondPurpose) || other.optionalSecondPurpose == optionalSecondPurpose));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ritualTitle,ritualPurpose,expectationTitle,expectationPurpose,checkInFraming,optionalSecondTitle,optionalSecondPurpose);

@override
String toString() {
  return 'StarterRhythmProposal(ritualTitle: $ritualTitle, ritualPurpose: $ritualPurpose, expectationTitle: $expectationTitle, expectationPurpose: $expectationPurpose, checkInFraming: $checkInFraming, optionalSecondTitle: $optionalSecondTitle, optionalSecondPurpose: $optionalSecondPurpose)';
}


}

/// @nodoc
abstract mixin class $StarterRhythmProposalCopyWith<$Res>  {
  factory $StarterRhythmProposalCopyWith(StarterRhythmProposal value, $Res Function(StarterRhythmProposal) _then) = _$StarterRhythmProposalCopyWithImpl;
@useResult
$Res call({
 String ritualTitle, String ritualPurpose, String expectationTitle, String expectationPurpose, String checkInFraming, String optionalSecondTitle, String optionalSecondPurpose
});




}
/// @nodoc
class _$StarterRhythmProposalCopyWithImpl<$Res>
    implements $StarterRhythmProposalCopyWith<$Res> {
  _$StarterRhythmProposalCopyWithImpl(this._self, this._then);

  final StarterRhythmProposal _self;
  final $Res Function(StarterRhythmProposal) _then;

/// Create a copy of StarterRhythmProposal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ritualTitle = null,Object? ritualPurpose = null,Object? expectationTitle = null,Object? expectationPurpose = null,Object? checkInFraming = null,Object? optionalSecondTitle = null,Object? optionalSecondPurpose = null,}) {
  return _then(_self.copyWith(
ritualTitle: null == ritualTitle ? _self.ritualTitle : ritualTitle // ignore: cast_nullable_to_non_nullable
as String,ritualPurpose: null == ritualPurpose ? _self.ritualPurpose : ritualPurpose // ignore: cast_nullable_to_non_nullable
as String,expectationTitle: null == expectationTitle ? _self.expectationTitle : expectationTitle // ignore: cast_nullable_to_non_nullable
as String,expectationPurpose: null == expectationPurpose ? _self.expectationPurpose : expectationPurpose // ignore: cast_nullable_to_non_nullable
as String,checkInFraming: null == checkInFraming ? _self.checkInFraming : checkInFraming // ignore: cast_nullable_to_non_nullable
as String,optionalSecondTitle: null == optionalSecondTitle ? _self.optionalSecondTitle : optionalSecondTitle // ignore: cast_nullable_to_non_nullable
as String,optionalSecondPurpose: null == optionalSecondPurpose ? _self.optionalSecondPurpose : optionalSecondPurpose // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [StarterRhythmProposal].
extension StarterRhythmProposalPatterns on StarterRhythmProposal {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StarterRhythmProposal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StarterRhythmProposal() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StarterRhythmProposal value)  $default,){
final _that = this;
switch (_that) {
case _StarterRhythmProposal():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StarterRhythmProposal value)?  $default,){
final _that = this;
switch (_that) {
case _StarterRhythmProposal() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String ritualTitle,  String ritualPurpose,  String expectationTitle,  String expectationPurpose,  String checkInFraming,  String optionalSecondTitle,  String optionalSecondPurpose)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StarterRhythmProposal() when $default != null:
return $default(_that.ritualTitle,_that.ritualPurpose,_that.expectationTitle,_that.expectationPurpose,_that.checkInFraming,_that.optionalSecondTitle,_that.optionalSecondPurpose);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String ritualTitle,  String ritualPurpose,  String expectationTitle,  String expectationPurpose,  String checkInFraming,  String optionalSecondTitle,  String optionalSecondPurpose)  $default,) {final _that = this;
switch (_that) {
case _StarterRhythmProposal():
return $default(_that.ritualTitle,_that.ritualPurpose,_that.expectationTitle,_that.expectationPurpose,_that.checkInFraming,_that.optionalSecondTitle,_that.optionalSecondPurpose);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String ritualTitle,  String ritualPurpose,  String expectationTitle,  String expectationPurpose,  String checkInFraming,  String optionalSecondTitle,  String optionalSecondPurpose)?  $default,) {final _that = this;
switch (_that) {
case _StarterRhythmProposal() when $default != null:
return $default(_that.ritualTitle,_that.ritualPurpose,_that.expectationTitle,_that.expectationPurpose,_that.checkInFraming,_that.optionalSecondTitle,_that.optionalSecondPurpose);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StarterRhythmProposal implements StarterRhythmProposal {
  const _StarterRhythmProposal({required this.ritualTitle, required this.ritualPurpose, required this.expectationTitle, required this.expectationPurpose, required this.checkInFraming, required this.optionalSecondTitle, required this.optionalSecondPurpose});
  factory _StarterRhythmProposal.fromJson(Map<String, dynamic> json) => _$StarterRhythmProposalFromJson(json);

@override final  String ritualTitle;
@override final  String ritualPurpose;
@override final  String expectationTitle;
@override final  String expectationPurpose;
@override final  String checkInFraming;
/// Offered, not included. The creator opts in (Notion 05 §4).
@override final  String optionalSecondTitle;
@override final  String optionalSecondPurpose;

/// Create a copy of StarterRhythmProposal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StarterRhythmProposalCopyWith<_StarterRhythmProposal> get copyWith => __$StarterRhythmProposalCopyWithImpl<_StarterRhythmProposal>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StarterRhythmProposalToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StarterRhythmProposal&&(identical(other.ritualTitle, ritualTitle) || other.ritualTitle == ritualTitle)&&(identical(other.ritualPurpose, ritualPurpose) || other.ritualPurpose == ritualPurpose)&&(identical(other.expectationTitle, expectationTitle) || other.expectationTitle == expectationTitle)&&(identical(other.expectationPurpose, expectationPurpose) || other.expectationPurpose == expectationPurpose)&&(identical(other.checkInFraming, checkInFraming) || other.checkInFraming == checkInFraming)&&(identical(other.optionalSecondTitle, optionalSecondTitle) || other.optionalSecondTitle == optionalSecondTitle)&&(identical(other.optionalSecondPurpose, optionalSecondPurpose) || other.optionalSecondPurpose == optionalSecondPurpose));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ritualTitle,ritualPurpose,expectationTitle,expectationPurpose,checkInFraming,optionalSecondTitle,optionalSecondPurpose);

@override
String toString() {
  return 'StarterRhythmProposal(ritualTitle: $ritualTitle, ritualPurpose: $ritualPurpose, expectationTitle: $expectationTitle, expectationPurpose: $expectationPurpose, checkInFraming: $checkInFraming, optionalSecondTitle: $optionalSecondTitle, optionalSecondPurpose: $optionalSecondPurpose)';
}


}

/// @nodoc
abstract mixin class _$StarterRhythmProposalCopyWith<$Res> implements $StarterRhythmProposalCopyWith<$Res> {
  factory _$StarterRhythmProposalCopyWith(_StarterRhythmProposal value, $Res Function(_StarterRhythmProposal) _then) = __$StarterRhythmProposalCopyWithImpl;
@override @useResult
$Res call({
 String ritualTitle, String ritualPurpose, String expectationTitle, String expectationPurpose, String checkInFraming, String optionalSecondTitle, String optionalSecondPurpose
});




}
/// @nodoc
class __$StarterRhythmProposalCopyWithImpl<$Res>
    implements _$StarterRhythmProposalCopyWith<$Res> {
  __$StarterRhythmProposalCopyWithImpl(this._self, this._then);

  final _StarterRhythmProposal _self;
  final $Res Function(_StarterRhythmProposal) _then;

/// Create a copy of StarterRhythmProposal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ritualTitle = null,Object? ritualPurpose = null,Object? expectationTitle = null,Object? expectationPurpose = null,Object? checkInFraming = null,Object? optionalSecondTitle = null,Object? optionalSecondPurpose = null,}) {
  return _then(_StarterRhythmProposal(
ritualTitle: null == ritualTitle ? _self.ritualTitle : ritualTitle // ignore: cast_nullable_to_non_nullable
as String,ritualPurpose: null == ritualPurpose ? _self.ritualPurpose : ritualPurpose // ignore: cast_nullable_to_non_nullable
as String,expectationTitle: null == expectationTitle ? _self.expectationTitle : expectationTitle // ignore: cast_nullable_to_non_nullable
as String,expectationPurpose: null == expectationPurpose ? _self.expectationPurpose : expectationPurpose // ignore: cast_nullable_to_non_nullable
as String,checkInFraming: null == checkInFraming ? _self.checkInFraming : checkInFraming // ignore: cast_nullable_to_non_nullable
as String,optionalSecondTitle: null == optionalSecondTitle ? _self.optionalSecondTitle : optionalSecondTitle // ignore: cast_nullable_to_non_nullable
as String,optionalSecondPurpose: null == optionalSecondPurpose ? _self.optionalSecondPurpose : optionalSecondPurpose // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
