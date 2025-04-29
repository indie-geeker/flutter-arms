import 'package:dio/dio.dart';
import '../annotations/skip_response_result.dart';

// class MethodMetadataInterceptor extends Interceptor {
//   @override
//   void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
//     // 检查是否有SkipResponseResult注解
//     final methodMetadata = options.extra['method_metadata'];
//     if (methodMetadata != null) {
//       final annotations = methodMetadata.annotations;
//       final hasSkipResponseResult = annotations.any((a) => a is SkipResponseResult);
//       options.extra['skip_response_result'] = hasSkipResponseResult;
//     }
//     handler.next(options);
//   }
// }
