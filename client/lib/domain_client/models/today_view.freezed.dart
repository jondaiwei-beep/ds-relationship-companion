// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'today_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ConsequenceView {

 String get id; String get title; String? get detail; String get status; DateTime get issuedAt;
/// Create a copy of ConsequenceView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConsequenceViewCopyWith<ConsequenceView> get copyWith => _$ConsequenceViewCopyWithImpl<ConsequenceView>(this as ConsequenceView, _$identity);

  /// Serializes this ConsequenceView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConsequenceView&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.detail, detail) || other.detail == detail)&&(identical(other.status, status) || other.status == status)&&(identical(other.issuedAt, issuedAt) || other.issuedAt == issuedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,detail,status,issuedAt);

@override
String toString() {
  return 'ConsequenceView(id: $id, title: $title, detail: $detail, status: $status, issuedAt: $issuedAt)';
}


}

/// @nodoc
abstract mixin class $ConsequenceViewCopyWith<$Res>  {
  factory $ConsequenceViewCopyWith(ConsequenceView value, $Res Function(ConsequenceView) _then) = _$ConsequenceViewCopyWithImpl;
@useResult
$Res call({
 String id, String title, String? detail, String status, DateTime issuedAt
});




}
/// @nodoc
class _$ConsequenceViewCopyWithImpl<$Res>
    implements $ConsequenceViewCopyWith<$Res> {
  _$ConsequenceViewCopyWithImpl(this._self, this._then);

  final ConsequenceView _self;
  final $Res Function(ConsequenceView) _then;

/// Create a copy of ConsequenceView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? detail = freezed,Object? status = null,Object? issuedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,detail: freezed == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,issuedAt: null == issuedAt ? _self.issuedAt : issuedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ConsequenceView].
extension ConsequenceViewPatterns on ConsequenceView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConsequenceView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConsequenceView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConsequenceView value)  $default,){
final _that = this;
switch (_that) {
case _ConsequenceView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConsequenceView value)?  $default,){
final _that = this;
switch (_that) {
case _ConsequenceView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String? detail,  String status,  DateTime issuedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConsequenceView() when $default != null:
return $default(_that.id,_that.title,_that.detail,_that.status,_that.issuedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String? detail,  String status,  DateTime issuedAt)  $default,) {final _that = this;
switch (_that) {
case _ConsequenceView():
return $default(_that.id,_that.title,_that.detail,_that.status,_that.issuedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String? detail,  String status,  DateTime issuedAt)?  $default,) {final _that = this;
switch (_that) {
case _ConsequenceView() when $default != null:
return $default(_that.id,_that.title,_that.detail,_that.status,_that.issuedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ConsequenceView implements ConsequenceView {
  const _ConsequenceView({required this.id, required this.title, this.detail, required this.status, required this.issuedAt});
  factory _ConsequenceView.fromJson(Map<String, dynamic> json) => _$ConsequenceViewFromJson(json);

@override final  String id;
@override final  String title;
@override final  String? detail;
@override final  String status;
@override final  DateTime issuedAt;

/// Create a copy of ConsequenceView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConsequenceViewCopyWith<_ConsequenceView> get copyWith => __$ConsequenceViewCopyWithImpl<_ConsequenceView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConsequenceViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConsequenceView&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.detail, detail) || other.detail == detail)&&(identical(other.status, status) || other.status == status)&&(identical(other.issuedAt, issuedAt) || other.issuedAt == issuedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,detail,status,issuedAt);

@override
String toString() {
  return 'ConsequenceView(id: $id, title: $title, detail: $detail, status: $status, issuedAt: $issuedAt)';
}


}

/// @nodoc
abstract mixin class _$ConsequenceViewCopyWith<$Res> implements $ConsequenceViewCopyWith<$Res> {
  factory _$ConsequenceViewCopyWith(_ConsequenceView value, $Res Function(_ConsequenceView) _then) = __$ConsequenceViewCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String? detail, String status, DateTime issuedAt
});




}
/// @nodoc
class __$ConsequenceViewCopyWithImpl<$Res>
    implements _$ConsequenceViewCopyWith<$Res> {
  __$ConsequenceViewCopyWithImpl(this._self, this._then);

  final _ConsequenceView _self;
  final $Res Function(_ConsequenceView) _then;

/// Create a copy of ConsequenceView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? detail = freezed,Object? status = null,Object? issuedAt = null,}) {
  return _then(_ConsequenceView(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,detail: freezed == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,issuedAt: null == issuedAt ? _self.issuedAt : issuedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$OccurrenceView {

 String get id; String get taskId; String get title; String? get detail;/// `recurring | one_off | open | checkin | measure`.
 String get kind;/// `check | photo | text | any`.
 String get proof; int get pointsEarn; bool get requiresDPresent;/// The relationship day, `yyyy-MM-dd`, in the Dynamic's zone.
 String get day; int get slot; DateTime? get dueAt; Outcome get outcome; DateTime? get outcomeAt; String? get outcomeNote; String? get proofKind; String? get proofRef; DateTime? get proposedTime; Disposition get disposition; DateTime? get dispositionAt; String? get dispositionNote; ConsequenceView? get consequence; String? get makeUpDay; String? get makeUpOf; DateTime? get seenAt; int get version;
/// Create a copy of OccurrenceView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OccurrenceViewCopyWith<OccurrenceView> get copyWith => _$OccurrenceViewCopyWithImpl<OccurrenceView>(this as OccurrenceView, _$identity);

  /// Serializes this OccurrenceView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OccurrenceView&&(identical(other.id, id) || other.id == id)&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.title, title) || other.title == title)&&(identical(other.detail, detail) || other.detail == detail)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.proof, proof) || other.proof == proof)&&(identical(other.pointsEarn, pointsEarn) || other.pointsEarn == pointsEarn)&&(identical(other.requiresDPresent, requiresDPresent) || other.requiresDPresent == requiresDPresent)&&(identical(other.day, day) || other.day == day)&&(identical(other.slot, slot) || other.slot == slot)&&(identical(other.dueAt, dueAt) || other.dueAt == dueAt)&&(identical(other.outcome, outcome) || other.outcome == outcome)&&(identical(other.outcomeAt, outcomeAt) || other.outcomeAt == outcomeAt)&&(identical(other.outcomeNote, outcomeNote) || other.outcomeNote == outcomeNote)&&(identical(other.proofKind, proofKind) || other.proofKind == proofKind)&&(identical(other.proofRef, proofRef) || other.proofRef == proofRef)&&(identical(other.proposedTime, proposedTime) || other.proposedTime == proposedTime)&&(identical(other.disposition, disposition) || other.disposition == disposition)&&(identical(other.dispositionAt, dispositionAt) || other.dispositionAt == dispositionAt)&&(identical(other.dispositionNote, dispositionNote) || other.dispositionNote == dispositionNote)&&(identical(other.consequence, consequence) || other.consequence == consequence)&&(identical(other.makeUpDay, makeUpDay) || other.makeUpDay == makeUpDay)&&(identical(other.makeUpOf, makeUpOf) || other.makeUpOf == makeUpOf)&&(identical(other.seenAt, seenAt) || other.seenAt == seenAt)&&(identical(other.version, version) || other.version == version));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,taskId,title,detail,kind,proof,pointsEarn,requiresDPresent,day,slot,dueAt,outcome,outcomeAt,outcomeNote,proofKind,proofRef,proposedTime,disposition,dispositionAt,dispositionNote,consequence,makeUpDay,makeUpOf,seenAt,version]);

@override
String toString() {
  return 'OccurrenceView(id: $id, taskId: $taskId, title: $title, detail: $detail, kind: $kind, proof: $proof, pointsEarn: $pointsEarn, requiresDPresent: $requiresDPresent, day: $day, slot: $slot, dueAt: $dueAt, outcome: $outcome, outcomeAt: $outcomeAt, outcomeNote: $outcomeNote, proofKind: $proofKind, proofRef: $proofRef, proposedTime: $proposedTime, disposition: $disposition, dispositionAt: $dispositionAt, dispositionNote: $dispositionNote, consequence: $consequence, makeUpDay: $makeUpDay, makeUpOf: $makeUpOf, seenAt: $seenAt, version: $version)';
}


}

/// @nodoc
abstract mixin class $OccurrenceViewCopyWith<$Res>  {
  factory $OccurrenceViewCopyWith(OccurrenceView value, $Res Function(OccurrenceView) _then) = _$OccurrenceViewCopyWithImpl;
@useResult
$Res call({
 String id, String taskId, String title, String? detail, String kind, String proof, int pointsEarn, bool requiresDPresent, String day, int slot, DateTime? dueAt, Outcome outcome, DateTime? outcomeAt, String? outcomeNote, String? proofKind, String? proofRef, DateTime? proposedTime, Disposition disposition, DateTime? dispositionAt, String? dispositionNote, ConsequenceView? consequence, String? makeUpDay, String? makeUpOf, DateTime? seenAt, int version
});


$ConsequenceViewCopyWith<$Res>? get consequence;

}
/// @nodoc
class _$OccurrenceViewCopyWithImpl<$Res>
    implements $OccurrenceViewCopyWith<$Res> {
  _$OccurrenceViewCopyWithImpl(this._self, this._then);

  final OccurrenceView _self;
  final $Res Function(OccurrenceView) _then;

/// Create a copy of OccurrenceView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? taskId = null,Object? title = null,Object? detail = freezed,Object? kind = null,Object? proof = null,Object? pointsEarn = null,Object? requiresDPresent = null,Object? day = null,Object? slot = null,Object? dueAt = freezed,Object? outcome = null,Object? outcomeAt = freezed,Object? outcomeNote = freezed,Object? proofKind = freezed,Object? proofRef = freezed,Object? proposedTime = freezed,Object? disposition = null,Object? dispositionAt = freezed,Object? dispositionNote = freezed,Object? consequence = freezed,Object? makeUpDay = freezed,Object? makeUpOf = freezed,Object? seenAt = freezed,Object? version = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,detail: freezed == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String?,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,proof: null == proof ? _self.proof : proof // ignore: cast_nullable_to_non_nullable
as String,pointsEarn: null == pointsEarn ? _self.pointsEarn : pointsEarn // ignore: cast_nullable_to_non_nullable
as int,requiresDPresent: null == requiresDPresent ? _self.requiresDPresent : requiresDPresent // ignore: cast_nullable_to_non_nullable
as bool,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as String,slot: null == slot ? _self.slot : slot // ignore: cast_nullable_to_non_nullable
as int,dueAt: freezed == dueAt ? _self.dueAt : dueAt // ignore: cast_nullable_to_non_nullable
as DateTime?,outcome: null == outcome ? _self.outcome : outcome // ignore: cast_nullable_to_non_nullable
as Outcome,outcomeAt: freezed == outcomeAt ? _self.outcomeAt : outcomeAt // ignore: cast_nullable_to_non_nullable
as DateTime?,outcomeNote: freezed == outcomeNote ? _self.outcomeNote : outcomeNote // ignore: cast_nullable_to_non_nullable
as String?,proofKind: freezed == proofKind ? _self.proofKind : proofKind // ignore: cast_nullable_to_non_nullable
as String?,proofRef: freezed == proofRef ? _self.proofRef : proofRef // ignore: cast_nullable_to_non_nullable
as String?,proposedTime: freezed == proposedTime ? _self.proposedTime : proposedTime // ignore: cast_nullable_to_non_nullable
as DateTime?,disposition: null == disposition ? _self.disposition : disposition // ignore: cast_nullable_to_non_nullable
as Disposition,dispositionAt: freezed == dispositionAt ? _self.dispositionAt : dispositionAt // ignore: cast_nullable_to_non_nullable
as DateTime?,dispositionNote: freezed == dispositionNote ? _self.dispositionNote : dispositionNote // ignore: cast_nullable_to_non_nullable
as String?,consequence: freezed == consequence ? _self.consequence : consequence // ignore: cast_nullable_to_non_nullable
as ConsequenceView?,makeUpDay: freezed == makeUpDay ? _self.makeUpDay : makeUpDay // ignore: cast_nullable_to_non_nullable
as String?,makeUpOf: freezed == makeUpOf ? _self.makeUpOf : makeUpOf // ignore: cast_nullable_to_non_nullable
as String?,seenAt: freezed == seenAt ? _self.seenAt : seenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of OccurrenceView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConsequenceViewCopyWith<$Res>? get consequence {
    if (_self.consequence == null) {
    return null;
  }

  return $ConsequenceViewCopyWith<$Res>(_self.consequence!, (value) {
    return _then(_self.copyWith(consequence: value));
  });
}
}


/// Adds pattern-matching-related methods to [OccurrenceView].
extension OccurrenceViewPatterns on OccurrenceView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OccurrenceView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OccurrenceView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OccurrenceView value)  $default,){
final _that = this;
switch (_that) {
case _OccurrenceView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OccurrenceView value)?  $default,){
final _that = this;
switch (_that) {
case _OccurrenceView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String taskId,  String title,  String? detail,  String kind,  String proof,  int pointsEarn,  bool requiresDPresent,  String day,  int slot,  DateTime? dueAt,  Outcome outcome,  DateTime? outcomeAt,  String? outcomeNote,  String? proofKind,  String? proofRef,  DateTime? proposedTime,  Disposition disposition,  DateTime? dispositionAt,  String? dispositionNote,  ConsequenceView? consequence,  String? makeUpDay,  String? makeUpOf,  DateTime? seenAt,  int version)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OccurrenceView() when $default != null:
return $default(_that.id,_that.taskId,_that.title,_that.detail,_that.kind,_that.proof,_that.pointsEarn,_that.requiresDPresent,_that.day,_that.slot,_that.dueAt,_that.outcome,_that.outcomeAt,_that.outcomeNote,_that.proofKind,_that.proofRef,_that.proposedTime,_that.disposition,_that.dispositionAt,_that.dispositionNote,_that.consequence,_that.makeUpDay,_that.makeUpOf,_that.seenAt,_that.version);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String taskId,  String title,  String? detail,  String kind,  String proof,  int pointsEarn,  bool requiresDPresent,  String day,  int slot,  DateTime? dueAt,  Outcome outcome,  DateTime? outcomeAt,  String? outcomeNote,  String? proofKind,  String? proofRef,  DateTime? proposedTime,  Disposition disposition,  DateTime? dispositionAt,  String? dispositionNote,  ConsequenceView? consequence,  String? makeUpDay,  String? makeUpOf,  DateTime? seenAt,  int version)  $default,) {final _that = this;
switch (_that) {
case _OccurrenceView():
return $default(_that.id,_that.taskId,_that.title,_that.detail,_that.kind,_that.proof,_that.pointsEarn,_that.requiresDPresent,_that.day,_that.slot,_that.dueAt,_that.outcome,_that.outcomeAt,_that.outcomeNote,_that.proofKind,_that.proofRef,_that.proposedTime,_that.disposition,_that.dispositionAt,_that.dispositionNote,_that.consequence,_that.makeUpDay,_that.makeUpOf,_that.seenAt,_that.version);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String taskId,  String title,  String? detail,  String kind,  String proof,  int pointsEarn,  bool requiresDPresent,  String day,  int slot,  DateTime? dueAt,  Outcome outcome,  DateTime? outcomeAt,  String? outcomeNote,  String? proofKind,  String? proofRef,  DateTime? proposedTime,  Disposition disposition,  DateTime? dispositionAt,  String? dispositionNote,  ConsequenceView? consequence,  String? makeUpDay,  String? makeUpOf,  DateTime? seenAt,  int version)?  $default,) {final _that = this;
switch (_that) {
case _OccurrenceView() when $default != null:
return $default(_that.id,_that.taskId,_that.title,_that.detail,_that.kind,_that.proof,_that.pointsEarn,_that.requiresDPresent,_that.day,_that.slot,_that.dueAt,_that.outcome,_that.outcomeAt,_that.outcomeNote,_that.proofKind,_that.proofRef,_that.proposedTime,_that.disposition,_that.dispositionAt,_that.dispositionNote,_that.consequence,_that.makeUpDay,_that.makeUpOf,_that.seenAt,_that.version);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OccurrenceView extends OccurrenceView {
  const _OccurrenceView({required this.id, required this.taskId, required this.title, this.detail, required this.kind, required this.proof, this.pointsEarn = 0, this.requiresDPresent = false, required this.day, this.slot = 0, this.dueAt, this.outcome = Outcome.open, this.outcomeAt, this.outcomeNote, this.proofKind, this.proofRef, this.proposedTime, this.disposition = Disposition.none, this.dispositionAt, this.dispositionNote, this.consequence, this.makeUpDay, this.makeUpOf, this.seenAt, this.version = 0}): super._();
  factory _OccurrenceView.fromJson(Map<String, dynamic> json) => _$OccurrenceViewFromJson(json);

@override final  String id;
@override final  String taskId;
@override final  String title;
@override final  String? detail;
/// `recurring | one_off | open | checkin | measure`.
@override final  String kind;
/// `check | photo | text | any`.
@override final  String proof;
@override@JsonKey() final  int pointsEarn;
@override@JsonKey() final  bool requiresDPresent;
/// The relationship day, `yyyy-MM-dd`, in the Dynamic's zone.
@override final  String day;
@override@JsonKey() final  int slot;
@override final  DateTime? dueAt;
@override@JsonKey() final  Outcome outcome;
@override final  DateTime? outcomeAt;
@override final  String? outcomeNote;
@override final  String? proofKind;
@override final  String? proofRef;
@override final  DateTime? proposedTime;
@override@JsonKey() final  Disposition disposition;
@override final  DateTime? dispositionAt;
@override final  String? dispositionNote;
@override final  ConsequenceView? consequence;
@override final  String? makeUpDay;
@override final  String? makeUpOf;
@override final  DateTime? seenAt;
@override@JsonKey() final  int version;

/// Create a copy of OccurrenceView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OccurrenceViewCopyWith<_OccurrenceView> get copyWith => __$OccurrenceViewCopyWithImpl<_OccurrenceView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OccurrenceViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OccurrenceView&&(identical(other.id, id) || other.id == id)&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.title, title) || other.title == title)&&(identical(other.detail, detail) || other.detail == detail)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.proof, proof) || other.proof == proof)&&(identical(other.pointsEarn, pointsEarn) || other.pointsEarn == pointsEarn)&&(identical(other.requiresDPresent, requiresDPresent) || other.requiresDPresent == requiresDPresent)&&(identical(other.day, day) || other.day == day)&&(identical(other.slot, slot) || other.slot == slot)&&(identical(other.dueAt, dueAt) || other.dueAt == dueAt)&&(identical(other.outcome, outcome) || other.outcome == outcome)&&(identical(other.outcomeAt, outcomeAt) || other.outcomeAt == outcomeAt)&&(identical(other.outcomeNote, outcomeNote) || other.outcomeNote == outcomeNote)&&(identical(other.proofKind, proofKind) || other.proofKind == proofKind)&&(identical(other.proofRef, proofRef) || other.proofRef == proofRef)&&(identical(other.proposedTime, proposedTime) || other.proposedTime == proposedTime)&&(identical(other.disposition, disposition) || other.disposition == disposition)&&(identical(other.dispositionAt, dispositionAt) || other.dispositionAt == dispositionAt)&&(identical(other.dispositionNote, dispositionNote) || other.dispositionNote == dispositionNote)&&(identical(other.consequence, consequence) || other.consequence == consequence)&&(identical(other.makeUpDay, makeUpDay) || other.makeUpDay == makeUpDay)&&(identical(other.makeUpOf, makeUpOf) || other.makeUpOf == makeUpOf)&&(identical(other.seenAt, seenAt) || other.seenAt == seenAt)&&(identical(other.version, version) || other.version == version));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,taskId,title,detail,kind,proof,pointsEarn,requiresDPresent,day,slot,dueAt,outcome,outcomeAt,outcomeNote,proofKind,proofRef,proposedTime,disposition,dispositionAt,dispositionNote,consequence,makeUpDay,makeUpOf,seenAt,version]);

@override
String toString() {
  return 'OccurrenceView(id: $id, taskId: $taskId, title: $title, detail: $detail, kind: $kind, proof: $proof, pointsEarn: $pointsEarn, requiresDPresent: $requiresDPresent, day: $day, slot: $slot, dueAt: $dueAt, outcome: $outcome, outcomeAt: $outcomeAt, outcomeNote: $outcomeNote, proofKind: $proofKind, proofRef: $proofRef, proposedTime: $proposedTime, disposition: $disposition, dispositionAt: $dispositionAt, dispositionNote: $dispositionNote, consequence: $consequence, makeUpDay: $makeUpDay, makeUpOf: $makeUpOf, seenAt: $seenAt, version: $version)';
}


}

/// @nodoc
abstract mixin class _$OccurrenceViewCopyWith<$Res> implements $OccurrenceViewCopyWith<$Res> {
  factory _$OccurrenceViewCopyWith(_OccurrenceView value, $Res Function(_OccurrenceView) _then) = __$OccurrenceViewCopyWithImpl;
@override @useResult
$Res call({
 String id, String taskId, String title, String? detail, String kind, String proof, int pointsEarn, bool requiresDPresent, String day, int slot, DateTime? dueAt, Outcome outcome, DateTime? outcomeAt, String? outcomeNote, String? proofKind, String? proofRef, DateTime? proposedTime, Disposition disposition, DateTime? dispositionAt, String? dispositionNote, ConsequenceView? consequence, String? makeUpDay, String? makeUpOf, DateTime? seenAt, int version
});


@override $ConsequenceViewCopyWith<$Res>? get consequence;

}
/// @nodoc
class __$OccurrenceViewCopyWithImpl<$Res>
    implements _$OccurrenceViewCopyWith<$Res> {
  __$OccurrenceViewCopyWithImpl(this._self, this._then);

  final _OccurrenceView _self;
  final $Res Function(_OccurrenceView) _then;

/// Create a copy of OccurrenceView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? taskId = null,Object? title = null,Object? detail = freezed,Object? kind = null,Object? proof = null,Object? pointsEarn = null,Object? requiresDPresent = null,Object? day = null,Object? slot = null,Object? dueAt = freezed,Object? outcome = null,Object? outcomeAt = freezed,Object? outcomeNote = freezed,Object? proofKind = freezed,Object? proofRef = freezed,Object? proposedTime = freezed,Object? disposition = null,Object? dispositionAt = freezed,Object? dispositionNote = freezed,Object? consequence = freezed,Object? makeUpDay = freezed,Object? makeUpOf = freezed,Object? seenAt = freezed,Object? version = null,}) {
  return _then(_OccurrenceView(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,detail: freezed == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String?,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,proof: null == proof ? _self.proof : proof // ignore: cast_nullable_to_non_nullable
as String,pointsEarn: null == pointsEarn ? _self.pointsEarn : pointsEarn // ignore: cast_nullable_to_non_nullable
as int,requiresDPresent: null == requiresDPresent ? _self.requiresDPresent : requiresDPresent // ignore: cast_nullable_to_non_nullable
as bool,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as String,slot: null == slot ? _self.slot : slot // ignore: cast_nullable_to_non_nullable
as int,dueAt: freezed == dueAt ? _self.dueAt : dueAt // ignore: cast_nullable_to_non_nullable
as DateTime?,outcome: null == outcome ? _self.outcome : outcome // ignore: cast_nullable_to_non_nullable
as Outcome,outcomeAt: freezed == outcomeAt ? _self.outcomeAt : outcomeAt // ignore: cast_nullable_to_non_nullable
as DateTime?,outcomeNote: freezed == outcomeNote ? _self.outcomeNote : outcomeNote // ignore: cast_nullable_to_non_nullable
as String?,proofKind: freezed == proofKind ? _self.proofKind : proofKind // ignore: cast_nullable_to_non_nullable
as String?,proofRef: freezed == proofRef ? _self.proofRef : proofRef // ignore: cast_nullable_to_non_nullable
as String?,proposedTime: freezed == proposedTime ? _self.proposedTime : proposedTime // ignore: cast_nullable_to_non_nullable
as DateTime?,disposition: null == disposition ? _self.disposition : disposition // ignore: cast_nullable_to_non_nullable
as Disposition,dispositionAt: freezed == dispositionAt ? _self.dispositionAt : dispositionAt // ignore: cast_nullable_to_non_nullable
as DateTime?,dispositionNote: freezed == dispositionNote ? _self.dispositionNote : dispositionNote // ignore: cast_nullable_to_non_nullable
as String?,consequence: freezed == consequence ? _self.consequence : consequence // ignore: cast_nullable_to_non_nullable
as ConsequenceView?,makeUpDay: freezed == makeUpDay ? _self.makeUpDay : makeUpDay // ignore: cast_nullable_to_non_nullable
as String?,makeUpOf: freezed == makeUpOf ? _self.makeUpOf : makeUpOf // ignore: cast_nullable_to_non_nullable
as String?,seenAt: freezed == seenAt ? _self.seenAt : seenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of OccurrenceView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConsequenceViewCopyWith<$Res>? get consequence {
    if (_self.consequence == null) {
    return null;
  }

  return $ConsequenceViewCopyWith<$Res>(_self.consequence!, (value) {
    return _then(_self.copyWith(consequence: value));
  });
}
}


/// @nodoc
mixin _$OpenTaskView {

 String get id; String get title; String? get detail; String get proof; int get pointsEarn;
/// Create a copy of OpenTaskView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OpenTaskViewCopyWith<OpenTaskView> get copyWith => _$OpenTaskViewCopyWithImpl<OpenTaskView>(this as OpenTaskView, _$identity);

  /// Serializes this OpenTaskView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OpenTaskView&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.detail, detail) || other.detail == detail)&&(identical(other.proof, proof) || other.proof == proof)&&(identical(other.pointsEarn, pointsEarn) || other.pointsEarn == pointsEarn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,detail,proof,pointsEarn);

@override
String toString() {
  return 'OpenTaskView(id: $id, title: $title, detail: $detail, proof: $proof, pointsEarn: $pointsEarn)';
}


}

/// @nodoc
abstract mixin class $OpenTaskViewCopyWith<$Res>  {
  factory $OpenTaskViewCopyWith(OpenTaskView value, $Res Function(OpenTaskView) _then) = _$OpenTaskViewCopyWithImpl;
@useResult
$Res call({
 String id, String title, String? detail, String proof, int pointsEarn
});




}
/// @nodoc
class _$OpenTaskViewCopyWithImpl<$Res>
    implements $OpenTaskViewCopyWith<$Res> {
  _$OpenTaskViewCopyWithImpl(this._self, this._then);

  final OpenTaskView _self;
  final $Res Function(OpenTaskView) _then;

/// Create a copy of OpenTaskView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? detail = freezed,Object? proof = null,Object? pointsEarn = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,detail: freezed == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String?,proof: null == proof ? _self.proof : proof // ignore: cast_nullable_to_non_nullable
as String,pointsEarn: null == pointsEarn ? _self.pointsEarn : pointsEarn // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [OpenTaskView].
extension OpenTaskViewPatterns on OpenTaskView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OpenTaskView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OpenTaskView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OpenTaskView value)  $default,){
final _that = this;
switch (_that) {
case _OpenTaskView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OpenTaskView value)?  $default,){
final _that = this;
switch (_that) {
case _OpenTaskView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String? detail,  String proof,  int pointsEarn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OpenTaskView() when $default != null:
return $default(_that.id,_that.title,_that.detail,_that.proof,_that.pointsEarn);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String? detail,  String proof,  int pointsEarn)  $default,) {final _that = this;
switch (_that) {
case _OpenTaskView():
return $default(_that.id,_that.title,_that.detail,_that.proof,_that.pointsEarn);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String? detail,  String proof,  int pointsEarn)?  $default,) {final _that = this;
switch (_that) {
case _OpenTaskView() when $default != null:
return $default(_that.id,_that.title,_that.detail,_that.proof,_that.pointsEarn);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OpenTaskView implements OpenTaskView {
  const _OpenTaskView({required this.id, required this.title, this.detail, required this.proof, this.pointsEarn = 0});
  factory _OpenTaskView.fromJson(Map<String, dynamic> json) => _$OpenTaskViewFromJson(json);

@override final  String id;
@override final  String title;
@override final  String? detail;
@override final  String proof;
@override@JsonKey() final  int pointsEarn;

/// Create a copy of OpenTaskView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OpenTaskViewCopyWith<_OpenTaskView> get copyWith => __$OpenTaskViewCopyWithImpl<_OpenTaskView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OpenTaskViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OpenTaskView&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.detail, detail) || other.detail == detail)&&(identical(other.proof, proof) || other.proof == proof)&&(identical(other.pointsEarn, pointsEarn) || other.pointsEarn == pointsEarn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,detail,proof,pointsEarn);

@override
String toString() {
  return 'OpenTaskView(id: $id, title: $title, detail: $detail, proof: $proof, pointsEarn: $pointsEarn)';
}


}

/// @nodoc
abstract mixin class _$OpenTaskViewCopyWith<$Res> implements $OpenTaskViewCopyWith<$Res> {
  factory _$OpenTaskViewCopyWith(_OpenTaskView value, $Res Function(_OpenTaskView) _then) = __$OpenTaskViewCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String? detail, String proof, int pointsEarn
});




}
/// @nodoc
class __$OpenTaskViewCopyWithImpl<$Res>
    implements _$OpenTaskViewCopyWith<$Res> {
  __$OpenTaskViewCopyWithImpl(this._self, this._then);

  final _OpenTaskView _self;
  final $Res Function(_OpenTaskView) _then;

/// Create a copy of OpenTaskView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? detail = freezed,Object? proof = null,Object? pointsEarn = null,}) {
  return _then(_OpenTaskView(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,detail: freezed == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String?,proof: null == proof ? _self.proof : proof // ignore: cast_nullable_to_non_nullable
as String,pointsEarn: null == pointsEarn ? _self.pointsEarn : pointsEarn // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$TodayView {

 String get dynamicId;/// The relationship day shown, `yyyy-MM-dd`.
 String get day; String get timezone; int get dayBoundaryMinutes;/// `D` or `S` — the caller's side, as the server sees it.
 String get side; List<OccurrenceView> get items; List<OpenTaskView> get openTasks; int get balance; int get daysTogether;/// D face: things the s has said that have no answer yet, all days.
 int get needsMe; String? get partnerDisplayName;
/// Create a copy of TodayView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TodayViewCopyWith<TodayView> get copyWith => _$TodayViewCopyWithImpl<TodayView>(this as TodayView, _$identity);

  /// Serializes this TodayView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TodayView&&(identical(other.dynamicId, dynamicId) || other.dynamicId == dynamicId)&&(identical(other.day, day) || other.day == day)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.dayBoundaryMinutes, dayBoundaryMinutes) || other.dayBoundaryMinutes == dayBoundaryMinutes)&&(identical(other.side, side) || other.side == side)&&const DeepCollectionEquality().equals(other.items, items)&&const DeepCollectionEquality().equals(other.openTasks, openTasks)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.daysTogether, daysTogether) || other.daysTogether == daysTogether)&&(identical(other.needsMe, needsMe) || other.needsMe == needsMe)&&(identical(other.partnerDisplayName, partnerDisplayName) || other.partnerDisplayName == partnerDisplayName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,dynamicId,day,timezone,dayBoundaryMinutes,side,const DeepCollectionEquality().hash(items),const DeepCollectionEquality().hash(openTasks),balance,daysTogether,needsMe,partnerDisplayName);

@override
String toString() {
  return 'TodayView(dynamicId: $dynamicId, day: $day, timezone: $timezone, dayBoundaryMinutes: $dayBoundaryMinutes, side: $side, items: $items, openTasks: $openTasks, balance: $balance, daysTogether: $daysTogether, needsMe: $needsMe, partnerDisplayName: $partnerDisplayName)';
}


}

/// @nodoc
abstract mixin class $TodayViewCopyWith<$Res>  {
  factory $TodayViewCopyWith(TodayView value, $Res Function(TodayView) _then) = _$TodayViewCopyWithImpl;
@useResult
$Res call({
 String dynamicId, String day, String timezone, int dayBoundaryMinutes, String side, List<OccurrenceView> items, List<OpenTaskView> openTasks, int balance, int daysTogether, int needsMe, String? partnerDisplayName
});




}
/// @nodoc
class _$TodayViewCopyWithImpl<$Res>
    implements $TodayViewCopyWith<$Res> {
  _$TodayViewCopyWithImpl(this._self, this._then);

  final TodayView _self;
  final $Res Function(TodayView) _then;

/// Create a copy of TodayView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? dynamicId = null,Object? day = null,Object? timezone = null,Object? dayBoundaryMinutes = null,Object? side = null,Object? items = null,Object? openTasks = null,Object? balance = null,Object? daysTogether = null,Object? needsMe = null,Object? partnerDisplayName = freezed,}) {
  return _then(_self.copyWith(
dynamicId: null == dynamicId ? _self.dynamicId : dynamicId // ignore: cast_nullable_to_non_nullable
as String,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as String,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,dayBoundaryMinutes: null == dayBoundaryMinutes ? _self.dayBoundaryMinutes : dayBoundaryMinutes // ignore: cast_nullable_to_non_nullable
as int,side: null == side ? _self.side : side // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<OccurrenceView>,openTasks: null == openTasks ? _self.openTasks : openTasks // ignore: cast_nullable_to_non_nullable
as List<OpenTaskView>,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as int,daysTogether: null == daysTogether ? _self.daysTogether : daysTogether // ignore: cast_nullable_to_non_nullable
as int,needsMe: null == needsMe ? _self.needsMe : needsMe // ignore: cast_nullable_to_non_nullable
as int,partnerDisplayName: freezed == partnerDisplayName ? _self.partnerDisplayName : partnerDisplayName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TodayView].
extension TodayViewPatterns on TodayView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TodayView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TodayView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TodayView value)  $default,){
final _that = this;
switch (_that) {
case _TodayView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TodayView value)?  $default,){
final _that = this;
switch (_that) {
case _TodayView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String dynamicId,  String day,  String timezone,  int dayBoundaryMinutes,  String side,  List<OccurrenceView> items,  List<OpenTaskView> openTasks,  int balance,  int daysTogether,  int needsMe,  String? partnerDisplayName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TodayView() when $default != null:
return $default(_that.dynamicId,_that.day,_that.timezone,_that.dayBoundaryMinutes,_that.side,_that.items,_that.openTasks,_that.balance,_that.daysTogether,_that.needsMe,_that.partnerDisplayName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String dynamicId,  String day,  String timezone,  int dayBoundaryMinutes,  String side,  List<OccurrenceView> items,  List<OpenTaskView> openTasks,  int balance,  int daysTogether,  int needsMe,  String? partnerDisplayName)  $default,) {final _that = this;
switch (_that) {
case _TodayView():
return $default(_that.dynamicId,_that.day,_that.timezone,_that.dayBoundaryMinutes,_that.side,_that.items,_that.openTasks,_that.balance,_that.daysTogether,_that.needsMe,_that.partnerDisplayName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String dynamicId,  String day,  String timezone,  int dayBoundaryMinutes,  String side,  List<OccurrenceView> items,  List<OpenTaskView> openTasks,  int balance,  int daysTogether,  int needsMe,  String? partnerDisplayName)?  $default,) {final _that = this;
switch (_that) {
case _TodayView() when $default != null:
return $default(_that.dynamicId,_that.day,_that.timezone,_that.dayBoundaryMinutes,_that.side,_that.items,_that.openTasks,_that.balance,_that.daysTogether,_that.needsMe,_that.partnerDisplayName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TodayView extends TodayView {
  const _TodayView({required this.dynamicId, required this.day, required this.timezone, this.dayBoundaryMinutes = 240, required this.side, final  List<OccurrenceView> items = const <OccurrenceView>[], final  List<OpenTaskView> openTasks = const <OpenTaskView>[], this.balance = 0, this.daysTogether = 0, this.needsMe = 0, this.partnerDisplayName}): _items = items,_openTasks = openTasks,super._();
  factory _TodayView.fromJson(Map<String, dynamic> json) => _$TodayViewFromJson(json);

@override final  String dynamicId;
/// The relationship day shown, `yyyy-MM-dd`.
@override final  String day;
@override final  String timezone;
@override@JsonKey() final  int dayBoundaryMinutes;
/// `D` or `S` — the caller's side, as the server sees it.
@override final  String side;
 final  List<OccurrenceView> _items;
@override@JsonKey() List<OccurrenceView> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

 final  List<OpenTaskView> _openTasks;
@override@JsonKey() List<OpenTaskView> get openTasks {
  if (_openTasks is EqualUnmodifiableListView) return _openTasks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_openTasks);
}

@override@JsonKey() final  int balance;
@override@JsonKey() final  int daysTogether;
/// D face: things the s has said that have no answer yet, all days.
@override@JsonKey() final  int needsMe;
@override final  String? partnerDisplayName;

/// Create a copy of TodayView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TodayViewCopyWith<_TodayView> get copyWith => __$TodayViewCopyWithImpl<_TodayView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TodayViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TodayView&&(identical(other.dynamicId, dynamicId) || other.dynamicId == dynamicId)&&(identical(other.day, day) || other.day == day)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.dayBoundaryMinutes, dayBoundaryMinutes) || other.dayBoundaryMinutes == dayBoundaryMinutes)&&(identical(other.side, side) || other.side == side)&&const DeepCollectionEquality().equals(other._items, _items)&&const DeepCollectionEquality().equals(other._openTasks, _openTasks)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.daysTogether, daysTogether) || other.daysTogether == daysTogether)&&(identical(other.needsMe, needsMe) || other.needsMe == needsMe)&&(identical(other.partnerDisplayName, partnerDisplayName) || other.partnerDisplayName == partnerDisplayName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,dynamicId,day,timezone,dayBoundaryMinutes,side,const DeepCollectionEquality().hash(_items),const DeepCollectionEquality().hash(_openTasks),balance,daysTogether,needsMe,partnerDisplayName);

@override
String toString() {
  return 'TodayView(dynamicId: $dynamicId, day: $day, timezone: $timezone, dayBoundaryMinutes: $dayBoundaryMinutes, side: $side, items: $items, openTasks: $openTasks, balance: $balance, daysTogether: $daysTogether, needsMe: $needsMe, partnerDisplayName: $partnerDisplayName)';
}


}

/// @nodoc
abstract mixin class _$TodayViewCopyWith<$Res> implements $TodayViewCopyWith<$Res> {
  factory _$TodayViewCopyWith(_TodayView value, $Res Function(_TodayView) _then) = __$TodayViewCopyWithImpl;
@override @useResult
$Res call({
 String dynamicId, String day, String timezone, int dayBoundaryMinutes, String side, List<OccurrenceView> items, List<OpenTaskView> openTasks, int balance, int daysTogether, int needsMe, String? partnerDisplayName
});




}
/// @nodoc
class __$TodayViewCopyWithImpl<$Res>
    implements _$TodayViewCopyWith<$Res> {
  __$TodayViewCopyWithImpl(this._self, this._then);

  final _TodayView _self;
  final $Res Function(_TodayView) _then;

/// Create a copy of TodayView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dynamicId = null,Object? day = null,Object? timezone = null,Object? dayBoundaryMinutes = null,Object? side = null,Object? items = null,Object? openTasks = null,Object? balance = null,Object? daysTogether = null,Object? needsMe = null,Object? partnerDisplayName = freezed,}) {
  return _then(_TodayView(
dynamicId: null == dynamicId ? _self.dynamicId : dynamicId // ignore: cast_nullable_to_non_nullable
as String,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as String,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,dayBoundaryMinutes: null == dayBoundaryMinutes ? _self.dayBoundaryMinutes : dayBoundaryMinutes // ignore: cast_nullable_to_non_nullable
as int,side: null == side ? _self.side : side // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<OccurrenceView>,openTasks: null == openTasks ? _self._openTasks : openTasks // ignore: cast_nullable_to_non_nullable
as List<OpenTaskView>,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as int,daysTogether: null == daysTogether ? _self.daysTogether : daysTogether // ignore: cast_nullable_to_non_nullable
as int,needsMe: null == needsMe ? _self.needsMe : needsMe // ignore: cast_nullable_to_non_nullable
as int,partnerDisplayName: freezed == partnerDisplayName ? _self.partnerDisplayName : partnerDisplayName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
