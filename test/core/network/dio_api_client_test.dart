import 'package:dio/dio.dart';
import 'package:flutter_arms/core/error/app_exception.dart';
import 'package:flutter_arms/core/network/api_request.dart';
import 'package:flutter_arms/core/network/dio_api_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DioApiClient', () {
    test('sends ApiRequest through Dio and decodes response data', () async {
      final dio = Dio();
      final client = DioApiClient(dio);
      late RequestOptions captured;

      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            captured = options;
            handler.resolve(
              Response<Object?>(
                requestOptions: options,
                statusCode: 200,
                data: <String, Object?>{'value': 'ok'},
              ),
            );
          },
        ),
      );

      final result = await client.send(
        ApiRequest<String>.post(
          '/items',
          body: <String, Object?>{'name': 'book'},
          query: <String, Object?>{'page': 1},
          headers: <String, String>{'x-demo': 'yes'},
          requiresAuth: false,
          decode: (json) => (json! as Map<String, Object?>)['value']! as String,
        ),
      );

      expect(result, 'ok');
      expect(captured.method, 'POST');
      expect(captured.path, '/items');
      expect(captured.data, <String, Object?>{'name': 'book'});
      expect(captured.queryParameters, <String, Object?>{'page': 1});
      expect(captured.headers['x-demo'], 'yes');
      expect(captured.extra['requiresAuth'], isFalse);
    });

    test('maps DioException to AppException', () async {
      final dio = Dio();
      final client = DioApiClient(dio);

      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                response: Response<Object?>(
                  requestOptions: options,
                  statusCode: 500,
                  data: <String, Object?>{'message': 'server down'},
                ),
                type: DioExceptionType.badResponse,
              ),
            );
          },
        ),
      );

      await expectLater(
        client.send(
          const ApiRequest<void>.get('/broken', decode: _decodeVoid),
        ),
        throwsA(
          isA<BadResponseException>().having(
            (error) => error.detail,
            'detail',
            'server down',
          ),
        ),
      );
    });

    test('rethrows AppException carried by DioException.error', () async {
      final dio = Dio();
      final client = DioApiClient(dio);
      const authException = AuthException(detail: 'expired');

      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                error: authException,
                type: DioExceptionType.unknown,
              ),
            );
          },
        ),
      );

      await expectLater(
        client.send(
          const ApiRequest<void>.get('/auth/me', decode: _decodeVoid),
        ),
        throwsA(same(authException)),
      );
    });

    test('wraps decode failures as UnknownException', () async {
      final dio = Dio();
      final client = DioApiClient(dio);

      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response<Object?>(
                requestOptions: options,
                statusCode: 200,
                data: <String, Object?>{'value': 'bad'},
              ),
            );
          },
        ),
      );

      await expectLater(
        client.send(
          ApiRequest<String>.get(
            '/items/1',
            decode: (_) => throw StateError('decode failed'),
          ),
        ),
        throwsA(isA<UnknownException>()),
      );
    });
  });
}

void _decodeVoid(Object? _) {}
