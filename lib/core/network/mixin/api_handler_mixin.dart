
import 'package:dio/dio.dart';

import '../../errors/failures.dart';
import '../../functional/either.dart';
import '../models/response_result.dart';
import '../models/response_status.dart';
import '../utils/dio_error_handler.dart';


mixin ApiHandlerMixin {
  /// 处理包装在ResponseResult中的请求
  Future<Either<Failure, T>> handleRemoteRequest<T>({
    required Future<ResponseResult<T>> Function() request,
    bool allowNullData = false,
    T? defaultValue,
    String? nullDataMessage,
    bool Function(int code)? customSuccessCheck,
  }) async {
    try {
      final response = await request();

      // 自定义成功码检查
      final isSuccess = customSuccessCheck?.call(response.success) ?? (response.success == ResponseStatus.success.code);

      if (isSuccess) {
        if (response.data != null) {
          return Right(response.data as T);
        } else if (allowNullData) {
          return Right(defaultValue as T);
        } else {
          return Left(ServerFailure(nullDataMessage ?? '数据为空'));
        }
      } else {
        final failure = ServerFailure(response.message ?? '未知错误');
        return Left(failure);
      }
    } on DioException catch (e) {
      final failure = DioErrorHandler.handleError(e);
      return Left(failure);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  /// 处理原始响应数据的请求（不包装在ResponseResult中）
  Future<Either<Failure, T>> handleRawRemoteRequest<T>({
    required Future<T> Function() request,
    bool allowNullData = false,
    T? defaultValue,
    String? nullDataMessage,
  }) async {
    try {
      final response = await request();
      
      if (response != null) {
        return Right(response);
      } else if (allowNullData) {
        return Right(defaultValue as T);
      } else {
        return Left(ServerFailure(nullDataMessage ?? '数据为空'));
      }
    } on DioException catch (e) {
      return Left(DioErrorHandler.handleError(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  /// 用于处理需要数据转换的请求
  /// [T] 目标类型
  /// [R] 原始响应数据类型
  /// [request] API请求函数
  /// [mapper] 数据转换函数
  /// [allowNullData] 是否允许空数据
  /// [defaultValue] 当数据为空且允许空数据时的默认值
  /// [nullDataMessage] 当数据为空且不允许空数据时的错误消息
  /// [customSuccessCheck] 自定义成功状态检查函数
  Future<Either<Failure, T>> handleRemoteRequestWithMapping<T, R>({
    required Future<ResponseResult<R>> Function() request,
    required T Function(R data) mapper,
    bool allowNullData = false,
    T? defaultValue,
    String? nullDataMessage,
    bool Function(int code)? customSuccessCheck,
  }) async {
    try {
      // 获取原始响应
      final response = await handleRemoteRequest<R>(
        request: request,
        allowNullData: allowNullData,
        defaultValue: null,  // 在这里不使用默认值，因为我们需要先进行映射
        nullDataMessage: nullDataMessage,
        customSuccessCheck: customSuccessCheck,
      );

      // 处理响应结果
      return response.fold(
            (failure) => Left(failure),  // 如果是失败，直接返回失败
            (data) {
          try {
            if (data == null) {
              if (allowNullData && defaultValue != null) {
                return Right(defaultValue);
              }
              return Left(ServerFailure(nullDataMessage ?? '数据为空'));
            }
            // 执行数据转换
            final mappedData = mapper(data);
            return Right(mappedData);
          } catch (e) {
            // 处理映射过程中可能发生的错误
            return Left(UnknownFailure('数据转换失败: ${e.toString()}'));
          }
        },
      );
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

}