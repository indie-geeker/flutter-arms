import 'package:dio/dio.dart';
import 'package:flutter_arms/core/network/token_interceptor.dart';
import 'package:flutter_arms/features/auth/data/datasources/retrofit_auth_remote_datasource.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RetrofitAuthRemoteDataSource', () {
    test('login opts out of stale Authorization injection', () async {
      final captured = <RequestOptions>[];
      final dio = Dio(BaseOptions(baseUrl: 'https://example.invalid'));

      dio.interceptors
        ..add(
          TokenInterceptor(
            accessTokenProvider: () async => 'expired-access',
            refreshTokenProvider: () async => 'refresh-token',
            refreshAction: (_) async => true,
            retryDio: Dio(),
          ),
        )
        ..add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              captured.add(options);
              handler.resolve(
                Response<Map<String, dynamic>>(
                  requestOptions: options,
                  statusCode: 200,
                  data: <String, dynamic>{
                    'accessToken': 'new-access',
                    'refreshToken': 'new-refresh',
                  },
                ),
              );
            },
          ),
        );

      final dataSource = RetrofitAuthRemoteDataSource(RetrofitAuthApi(dio));

      await dataSource.login(<String, dynamic>{
        'username': 'admin',
        'password': 'admin',
      });

      final request = captured.single;
      expect(request.extra['requiresAuth'], isFalse);
      expect(request.headers, isNot(contains('Authorization')));
    });
  });
}
