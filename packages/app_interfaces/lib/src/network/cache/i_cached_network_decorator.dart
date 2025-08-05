
import 'package:app_interfaces/src/network/models/api_response.dart';

import '../models/request_options.dart';
import 'cache_strategy_type.dart';

// /// 网络请求的缓存策略装饰器接口
// ///
// /// 用于在不修改原有请求的情况下添加缓存功能
// abstract class ICachedNetworkDecorator {
//   /// 执行带缓存的请求
//   ///
//   /// [requestFunc] 原始请求函数
//   /// [options] 请求选项
//   /// [cacheStrategy] 缓存策略类型
//   ///
//   /// 返回响应结果
//   Future<ApiResponse<T>> executeCached<T>(
//       Future<ApiResponse<T>> Function() requestFunc,
//       RequestOptions options, {
//         CacheStrategyType cacheStrategy = CacheStrategyType.networkFirst,
//       });
// }
