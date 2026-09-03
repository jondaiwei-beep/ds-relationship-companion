// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MonthCell {

/// `yyyy-MM-dd`.
 String get day; int get due; int get delivered; int get flagged; int get missed; int get undisposed; int get comments; bool get hasPrivateNote;
/// Create a copy of MonthCell
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MonthCellCopyWith<MonthCell> get copyWith => _$MonthCellCopyWithImpl<MonthCell>(this as MonthCell, _$identity);

  /// Serializes this MonthCell to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MonthCell&&(identical(other.day, day) || other.day == day)&&(identical(other.due, due) || other.due == due)&&(identical(other.delivered, delivered) || other.delivered == delivered)&&(identical(other.flagged, flagged) || other.flagged == flagged)&&(identical(other.missed, missed) || other.missed == missed)&&(identical(other.undisposed, undisposed) || other.undisposed == undisposed)&&(identical(other.comments, comments) || other.comments == comments)&&(identical(other.hasPrivateNote, hasPrivateNote) || other.hasPrivateNote == hasPrivateNote));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,day,due,delivered,flagged,missed,undisposed,comments,hasPrivateNote);

@override
String toString() {
  return 'MonthCell(day: $day, due: $due, delivered: $delivered, flagged: $flagged, missed: $missed, undisposed: $undisposed, comments: $comments, hasPrivateNote: $hasPrivateNote)';
}


}

