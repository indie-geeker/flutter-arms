// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exceptions.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppException {
  String get message;
  int? get code;
  dynamic get details;

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AppExceptionCopyWith<AppException> get copyWith =>
      _$AppExceptionCopyWithImpl<AppException>(
          this as AppException, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AppException &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.code, code) || other.code == code) &&
            const DeepCollectionEquality().equals(other.details, details));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, message, code, const DeepCollectionEquality().hash(details));

  @override
  String toString() {
    return 'AppException(message: $message, code: $code, details: $details)';
  }
}

/// @nodoc
abstract mixin class $AppExceptionCopyWith<$Res> {
  factory $AppExceptionCopyWith(
          AppException value, $Res Function(AppException) _then) =
      _$AppExceptionCopyWithImpl;
  @useResult
  $Res call({String message, int? code, dynamic details});
}

/// @nodoc
class _$AppExceptionCopyWithImpl<$Res> implements $AppExceptionCopyWith<$Res> {
  _$AppExceptionCopyWithImpl(this._self, this._then);

  final AppException _self;
  final $Res Function(AppException) _then;

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? code = freezed,
    Object? details = freezed,
  }) {
    return _then(_self.copyWith(
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      code: freezed == code
          ? _self.code
          : code // ignore: cast_nullable_to_non_nullable
              as int?,
      details: freezed == details
          ? _self.details
          : details // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ));
  }
}

/// @nodoc

class _AppException implements AppException {
  const _AppException({required this.message, this.code, this.details});

  @override
  final String message;
  @override
  final int? code;
  @override
  final dynamic details;

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AppExceptionCopyWith<_AppException> get copyWith =>
      __$AppExceptionCopyWithImpl<_AppException>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AppException &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.code, code) || other.code == code) &&
            const DeepCollectionEquality().equals(other.details, details));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, message, code, const DeepCollectionEquality().hash(details));

  @override
  String toString() {
    return 'AppException(message: $message, code: $code, details: $details)';
  }
}

/// @nodoc
abstract mixin class _$AppExceptionCopyWith<$Res>
    implements $AppExceptionCopyWith<$Res> {
  factory _$AppExceptionCopyWith(
          _AppException value, $Res Function(_AppException) _then) =
      __$AppExceptionCopyWithImpl;
  @override
  @useResult
  $Res call({String message, int? code, dynamic details});
}

/// @nodoc
class __$AppExceptionCopyWithImpl<$Res>
    implements _$AppExceptionCopyWith<$Res> {
  __$AppExceptionCopyWithImpl(this._self, this._then);

  final _AppException _self;
  final $Res Function(_AppException) _then;

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
    Object? code = freezed,
    Object? details = freezed,
  }) {
    return _then(_AppException(
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      code: freezed == code
          ? _self.code
          : code // ignore: cast_nullable_to_non_nullable
              as int?,
      details: freezed == details
          ? _self.details
          : details // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ));
  }
}

/// @nodoc

class CacheException implements AppException {
  const CacheException({required this.message, this.code, this.details});

  @override
  final String message;
  @override
  final int? code;
  @override
  final dynamic details;

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CacheExceptionCopyWith<CacheException> get copyWith =>
      _$CacheExceptionCopyWithImpl<CacheException>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CacheException &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.code, code) || other.code == code) &&
            const DeepCollectionEquality().equals(other.details, details));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, message, code, const DeepCollectionEquality().hash(details));

  @override
  String toString() {
    return 'AppException.cache(message: $message, code: $code, details: $details)';
  }
}

/// @nodoc
abstract mixin class $CacheExceptionCopyWith<$Res>
    implements $AppExceptionCopyWith<$Res> {
  factory $CacheExceptionCopyWith(
          CacheException value, $Res Function(CacheException) _then) =
      _$CacheExceptionCopyWithImpl;
  @override
  @useResult
  $Res call({String message, int? code, dynamic details});
}

