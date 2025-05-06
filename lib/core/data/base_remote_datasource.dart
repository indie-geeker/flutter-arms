// 共性行为:
// API调用的错误处理
// 响应解析的通用逻辑
// 请求头管理（如认证Token）

import 'package:flutter_arms/core/network/providers/network_provider.dart';
import 'package:retrofit/retrofit.dart';

import '../errors/error_handler.dart';
import '../errors/result.dart';
import '../network/adapters/response_adapter.dart';
import '../network/api_client.dart';

abstract class BaseRemoteDataSource {
  final ApiClientWrapper clientWrapper;
  final ErrorHandler errorHandler;
  
  BaseRemoteDataSource(this.clientWrapper, this.errorHandler);
  
  // 访问 ApiClient
  ApiClient get apiClient => clientWrapper.client;
  
  // 访问 ResponseAdapter
  ResponseAdapter get adapter => clientWrapper.adapter;


  Future<Result<T>> safeApiCall<T>(Future<T> Function() apiCall) async {
    // 先等待 apiCall 完成
    final T value = await apiCall();
    // 然后将结果传给 handleException
    return errorHandler.handleException<T>(() => value);
  }

  /// 解析响应数据，处理标准响应格式
  /// 会自动从完整响应中提取data部分传递给fromJson函数
  T parseResponse<T>(HttpResponse response, T Function(Map<String, dynamic>) fromJson) {
    final map = _extractMapFromResponse(response);
    
    // 使用adapter处理标准响应格式
    // 提取data部分数据
    final data = adapter.getData(map);
    if (data is Map<String, dynamic>) {
      // 将data部分传递给fromJson函数
      return fromJson(data);
    } else if (data == null && T == Null) {
      // 处理无数据返回的情况
      return null as T;
    }

    throw Exception('响应数据格式不正确: ${data.runtimeType}');
  }

  Map<String, dynamic> _extractMapFromResponse(HttpResponse response) {
    if (response.data is Map<String, dynamic>) {
      return response.data as Map<String, dynamic>;
    } else {
      throw Exception('网络请求响应体不是 Map<String, dynamic>，实际类型为: ${response.data.runtimeType}');
    }
  }
}