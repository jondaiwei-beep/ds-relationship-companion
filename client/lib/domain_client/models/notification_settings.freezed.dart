// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NotificationSettings {

 String get timezone;/// NEUTRAL keeps the lockscreen and email subject free of relationship
/// content. It is the default and never widens on its own.
 String get notificationPreview;/// Minutes past local midnight; null when quiet hours are off.
 int? get quietHoursStartMin; int? get quietHoursEndMin;
/// Create a copy of NotificationSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationSettingsCopyWith<NotificationSettings> get copyWith => _$NotificationSettingsCopyWithImpl<NotificationSettings>(this as NotificationSettings, _$identity);

  /// Serializes this NotificationSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationSettings&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.notificationPreview, notificationPreview) || other.notificationPreview == notificationPreview)&&(identical(other.quietHoursStartMin, quietHoursStartMin) || other.quietHoursStartMin == quietHoursStartMin)&&(identical(other.quietHoursEndMin, quietHoursEndMin) || other.quietHoursEndMin == quietHoursEndMin));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,timezone,notificationPreview,quietHoursStartMin,quietHoursEndMin);

@override
String toString() {
  return 'NotificationSettings(timezone: $timezone, notificationPreview: $notificationPreview, quietHoursStartMin: $quietHoursStartMin, quietHoursEndMin: $quietHoursEndMin)';
}


}

/// @nodoc
abstract mixin class $NotificationSettingsCopyWith<$Res>  {
  factory $NotificationSettingsCopyWith(NotificationSettings value, $Res Function(NotificationSettings) _then) = _$NotificationSettingsCopyWithImpl;
@useResult
$Res call({
 String timezone, String notificationPreview, int? quietHoursStartMin, int? quietHoursEndMin
});




}
/// @nodoc
class _$NotificationSettingsCopyWithImpl<$Res>
    implements $NotificationSettingsCopyWith<$Res> {
  _$NotificationSettingsCopyWithImpl(this._self, this._then);

  final NotificationSettings _self;
  final $Res Function(NotificationSettings) _then;

/// Create a copy of NotificationSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? timezone = null,Object? notificationPreview = null,Object? quietHoursStartMin = freezed,Object? quietHoursEndMin = freezed,}) {
  return _then(_self.copyWith(
timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,notificationPreview: null == notificationPreview ? _self.notificationPreview : notificationPreview // ignore: cast_nullable_to_non_nullable
as String,quietHoursStartMin: freezed == quietHoursStartMin ? _self.quietHoursStartMin : quietHoursStartMin // ignore: cast_nullable_to_non_nullable
as int?,quietHoursEndMin: freezed == quietHoursEndMin ? _self.quietHoursEndMin : quietHoursEndMin // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationSettings].
extension NotificationSettingsPatterns on NotificationSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationSettings value)  $default,){
final _that = this;
switch (_that) {
case _NotificationSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationSettings value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String timezone,  String notificationPreview,  int? quietHoursStartMin,  int? quietHoursEndMin)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationSettings() when $default != null:
return $default(_that.timezone,_that.notificationPreview,_that.quietHoursStartMin,_that.quietHoursEndMin);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String timezone,  String notificationPreview,  int? quietHoursStartMin,  int? quietHoursEndMin)  $default,) {final _that = this;
switch (_that) {
case _NotificationSettings():
return $default(_that.timezone,_that.notificationPreview,_that.quietHoursStartMin,_that.quietHoursEndMin);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String timezone,  String notificationPreview,  int? quietHoursStartMin,  int? quietHoursEndMin)?  $default,) {final _that = this;
switch (_that) {
case _NotificationSettings() when $default != null:
return $default(_that.timezone,_that.notificationPreview,_that.quietHoursStartMin,_that.quietHoursEndMin);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotificationSettings extends NotificationSettings {
  const _NotificationSettings({this.timezone = 'UTC', this.notificationPreview = 'NEUTRAL', this.quietHoursStartMin, this.quietHoursEndMin}): super._();
  factory _NotificationSettings.fromJson(Map<String, dynamic> json) => _$NotificationSettingsFromJson(json);

@override@JsonKey() final  String timezone;
/// NEUTRAL keeps the lockscreen and email subject free of relationship
/// content. It is the default and never widens on its own.
@override@JsonKey() final  String notificationPreview;
/// Minutes past local midnight; null when quiet hours are off.
@override final  int? quietHoursStartMin;
@override final  int? quietHoursEndMin;

/// Create a copy of NotificationSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationSettingsCopyWith<_NotificationSettings> get copyWith => __$NotificationSettingsCopyWithImpl<_NotificationSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationSettings&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.notificationPreview, notificationPreview) || other.notificationPreview == notificationPreview)&&(identical(other.quietHoursStartMin, quietHoursStartMin) || other.quietHoursStartMin == quietHoursStartMin)&&(identical(other.quietHoursEndMin, quietHoursEndMin) || other.quietHoursEndMin == quietHoursEndMin));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,timezone,notificationPreview,quietHoursStartMin,quietHoursEndMin);

@override
String toString() {
  return 'NotificationSettings(timezone: $timezone, notificationPreview: $notificationPreview, quietHoursStartMin: $quietHoursStartMin, quietHoursEndMin: $quietHoursEndMin)';
}


}

/// @nodoc
abstract mixin class _$NotificationSettingsCopyWith<$Res> implements $NotificationSettingsCopyWith<$Res> {
  factory _$NotificationSettingsCopyWith(_NotificationSettings value, $Res Function(_NotificationSettings) _then) = __$NotificationSettingsCopyWithImpl;
@override @useResult
$Res call({
 String timezone, String notificationPreview, int? quietHoursStartMin, int? quietHoursEndMin
});




}
/// @nodoc
class __$NotificationSettingsCopyWithImpl<$Res>
    implements _$NotificationSettingsCopyWith<$Res> {
  __$NotificationSettingsCopyWithImpl(this._self, this._then);

  final _NotificationSettings _self;
  final $Res Function(_NotificationSettings) _then;

/// Create a copy of NotificationSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? timezone = null,Object? notificationPreview = null,Object? quietHoursStartMin = freezed,Object? quietHoursEndMin = freezed,}) {
  return _then(_NotificationSettings(
timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,notificationPreview: null == notificationPreview ? _self.notificationPreview : notificationPreview // ignore: cast_nullable_to_non_nullable
as String,quietHoursStartMin: freezed == quietHoursStartMin ? _self.quietHoursStartMin : quietHoursStartMin // ignore: cast_nullable_to_non_nullable
as int?,quietHoursEndMin: freezed == quietHoursEndMin ? _self.quietHoursEndMin : quietHoursEndMin // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