/// @nodoc
class _$CacheExceptionCopyWithImpl<$Res>
    implements $CacheExceptionCopyWith<$Res> {
  _$CacheExceptionCopyWithImpl(this._self, this._then);

  final CacheException _self;
  final $Res Function(CacheException) _then;

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
    Object? code = freezed,
    Object? details = freezed,
  }) {
    return _then(CacheException(
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      code: freezed == code
          ? _self.code
          : code // ignore: cast_nullable_to_non_nullable
              as int?,
      details: freezed == details
          ? _self.details
          : details // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ));
  }
}

/// @nodoc

class NetworkException implements AppException {
  const NetworkException(
      {required this.message, this.code, this.details, this.statusCode});

  @override
  final String message;
  @override
  final int? code;
  @override
  final dynamic details;
  final int? statusCode;

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $NetworkExceptionCopyWith<NetworkException> get copyWith =>
      _$NetworkExceptionCopyWithImpl<NetworkException>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is NetworkException &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.code, code) || other.code == code) &&
            const DeepCollectionEquality().equals(other.details, details) &&
            (identical(other.statusCode, statusCode) ||
                other.statusCode == statusCode));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, code,
      const DeepCollectionEquality().hash(details), statusCode);

  @override
  String toString() {
    return 'AppException.network(message: $message, code: $code, details: $details, statusCode: $statusCode)';
  }
}

/// @nodoc
abstract mixin class $NetworkExceptionCopyWith<$Res>
    implements $AppExceptionCopyWith<$Res> {
  factory $NetworkExceptionCopyWith(
          NetworkException value, $Res Function(NetworkException) _then) =
      _$NetworkExceptionCopyWithImpl;
  @override
  @useResult
  $Res call({String message, int? code, dynamic details, int? statusCode});
}

/// @nodoc
class _$NetworkExceptionCopyWithImpl<$Res>
    implements $NetworkExceptionCopyWith<$Res> {
  _$NetworkExceptionCopyWithImpl(this._self, this._then);

  final NetworkException _self;
  final $Res Function(NetworkException) _then;

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
    Object? code = freezed,
    Object? details = freezed,
    Object? statusCode = freezed,
  }) {
    return _then(NetworkException(
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      code: freezed == code
          ? _self.code
          : code // ignore: cast_nullable_to_non_nullable
              as int?,
      details: freezed == details
          ? _self.details
          : details // ignore: cast_nullable_to_non_nullable
              as dynamic,
      statusCode: freezed == statusCode
          ? _self.statusCode
          : statusCode // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc

class UnauthorizedException implements AppException {
  const UnauthorizedException({required this.message, this.code, this.details});

  @override
  final String message;
  @override
  final int? code;
  @override
  final dynamic details;

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $UnauthorizedExceptionCopyWith<UnauthorizedException> get copyWith =>
      _$UnauthorizedExceptionCopyWithImpl<UnauthorizedException>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is UnauthorizedException &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.code, code) || other.code == code) &&
            const DeepCollectionEquality().equals(other.details, details));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, message, code, const DeepCollectionEquality().hash(details));

  @override
  String toString() {
    return 'AppException.unauthorized(message: $message, code: $code, details: $details)';
  }
}

/// @nodoc
abstract mixin class $UnauthorizedExceptionCopyWith<$Res>
    implements $AppExceptionCopyWith<$Res> {
  factory $UnauthorizedExceptionCopyWith(UnauthorizedException value,
          $Res Function(UnauthorizedException) _then) =
      _$UnauthorizedExceptionCopyWithImpl;
  @override
  @useResult
  $Res call({String message, int? code, dynamic details});
}

