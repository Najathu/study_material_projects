// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'network_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NetworkLogEntry {

 int get id; String get method; String get url; DateTime get startedAt; int? get statusCode; int? get durationMs; String? get error;
/// Create a copy of NetworkLogEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NetworkLogEntryCopyWith<NetworkLogEntry> get copyWith => _$NetworkLogEntryCopyWithImpl<NetworkLogEntry>(this as NetworkLogEntry, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as NetworkLogEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NetworkLogEntry&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.method, _this.method) || other.method == _this.method)&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.startedAt, _this.startedAt) || other.startedAt == _this.startedAt)&&(identical(other.statusCode, _this.statusCode) || other.statusCode == _this.statusCode)&&(identical(other.durationMs, _this.durationMs) || other.durationMs == _this.durationMs)&&(identical(other.error, _this.error) || other.error == _this.error));
}


@override
int get hashCode {
  final _this = this as NetworkLogEntry;
  return Object.hash(runtimeType,_this.id,_this.method,_this.url,_this.startedAt,_this.statusCode,_this.durationMs,_this.error);
}

@override
String toString() {
  final _this = this as NetworkLogEntry;
  return 'NetworkLogEntry(id: ${_this.id}, method: ${_this.method}, url: ${_this.url}, startedAt: ${_this.startedAt}, statusCode: ${_this.statusCode}, durationMs: ${_this.durationMs}, error: ${_this.error})';
}


}

/// @nodoc
abstract mixin class $NetworkLogEntryCopyWith<$Res>  {
  factory $NetworkLogEntryCopyWith(NetworkLogEntry value, $Res Function(NetworkLogEntry) _then) = _$NetworkLogEntryCopyWithImpl;
@useResult
$Res call({
 int id, String method, String url, DateTime startedAt, int? statusCode, int? durationMs, String? error
});




}
/// @nodoc
class _$NetworkLogEntryCopyWithImpl<$Res>
    implements $NetworkLogEntryCopyWith<$Res> {
  _$NetworkLogEntryCopyWithImpl(this._self, this._then);

  final NetworkLogEntry _self;
  final $Res Function(NetworkLogEntry) _then;

/// Create a copy of NetworkLogEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? method = null,Object? url = null,Object? startedAt = null,Object? statusCode = freezed,Object? durationMs = freezed,Object? error = freezed,}) {
  return _then(NetworkLogEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,statusCode: freezed == statusCode ? _self.statusCode : statusCode // ignore: cast_nullable_to_non_nullable
as int?,durationMs: freezed == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [NetworkLogEntry].
extension NetworkLogEntryPatterns on NetworkLogEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NetworkLogEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NetworkLogEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NetworkLogEntry value)  $default,){
final _that = this;
switch (_that) {
case _NetworkLogEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NetworkLogEntry value)?  $default,){
final _that = this;
switch (_that) {
case _NetworkLogEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String method,  String url,  DateTime startedAt,  int? statusCode,  int? durationMs,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NetworkLogEntry() when $default != null:
return $default(_that.id,_that.method,_that.url,_that.startedAt,_that.statusCode,_that.durationMs,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String method,  String url,  DateTime startedAt,  int? statusCode,  int? durationMs,  String? error)  $default,) {final _that = this;
switch (_that) {
case _NetworkLogEntry():
return $default(_that.id,_that.method,_that.url,_that.startedAt,_that.statusCode,_that.durationMs,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String method,  String url,  DateTime startedAt,  int? statusCode,  int? durationMs,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _NetworkLogEntry() when $default != null:
return $default(_that.id,_that.method,_that.url,_that.startedAt,_that.statusCode,_that.durationMs,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _NetworkLogEntry implements NetworkLogEntry {
  const _NetworkLogEntry({required this.id, required this.method, required this.url, required this.startedAt, this.statusCode, this.durationMs, this.error});
  

@override final  int id;
@override final  String method;
@override final  String url;
@override final  DateTime startedAt;
@override final  int? statusCode;
@override final  int? durationMs;
@override final  String? error;

/// Create a copy of NetworkLogEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NetworkLogEntryCopyWith<_NetworkLogEntry> get copyWith => __$NetworkLogEntryCopyWithImpl<_NetworkLogEntry>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NetworkLogEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.method, method) || other.method == method)&&(identical(other.url, url) || other.url == url)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.statusCode, statusCode) || other.statusCode == statusCode)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,method,url,startedAt,statusCode,durationMs,error);
}

@override
String toString() {
    return 'NetworkLogEntry(id: $id, method: $method, url: $url, startedAt: $startedAt, statusCode: $statusCode, durationMs: $durationMs, error: $error)';
}


}

/// @nodoc
abstract mixin class _$NetworkLogEntryCopyWith<$Res> implements $NetworkLogEntryCopyWith<$Res> {
  factory _$NetworkLogEntryCopyWith(_NetworkLogEntry value, $Res Function(_NetworkLogEntry) _then) = __$NetworkLogEntryCopyWithImpl;
@override @useResult
$Res call({
 int id, String method, String url, DateTime startedAt, int? statusCode, int? durationMs, String? error
});




}
/// @nodoc
class __$NetworkLogEntryCopyWithImpl<$Res>
    implements _$NetworkLogEntryCopyWith<$Res> {
  __$NetworkLogEntryCopyWithImpl(this._self, this._then);

  final _NetworkLogEntry _self;
  final $Res Function(_NetworkLogEntry) _then;

/// Create a copy of NetworkLogEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? method = null,Object? url = null,Object? startedAt = null,Object? statusCode = freezed,Object? durationMs = freezed,Object? error = freezed,}) {
  return _then(_NetworkLogEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,statusCode: freezed == statusCode ? _self.statusCode : statusCode // ignore: cast_nullable_to_non_nullable
as int?,durationMs: freezed == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
