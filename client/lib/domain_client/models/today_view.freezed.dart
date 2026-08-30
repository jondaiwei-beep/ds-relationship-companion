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
mixin _$TodayItem {

 String get occurrenceId; String get title; String? get purpose;/// `TASK` or `RITUAL`, stated by the server (REQ-STATE-001). Defaulted so
/// a client built against an older server degrades to the common kind
/// rather than failing to parse the day.
 String get kind; String get state;/// What this person may do with this item right now, stated by the server.
/// REQ-STATE-001 names entitlement explicitly: the screen used to offer
/// all four actions unconditionally, including on items whose only
/// permitted action was to withdraw an open adjustment.
 List<String> get allowedActions; DateTime? get dueAt;/// Who set this. Direction comes from a person, not from the app.
 String? get fromDisplayName;
/// Create a copy of TodayItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TodayItemCopyWith<TodayItem> get copyWith => _$TodayItemCopyWithImpl<TodayItem>(this as TodayItem, _$identity);

  /// Serializes this TodayItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TodayItem&&(identical(other.occurrenceId, occurrenceId) || other.occurrenceId == occurrenceId)&&(identical(other.title, title) || other.title == title)&&(identical(other.purpose, purpose) || other.purpose == purpose)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.state, state) || other.state == state)&&const DeepCollectionEquality().equals(other.allowedActions, allowedActions)&&(identical(other.dueAt, dueAt) || other.dueAt == dueAt)&&(identical(other.fromDisplayName, fromDisplayName) || other.fromDisplayName == fromDisplayName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,occurrenceId,title,purpose,kind,state,const DeepCollectionEquality().hash(allowedActions),dueAt,fromDisplayName);

@override
String toString() {
  return 'TodayItem(occurrenceId: $occurrenceId, title: $title, purpose: $purpose, kind: $kind, state: $state, allowedActions: $allowedActions, dueAt: $dueAt, fromDisplayName: $fromDisplayName)';
}


}