/// @nodoc
class _$UnauthorizedExceptionCopyWithImpl<$Res>
    implements $UnauthorizedExceptionCopyWith<$Res> {
  _$UnauthorizedExceptionCopyWithImpl(this._self, this._then);

  final UnauthorizedException _self;
  final $Res Function(UnauthorizedException) _then;

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
    Object? code = freezed,
    Object? details = freezed,
  }) {
    return _then(UnauthorizedException(
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      code: freezed == code
          ? _self.code
          : code // ignore: cast_nullable_to_non_nullable
              as int?,
      details: freezed == details
          ? _self.details
          : details // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ));
  }
}

/// @nodoc

class TimeoutException implements AppException {
  const TimeoutException({required this.message, this.code, this.details});

  @override
  final String message;
  @override
  final int? code;
  @override
  final dynamic details;

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TimeoutExceptionCopyWith<TimeoutException> get copyWith =>
      _$TimeoutExceptionCopyWithImpl<TimeoutException>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TimeoutException &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.code, code) || other.code == code) &&
            const DeepCollectionEquality().equals(other.details, details));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, message, code, const DeepCollectionEquality().hash(details));

  @override
  String toString() {
    return 'AppException.timeout(message: $message, code: $code, details: $details)';
  }
}

/// @nodoc
abstract mixin class $TimeoutExceptionCopyWith<$Res>
    implements $AppExceptionCopyWith<$Res> {
  factory $TimeoutExceptionCopyWith(
          TimeoutException value, $Res Function(TimeoutException) _then) =
      _$TimeoutExceptionCopyWithImpl;
  @override
  @useResult
  $Res call({String message, int? code, dynamic details});
}

/// @nodoc
class _$TimeoutExceptionCopyWithImpl<$Res>
    implements $TimeoutExceptionCopyWith<$Res> {
  _$TimeoutExceptionCopyWithImpl(this._self, this._then);

  final TimeoutException _self;
  final $Res Function(TimeoutException) _then;

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
    Object? code = freezed,
    Object? details = freezed,
  }) {
    return _then(TimeoutException(
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      code: freezed == code
          ? _self.code
          : code // ignore: cast_nullable_to_non_nullable
              as int?,
      details: freezed == details
          ? _self.details
          : details // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ));
  }
}

/// @nodoc

class ParseException implements AppException {
  const ParseException({required this.message, this.code, this.details});

  @override
  final String message;
  @override
  final int? code;
  @override
  final dynamic details;

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ParseExceptionCopyWith<ParseException> get copyWith =>
      _$ParseExceptionCopyWithImpl<ParseException>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ParseException &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.code, code) || other.code == code) &&
            const DeepCollectionEquality().equals(other.details, details));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, message, code, const DeepCollectionEquality().hash(details));

  @override
  String toString() {
    return 'AppException.parse(message: $message, code: $code, details: $details)';
  }
}

/// @nodoc
abstract mixin class $ParseExceptionCopyWith<$Res>
    implements $AppExceptionCopyWith<$Res> {
  factory $ParseExceptionCopyWith(
          ParseException value, $Res Function(ParseException) _then) =
      _$ParseExceptionCopyWithImpl;
  @override
  @useResult
  $Res call({String message, int? code, dynamic details});
}

/// @nodoc
class _$ParseExceptionCopyWithImpl<$Res>
    implements $ParseExceptionCopyWith<$Res> {
  _$ParseExceptionCopyWithImpl(this._self, this._then);

  final ParseException _self;
  final $Res Function(ParseException) _then;

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
    Object? code = freezed,
    Object? details = freezed,
  }) {
    return _then(ParseException(
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      code: freezed == code
          ? _self.code
          : code // ignore: cast_nullable_to_non_nullable
              as int?,
      details: freezed == details
          ? _self.details
          : details // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ));
  }
}

/// @nodoc

class ServerException implements AppException {
  const ServerException({required this.message, this.code, this.details});

  @override
  final String message;
  @override
  final int? code;
  @override
  final dynamic details;

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ServerExceptionCopyWith<ServerException> get copyWith =>
      _$ServerExceptionCopyWithImpl<ServerException>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ServerException &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.code, code) || other.code == code) &&
            const DeepCollectionEquality().equals(other.details, details));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, message, code, const DeepCollectionEquality().hash(details));

  @override
  String toString() {
    return 'AppException.server(message: $message, code: $code, details: $details)';
  }
}

