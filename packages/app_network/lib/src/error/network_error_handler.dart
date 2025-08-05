import 'package:app_interfaces/app_interfaces.dart';
import 'package:dio/dio.dart' as dio;

/// 网络错误处理器实现
///
/// 负责处理和转换各种网络错误，提供统一的错误处理机制
class NetworkErrorHandler implements INetworkErrorHandler {
  final Map<NetworkErrorType, String> _errorMessages;
  final bool _enableDetailedErrors;
  final Map<NetworkErrorType, Future<Object> Function(Object, RequestOptions)> _customHandlers = {};

  NetworkErrorHandler({
    Map<NetworkErrorType, String>? customErrorMessages,
    bool enableDetailedErrors = false,
  })  : _errorMessages = {
          ..._defaultErrorMessages,
          ...?customErrorMessages,
        },
        _enableDetailedErrors = enableDetailedErrors;

  static const Map<NetworkErrorType, String> _defaultErrorMessages = {
    NetworkErrorType.connectionTimeout: '连接超时，请检查网络连接',
    NetworkErrorType.receiveTimeout: '接收数据超时，请稍后重试',
    NetworkErrorType.sendTimeout: '发送数据超时，请稍后重试',
    NetworkErrorType.connectionError: '网络连接失败，请检查网络设置',
    NetworkErrorType.serverError: '服务器错误，请稍后重试',
    NetworkErrorType.clientError: '请求错误，请检查请求参数',
    NetworkErrorType.unauthorized: '未授权访问，请重新登录',
    NetworkErrorType.forbidden: '禁止访问，权限不足',
    NetworkErrorType.notFound: '请求的资源不存在',
    NetworkErrorType.conflict: '请求冲突，请稍后重试',
    NetworkErrorType.cancel: '请求已取消',
    NetworkErrorType.parseError: '数据解析失败',
    NetworkErrorType.businessError: '业务处理失败',
    NetworkErrorType.unknown: '未知错误，请稍后重试',
  };

  @override
  Future<Object> handleError(
    Object error,
    StackTrace stackTrace,
    RequestOptions options,
  ) async {
    if (error is NetworkException) {
      return error;
    }

    // 检查是否有自定义处理器
    final errorType = getErrorType(error);
    final customHandler = _customHandlers[errorType];
    if (customHandler != null) {
      return await customHandler(error, options);
    }

    // 默认处理
    final message = getErrorMessage(error);
    final statusCode = getStatusCode(error);

    return NetworkException(
      message: message,
      code: errorType.name,
      statusCode: statusCode,
      details: _enableDetailedErrors ? error.toString() : null,
      stackTrace: stackTrace,
    );
  }

  @override
  NetworkErrorType getErrorType(Object error) {
    if (error is dio.DioException) {
      switch (error.type) {
        case dio.DioExceptionType.connectionTimeout:
          return NetworkErrorType.connectionTimeout;
        case dio.DioExceptionType.sendTimeout:
          return NetworkErrorType.sendTimeout;
        case dio.DioExceptionType.receiveTimeout:
          return NetworkErrorType.receiveTimeout;
        case dio.DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          if (statusCode != null) {
            if (statusCode == 401) return NetworkErrorType.unauthorized;
            if (statusCode == 403) return NetworkErrorType.forbidden;
            if (statusCode == 404) return NetworkErrorType.notFound;
            if (statusCode == 409) return NetworkErrorType.conflict;
            if (statusCode >= 400 && statusCode < 500) return NetworkErrorType.clientError;
            if (statusCode >= 500) return NetworkErrorType.serverError;
          }
          return NetworkErrorType.serverError;
        case dio.DioExceptionType.cancel:
          return NetworkErrorType.cancel;
        case dio.DioExceptionType.connectionError:
          return NetworkErrorType.connectionError;
        case dio.DioExceptionType.badCertificate:
          return NetworkErrorType.connectionError;
        case dio.DioExceptionType.unknown:
          return NetworkErrorType.unknown;
      }
    }
    
    if (error is NetworkException) {
      // 尝试从 code 映射回 NetworkErrorType
      for (final type in NetworkErrorType.values) {
        if (type.name == error.code) {
          return type;
        }
      }
    }
    
    return NetworkErrorType.unknown;
  }

  @override
  String getErrorMessage(Object error, [String fallbackMessage = '网络请求失败，请稍后重试']) {
    final errorType = getErrorType(error);
    var message = _errorMessages[errorType] ?? fallbackMessage;
    
    // 如果启用详细错误信息，添加原始错误信息
    if (_enableDetailedErrors) {
      message += ' (详细信息: $error)';
    }
    
    return message;
  }

  @override
  int? getStatusCode(Object error) {
    if (error is dio.DioException) {
      return error.response?.statusCode;
    }
    if (error is NetworkException) {
      return error.statusCode;
    }
    return null;
  }

  @override
  bool isUnauthorizedError(Object error) {
    return getErrorType(error) == NetworkErrorType.unauthorized;
  }

  @override
  bool isConnectionError(Object error) {
    final errorType = getErrorType(error);
    return errorType == NetworkErrorType.connectionError ||
           errorType == NetworkErrorType.connectionTimeout;
  }

  @override
  bool isBusinessError(Object error) {
    return getErrorType(error) == NetworkErrorType.businessError;
  }

  @override
  bool isServerError(Object error) {
    return getErrorType(error) == NetworkErrorType.serverError;
  }

  @override
  String? getBusinessErrorCode(Object error) {
    if (error is NetworkException && error.code == 'business_error') {
      return error.details?.toString();
    }
    return null;
  }

  @override
  void registerErrorHandler(
    NetworkErrorType errorType,
    Future<Object> Function(Object error, RequestOptions options) handler,
  ) {
    _customHandlers[errorType] = handler;
  }

  /// 检查错误是否可重试
  bool isRetryableError(NetworkErrorType errorType) {
    switch (errorType) {
      case NetworkErrorType.connectionTimeout:
      case NetworkErrorType.receiveTimeout:
      case NetworkErrorType.sendTimeout:
      case NetworkErrorType.connectionError:
      case NetworkErrorType.serverError:
        return true;
      case NetworkErrorType.clientError:
      case NetworkErrorType.unauthorized:
      case NetworkErrorType.forbidden:
      case NetworkErrorType.notFound:
      case NetworkErrorType.conflict:
      case NetworkErrorType.cancel:
      case NetworkErrorType.parseError:
      case NetworkErrorType.businessError:
      case NetworkErrorType.unknown:
        return false;
    }
  }

  bool isAuthenticationError(NetworkErrorType errorType) {
    return errorType == NetworkErrorType.unauthorized;
  }

  bool isNetworkError(NetworkErrorType errorType) {
    switch (errorType) {
      case NetworkErrorType.connectionTimeout:
      case NetworkErrorType.receiveTimeout:
      case NetworkErrorType.sendTimeout:
      case NetworkErrorType.connectionError:
        return true;
      default:
        return false;
    }
  }



  /// 更新错误消息
  void updateErrorMessage(NetworkErrorType errorType, String message) {
    _errorMessages[errorType] = message;
  }

  /// 获取所有错误消息
  Map<NetworkErrorType, String> getAllErrorMessages() {
    return Map.unmodifiable(_errorMessages);
  }
}
