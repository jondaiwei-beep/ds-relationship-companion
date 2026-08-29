// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'weekly_reflection_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WeeklyMoment {

 String? get title;/// Their words, verbatim. Never paraphrased, never generated.
 String? get text; String? get fromDisplayName; DateTime get occurredAt;
/// Create a copy of WeeklyMoment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WeeklyMomentCopyWith<WeeklyMoment> get copyWith => _$WeeklyMomentCopyWithImpl<WeeklyMoment>(this as WeeklyMoment, _$identity);

  /// Serializes this WeeklyMoment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WeeklyMoment&&(identical(other.title, title) || other.title == title)&&(identical(other.text, text) || other.text == text)&&(identical(other.fromDisplayName, fromDisplayName) || other.fromDisplayName == fromDisplayName)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,text,fromDisplayName,occurredAt);

@override
String toString() {
  return 'WeeklyMoment(title: $title, text: $text, fromDisplayName: $fromDisplayName, occurredAt: $occurredAt)';
}


}

/// @nodoc
abstract mixin class $WeeklyMomentCopyWith<$Res>  {
  factory $WeeklyMomentCopyWith(WeeklyMoment value, $Res Function(WeeklyMoment) _then) = _$WeeklyMomentCopyWithImpl;
@useResult
$Res call({
 String? title, String? text, String? fromDisplayName, DateTime occurredAt
});




}
/// @nodoc
class _$WeeklyMomentCopyWithImpl<$Res>
    implements $WeeklyMomentCopyWith<$Res> {
  _$WeeklyMomentCopyWithImpl(this._self, this._then);

  final WeeklyMoment _self;
  final $Res Function(WeeklyMoment) _then;

/// Create a copy of WeeklyMoment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = freezed,Object? text = freezed,Object? fromDisplayName = freezed,Object? occurredAt = null,}) {
  return _then(_self.copyWith(
title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,fromDisplayName: freezed == fromDisplayName ? _self.fromDisplayName : fromDisplayName // ignore: cast_nullable_to_non_nullable
as String?,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [WeeklyMoment].
extension WeeklyMomentPatterns on WeeklyMoment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WeeklyMoment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WeeklyMoment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WeeklyMoment value)  $default,){
final _that = this;
switch (_that) {
case _WeeklyMoment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WeeklyMoment value)?  $default,){
final _that = this;
switch (_that) {
case _WeeklyMoment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? title,  String? text,  String? fromDisplayName,  DateTime occurredAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WeeklyMoment() when $default != null:
return $default(_that.title,_that.text,_that.fromDisplayName,_that.occurredAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? title,  String? text,  String? fromDisplayName,  DateTime occurredAt)  $default,) {final _that = this;
switch (_that) {
case _WeeklyMoment():
return $default(_that.title,_that.text,_that.fromDisplayName,_that.occurredAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? title,  String? text,  String? fromDisplayName,  DateTime occurredAt)?  $default,) {final _that = this;
switch (_that) {
case _WeeklyMoment() when $default != null:
return $default(_that.title,_that.text,_that.fromDisplayName,_that.occurredAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WeeklyMoment implements WeeklyMoment {
  const _WeeklyMoment({this.title, this.text, this.fromDisplayName, required this.occurredAt});
  factory _WeeklyMoment.fromJson(Map<String, dynamic> json) => _$WeeklyMomentFromJson(json);

@override final  String? title;
/// Their words, verbatim. Never paraphrased, never generated.
@override final  String? text;
@override final  String? fromDisplayName;
@override final  DateTime occurredAt;

/// Create a copy of WeeklyMoment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WeeklyMomentCopyWith<_WeeklyMoment> get copyWith => __$WeeklyMomentCopyWithImpl<_WeeklyMoment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WeeklyMomentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WeeklyMoment&&(identical(other.title, title) || other.title == title)&&(identical(other.text, text) || other.text == text)&&(identical(other.fromDisplayName, fromDisplayName) || other.fromDisplayName == fromDisplayName)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,text,fromDisplayName,occurredAt);

@override
String toString() {
  return 'WeeklyMoment(title: $title, text: $text, fromDisplayName: $fromDisplayName, occurredAt: $occurredAt)';
}


}

/// @nodoc
abstract mixin class _$WeeklyMomentCopyWith<$Res> implements $WeeklyMomentCopyWith<$Res> {
  factory _$WeeklyMomentCopyWith(_WeeklyMoment value, $Res Function(_WeeklyMoment) _then) = __$WeeklyMomentCopyWithImpl;
@override @useResult
$Res call({
 String? title, String? text, String? fromDisplayName, DateTime occurredAt
});




}
/// @nodoc
class __$WeeklyMomentCopyWithImpl<$Res>
    implements _$WeeklyMomentCopyWith<$Res> {
  __$WeeklyMomentCopyWithImpl(this._self, this._then);

  final _WeeklyMoment _self;
  final $Res Function(_WeeklyMoment) _then;

/// Create a copy of WeeklyMoment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = freezed,Object? text = freezed,Object? fromDisplayName = freezed,Object? occurredAt = null,}) {
  return _then(_WeeklyMoment(
title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,fromDisplayName: freezed == fromDisplayName ? _self.fromDisplayName : fromDisplayName // ignore: cast_nullable_to_non_nullable
as String?,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$WeeklyReflectionView {

 int get connectedDays; List<WeeklyMoment> get answeredMoments; int get adjustmentsResolved;/// False until the couple has a week behind them. A reflection offered on
/// day two invites a judgement about a week that has not happened.
 bool get hasEnoughHistory;
/// Create a copy of WeeklyReflectionView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WeeklyReflectionViewCopyWith<WeeklyReflectionView> get copyWith => _$WeeklyReflectionViewCopyWithImpl<WeeklyReflectionView>(this as WeeklyReflectionView, _$identity);

  /// Serializes this WeeklyReflectionView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WeeklyReflectionView&&(identical(other.connectedDays, connectedDays) || other.connectedDays == connectedDays)&&const DeepCollectionEquality().equals(other.answeredMoments, answeredMoments)&&(identical(other.adjustmentsResolved, adjustmentsResolved) || other.adjustmentsResolved == adjustmentsResolved)&&(identical(other.hasEnoughHistory, hasEnoughHistory) || other.hasEnoughHistory == hasEnoughHistory));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,connectedDays,const DeepCollectionEquality().hash(answeredMoments),adjustmentsResolved,hasEnoughHistory);

@override
String toString() {
  return 'WeeklyReflectionView(connectedDays: $connectedDays, answeredMoments: $answeredMoments, adjustmentsResolved: $adjustmentsResolved, hasEnoughHistory: $hasEnoughHistory)';
}


}

/// @nodoc
abstract mixin class $WeeklyReflectionViewCopyWith<$Res>  {
  factory $WeeklyReflectionViewCopyWith(WeeklyReflectionView value, $Res Function(WeeklyReflectionView) _then) = _$WeeklyReflectionViewCopyWithImpl;
@useResult
$Res call({
 int connectedDays, List<WeeklyMoment> answeredMoments, int adjustmentsResolved, bool hasEnoughHistory
});




}
/// @nodoc
class _$WeeklyReflectionViewCopyWithImpl<$Res>
    implements $WeeklyReflectionViewCopyWith<$Res> {
  _$WeeklyReflectionViewCopyWithImpl(this._self, this._then);

  final WeeklyReflectionView _self;
  final $Res Function(WeeklyReflectionView) _then;

/// Create a copy of WeeklyReflectionView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? connectedDays = null,Object? answeredMoments = null,Object? adjustmentsResolved = null,Object? hasEnoughHistory = null,}) {
  return _then(_self.copyWith(
connectedDays: null == connectedDays ? _self.connectedDays : connectedDays // ignore: cast_nullable_to_non_nullable
as int,answeredMoments: null == answeredMoments ? _self.answeredMoments : answeredMoments // ignore: cast_nullable_to_non_nullable
as List<WeeklyMoment>,adjustmentsResolved: null == adjustmentsResolved ? _self.adjustmentsResolved : adjustmentsResolved // ignore: cast_nullable_to_non_nullable
as int,hasEnoughHistory: null == hasEnoughHistory ? _self.hasEnoughHistory : hasEnoughHistory // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [WeeklyReflectionView].
extension WeeklyReflectionViewPatterns on WeeklyReflectionView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WeeklyReflectionView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WeeklyReflectionView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WeeklyReflectionView value)  $default,){
final _that = this;
switch (_that) {
case _WeeklyReflectionView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WeeklyReflectionView value)?  $default,){
final _that = this;
switch (_that) {
case _WeeklyReflectionView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int connectedDays,  List<WeeklyMoment> answeredMoments,  int adjustmentsResolved,  bool hasEnoughHistory)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WeeklyReflectionView() when $default != null:
return $default(_that.connectedDays,_that.answeredMoments,_that.adjustmentsResolved,_that.hasEnoughHistory);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int connectedDays,  List<WeeklyMoment> answeredMoments,  int adjustmentsResolved,  bool hasEnoughHistory)  $default,) {final _that = this;
switch (_that) {
case _WeeklyReflectionView():
return $default(_that.connectedDays,_that.answeredMoments,_that.adjustmentsResolved,_that.hasEnoughHistory);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int connectedDays,  List<WeeklyMoment> answeredMoments,  int adjustmentsResolved,  bool hasEnoughHistory)?  $default,) {final _that = this;
switch (_that) {
case _WeeklyReflectionView() when $default != null:
return $default(_that.connectedDays,_that.answeredMoments,_that.adjustmentsResolved,_that.hasEnoughHistory);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WeeklyReflectionView implements WeeklyReflectionView {
  const _WeeklyReflectionView({this.connectedDays = 0, final  List<WeeklyMoment> answeredMoments = const <WeeklyMoment>[], this.adjustmentsResolved = 0, this.hasEnoughHistory = false}): _answeredMoments = answeredMoments;
  factory _WeeklyReflectionView.fromJson(Map<String, dynamic> json) => _$WeeklyReflectionViewFromJson(json);

@override@JsonKey() final  int connectedDays;
 final  List<WeeklyMoment> _answeredMoments;
@override@JsonKey() List<WeeklyMoment> get answeredMoments {
  if (_answeredMoments is EqualUnmodifiableListView) return _answeredMoments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_answeredMoments);
}

@override@JsonKey() final  int adjustmentsResolved;
/// False until the couple has a week behind them. A reflection offered on
/// day two invites a judgement about a week that has not happened.
@override@JsonKey() final  bool hasEnoughHistory;

/// Create a copy of WeeklyReflectionView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WeeklyReflectionViewCopyWith<_WeeklyReflectionView> get copyWith => __$WeeklyReflectionViewCopyWithImpl<_WeeklyReflectionView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WeeklyReflectionViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WeeklyReflectionView&&(identical(other.connectedDays, connectedDays) || other.connectedDays == connectedDays)&&const DeepCollectionEquality().equals(other._answeredMoments, _answeredMoments)&&(identical(other.adjustmentsResolved, adjustmentsResolved) || other.adjustmentsResolved == adjustmentsResolved)&&(identical(other.hasEnoughHistory, hasEnoughHistory) || other.hasEnoughHistory == hasEnoughHistory));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,connectedDays,const DeepCollectionEquality().hash(_answeredMoments),adjustmentsResolved,hasEnoughHistory);

@override
String toString() {
  return 'WeeklyReflectionView(connectedDays: $connectedDays, answeredMoments: $answeredMoments, adjustmentsResolved: $adjustmentsResolved, hasEnoughHistory: $hasEnoughHistory)';
}


}

/// @nodoc
abstract mixin class _$WeeklyReflectionViewCopyWith<$Res> implements $WeeklyReflectionViewCopyWith<$Res> {
  factory _$WeeklyReflectionViewCopyWith(_WeeklyReflectionView value, $Res Function(_WeeklyReflectionView) _then) = __$WeeklyReflectionViewCopyWithImpl;
@override @useResult
$Res call({
 int connectedDays, List<WeeklyMoment> answeredMoments, int adjustmentsResolved, bool hasEnoughHistory
});




}
/// @nodoc
class __$WeeklyReflectionViewCopyWithImpl<$Res>
    implements _$WeeklyReflectionViewCopyWith<$Res> {
  __$WeeklyReflectionViewCopyWithImpl(this._self, this._then);

  final _WeeklyReflectionView _self;
  final $Res Function(_WeeklyReflectionView) _then;

/// Create a copy of WeeklyReflectionView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? connectedDays = null,Object? answeredMoments = null,Object? adjustmentsResolved = null,Object? hasEnoughHistory = null,}) {
  return _then(_WeeklyReflectionView(
connectedDays: null == connectedDays ? _self.connectedDays : connectedDays // ignore: cast_nullable_to_non_nullable
as int,answeredMoments: null == answeredMoments ? _self._answeredMoments : answeredMoments // ignore: cast_nullable_to_non_nullable
as List<WeeklyMoment>,adjustmentsResolved: null == adjustmentsResolved ? _self.adjustmentsResolved : adjustmentsResolved // ignore: cast_nullable_to_non_nullable
as int,hasEnoughHistory: null == hasEnoughHistory ? _self.hasEnoughHistory : hasEnoughHistory // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
