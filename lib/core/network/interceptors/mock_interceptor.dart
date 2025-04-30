import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class MockInterceptor extends Interceptor {
  @override
  Future<dynamic> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    debugPrint("MockInterceptor onRequest:${options.path}");
    switch (options.path) {
      case "/user/login":
        // 模拟延迟 - 使用await等待延迟完成
        await mockDelay();
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

  // 返回Future使方法可以被await
  Future<void> mockDelay() async {
    await Future.delayed(const Duration(seconds: 2));
  }
}