/// @nodoc
abstract mixin class $MonthCellCopyWith<$Res>  {
  factory $MonthCellCopyWith(MonthCell value, $Res Function(MonthCell) _then) = _$MonthCellCopyWithImpl;
@useResult
$Res call({
 String day, int due, int delivered, int flagged, int missed, int undisposed, int comments, bool hasPrivateNote
});




}
/// @nodoc
class _$MonthCellCopyWithImpl<$Res>
    implements $MonthCellCopyWith<$Res> {
  _$MonthCellCopyWithImpl(this._self, this._then);

  final MonthCell _self;
  final $Res Function(MonthCell) _then;

/// Create a copy of MonthCell
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? day = null,Object? due = null,Object? delivered = null,Object? flagged = null,Object? missed = null,Object? undisposed = null,Object? comments = null,Object? hasPrivateNote = null,}) {
  return _then(_self.copyWith(
day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as String,due: null == due ? _self.due : due // ignore: cast_nullable_to_non_nullable
as int,delivered: null == delivered ? _self.delivered : delivered // ignore: cast_nullable_to_non_nullable
as int,flagged: null == flagged ? _self.flagged : flagged // ignore: cast_nullable_to_non_nullable
as int,missed: null == missed ? _self.missed : missed // ignore: cast_nullable_to_non_nullable
as int,undisposed: null == undisposed ? _self.undisposed : undisposed // ignore: cast_nullable_to_non_nullable
as int,comments: null == comments ? _self.comments : comments // ignore: cast_nullable_to_non_nullable
as int,hasPrivateNote: null == hasPrivateNote ? _self.hasPrivateNote : hasPrivateNote // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [MonthCell].
extension MonthCellPatterns on MonthCell {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MonthCell value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MonthCell() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MonthCell value)  $default,){
final _that = this;
switch (_that) {
case _MonthCell():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MonthCell value)?  $default,){
final _that = this;
switch (_that) {
case _MonthCell() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String day,  int due,  int delivered,  int flagged,  int missed,  int undisposed,  int comments,  bool hasPrivateNote)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MonthCell() when $default != null:
return $default(_that.day,_that.due,_that.delivered,_that.flagged,_that.missed,_that.undisposed,_that.comments,_that.hasPrivateNote);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String day,  int due,  int delivered,  int flagged,  int missed,  int undisposed,  int comments,  bool hasPrivateNote)  $default,) {final _that = this;
switch (_that) {
case _MonthCell():
return $default(_that.day,_that.due,_that.delivered,_that.flagged,_that.missed,_that.undisposed,_that.comments,_that.hasPrivateNote);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String day,  int due,  int delivered,  int flagged,  int missed,  int undisposed,  int comments,  bool hasPrivateNote)?  $default,) {final _that = this;
switch (_that) {
case _MonthCell() when $default != null:
return $default(_that.day,_that.due,_that.delivered,_that.flagged,_that.missed,_that.undisposed,_that.comments,_that.hasPrivateNote);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MonthCell implements MonthCell {
  const _MonthCell({required this.day, this.due = 0, this.delivered = 0, this.flagged = 0, this.missed = 0, this.undisposed = 0, this.comments = 0, this.hasPrivateNote = false});
  factory _MonthCell.fromJson(Map<String, dynamic> json) => _$MonthCellFromJson(json);

/// `yyyy-MM-dd`.
@override final  String day;
@override@JsonKey() final  int due;
@override@JsonKey() final  int delivered;
@override@JsonKey() final  int flagged;
@override@JsonKey() final  int missed;
@override@JsonKey() final  int undisposed;
@override@JsonKey() final  int comments;
@override@JsonKey() final  bool hasPrivateNote;

/// Create a copy of MonthCell
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MonthCellCopyWith<_MonthCell> get copyWith => __$MonthCellCopyWithImpl<_MonthCell>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MonthCellToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MonthCell&&(identical(other.day, day) || other.day == day)&&(identical(other.due, due) || other.due == due)&&(identical(other.delivered, delivered) || other.delivered == delivered)&&(identical(other.flagged, flagged) || other.flagged == flagged)&&(identical(other.missed, missed) || other.missed == missed)&&(identical(other.undisposed, undisposed) || other.undisposed == undisposed)&&(identical(other.comments, comments) || other.comments == comments)&&(identical(other.hasPrivateNote, hasPrivateNote) || other.hasPrivateNote == hasPrivateNote));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,day,due,delivered,flagged,missed,undisposed,comments,hasPrivateNote);

@override
String toString() {
  return 'MonthCell(day: $day, due: $due, delivered: $delivered, flagged: $flagged, missed: $missed, undisposed: $undisposed, comments: $comments, hasPrivateNote: $hasPrivateNote)';
}


}

/// @nodoc
abstract mixin class _$MonthCellCopyWith<$Res> implements $MonthCellCopyWith<$Res> {
  factory _$MonthCellCopyWith(_MonthCell value, $Res Function(_MonthCell) _then) = __$MonthCellCopyWithImpl;
@override @useResult
$Res call({
 String day, int due, int delivered, int flagged, int missed, int undisposed, int comments, bool hasPrivateNote
});




}
/// @nodoc
class __$MonthCellCopyWithImpl<$Res>
    implements _$MonthCellCopyWith<$Res> {
  __$MonthCellCopyWithImpl(this._self, this._then);

  final _MonthCell _self;
  final $Res Function(_MonthCell) _then;

/// Create a copy of MonthCell
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? day = null,Object? due = null,Object? delivered = null,Object? flagged = null,Object? missed = null,Object? undisposed = null,Object? comments = null,Object? hasPrivateNote = null,}) {
  return _then(_MonthCell(
day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as String,due: null == due ? _self.due : due // ignore: cast_nullable_to_non_nullable
as int,delivered: null == delivered ? _self.delivered : delivered // ignore: cast_nullable_to_non_nullable
as int,flagged: null == flagged ? _self.flagged : flagged // ignore: cast_nullable_to_non_nullable
as int,missed: null == missed ? _self.missed : missed // ignore: cast_nullable_to_non_nullable
as int,undisposed: null == undisposed ? _self.undisposed : undisposed // ignore: cast_nullable_to_non_nullable
as int,comments: null == comments ? _self.comments : comments // ignore: cast_nullable_to_non_nullable
as int,hasPrivateNote: null == hasPrivateNote ? _self.hasPrivateNote : hasPrivateNote // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$OutcomeEntry {

 String get occurrenceId; String get taskId; String get taskTitle;/// The wire spelling (`delivered`, `missed`, …).
 String get toValue; String? get note; String? get proofKind; String? get proofRef;/// `kind=measure` only: the number delivered, in [unit].
@JsonKey(fromJson: decimalFromJson) double? get value; String? get unit;
/// Create a copy of OutcomeEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OutcomeEntryCopyWith<OutcomeEntry> get copyWith => _$OutcomeEntryCopyWithImpl<OutcomeEntry>(this as OutcomeEntry, _$identity);

  /// Serializes this OutcomeEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OutcomeEntry&&(identical(other.occurrenceId, occurrenceId) || other.occurrenceId == occurrenceId)&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.taskTitle, taskTitle) || other.taskTitle == taskTitle)&&(identical(other.toValue, toValue) || other.toValue == toValue)&&(identical(other.note, note) || other.note == note)&&(identical(other.proofKind, proofKind) || other.proofKind == proofKind)&&(identical(other.proofRef, proofRef) || other.proofRef == proofRef)&&(identical(other.value, value) || other.value == value)&&(identical(other.unit, unit) || other.unit == unit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,occurrenceId,taskId,taskTitle,toValue,note,proofKind,proofRef,value,unit);

@override
String toString() {
  return 'OutcomeEntry(occurrenceId: $occurrenceId, taskId: $taskId, taskTitle: $taskTitle, toValue: $toValue, note: $note, proofKind: $proofKind, proofRef: $proofRef, value: $value, unit: $unit)';
}


}

/// @nodoc
abstract mixin class $OutcomeEntryCopyWith<$Res>  {
  factory $OutcomeEntryCopyWith(OutcomeEntry value, $Res Function(OutcomeEntry) _then) = _$OutcomeEntryCopyWithImpl;
@useResult
$Res call({
 String occurrenceId, String taskId, String taskTitle, String toValue, String? note, String? proofKind, String? proofRef,@JsonKey(fromJson: decimalFromJson) double? value, String? unit
});




}
/// @nodoc
class _$OutcomeEntryCopyWithImpl<$Res>
    implements $OutcomeEntryCopyWith<$Res> {
  _$OutcomeEntryCopyWithImpl(this._self, this._then);

  final OutcomeEntry _self;
  final $Res Function(OutcomeEntry) _then;

/// Create a copy of OutcomeEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? occurrenceId = null,Object? taskId = null,Object? taskTitle = null,Object? toValue = null,Object? note = freezed,Object? proofKind = freezed,Object? proofRef = freezed,Object? value = freezed,Object? unit = freezed,}) {
  return _then(_self.copyWith(
occurrenceId: null == occurrenceId ? _self.occurrenceId : occurrenceId // ignore: cast_nullable_to_non_nullable
as String,taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,taskTitle: null == taskTitle ? _self.taskTitle : taskTitle // ignore: cast_nullable_to_non_nullable
as String,toValue: null == toValue ? _self.toValue : toValue // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,proofKind: freezed == proofKind ? _self.proofKind : proofKind // ignore: cast_nullable_to_non_nullable
as String?,proofRef: freezed == proofRef ? _self.proofRef : proofRef // ignore: cast_nullable_to_non_nullable
as String?,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [OutcomeEntry].
extension OutcomeEntryPatterns on OutcomeEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OutcomeEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OutcomeEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OutcomeEntry value)  $default,){
final _that = this;
switch (_that) {
case _OutcomeEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OutcomeEntry value)?  $default,){
final _that = this;
switch (_that) {
case _OutcomeEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String occurrenceId,  String taskId,  String taskTitle,  String toValue,  String? note,  String? proofKind,  String? proofRef, @JsonKey(fromJson: decimalFromJson)  double? value,  String? unit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OutcomeEntry() when $default != null:
return $default(_that.occurrenceId,_that.taskId,_that.taskTitle,_that.toValue,_that.note,_that.proofKind,_that.proofRef,_that.value,_that.unit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String occurrenceId,  String taskId,  String taskTitle,  String toValue,  String? note,  String? proofKind,  String? proofRef, @JsonKey(fromJson: decimalFromJson)  double? value,  String? unit)  $default,) {final _that = this;
switch (_that) {
case _OutcomeEntry():
return $default(_that.occurrenceId,_that.taskId,_that.taskTitle,_that.toValue,_that.note,_that.proofKind,_that.proofRef,_that.value,_that.unit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String occurrenceId,  String taskId,  String taskTitle,  String toValue,  String? note,  String? proofKind,  String? proofRef, @JsonKey(fromJson: decimalFromJson)  double? value,  String? unit)?  $default,) {final _that = this;
switch (_that) {
case _OutcomeEntry() when $default != null:
return $default(_that.occurrenceId,_that.taskId,_that.taskTitle,_that.toValue,_that.note,_that.proofKind,_that.proofRef,_that.value,_that.unit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OutcomeEntry extends OutcomeEntry {
  const _OutcomeEntry({required this.occurrenceId, required this.taskId, required this.taskTitle, required this.toValue, this.note, this.proofKind, this.proofRef, @JsonKey(fromJson: decimalFromJson) this.value, this.unit}): super._();
  factory _OutcomeEntry.fromJson(Map<String, dynamic> json) => _$OutcomeEntryFromJson(json);

@override final  String occurrenceId;
@override final  String taskId;
@override final  String taskTitle;
/// The wire spelling (`delivered`, `missed`, …).
@override final  String toValue;
@override final  String? note;
@override final  String? proofKind;
@override final  String? proofRef;
/// `kind=measure` only: the number delivered, in [unit].
@override@JsonKey(fromJson: decimalFromJson) final  double? value;
@override final  String? unit;

/// Create a copy of OutcomeEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OutcomeEntryCopyWith<_OutcomeEntry> get copyWith => __$OutcomeEntryCopyWithImpl<_OutcomeEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OutcomeEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OutcomeEntry&&(identical(other.occurrenceId, occurrenceId) || other.occurrenceId == occurrenceId)&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.taskTitle, taskTitle) || other.taskTitle == taskTitle)&&(identical(other.toValue, toValue) || other.toValue == toValue)&&(identical(other.note, note) || other.note == note)&&(identical(other.proofKind, proofKind) || other.proofKind == proofKind)&&(identical(other.proofRef, proofRef) || other.proofRef == proofRef)&&(identical(other.value, value) || other.value == value)&&(identical(other.unit, unit) || other.unit == unit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,occurrenceId,taskId,taskTitle,toValue,note,proofKind,proofRef,value,unit);

@override
String toString() {
  return 'OutcomeEntry(occurrenceId: $occurrenceId, taskId: $taskId, taskTitle: $taskTitle, toValue: $toValue, note: $note, proofKind: $proofKind, proofRef: $proofRef, value: $value, unit: $unit)';
}


}

/// @nodoc
abstract mixin class _$OutcomeEntryCopyWith<$Res> implements $OutcomeEntryCopyWith<$Res> {
  factory _$OutcomeEntryCopyWith(_OutcomeEntry value, $Res Function(_OutcomeEntry) _then) = __$OutcomeEntryCopyWithImpl;
@override @useResult
$Res call({
 String occurrenceId, String taskId, String taskTitle, String toValue, String? note, String? proofKind, String? proofRef,@JsonKey(fromJson: decimalFromJson) double? value, String? unit
});




}
/// @nodoc
class __$OutcomeEntryCopyWithImpl<$Res>
    implements _$OutcomeEntryCopyWith<$Res> {
  __$OutcomeEntryCopyWithImpl(this._self, this._then);

  final _OutcomeEntry _self;
  final $Res Function(_OutcomeEntry) _then;

/// Create a copy of OutcomeEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? occurrenceId = null,Object? taskId = null,Object? taskTitle = null,Object? toValue = null,Object? note = freezed,Object? proofKind = freezed,Object? proofRef = freezed,Object? value = freezed,Object? unit = freezed,}) {
  return _then(_OutcomeEntry(
occurrenceId: null == occurrenceId ? _self.occurrenceId : occurrenceId // ignore: cast_nullable_to_non_nullable
as String,taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,taskTitle: null == taskTitle ? _self.taskTitle : taskTitle // ignore: cast_nullable_to_non_nullable
as String,toValue: null == toValue ? _self.toValue : toValue // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,proofKind: freezed == proofKind ? _self.proofKind : proofKind // ignore: cast_nullable_to_non_nullable
as String?,proofRef: freezed == proofRef ? _self.proofRef : proofRef // ignore: cast_nullable_to_non_nullable
as String?,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$DispositionEntry {

 String get occurrenceId; String get taskId; String get taskTitle; String get toValue; String? get note; String? get consequenceTitle;/// `yyyy-MM-dd`, when the D asked for it to be made up.
 String? get makeUpDay;
/// Create a copy of DispositionEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DispositionEntryCopyWith<DispositionEntry> get copyWith => _$DispositionEntryCopyWithImpl<DispositionEntry>(this as DispositionEntry, _$identity);

  /// Serializes this DispositionEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DispositionEntry&&(identical(other.occurrenceId, occurrenceId) || other.occurrenceId == occurrenceId)&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.taskTitle, taskTitle) || other.taskTitle == taskTitle)&&(identical(other.toValue, toValue) || other.toValue == toValue)&&(identical(other.note, note) || other.note == note)&&(identical(other.consequenceTitle, consequenceTitle) || other.consequenceTitle == consequenceTitle)&&(identical(other.makeUpDay, makeUpDay) || other.makeUpDay == makeUpDay));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,occurrenceId,taskId,taskTitle,toValue,note,consequenceTitle,makeUpDay);

@override
String toString() {
  return 'DispositionEntry(occurrenceId: $occurrenceId, taskId: $taskId, taskTitle: $taskTitle, toValue: $toValue, note: $note, consequenceTitle: $consequenceTitle, makeUpDay: $makeUpDay)';
}


}

/// @nodoc
abstract mixin class $DispositionEntryCopyWith<$Res>  {
  factory $DispositionEntryCopyWith(DispositionEntry value, $Res Function(DispositionEntry) _then) = _$DispositionEntryCopyWithImpl;
@useResult
$Res call({
 String occurrenceId, String taskId, String taskTitle, String toValue, String? note, String? consequenceTitle, String? makeUpDay
});




}
/// @nodoc
class _$DispositionEntryCopyWithImpl<$Res>
    implements $DispositionEntryCopyWith<$Res> {
  _$DispositionEntryCopyWithImpl(this._self, this._then);

  final DispositionEntry _self;
  final $Res Function(DispositionEntry) _then;

/// Create a copy of DispositionEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? occurrenceId = null,Object? taskId = null,Object? taskTitle = null,Object? toValue = null,Object? note = freezed,Object? consequenceTitle = freezed,Object? makeUpDay = freezed,}) {
  return _then(_self.copyWith(
occurrenceId: null == occurrenceId ? _self.occurrenceId : occurrenceId // ignore: cast_nullable_to_non_nullable
as String,taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,taskTitle: null == taskTitle ? _self.taskTitle : taskTitle // ignore: cast_nullable_to_non_nullable
as String,toValue: null == toValue ? _self.toValue : toValue // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,consequenceTitle: freezed == consequenceTitle ? _self.consequenceTitle : consequenceTitle // ignore: cast_nullable_to_non_nullable
as String?,makeUpDay: freezed == makeUpDay ? _self.makeUpDay : makeUpDay // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DispositionEntry].
extension DispositionEntryPatterns on DispositionEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DispositionEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DispositionEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DispositionEntry value)  $default,){
final _that = this;
switch (_that) {
case _DispositionEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DispositionEntry value)?  $default,){
final _that = this;
switch (_that) {
case _DispositionEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String occurrenceId,  String taskId,  String taskTitle,  String toValue,  String? note,  String? consequenceTitle,  String? makeUpDay)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DispositionEntry() when $default != null:
return $default(_that.occurrenceId,_that.taskId,_that.taskTitle,_that.toValue,_that.note,_that.consequenceTitle,_that.makeUpDay);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String occurrenceId,  String taskId,  String taskTitle,  String toValue,  String? note,  String? consequenceTitle,  String? makeUpDay)  $default,) {final _that = this;
switch (_that) {
case _DispositionEntry():
return $default(_that.occurrenceId,_that.taskId,_that.taskTitle,_that.toValue,_that.note,_that.consequenceTitle,_that.makeUpDay);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String occurrenceId,  String taskId,  String taskTitle,  String toValue,  String? note,  String? consequenceTitle,  String? makeUpDay)?  $default,) {final _that = this;
switch (_that) {
case _DispositionEntry() when $default != null:
return $default(_that.occurrenceId,_that.taskId,_that.taskTitle,_that.toValue,_that.note,_that.consequenceTitle,_that.makeUpDay);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DispositionEntry extends DispositionEntry {
  const _DispositionEntry({required this.occurrenceId, required this.taskId, required this.taskTitle, required this.toValue, this.note, this.consequenceTitle, this.makeUpDay}): super._();
  factory _DispositionEntry.fromJson(Map<String, dynamic> json) => _$DispositionEntryFromJson(json);

@override final  String occurrenceId;
@override final  String taskId;
@override final  String taskTitle;
@override final  String toValue;
@override final  String? note;
@override final  String? consequenceTitle;
/// `yyyy-MM-dd`, when the D asked for it to be made up.
@override final  String? makeUpDay;

/// Create a copy of DispositionEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DispositionEntryCopyWith<_DispositionEntry> get copyWith => __$DispositionEntryCopyWithImpl<_DispositionEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DispositionEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DispositionEntry&&(identical(other.occurrenceId, occurrenceId) || other.occurrenceId == occurrenceId)&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.taskTitle, taskTitle) || other.taskTitle == taskTitle)&&(identical(other.toValue, toValue) || other.toValue == toValue)&&(identical(other.note, note) || other.note == note)&&(identical(other.consequenceTitle, consequenceTitle) || other.consequenceTitle == consequenceTitle)&&(identical(other.makeUpDay, makeUpDay) || other.makeUpDay == makeUpDay));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,occurrenceId,taskId,taskTitle,toValue,note,consequenceTitle,makeUpDay);

@override
String toString() {
  return 'DispositionEntry(occurrenceId: $occurrenceId, taskId: $taskId, taskTitle: $taskTitle, toValue: $toValue, note: $note, consequenceTitle: $consequenceTitle, makeUpDay: $makeUpDay)';
}


}

/// @nodoc
abstract mixin class _$DispositionEntryCopyWith<$Res> implements $DispositionEntryCopyWith<$Res> {
  factory _$DispositionEntryCopyWith(_DispositionEntry value, $Res Function(_DispositionEntry) _then) = __$DispositionEntryCopyWithImpl;
@override @useResult
$Res call({
 String occurrenceId, String taskId, String taskTitle, String toValue, String? note, String? consequenceTitle, String? makeUpDay
});




}
/// @nodoc
class __$DispositionEntryCopyWithImpl<$Res>
    implements _$DispositionEntryCopyWith<$Res> {
  __$DispositionEntryCopyWithImpl(this._self, this._then);

  final _DispositionEntry _self;
  final $Res Function(_DispositionEntry) _then;

/// Create a copy of DispositionEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? occurrenceId = null,Object? taskId = null,Object? taskTitle = null,Object? toValue = null,Object? note = freezed,Object? consequenceTitle = freezed,Object? makeUpDay = freezed,}) {
  return _then(_DispositionEntry(
occurrenceId: null == occurrenceId ? _self.occurrenceId : occurrenceId // ignore: cast_nullable_to_non_nullable
as String,taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,taskTitle: null == taskTitle ? _self.taskTitle : taskTitle // ignore: cast_nullable_to_non_nullable
as String,toValue: null == toValue ? _self.toValue : toValue // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,consequenceTitle: freezed == consequenceTitle ? _self.consequenceTitle : consequenceTitle // ignore: cast_nullable_to_non_nullable
as String?,makeUpDay: freezed == makeUpDay ? _self.makeUpDay : makeUpDay // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$CommentEntry {

 String get id; String get authorId; String get body;
/// Create a copy of CommentEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommentEntryCopyWith<CommentEntry> get copyWith => _$CommentEntryCopyWithImpl<CommentEntry>(this as CommentEntry, _$identity);

  /// Serializes this CommentEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommentEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.authorId, authorId) || other.authorId == authorId)&&(identical(other.body, body) || other.body == body));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,authorId,body);

@override
String toString() {
  return 'CommentEntry(id: $id, authorId: $authorId, body: $body)';
}


}

/// @nodoc
abstract mixin class $CommentEntryCopyWith<$Res>  {
  factory $CommentEntryCopyWith(CommentEntry value, $Res Function(CommentEntry) _then) = _$CommentEntryCopyWithImpl;
@useResult
$Res call({
 String id, String authorId, String body
});




}
/// @nodoc
class _$CommentEntryCopyWithImpl<$Res>
    implements $CommentEntryCopyWith<$Res> {
  _$CommentEntryCopyWithImpl(this._self, this._then);

  final CommentEntry _self;
  final $Res Function(CommentEntry) _then;

/// Create a copy of CommentEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? authorId = null,Object? body = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,authorId: null == authorId ? _self.authorId : authorId // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CommentEntry].
extension CommentEntryPatterns on CommentEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommentEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommentEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommentEntry value)  $default,){
final _that = this;
switch (_that) {
case _CommentEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommentEntry value)?  $default,){
final _that = this;
switch (_that) {
case _CommentEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String authorId,  String body)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommentEntry() when $default != null:
return $default(_that.id,_that.authorId,_that.body);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String authorId,  String body)  $default,) {final _that = this;
switch (_that) {
case _CommentEntry():
return $default(_that.id,_that.authorId,_that.body);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String authorId,  String body)?  $default,) {final _that = this;
switch (_that) {
case _CommentEntry() when $default != null:
return $default(_that.id,_that.authorId,_that.body);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CommentEntry implements CommentEntry {
  const _CommentEntry({required this.id, required this.authorId, required this.body});
  factory _CommentEntry.fromJson(Map<String, dynamic> json) => _$CommentEntryFromJson(json);

@override final  String id;
@override final  String authorId;
@override final  String body;

/// Create a copy of CommentEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommentEntryCopyWith<_CommentEntry> get copyWith => __$CommentEntryCopyWithImpl<_CommentEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CommentEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommentEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.authorId, authorId) || other.authorId == authorId)&&(identical(other.body, body) || other.body == body));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,authorId,body);

@override
String toString() {
  return 'CommentEntry(id: $id, authorId: $authorId, body: $body)';
}


}

/// @nodoc
abstract mixin class _$CommentEntryCopyWith<$Res> implements $CommentEntryCopyWith<$Res> {
  factory _$CommentEntryCopyWith(_CommentEntry value, $Res Function(_CommentEntry) _then) = __$CommentEntryCopyWithImpl;
@override @useResult
$Res call({
 String id, String authorId, String body
});




}
/// @nodoc
class __$CommentEntryCopyWithImpl<$Res>
    implements _$CommentEntryCopyWith<$Res> {
  __$CommentEntryCopyWithImpl(this._self, this._then);

  final _CommentEntry _self;
  final $Res Function(_CommentEntry) _then;

/// Create a copy of CommentEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? authorId = null,Object? body = null,}) {
  return _then(_CommentEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,authorId: null == authorId ? _self.authorId : authorId // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$PointsEntry {

 String get id;/// `task_earn | d_award | d_deduct | redemption | redemption_refund`.
 String get reason; int get amount; String? get note;/// Null when no person wrote it (a task's own points on delivery).
 String? get actorUserId;
/// Create a copy of PointsEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PointsEntryCopyWith<PointsEntry> get copyWith => _$PointsEntryCopyWithImpl<PointsEntry>(this as PointsEntry, _$identity);

  /// Serializes this PointsEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PointsEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.note, note) || other.note == note)&&(identical(other.actorUserId, actorUserId) || other.actorUserId == actorUserId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,reason,amount,note,actorUserId);

@override
String toString() {
  return 'PointsEntry(id: $id, reason: $reason, amount: $amount, note: $note, actorUserId: $actorUserId)';
}


}

/// @nodoc
abstract mixin class $PointsEntryCopyWith<$Res>  {
  factory $PointsEntryCopyWith(PointsEntry value, $Res Function(PointsEntry) _then) = _$PointsEntryCopyWithImpl;
@useResult
$Res call({
 String id, String reason, int amount, String? note, String? actorUserId
});




}
/// @nodoc
class _$PointsEntryCopyWithImpl<$Res>
    implements $PointsEntryCopyWith<$Res> {
  _$PointsEntryCopyWithImpl(this._self, this._then);

  final PointsEntry _self;
  final $Res Function(PointsEntry) _then;

/// Create a copy of PointsEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? reason = null,Object? amount = null,Object? note = freezed,Object? actorUserId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,actorUserId: freezed == actorUserId ? _self.actorUserId : actorUserId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PointsEntry].
extension PointsEntryPatterns on PointsEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PointsEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PointsEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PointsEntry value)  $default,){
final _that = this;
switch (_that) {
case _PointsEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PointsEntry value)?  $default,){
final _that = this;
switch (_that) {
case _PointsEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String reason,  int amount,  String? note,  String? actorUserId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PointsEntry() when $default != null:
return $default(_that.id,_that.reason,_that.amount,_that.note,_that.actorUserId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String reason,  int amount,  String? note,  String? actorUserId)  $default,) {final _that = this;
switch (_that) {
case _PointsEntry():
return $default(_that.id,_that.reason,_that.amount,_that.note,_that.actorUserId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String reason,  int amount,  String? note,  String? actorUserId)?  $default,) {final _that = this;
switch (_that) {
case _PointsEntry() when $default != null:
return $default(_that.id,_that.reason,_that.amount,_that.note,_that.actorUserId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PointsEntry implements PointsEntry {
  const _PointsEntry({required this.id, required this.reason, required this.amount, this.note, this.actorUserId});
  factory _PointsEntry.fromJson(Map<String, dynamic> json) => _$PointsEntryFromJson(json);

@override final  String id;
/// `task_earn | d_award | d_deduct | redemption | redemption_refund`.
@override final  String reason;
@override final  int amount;
@override final  String? note;
/// Null when no person wrote it (a task's own points on delivery).
@override final  String? actorUserId;

/// Create a copy of PointsEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PointsEntryCopyWith<_PointsEntry> get copyWith => __$PointsEntryCopyWithImpl<_PointsEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PointsEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PointsEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.note, note) || other.note == note)&&(identical(other.actorUserId, actorUserId) || other.actorUserId == actorUserId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,reason,amount,note,actorUserId);

@override
String toString() {
  return 'PointsEntry(id: $id, reason: $reason, amount: $amount, note: $note, actorUserId: $actorUserId)';
}


}

/// @nodoc
abstract mixin class _$PointsEntryCopyWith<$Res> implements $PointsEntryCopyWith<$Res> {
  factory _$PointsEntryCopyWith(_PointsEntry value, $Res Function(_PointsEntry) _then) = __$PointsEntryCopyWithImpl;
@override @useResult
$Res call({
 String id, String reason, int amount, String? note, String? actorUserId
});




}
/// @nodoc
class __$PointsEntryCopyWithImpl<$Res>
    implements _$PointsEntryCopyWith<$Res> {
  __$PointsEntryCopyWithImpl(this._self, this._then);

  final _PointsEntry _self;
  final $Res Function(_PointsEntry) _then;

/// Create a copy of PointsEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? reason = null,Object? amount = null,Object? note = freezed,Object? actorUserId = freezed,}) {
  return _then(_PointsEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,actorUserId: freezed == actorUserId ? _self.actorUserId : actorUserId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$RedemptionEntry {

 String get id; String get rewardId; String get rewardTitle; String? get givenByUserId; String get subjectUserId;
/// Create a copy of RedemptionEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RedemptionEntryCopyWith<RedemptionEntry> get copyWith => _$RedemptionEntryCopyWithImpl<RedemptionEntry>(this as RedemptionEntry, _$identity);

  /// Serializes this RedemptionEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RedemptionEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.rewardId, rewardId) || other.rewardId == rewardId)&&(identical(other.rewardTitle, rewardTitle) || other.rewardTitle == rewardTitle)&&(identical(other.givenByUserId, givenByUserId) || other.givenByUserId == givenByUserId)&&(identical(other.subjectUserId, subjectUserId) || other.subjectUserId == subjectUserId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,rewardId,rewardTitle,givenByUserId,subjectUserId);

@override
String toString() {
  return 'RedemptionEntry(id: $id, rewardId: $rewardId, rewardTitle: $rewardTitle, givenByUserId: $givenByUserId, subjectUserId: $subjectUserId)';
}


}

/// @nodoc
abstract mixin class $RedemptionEntryCopyWith<$Res>  {
  factory $RedemptionEntryCopyWith(RedemptionEntry value, $Res Function(RedemptionEntry) _then) = _$RedemptionEntryCopyWithImpl;
@useResult
$Res call({
 String id, String rewardId, String rewardTitle, String? givenByUserId, String subjectUserId
});




}
/// @nodoc
class _$RedemptionEntryCopyWithImpl<$Res>
    implements $RedemptionEntryCopyWith<$Res> {
  _$RedemptionEntryCopyWithImpl(this._self, this._then);

  final RedemptionEntry _self;
  final $Res Function(RedemptionEntry) _then;

/// Create a copy of RedemptionEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? rewardId = null,Object? rewardTitle = null,Object? givenByUserId = freezed,Object? subjectUserId = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,rewardId: null == rewardId ? _self.rewardId : rewardId // ignore: cast_nullable_to_non_nullable
as String,rewardTitle: null == rewardTitle ? _self.rewardTitle : rewardTitle // ignore: cast_nullable_to_non_nullable
as String,givenByUserId: freezed == givenByUserId ? _self.givenByUserId : givenByUserId // ignore: cast_nullable_to_non_nullable
as String?,subjectUserId: null == subjectUserId ? _self.subjectUserId : subjectUserId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RedemptionEntry].
extension RedemptionEntryPatterns on RedemptionEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RedemptionEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RedemptionEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RedemptionEntry value)  $default,){
final _that = this;
switch (_that) {
case _RedemptionEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RedemptionEntry value)?  $default,){
final _that = this;
switch (_that) {
case _RedemptionEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String rewardId,  String rewardTitle,  String? givenByUserId,  String subjectUserId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RedemptionEntry() when $default != null:
return $default(_that.id,_that.rewardId,_that.rewardTitle,_that.givenByUserId,_that.subjectUserId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String rewardId,  String rewardTitle,  String? givenByUserId,  String subjectUserId)  $default,) {final _that = this;
switch (_that) {
case _RedemptionEntry():
return $default(_that.id,_that.rewardId,_that.rewardTitle,_that.givenByUserId,_that.subjectUserId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String rewardId,  String rewardTitle,  String? givenByUserId,  String subjectUserId)?  $default,) {final _that = this;
switch (_that) {
case _RedemptionEntry() when $default != null:
return $default(_that.id,_that.rewardId,_that.rewardTitle,_that.givenByUserId,_that.subjectUserId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RedemptionEntry implements RedemptionEntry {
  const _RedemptionEntry({required this.id, required this.rewardId, required this.rewardTitle, this.givenByUserId, required this.subjectUserId});
  factory _RedemptionEntry.fromJson(Map<String, dynamic> json) => _$RedemptionEntryFromJson(json);

@override final  String id;
@override final  String rewardId;
@override final  String rewardTitle;
@override final  String? givenByUserId;
@override final  String subjectUserId;

/// Create a copy of RedemptionEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RedemptionEntryCopyWith<_RedemptionEntry> get copyWith => __$RedemptionEntryCopyWithImpl<_RedemptionEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RedemptionEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RedemptionEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.rewardId, rewardId) || other.rewardId == rewardId)&&(identical(other.rewardTitle, rewardTitle) || other.rewardTitle == rewardTitle)&&(identical(other.givenByUserId, givenByUserId) || other.givenByUserId == givenByUserId)&&(identical(other.subjectUserId, subjectUserId) || other.subjectUserId == subjectUserId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,rewardId,rewardTitle,givenByUserId,subjectUserId);

@override
String toString() {
  return 'RedemptionEntry(id: $id, rewardId: $rewardId, rewardTitle: $rewardTitle, givenByUserId: $givenByUserId, subjectUserId: $subjectUserId)';
}


}

/// @nodoc
abstract mixin class _$RedemptionEntryCopyWith<$Res> implements $RedemptionEntryCopyWith<$Res> {
  factory _$RedemptionEntryCopyWith(_RedemptionEntry value, $Res Function(_RedemptionEntry) _then) = __$RedemptionEntryCopyWithImpl;
@override @useResult
$Res call({
 String id, String rewardId, String rewardTitle, String? givenByUserId, String subjectUserId
});




}
/// @nodoc
class __$RedemptionEntryCopyWithImpl<$Res>
    implements _$RedemptionEntryCopyWith<$Res> {
  __$RedemptionEntryCopyWithImpl(this._self, this._then);

  final _RedemptionEntry _self;
  final $Res Function(_RedemptionEntry) _then;

/// Create a copy of RedemptionEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? rewardId = null,Object? rewardTitle = null,Object? givenByUserId = freezed,Object? subjectUserId = null,}) {
  return _then(_RedemptionEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,rewardId: null == rewardId ? _self.rewardId : rewardId // ignore: cast_nullable_to_non_nullable
as String,rewardTitle: null == rewardTitle ? _self.rewardTitle : rewardTitle // ignore: cast_nullable_to_non_nullable
as String,givenByUserId: freezed == givenByUserId ? _self.givenByUserId : givenByUserId // ignore: cast_nullable_to_non_nullable
as String?,subjectUserId: null == subjectUserId ? _self.subjectUserId : subjectUserId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$TimelineEntry {

 DateTime get at;/// `outcome | disposition | comment | points | redemption`.
 String get kind; OutcomeEntry? get outcome; DispositionEntry? get disposition; CommentEntry? get comment; PointsEntry? get points; RedemptionEntry? get redemption;
/// Create a copy of TimelineEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TimelineEntryCopyWith<TimelineEntry> get copyWith => _$TimelineEntryCopyWithImpl<TimelineEntry>(this as TimelineEntry, _$identity);

  /// Serializes this TimelineEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimelineEntry&&(identical(other.at, at) || other.at == at)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.outcome, outcome) || other.outcome == outcome)&&(identical(other.disposition, disposition) || other.disposition == disposition)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.points, points) || other.points == points)&&(identical(other.redemption, redemption) || other.redemption == redemption));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,at,kind,outcome,disposition,comment,points,redemption);

@override
String toString() {
  return 'TimelineEntry(at: $at, kind: $kind, outcome: $outcome, disposition: $disposition, comment: $comment, points: $points, redemption: $redemption)';
}


}

/// @nodoc
abstract mixin class $TimelineEntryCopyWith<$Res>  {
  factory $TimelineEntryCopyWith(TimelineEntry value, $Res Function(TimelineEntry) _then) = _$TimelineEntryCopyWithImpl;
@useResult
$Res call({
 DateTime at, String kind, OutcomeEntry? outcome, DispositionEntry? disposition, CommentEntry? comment, PointsEntry? points, RedemptionEntry? redemption
});


$OutcomeEntryCopyWith<$Res>? get outcome;$DispositionEntryCopyWith<$Res>? get disposition;$CommentEntryCopyWith<$Res>? get comment;$PointsEntryCopyWith<$Res>? get points;$RedemptionEntryCopyWith<$Res>? get redemption;

}
/// @nodoc
class _$TimelineEntryCopyWithImpl<$Res>
    implements $TimelineEntryCopyWith<$Res> {
  _$TimelineEntryCopyWithImpl(this._self, this._then);

  final TimelineEntry _self;
  final $Res Function(TimelineEntry) _then;

/// Create a copy of TimelineEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? at = null,Object? kind = null,Object? outcome = freezed,Object? disposition = freezed,Object? comment = freezed,Object? points = freezed,Object? redemption = freezed,}) {
  return _then(_self.copyWith(
at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,outcome: freezed == outcome ? _self.outcome : outcome // ignore: cast_nullable_to_non_nullable
as OutcomeEntry?,disposition: freezed == disposition ? _self.disposition : disposition // ignore: cast_nullable_to_non_nullable
as DispositionEntry?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as CommentEntry?,points: freezed == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as PointsEntry?,redemption: freezed == redemption ? _self.redemption : redemption // ignore: cast_nullable_to_non_nullable
as RedemptionEntry?,
  ));
}
/// Create a copy of TimelineEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OutcomeEntryCopyWith<$Res>? get outcome {
    if (_self.outcome == null) {
    return null;
  }

  return $OutcomeEntryCopyWith<$Res>(_self.outcome!, (value) {
    return _then(_self.copyWith(outcome: value));
  });
}/// Create a copy of TimelineEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DispositionEntryCopyWith<$Res>? get disposition {
    if (_self.disposition == null) {
    return null;
  }

  return $DispositionEntryCopyWith<$Res>(_self.disposition!, (value) {
    return _then(_self.copyWith(disposition: value));
  });
}/// Create a copy of TimelineEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommentEntryCopyWith<$Res>? get comment {
    if (_self.comment == null) {
    return null;
  }

  return $CommentEntryCopyWith<$Res>(_self.comment!, (value) {
    return _then(_self.copyWith(comment: value));
  });
}/// Create a copy of TimelineEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PointsEntryCopyWith<$Res>? get points {
    if (_self.points == null) {
    return null;
  }

  return $PointsEntryCopyWith<$Res>(_self.points!, (value) {
    return _then(_self.copyWith(points: value));
  });
}/// Create a copy of TimelineEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RedemptionEntryCopyWith<$Res>? get redemption {
    if (_self.redemption == null) {
    return null;
  }

  return $RedemptionEntryCopyWith<$Res>(_self.redemption!, (value) {
    return _then(_self.copyWith(redemption: value));
  });
}
}


/// Adds pattern-matching-related methods to [TimelineEntry].
extension TimelineEntryPatterns on TimelineEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TimelineEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TimelineEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TimelineEntry value)  $default,){
final _that = this;
switch (_that) {
case _TimelineEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TimelineEntry value)?  $default,){
final _that = this;
switch (_that) {
case _TimelineEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime at,  String kind,  OutcomeEntry? outcome,  DispositionEntry? disposition,  CommentEntry? comment,  PointsEntry? points,  RedemptionEntry? redemption)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TimelineEntry() when $default != null:
return $default(_that.at,_that.kind,_that.outcome,_that.disposition,_that.comment,_that.points,_that.redemption);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime at,  String kind,  OutcomeEntry? outcome,  DispositionEntry? disposition,  CommentEntry? comment,  PointsEntry? points,  RedemptionEntry? redemption)  $default,) {final _that = this;
switch (_that) {
case _TimelineEntry():
return $default(_that.at,_that.kind,_that.outcome,_that.disposition,_that.comment,_that.points,_that.redemption);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime at,  String kind,  OutcomeEntry? outcome,  DispositionEntry? disposition,  CommentEntry? comment,  PointsEntry? points,  RedemptionEntry? redemption)?  $default,) {final _that = this;
switch (_that) {
case _TimelineEntry() when $default != null:
return $default(_that.at,_that.kind,_that.outcome,_that.disposition,_that.comment,_that.points,_that.redemption);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TimelineEntry implements TimelineEntry {
  const _TimelineEntry({required this.at, required this.kind, this.outcome, this.disposition, this.comment, this.points, this.redemption});
  factory _TimelineEntry.fromJson(Map<String, dynamic> json) => _$TimelineEntryFromJson(json);

@override final  DateTime at;
/// `outcome | disposition | comment | points | redemption`.
@override final  String kind;
@override final  OutcomeEntry? outcome;
@override final  DispositionEntry? disposition;
@override final  CommentEntry? comment;
@override final  PointsEntry? points;
@override final  RedemptionEntry? redemption;

/// Create a copy of TimelineEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TimelineEntryCopyWith<_TimelineEntry> get copyWith => __$TimelineEntryCopyWithImpl<_TimelineEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TimelineEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TimelineEntry&&(identical(other.at, at) || other.at == at)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.outcome, outcome) || other.outcome == outcome)&&(identical(other.disposition, disposition) || other.disposition == disposition)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.points, points) || other.points == points)&&(identical(other.redemption, redemption) || other.redemption == redemption));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,at,kind,outcome,disposition,comment,points,redemption);

@override
String toString() {
  return 'TimelineEntry(at: $at, kind: $kind, outcome: $outcome, disposition: $disposition, comment: $comment, points: $points, redemption: $redemption)';
}


}

/// @nodoc
abstract mixin class _$TimelineEntryCopyWith<$Res> implements $TimelineEntryCopyWith<$Res> {
  factory _$TimelineEntryCopyWith(_TimelineEntry value, $Res Function(_TimelineEntry) _then) = __$TimelineEntryCopyWithImpl;
@override @useResult
$Res call({
 DateTime at, String kind, OutcomeEntry? outcome, DispositionEntry? disposition, CommentEntry? comment, PointsEntry? points, RedemptionEntry? redemption
});


@override $OutcomeEntryCopyWith<$Res>? get outcome;@override $DispositionEntryCopyWith<$Res>? get disposition;@override $CommentEntryCopyWith<$Res>? get comment;@override $PointsEntryCopyWith<$Res>? get points;@override $RedemptionEntryCopyWith<$Res>? get redemption;

}
/// @nodoc
class __$TimelineEntryCopyWithImpl<$Res>
    implements _$TimelineEntryCopyWith<$Res> {
  __$TimelineEntryCopyWithImpl(this._self, this._then);

  final _TimelineEntry _self;
  final $Res Function(_TimelineEntry) _then;

/// Create a copy of TimelineEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? at = null,Object? kind = null,Object? outcome = freezed,Object? disposition = freezed,Object? comment = freezed,Object? points = freezed,Object? redemption = freezed,}) {
  return _then(_TimelineEntry(
at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,outcome: freezed == outcome ? _self.outcome : outcome // ignore: cast_nullable_to_non_nullable
as OutcomeEntry?,disposition: freezed == disposition ? _self.disposition : disposition // ignore: cast_nullable_to_non_nullable
as DispositionEntry?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as CommentEntry?,points: freezed == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as PointsEntry?,redemption: freezed == redemption ? _self.redemption : redemption // ignore: cast_nullable_to_non_nullable
as RedemptionEntry?,
  ));
}

/// Create a copy of TimelineEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OutcomeEntryCopyWith<$Res>? get outcome {
    if (_self.outcome == null) {
    return null;
  }

  return $OutcomeEntryCopyWith<$Res>(_self.outcome!, (value) {
    return _then(_self.copyWith(outcome: value));
  });
}/// Create a copy of TimelineEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DispositionEntryCopyWith<$Res>? get disposition {
    if (_self.disposition == null) {
    return null;
  }

  return $DispositionEntryCopyWith<$Res>(_self.disposition!, (value) {
    return _then(_self.copyWith(disposition: value));
  });
}/// Create a copy of TimelineEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommentEntryCopyWith<$Res>? get comment {
    if (_self.comment == null) {
    return null;
  }

  return $CommentEntryCopyWith<$Res>(_self.comment!, (value) {
    return _then(_self.copyWith(comment: value));
  });
}/// Create a copy of TimelineEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PointsEntryCopyWith<$Res>? get points {
    if (_self.points == null) {
    return null;
  }

  return $PointsEntryCopyWith<$Res>(_self.points!, (value) {
    return _then(_self.copyWith(points: value));
  });
}/// Create a copy of TimelineEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RedemptionEntryCopyWith<$Res>? get redemption {
    if (_self.redemption == null) {
    return null;
  }

  return $RedemptionEntryCopyWith<$Res>(_self.redemption!, (value) {
    return _then(_self.copyWith(redemption: value));
  });
}
}


/// @nodoc
mixin _$DayView {

 String get day; List<TimelineEntry> get timeline; List<CommentEntry> get comments;/// The caller's own note, never the partner's.
 String? get myPrivateNote;
/// Create a copy of DayView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DayViewCopyWith<DayView> get copyWith => _$DayViewCopyWithImpl<DayView>(this as DayView, _$identity);

  /// Serializes this DayView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DayView&&(identical(other.day, day) || other.day == day)&&const DeepCollectionEquality().equals(other.timeline, timeline)&&const DeepCollectionEquality().equals(other.comments, comments)&&(identical(other.myPrivateNote, myPrivateNote) || other.myPrivateNote == myPrivateNote));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,day,const DeepCollectionEquality().hash(timeline),const DeepCollectionEquality().hash(comments),myPrivateNote);

@override
String toString() {
  return 'DayView(day: $day, timeline: $timeline, comments: $comments, myPrivateNote: $myPrivateNote)';
}


}

/// @nodoc
abstract mixin class $DayViewCopyWith<$Res>  {
  factory $DayViewCopyWith(DayView value, $Res Function(DayView) _then) = _$DayViewCopyWithImpl;
@useResult
$Res call({
 String day, List<TimelineEntry> timeline, List<CommentEntry> comments, String? myPrivateNote
});




}
/// @nodoc
class _$DayViewCopyWithImpl<$Res>
    implements $DayViewCopyWith<$Res> {
  _$DayViewCopyWithImpl(this._self, this._then);

  final DayView _self;
  final $Res Function(DayView) _then;

/// Create a copy of DayView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? day = null,Object? timeline = null,Object? comments = null,Object? myPrivateNote = freezed,}) {
  return _then(_self.copyWith(
day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as String,timeline: null == timeline ? _self.timeline : timeline // ignore: cast_nullable_to_non_nullable
as List<TimelineEntry>,comments: null == comments ? _self.comments : comments // ignore: cast_nullable_to_non_nullable
as List<CommentEntry>,myPrivateNote: freezed == myPrivateNote ? _self.myPrivateNote : myPrivateNote // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DayView].
extension DayViewPatterns on DayView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DayView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DayView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DayView value)  $default,){
final _that = this;
switch (_that) {
case _DayView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DayView value)?  $default,){
final _that = this;
switch (_that) {
case _DayView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String day,  List<TimelineEntry> timeline,  List<CommentEntry> comments,  String? myPrivateNote)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DayView() when $default != null:
return $default(_that.day,_that.timeline,_that.comments,_that.myPrivateNote);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String day,  List<TimelineEntry> timeline,  List<CommentEntry> comments,  String? myPrivateNote)  $default,) {final _that = this;
switch (_that) {
case _DayView():
return $default(_that.day,_that.timeline,_that.comments,_that.myPrivateNote);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String day,  List<TimelineEntry> timeline,  List<CommentEntry> comments,  String? myPrivateNote)?  $default,) {final _that = this;
switch (_that) {
case _DayView() when $default != null:
return $default(_that.day,_that.timeline,_that.comments,_that.myPrivateNote);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DayView extends DayView {
  const _DayView({required this.day, final  List<TimelineEntry> timeline = const <TimelineEntry>[], final  List<CommentEntry> comments = const <CommentEntry>[], this.myPrivateNote}): _timeline = timeline,_comments = comments,super._();
  factory _DayView.fromJson(Map<String, dynamic> json) => _$DayViewFromJson(json);

@override final  String day;
 final  List<TimelineEntry> _timeline;
@override@JsonKey() List<TimelineEntry> get timeline {
  if (_timeline is EqualUnmodifiableListView) return _timeline;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_timeline);
}

 final  List<CommentEntry> _comments;
@override@JsonKey() List<CommentEntry> get comments {
  if (_comments is EqualUnmodifiableListView) return _comments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_comments);
}

/// The caller's own note, never the partner's.
@override final  String? myPrivateNote;

/// Create a copy of DayView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DayViewCopyWith<_DayView> get copyWith => __$DayViewCopyWithImpl<_DayView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DayViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DayView&&(identical(other.day, day) || other.day == day)&&const DeepCollectionEquality().equals(other._timeline, _timeline)&&const DeepCollectionEquality().equals(other._comments, _comments)&&(identical(other.myPrivateNote, myPrivateNote) || other.myPrivateNote == myPrivateNote));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,day,const DeepCollectionEquality().hash(_timeline),const DeepCollectionEquality().hash(_comments),myPrivateNote);

@override
String toString() {
  return 'DayView(day: $day, timeline: $timeline, comments: $comments, myPrivateNote: $myPrivateNote)';
}


}

/// @nodoc
abstract mixin class _$DayViewCopyWith<$Res> implements $DayViewCopyWith<$Res> {
  factory _$DayViewCopyWith(_DayView value, $Res Function(_DayView) _then) = __$DayViewCopyWithImpl;
@override @useResult
$Res call({
 String day, List<TimelineEntry> timeline, List<CommentEntry> comments, String? myPrivateNote
});




}
/// @nodoc
class __$DayViewCopyWithImpl<$Res>
    implements _$DayViewCopyWith<$Res> {
  __$DayViewCopyWithImpl(this._self, this._then);

  final _DayView _self;
  final $Res Function(_DayView) _then;

/// Create a copy of DayView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? day = null,Object? timeline = null,Object? comments = null,Object? myPrivateNote = freezed,}) {
  return _then(_DayView(
day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as String,timeline: null == timeline ? _self._timeline : timeline // ignore: cast_nullable_to_non_nullable
as List<TimelineEntry>,comments: null == comments ? _self._comments : comments // ignore: cast_nullable_to_non_nullable
as List<CommentEntry>,myPrivateNote: freezed == myPrivateNote ? _self.myPrivateNote : myPrivateNote // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$FactsView {

 String get from; String get to; int get delivered; int get late; int get flagged; int get missed; int get letGo; int get praised; int get madeUp; int get punished; int get comments; int get pointsEarned; int get pointsDeducted; int get redemptions;
/// Create a copy of FactsView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FactsViewCopyWith<FactsView> get copyWith => _$FactsViewCopyWithImpl<FactsView>(this as FactsView, _$identity);

  /// Serializes this FactsView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FactsView&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to)&&(identical(other.delivered, delivered) || other.delivered == delivered)&&(identical(other.late, late) || other.late == late)&&(identical(other.flagged, flagged) || other.flagged == flagged)&&(identical(other.missed, missed) || other.missed == missed)&&(identical(other.letGo, letGo) || other.letGo == letGo)&&(identical(other.praised, praised) || other.praised == praised)&&(identical(other.madeUp, madeUp) || other.madeUp == madeUp)&&(identical(other.punished, punished) || other.punished == punished)&&(identical(other.comments, comments) || other.comments == comments)&&(identical(other.pointsEarned, pointsEarned) || other.pointsEarned == pointsEarned)&&(identical(other.pointsDeducted, pointsDeducted) || other.pointsDeducted == pointsDeducted)&&(identical(other.redemptions, redemptions) || other.redemptions == redemptions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,from,to,delivered,late,flagged,missed,letGo,praised,madeUp,punished,comments,pointsEarned,pointsDeducted,redemptions);

@override
String toString() {
  return 'FactsView(from: $from, to: $to, delivered: $delivered, late: $late, flagged: $flagged, missed: $missed, letGo: $letGo, praised: $praised, madeUp: $madeUp, punished: $punished, comments: $comments, pointsEarned: $pointsEarned, pointsDeducted: $pointsDeducted, redemptions: $redemptions)';
}


}

/// @nodoc
abstract mixin class $FactsViewCopyWith<$Res>  {
  factory $FactsViewCopyWith(FactsView value, $Res Function(FactsView) _then) = _$FactsViewCopyWithImpl;
@useResult
$Res call({
 String from, String to, int delivered, int late, int flagged, int missed, int letGo, int praised, int madeUp, int punished, int comments, int pointsEarned, int pointsDeducted, int redemptions
});




}
/// @nodoc
class _$FactsViewCopyWithImpl<$Res>
    implements $FactsViewCopyWith<$Res> {
  _$FactsViewCopyWithImpl(this._self, this._then);

  final FactsView _self;
  final $Res Function(FactsView) _then;

/// Create a copy of FactsView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? from = null,Object? to = null,Object? delivered = null,Object? late = null,Object? flagged = null,Object? missed = null,Object? letGo = null,Object? praised = null,Object? madeUp = null,Object? punished = null,Object? comments = null,Object? pointsEarned = null,Object? pointsDeducted = null,Object? redemptions = null,}) {
  return _then(_self.copyWith(
from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as String,to: null == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as String,delivered: null == delivered ? _self.delivered : delivered // ignore: cast_nullable_to_non_nullable
as int,late: null == late ? _self.late : late // ignore: cast_nullable_to_non_nullable
as int,flagged: null == flagged ? _self.flagged : flagged // ignore: cast_nullable_to_non_nullable
as int,missed: null == missed ? _self.missed : missed // ignore: cast_nullable_to_non_nullable
as int,letGo: null == letGo ? _self.letGo : letGo // ignore: cast_nullable_to_non_nullable
as int,praised: null == praised ? _self.praised : praised // ignore: cast_nullable_to_non_nullable
as int,madeUp: null == madeUp ? _self.madeUp : madeUp // ignore: cast_nullable_to_non_nullable
as int,punished: null == punished ? _self.punished : punished // ignore: cast_nullable_to_non_nullable
as int,comments: null == comments ? _self.comments : comments // ignore: cast_nullable_to_non_nullable
as int,pointsEarned: null == pointsEarned ? _self.pointsEarned : pointsEarned // ignore: cast_nullable_to_non_nullable
as int,pointsDeducted: null == pointsDeducted ? _self.pointsDeducted : pointsDeducted // ignore: cast_nullable_to_non_nullable
as int,redemptions: null == redemptions ? _self.redemptions : redemptions // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [FactsView].
extension FactsViewPatterns on FactsView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FactsView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FactsView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FactsView value)  $default,){
final _that = this;
switch (_that) {
case _FactsView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FactsView value)?  $default,){
final _that = this;
switch (_that) {
case _FactsView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String from,  String to,  int delivered,  int late,  int flagged,  int missed,  int letGo,  int praised,  int madeUp,  int punished,  int comments,  int pointsEarned,  int pointsDeducted,  int redemptions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FactsView() when $default != null:
return $default(_that.from,_that.to,_that.delivered,_that.late,_that.flagged,_that.missed,_that.letGo,_that.praised,_that.madeUp,_that.punished,_that.comments,_that.pointsEarned,_that.pointsDeducted,_that.redemptions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String from,  String to,  int delivered,  int late,  int flagged,  int missed,  int letGo,  int praised,  int madeUp,  int punished,  int comments,  int pointsEarned,  int pointsDeducted,  int redemptions)  $default,) {final _that = this;
switch (_that) {
case _FactsView():
return $default(_that.from,_that.to,_that.delivered,_that.late,_that.flagged,_that.missed,_that.letGo,_that.praised,_that.madeUp,_that.punished,_that.comments,_that.pointsEarned,_that.pointsDeducted,_that.redemptions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String from,  String to,  int delivered,  int late,  int flagged,  int missed,  int letGo,  int praised,  int madeUp,  int punished,  int comments,  int pointsEarned,  int pointsDeducted,  int redemptions)?  $default,) {final _that = this;
switch (_that) {
case _FactsView() when $default != null:
return $default(_that.from,_that.to,_that.delivered,_that.late,_that.flagged,_that.missed,_that.letGo,_that.praised,_that.madeUp,_that.punished,_that.comments,_that.pointsEarned,_that.pointsDeducted,_that.redemptions);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FactsView implements FactsView {
  const _FactsView({required this.from, required this.to, this.delivered = 0, this.late = 0, this.flagged = 0, this.missed = 0, this.letGo = 0, this.praised = 0, this.madeUp = 0, this.punished = 0, this.comments = 0, this.pointsEarned = 0, this.pointsDeducted = 0, this.redemptions = 0});
  factory _FactsView.fromJson(Map<String, dynamic> json) => _$FactsViewFromJson(json);

@override final  String from;
@override final  String to;
@override@JsonKey() final  int delivered;
@override@JsonKey() final  int late;
@override@JsonKey() final  int flagged;
@override@JsonKey() final  int missed;
@override@JsonKey() final  int letGo;
@override@JsonKey() final  int praised;
@override@JsonKey() final  int madeUp;
@override@JsonKey() final  int punished;
@override@JsonKey() final  int comments;
@override@JsonKey() final  int pointsEarned;
@override@JsonKey() final  int pointsDeducted;
@override@JsonKey() final  int redemptions;

/// Create a copy of FactsView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FactsViewCopyWith<_FactsView> get copyWith => __$FactsViewCopyWithImpl<_FactsView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FactsViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FactsView&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to)&&(identical(other.delivered, delivered) || other.delivered == delivered)&&(identical(other.late, late) || other.late == late)&&(identical(other.flagged, flagged) || other.flagged == flagged)&&(identical(other.missed, missed) || other.missed == missed)&&(identical(other.letGo, letGo) || other.letGo == letGo)&&(identical(other.praised, praised) || other.praised == praised)&&(identical(other.madeUp, madeUp) || other.madeUp == madeUp)&&(identical(other.punished, punished) || other.punished == punished)&&(identical(other.comments, comments) || other.comments == comments)&&(identical(other.pointsEarned, pointsEarned) || other.pointsEarned == pointsEarned)&&(identical(other.pointsDeducted, pointsDeducted) || other.pointsDeducted == pointsDeducted)&&(identical(other.redemptions, redemptions) || other.redemptions == redemptions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,from,to,delivered,late,flagged,missed,letGo,praised,madeUp,punished,comments,pointsEarned,pointsDeducted,redemptions);

@override
String toString() {
  return 'FactsView(from: $from, to: $to, delivered: $delivered, late: $late, flagged: $flagged, missed: $missed, letGo: $letGo, praised: $praised, madeUp: $madeUp, punished: $punished, comments: $comments, pointsEarned: $pointsEarned, pointsDeducted: $pointsDeducted, redemptions: $redemptions)';
}


}

/// @nodoc
abstract mixin class _$FactsViewCopyWith<$Res> implements $FactsViewCopyWith<$Res> {
  factory _$FactsViewCopyWith(_FactsView value, $Res Function(_FactsView) _then) = __$FactsViewCopyWithImpl;
@override @useResult
$Res call({
 String from, String to, int delivered, int late, int flagged, int missed, int letGo, int praised, int madeUp, int punished, int comments, int pointsEarned, int pointsDeducted, int redemptions
});




}
/// @nodoc
class __$FactsViewCopyWithImpl<$Res>
    implements _$FactsViewCopyWith<$Res> {
  __$FactsViewCopyWithImpl(this._self, this._then);

  final _FactsView _self;
  final $Res Function(_FactsView) _then;

/// Create a copy of FactsView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? from = null,Object? to = null,Object? delivered = null,Object? late = null,Object? flagged = null,Object? missed = null,Object? letGo = null,Object? praised = null,Object? madeUp = null,Object? punished = null,Object? comments = null,Object? pointsEarned = null,Object? pointsDeducted = null,Object? redemptions = null,}) {
  return _then(_FactsView(
from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as String,to: null == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as String,delivered: null == delivered ? _self.delivered : delivered // ignore: cast_nullable_to_non_nullable
as int,late: null == late ? _self.late : late // ignore: cast_nullable_to_non_nullable
as int,flagged: null == flagged ? _self.flagged : flagged // ignore: cast_nullable_to_non_nullable
as int,missed: null == missed ? _self.missed : missed // ignore: cast_nullable_to_non_nullable
as int,letGo: null == letGo ? _self.letGo : letGo // ignore: cast_nullable_to_non_nullable
as int,praised: null == praised ? _self.praised : praised // ignore: cast_nullable_to_non_nullable
as int,madeUp: null == madeUp ? _self.madeUp : madeUp // ignore: cast_nullable_to_non_nullable
as int,punished: null == punished ? _self.punished : punished // ignore: cast_nullable_to_non_nullable
as int,comments: null == comments ? _self.comments : comments // ignore: cast_nullable_to_non_nullable
as int,pointsEarned: null == pointsEarned ? _self.pointsEarned : pointsEarned // ignore: cast_nullable_to_non_nullable
as int,pointsDeducted: null == pointsDeducted ? _self.pointsDeducted : pointsDeducted // ignore: cast_nullable_to_non_nullable
as int,redemptions: null == redemptions ? _self.redemptions : redemptions // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$SummaryView {

 int get daysTogether; int get currentStreak;
/// Create a copy of SummaryView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SummaryViewCopyWith<SummaryView> get copyWith => _$SummaryViewCopyWithImpl<SummaryView>(this as SummaryView, _$identity);

  /// Serializes this SummaryView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SummaryView&&(identical(other.daysTogether, daysTogether) || other.daysTogether == daysTogether)&&(identical(other.currentStreak, currentStreak) || other.currentStreak == currentStreak));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,daysTogether,currentStreak);

@override
String toString() {
  return 'SummaryView(daysTogether: $daysTogether, currentStreak: $currentStreak)';
}


}

/// @nodoc
abstract mixin class $SummaryViewCopyWith<$Res>  {
  factory $SummaryViewCopyWith(SummaryView value, $Res Function(SummaryView) _then) = _$SummaryViewCopyWithImpl;
@useResult
$Res call({
 int daysTogether, int currentStreak
});




}
/// @nodoc
class _$SummaryViewCopyWithImpl<$Res>
    implements $SummaryViewCopyWith<$Res> {
  _$SummaryViewCopyWithImpl(this._self, this._then);

  final SummaryView _self;
  final $Res Function(SummaryView) _then;

/// Create a copy of SummaryView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? daysTogether = null,Object? currentStreak = null,}) {
  return _then(_self.copyWith(
daysTogether: null == daysTogether ? _self.daysTogether : daysTogether // ignore: cast_nullable_to_non_nullable
as int,currentStreak: null == currentStreak ? _self.currentStreak : currentStreak // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SummaryView].
extension SummaryViewPatterns on SummaryView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SummaryView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SummaryView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SummaryView value)  $default,){
final _that = this;
switch (_that) {
case _SummaryView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SummaryView value)?  $default,){
final _that = this;
switch (_that) {
case _SummaryView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int daysTogether,  int currentStreak)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SummaryView() when $default != null:
return $default(_that.daysTogether,_that.currentStreak);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int daysTogether,  int currentStreak)  $default,) {final _that = this;
switch (_that) {
case _SummaryView():
return $default(_that.daysTogether,_that.currentStreak);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int daysTogether,  int currentStreak)?  $default,) {final _that = this;
switch (_that) {
case _SummaryView() when $default != null:
return $default(_that.daysTogether,_that.currentStreak);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SummaryView implements SummaryView {
  const _SummaryView({this.daysTogether = 0, this.currentStreak = 0});
  factory _SummaryView.fromJson(Map<String, dynamic> json) => _$SummaryViewFromJson(json);

@override@JsonKey() final  int daysTogether;
@override@JsonKey() final  int currentStreak;

/// Create a copy of SummaryView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SummaryViewCopyWith<_SummaryView> get copyWith => __$SummaryViewCopyWithImpl<_SummaryView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SummaryViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SummaryView&&(identical(other.daysTogether, daysTogether) || other.daysTogether == daysTogether)&&(identical(other.currentStreak, currentStreak) || other.currentStreak == currentStreak));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,daysTogether,currentStreak);

@override
String toString() {
  return 'SummaryView(daysTogether: $daysTogether, currentStreak: $currentStreak)';
}


}

/// @nodoc
abstract mixin class _$SummaryViewCopyWith<$Res> implements $SummaryViewCopyWith<$Res> {
  factory _$SummaryViewCopyWith(_SummaryView value, $Res Function(_SummaryView) _then) = __$SummaryViewCopyWithImpl;
@override @useResult
$Res call({
 int daysTogether, int currentStreak
});




}
/// @nodoc
class __$SummaryViewCopyWithImpl<$Res>
    implements _$SummaryViewCopyWith<$Res> {
  __$SummaryViewCopyWithImpl(this._self, this._then);

  final _SummaryView _self;
  final $Res Function(_SummaryView) _then;

/// Create a copy of SummaryView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? daysTogether = null,Object? currentStreak = null,}) {
  return _then(_SummaryView(
daysTogether: null == daysTogether ? _self.daysTogether : daysTogether // ignore: cast_nullable_to_non_nullable
as int,currentStreak: null == currentStreak ? _self.currentStreak : currentStreak // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$DayComment {

 String get id; String get dynamicId; String get day; String get authorId; String get body; DateTime get createdAt;
/// Create a copy of DayComment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DayCommentCopyWith<DayComment> get copyWith => _$DayCommentCopyWithImpl<DayComment>(this as DayComment, _$identity);

  /// Serializes this DayComment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DayComment&&(identical(other.id, id) || other.id == id)&&(identical(other.dynamicId, dynamicId) || other.dynamicId == dynamicId)&&(identical(other.day, day) || other.day == day)&&(identical(other.authorId, authorId) || other.authorId == authorId)&&(identical(other.body, body) || other.body == body)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,dynamicId,day,authorId,body,createdAt);

@override
String toString() {
  return 'DayComment(id: $id, dynamicId: $dynamicId, day: $day, authorId: $authorId, body: $body, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $DayCommentCopyWith<$Res>  {
  factory $DayCommentCopyWith(DayComment value, $Res Function(DayComment) _then) = _$DayCommentCopyWithImpl;
@useResult
$Res call({
 String id, String dynamicId, String day, String authorId, String body, DateTime createdAt
});




}
/// @nodoc
class _$DayCommentCopyWithImpl<$Res>
    implements $DayCommentCopyWith<$Res> {
  _$DayCommentCopyWithImpl(this._self, this._then);

  final DayComment _self;
  final $Res Function(DayComment) _then;

/// Create a copy of DayComment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? dynamicId = null,Object? day = null,Object? authorId = null,Object? body = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,dynamicId: null == dynamicId ? _self.dynamicId : dynamicId // ignore: cast_nullable_to_non_nullable
as String,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as String,authorId: null == authorId ? _self.authorId : authorId // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [DayComment].
extension DayCommentPatterns on DayComment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DayComment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DayComment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DayComment value)  $default,){
final _that = this;
switch (_that) {
case _DayComment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DayComment value)?  $default,){
final _that = this;
switch (_that) {
case _DayComment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String dynamicId,  String day,  String authorId,  String body,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DayComment() when $default != null:
return $default(_that.id,_that.dynamicId,_that.day,_that.authorId,_that.body,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String dynamicId,  String day,  String authorId,  String body,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _DayComment():
return $default(_that.id,_that.dynamicId,_that.day,_that.authorId,_that.body,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String dynamicId,  String day,  String authorId,  String body,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _DayComment() when $default != null:
return $default(_that.id,_that.dynamicId,_that.day,_that.authorId,_that.body,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DayComment implements DayComment {
  const _DayComment({required this.id, required this.dynamicId, required this.day, required this.authorId, required this.body, required this.createdAt});
  factory _DayComment.fromJson(Map<String, dynamic> json) => _$DayCommentFromJson(json);

@override final  String id;
@override final  String dynamicId;
@override final  String day;
@override final  String authorId;
@override final  String body;
@override final  DateTime createdAt;

/// Create a copy of DayComment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DayCommentCopyWith<_DayComment> get copyWith => __$DayCommentCopyWithImpl<_DayComment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DayCommentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DayComment&&(identical(other.id, id) || other.id == id)&&(identical(other.dynamicId, dynamicId) || other.dynamicId == dynamicId)&&(identical(other.day, day) || other.day == day)&&(identical(other.authorId, authorId) || other.authorId == authorId)&&(identical(other.body, body) || other.body == body)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,dynamicId,day,authorId,body,createdAt);

@override
String toString() {
  return 'DayComment(id: $id, dynamicId: $dynamicId, day: $day, authorId: $authorId, body: $body, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$DayCommentCopyWith<$Res> implements $DayCommentCopyWith<$Res> {
  factory _$DayCommentCopyWith(_DayComment value, $Res Function(_DayComment) _then) = __$DayCommentCopyWithImpl;
@override @useResult
$Res call({
 String id, String dynamicId, String day, String authorId, String body, DateTime createdAt
});




}
/// @nodoc
class __$DayCommentCopyWithImpl<$Res>
    implements _$DayCommentCopyWith<$Res> {
  __$DayCommentCopyWithImpl(this._self, this._then);

  final _DayComment _self;
  final $Res Function(_DayComment) _then;

/// Create a copy of DayComment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? dynamicId = null,Object? day = null,Object? authorId = null,Object? body = null,Object? createdAt = null,}) {
  return _then(_DayComment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,dynamicId: null == dynamicId ? _self.dynamicId : dynamicId // ignore: cast_nullable_to_non_nullable
as String,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as String,authorId: null == authorId ? _self.authorId : authorId // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$SeriesPoint {

/// `yyyy-MM-dd`.
 String get day;@JsonKey(fromJson: decimalFromJson) double? get value;
/// Create a copy of SeriesPoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SeriesPointCopyWith<SeriesPoint> get copyWith => _$SeriesPointCopyWithImpl<SeriesPoint>(this as SeriesPoint, _$identity);

  /// Serializes this SeriesPoint to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SeriesPoint&&(identical(other.day, day) || other.day == day)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,day,value);

@override
String toString() {
  return 'SeriesPoint(day: $day, value: $value)';
}


}

/// @nodoc
abstract mixin class $SeriesPointCopyWith<$Res>  {
  factory $SeriesPointCopyWith(SeriesPoint value, $Res Function(SeriesPoint) _then) = _$SeriesPointCopyWithImpl;
@useResult
$Res call({
 String day,@JsonKey(fromJson: decimalFromJson) double? value
});




}
/// @nodoc
class _$SeriesPointCopyWithImpl<$Res>
    implements $SeriesPointCopyWith<$Res> {
  _$SeriesPointCopyWithImpl(this._self, this._then);

  final SeriesPoint _self;
  final $Res Function(SeriesPoint) _then;

/// Create a copy of SeriesPoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? day = null,Object? value = freezed,}) {
  return _then(_self.copyWith(
day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as String,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [SeriesPoint].
extension SeriesPointPatterns on SeriesPoint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SeriesPoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SeriesPoint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SeriesPoint value)  $default,){
final _that = this;
switch (_that) {
case _SeriesPoint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SeriesPoint value)?  $default,){
final _that = this;
switch (_that) {
case _SeriesPoint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String day, @JsonKey(fromJson: decimalFromJson)  double? value)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SeriesPoint() when $default != null:
return $default(_that.day,_that.value);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String day, @JsonKey(fromJson: decimalFromJson)  double? value)  $default,) {final _that = this;
switch (_that) {
case _SeriesPoint():
return $default(_that.day,_that.value);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String day, @JsonKey(fromJson: decimalFromJson)  double? value)?  $default,) {final _that = this;
switch (_that) {
case _SeriesPoint() when $default != null:
return $default(_that.day,_that.value);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SeriesPoint implements SeriesPoint {
  const _SeriesPoint({required this.day, @JsonKey(fromJson: decimalFromJson) this.value});
  factory _SeriesPoint.fromJson(Map<String, dynamic> json) => _$SeriesPointFromJson(json);

/// `yyyy-MM-dd`.
@override final  String day;
@override@JsonKey(fromJson: decimalFromJson) final  double? value;

/// Create a copy of SeriesPoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SeriesPointCopyWith<_SeriesPoint> get copyWith => __$SeriesPointCopyWithImpl<_SeriesPoint>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SeriesPointToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SeriesPoint&&(identical(other.day, day) || other.day == day)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,day,value);

@override
String toString() {
  return 'SeriesPoint(day: $day, value: $value)';
}


}

/// @nodoc
abstract mixin class _$SeriesPointCopyWith<$Res> implements $SeriesPointCopyWith<$Res> {
  factory _$SeriesPointCopyWith(_SeriesPoint value, $Res Function(_SeriesPoint) _then) = __$SeriesPointCopyWithImpl;
@override @useResult
$Res call({
 String day,@JsonKey(fromJson: decimalFromJson) double? value
});




}
/// @nodoc
class __$SeriesPointCopyWithImpl<$Res>
    implements _$SeriesPointCopyWith<$Res> {
  __$SeriesPointCopyWithImpl(this._self, this._then);

  final _SeriesPoint _self;
  final $Res Function(_SeriesPoint) _then;

/// Create a copy of SeriesPoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? day = null,Object? value = freezed,}) {
  return _then(_SeriesPoint(
day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as String,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$SeriesView {

 String get taskId; String? get unit; List<SeriesPoint> get points;
/// Create a copy of SeriesView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SeriesViewCopyWith<SeriesView> get copyWith => _$SeriesViewCopyWithImpl<SeriesView>(this as SeriesView, _$identity);

  /// Serializes this SeriesView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SeriesView&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.unit, unit) || other.unit == unit)&&const DeepCollectionEquality().equals(other.points, points));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,taskId,unit,const DeepCollectionEquality().hash(points));

@override
String toString() {
  return 'SeriesView(taskId: $taskId, unit: $unit, points: $points)';
}


}

/// @nodoc
abstract mixin class $SeriesViewCopyWith<$Res>  {
  factory $SeriesViewCopyWith(SeriesView value, $Res Function(SeriesView) _then) = _$SeriesViewCopyWithImpl;
@useResult
$Res call({
 String taskId, String? unit, List<SeriesPoint> points
});




}
/// @nodoc
class _$SeriesViewCopyWithImpl<$Res>
    implements $SeriesViewCopyWith<$Res> {
  _$SeriesViewCopyWithImpl(this._self, this._then);

  final SeriesView _self;
  final $Res Function(SeriesView) _then;

/// Create a copy of SeriesView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? taskId = null,Object? unit = freezed,Object? points = null,}) {
  return _then(_self.copyWith(
taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as List<SeriesPoint>,
  ));
}

}


/// Adds pattern-matching-related methods to [SeriesView].
extension SeriesViewPatterns on SeriesView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SeriesView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SeriesView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SeriesView value)  $default,){
final _that = this;
switch (_that) {
case _SeriesView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SeriesView value)?  $default,){
final _that = this;
switch (_that) {
case _SeriesView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String taskId,  String? unit,  List<SeriesPoint> points)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SeriesView() when $default != null:
return $default(_that.taskId,_that.unit,_that.points);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String taskId,  String? unit,  List<SeriesPoint> points)  $default,) {final _that = this;
switch (_that) {
case _SeriesView():
return $default(_that.taskId,_that.unit,_that.points);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String taskId,  String? unit,  List<SeriesPoint> points)?  $default,) {final _that = this;
switch (_that) {
case _SeriesView() when $default != null:
return $default(_that.taskId,_that.unit,_that.points);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SeriesView implements SeriesView {
  const _SeriesView({required this.taskId, this.unit, final  List<SeriesPoint> points = const []}): _points = points;
  factory _SeriesView.fromJson(Map<String, dynamic> json) => _$SeriesViewFromJson(json);

@override final  String taskId;
@override final  String? unit;
 final  List<SeriesPoint> _points;
@override@JsonKey() List<SeriesPoint> get points {
  if (_points is EqualUnmodifiableListView) return _points;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_points);
}


/// Create a copy of SeriesView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SeriesViewCopyWith<_SeriesView> get copyWith => __$SeriesViewCopyWithImpl<_SeriesView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SeriesViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SeriesView&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.unit, unit) || other.unit == unit)&&const DeepCollectionEquality().equals(other._points, _points));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,taskId,unit,const DeepCollectionEquality().hash(_points));

@override
String toString() {
  return 'SeriesView(taskId: $taskId, unit: $unit, points: $points)';
}


}

/// @nodoc
abstract mixin class _$SeriesViewCopyWith<$Res> implements $SeriesViewCopyWith<$Res> {
  factory _$SeriesViewCopyWith(_SeriesView value, $Res Function(_SeriesView) _then) = __$SeriesViewCopyWithImpl;
@override @useResult
$Res call({
 String taskId, String? unit, List<SeriesPoint> points
});




}
/// @nodoc
class __$SeriesViewCopyWithImpl<$Res>
    implements _$SeriesViewCopyWith<$Res> {
  __$SeriesViewCopyWithImpl(this._self, this._then);

  final _SeriesView _self;
  final $Res Function(_SeriesView) _then;

/// Create a copy of SeriesView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? taskId = null,Object? unit = freezed,Object? points = null,}) {
  return _then(_SeriesView(
taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,points: null == points ? _self._points : points // ignore: cast_nullable_to_non_nullable
as List<SeriesPoint>,
  ));
}


}

// dart format on
