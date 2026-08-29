// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'us_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RelationshipMoment {

 String get eventType; String? get actorDisplayName; DateTime get occurredAt; String? get title;/// Present only for a human acknowledgement — their words, verbatim.
 String? get text;
/// Create a copy of RelationshipMoment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RelationshipMomentCopyWith<RelationshipMoment> get copyWith => _$RelationshipMomentCopyWithImpl<RelationshipMoment>(this as RelationshipMoment, _$identity);

  /// Serializes this RelationshipMoment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RelationshipMoment&&(identical(other.eventType, eventType) || other.eventType == eventType)&&(identical(other.actorDisplayName, actorDisplayName) || other.actorDisplayName == actorDisplayName)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&(identical(other.title, title) || other.title == title)&&(identical(other.text, text) || other.text == text));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,eventType,actorDisplayName,occurredAt,title,text);

@override
String toString() {
  return 'RelationshipMoment(eventType: $eventType, actorDisplayName: $actorDisplayName, occurredAt: $occurredAt, title: $title, text: $text)';
}


}

/// @nodoc
abstract mixin class $RelationshipMomentCopyWith<$Res>  {
  factory $RelationshipMomentCopyWith(RelationshipMoment value, $Res Function(RelationshipMoment) _then) = _$RelationshipMomentCopyWithImpl;
@useResult
$Res call({
 String eventType, String? actorDisplayName, DateTime occurredAt, String? title, String? text
});




}
/// @nodoc
class _$RelationshipMomentCopyWithImpl<$Res>
    implements $RelationshipMomentCopyWith<$Res> {
  _$RelationshipMomentCopyWithImpl(this._self, this._then);

  final RelationshipMoment _self;
  final $Res Function(RelationshipMoment) _then;

/// Create a copy of RelationshipMoment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? eventType = null,Object? actorDisplayName = freezed,Object? occurredAt = null,Object? title = freezed,Object? text = freezed,}) {
  return _then(_self.copyWith(
eventType: null == eventType ? _self.eventType : eventType // ignore: cast_nullable_to_non_nullable
as String,actorDisplayName: freezed == actorDisplayName ? _self.actorDisplayName : actorDisplayName // ignore: cast_nullable_to_non_nullable
as String?,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RelationshipMoment].
extension RelationshipMomentPatterns on RelationshipMoment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RelationshipMoment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RelationshipMoment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RelationshipMoment value)  $default,){
final _that = this;
switch (_that) {
case _RelationshipMoment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RelationshipMoment value)?  $default,){
final _that = this;
switch (_that) {
case _RelationshipMoment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String eventType,  String? actorDisplayName,  DateTime occurredAt,  String? title,  String? text)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RelationshipMoment() when $default != null:
return $default(_that.eventType,_that.actorDisplayName,_that.occurredAt,_that.title,_that.text);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String eventType,  String? actorDisplayName,  DateTime occurredAt,  String? title,  String? text)  $default,) {final _that = this;
switch (_that) {
case _RelationshipMoment():
return $default(_that.eventType,_that.actorDisplayName,_that.occurredAt,_that.title,_that.text);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String eventType,  String? actorDisplayName,  DateTime occurredAt,  String? title,  String? text)?  $default,) {final _that = this;
switch (_that) {
case _RelationshipMoment() when $default != null:
return $default(_that.eventType,_that.actorDisplayName,_that.occurredAt,_that.title,_that.text);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RelationshipMoment implements RelationshipMoment {
  const _RelationshipMoment({required this.eventType, this.actorDisplayName, required this.occurredAt, this.title, this.text});
  factory _RelationshipMoment.fromJson(Map<String, dynamic> json) => _$RelationshipMomentFromJson(json);

@override final  String eventType;
@override final  String? actorDisplayName;
@override final  DateTime occurredAt;
@override final  String? title;
/// Present only for a human acknowledgement — their words, verbatim.
@override final  String? text;

/// Create a copy of RelationshipMoment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RelationshipMomentCopyWith<_RelationshipMoment> get copyWith => __$RelationshipMomentCopyWithImpl<_RelationshipMoment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RelationshipMomentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RelationshipMoment&&(identical(other.eventType, eventType) || other.eventType == eventType)&&(identical(other.actorDisplayName, actorDisplayName) || other.actorDisplayName == actorDisplayName)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&(identical(other.title, title) || other.title == title)&&(identical(other.text, text) || other.text == text));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,eventType,actorDisplayName,occurredAt,title,text);

@override
String toString() {
  return 'RelationshipMoment(eventType: $eventType, actorDisplayName: $actorDisplayName, occurredAt: $occurredAt, title: $title, text: $text)';
}


}

/// @nodoc
abstract mixin class _$RelationshipMomentCopyWith<$Res> implements $RelationshipMomentCopyWith<$Res> {
  factory _$RelationshipMomentCopyWith(_RelationshipMoment value, $Res Function(_RelationshipMoment) _then) = __$RelationshipMomentCopyWithImpl;
@override @useResult
$Res call({
 String eventType, String? actorDisplayName, DateTime occurredAt, String? title, String? text
});




}
/// @nodoc
class __$RelationshipMomentCopyWithImpl<$Res>
    implements _$RelationshipMomentCopyWith<$Res> {
  __$RelationshipMomentCopyWithImpl(this._self, this._then);

  final _RelationshipMoment _self;
  final $Res Function(_RelationshipMoment) _then;

/// Create a copy of RelationshipMoment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? eventType = null,Object? actorDisplayName = freezed,Object? occurredAt = null,Object? title = freezed,Object? text = freezed,}) {
  return _then(_RelationshipMoment(
eventType: null == eventType ? _self.eventType : eventType // ignore: cast_nullable_to_non_nullable
as String,actorDisplayName: freezed == actorDisplayName ? _self.actorDisplayName : actorDisplayName // ignore: cast_nullable_to_non_nullable
as String?,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$UsView {

 List<RelationshipMoment> get moments;/// Days on which BOTH members produced a meaningful event.
 int get connectedDays;
/// Create a copy of UsView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UsViewCopyWith<UsView> get copyWith => _$UsViewCopyWithImpl<UsView>(this as UsView, _$identity);

  /// Serializes this UsView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UsView&&const DeepCollectionEquality().equals(other.moments, moments)&&(identical(other.connectedDays, connectedDays) || other.connectedDays == connectedDays));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(moments),connectedDays);

@override
String toString() {
  return 'UsView(moments: $moments, connectedDays: $connectedDays)';
}


}

/// @nodoc
abstract mixin class $UsViewCopyWith<$Res>  {
  factory $UsViewCopyWith(UsView value, $Res Function(UsView) _then) = _$UsViewCopyWithImpl;
@useResult
$Res call({
 List<RelationshipMoment> moments, int connectedDays
});




}
/// @nodoc
class _$UsViewCopyWithImpl<$Res>
    implements $UsViewCopyWith<$Res> {
  _$UsViewCopyWithImpl(this._self, this._then);

  final UsView _self;
  final $Res Function(UsView) _then;

/// Create a copy of UsView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? moments = null,Object? connectedDays = null,}) {
  return _then(_self.copyWith(
moments: null == moments ? _self.moments : moments // ignore: cast_nullable_to_non_nullable
as List<RelationshipMoment>,connectedDays: null == connectedDays ? _self.connectedDays : connectedDays // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [UsView].
extension UsViewPatterns on UsView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UsView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UsView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UsView value)  $default,){
final _that = this;
switch (_that) {
case _UsView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UsView value)?  $default,){
final _that = this;
switch (_that) {
case _UsView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<RelationshipMoment> moments,  int connectedDays)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UsView() when $default != null:
return $default(_that.moments,_that.connectedDays);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<RelationshipMoment> moments,  int connectedDays)  $default,) {final _that = this;
switch (_that) {
case _UsView():
return $default(_that.moments,_that.connectedDays);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<RelationshipMoment> moments,  int connectedDays)?  $default,) {final _that = this;
switch (_that) {
case _UsView() when $default != null:
return $default(_that.moments,_that.connectedDays);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UsView implements UsView {
  const _UsView({final  List<RelationshipMoment> moments = const <RelationshipMoment>[], this.connectedDays = 0}): _moments = moments;
  factory _UsView.fromJson(Map<String, dynamic> json) => _$UsViewFromJson(json);

 final  List<RelationshipMoment> _moments;
@override@JsonKey() List<RelationshipMoment> get moments {
  if (_moments is EqualUnmodifiableListView) return _moments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_moments);
}

/// Days on which BOTH members produced a meaningful event.
@override@JsonKey() final  int connectedDays;

/// Create a copy of UsView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UsViewCopyWith<_UsView> get copyWith => __$UsViewCopyWithImpl<_UsView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UsViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UsView&&const DeepCollectionEquality().equals(other._moments, _moments)&&(identical(other.connectedDays, connectedDays) || other.connectedDays == connectedDays));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_moments),connectedDays);

@override
String toString() {
  return 'UsView(moments: $moments, connectedDays: $connectedDays)';
}


}

/// @nodoc
abstract mixin class _$UsViewCopyWith<$Res> implements $UsViewCopyWith<$Res> {
  factory _$UsViewCopyWith(_UsView value, $Res Function(_UsView) _then) = __$UsViewCopyWithImpl;
@override @useResult
$Res call({
 List<RelationshipMoment> moments, int connectedDays
});




}
/// @nodoc
class __$UsViewCopyWithImpl<$Res>
    implements _$UsViewCopyWith<$Res> {
  __$UsViewCopyWithImpl(this._self, this._then);

  final _UsView _self;
  final $Res Function(_UsView) _then;

/// Create a copy of UsView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? moments = null,Object? connectedDays = null,}) {
  return _then(_UsView(
moments: null == moments ? _self._moments : moments // ignore: cast_nullable_to_non_nullable
as List<RelationshipMoment>,connectedDays: null == connectedDays ? _self.connectedDays : connectedDays // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
