// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'occurrence_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AcknowledgementView {

 String get type; String get text; DateTime get sentAt; String? get senderDisplayName;
/// Create a copy of AcknowledgementView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AcknowledgementViewCopyWith<AcknowledgementView> get copyWith => _$AcknowledgementViewCopyWithImpl<AcknowledgementView>(this as AcknowledgementView, _$identity);

  /// Serializes this AcknowledgementView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AcknowledgementView&&(identical(other.type, type) || other.type == type)&&(identical(other.text, text) || other.text == text)&&(identical(other.sentAt, sentAt) || other.sentAt == sentAt)&&(identical(other.senderDisplayName, senderDisplayName) || other.senderDisplayName == senderDisplayName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,text,sentAt,senderDisplayName);

@override
String toString() {
  return 'AcknowledgementView(type: $type, text: $text, sentAt: $sentAt, senderDisplayName: $senderDisplayName)';
}


}

/// @nodoc
abstract mixin class $AcknowledgementViewCopyWith<$Res>  {
  factory $AcknowledgementViewCopyWith(AcknowledgementView value, $Res Function(AcknowledgementView) _then) = _$AcknowledgementViewCopyWithImpl;
@useResult
$Res call({
 String type, String text, DateTime sentAt, String? senderDisplayName
});




}
/// @nodoc
class _$AcknowledgementViewCopyWithImpl<$Res>
    implements $AcknowledgementViewCopyWith<$Res> {
  _$AcknowledgementViewCopyWithImpl(this._self, this._then);

  final AcknowledgementView _self;
  final $Res Function(AcknowledgementView) _then;

/// Create a copy of AcknowledgementView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? text = null,Object? sentAt = null,Object? senderDisplayName = freezed,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,sentAt: null == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as DateTime,senderDisplayName: freezed == senderDisplayName ? _self.senderDisplayName : senderDisplayName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AcknowledgementView].
extension AcknowledgementViewPatterns on AcknowledgementView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AcknowledgementView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AcknowledgementView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AcknowledgementView value)  $default,){
final _that = this;
switch (_that) {
case _AcknowledgementView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AcknowledgementView value)?  $default,){
final _that = this;
switch (_that) {
case _AcknowledgementView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String type,  String text,  DateTime sentAt,  String? senderDisplayName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AcknowledgementView() when $default != null:
return $default(_that.type,_that.text,_that.sentAt,_that.senderDisplayName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String type,  String text,  DateTime sentAt,  String? senderDisplayName)  $default,) {final _that = this;
switch (_that) {
case _AcknowledgementView():
return $default(_that.type,_that.text,_that.sentAt,_that.senderDisplayName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String type,  String text,  DateTime sentAt,  String? senderDisplayName)?  $default,) {final _that = this;
switch (_that) {
case _AcknowledgementView() when $default != null:
return $default(_that.type,_that.text,_that.sentAt,_that.senderDisplayName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AcknowledgementView implements AcknowledgementView {
  const _AcknowledgementView({required this.type, required this.text, required this.sentAt, this.senderDisplayName});
  factory _AcknowledgementView.fromJson(Map<String, dynamic> json) => _$AcknowledgementViewFromJson(json);

@override final  String type;
@override final  String text;
@override final  DateTime sentAt;
@override final  String? senderDisplayName;

/// Create a copy of AcknowledgementView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AcknowledgementViewCopyWith<_AcknowledgementView> get copyWith => __$AcknowledgementViewCopyWithImpl<_AcknowledgementView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AcknowledgementViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AcknowledgementView&&(identical(other.type, type) || other.type == type)&&(identical(other.text, text) || other.text == text)&&(identical(other.sentAt, sentAt) || other.sentAt == sentAt)&&(identical(other.senderDisplayName, senderDisplayName) || other.senderDisplayName == senderDisplayName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,text,sentAt,senderDisplayName);

@override
String toString() {
  return 'AcknowledgementView(type: $type, text: $text, sentAt: $sentAt, senderDisplayName: $senderDisplayName)';
}


}

/// @nodoc
abstract mixin class _$AcknowledgementViewCopyWith<$Res> implements $AcknowledgementViewCopyWith<$Res> {
  factory _$AcknowledgementViewCopyWith(_AcknowledgementView value, $Res Function(_AcknowledgementView) _then) = __$AcknowledgementViewCopyWithImpl;
@override @useResult
$Res call({
 String type, String text, DateTime sentAt, String? senderDisplayName
});




}
/// @nodoc
class __$AcknowledgementViewCopyWithImpl<$Res>
    implements _$AcknowledgementViewCopyWith<$Res> {
  __$AcknowledgementViewCopyWithImpl(this._self, this._then);

  final _AcknowledgementView _self;
  final $Res Function(_AcknowledgementView) _then;

/// Create a copy of AcknowledgementView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? text = null,Object? sentAt = null,Object? senderDisplayName = freezed,}) {
  return _then(_AcknowledgementView(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,sentAt: null == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as DateTime,senderDisplayName: freezed == senderDisplayName ? _self.senderDisplayName : senderDisplayName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$OccurrenceView {

 String get id; String get title; String? get purpose; OccurrenceState get state; DateTime? get dueAt; DateTime? get completedAt; AcknowledgementView? get acknowledgement;/// The other person, by name. Screens in the loop address a human being
/// rather than a workflow role.
 String? get partnerDisplayName;/// Server-computed UX hint. Never treated as authorization.
 List<String> get allowedActions;
/// Create a copy of OccurrenceView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OccurrenceViewCopyWith<OccurrenceView> get copyWith => _$OccurrenceViewCopyWithImpl<OccurrenceView>(this as OccurrenceView, _$identity);

  /// Serializes this OccurrenceView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OccurrenceView&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.purpose, purpose) || other.purpose == purpose)&&(identical(other.state, state) || other.state == state)&&(identical(other.dueAt, dueAt) || other.dueAt == dueAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.acknowledgement, acknowledgement) || other.acknowledgement == acknowledgement)&&(identical(other.partnerDisplayName, partnerDisplayName) || other.partnerDisplayName == partnerDisplayName)&&const DeepCollectionEquality().equals(other.allowedActions, allowedActions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,purpose,state,dueAt,completedAt,acknowledgement,partnerDisplayName,const DeepCollectionEquality().hash(allowedActions));

@override
String toString() {
  return 'OccurrenceView(id: $id, title: $title, purpose: $purpose, state: $state, dueAt: $dueAt, completedAt: $completedAt, acknowledgement: $acknowledgement, partnerDisplayName: $partnerDisplayName, allowedActions: $allowedActions)';
}


}

/// @nodoc
abstract mixin class $OccurrenceViewCopyWith<$Res>  {
  factory $OccurrenceViewCopyWith(OccurrenceView value, $Res Function(OccurrenceView) _then) = _$OccurrenceViewCopyWithImpl;
@useResult
$Res call({
 String id, String title, String? purpose, OccurrenceState state, DateTime? dueAt, DateTime? completedAt, AcknowledgementView? acknowledgement, String? partnerDisplayName, List<String> allowedActions
});


$AcknowledgementViewCopyWith<$Res>? get acknowledgement;

}
/// @nodoc
class _$OccurrenceViewCopyWithImpl<$Res>
    implements $OccurrenceViewCopyWith<$Res> {
  _$OccurrenceViewCopyWithImpl(this._self, this._then);

  final OccurrenceView _self;
  final $Res Function(OccurrenceView) _then;

/// Create a copy of OccurrenceView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? purpose = freezed,Object? state = null,Object? dueAt = freezed,Object? completedAt = freezed,Object? acknowledgement = freezed,Object? partnerDisplayName = freezed,Object? allowedActions = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,purpose: freezed == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as String?,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as OccurrenceState,dueAt: freezed == dueAt ? _self.dueAt : dueAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,acknowledgement: freezed == acknowledgement ? _self.acknowledgement : acknowledgement // ignore: cast_nullable_to_non_nullable
as AcknowledgementView?,partnerDisplayName: freezed == partnerDisplayName ? _self.partnerDisplayName : partnerDisplayName // ignore: cast_nullable_to_non_nullable
as String?,allowedActions: null == allowedActions ? _self.allowedActions : allowedActions // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}
/// Create a copy of OccurrenceView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AcknowledgementViewCopyWith<$Res>? get acknowledgement {
    if (_self.acknowledgement == null) {
    return null;
  }

  return $AcknowledgementViewCopyWith<$Res>(_self.acknowledgement!, (value) {
    return _then(_self.copyWith(acknowledgement: value));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String? purpose,  OccurrenceState state,  DateTime? dueAt,  DateTime? completedAt,  AcknowledgementView? acknowledgement,  String? partnerDisplayName,  List<String> allowedActions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OccurrenceView() when $default != null:
return $default(_that.id,_that.title,_that.purpose,_that.state,_that.dueAt,_that.completedAt,_that.acknowledgement,_that.partnerDisplayName,_that.allowedActions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String? purpose,  OccurrenceState state,  DateTime? dueAt,  DateTime? completedAt,  AcknowledgementView? acknowledgement,  String? partnerDisplayName,  List<String> allowedActions)  $default,) {final _that = this;
switch (_that) {
case _OccurrenceView():
return $default(_that.id,_that.title,_that.purpose,_that.state,_that.dueAt,_that.completedAt,_that.acknowledgement,_that.partnerDisplayName,_that.allowedActions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String? purpose,  OccurrenceState state,  DateTime? dueAt,  DateTime? completedAt,  AcknowledgementView? acknowledgement,  String? partnerDisplayName,  List<String> allowedActions)?  $default,) {final _that = this;
switch (_that) {
case _OccurrenceView() when $default != null:
return $default(_that.id,_that.title,_that.purpose,_that.state,_that.dueAt,_that.completedAt,_that.acknowledgement,_that.partnerDisplayName,_that.allowedActions);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OccurrenceView implements OccurrenceView {
  const _OccurrenceView({required this.id, required this.title, this.purpose, required this.state, this.dueAt, this.completedAt, this.acknowledgement, this.partnerDisplayName, final  List<String> allowedActions = const <String>[]}): _allowedActions = allowedActions;
  factory _OccurrenceView.fromJson(Map<String, dynamic> json) => _$OccurrenceViewFromJson(json);

@override final  String id;
@override final  String title;
@override final  String? purpose;
@override final  OccurrenceState state;
@override final  DateTime? dueAt;
@override final  DateTime? completedAt;
@override final  AcknowledgementView? acknowledgement;
/// The other person, by name. Screens in the loop address a human being
/// rather than a workflow role.
@override final  String? partnerDisplayName;
/// Server-computed UX hint. Never treated as authorization.
 final  List<String> _allowedActions;
/// Server-computed UX hint. Never treated as authorization.
@override@JsonKey() List<String> get allowedActions {
  if (_allowedActions is EqualUnmodifiableListView) return _allowedActions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allowedActions);
}


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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OccurrenceView&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.purpose, purpose) || other.purpose == purpose)&&(identical(other.state, state) || other.state == state)&&(identical(other.dueAt, dueAt) || other.dueAt == dueAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.acknowledgement, acknowledgement) || other.acknowledgement == acknowledgement)&&(identical(other.partnerDisplayName, partnerDisplayName) || other.partnerDisplayName == partnerDisplayName)&&const DeepCollectionEquality().equals(other._allowedActions, _allowedActions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,purpose,state,dueAt,completedAt,acknowledgement,partnerDisplayName,const DeepCollectionEquality().hash(_allowedActions));

@override
String toString() {
  return 'OccurrenceView(id: $id, title: $title, purpose: $purpose, state: $state, dueAt: $dueAt, completedAt: $completedAt, acknowledgement: $acknowledgement, partnerDisplayName: $partnerDisplayName, allowedActions: $allowedActions)';
}


}

/// @nodoc
abstract mixin class _$OccurrenceViewCopyWith<$Res> implements $OccurrenceViewCopyWith<$Res> {
  factory _$OccurrenceViewCopyWith(_OccurrenceView value, $Res Function(_OccurrenceView) _then) = __$OccurrenceViewCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String? purpose, OccurrenceState state, DateTime? dueAt, DateTime? completedAt, AcknowledgementView? acknowledgement, String? partnerDisplayName, List<String> allowedActions
});


@override $AcknowledgementViewCopyWith<$Res>? get acknowledgement;

}
/// @nodoc
class __$OccurrenceViewCopyWithImpl<$Res>
    implements _$OccurrenceViewCopyWith<$Res> {
  __$OccurrenceViewCopyWithImpl(this._self, this._then);

  final _OccurrenceView _self;
  final $Res Function(_OccurrenceView) _then;

/// Create a copy of OccurrenceView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? purpose = freezed,Object? state = null,Object? dueAt = freezed,Object? completedAt = freezed,Object? acknowledgement = freezed,Object? partnerDisplayName = freezed,Object? allowedActions = null,}) {
  return _then(_OccurrenceView(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,purpose: freezed == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as String?,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as OccurrenceState,dueAt: freezed == dueAt ? _self.dueAt : dueAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,acknowledgement: freezed == acknowledgement ? _self.acknowledgement : acknowledgement // ignore: cast_nullable_to_non_nullable
as AcknowledgementView?,partnerDisplayName: freezed == partnerDisplayName ? _self.partnerDisplayName : partnerDisplayName // ignore: cast_nullable_to_non_nullable
as String?,allowedActions: null == allowedActions ? _self._allowedActions : allowedActions // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

/// Create a copy of OccurrenceView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AcknowledgementViewCopyWith<$Res>? get acknowledgement {
    if (_self.acknowledgement == null) {
    return null;
  }

  return $AcknowledgementViewCopyWith<$Res>(_self.acknowledgement!, (value) {
    return _then(_self.copyWith(acknowledgement: value));
  });
}
}

// dart format on
