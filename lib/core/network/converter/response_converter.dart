import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/response_result.dart';

/// 响应数据转换器
/// 用于处理API响应数据的包装和解包装
class ResponseConverter extends Converter<Map<String, dynamic>, dynamic> {
  const ResponseConverter();

  @override
  dynamic convert(Map<String, dynamic> input) {
    // 检查是否需要跳过ResponseResult包装
    final skipResponseResult = input['_skip_response_result'] as bool?;
    if (skipResponseResult == true) {
      // 移除标记并返回原始数据
      input.remove('_skip_response_result');
      return input;
    }

    // 已经是ResponseResult格式
    if (input.containsKey('success') && input.containsKey('message')) {
      return input;
    }

    // 包装成ResponseResult格式
    return ResponseResult<dynamic>.fromJson(
      input,
      (json) => json,
    );
  }

  @override
  Sink<Map<String, dynamic>> startChunkedConversion(Sink<dynamic> sink) {
    throw UnsupportedError("Chunked conversion is not supported");
  }
}
