// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TaskView {

 String get id; String get title; String? get detail; String get kind; Map<String, dynamic>? get schedule; int get timesPerDay;/// `HH:mm[:ss]` local to the Dynamic, or null when the task has no clock.
 String? get dueTime; DateTime? get dueAt; String get proof; int get pointsEarn; bool get requiresDPresent; DateTime? get pausedUntil; String? get unit; String get createdBy;/// `proposed | active | archived`.
 String get status; int get position;
/// Create a copy of TaskView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskViewCopyWith<TaskView> get copyWith => _$TaskViewCopyWithImpl<TaskView>(this as TaskView, _$identity);

  /// Serializes this TaskView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskView&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.detail, detail) || other.detail == detail)&&(identical(other.kind, kind) || other.kind == kind)&&const DeepCollectionEquality().equals(other.schedule, schedule)&&(identical(other.timesPerDay, timesPerDay) || other.timesPerDay == timesPerDay)&&(identical(other.dueTime, dueTime) || other.dueTime == dueTime)&&(identical(other.dueAt, dueAt) || other.dueAt == dueAt)&&(identical(other.proof, proof) || other.proof == proof)&&(identical(other.pointsEarn, pointsEarn) || other.pointsEarn == pointsEarn)&&(identical(other.requiresDPresent, requiresDPresent) || other.requiresDPresent == requiresDPresent)&&(identical(other.pausedUntil, pausedUntil) || other.pausedUntil == pausedUntil)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.status, status) || other.status == status)&&(identical(other.position, position) || other.position == position));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,detail,kind,const DeepCollectionEquality().hash(schedule),timesPerDay,dueTime,dueAt,proof,pointsEarn,requiresDPresent,pausedUntil,unit,createdBy,status,position);

@override
String toString() {
  return 'TaskView(id: $id, title: $title, detail: $detail, kind: $kind, schedule: $schedule, timesPerDay: $timesPerDay, dueTime: $dueTime, dueAt: $dueAt, proof: $proof, pointsEarn: $pointsEarn, requiresDPresent: $requiresDPresent, pausedUntil: $pausedUntil, unit: $unit, createdBy: $createdBy, status: $status, position: $position)';
}


}

