import 'package:flutter_arms/core/network/api_request.dart';

/// 应用级 API Client 端口。
abstract interface class ApiClient {
  /// 实现名称，用于日志或诊断。
  String get adapterName;

  /// 发送请求并返回解码后的数据。
  Future<T> send<T>(ApiRequest<T> request);
}
