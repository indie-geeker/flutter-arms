import 'package:dio/dio.dart';

class MockInterceptor extends Interceptor {
  @override
  Future onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    switch (options.path) {
      case "/user/login":
        // 模拟延迟
        mockDelay();
        // 返回本地数据
        return handler.resolve(Response(requestOptions: options, data: {
          "code": 0,
          "data": {"token": "123456", "userId": "123456", "username": "张三"}
        }));

      default:
        break;
    }

    return super.onRequest(options, handler);
  }

  void mockDelay() async {
    await Future.delayed(const Duration(seconds: 2));
  }
}
