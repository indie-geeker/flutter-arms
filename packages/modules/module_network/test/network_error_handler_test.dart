import 'package:dio/dio.dart';
import 'package:interfaces/interfaces.dart';
import 'package:module_network/src/utils/network_error_handler.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NetworkErrorHandler.handleDioException', () {
    test('maps timeout exception types', () {
      final connectTimeout = _dioError(DioExceptionType.connectionTimeout);
      final sendTimeout = _dioError(DioExceptionType.sendTimeout);
      final receiveTimeout = _dioError(DioExceptionType.receiveTimeout);

      final connect = NetworkErrorHandler.handleDioException(connectTimeout);
      final send = NetworkErrorHandler.handleDioException(sendTimeout);
      final receive = NetworkErrorHandler.handleDioException(receiveTimeout);

      expect(connect.type, NetworkExceptionType.timeout);
      expect(connect.message, 'Connection timeout');
      expect(send.type, NetworkExceptionType.timeout);
      expect(send.message, 'Send timeout');
      expect(receive.type, NetworkExceptionType.timeout);
      expect(receive.message, 'Receive timeout');
    });

    test('maps badResponse with status-based message', () {
      final badResponse = _dioError(
        DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/users'),
          statusCode: 404,
        ),
      );

      final result = NetworkErrorHandler.handleDioException(badResponse);

      expect(result.type, NetworkExceptionType.serverError);
      expect(result.statusCode, 404);
      expect(result.message, 'Not found');
    });

    test('extracts message field from badResponse payload map', () {
      final badResponse = _dioError(
        DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/users'),
          statusCode: 400,
          data: const {'message': 'custom-error'},
        ),
      );

      final result = NetworkErrorHandler.handleDioException(badResponse);

      expect(result.message, 'custom-error');
    });

    test('maps cancel, connection, certificate and unknown errors', () {
      final cancelled = NetworkErrorHandler.handleDioException(
        _dioError(DioExceptionType.cancel),
      );
      final noInternet = NetworkErrorHandler.handleDioException(
        _dioError(DioExceptionType.connectionError),
      );
      final cert = NetworkErrorHandler.handleDioException(
        _dioError(DioExceptionType.badCertificate),
      );
      final unknown = NetworkErrorHandler.handleDioException(
        _dioError(DioExceptionType.unknown, message: 'boom'),
      );

      expect(cancelled.type, NetworkExceptionType.cancelled);
      expect(cancelled.message, 'Request cancelled');
      expect(noInternet.type, NetworkExceptionType.noInternet);
      expect(noInternet.message, 'No internet connection');
      expect(cert.type, NetworkExceptionType.unknown);
      expect(cert.message, 'SSL certificate verification failed');
      expect(unknown.type, NetworkExceptionType.unknown);
      expect(unknown.message, 'boom');
    });
  });

  group('NetworkErrorHandler.handleGenericException', () {
    test('maps FormatException to parseError', () {
      final result = NetworkErrorHandler.handleGenericException(
        const FormatException('invalid json'),
        StackTrace.empty,
      );

      expect(result.type, NetworkExceptionType.parseError);
      expect(result.message, 'Failed to parse response data');
    });

    test('maps generic errors to unknown with toString message', () {
      final result = NetworkErrorHandler.handleGenericException(
        StateError('bad state'),
        null,
      );

      expect(result.type, NetworkExceptionType.unknown);
      expect(result.message, 'Bad state: bad state');
    });
  });

  group('NetworkErrorHandler.isRetryable', () {
    const retryableStatusCodes = <int>{408, 429};

    test('returns true for timeout errors', () {
      final exception = NetworkException(
        message: 'timeout',
        type: NetworkExceptionType.timeout,
      );

      expect(
        NetworkErrorHandler.isRetryable(exception, retryableStatusCodes),
        isTrue,
      );
    });

    test('returns true for connection errors', () {
      final exception = NetworkException(
        message: 'offline',
        type: NetworkExceptionType.noInternet,
      );

      expect(
        NetworkErrorHandler.isRetryable(exception, retryableStatusCodes),
        isTrue,
      );
    });

    test('returns true for configured retryable status code', () {
      final exception = NetworkException(
        message: 'rate-limit',
        type: NetworkExceptionType.unknown,
        statusCode: 429,
      );

      expect(
        NetworkErrorHandler.isRetryable(exception, retryableStatusCodes),
        isTrue,
      );
    });

    test(
      'returns true for server errors and false for non-retryable errors',
      () {
        final serverError = NetworkException(
          message: 'server error',
          type: NetworkExceptionType.serverError,
          statusCode: 500,
        );
        final nonRetryable = NetworkException(
          message: 'bad request',
          type: NetworkExceptionType.serverError,
          statusCode: 400,
        );

        expect(
          NetworkErrorHandler.isRetryable(serverError, retryableStatusCodes),
          isTrue,
        );
        expect(
          NetworkErrorHandler.isRetryable(nonRetryable, retryableStatusCodes),
          isFalse,
        );
      },
    );
  });
}

DioException _dioError(
  DioExceptionType type, {
  Response<dynamic>? response,
  String? message,
}) {
  return DioException(
    requestOptions: RequestOptions(path: '/'),
    type: type,
    response: response,
    message: message,
  );
}