/// @nodoc
abstract mixin class $TaskViewCopyWith<$Res>  {
  factory $TaskViewCopyWith(TaskView value, $Res Function(TaskView) _then) = _$TaskViewCopyWithImpl;
@useResult
$Res call({
 String id, String title, String? detail, String kind, Map<String, dynamic>? schedule, int timesPerDay, String? dueTime, DateTime? dueAt, String proof, int pointsEarn, bool requiresDPresent, DateTime? pausedUntil, String? unit, String createdBy, String status, int position
});




}
/// @nodoc
class _$TaskViewCopyWithImpl<$Res>
    implements $TaskViewCopyWith<$Res> {
  _$TaskViewCopyWithImpl(this._self, this._then);

  final TaskView _self;
  final $Res Function(TaskView) _then;

/// Create a copy of TaskView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? detail = freezed,Object? kind = null,Object? schedule = freezed,Object? timesPerDay = null,Object? dueTime = freezed,Object? dueAt = freezed,Object? proof = null,Object? pointsEarn = null,Object? requiresDPresent = null,Object? pausedUntil = freezed,Object? unit = freezed,Object? createdBy = null,Object? status = null,Object? position = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,detail: freezed == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String?,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,schedule: freezed == schedule ? _self.schedule : schedule // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,timesPerDay: null == timesPerDay ? _self.timesPerDay : timesPerDay // ignore: cast_nullable_to_non_nullable
as int,dueTime: freezed == dueTime ? _self.dueTime : dueTime // ignore: cast_nullable_to_non_nullable
as String?,dueAt: freezed == dueAt ? _self.dueAt : dueAt // ignore: cast_nullable_to_non_nullable
as DateTime?,proof: null == proof ? _self.proof : proof // ignore: cast_nullable_to_non_nullable
as String,pointsEarn: null == pointsEarn ? _self.pointsEarn : pointsEarn // ignore: cast_nullable_to_non_nullable
as int,requiresDPresent: null == requiresDPresent ? _self.requiresDPresent : requiresDPresent // ignore: cast_nullable_to_non_nullable
as bool,pausedUntil: freezed == pausedUntil ? _self.pausedUntil : pausedUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TaskView].
extension TaskViewPatterns on TaskView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaskView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaskView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaskView value)  $default,){
final _that = this;
switch (_that) {
case _TaskView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaskView value)?  $default,){
final _that = this;
switch (_that) {
case _TaskView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String? detail,  String kind,  Map<String, dynamic>? schedule,  int timesPerDay,  String? dueTime,  DateTime? dueAt,  String proof,  int pointsEarn,  bool requiresDPresent,  DateTime? pausedUntil,  String? unit,  String createdBy,  String status,  int position)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaskView() when $default != null:
return $default(_that.id,_that.title,_that.detail,_that.kind,_that.schedule,_that.timesPerDay,_that.dueTime,_that.dueAt,_that.proof,_that.pointsEarn,_that.requiresDPresent,_that.pausedUntil,_that.unit,_that.createdBy,_that.status,_that.position);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String? detail,  String kind,  Map<String, dynamic>? schedule,  int timesPerDay,  String? dueTime,  DateTime? dueAt,  String proof,  int pointsEarn,  bool requiresDPresent,  DateTime? pausedUntil,  String? unit,  String createdBy,  String status,  int position)  $default,) {final _that = this;
switch (_that) {
case _TaskView():
return $default(_that.id,_that.title,_that.detail,_that.kind,_that.schedule,_that.timesPerDay,_that.dueTime,_that.dueAt,_that.proof,_that.pointsEarn,_that.requiresDPresent,_that.pausedUntil,_that.unit,_that.createdBy,_that.status,_that.position);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String? detail,  String kind,  Map<String, dynamic>? schedule,  int timesPerDay,  String? dueTime,  DateTime? dueAt,  String proof,  int pointsEarn,  bool requiresDPresent,  DateTime? pausedUntil,  String? unit,  String createdBy,  String status,  int position)?  $default,) {final _that = this;
switch (_that) {
case _TaskView() when $default != null:
return $default(_that.id,_that.title,_that.detail,_that.kind,_that.schedule,_that.timesPerDay,_that.dueTime,_that.dueAt,_that.proof,_that.pointsEarn,_that.requiresDPresent,_that.pausedUntil,_that.unit,_that.createdBy,_that.status,_that.position);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TaskView implements TaskView {
  const _TaskView({required this.id, required this.title, this.detail, required this.kind, final  Map<String, dynamic>? schedule, this.timesPerDay = 1, this.dueTime, this.dueAt, required this.proof, this.pointsEarn = 0, this.requiresDPresent = false, this.pausedUntil, this.unit, required this.createdBy, required this.status, this.position = 0}): _schedule = schedule;
  factory _TaskView.fromJson(Map<String, dynamic> json) => _$TaskViewFromJson(json);

@override final  String id;
@override final  String title;
@override final  String? detail;
@override final  String kind;
 final  Map<String, dynamic>? _schedule;
@override Map<String, dynamic>? get schedule {
  final value = _schedule;
  if (value == null) return null;
  if (_schedule is EqualUnmodifiableMapView) return _schedule;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override@JsonKey() final  int timesPerDay;
/// `HH:mm[:ss]` local to the Dynamic, or null when the task has no clock.
@override final  String? dueTime;
@override final  DateTime? dueAt;
@override final  String proof;
@override@JsonKey() final  int pointsEarn;
@override@JsonKey() final  bool requiresDPresent;
@override final  DateTime? pausedUntil;
@override final  String? unit;
@override final  String createdBy;
/// `proposed | active | archived`.
@override final  String status;
@override@JsonKey() final  int position;

/// Create a copy of TaskView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskViewCopyWith<_TaskView> get copyWith => __$TaskViewCopyWithImpl<_TaskView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TaskViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaskView&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.detail, detail) || other.detail == detail)&&(identical(other.kind, kind) || other.kind == kind)&&const DeepCollectionEquality().equals(other._schedule, _schedule)&&(identical(other.timesPerDay, timesPerDay) || other.timesPerDay == timesPerDay)&&(identical(other.dueTime, dueTime) || other.dueTime == dueTime)&&(identical(other.dueAt, dueAt) || other.dueAt == dueAt)&&(identical(other.proof, proof) || other.proof == proof)&&(identical(other.pointsEarn, pointsEarn) || other.pointsEarn == pointsEarn)&&(identical(other.requiresDPresent, requiresDPresent) || other.requiresDPresent == requiresDPresent)&&(identical(other.pausedUntil, pausedUntil) || other.pausedUntil == pausedUntil)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.status, status) || other.status == status)&&(identical(other.position, position) || other.position == position));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,detail,kind,const DeepCollectionEquality().hash(_schedule),timesPerDay,dueTime,dueAt,proof,pointsEarn,requiresDPresent,pausedUntil,unit,createdBy,status,position);

@override
String toString() {
  return 'TaskView(id: $id, title: $title, detail: $detail, kind: $kind, schedule: $schedule, timesPerDay: $timesPerDay, dueTime: $dueTime, dueAt: $dueAt, proof: $proof, pointsEarn: $pointsEarn, requiresDPresent: $requiresDPresent, pausedUntil: $pausedUntil, unit: $unit, createdBy: $createdBy, status: $status, position: $position)';
}


}

/// @nodoc
abstract mixin class _$TaskViewCopyWith<$Res> implements $TaskViewCopyWith<$Res> {
  factory _$TaskViewCopyWith(_TaskView value, $Res Function(_TaskView) _then) = __$TaskViewCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String? detail, String kind, Map<String, dynamic>? schedule, int timesPerDay, String? dueTime, DateTime? dueAt, String proof, int pointsEarn, bool requiresDPresent, DateTime? pausedUntil, String? unit, String createdBy, String status, int position
});




}
/// @nodoc
class __$TaskViewCopyWithImpl<$Res>
    implements _$TaskViewCopyWith<$Res> {
  __$TaskViewCopyWithImpl(this._self, this._then);

  final _TaskView _self;
  final $Res Function(_TaskView) _then;

/// Create a copy of TaskView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? detail = freezed,Object? kind = null,Object? schedule = freezed,Object? timesPerDay = null,Object? dueTime = freezed,Object? dueAt = freezed,Object? proof = null,Object? pointsEarn = null,Object? requiresDPresent = null,Object? pausedUntil = freezed,Object? unit = freezed,Object? createdBy = null,Object? status = null,Object? position = null,}) {
  return _then(_TaskView(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,detail: freezed == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String?,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,schedule: freezed == schedule ? _self._schedule : schedule // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,timesPerDay: null == timesPerDay ? _self.timesPerDay : timesPerDay // ignore: cast_nullable_to_non_nullable
as int,dueTime: freezed == dueTime ? _self.dueTime : dueTime // ignore: cast_nullable_to_non_nullable
as String?,dueAt: freezed == dueAt ? _self.dueAt : dueAt // ignore: cast_nullable_to_non_nullable
as DateTime?,proof: null == proof ? _self.proof : proof // ignore: cast_nullable_to_non_nullable
as String,pointsEarn: null == pointsEarn ? _self.pointsEarn : pointsEarn // ignore: cast_nullable_to_non_nullable
as int,requiresDPresent: null == requiresDPresent ? _self.requiresDPresent : requiresDPresent // ignore: cast_nullable_to_non_nullable
as bool,pausedUntil: freezed == pausedUntil ? _self.pausedUntil : pausedUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$NewTask {

 String get title; String? get detail;/// `recurring | one_off | open | checkin | measure`.
 String get kind;/// `{"type":"daily"}` and friends. Null lets the server default a
/// recurring task to daily.
 Map<String, dynamic>? get schedule; int get timesPerDay; String? get dueTime; DateTime? get dueAt; String get proof; int get pointsEarn; bool get requiresDPresent; String? get unit;
/// Create a copy of NewTask
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NewTaskCopyWith<NewTask> get copyWith => _$NewTaskCopyWithImpl<NewTask>(this as NewTask, _$identity);

  /// Serializes this NewTask to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NewTask&&(identical(other.title, title) || other.title == title)&&(identical(other.detail, detail) || other.detail == detail)&&(identical(other.kind, kind) || other.kind == kind)&&const DeepCollectionEquality().equals(other.schedule, schedule)&&(identical(other.timesPerDay, timesPerDay) || other.timesPerDay == timesPerDay)&&(identical(other.dueTime, dueTime) || other.dueTime == dueTime)&&(identical(other.dueAt, dueAt) || other.dueAt == dueAt)&&(identical(other.proof, proof) || other.proof == proof)&&(identical(other.pointsEarn, pointsEarn) || other.pointsEarn == pointsEarn)&&(identical(other.requiresDPresent, requiresDPresent) || other.requiresDPresent == requiresDPresent)&&(identical(other.unit, unit) || other.unit == unit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,detail,kind,const DeepCollectionEquality().hash(schedule),timesPerDay,dueTime,dueAt,proof,pointsEarn,requiresDPresent,unit);

@override
String toString() {
  return 'NewTask(title: $title, detail: $detail, kind: $kind, schedule: $schedule, timesPerDay: $timesPerDay, dueTime: $dueTime, dueAt: $dueAt, proof: $proof, pointsEarn: $pointsEarn, requiresDPresent: $requiresDPresent, unit: $unit)';
}


}

/// @nodoc
abstract mixin class $NewTaskCopyWith<$Res>  {
  factory $NewTaskCopyWith(NewTask value, $Res Function(NewTask) _then) = _$NewTaskCopyWithImpl;
@useResult
$Res call({
 String title, String? detail, String kind, Map<String, dynamic>? schedule, int timesPerDay, String? dueTime, DateTime? dueAt, String proof, int pointsEarn, bool requiresDPresent, String? unit
});




}
/// @nodoc
class _$NewTaskCopyWithImpl<$Res>
    implements $NewTaskCopyWith<$Res> {
  _$NewTaskCopyWithImpl(this._self, this._then);

  final NewTask _self;
  final $Res Function(NewTask) _then;

/// Create a copy of NewTask
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? detail = freezed,Object? kind = null,Object? schedule = freezed,Object? timesPerDay = null,Object? dueTime = freezed,Object? dueAt = freezed,Object? proof = null,Object? pointsEarn = null,Object? requiresDPresent = null,Object? unit = freezed,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,detail: freezed == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String?,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,schedule: freezed == schedule ? _self.schedule : schedule // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,timesPerDay: null == timesPerDay ? _self.timesPerDay : timesPerDay // ignore: cast_nullable_to_non_nullable
as int,dueTime: freezed == dueTime ? _self.dueTime : dueTime // ignore: cast_nullable_to_non_nullable
as String?,dueAt: freezed == dueAt ? _self.dueAt : dueAt // ignore: cast_nullable_to_non_nullable
as DateTime?,proof: null == proof ? _self.proof : proof // ignore: cast_nullable_to_non_nullable
as String,pointsEarn: null == pointsEarn ? _self.pointsEarn : pointsEarn // ignore: cast_nullable_to_non_nullable
as int,requiresDPresent: null == requiresDPresent ? _self.requiresDPresent : requiresDPresent // ignore: cast_nullable_to_non_nullable
as bool,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [NewTask].
extension NewTaskPatterns on NewTask {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NewTask value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NewTask() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NewTask value)  $default,){
final _that = this;
switch (_that) {
case _NewTask():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NewTask value)?  $default,){
final _that = this;
switch (_that) {
case _NewTask() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String? detail,  String kind,  Map<String, dynamic>? schedule,  int timesPerDay,  String? dueTime,  DateTime? dueAt,  String proof,  int pointsEarn,  bool requiresDPresent,  String? unit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NewTask() when $default != null:
return $default(_that.title,_that.detail,_that.kind,_that.schedule,_that.timesPerDay,_that.dueTime,_that.dueAt,_that.proof,_that.pointsEarn,_that.requiresDPresent,_that.unit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String? detail,  String kind,  Map<String, dynamic>? schedule,  int timesPerDay,  String? dueTime,  DateTime? dueAt,  String proof,  int pointsEarn,  bool requiresDPresent,  String? unit)  $default,) {final _that = this;
switch (_that) {
case _NewTask():
return $default(_that.title,_that.detail,_that.kind,_that.schedule,_that.timesPerDay,_that.dueTime,_that.dueAt,_that.proof,_that.pointsEarn,_that.requiresDPresent,_that.unit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String? detail,  String kind,  Map<String, dynamic>? schedule,  int timesPerDay,  String? dueTime,  DateTime? dueAt,  String proof,  int pointsEarn,  bool requiresDPresent,  String? unit)?  $default,) {final _that = this;
switch (_that) {
case _NewTask() when $default != null:
return $default(_that.title,_that.detail,_that.kind,_that.schedule,_that.timesPerDay,_that.dueTime,_that.dueAt,_that.proof,_that.pointsEarn,_that.requiresDPresent,_that.unit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NewTask implements NewTask {
  const _NewTask({required this.title, this.detail, this.kind = 'recurring', final  Map<String, dynamic>? schedule, this.timesPerDay = 1, this.dueTime, this.dueAt, this.proof = 'check', this.pointsEarn = 0, this.requiresDPresent = false, this.unit}): _schedule = schedule;
  factory _NewTask.fromJson(Map<String, dynamic> json) => _$NewTaskFromJson(json);

@override final  String title;
@override final  String? detail;
/// `recurring | one_off | open | checkin | measure`.
@override@JsonKey() final  String kind;
/// `{"type":"daily"}` and friends. Null lets the server default a
/// recurring task to daily.
 final  Map<String, dynamic>? _schedule;
/// `{"type":"daily"}` and friends. Null lets the server default a
/// recurring task to daily.
@override Map<String, dynamic>? get schedule {
  final value = _schedule;
  if (value == null) return null;
  if (_schedule is EqualUnmodifiableMapView) return _schedule;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override@JsonKey() final  int timesPerDay;
@override final  String? dueTime;
@override final  DateTime? dueAt;
@override@JsonKey() final  String proof;
@override@JsonKey() final  int pointsEarn;
@override@JsonKey() final  bool requiresDPresent;
@override final  String? unit;

/// Create a copy of NewTask
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NewTaskCopyWith<_NewTask> get copyWith => __$NewTaskCopyWithImpl<_NewTask>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NewTaskToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NewTask&&(identical(other.title, title) || other.title == title)&&(identical(other.detail, detail) || other.detail == detail)&&(identical(other.kind, kind) || other.kind == kind)&&const DeepCollectionEquality().equals(other._schedule, _schedule)&&(identical(other.timesPerDay, timesPerDay) || other.timesPerDay == timesPerDay)&&(identical(other.dueTime, dueTime) || other.dueTime == dueTime)&&(identical(other.dueAt, dueAt) || other.dueAt == dueAt)&&(identical(other.proof, proof) || other.proof == proof)&&(identical(other.pointsEarn, pointsEarn) || other.pointsEarn == pointsEarn)&&(identical(other.requiresDPresent, requiresDPresent) || other.requiresDPresent == requiresDPresent)&&(identical(other.unit, unit) || other.unit == unit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,detail,kind,const DeepCollectionEquality().hash(_schedule),timesPerDay,dueTime,dueAt,proof,pointsEarn,requiresDPresent,unit);

@override
String toString() {
  return 'NewTask(title: $title, detail: $detail, kind: $kind, schedule: $schedule, timesPerDay: $timesPerDay, dueTime: $dueTime, dueAt: $dueAt, proof: $proof, pointsEarn: $pointsEarn, requiresDPresent: $requiresDPresent, unit: $unit)';
}


}

/// @nodoc
abstract mixin class _$NewTaskCopyWith<$Res> implements $NewTaskCopyWith<$Res> {
  factory _$NewTaskCopyWith(_NewTask value, $Res Function(_NewTask) _then) = __$NewTaskCopyWithImpl;
@override @useResult
$Res call({
 String title, String? detail, String kind, Map<String, dynamic>? schedule, int timesPerDay, String? dueTime, DateTime? dueAt, String proof, int pointsEarn, bool requiresDPresent, String? unit
});




}
/// @nodoc
class __$NewTaskCopyWithImpl<$Res>
    implements _$NewTaskCopyWith<$Res> {
  __$NewTaskCopyWithImpl(this._self, this._then);

  final _NewTask _self;
  final $Res Function(_NewTask) _then;

/// Create a copy of NewTask
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? detail = freezed,Object? kind = null,Object? schedule = freezed,Object? timesPerDay = null,Object? dueTime = freezed,Object? dueAt = freezed,Object? proof = null,Object? pointsEarn = null,Object? requiresDPresent = null,Object? unit = freezed,}) {
  return _then(_NewTask(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,detail: freezed == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String?,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,schedule: freezed == schedule ? _self._schedule : schedule // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,timesPerDay: null == timesPerDay ? _self.timesPerDay : timesPerDay // ignore: cast_nullable_to_non_nullable
as int,dueTime: freezed == dueTime ? _self.dueTime : dueTime // ignore: cast_nullable_to_non_nullable
as String?,dueAt: freezed == dueAt ? _self.dueAt : dueAt // ignore: cast_nullable_to_non_nullable
as DateTime?,proof: null == proof ? _self.proof : proof // ignore: cast_nullable_to_non_nullable
as String,pointsEarn: null == pointsEarn ? _self.pointsEarn : pointsEarn // ignore: cast_nullable_to_non_nullable
as int,requiresDPresent: null == requiresDPresent ? _self.requiresDPresent : requiresDPresent // ignore: cast_nullable_to_non_nullable
as bool,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
