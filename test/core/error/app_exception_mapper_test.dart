import 'package:dio/dio.dart';
import 'package:flutter_arms/core/error/app_exception.dart';
import 'package:flutter_arms/core/error/app_exception_mapper.dart';
import 'package:flutter_arms/core/error/failure_code.dart';
import 'package:flutter_test/flutter_test.dart';

DioException _dioEx(
  DioExceptionType type, {
  Response<dynamic>? response,
}) => DioException(
  requestOptions: RequestOptions(path: '/x'),
  type: type,
  response: response,
);

void main() {
  group('AppExceptionMapper.fromDio', () {
    test('connectionTimeout -> TimeoutException', () {
      final ex = AppExceptionMapper.fromDio(
        _dioEx(DioExceptionType.connectionTimeout),
      );
      expect(ex, isA<TimeoutException>());
      expect(ex.code, FailureCode.timeout);
    });

    test('sendTimeout -> TimeoutException', () {
      final ex = AppExceptionMapper.fromDio(
        _dioEx(DioExceptionType.sendTimeout),
      );
      expect(ex, isA<TimeoutException>());
    });

    test('receiveTimeout -> TimeoutException', () {
      final ex = AppExceptionMapper.fromDio(
        _dioEx(DioExceptionType.receiveTimeout),
      );
      expect(ex, isA<TimeoutException>());
    });

    test('badResponse 401 -> AuthException', () {
      final response = Response<dynamic>(
        requestOptions: RequestOptions(path: '/x'),
        statusCode: 401,
      );
      final ex = AppExceptionMapper.fromDio(
        _dioEx(DioExceptionType.badResponse, response: response),
      );
      expect(ex, isA<AuthException>());
      expect(ex.code, FailureCode.auth);
    });

    test('badResponse 500 -> BadResponseException', () {
      final response = Response<dynamic>(
        requestOptions: RequestOptions(path: '/x'),
        statusCode: 500,
        data: <String, dynamic>{'message': 'server error'},
      );
      final ex = AppExceptionMapper.fromDio(
        _dioEx(DioExceptionType.badResponse, response: response),
      );
      expect(ex, isA<BadResponseException>());
      expect(ex.code, FailureCode.badResponse);
      expect(ex.detail, 'server error');
    });

    test('cancel -> CancelledException', () {
      final ex = AppExceptionMapper.fromDio(_dioEx(DioExceptionType.cancel));
      expect(ex, isA<CancelledException>());
    });

    test('connectionError -> NetworkException', () {
      final ex = AppExceptionMapper.fromDio(
        _dioEx(DioExceptionType.connectionError),
      );
      expect(ex, isA<NetworkException>());
    });

    test('badCertificate -> UnknownException', () {
      final ex = AppExceptionMapper.fromDio(
        _dioEx(DioExceptionType.badCertificate),
      );
      expect(ex, isA<UnknownException>());
    });

    test('unknown -> UnknownException', () {
      final ex = AppExceptionMapper.fromDio(_dioEx(DioExceptionType.unknown));
      expect(ex, isA<UnknownException>());
    });
  });
}
