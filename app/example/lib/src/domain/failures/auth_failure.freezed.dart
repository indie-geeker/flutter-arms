// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AuthFailure {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthFailure()';
}


}

/// @nodoc
class $AuthFailureCopyWith<$Res>  {
$AuthFailureCopyWith(AuthFailure _, $Res Function(AuthFailure) __);
}


/// Adds pattern-matching-related methods to [AuthFailure].
extension AuthFailurePatterns on AuthFailure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _EmptyUsername value)?  emptyUsername,TResult Function( _EmptyPassword value)?  emptyPassword,TResult Function( _InvalidUsername value)?  invalidUsername,TResult Function( _InvalidPassword value)?  invalidPassword,TResult Function( _InvalidCredentials value)?  invalidCredentials,TResult Function( _UserNotFound value)?  userNotFound,TResult Function( _StorageError value)?  storageError,TResult Function( _NetworkError value)?  networkError,TResult Function( _Unexpected value)?  unexpected,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EmptyUsername() when emptyUsername != null:
return emptyUsername(_that);case _EmptyPassword() when emptyPassword != null:
return emptyPassword(_that);case _InvalidUsername() when invalidUsername != null:
return invalidUsername(_that);case _InvalidPassword() when invalidPassword != null:
return invalidPassword(_that);case _InvalidCredentials() when invalidCredentials != null:
return invalidCredentials(_that);case _UserNotFound() when userNotFound != null:
return userNotFound(_that);case _StorageError() when storageError != null:
return storageError(_that);case _NetworkError() when networkError != null:
return networkError(_that);case _Unexpected() when unexpected != null:
return unexpected(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _EmptyUsername value)  emptyUsername,required TResult Function( _EmptyPassword value)  emptyPassword,required TResult Function( _InvalidUsername value)  invalidUsername,required TResult Function( _InvalidPassword value)  invalidPassword,required TResult Function( _InvalidCredentials value)  invalidCredentials,required TResult Function( _UserNotFound value)  userNotFound,required TResult Function( _StorageError value)  storageError,required TResult Function( _NetworkError value)  networkError,required TResult Function( _Unexpected value)  unexpected,}){
final _that = this;
switch (_that) {
case _EmptyUsername():
return emptyUsername(_that);case _EmptyPassword():
return emptyPassword(_that);case _InvalidUsername():
return invalidUsername(_that);case _InvalidPassword():
return invalidPassword(_that);case _InvalidCredentials():
return invalidCredentials(_that);case _UserNotFound():
return userNotFound(_that);case _StorageError():
return storageError(_that);case _NetworkError():
return networkError(_that);case _Unexpected():
return unexpected(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _EmptyUsername value)?  emptyUsername,TResult? Function( _EmptyPassword value)?  emptyPassword,TResult? Function( _InvalidUsername value)?  invalidUsername,TResult? Function( _InvalidPassword value)?  invalidPassword,TResult? Function( _InvalidCredentials value)?  invalidCredentials,TResult? Function( _UserNotFound value)?  userNotFound,TResult? Function( _StorageError value)?  storageError,TResult? Function( _NetworkError value)?  networkError,TResult? Function( _Unexpected value)?  unexpected,}){
final _that = this;
switch (_that) {
case _EmptyUsername() when emptyUsername != null:
return emptyUsername(_that);case _EmptyPassword() when emptyPassword != null:
return emptyPassword(_that);case _InvalidUsername() when invalidUsername != null:
return invalidUsername(_that);case _InvalidPassword() when invalidPassword != null:
return invalidPassword(_that);case _InvalidCredentials() when invalidCredentials != null:
return invalidCredentials(_that);case _UserNotFound() when userNotFound != null:
return userNotFound(_that);case _StorageError() when storageError != null:
return storageError(_that);case _NetworkError() when networkError != null:
return networkError(_that);case _Unexpected() when unexpected != null:
return unexpected(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  emptyUsername,TResult Function()?  emptyPassword,TResult Function( String message)?  invalidUsername,TResult Function( String message)?  invalidPassword,TResult Function()?  invalidCredentials,TResult Function()?  userNotFound,TResult Function( String message)?  storageError,TResult Function( String message)?  networkError,TResult Function( String message)?  unexpected,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EmptyUsername() when emptyUsername != null:
return emptyUsername();case _EmptyPassword() when emptyPassword != null:
return emptyPassword();case _InvalidUsername() when invalidUsername != null:
return invalidUsername(_that.message);case _InvalidPassword() when invalidPassword != null:
return invalidPassword(_that.message);case _InvalidCredentials() when invalidCredentials != null:
return invalidCredentials();case _UserNotFound() when userNotFound != null:
return userNotFound();case _StorageError() when storageError != null:
return storageError(_that.message);case _NetworkError() when networkError != null:
return networkError(_that.message);case _Unexpected() when unexpected != null:
return unexpected(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  emptyUsername,required TResult Function()  emptyPassword,required TResult Function( String message)  invalidUsername,required TResult Function( String message)  invalidPassword,required TResult Function()  invalidCredentials,required TResult Function()  userNotFound,required TResult Function( String message)  storageError,required TResult Function( String message)  networkError,required TResult Function( String message)  unexpected,}) {final _that = this;
switch (_that) {
case _EmptyUsername():
return emptyUsername();case _EmptyPassword():
return emptyPassword();case _InvalidUsername():
return invalidUsername(_that.message);case _InvalidPassword():
return invalidPassword(_that.message);case _InvalidCredentials():
return invalidCredentials();case _UserNotFound():
return userNotFound();case _StorageError():
return storageError(_that.message);case _NetworkError():
return networkError(_that.message);case _Unexpected():
return unexpected(_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  emptyUsername,TResult? Function()?  emptyPassword,TResult? Function( String message)?  invalidUsername,TResult? Function( String message)?  invalidPassword,TResult? Function()?  invalidCredentials,TResult? Function()?  userNotFound,TResult? Function( String message)?  storageError,TResult? Function( String message)?  networkError,TResult? Function( String message)?  unexpected,}) {final _that = this;
switch (_that) {
case _EmptyUsername() when emptyUsername != null:
return emptyUsername();case _EmptyPassword() when emptyPassword != null:
return emptyPassword();case _InvalidUsername() when invalidUsername != null:
return invalidUsername(_that.message);case _InvalidPassword() when invalidPassword != null:
return invalidPassword(_that.message);case _InvalidCredentials() when invalidCredentials != null:
return invalidCredentials();case _UserNotFound() when userNotFound != null:
return userNotFound();case _StorageError() when storageError != null:
return storageError(_that.message);case _NetworkError() when networkError != null:
return networkError(_that.message);case _Unexpected() when unexpected != null:
return unexpected(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _EmptyUsername implements AuthFailure {
  const _EmptyUsername();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EmptyUsername);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthFailure.emptyUsername()';
}


}




/// @nodoc


class _EmptyPassword implements AuthFailure {
  const _EmptyPassword();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EmptyPassword);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthFailure.emptyPassword()';
}


}




/// @nodoc


class _InvalidUsername implements AuthFailure {
  const _InvalidUsername(this.message);
  

 final  String message;

/// Create a copy of AuthFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InvalidUsernameCopyWith<_InvalidUsername> get copyWith => __$InvalidUsernameCopyWithImpl<_InvalidUsername>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InvalidUsername&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'AuthFailure.invalidUsername(message: $message)';
}


}

/// @nodoc
abstract mixin class _$InvalidUsernameCopyWith<$Res> implements $AuthFailureCopyWith<$Res> {
  factory _$InvalidUsernameCopyWith(_InvalidUsername value, $Res Function(_InvalidUsername) _then) = __$InvalidUsernameCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$InvalidUsernameCopyWithImpl<$Res>
    implements _$InvalidUsernameCopyWith<$Res> {
  __$InvalidUsernameCopyWithImpl(this._self, this._then);

  final _InvalidUsername _self;
  final $Res Function(_InvalidUsername) _then;

/// Create a copy of AuthFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_InvalidUsername(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _InvalidPassword implements AuthFailure {
  const _InvalidPassword(this.message);
  

 final  String message;

/// Create a copy of AuthFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InvalidPasswordCopyWith<_InvalidPassword> get copyWith => __$InvalidPasswordCopyWithImpl<_InvalidPassword>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InvalidPassword&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'AuthFailure.invalidPassword(message: $message)';
}


}

/// @nodoc
abstract mixin class _$InvalidPasswordCopyWith<$Res> implements $AuthFailureCopyWith<$Res> {
  factory _$InvalidPasswordCopyWith(_InvalidPassword value, $Res Function(_InvalidPassword) _then) = __$InvalidPasswordCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$InvalidPasswordCopyWithImpl<$Res>
    implements _$InvalidPasswordCopyWith<$Res> {
  __$InvalidPasswordCopyWithImpl(this._self, this._then);

  final _InvalidPassword _self;
  final $Res Function(_InvalidPassword) _then;

/// Create a copy of AuthFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_InvalidPassword(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _InvalidCredentials implements AuthFailure {
  const _InvalidCredentials();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InvalidCredentials);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthFailure.invalidCredentials()';
}


}




