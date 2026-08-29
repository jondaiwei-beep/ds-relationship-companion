// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attention_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AttentionItem {

 String get occurrenceId; String get title; String get state;/// The person who acted. A response is addressed to a person, not a task.
 String? get actorDisplayName; DateTime? get occurredAt; int get priority;
/// Create a copy of AttentionItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttentionItemCopyWith<AttentionItem> get copyWith => _$AttentionItemCopyWithImpl<AttentionItem>(this as AttentionItem, _$identity);

  /// Serializes this AttentionItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AttentionItem&&(identical(other.occurrenceId, occurrenceId) || other.occurrenceId == occurrenceId)&&(identical(other.title, title) || other.title == title)&&(identical(other.state, state) || other.state == state)&&(identical(other.actorDisplayName, actorDisplayName) || other.actorDisplayName == actorDisplayName)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&(identical(other.priority, priority) || other.priority == priority));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,occurrenceId,title,state,actorDisplayName,occurredAt,priority);

@override
String toString() {
  return 'AttentionItem(occurrenceId: $occurrenceId, title: $title, state: $state, actorDisplayName: $actorDisplayName, occurredAt: $occurredAt, priority: $priority)';
}


}

/// @nodoc
abstract mixin class $AttentionItemCopyWith<$Res>  {
  factory $AttentionItemCopyWith(AttentionItem value, $Res Function(AttentionItem) _then) = _$AttentionItemCopyWithImpl;
@useResult
$Res call({
 String occurrenceId, String title, String state, String? actorDisplayName, DateTime? occurredAt, int priority
});




}
/// @nodoc
class _$AttentionItemCopyWithImpl<$Res>
    implements $AttentionItemCopyWith<$Res> {
  _$AttentionItemCopyWithImpl(this._self, this._then);

  final AttentionItem _self;
  final $Res Function(AttentionItem) _then;

/// Create a copy of AttentionItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? occurrenceId = null,Object? title = null,Object? state = null,Object? actorDisplayName = freezed,Object? occurredAt = freezed,Object? priority = null,}) {
  return _then(_self.copyWith(
occurrenceId: null == occurrenceId ? _self.occurrenceId : occurrenceId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,actorDisplayName: freezed == actorDisplayName ? _self.actorDisplayName : actorDisplayName // ignore: cast_nullable_to_non_nullable
as String?,occurredAt: freezed == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AttentionItem].
extension AttentionItemPatterns on AttentionItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AttentionItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AttentionItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AttentionItem value)  $default,){
final _that = this;
switch (_that) {
case _AttentionItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AttentionItem value)?  $default,){
final _that = this;
switch (_that) {
case _AttentionItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String occurrenceId,  String title,  String state,  String? actorDisplayName,  DateTime? occurredAt,  int priority)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AttentionItem() when $default != null:
return $default(_that.occurrenceId,_that.title,_that.state,_that.actorDisplayName,_that.occurredAt,_that.priority);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String occurrenceId,  String title,  String state,  String? actorDisplayName,  DateTime? occurredAt,  int priority)  $default,) {final _that = this;
switch (_that) {
case _AttentionItem():
return $default(_that.occurrenceId,_that.title,_that.state,_that.actorDisplayName,_that.occurredAt,_that.priority);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String occurrenceId,  String title,  String state,  String? actorDisplayName,  DateTime? occurredAt,  int priority)?  $default,) {final _that = this;
switch (_that) {
case _AttentionItem() when $default != null:
return $default(_that.occurrenceId,_that.title,_that.state,_that.actorDisplayName,_that.occurredAt,_that.priority);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AttentionItem implements AttentionItem {
  const _AttentionItem({required this.occurrenceId, required this.title, required this.state, this.actorDisplayName, this.occurredAt, required this.priority});
  factory _AttentionItem.fromJson(Map<String, dynamic> json) => _$AttentionItemFromJson(json);

@override final  String occurrenceId;
@override final  String title;
@override final  String state;
/// The person who acted. A response is addressed to a person, not a task.
@override final  String? actorDisplayName;
@override final  DateTime? occurredAt;
@override final  int priority;

/// Create a copy of AttentionItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttentionItemCopyWith<_AttentionItem> get copyWith => __$AttentionItemCopyWithImpl<_AttentionItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AttentionItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AttentionItem&&(identical(other.occurrenceId, occurrenceId) || other.occurrenceId == occurrenceId)&&(identical(other.title, title) || other.title == title)&&(identical(other.state, state) || other.state == state)&&(identical(other.actorDisplayName, actorDisplayName) || other.actorDisplayName == actorDisplayName)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&(identical(other.priority, priority) || other.priority == priority));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,occurrenceId,title,state,actorDisplayName,occurredAt,priority);

@override
String toString() {
  return 'AttentionItem(occurrenceId: $occurrenceId, title: $title, state: $state, actorDisplayName: $actorDisplayName, occurredAt: $occurredAt, priority: $priority)';
}


}

/// @nodoc
abstract mixin class _$AttentionItemCopyWith<$Res> implements $AttentionItemCopyWith<$Res> {
  factory _$AttentionItemCopyWith(_AttentionItem value, $Res Function(_AttentionItem) _then) = __$AttentionItemCopyWithImpl;
@override @useResult
$Res call({
 String occurrenceId, String title, String state, String? actorDisplayName, DateTime? occurredAt, int priority
});




}
/// @nodoc
class __$AttentionItemCopyWithImpl<$Res>
    implements _$AttentionItemCopyWith<$Res> {
  __$AttentionItemCopyWithImpl(this._self, this._then);

  final _AttentionItem _self;
  final $Res Function(_AttentionItem) _then;

/// Create a copy of AttentionItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? occurrenceId = null,Object? title = null,Object? state = null,Object? actorDisplayName = freezed,Object? occurredAt = freezed,Object? priority = null,}) {
  return _then(_AttentionItem(
occurrenceId: null == occurrenceId ? _self.occurrenceId : occurrenceId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,actorDisplayName: freezed == actorDisplayName ? _self.actorDisplayName : actorDisplayName // ignore: cast_nullable_to_non_nullable
as String?,occurredAt: freezed == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$AttentionView {

 List<AttentionItem> get items; int get needsResponseCount; int get needsReviewCount;
/// Create a copy of AttentionView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttentionViewCopyWith<AttentionView> get copyWith => _$AttentionViewCopyWithImpl<AttentionView>(this as AttentionView, _$identity);

  /// Serializes this AttentionView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AttentionView&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.needsResponseCount, needsResponseCount) || other.needsResponseCount == needsResponseCount)&&(identical(other.needsReviewCount, needsReviewCount) || other.needsReviewCount == needsReviewCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),needsResponseCount,needsReviewCount);

@override
String toString() {
  return 'AttentionView(items: $items, needsResponseCount: $needsResponseCount, needsReviewCount: $needsReviewCount)';
}


}

/// @nodoc
abstract mixin class $AttentionViewCopyWith<$Res>  {
  factory $AttentionViewCopyWith(AttentionView value, $Res Function(AttentionView) _then) = _$AttentionViewCopyWithImpl;
@useResult
$Res call({
 List<AttentionItem> items, int needsResponseCount, int needsReviewCount
});




}
/// @nodoc
class _$AttentionViewCopyWithImpl<$Res>
    implements $AttentionViewCopyWith<$Res> {
  _$AttentionViewCopyWithImpl(this._self, this._then);

  final AttentionView _self;
  final $Res Function(AttentionView) _then;

/// Create a copy of AttentionView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? needsResponseCount = null,Object? needsReviewCount = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<AttentionItem>,needsResponseCount: null == needsResponseCount ? _self.needsResponseCount : needsResponseCount // ignore: cast_nullable_to_non_nullable
as int,needsReviewCount: null == needsReviewCount ? _self.needsReviewCount : needsReviewCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AttentionView].
extension AttentionViewPatterns on AttentionView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AttentionView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AttentionView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AttentionView value)  $default,){
final _that = this;
switch (_that) {
case _AttentionView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AttentionView value)?  $default,){
final _that = this;
switch (_that) {
case _AttentionView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<AttentionItem> items,  int needsResponseCount,  int needsReviewCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AttentionView() when $default != null:
return $default(_that.items,_that.needsResponseCount,_that.needsReviewCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<AttentionItem> items,  int needsResponseCount,  int needsReviewCount)  $default,) {final _that = this;
switch (_that) {
case _AttentionView():
return $default(_that.items,_that.needsResponseCount,_that.needsReviewCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<AttentionItem> items,  int needsResponseCount,  int needsReviewCount)?  $default,) {final _that = this;
switch (_that) {
case _AttentionView() when $default != null:
return $default(_that.items,_that.needsResponseCount,_that.needsReviewCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AttentionView implements AttentionView {
  const _AttentionView({final  List<AttentionItem> items = const <AttentionItem>[], this.needsResponseCount = 0, this.needsReviewCount = 0}): _items = items;
  factory _AttentionView.fromJson(Map<String, dynamic> json) => _$AttentionViewFromJson(json);

 final  List<AttentionItem> _items;
@override@JsonKey() List<AttentionItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey() final  int needsResponseCount;
@override@JsonKey() final  int needsReviewCount;

/// Create a copy of AttentionView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttentionViewCopyWith<_AttentionView> get copyWith => __$AttentionViewCopyWithImpl<_AttentionView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AttentionViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AttentionView&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.needsResponseCount, needsResponseCount) || other.needsResponseCount == needsResponseCount)&&(identical(other.needsReviewCount, needsReviewCount) || other.needsReviewCount == needsReviewCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),needsResponseCount,needsReviewCount);

@override
String toString() {
  return 'AttentionView(items: $items, needsResponseCount: $needsResponseCount, needsReviewCount: $needsReviewCount)';
}


}

/// @nodoc
abstract mixin class _$AttentionViewCopyWith<$Res> implements $AttentionViewCopyWith<$Res> {
  factory _$AttentionViewCopyWith(_AttentionView value, $Res Function(_AttentionView) _then) = __$AttentionViewCopyWithImpl;
@override @useResult
$Res call({
 List<AttentionItem> items, int needsResponseCount, int needsReviewCount
});




}
/// @nodoc
class __$AttentionViewCopyWithImpl<$Res>
    implements _$AttentionViewCopyWith<$Res> {
  __$AttentionViewCopyWithImpl(this._self, this._then);

  final _AttentionView _self;
  final $Res Function(_AttentionView) _then;

/// Create a copy of AttentionView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? needsResponseCount = null,Object? needsReviewCount = null,}) {
  return _then(_AttentionView(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<AttentionItem>,needsResponseCount: null == needsResponseCount ? _self.needsResponseCount : needsResponseCount // ignore: cast_nullable_to_non_nullable
as int,needsReviewCount: null == needsReviewCount ? _self.needsReviewCount : needsReviewCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
