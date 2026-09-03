// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RuleView {

 String get id; String get title; String? get body; String get group; String get createdBy;/// `proposed | active | archived`.
 String get status; int get position; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of RuleView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RuleViewCopyWith<RuleView> get copyWith => _$RuleViewCopyWithImpl<RuleView>(this as RuleView, _$identity);

  /// Serializes this RuleView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RuleView&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.group, group) || other.group == group)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.status, status) || other.status == status)&&(identical(other.position, position) || other.position == position)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,body,group,createdBy,status,position,createdAt,updatedAt);

@override
String toString() {
  return 'RuleView(id: $id, title: $title, body: $body, group: $group, createdBy: $createdBy, status: $status, position: $position, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $RuleViewCopyWith<$Res>  {
  factory $RuleViewCopyWith(RuleView value, $Res Function(RuleView) _then) = _$RuleViewCopyWithImpl;
@useResult
$Res call({
 String id, String title, String? body, String group, String createdBy, String status, int position, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$RuleViewCopyWithImpl<$Res>
    implements $RuleViewCopyWith<$Res> {
  _$RuleViewCopyWithImpl(this._self, this._then);

  final RuleView _self;
  final $Res Function(RuleView) _then;

/// Create a copy of RuleView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? body = freezed,Object? group = null,Object? createdBy = null,Object? status = null,Object? position = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,group: null == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as String,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [RuleView].
extension RuleViewPatterns on RuleView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RuleView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RuleView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RuleView value)  $default,){
final _that = this;
switch (_that) {
case _RuleView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RuleView value)?  $default,){
final _that = this;
switch (_that) {
case _RuleView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String? body,  String group,  String createdBy,  String status,  int position,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RuleView() when $default != null:
return $default(_that.id,_that.title,_that.body,_that.group,_that.createdBy,_that.status,_that.position,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String? body,  String group,  String createdBy,  String status,  int position,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _RuleView():
return $default(_that.id,_that.title,_that.body,_that.group,_that.createdBy,_that.status,_that.position,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String? body,  String group,  String createdBy,  String status,  int position,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _RuleView() when $default != null:
return $default(_that.id,_that.title,_that.body,_that.group,_that.createdBy,_that.status,_that.position,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RuleView extends RuleView {
  const _RuleView({required this.id, required this.title, this.body, this.group = 'other', required this.createdBy, required this.status, this.position = 0, this.createdAt, this.updatedAt}): super._();
  factory _RuleView.fromJson(Map<String, dynamic> json) => _$RuleViewFromJson(json);

@override final  String id;
@override final  String title;
@override final  String? body;
@override@JsonKey() final  String group;
@override final  String createdBy;
/// `proposed | active | archived`.
@override final  String status;
@override@JsonKey() final  int position;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of RuleView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RuleViewCopyWith<_RuleView> get copyWith => __$RuleViewCopyWithImpl<_RuleView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RuleViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RuleView&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.group, group) || other.group == group)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.status, status) || other.status == status)&&(identical(other.position, position) || other.position == position)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,body,group,createdBy,status,position,createdAt,updatedAt);

@override
String toString() {
  return 'RuleView(id: $id, title: $title, body: $body, group: $group, createdBy: $createdBy, status: $status, position: $position, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$RuleViewCopyWith<$Res> implements $RuleViewCopyWith<$Res> {
  factory _$RuleViewCopyWith(_RuleView value, $Res Function(_RuleView) _then) = __$RuleViewCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String? body, String group, String createdBy, String status, int position, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$RuleViewCopyWithImpl<$Res>
    implements _$RuleViewCopyWith<$Res> {
  __$RuleViewCopyWithImpl(this._self, this._then);

  final _RuleView _self;
  final $Res Function(_RuleView) _then;

/// Create a copy of RuleView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? body = freezed,Object? group = null,Object? createdBy = null,Object? status = null,Object? position = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_RuleView(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,group: null == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as String,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$NewRule {

 String get title; String? get body; String get group;
/// Create a copy of NewRule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NewRuleCopyWith<NewRule> get copyWith => _$NewRuleCopyWithImpl<NewRule>(this as NewRule, _$identity);

  /// Serializes this NewRule to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NewRule&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.group, group) || other.group == group));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,body,group);

@override
String toString() {
  return 'NewRule(title: $title, body: $body, group: $group)';
}


}

/// @nodoc
abstract mixin class $NewRuleCopyWith<$Res>  {
  factory $NewRuleCopyWith(NewRule value, $Res Function(NewRule) _then) = _$NewRuleCopyWithImpl;
@useResult
$Res call({
 String title, String? body, String group
});




}
/// @nodoc
class _$NewRuleCopyWithImpl<$Res>
    implements $NewRuleCopyWith<$Res> {
  _$NewRuleCopyWithImpl(this._self, this._then);

  final NewRule _self;
  final $Res Function(NewRule) _then;

/// Create a copy of NewRule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? body = freezed,Object? group = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,group: null == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [NewRule].
extension NewRulePatterns on NewRule {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NewRule value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NewRule() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NewRule value)  $default,){
final _that = this;
switch (_that) {
case _NewRule():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NewRule value)?  $default,){
final _that = this;
switch (_that) {
case _NewRule() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String? body,  String group)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NewRule() when $default != null:
return $default(_that.title,_that.body,_that.group);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String? body,  String group)  $default,) {final _that = this;
switch (_that) {
case _NewRule():
return $default(_that.title,_that.body,_that.group);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String? body,  String group)?  $default,) {final _that = this;
switch (_that) {
case _NewRule() when $default != null:
return $default(_that.title,_that.body,_that.group);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NewRule implements NewRule {
  const _NewRule({required this.title, this.body, this.group = 'other'});
  factory _NewRule.fromJson(Map<String, dynamic> json) => _$NewRuleFromJson(json);

@override final  String title;
@override final  String? body;
@override@JsonKey() final  String group;

/// Create a copy of NewRule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NewRuleCopyWith<_NewRule> get copyWith => __$NewRuleCopyWithImpl<_NewRule>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NewRuleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NewRule&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.group, group) || other.group == group));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,body,group);

@override
String toString() {
  return 'NewRule(title: $title, body: $body, group: $group)';
}


}

/// @nodoc
abstract mixin class _$NewRuleCopyWith<$Res> implements $NewRuleCopyWith<$Res> {
  factory _$NewRuleCopyWith(_NewRule value, $Res Function(_NewRule) _then) = __$NewRuleCopyWithImpl;
@override @useResult
$Res call({
 String title, String? body, String group
});




}
/// @nodoc
class __$NewRuleCopyWithImpl<$Res>
    implements _$NewRuleCopyWith<$Res> {
  __$NewRuleCopyWithImpl(this._self, this._then);

  final _NewRule _self;
  final $Res Function(_NewRule) _then;

/// Create a copy of NewRule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? body = freezed,Object? group = null,}) {
  return _then(_NewRule(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,group: null == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$RuleEdit {

 String? get title; String? get body; String? get group; int? get position;
/// Create a copy of RuleEdit
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RuleEditCopyWith<RuleEdit> get copyWith => _$RuleEditCopyWithImpl<RuleEdit>(this as RuleEdit, _$identity);

  /// Serializes this RuleEdit to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RuleEdit&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.group, group) || other.group == group)&&(identical(other.position, position) || other.position == position));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,body,group,position);

@override
String toString() {
  return 'RuleEdit(title: $title, body: $body, group: $group, position: $position)';
}


}

/// @nodoc
abstract mixin class $RuleEditCopyWith<$Res>  {
  factory $RuleEditCopyWith(RuleEdit value, $Res Function(RuleEdit) _then) = _$RuleEditCopyWithImpl;
@useResult
$Res call({
 String? title, String? body, String? group, int? position
});




}
/// @nodoc
class _$RuleEditCopyWithImpl<$Res>
    implements $RuleEditCopyWith<$Res> {
  _$RuleEditCopyWithImpl(this._self, this._then);

  final RuleEdit _self;
  final $Res Function(RuleEdit) _then;

/// Create a copy of RuleEdit
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = freezed,Object? body = freezed,Object? group = freezed,Object? position = freezed,}) {
  return _then(_self.copyWith(
title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,group: freezed == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as String?,position: freezed == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [RuleEdit].
extension RuleEditPatterns on RuleEdit {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RuleEdit value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RuleEdit() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RuleEdit value)  $default,){
final _that = this;
switch (_that) {
case _RuleEdit():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RuleEdit value)?  $default,){
final _that = this;
switch (_that) {
case _RuleEdit() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? title,  String? body,  String? group,  int? position)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RuleEdit() when $default != null:
return $default(_that.title,_that.body,_that.group,_that.position);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? title,  String? body,  String? group,  int? position)  $default,) {final _that = this;
switch (_that) {
case _RuleEdit():
return $default(_that.title,_that.body,_that.group,_that.position);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? title,  String? body,  String? group,  int? position)?  $default,) {final _that = this;
switch (_that) {
case _RuleEdit() when $default != null:
return $default(_that.title,_that.body,_that.group,_that.position);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RuleEdit implements RuleEdit {
  const _RuleEdit({this.title, this.body, this.group, this.position});
  factory _RuleEdit.fromJson(Map<String, dynamic> json) => _$RuleEditFromJson(json);

@override final  String? title;
@override final  String? body;
@override final  String? group;
@override final  int? position;

/// Create a copy of RuleEdit
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RuleEditCopyWith<_RuleEdit> get copyWith => __$RuleEditCopyWithImpl<_RuleEdit>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RuleEditToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RuleEdit&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.group, group) || other.group == group)&&(identical(other.position, position) || other.position == position));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,body,group,position);

@override
String toString() {
  return 'RuleEdit(title: $title, body: $body, group: $group, position: $position)';
}


}

/// @nodoc
abstract mixin class _$RuleEditCopyWith<$Res> implements $RuleEditCopyWith<$Res> {
  factory _$RuleEditCopyWith(_RuleEdit value, $Res Function(_RuleEdit) _then) = __$RuleEditCopyWithImpl;
@override @useResult
$Res call({
 String? title, String? body, String? group, int? position
});




}
/// @nodoc
class __$RuleEditCopyWithImpl<$Res>
    implements _$RuleEditCopyWith<$Res> {
  __$RuleEditCopyWithImpl(this._self, this._then);

  final _RuleEdit _self;
  final $Res Function(_RuleEdit) _then;

/// Create a copy of RuleEdit
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = freezed,Object? body = freezed,Object? group = freezed,Object? position = freezed,}) {
  return _then(_RuleEdit(
title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,group: freezed == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as String?,position: freezed == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
