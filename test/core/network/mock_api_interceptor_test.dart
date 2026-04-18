import 'package:dio/dio.dart';
import 'package:flutter_arms/core/error/app_exception.dart';
import 'package:flutter_arms/core/error/failure_code.dart';
import 'package:flutter_arms/core/network/api_interceptor.dart';
import 'package:flutter_arms/core/network/dio_ext.dart';
import 'package:flutter_arms/core/network/mock_api_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Dio dio;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://example.invalid'))
      // Mock 首位 -> reject(err, true) 触发 ApiInterceptor.onError；
      // 否则 "following" 为空，DioException 不会被映射成 AppException。
      ..interceptors.add(
        // 覆盖生产默认的 300ms，消除测试等待时间。
        const MockApiInterceptor(latency: Duration.zero),
      )
      ..interceptors.add(const ApiInterceptor());
  });

  group('MockApiInterceptor', () {
    test('/auth/login with admin/admin returns 200 + tokens', () async {
      final res = await dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: <String, dynamic>{'username': 'admin', 'password': 'admin'},
      );

      expect(res.statusCode, 200);
      expect(res.data, isNotNull);
      expect(res.data!['accessToken'], isA<String>());
      expect(res.data!['refreshToken'], isA<String>());
    });

    test(
      '/auth/login with wrong creds -> 401 -> AuthException after .asApi()',
      () async {
        Object? caught;
        try {
          await dio
              .post<Map<String, dynamic>>(
                '/auth/login',
                data: <String, dynamic>{'username': 'wrong', 'password': 'x'},
              )
              .asApi();
        } on Object catch (e) {
          caught = e;
        }

        expect(caught, isA<AuthException>());
        final ex = caught! as AuthException;
        expect(ex.code, FailureCode.auth);
        expect(ex.detail, 'Invalid username or password');
      },
    );

    test('/auth/me returns canned user', () async {
      final res = await dio.get<Map<String, dynamic>>('/auth/me');

      expect(res.statusCode, 200);
      expect(res.data!['id'], 'mock-user-1');
      expect(res.data!['name'], 'Admin');
      expect(res.data!['email'], 'admin@example.com');
    });

    test('/auth/refresh with empty token -> 401', () async {
      Object? caught;
      try {
        await dio
            .post<Map<String, dynamic>>(
              '/auth/refresh',
              data: <String, dynamic>{'refreshToken': ''},
            )
            .asApi();
      } on Object catch (e) {
        caught = e;
      }

      expect(caught, isA<AuthException>());
    });

    test('/auth/refresh with valid token -> 200 + new tokens', () async {
      final res = await dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: <String, dynamic>{'refreshToken': 'any-non-empty'},
      );

      expect(res.statusCode, 200);
      expect(res.data!['accessToken'], isA<String>());
    });

    test('/auth/logout returns 204', () async {
      final res = await dio.post<dynamic>('/auth/logout');
      expect(res.statusCode, 204);
    });

    test('non-auth path falls through (would hit network)', () async {
      // 我们通过 BaseUrl 指向 invalid 域名 + connectTimeout 极短来证明
      // 非 auth 路径不会被短路。直接断言抛 DioException。
      dio.options.connectTimeout = const Duration(milliseconds: 200);
      await expectLater(
        dio.get<dynamic>('/users/42'),
        throwsA(isA<DioException>()),
      );
    });
  });
}