/// @nodoc


class _UserNotFound implements AuthFailure {
  const _UserNotFound();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserNotFound);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthFailure.userNotFound()';
}


}




/// @nodoc


class _StorageError implements AuthFailure {
  const _StorageError(this.message);
  

 final  String message;

/// Create a copy of AuthFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StorageErrorCopyWith<_StorageError> get copyWith => __$StorageErrorCopyWithImpl<_StorageError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StorageError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'AuthFailure.storageError(message: $message)';
}


}

/// @nodoc
abstract mixin class _$StorageErrorCopyWith<$Res> implements $AuthFailureCopyWith<$Res> {
  factory _$StorageErrorCopyWith(_StorageError value, $Res Function(_StorageError) _then) = __$StorageErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$StorageErrorCopyWithImpl<$Res>
    implements _$StorageErrorCopyWith<$Res> {
  __$StorageErrorCopyWithImpl(this._self, this._then);

  final _StorageError _self;
  final $Res Function(_StorageError) _then;

/// Create a copy of AuthFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_StorageError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _NetworkError implements AuthFailure {
  const _NetworkError(this.message);
  

 final  String message;

/// Create a copy of AuthFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NetworkErrorCopyWith<_NetworkError> get copyWith => __$NetworkErrorCopyWithImpl<_NetworkError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NetworkError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'AuthFailure.networkError(message: $message)';
}


}

