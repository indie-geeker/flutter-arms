import '../../../app_interfaces.dart';
import '../configs/cache_policy.dart';
import 'cache_decision.dart';

/**
 * Description:
 * Author: wen
 * Date: 10/16/25
 **/

/// Interface for resolving cache decisions based on policy
abstract class ICachePolicyResolver {
  /// Resolve whether to use cache or network based on policy
  CacheDecision resolve<T>({
    required CachePolicy policy,
    required RequestOptions options,
    ApiResponse<T>? cachedResponse,
    bool isCacheExpired,
    bool isCacheStale,
  });
}