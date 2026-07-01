import 'package:dio/dio.dart';
import 'package:flutter_arms/core/error/app_exception.dart';
import 'package:flutter_arms/core/error/app_exception_mapper.dart';
import 'package:flutter_arms/core/network/api_client.dart';
import 'package:flutter_arms/core/network/api_request.dart';
import 'package:flutter_arms/core/network/dio_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dio_api_client.g.dart';

/// Dio API Client 适配器。
final class DioApiClient implements ApiClient {
  /// 构造函数。
  const DioApiClient(this._dio);

  final Dio _dio;

  @override
  String get adapterName => 'dio';

  @override
  Future<T> send<T>(ApiRequest<T> request) async {
    try {
      final response = await _dio.request<Object?>(
        request.path,
        data: request.body,
        queryParameters: request.query,
        options: Options(
          method: request.method.name.toUpperCase(),
          headers: request.headers,
          extra: <String, Object?>{'requiresAuth': request.requiresAuth},
        ),
      );
      return request.decode(response.data);
    } on DioException catch (error, stackTrace) {
      final inner = error.error;
      if (inner is AppException) {
        throw inner;
      }
      throw AppExceptionMapper.fromDio(error, stackTrace);
    } on AppException {
      rethrow;
    } on Object catch (error, stackTrace) {
      throw UnknownException(cause: error, stackTrace: stackTrace);
    }
  }
}

/// 默认 ApiClient 依赖。
@Riverpod(keepAlive: true)
ApiClient apiClient(Ref ref) {
  return DioApiClient(ref.read(dioProvider));
}
