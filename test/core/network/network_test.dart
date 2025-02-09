import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_arms/core/network/network_config.dart';
import 'package:flutter_arms/core/network/interceptors/logging_interceptor.dart';

void main() {
  late Dio dio;

  setUp(() {
    dio = Dio(NetworkConfig.options);
    dio.interceptors.add(LoggingInterceptor());
  });

  group('Dio Network Tests', () {
    // test('should initialize Dio with correct configuration', () {
    //   expect(dio.options.baseUrl, equals(NetworkConfig.baseUrl));
      // expect(dio.options.connectTimeout?.inMilliseconds, equals(NetworkConfig.connectTimeout));
      // expect(dio.options.receiveTimeout?.inMilliseconds, equals(NetworkConfig.receiveTimeout));
      // expect(dio.options.sendTimeout?.inMilliseconds, equals(NetworkConfig.sendTimeout));
    // });

    // test('should have correct headers', () {
    //   expect(dio.options.headers['Content-Type'], equals('application/json'));
    //   expect(dio.options.headers['Accept'], equals('application/json'));
    // });

    // test('should have logging interceptor', () {
    //   final hasLoggingInterceptor = dio.interceptors
    //       .any((interceptor) => interceptor is LoggingInterceptor);
    //   expect(hasLoggingInterceptor, isTrue);
    // });
    //
    // test('should make successful GET request to httpbin', () async {
    //   final response = await dio.get('https://httpbin.org/get');
    //   expect(response.statusCode, equals(200));
    //   expect(response.data, isNotNull);
    // });
    //
    // test('should handle error response correctly', () async {
    //   try {
    //     await dio.get('https://httpbin.org/status/404');
    //     fail('Should throw DioException');
    //   } on DioException catch (e) {
    //     expect(e.response?.statusCode, equals(404));
    //   }
    // });

    // group('Timeout Tests', () {
    //   const timeoutDuration = Duration(milliseconds: 1000);
    //
    //   setUp(() {
    //     // 为超时测试配置较短的超时时间
    //     dio.options = dio.options.copyWith(
    //       receiveTimeout: timeoutDuration,
    //       connectTimeout: timeoutDuration,
    //       sendTimeout: timeoutDuration,
    //     );
    //   });
    //
    //   test('should timeout for delayed response', () async {
    //     try {
    //       await dio.get('https://httpbin.org/delay/5');
    //       fail('Should throw DioException');
    //     } on DioException catch (e) {
    //       // 验证超时类型
    //       expect(e.type, equals(DioExceptionType.receiveTimeout));
    //
    //       // 验证超时消息包含预期的持续时间
    //       expect(e.message, contains('0:00:01.000000'));
    //       expect(e.message, contains('receiveTimeout'));
    //
    //       // 验证请求信息
    //       expect(e.requestOptions.method, equals('GET'));
    //       expect(e.requestOptions.path, equals('https://httpbin.org/delay/5'));
    //
    //       // 验证请求头
    //       expect(e.requestOptions.headers['Content-Type'], equals('application/json'));
    //       expect(e.requestOptions.headers['Accept'], equals('application/json'));
    //     }
    //   });
    // });
  });
}
