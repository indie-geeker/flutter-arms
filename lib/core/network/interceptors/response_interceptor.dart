import 'package:flutter/material.dart';

import '../../errors/failures.dart';
import '../converter/adaptable_response_converter.dart';
import 'package:dio/dio.dart';
import '../adapters/response_adapter.dart';

class ResponseInterceptor extends Interceptor {
  final AdaptableResponseConverter _converter;

  ResponseInterceptor(this._converter);
  
  // 添加获取adapter的getter方法
  ResponseAdapter get adapter => _converter.adapter;

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // 检查是否有RawResponseResult注解
    final rawResponseResult = response.requestOptions.extra['raw_response_result'] as bool?;

    if (rawResponseResult == true) {
      // 如果有RawResponseResult注解，直接返回原始数据
      handler.next(response);
      return;
    }

    // 处理响应数据
    if (response.data is Map<String, dynamic>) {
      try {
        // 使用适配器检查响应格式
        final result = _converter.convert(
            response,
                (data) => data  // 这里只进行格式检查
        );

        // 如果响应格式正确，可以保持不变
        // 如果响应中有错误，可以处理它
        if (result is Failure) {
          // 处理API业务错误，例如将其转换为标准格式
          // 或者抛出异常
        }
      } catch (e) {
        // 处理转换错误
        debugPrint('Response conversion error: $e');
      }
    }

    handler.next(response);
  }
}