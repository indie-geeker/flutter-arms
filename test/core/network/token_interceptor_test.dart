import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_arms/core/network/token_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TokenInterceptor', () {
    test('does not inject Authorization when requiresAuth is false', () async {
      final dio = Dio();
      var accessTokenReads = 0;
      late RequestOptions captured;

      dio.interceptors
        ..add(
          TokenInterceptor(
            accessTokenProvider: () async {
              accessTokenReads++;
              return 'access';
            },
            refreshTokenProvider: () async => 'refresh',
            refreshAction: (_) async => true,
            retryDio: Dio(),
          ),
        )
        ..add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              captured = options;
              handler.resolve(
                Response<Object?>(requestOptions: options, statusCode: 200),
              );
            },
          ),
        );

      await dio.get<void>(
        '/auth/login',
        options: Options(extra: <String, Object?>{'requiresAuth': false}),
      );

      expect(accessTokenReads, 0);
      expect(captured.headers, isNot(contains('Authorization')));
    });

    test(
      'does not refresh and retry a 401 when requiresAuth is false',
      () async {
        final retryDio = Dio()..httpClientAdapter = const _StatusAdapter(200);
        final dio = Dio()..httpClientAdapter = const _StatusAdapter(401);
        var refreshCalls = 0;

        dio.interceptors.add(
          TokenInterceptor(
            accessTokenProvider: () async => 'access',
            refreshTokenProvider: () async => 'refresh',
            refreshAction: (_) async {
              refreshCalls++;
              return true;
            },
            retryDio: retryDio,
          ),
        );

        await expectLater(
          dio.get<void>(
            '/auth/login',
            options: Options(extra: <String, Object?>{'requiresAuth': false}),
          ),
          throwsA(
            isA<DioException>().having(
              (error) => error.response?.statusCode,
              'statusCode',
              401,
            ),
          ),
        );
        expect(refreshCalls, 0);
      },
    );
  });
}

final class _StatusAdapter implements HttpClientAdapter {
  const _StatusAdapter(this.statusCode);

  final int statusCode;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final body = jsonEncode(<String, Object?>{'ok': statusCode < 400});
    return ResponseBody.fromString(
      body,
      statusCode,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
