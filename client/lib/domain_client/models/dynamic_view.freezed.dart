// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dynamic_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MemberView {

 String get userId; String? get displayName; String get roleContext;/// How they describe their role. Never used for authorization.
 String? get rolePreset;/// `D` or `S` — which face of the app this member sees.
 String? get side; String get accessState;
/// Create a copy of MemberView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MemberViewCopyWith<MemberView> get copyWith => _$MemberViewCopyWithImpl<MemberView>(this as MemberView, _$identity);

  /// Serializes this MemberView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MemberView&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.roleContext, roleContext) || other.roleContext == roleContext)&&(identical(other.rolePreset, rolePreset) || other.rolePreset == rolePreset)&&(identical(other.side, side) || other.side == side)&&(identical(other.accessState, accessState) || other.accessState == accessState));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,displayName,roleContext,rolePreset,side,accessState);

@override
String toString() {
  return 'MemberView(userId: $userId, displayName: $displayName, roleContext: $roleContext, rolePreset: $rolePreset, side: $side, accessState: $accessState)';
}


}

/// @nodoc
abstract mixin class $MemberViewCopyWith<$Res>  {
  factory $MemberViewCopyWith(MemberView value, $Res Function(MemberView) _then) = _$MemberViewCopyWithImpl;
@useResult
$Res call({
 String userId, String? displayName, String roleContext, String? rolePreset, String? side, String accessState
});




}
/// @nodoc
class _$MemberViewCopyWithImpl<$Res>
    implements $MemberViewCopyWith<$Res> {
  _$MemberViewCopyWithImpl(this._self, this._then);

  final MemberView _self;
  final $Res Function(MemberView) _then;

/// Create a copy of MemberView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? displayName = freezed,Object? roleContext = null,Object? rolePreset = freezed,Object? side = freezed,Object? accessState = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,roleContext: null == roleContext ? _self.roleContext : roleContext // ignore: cast_nullable_to_non_nullable
as String,rolePreset: freezed == rolePreset ? _self.rolePreset : rolePreset // ignore: cast_nullable_to_non_nullable
as String?,side: freezed == side ? _self.side : side // ignore: cast_nullable_to_non_nullable
as String?,accessState: null == accessState ? _self.accessState : accessState // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MemberView].
extension MemberViewPatterns on MemberView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MemberView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MemberView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MemberView value)  $default,){
final _that = this;
switch (_that) {
case _MemberView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MemberView value)?  $default,){
final _that = this;
switch (_that) {
case _MemberView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String? displayName,  String roleContext,  String? rolePreset,  String? side,  String accessState)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MemberView() when $default != null:
return $default(_that.userId,_that.displayName,_that.roleContext,_that.rolePreset,_that.side,_that.accessState);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String? displayName,  String roleContext,  String? rolePreset,  String? side,  String accessState)  $default,) {final _that = this;
switch (_that) {
case _MemberView():
return $default(_that.userId,_that.displayName,_that.roleContext,_that.rolePreset,_that.side,_that.accessState);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String? displayName,  String roleContext,  String? rolePreset,  String? side,  String accessState)?  $default,) {final _that = this;
switch (_that) {
case _MemberView() when $default != null:
return $default(_that.userId,_that.displayName,_that.roleContext,_that.rolePreset,_that.side,_that.accessState);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MemberView implements MemberView {
  const _MemberView({required this.userId, this.displayName, required this.roleContext, this.rolePreset, this.side, required this.accessState});
  factory _MemberView.fromJson(Map<String, dynamic> json) => _$MemberViewFromJson(json);

@override final  String userId;
@override final  String? displayName;
@override final  String roleContext;
/// How they describe their role. Never used for authorization.
@override final  String? rolePreset;
/// `D` or `S` — which face of the app this member sees.
@override final  String? side;
@override final  String accessState;

/// Create a copy of MemberView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MemberViewCopyWith<_MemberView> get copyWith => __$MemberViewCopyWithImpl<_MemberView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MemberViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MemberView&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.roleContext, roleContext) || other.roleContext == roleContext)&&(identical(other.rolePreset, rolePreset) || other.rolePreset == rolePreset)&&(identical(other.side, side) || other.side == side)&&(identical(other.accessState, accessState) || other.accessState == accessState));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,displayName,roleContext,rolePreset,side,accessState);

@override
String toString() {
  return 'MemberView(userId: $userId, displayName: $displayName, roleContext: $roleContext, rolePreset: $rolePreset, side: $side, accessState: $accessState)';
}


}

/// @nodoc
abstract mixin class _$MemberViewCopyWith<$Res> implements $MemberViewCopyWith<$Res> {
  factory _$MemberViewCopyWith(_MemberView value, $Res Function(_MemberView) _then) = __$MemberViewCopyWithImpl;
@override @useResult
$Res call({
 String userId, String? displayName, String roleContext, String? rolePreset, String? side, String accessState
});




}
/// @nodoc
class __$MemberViewCopyWithImpl<$Res>
    implements _$MemberViewCopyWith<$Res> {
  __$MemberViewCopyWithImpl(this._self, this._then);

  final _MemberView _self;
  final $Res Function(_MemberView) _then;

/// Create a copy of MemberView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? displayName = freezed,Object? roleContext = null,Object? rolePreset = freezed,Object? side = freezed,Object? accessState = null,}) {
  return _then(_MemberView(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,roleContext: null == roleContext ? _self.roleContext : roleContext // ignore: cast_nullable_to_non_nullable
as String,rolePreset: freezed == rolePreset ? _self.rolePreset : rolePreset // ignore: cast_nullable_to_non_nullable
as String?,side: freezed == side ? _self.side : side // ignore: cast_nullable_to_non_nullable
as String?,accessState: null == accessState ? _self.accessState : accessState // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$StructureItem {

 String get taskId; String get kind; String get title; bool get active;
/// Create a copy of StructureItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StructureItemCopyWith<StructureItem> get copyWith => _$StructureItemCopyWithImpl<StructureItem>(this as StructureItem, _$identity);

  /// Serializes this StructureItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StructureItem&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.title, title) || other.title == title)&&(identical(other.active, active) || other.active == active));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,taskId,kind,title,active);

@override
String toString() {
  return 'StructureItem(taskId: $taskId, kind: $kind, title: $title, active: $active)';
}


}

/// @nodoc
abstract mixin class $StructureItemCopyWith<$Res>  {
  factory $StructureItemCopyWith(StructureItem value, $Res Function(StructureItem) _then) = _$StructureItemCopyWithImpl;
@useResult
$Res call({
 String taskId, String kind, String title, bool active
});




}
/// @nodoc
class _$StructureItemCopyWithImpl<$Res>
    implements $StructureItemCopyWith<$Res> {
  _$StructureItemCopyWithImpl(this._self, this._then);

  final StructureItem _self;
  final $Res Function(StructureItem) _then;

/// Create a copy of StructureItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? taskId = null,Object? kind = null,Object? title = null,Object? active = null,}) {
  return _then(_self.copyWith(
taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [StructureItem].
extension StructureItemPatterns on StructureItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StructureItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StructureItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StructureItem value)  $default,){
final _that = this;
switch (_that) {
case _StructureItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StructureItem value)?  $default,){
final _that = this;
switch (_that) {
case _StructureItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String taskId,  String kind,  String title,  bool active)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StructureItem() when $default != null:
return $default(_that.taskId,_that.kind,_that.title,_that.active);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String taskId,  String kind,  String title,  bool active)  $default,) {final _that = this;
switch (_that) {
case _StructureItem():
return $default(_that.taskId,_that.kind,_that.title,_that.active);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String taskId,  String kind,  String title,  bool active)?  $default,) {final _that = this;
switch (_that) {
case _StructureItem() when $default != null:
return $default(_that.taskId,_that.kind,_that.title,_that.active);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StructureItem implements StructureItem {
  const _StructureItem({required this.taskId, required this.kind, required this.title, required this.active});
  factory _StructureItem.fromJson(Map<String, dynamic> json) => _$StructureItemFromJson(json);

@override final  String taskId;
@override final  String kind;
@override final  String title;
@override final  bool active;

/// Create a copy of StructureItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StructureItemCopyWith<_StructureItem> get copyWith => __$StructureItemCopyWithImpl<_StructureItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StructureItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StructureItem&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.title, title) || other.title == title)&&(identical(other.active, active) || other.active == active));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,taskId,kind,title,active);

@override
String toString() {
  return 'StructureItem(taskId: $taskId, kind: $kind, title: $title, active: $active)';
}


}

/// @nodoc
abstract mixin class _$StructureItemCopyWith<$Res> implements $StructureItemCopyWith<$Res> {
  factory _$StructureItemCopyWith(_StructureItem value, $Res Function(_StructureItem) _then) = __$StructureItemCopyWithImpl;
@override @useResult
$Res call({
 String taskId, String kind, String title, bool active
});




}
/// @nodoc
class __$StructureItemCopyWithImpl<$Res>
    implements _$StructureItemCopyWith<$Res> {
  __$StructureItemCopyWithImpl(this._self, this._then);

  final _StructureItem _self;
  final $Res Function(_StructureItem) _then;

/// Create a copy of StructureItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? taskId = null,Object? kind = null,Object? title = null,Object? active = null,}) {
  return _then(_StructureItem(
taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$DynamicDetail {

 String get dynamicId; String get state; String get desiredOutcome; String get structureLevel; String get referenceTimezone; int get dayBoundaryMinutes; DateTime? get pausedAt;/// D-26: the D is away until this instant; tasks needing them are paused.
 DateTime? get dAwayUntil; List<MemberView> get members; List<StructureItem> get structure;/// Agency no role can ever remove. The UI must always be
/// able to surface these, whatever the viewer's role.
 List<String> get alwaysAvailable;
/// Create a copy of DynamicDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DynamicDetailCopyWith<DynamicDetail> get copyWith => _$DynamicDetailCopyWithImpl<DynamicDetail>(this as DynamicDetail, _$identity);

  /// Serializes this DynamicDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DynamicDetail&&(identical(other.dynamicId, dynamicId) || other.dynamicId == dynamicId)&&(identical(other.state, state) || other.state == state)&&(identical(other.desiredOutcome, desiredOutcome) || other.desiredOutcome == desiredOutcome)&&(identical(other.structureLevel, structureLevel) || other.structureLevel == structureLevel)&&(identical(other.referenceTimezone, referenceTimezone) || other.referenceTimezone == referenceTimezone)&&(identical(other.dayBoundaryMinutes, dayBoundaryMinutes) || other.dayBoundaryMinutes == dayBoundaryMinutes)&&(identical(other.pausedAt, pausedAt) || other.pausedAt == pausedAt)&&(identical(other.dAwayUntil, dAwayUntil) || other.dAwayUntil == dAwayUntil)&&const DeepCollectionEquality().equals(other.members, members)&&const DeepCollectionEquality().equals(other.structure, structure)&&const DeepCollectionEquality().equals(other.alwaysAvailable, alwaysAvailable));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,dynamicId,state,desiredOutcome,structureLevel,referenceTimezone,dayBoundaryMinutes,pausedAt,dAwayUntil,const DeepCollectionEquality().hash(members),const DeepCollectionEquality().hash(structure),const DeepCollectionEquality().hash(alwaysAvailable));

@override
String toString() {
  return 'DynamicDetail(dynamicId: $dynamicId, state: $state, desiredOutcome: $desiredOutcome, structureLevel: $structureLevel, referenceTimezone: $referenceTimezone, dayBoundaryMinutes: $dayBoundaryMinutes, pausedAt: $pausedAt, dAwayUntil: $dAwayUntil, members: $members, structure: $structure, alwaysAvailable: $alwaysAvailable)';
}


}

/// @nodoc
abstract mixin class $DynamicDetailCopyWith<$Res>  {
  factory $DynamicDetailCopyWith(DynamicDetail value, $Res Function(DynamicDetail) _then) = _$DynamicDetailCopyWithImpl;
@useResult
$Res call({
 String dynamicId, String state, String desiredOutcome, String structureLevel, String referenceTimezone, int dayBoundaryMinutes, DateTime? pausedAt, DateTime? dAwayUntil, List<MemberView> members, List<StructureItem> structure, List<String> alwaysAvailable
});




}
/// @nodoc
class _$DynamicDetailCopyWithImpl<$Res>
    implements $DynamicDetailCopyWith<$Res> {
  _$DynamicDetailCopyWithImpl(this._self, this._then);

  final DynamicDetail _self;
  final $Res Function(DynamicDetail) _then;

/// Create a copy of DynamicDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? dynamicId = null,Object? state = null,Object? desiredOutcome = null,Object? structureLevel = null,Object? referenceTimezone = null,Object? dayBoundaryMinutes = null,Object? pausedAt = freezed,Object? dAwayUntil = freezed,Object? members = null,Object? structure = null,Object? alwaysAvailable = null,}) {
  return _then(_self.copyWith(
dynamicId: null == dynamicId ? _self.dynamicId : dynamicId // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,desiredOutcome: null == desiredOutcome ? _self.desiredOutcome : desiredOutcome // ignore: cast_nullable_to_non_nullable
as String,structureLevel: null == structureLevel ? _self.structureLevel : structureLevel // ignore: cast_nullable_to_non_nullable
as String,referenceTimezone: null == referenceTimezone ? _self.referenceTimezone : referenceTimezone // ignore: cast_nullable_to_non_nullable
as String,dayBoundaryMinutes: null == dayBoundaryMinutes ? _self.dayBoundaryMinutes : dayBoundaryMinutes // ignore: cast_nullable_to_non_nullable
as int,pausedAt: freezed == pausedAt ? _self.pausedAt : pausedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,dAwayUntil: freezed == dAwayUntil ? _self.dAwayUntil : dAwayUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,members: null == members ? _self.members : members // ignore: cast_nullable_to_non_nullable
as List<MemberView>,structure: null == structure ? _self.structure : structure // ignore: cast_nullable_to_non_nullable
as List<StructureItem>,alwaysAvailable: null == alwaysAvailable ? _self.alwaysAvailable : alwaysAvailable // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [DynamicDetail].
extension DynamicDetailPatterns on DynamicDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DynamicDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DynamicDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DynamicDetail value)  $default,){
final _that = this;
switch (_that) {
case _DynamicDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DynamicDetail value)?  $default,){
final _that = this;
switch (_that) {
case _DynamicDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String dynamicId,  String state,  String desiredOutcome,  String structureLevel,  String referenceTimezone,  int dayBoundaryMinutes,  DateTime? pausedAt,  DateTime? dAwayUntil,  List<MemberView> members,  List<StructureItem> structure,  List<String> alwaysAvailable)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DynamicDetail() when $default != null:
return $default(_that.dynamicId,_that.state,_that.desiredOutcome,_that.structureLevel,_that.referenceTimezone,_that.dayBoundaryMinutes,_that.pausedAt,_that.dAwayUntil,_that.members,_that.structure,_that.alwaysAvailable);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String dynamicId,  String state,  String desiredOutcome,  String structureLevel,  String referenceTimezone,  int dayBoundaryMinutes,  DateTime? pausedAt,  DateTime? dAwayUntil,  List<MemberView> members,  List<StructureItem> structure,  List<String> alwaysAvailable)  $default,) {final _that = this;
switch (_that) {
case _DynamicDetail():
return $default(_that.dynamicId,_that.state,_that.desiredOutcome,_that.structureLevel,_that.referenceTimezone,_that.dayBoundaryMinutes,_that.pausedAt,_that.dAwayUntil,_that.members,_that.structure,_that.alwaysAvailable);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String dynamicId,  String state,  String desiredOutcome,  String structureLevel,  String referenceTimezone,  int dayBoundaryMinutes,  DateTime? pausedAt,  DateTime? dAwayUntil,  List<MemberView> members,  List<StructureItem> structure,  List<String> alwaysAvailable)?  $default,) {final _that = this;
switch (_that) {
case _DynamicDetail() when $default != null:
return $default(_that.dynamicId,_that.state,_that.desiredOutcome,_that.structureLevel,_that.referenceTimezone,_that.dayBoundaryMinutes,_that.pausedAt,_that.dAwayUntil,_that.members,_that.structure,_that.alwaysAvailable);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DynamicDetail implements DynamicDetail {
  const _DynamicDetail({required this.dynamicId, required this.state, required this.desiredOutcome, required this.structureLevel, required this.referenceTimezone, this.dayBoundaryMinutes = 0, this.pausedAt, this.dAwayUntil, final  List<MemberView> members = const <MemberView>[], final  List<StructureItem> structure = const <StructureItem>[], final  List<String> alwaysAvailable = const <String>[]}): _members = members,_structure = structure,_alwaysAvailable = alwaysAvailable;
  factory _DynamicDetail.fromJson(Map<String, dynamic> json) => _$DynamicDetailFromJson(json);

@override final  String dynamicId;
@override final  String state;
@override final  String desiredOutcome;
@override final  String structureLevel;
@override final  String referenceTimezone;
@override@JsonKey() final  int dayBoundaryMinutes;
@override final  DateTime? pausedAt;
/// D-26: the D is away until this instant; tasks needing them are paused.
@override final  DateTime? dAwayUntil;
 final  List<MemberView> _members;
@override@JsonKey() List<MemberView> get members {
  if (_members is EqualUnmodifiableListView) return _members;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_members);
}

 final  List<StructureItem> _structure;
@override@JsonKey() List<StructureItem> get structure {
  if (_structure is EqualUnmodifiableListView) return _structure;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_structure);
}

/// Agency no role can ever remove. The UI must always be
/// able to surface these, whatever the viewer's role.
 final  List<String> _alwaysAvailable;
/// Agency no role can ever remove. The UI must always be
/// able to surface these, whatever the viewer's role.
@override@JsonKey() List<String> get alwaysAvailable {
  if (_alwaysAvailable is EqualUnmodifiableListView) return _alwaysAvailable;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_alwaysAvailable);
}


/// Create a copy of DynamicDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DynamicDetailCopyWith<_DynamicDetail> get copyWith => __$DynamicDetailCopyWithImpl<_DynamicDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DynamicDetailToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DynamicDetail&&(identical(other.dynamicId, dynamicId) || other.dynamicId == dynamicId)&&(identical(other.state, state) || other.state == state)&&(identical(other.desiredOutcome, desiredOutcome) || other.desiredOutcome == desiredOutcome)&&(identical(other.structureLevel, structureLevel) || other.structureLevel == structureLevel)&&(identical(other.referenceTimezone, referenceTimezone) || other.referenceTimezone == referenceTimezone)&&(identical(other.dayBoundaryMinutes, dayBoundaryMinutes) || other.dayBoundaryMinutes == dayBoundaryMinutes)&&(identical(other.pausedAt, pausedAt) || other.pausedAt == pausedAt)&&(identical(other.dAwayUntil, dAwayUntil) || other.dAwayUntil == dAwayUntil)&&const DeepCollectionEquality().equals(other._members, _members)&&const DeepCollectionEquality().equals(other._structure, _structure)&&const DeepCollectionEquality().equals(other._alwaysAvailable, _alwaysAvailable));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,dynamicId,state,desiredOutcome,structureLevel,referenceTimezone,dayBoundaryMinutes,pausedAt,dAwayUntil,const DeepCollectionEquality().hash(_members),const DeepCollectionEquality().hash(_structure),const DeepCollectionEquality().hash(_alwaysAvailable));

@override
String toString() {
  return 'DynamicDetail(dynamicId: $dynamicId, state: $state, desiredOutcome: $desiredOutcome, structureLevel: $structureLevel, referenceTimezone: $referenceTimezone, dayBoundaryMinutes: $dayBoundaryMinutes, pausedAt: $pausedAt, dAwayUntil: $dAwayUntil, members: $members, structure: $structure, alwaysAvailable: $alwaysAvailable)';
}


}

/// @nodoc
abstract mixin class _$DynamicDetailCopyWith<$Res> implements $DynamicDetailCopyWith<$Res> {
  factory _$DynamicDetailCopyWith(_DynamicDetail value, $Res Function(_DynamicDetail) _then) = __$DynamicDetailCopyWithImpl;
@override @useResult
$Res call({
 String dynamicId, String state, String desiredOutcome, String structureLevel, String referenceTimezone, int dayBoundaryMinutes, DateTime? pausedAt, DateTime? dAwayUntil, List<MemberView> members, List<StructureItem> structure, List<String> alwaysAvailable
});




}
/// @nodoc
class __$DynamicDetailCopyWithImpl<$Res>
    implements _$DynamicDetailCopyWith<$Res> {
  __$DynamicDetailCopyWithImpl(this._self, this._then);

  final _DynamicDetail _self;
  final $Res Function(_DynamicDetail) _then;

/// Create a copy of DynamicDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dynamicId = null,Object? state = null,Object? desiredOutcome = null,Object? structureLevel = null,Object? referenceTimezone = null,Object? dayBoundaryMinutes = null,Object? pausedAt = freezed,Object? dAwayUntil = freezed,Object? members = null,Object? structure = null,Object? alwaysAvailable = null,}) {
  return _then(_DynamicDetail(
dynamicId: null == dynamicId ? _self.dynamicId : dynamicId // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,desiredOutcome: null == desiredOutcome ? _self.desiredOutcome : desiredOutcome // ignore: cast_nullable_to_non_nullable
as String,structureLevel: null == structureLevel ? _self.structureLevel : structureLevel // ignore: cast_nullable_to_non_nullable
as String,referenceTimezone: null == referenceTimezone ? _self.referenceTimezone : referenceTimezone // ignore: cast_nullable_to_non_nullable
as String,dayBoundaryMinutes: null == dayBoundaryMinutes ? _self.dayBoundaryMinutes : dayBoundaryMinutes // ignore: cast_nullable_to_non_nullable
as int,pausedAt: freezed == pausedAt ? _self.pausedAt : pausedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,dAwayUntil: freezed == dAwayUntil ? _self.dAwayUntil : dAwayUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,members: null == members ? _self._members : members // ignore: cast_nullable_to_non_nullable
as List<MemberView>,structure: null == structure ? _self._structure : structure // ignore: cast_nullable_to_non_nullable
as List<StructureItem>,alwaysAvailable: null == alwaysAvailable ? _self._alwaysAvailable : alwaysAvailable // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
