import 'package:dio/dio.dart';
import '../annotations/skip_response_result.dart';
import '../models/response_result.dart';
import '../models/response_status.dart';
import '../converter/response_converter.dart';

class ResponseInterceptor extends Interceptor {
  final _converter = const ResponseConverter();

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // 检查是否有SkipResponseResult注解
    final skipResponseResult = response.requestOptions.extra['skip_response_result'] as bool?;

    if (skipResponseResult == true) {
      // 如果有SkipResponseResult注解，直接返回原始数据
      handler.next(response);
      return;
    }

    // 否则包装成ResponseResult格式
    if (response.data is Map<String, dynamic>) {
      // 使用转换器处理响应数据
      response.data = _converter.convert(response.data as Map<String, dynamic>);
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 如果错误响应不是标准格式，转换为标准格式
    if (err.response?.data is! Map<String, dynamic> ||
        !err.response!.data.containsKey('code')) {
      ResponseResult<dynamic> responseResult = ResponseResult<dynamic>(
        success: err.response?.statusCode ?? ResponseStatus.unknownError.code,
        message: err.message ?? ResponseStatus.unknownError.message,
        data: null,
      );
      err.response?.data = responseResult;
    }
    handler.next(err);
  }
}