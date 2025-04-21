import 'dart:convert';

import 'package:dio/dio.dart';

import '../utils/logger_util.dart';

/// Dio 日志拦截器
///
/// 用于记录 Dio 网络请求和响应的日志
class CustomLogInterceptor extends Interceptor {
  final bool request;
  final bool requestHeader;
  final bool requestBody;
  final bool responseHeader;
  final bool responseBody;
  final bool error;
  
  /// 是否打印请求/响应数据的完整内容
  final bool logFullData;
  
  /// 数据长度超过此值时截断
  final int maxDataLength;

  CustomLogInterceptor({
    this.request = true,
    this.requestHeader = true,
    this.requestBody = true,
    this.responseHeader = true,
    this.responseBody = true,
    this.error = true,
    this.logFullData = false,
    this.maxDataLength = 2000,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (request) {
      _logRequest(options);
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (responseHeader || responseBody) {
      _logResponse(response);
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (error) {
      _logError(err);
    }
    super.onError(err, handler);
  }

  /// 记录请求日志
  void _logRequest(RequestOptions options) {
    logger.i('*** 请求 ***');
    logger.i('请求方法: ${options.method}');
    logger.i('请求URL: ${options.uri}');
    
    if (requestHeader) {
      logger.d('请求头: ${_formatJson(options.headers)}');
    }
    
    if (requestBody && options.data != null) {
      logger.d('请求体: ${_formatRequestData(options.data)}');
    }
  }

  /// 记录响应日志
  void _logResponse(Response response) {
    logger.i('*** 响应 ***');
    logger.i('状态码: ${response.statusCode}');
    logger.i('请求URL: ${response.requestOptions.uri}');
    
    if (responseHeader) {
      logger.d('响应头: ${_formatJson(response.headers.map)}');
    }
    
    if (responseBody) {
      logger.d('响应体: ${_formatResponseData(response.data)}');
    }
  }

  /// 记录错误日志
  void _logError(DioException err) {
    logger.e('*** 错误 ***');
    logger.e('请求URL: ${err.requestOptions.uri}');
    logger.e('错误类型: ${err.type}');
    logger.e('错误消息: ${err.message}');
    
    if (err.response != null) {
      logger.e('状态码: ${err.response?.statusCode}');
      if (responseBody && err.response?.data != null) {
        logger.e('错误响应: ${_formatResponseData(err.response?.data)}');
      }
    }
  }

  /// 格式化请求数据
  String _formatRequestData(dynamic data) {
    if (data is Map || data is List) {
      try {
        String jsonStr = json.encode(data);
        return _truncateIfNeeded(jsonStr);
      } catch (e) {
        return _truncateIfNeeded(data.toString());
      }
    } else if (data is FormData) {
      try {
        Map<String, dynamic> formMap = {};
        data.fields.forEach((field) => formMap[field.key] = field.value);
        data.files.forEach((file) => formMap[file.key] = 'FILE: ${file.value.filename}');
        return _truncateIfNeeded(json.encode(formMap));
      } catch (e) {
        return _truncateIfNeeded(data.toString());
      }
    } else {
      return _truncateIfNeeded(data.toString());
    }
  }

  /// 格式化响应数据
  String _formatResponseData(dynamic data) {
    if (data is Map || data is List) {
      try {
        String jsonStr = _formatJson(data);
        return _truncateIfNeeded(jsonStr);
      } catch (e) {
        return _truncateIfNeeded(data.toString());
      }
    } else if (data is String) {
      try {
        // 尝试解析 JSON 字符串
        var jsonData = json.decode(data);
        return _truncateIfNeeded(_formatJson(jsonData));
      } catch (e) {
        return _truncateIfNeeded(data);
      }
    } else {
      return _truncateIfNeeded(data.toString());
    }
  }

  /// 格式化 JSON 数据
  String _formatJson(dynamic json) {
    try {
      if (logFullData) {
        var encoder = const JsonEncoder.withIndent('  ');
        return encoder.convert(json);
      } else {
        return jsonEncode(json);
      }
    } catch (e) {
      return json.toString();
    }
  }

  /// 如果数据太长，则截断
  String _truncateIfNeeded(String data) {
    if (!logFullData && data.length > maxDataLength) {
      return '${data.substring(0, maxDataLength)}... (${data.length} 字符)';
    }
    return data;
  }
}