/// @nodoc
abstract mixin class _$NetworkErrorCopyWith<$Res> implements $AuthFailureCopyWith<$Res> {
  factory _$NetworkErrorCopyWith(_NetworkError value, $Res Function(_NetworkError) _then) = __$NetworkErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$NetworkErrorCopyWithImpl<$Res>
    implements _$NetworkErrorCopyWith<$Res> {
  __$NetworkErrorCopyWithImpl(this._self, this._then);

  final _NetworkError _self;
  final $Res Function(_NetworkError) _then;

/// Create a copy of AuthFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_NetworkError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _Unexpected implements AuthFailure {
  const _Unexpected(this.message);
  

 final  String message;

/// Create a copy of AuthFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UnexpectedCopyWith<_Unexpected> get copyWith => __$UnexpectedCopyWithImpl<_Unexpected>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Unexpected&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'AuthFailure.unexpected(message: $message)';
}


}

/// @nodoc
abstract mixin class _$UnexpectedCopyWith<$Res> implements $AuthFailureCopyWith<$Res> {
  factory _$UnexpectedCopyWith(_Unexpected value, $Res Function(_Unexpected) _then) = __$UnexpectedCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$UnexpectedCopyWithImpl<$Res>
    implements _$UnexpectedCopyWith<$Res> {
  __$UnexpectedCopyWithImpl(this._self, this._then);

  final _Unexpected _self;
  final $Res Function(_Unexpected) _then;

/// Create a copy of AuthFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_Unexpected(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