/// @nodoc
abstract mixin class $TodayItemCopyWith<$Res>  {
  factory $TodayItemCopyWith(TodayItem value, $Res Function(TodayItem) _then) = _$TodayItemCopyWithImpl;
@useResult
$Res call({
 String occurrenceId, String title, String? purpose, String kind, String state, List<String> allowedActions, DateTime? dueAt, String? fromDisplayName
});




}
/// @nodoc
class _$TodayItemCopyWithImpl<$Res>
    implements $TodayItemCopyWith<$Res> {
  _$TodayItemCopyWithImpl(this._self, this._then);

  final TodayItem _self;
  final $Res Function(TodayItem) _then;

/// Create a copy of TodayItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? occurrenceId = null,Object? title = null,Object? purpose = freezed,Object? kind = null,Object? state = null,Object? allowedActions = null,Object? dueAt = freezed,Object? fromDisplayName = freezed,}) {
  return _then(_self.copyWith(
occurrenceId: null == occurrenceId ? _self.occurrenceId : occurrenceId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,purpose: freezed == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as String?,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,allowedActions: null == allowedActions ? _self.allowedActions : allowedActions // ignore: cast_nullable_to_non_nullable
as List<String>,dueAt: freezed == dueAt ? _self.dueAt : dueAt // ignore: cast_nullable_to_non_nullable
as DateTime?,fromDisplayName: freezed == fromDisplayName ? _self.fromDisplayName : fromDisplayName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TodayItem].
extension TodayItemPatterns on TodayItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TodayItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TodayItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TodayItem value)  $default,){
final _that = this;
switch (_that) {
case _TodayItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TodayItem value)?  $default,){
final _that = this;
switch (_that) {
case _TodayItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String occurrenceId,  String title,  String? purpose,  String kind,  String state,  List<String> allowedActions,  DateTime? dueAt,  String? fromDisplayName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TodayItem() when $default != null:
return $default(_that.occurrenceId,_that.title,_that.purpose,_that.kind,_that.state,_that.allowedActions,_that.dueAt,_that.fromDisplayName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String occurrenceId,  String title,  String? purpose,  String kind,  String state,  List<String> allowedActions,  DateTime? dueAt,  String? fromDisplayName)  $default,) {final _that = this;
switch (_that) {
case _TodayItem():
return $default(_that.occurrenceId,_that.title,_that.purpose,_that.kind,_that.state,_that.allowedActions,_that.dueAt,_that.fromDisplayName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String occurrenceId,  String title,  String? purpose,  String kind,  String state,  List<String> allowedActions,  DateTime? dueAt,  String? fromDisplayName)?  $default,) {final _that = this;
switch (_that) {
case _TodayItem() when $default != null:
return $default(_that.occurrenceId,_that.title,_that.purpose,_that.kind,_that.state,_that.allowedActions,_that.dueAt,_that.fromDisplayName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TodayItem implements TodayItem {
  const _TodayItem({required this.occurrenceId, required this.title, this.purpose, this.kind = 'TASK', required this.state, final  List<String> allowedActions = const <String>[], this.dueAt, this.fromDisplayName}): _allowedActions = allowedActions;
  factory _TodayItem.fromJson(Map<String, dynamic> json) => _$TodayItemFromJson(json);

@override final  String occurrenceId;
@override final  String title;
@override final  String? purpose;
/// `TASK` or `RITUAL`, stated by the server (REQ-STATE-001). Defaulted so
/// a client built against an older server degrades to the common kind
/// rather than failing to parse the day.
@override@JsonKey() final  String kind;
@override final  String state;
/// What this person may do with this item right now, stated by the server.
/// REQ-STATE-001 names entitlement explicitly: the screen used to offer
/// all four actions unconditionally, including on items whose only
/// permitted action was to withdraw an open adjustment.
 final  List<String> _allowedActions;
/// What this person may do with this item right now, stated by the server.
/// REQ-STATE-001 names entitlement explicitly: the screen used to offer
/// all four actions unconditionally, including on items whose only
/// permitted action was to withdraw an open adjustment.
@override@JsonKey() List<String> get allowedActions {
  if (_allowedActions is EqualUnmodifiableListView) return _allowedActions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allowedActions);
}

@override final  DateTime? dueAt;
/// Who set this. Direction comes from a person, not from the app.
@override final  String? fromDisplayName;

/// Create a copy of TodayItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TodayItemCopyWith<_TodayItem> get copyWith => __$TodayItemCopyWithImpl<_TodayItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TodayItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TodayItem&&(identical(other.occurrenceId, occurrenceId) || other.occurrenceId == occurrenceId)&&(identical(other.title, title) || other.title == title)&&(identical(other.purpose, purpose) || other.purpose == purpose)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.state, state) || other.state == state)&&const DeepCollectionEquality().equals(other._allowedActions, _allowedActions)&&(identical(other.dueAt, dueAt) || other.dueAt == dueAt)&&(identical(other.fromDisplayName, fromDisplayName) || other.fromDisplayName == fromDisplayName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,occurrenceId,title,purpose,kind,state,const DeepCollectionEquality().hash(_allowedActions),dueAt,fromDisplayName);

@override
String toString() {
  return 'TodayItem(occurrenceId: $occurrenceId, title: $title, purpose: $purpose, kind: $kind, state: $state, allowedActions: $allowedActions, dueAt: $dueAt, fromDisplayName: $fromDisplayName)';
}


}

/// @nodoc
abstract mixin class _$TodayItemCopyWith<$Res> implements $TodayItemCopyWith<$Res> {
  factory _$TodayItemCopyWith(_TodayItem value, $Res Function(_TodayItem) _then) = __$TodayItemCopyWithImpl;
@override @useResult
$Res call({
 String occurrenceId, String title, String? purpose, String kind, String state, List<String> allowedActions, DateTime? dueAt, String? fromDisplayName
});




}
/// @nodoc
class __$TodayItemCopyWithImpl<$Res>
    implements _$TodayItemCopyWith<$Res> {
  __$TodayItemCopyWithImpl(this._self, this._then);

  final _TodayItem _self;
  final $Res Function(_TodayItem) _then;

/// Create a copy of TodayItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? occurrenceId = null,Object? title = null,Object? purpose = freezed,Object? kind = null,Object? state = null,Object? allowedActions = null,Object? dueAt = freezed,Object? fromDisplayName = freezed,}) {
  return _then(_TodayItem(
occurrenceId: null == occurrenceId ? _self.occurrenceId : occurrenceId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,purpose: freezed == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as String?,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,allowedActions: null == allowedActions ? _self._allowedActions : allowedActions // ignore: cast_nullable_to_non_nullable
as List<String>,dueAt: freezed == dueAt ? _self.dueAt : dueAt // ignore: cast_nullable_to_non_nullable
as DateTime?,fromDisplayName: freezed == fromDisplayName ? _self.fromDisplayName : fromDisplayName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$RecentResponse {

 String get occurrenceId; String get title; String get type; String get text; DateTime get sentAt; String? get senderDisplayName;
/// Create a copy of RecentResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecentResponseCopyWith<RecentResponse> get copyWith => _$RecentResponseCopyWithImpl<RecentResponse>(this as RecentResponse, _$identity);

  /// Serializes this RecentResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecentResponse&&(identical(other.occurrenceId, occurrenceId) || other.occurrenceId == occurrenceId)&&(identical(other.title, title) || other.title == title)&&(identical(other.type, type) || other.type == type)&&(identical(other.text, text) || other.text == text)&&(identical(other.sentAt, sentAt) || other.sentAt == sentAt)&&(identical(other.senderDisplayName, senderDisplayName) || other.senderDisplayName == senderDisplayName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,occurrenceId,title,type,text,sentAt,senderDisplayName);

@override
String toString() {
  return 'RecentResponse(occurrenceId: $occurrenceId, title: $title, type: $type, text: $text, sentAt: $sentAt, senderDisplayName: $senderDisplayName)';
}


}

/// @nodoc
abstract mixin class $RecentResponseCopyWith<$Res>  {
  factory $RecentResponseCopyWith(RecentResponse value, $Res Function(RecentResponse) _then) = _$RecentResponseCopyWithImpl;
@useResult
$Res call({
 String occurrenceId, String title, String type, String text, DateTime sentAt, String? senderDisplayName
});




}
/// @nodoc
class _$RecentResponseCopyWithImpl<$Res>
    implements $RecentResponseCopyWith<$Res> {
  _$RecentResponseCopyWithImpl(this._self, this._then);

  final RecentResponse _self;
  final $Res Function(RecentResponse) _then;

/// Create a copy of RecentResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? occurrenceId = null,Object? title = null,Object? type = null,Object? text = null,Object? sentAt = null,Object? senderDisplayName = freezed,}) {
  return _then(_self.copyWith(
occurrenceId: null == occurrenceId ? _self.occurrenceId : occurrenceId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,sentAt: null == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as DateTime,senderDisplayName: freezed == senderDisplayName ? _self.senderDisplayName : senderDisplayName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RecentResponse].
extension RecentResponsePatterns on RecentResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecentResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecentResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecentResponse value)  $default,){
final _that = this;
switch (_that) {
case _RecentResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecentResponse value)?  $default,){
final _that = this;
switch (_that) {
case _RecentResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String occurrenceId,  String title,  String type,  String text,  DateTime sentAt,  String? senderDisplayName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecentResponse() when $default != null:
return $default(_that.occurrenceId,_that.title,_that.type,_that.text,_that.sentAt,_that.senderDisplayName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String occurrenceId,  String title,  String type,  String text,  DateTime sentAt,  String? senderDisplayName)  $default,) {final _that = this;
switch (_that) {
case _RecentResponse():
return $default(_that.occurrenceId,_that.title,_that.type,_that.text,_that.sentAt,_that.senderDisplayName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String occurrenceId,  String title,  String type,  String text,  DateTime sentAt,  String? senderDisplayName)?  $default,) {final _that = this;
switch (_that) {
case _RecentResponse() when $default != null:
return $default(_that.occurrenceId,_that.title,_that.type,_that.text,_that.sentAt,_that.senderDisplayName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecentResponse implements RecentResponse {
  const _RecentResponse({required this.occurrenceId, required this.title, required this.type, required this.text, required this.sentAt, this.senderDisplayName});
  factory _RecentResponse.fromJson(Map<String, dynamic> json) => _$RecentResponseFromJson(json);

@override final  String occurrenceId;
@override final  String title;
@override final  String type;
@override final  String text;
@override final  DateTime sentAt;
@override final  String? senderDisplayName;

/// Create a copy of RecentResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecentResponseCopyWith<_RecentResponse> get copyWith => __$RecentResponseCopyWithImpl<_RecentResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecentResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecentResponse&&(identical(other.occurrenceId, occurrenceId) || other.occurrenceId == occurrenceId)&&(identical(other.title, title) || other.title == title)&&(identical(other.type, type) || other.type == type)&&(identical(other.text, text) || other.text == text)&&(identical(other.sentAt, sentAt) || other.sentAt == sentAt)&&(identical(other.senderDisplayName, senderDisplayName) || other.senderDisplayName == senderDisplayName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,occurrenceId,title,type,text,sentAt,senderDisplayName);

@override
String toString() {
  return 'RecentResponse(occurrenceId: $occurrenceId, title: $title, type: $type, text: $text, sentAt: $sentAt, senderDisplayName: $senderDisplayName)';
}


}

/// @nodoc
abstract mixin class _$RecentResponseCopyWith<$Res> implements $RecentResponseCopyWith<$Res> {
  factory _$RecentResponseCopyWith(_RecentResponse value, $Res Function(_RecentResponse) _then) = __$RecentResponseCopyWithImpl;
@override @useResult
$Res call({
 String occurrenceId, String title, String type, String text, DateTime sentAt, String? senderDisplayName
});




}
/// @nodoc
class __$RecentResponseCopyWithImpl<$Res>
    implements _$RecentResponseCopyWith<$Res> {
  __$RecentResponseCopyWithImpl(this._self, this._then);

  final _RecentResponse _self;
  final $Res Function(_RecentResponse) _then;

/// Create a copy of RecentResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? occurrenceId = null,Object? title = null,Object? type = null,Object? text = null,Object? sentAt = null,Object? senderDisplayName = freezed,}) {
  return _then(_RecentResponse(
occurrenceId: null == occurrenceId ? _self.occurrenceId : occurrenceId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,sentAt: null == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as DateTime,senderDisplayName: freezed == senderDisplayName ? _self.senderDisplayName : senderDisplayName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$TodayView {

/// My role in THIS dynamic (Notion 03 §1 — role belongs to Membership).
 String get roleContext;/// How many things are waiting on my human response, stated by the
/// server. Today shows the direction-giving face when this is non-zero.
 int get needsMyResponseCount;/// The relationship day this list belongs to, resolved by the server in
/// the Dynamic's own timezone. The client never derives it from the
/// device clock.
 DateTime? get relationshipDay;/// Minutes past midnight at which the relationship day rolls over, in the
/// Dynamic's own timezone. The screen used to state a hard-coded 2:00 AM,
/// which was wrong for any Dynamic that chose another boundary.
 int get dayBoundaryMinutes;/// When the server last confirmed this list. Offline shows the last
/// confirmed list with this timestamp rather than implying it is current.
 DateTime? get lastConfirmedAt;/// Total actionable items for the day, stated by the server.
 int get totalCount;/// At most three, in server order: the first carries editorial emphasis,
/// the next two are timeline rows. Never re-sorted on the client.
 List<TodayItem> get priorityItems;/// Everything else for the day, behind one count-bearing disclosure.
 List<TodayItem> get laterItems; List<TodayItem> get awaitingResponse; RecentResponse? get recentResponse;
/// Create a copy of TodayView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TodayViewCopyWith<TodayView> get copyWith => _$TodayViewCopyWithImpl<TodayView>(this as TodayView, _$identity);

  /// Serializes this TodayView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TodayView&&(identical(other.roleContext, roleContext) || other.roleContext == roleContext)&&(identical(other.needsMyResponseCount, needsMyResponseCount) || other.needsMyResponseCount == needsMyResponseCount)&&(identical(other.relationshipDay, relationshipDay) || other.relationshipDay == relationshipDay)&&(identical(other.dayBoundaryMinutes, dayBoundaryMinutes) || other.dayBoundaryMinutes == dayBoundaryMinutes)&&(identical(other.lastConfirmedAt, lastConfirmedAt) || other.lastConfirmedAt == lastConfirmedAt)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&const DeepCollectionEquality().equals(other.priorityItems, priorityItems)&&const DeepCollectionEquality().equals(other.laterItems, laterItems)&&const DeepCollectionEquality().equals(other.awaitingResponse, awaitingResponse)&&(identical(other.recentResponse, recentResponse) || other.recentResponse == recentResponse));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,roleContext,needsMyResponseCount,relationshipDay,dayBoundaryMinutes,lastConfirmedAt,totalCount,const DeepCollectionEquality().hash(priorityItems),const DeepCollectionEquality().hash(laterItems),const DeepCollectionEquality().hash(awaitingResponse),recentResponse);

@override
String toString() {
  return 'TodayView(roleContext: $roleContext, needsMyResponseCount: $needsMyResponseCount, relationshipDay: $relationshipDay, dayBoundaryMinutes: $dayBoundaryMinutes, lastConfirmedAt: $lastConfirmedAt, totalCount: $totalCount, priorityItems: $priorityItems, laterItems: $laterItems, awaitingResponse: $awaitingResponse, recentResponse: $recentResponse)';
}


}

/// @nodoc
abstract mixin class $TodayViewCopyWith<$Res>  {
  factory $TodayViewCopyWith(TodayView value, $Res Function(TodayView) _then) = _$TodayViewCopyWithImpl;
@useResult
$Res call({
 String roleContext, int needsMyResponseCount, DateTime? relationshipDay, int dayBoundaryMinutes, DateTime? lastConfirmedAt, int totalCount, List<TodayItem> priorityItems, List<TodayItem> laterItems, List<TodayItem> awaitingResponse, RecentResponse? recentResponse
});


$RecentResponseCopyWith<$Res>? get recentResponse;

}
/// @nodoc
class _$TodayViewCopyWithImpl<$Res>
    implements $TodayViewCopyWith<$Res> {
  _$TodayViewCopyWithImpl(this._self, this._then);

  final TodayView _self;
  final $Res Function(TodayView) _then;

/// Create a copy of TodayView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? roleContext = null,Object? needsMyResponseCount = null,Object? relationshipDay = freezed,Object? dayBoundaryMinutes = null,Object? lastConfirmedAt = freezed,Object? totalCount = null,Object? priorityItems = null,Object? laterItems = null,Object? awaitingResponse = null,Object? recentResponse = freezed,}) {
  return _then(_self.copyWith(
roleContext: null == roleContext ? _self.roleContext : roleContext // ignore: cast_nullable_to_non_nullable
as String,needsMyResponseCount: null == needsMyResponseCount ? _self.needsMyResponseCount : needsMyResponseCount // ignore: cast_nullable_to_non_nullable
as int,relationshipDay: freezed == relationshipDay ? _self.relationshipDay : relationshipDay // ignore: cast_nullable_to_non_nullable
as DateTime?,dayBoundaryMinutes: null == dayBoundaryMinutes ? _self.dayBoundaryMinutes : dayBoundaryMinutes // ignore: cast_nullable_to_non_nullable
as int,lastConfirmedAt: freezed == lastConfirmedAt ? _self.lastConfirmedAt : lastConfirmedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,priorityItems: null == priorityItems ? _self.priorityItems : priorityItems // ignore: cast_nullable_to_non_nullable
as List<TodayItem>,laterItems: null == laterItems ? _self.laterItems : laterItems // ignore: cast_nullable_to_non_nullable
as List<TodayItem>,awaitingResponse: null == awaitingResponse ? _self.awaitingResponse : awaitingResponse // ignore: cast_nullable_to_non_nullable
as List<TodayItem>,recentResponse: freezed == recentResponse ? _self.recentResponse : recentResponse // ignore: cast_nullable_to_non_nullable
as RecentResponse?,
  ));
}
/// Create a copy of TodayView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecentResponseCopyWith<$Res>? get recentResponse {
    if (_self.recentResponse == null) {
    return null;
  }

  return $RecentResponseCopyWith<$Res>(_self.recentResponse!, (value) {
    return _then(_self.copyWith(recentResponse: value));
  });
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String roleContext,  int needsMyResponseCount,  DateTime? relationshipDay,  int dayBoundaryMinutes,  DateTime? lastConfirmedAt,  int totalCount,  List<TodayItem> priorityItems,  List<TodayItem> laterItems,  List<TodayItem> awaitingResponse,  RecentResponse? recentResponse)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TodayView() when $default != null:
return $default(_that.roleContext,_that.needsMyResponseCount,_that.relationshipDay,_that.dayBoundaryMinutes,_that.lastConfirmedAt,_that.totalCount,_that.priorityItems,_that.laterItems,_that.awaitingResponse,_that.recentResponse);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String roleContext,  int needsMyResponseCount,  DateTime? relationshipDay,  int dayBoundaryMinutes,  DateTime? lastConfirmedAt,  int totalCount,  List<TodayItem> priorityItems,  List<TodayItem> laterItems,  List<TodayItem> awaitingResponse,  RecentResponse? recentResponse)  $default,) {final _that = this;
switch (_that) {
case _TodayView():
return $default(_that.roleContext,_that.needsMyResponseCount,_that.relationshipDay,_that.dayBoundaryMinutes,_that.lastConfirmedAt,_that.totalCount,_that.priorityItems,_that.laterItems,_that.awaitingResponse,_that.recentResponse);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String roleContext,  int needsMyResponseCount,  DateTime? relationshipDay,  int dayBoundaryMinutes,  DateTime? lastConfirmedAt,  int totalCount,  List<TodayItem> priorityItems,  List<TodayItem> laterItems,  List<TodayItem> awaitingResponse,  RecentResponse? recentResponse)?  $default,) {final _that = this;
switch (_that) {
case _TodayView() when $default != null:
return $default(_that.roleContext,_that.needsMyResponseCount,_that.relationshipDay,_that.dayBoundaryMinutes,_that.lastConfirmedAt,_that.totalCount,_that.priorityItems,_that.laterItems,_that.awaitingResponse,_that.recentResponse);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TodayView implements TodayView {
  const _TodayView({this.roleContext = 'PARTNER', this.needsMyResponseCount = 0, this.relationshipDay, this.dayBoundaryMinutes = 120, this.lastConfirmedAt, this.totalCount = 0, final  List<TodayItem> priorityItems = const <TodayItem>[], final  List<TodayItem> laterItems = const <TodayItem>[], final  List<TodayItem> awaitingResponse = const <TodayItem>[], this.recentResponse}): _priorityItems = priorityItems,_laterItems = laterItems,_awaitingResponse = awaitingResponse;
  factory _TodayView.fromJson(Map<String, dynamic> json) => _$TodayViewFromJson(json);

/// My role in THIS dynamic (Notion 03 §1 — role belongs to Membership).
@override@JsonKey() final  String roleContext;
/// How many things are waiting on my human response, stated by the
/// server. Today shows the direction-giving face when this is non-zero.
@override@JsonKey() final  int needsMyResponseCount;
/// The relationship day this list belongs to, resolved by the server in
/// the Dynamic's own timezone. The client never derives it from the
/// device clock.
@override final  DateTime? relationshipDay;
/// Minutes past midnight at which the relationship day rolls over, in the
/// Dynamic's own timezone. The screen used to state a hard-coded 2:00 AM,
/// which was wrong for any Dynamic that chose another boundary.
@override@JsonKey() final  int dayBoundaryMinutes;
/// When the server last confirmed this list. Offline shows the last
/// confirmed list with this timestamp rather than implying it is current.
@override final  DateTime? lastConfirmedAt;
/// Total actionable items for the day, stated by the server.
@override@JsonKey() final  int totalCount;
/// At most three, in server order: the first carries editorial emphasis,
/// the next two are timeline rows. Never re-sorted on the client.
 final  List<TodayItem> _priorityItems;
/// At most three, in server order: the first carries editorial emphasis,
/// the next two are timeline rows. Never re-sorted on the client.
@override@JsonKey() List<TodayItem> get priorityItems {
  if (_priorityItems is EqualUnmodifiableListView) return _priorityItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_priorityItems);
}

/// Everything else for the day, behind one count-bearing disclosure.
 final  List<TodayItem> _laterItems;
/// Everything else for the day, behind one count-bearing disclosure.
@override@JsonKey() List<TodayItem> get laterItems {
  if (_laterItems is EqualUnmodifiableListView) return _laterItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_laterItems);
}

 final  List<TodayItem> _awaitingResponse;
@override@JsonKey() List<TodayItem> get awaitingResponse {
  if (_awaitingResponse is EqualUnmodifiableListView) return _awaitingResponse;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_awaitingResponse);
}

@override final  RecentResponse? recentResponse;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TodayView&&(identical(other.roleContext, roleContext) || other.roleContext == roleContext)&&(identical(other.needsMyResponseCount, needsMyResponseCount) || other.needsMyResponseCount == needsMyResponseCount)&&(identical(other.relationshipDay, relationshipDay) || other.relationshipDay == relationshipDay)&&(identical(other.dayBoundaryMinutes, dayBoundaryMinutes) || other.dayBoundaryMinutes == dayBoundaryMinutes)&&(identical(other.lastConfirmedAt, lastConfirmedAt) || other.lastConfirmedAt == lastConfirmedAt)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&const DeepCollectionEquality().equals(other._priorityItems, _priorityItems)&&const DeepCollectionEquality().equals(other._laterItems, _laterItems)&&const DeepCollectionEquality().equals(other._awaitingResponse, _awaitingResponse)&&(identical(other.recentResponse, recentResponse) || other.recentResponse == recentResponse));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,roleContext,needsMyResponseCount,relationshipDay,dayBoundaryMinutes,lastConfirmedAt,totalCount,const DeepCollectionEquality().hash(_priorityItems),const DeepCollectionEquality().hash(_laterItems),const DeepCollectionEquality().hash(_awaitingResponse),recentResponse);

@override
String toString() {
  return 'TodayView(roleContext: $roleContext, needsMyResponseCount: $needsMyResponseCount, relationshipDay: $relationshipDay, dayBoundaryMinutes: $dayBoundaryMinutes, lastConfirmedAt: $lastConfirmedAt, totalCount: $totalCount, priorityItems: $priorityItems, laterItems: $laterItems, awaitingResponse: $awaitingResponse, recentResponse: $recentResponse)';
}


}

/// @nodoc
abstract mixin class _$TodayViewCopyWith<$Res> implements $TodayViewCopyWith<$Res> {
  factory _$TodayViewCopyWith(_TodayView value, $Res Function(_TodayView) _then) = __$TodayViewCopyWithImpl;
@override @useResult
$Res call({
 String roleContext, int needsMyResponseCount, DateTime? relationshipDay, int dayBoundaryMinutes, DateTime? lastConfirmedAt, int totalCount, List<TodayItem> priorityItems, List<TodayItem> laterItems, List<TodayItem> awaitingResponse, RecentResponse? recentResponse
});


@override $RecentResponseCopyWith<$Res>? get recentResponse;

}
/// @nodoc
class __$TodayViewCopyWithImpl<$Res>
    implements _$TodayViewCopyWith<$Res> {
  __$TodayViewCopyWithImpl(this._self, this._then);

  final _TodayView _self;
  final $Res Function(_TodayView) _then;

/// Create a copy of TodayView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? roleContext = null,Object? needsMyResponseCount = null,Object? relationshipDay = freezed,Object? dayBoundaryMinutes = null,Object? lastConfirmedAt = freezed,Object? totalCount = null,Object? priorityItems = null,Object? laterItems = null,Object? awaitingResponse = null,Object? recentResponse = freezed,}) {
  return _then(_TodayView(
roleContext: null == roleContext ? _self.roleContext : roleContext // ignore: cast_nullable_to_non_nullable
as String,needsMyResponseCount: null == needsMyResponseCount ? _self.needsMyResponseCount : needsMyResponseCount // ignore: cast_nullable_to_non_nullable
as int,relationshipDay: freezed == relationshipDay ? _self.relationshipDay : relationshipDay // ignore: cast_nullable_to_non_nullable
as DateTime?,dayBoundaryMinutes: null == dayBoundaryMinutes ? _self.dayBoundaryMinutes : dayBoundaryMinutes // ignore: cast_nullable_to_non_nullable
as int,lastConfirmedAt: freezed == lastConfirmedAt ? _self.lastConfirmedAt : lastConfirmedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,priorityItems: null == priorityItems ? _self._priorityItems : priorityItems // ignore: cast_nullable_to_non_nullable
as List<TodayItem>,laterItems: null == laterItems ? _self._laterItems : laterItems // ignore: cast_nullable_to_non_nullable
as List<TodayItem>,awaitingResponse: null == awaitingResponse ? _self._awaitingResponse : awaitingResponse // ignore: cast_nullable_to_non_nullable
as List<TodayItem>,recentResponse: freezed == recentResponse ? _self.recentResponse : recentResponse // ignore: cast_nullable_to_non_nullable
as RecentResponse?,
  ));
}

/// Create a copy of TodayView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecentResponseCopyWith<$Res>? get recentResponse {
    if (_self.recentResponse == null) {
    return null;
  }

  return $RecentResponseCopyWith<$Res>(_self.recentResponse!, (value) {
    return _then(_self.copyWith(recentResponse: value));
  });
}
}

// dart format on