/// @nodoc
abstract mixin class $ServerExceptionCopyWith<$Res>
    implements $AppExceptionCopyWith<$Res> {
  factory $ServerExceptionCopyWith(
          ServerException value, $Res Function(ServerException) _then) =
      _$ServerExceptionCopyWithImpl;
  @override
  @useResult
  $Res call({String message, int? code, dynamic details});
}

/// @nodoc
class _$ServerExceptionCopyWithImpl<$Res>
    implements $ServerExceptionCopyWith<$Res> {
  _$ServerExceptionCopyWithImpl(this._self, this._then);

  final ServerException _self;
  final $Res Function(ServerException) _then;

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
    Object? code = freezed,
    Object? details = freezed,
  }) {
    return _then(ServerException(
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      code: freezed == code
          ? _self.code
          : code // ignore: cast_nullable_to_non_nullable
              as int?,
      details: freezed == details
          ? _self.details
          : details // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ));
  }
}

/// @nodoc

class ServiceException implements AppException {
  const ServiceException({required this.message, this.code, this.details});

  @override
  final String message;
  @override
  final int? code;
  @override
  final dynamic details;

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ServiceExceptionCopyWith<ServiceException> get copyWith =>
      _$ServiceExceptionCopyWithImpl<ServiceException>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ServiceException &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.code, code) || other.code == code) &&
            const DeepCollectionEquality().equals(other.details, details));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, message, code, const DeepCollectionEquality().hash(details));

  @override
  String toString() {
    return 'AppException.service(message: $message, code: $code, details: $details)';
  }
}

/// @nodoc
abstract mixin class $ServiceExceptionCopyWith<$Res>
    implements $AppExceptionCopyWith<$Res> {
  factory $ServiceExceptionCopyWith(
          ServiceException value, $Res Function(ServiceException) _then) =
      _$ServiceExceptionCopyWithImpl;
  @override
  @useResult
  $Res call({String message, int? code, dynamic details});
}

/// @nodoc
class _$ServiceExceptionCopyWithImpl<$Res>
    implements $ServiceExceptionCopyWith<$Res> {
  _$ServiceExceptionCopyWithImpl(this._self, this._then);

  final ServiceException _self;
  final $Res Function(ServiceException) _then;

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
    Object? code = freezed,
    Object? details = freezed,
  }) {
    return _then(ServiceException(
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      code: freezed == code
          ? _self.code
          : code // ignore: cast_nullable_to_non_nullable
              as int?,
      details: freezed == details
          ? _self.details
          : details // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ));
  }
}

/// @nodoc

class UnknownException implements AppException {
  const UnknownException({required this.message, this.code, this.details});

  @override
  final String message;
  @override
  final int? code;
  @override
  final dynamic details;

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $UnknownExceptionCopyWith<UnknownException> get copyWith =>
      _$UnknownExceptionCopyWithImpl<UnknownException>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is UnknownException &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.code, code) || other.code == code) &&
            const DeepCollectionEquality().equals(other.details, details));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, message, code, const DeepCollectionEquality().hash(details));

  @override
  String toString() {
    return 'AppException.unknown(message: $message, code: $code, details: $details)';
  }
}

/// @nodoc
abstract mixin class $UnknownExceptionCopyWith<$Res>
    implements $AppExceptionCopyWith<$Res> {
  factory $UnknownExceptionCopyWith(
          UnknownException value, $Res Function(UnknownException) _then) =
      _$UnknownExceptionCopyWithImpl;
  @override
  @useResult
  $Res call({String message, int? code, dynamic details});
}

/// @nodoc
class _$UnknownExceptionCopyWithImpl<$Res>
    implements $UnknownExceptionCopyWith<$Res> {
  _$UnknownExceptionCopyWithImpl(this._self, this._then);

  final UnknownException _self;
  final $Res Function(UnknownException) _then;

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
    Object? code = freezed,
    Object? details = freezed,
  }) {
    return _then(UnknownException(
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      code: freezed == code
          ? _self.code
          : code // ignore: cast_nullable_to_non_nullable
              as int?,
      details: freezed == details
          ? _self.details
          : details // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ));
  }
}

// dart format on
