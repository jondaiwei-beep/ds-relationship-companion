// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'consequence.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ConsequenceView {

 String get id; String? get dynamicId;/// Always a D. Never the software.
 String get issuedBy; String get title; String? get detail;/// `issued | done_by_s | confirmed | waived`.
 String get status; DateTime? get issuedAt; DateTime? get doneAt; DateTime? get decidedAt;
/// Create a copy of ConsequenceView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConsequenceViewCopyWith<ConsequenceView> get copyWith => _$ConsequenceViewCopyWithImpl<ConsequenceView>(this as ConsequenceView, _$identity);

  /// Serializes this ConsequenceView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConsequenceView&&(identical(other.id, id) || other.id == id)&&(identical(other.dynamicId, dynamicId) || other.dynamicId == dynamicId)&&(identical(other.issuedBy, issuedBy) || other.issuedBy == issuedBy)&&(identical(other.title, title) || other.title == title)&&(identical(other.detail, detail) || other.detail == detail)&&(identical(other.status, status) || other.status == status)&&(identical(other.issuedAt, issuedAt) || other.issuedAt == issuedAt)&&(identical(other.doneAt, doneAt) || other.doneAt == doneAt)&&(identical(other.decidedAt, decidedAt) || other.decidedAt == decidedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,dynamicId,issuedBy,title,detail,status,issuedAt,doneAt,decidedAt);

@override
String toString() {
  return 'ConsequenceView(id: $id, dynamicId: $dynamicId, issuedBy: $issuedBy, title: $title, detail: $detail, status: $status, issuedAt: $issuedAt, doneAt: $doneAt, decidedAt: $decidedAt)';
}


}

/// @nodoc
abstract mixin class $ConsequenceViewCopyWith<$Res>  {
  factory $ConsequenceViewCopyWith(ConsequenceView value, $Res Function(ConsequenceView) _then) = _$ConsequenceViewCopyWithImpl;
@useResult
$Res call({
 String id, String? dynamicId, String issuedBy, String title, String? detail, String status, DateTime? issuedAt, DateTime? doneAt, DateTime? decidedAt
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? dynamicId = freezed,Object? issuedBy = null,Object? title = null,Object? detail = freezed,Object? status = null,Object? issuedAt = freezed,Object? doneAt = freezed,Object? decidedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,dynamicId: freezed == dynamicId ? _self.dynamicId : dynamicId // ignore: cast_nullable_to_non_nullable
as String?,issuedBy: null == issuedBy ? _self.issuedBy : issuedBy // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,detail: freezed == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,issuedAt: freezed == issuedAt ? _self.issuedAt : issuedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,doneAt: freezed == doneAt ? _self.doneAt : doneAt // ignore: cast_nullable_to_non_nullable
as DateTime?,decidedAt: freezed == decidedAt ? _self.decidedAt : decidedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? dynamicId,  String issuedBy,  String title,  String? detail,  String status,  DateTime? issuedAt,  DateTime? doneAt,  DateTime? decidedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConsequenceView() when $default != null:
return $default(_that.id,_that.dynamicId,_that.issuedBy,_that.title,_that.detail,_that.status,_that.issuedAt,_that.doneAt,_that.decidedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? dynamicId,  String issuedBy,  String title,  String? detail,  String status,  DateTime? issuedAt,  DateTime? doneAt,  DateTime? decidedAt)  $default,) {final _that = this;
switch (_that) {
case _ConsequenceView():
return $default(_that.id,_that.dynamicId,_that.issuedBy,_that.title,_that.detail,_that.status,_that.issuedAt,_that.doneAt,_that.decidedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? dynamicId,  String issuedBy,  String title,  String? detail,  String status,  DateTime? issuedAt,  DateTime? doneAt,  DateTime? decidedAt)?  $default,) {final _that = this;
switch (_that) {
case _ConsequenceView() when $default != null:
return $default(_that.id,_that.dynamicId,_that.issuedBy,_that.title,_that.detail,_that.status,_that.issuedAt,_that.doneAt,_that.decidedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ConsequenceView extends ConsequenceView {
  const _ConsequenceView({required this.id, this.dynamicId, required this.issuedBy, required this.title, this.detail, required this.status, this.issuedAt, this.doneAt, this.decidedAt}): super._();
  factory _ConsequenceView.fromJson(Map<String, dynamic> json) => _$ConsequenceViewFromJson(json);

@override final  String id;
@override final  String? dynamicId;
/// Always a D. Never the software.
@override final  String issuedBy;
@override final  String title;
@override final  String? detail;
/// `issued | done_by_s | confirmed | waived`.
@override final  String status;
@override final  DateTime? issuedAt;
@override final  DateTime? doneAt;
@override final  DateTime? decidedAt;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConsequenceView&&(identical(other.id, id) || other.id == id)&&(identical(other.dynamicId, dynamicId) || other.dynamicId == dynamicId)&&(identical(other.issuedBy, issuedBy) || other.issuedBy == issuedBy)&&(identical(other.title, title) || other.title == title)&&(identical(other.detail, detail) || other.detail == detail)&&(identical(other.status, status) || other.status == status)&&(identical(other.issuedAt, issuedAt) || other.issuedAt == issuedAt)&&(identical(other.doneAt, doneAt) || other.doneAt == doneAt)&&(identical(other.decidedAt, decidedAt) || other.decidedAt == decidedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,dynamicId,issuedBy,title,detail,status,issuedAt,doneAt,decidedAt);

@override
String toString() {
  return 'ConsequenceView(id: $id, dynamicId: $dynamicId, issuedBy: $issuedBy, title: $title, detail: $detail, status: $status, issuedAt: $issuedAt, doneAt: $doneAt, decidedAt: $decidedAt)';
}


}

/// @nodoc
abstract mixin class _$ConsequenceViewCopyWith<$Res> implements $ConsequenceViewCopyWith<$Res> {
  factory _$ConsequenceViewCopyWith(_ConsequenceView value, $Res Function(_ConsequenceView) _then) = __$ConsequenceViewCopyWithImpl;
@override @useResult
$Res call({
 String id, String? dynamicId, String issuedBy, String title, String? detail, String status, DateTime? issuedAt, DateTime? doneAt, DateTime? decidedAt
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? dynamicId = freezed,Object? issuedBy = null,Object? title = null,Object? detail = freezed,Object? status = null,Object? issuedAt = freezed,Object? doneAt = freezed,Object? decidedAt = freezed,}) {
  return _then(_ConsequenceView(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,dynamicId: freezed == dynamicId ? _self.dynamicId : dynamicId // ignore: cast_nullable_to_non_nullable
as String?,issuedBy: null == issuedBy ? _self.issuedBy : issuedBy // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,detail: freezed == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,issuedAt: freezed == issuedAt ? _self.issuedAt : issuedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,doneAt: freezed == doneAt ? _self.doneAt : doneAt // ignore: cast_nullable_to_non_nullable
as DateTime?,decidedAt: freezed == decidedAt ? _self.decidedAt : decidedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
