
// 共性行为:
// API调用的错误处理
// 响应解析的通用逻辑
// 请求头管理（如认证Token）

import '../errors/error_handler.dart';
import '../errors/result.dart';
import '../network/api_client.dart';

abstract class BaseRemoteDataSource {
  final ApiClient client;
  final ErrorHandler errorHandler;
  
  BaseRemoteDataSource(this.client, this.errorHandler);

  Future<Result<T>> safeApiCall<T>(Future<T> Function() apiCall) async{
    return errorHandler.handleException(() async{
      return await apiCall();
    });
  }
}