import 'package:app_interfaces/app_interfaces.dart';
import 'package:flutter/foundation.dart';

/// 请求去重拦截器
///
/// 防止重复的请求同时发送，提高性能并减少服务器负载
/// 当检测到相同的请求正在进行时，会返回正在进行的请求的 Future
class DeduplicationInterceptor implements IRequestInterceptor {
  final bool _enabled;
  final Duration _expirationDuration;

  /// 正在进行的请求缓存
  /// key: 请求唯一标识
  /// value: 请求的 Future
  final Map<String, Future<ApiResponse>> _pendingRequests = {};

  /// 请求时间戳
  /// 用于清理过期的请求缓存
  final Map<String, DateTime> _requestTimestamps = {};

  /// 创建请求去重拦截器
  ///
  /// [expirationDuration] 请求缓存过期时间，默认 5 分钟
  /// [enabled] 是否启用拦截器，默认为 true
  DeduplicationInterceptor({
    Duration? expirationDuration,
    bool enabled = true,
  })  : _expirationDuration = expirationDuration ?? const Duration(minutes: 5),
        _enabled = enabled;

  @override
  int get priority => 10; // 高优先级，在其他拦截器之前执行

  @override
  bool get enabled => _enabled;

  @override
  Future<RequestOptions> onRequest(RequestOptions options) async {
    // 定期清理过期请求
    _cleanupExpiredRequests();

    // 生成请求唯一键
    final requestKey = _generateRequestKey(options);

    // 检查是否有相同的请求正在进行
    if (_pendingRequests.containsKey(requestKey)) {
      debugPrint(
          '[DeduplicationInterceptor] 请求去重: ${options.method.name} ${options.path}');

      // 将去重信息存储在 extra 中，供后续处理
      return options.copyWith(
        extra: {
          ...options.extra,
          '_deduplication_key': requestKey,
          '_deduplication_hit': true,
        },
      );
    }

    // 标记请求为新请求
    return options.copyWith(
      extra: {
        ...options.extra,
        '_deduplication_key': requestKey,
        '_deduplication_hit': false,
      },
    );
  }

  @override
  Future<ApiResponse<T>> onResponse<T>(
    ApiResponse<T> response,
    RequestOptions options,
  ) async {
    // 从 extra 中获取去重信息
    final requestKey = options.extra['_deduplication_key'] as String?;
    final isDeduplicationHit = options.extra['_deduplication_hit'] as bool? ?? false;

    // 如果是去重命中，不需要清理缓存（因为不是我们创建的）
    if (isDeduplicationHit) {
      return response;
    }

    // 清理已完成的请求缓存
    if (requestKey != null) {
      _pendingRequests.remove(requestKey);
      _requestTimestamps.remove(requestKey);
    }

    return response;
  }

  @override
  Future<Object> onError(Object error, RequestOptions options) async {
    // 发生错误时也要清理缓存
    final requestKey = options.extra['_deduplication_key'] as String?;
    final isDeduplicationHit = options.extra['_deduplication_hit'] as bool? ?? false;

    if (!isDeduplicationHit && requestKey != null) {
      _pendingRequests.remove(requestKey);
      _requestTimestamps.remove(requestKey);
    }

    return error;
  }

  /// 注册正在进行的请求
  ///
  /// 应该在实际发送请求之前调用
  /// 这个方法需要在 NetworkClient 中调用
  void registerPendingRequest(
    String requestKey,
    Future<ApiResponse> requestFuture,
  ) {
    _pendingRequests[requestKey] = requestFuture;
    _requestTimestamps[requestKey] = DateTime.now();
  }

  /// 检查是否存在正在进行的相同请求
  Future<ApiResponse<T>>? getPendingRequest<T>(String requestKey) {
    return _pendingRequests[requestKey] as Future<ApiResponse<T>>?;
  }

  /// 生成请求唯一键
  String _generateRequestKey(RequestOptions options) {
    final buffer = StringBuffer();
    buffer.write(options.method.name);
    buffer.write('|');
    buffer.write(options.path);

    // 添加查询参数
    if (options.queryParameters?.isNotEmpty == true) {
      final sortedParams = Map.fromEntries(
        options.queryParameters!.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key)),
      );
      buffer.write('|');
      buffer.write(
        Uri(
          queryParameters:
              sortedParams.map((k, v) => MapEntry(k, v.toString())),
        ).query,
      );
    }

    // 添加请求体（仅对于 POST/PUT/PATCH/DELETE 请求）
    if (options.data != null && _isModifyingMethod(options.method)) {
      buffer.write('|');
      buffer.write(options.data.toString().hashCode);
    }

    return buffer.toString();
  }

  /// 检查是否为修改性方法
  bool _isModifyingMethod(RequestMethod method) {
    return method == RequestMethod.post ||
        method == RequestMethod.put ||
        method == RequestMethod.delete ||
        method == RequestMethod.patch;
  }

  /// 清理过期的请求缓存
  void _cleanupExpiredRequests() {
    final now = DateTime.now();
    final expiredKeys = <String>[];

    _requestTimestamps.forEach((key, timestamp) {
      if (now.difference(timestamp) > _expirationDuration) {
        expiredKeys.add(key);
      }
    });

    for (final key in expiredKeys) {
      _pendingRequests.remove(key);
      _requestTimestamps.remove(key);
    }

    if (expiredKeys.isNotEmpty) {
      debugPrint(
          '[DeduplicationInterceptor] 清理了 ${expiredKeys.length} 个过期请求缓存');
    }
  }

  /// 获取请求去重统计信息
  Map<String, dynamic> getStats() {
    return {
      'pending_requests_count': _pendingRequests.length,
      'cached_timestamps_count': _requestTimestamps.length,
      'oldest_request_age_minutes': _getOldestRequestAge(),
    };
  }

  /// 获取最旧请求的年龄（分钟）
  int _getOldestRequestAge() {
    if (_requestTimestamps.isEmpty) return 0;

    final now = DateTime.now();
    final oldestTimestamp =
        _requestTimestamps.values.reduce((a, b) => a.isBefore(b) ? a : b);

    return now.difference(oldestTimestamp).inMinutes;
  }

  /// 清除所有缓存的请求
  void clear() {
    _pendingRequests.clear();
    _requestTimestamps.clear();
  }

  /// 强制移除特定请求的缓存
  void removeRequest(String requestKey) {
    _pendingRequests.remove(requestKey);
    _requestTimestamps.remove(requestKey);
  }
}

/// RequestOptions 扩展方法 (已弃用，使用内置的 copyWith)
/// 保留此扩展以避免破坏现有代码，但不再推荐使用
@Deprecated('Use the built-in copyWith method instead')
extension RequestOptionsExtension on RequestOptions {
  // 扩展方法已移除，请使用 RequestOptions 内置的 copyWith 方法
}
