import 'package:app_interfaces/app_interfaces.dart';

/// 响应解析拦截器
///
/// 负责在响应阶段解析服务器返回的数据
/// 将解析逻辑从 NetworkConfig 中分离出来，提高灵活性
class ResponseParserInterceptor implements IRequestInterceptor {
  final ResponseParser parser;
  final bool _enabled;

  /// 创建响应解析拦截器
  ///
  /// [parser] 响应解析器
  /// [enabled] 是否启用拦截器，默认为 true
  ResponseParserInterceptor(
    this.parser, {
    bool enabled = true,
  }) : _enabled = enabled;

  @override
  int get priority => 100; // 较低优先级，在其他拦截器之后执行

  @override
  bool get enabled => _enabled;

  @override
  Future<RequestOptions> onRequest(RequestOptions options) async {
    // 解析拦截器不需要修改请求
    return options;
  }

  @override
  Future<ApiResponse<T>> onResponse<T>(
    ApiResponse<T> response,
    RequestOptions options,
  ) async {
    // 检查是否需要解析响应
    // 如果响应类型不是 JSON，则跳过解析
    if (options.responseType != ResponseType.json) {
      return response;
    }

    // 检查响应数据是否为 Map
    if (response.data is! Map<String, dynamic>) {
      return response;
    }

    try {
      // 使用解析器解析响应数据
      final jsonData = response.data as Map<String, dynamic>;

      // 注意：这里 parser.parse 需要一个 fromJson 函数
      // 但在拦截器中我们无法知道具体的类型转换
      // 所以这里只做基础的解析结构验证
      // 实际的类型转换应该在业务层完成

      // 检查解析器定义的响应结构
      // 这里假设解析器会验证响应格式的正确性
      final parsedResult = parser.parse<dynamic>(
        jsonData,
        (data) => data, // 恒等函数，不做类型转换
      );

      // 如果解析成功，返回原响应
      if (parsedResult.isSuccess) {
        return response;
      }

      // 如果解析失败，抛出业务错误
      throw BusinessException(
        message: parsedResult.apiResponse.message ?? 'Parse failed',
        code: 'parse_error',
        details: parsedResult.apiResponse.data,
      );
    } catch (e) {
      // 如果是已知的异常，直接重新抛出
      if (e is AppException) {
        rethrow;
      }

      // 其他异常包装为数据异常
      throw DataException(
        message: 'Failed to parse response: $e',
        code: 'response_parse_error',
        details: e,
      );
    }
  }

  @override
  Future<Object> onError(Object error, RequestOptions options) async {
    // 解析拦截器不处理错误
    return error;
  }
}

/// 支持自定义解析器的响应解析拦截器
///
/// 允许为特定请求指定不同的解析器
class CustomizableResponseParserInterceptor implements IRequestInterceptor {
  final ResponseParser defaultParser;
  final bool _enabled;

  /// 自定义解析器映射
  /// key: 请求路径模式（支持通配符）
  /// value: 对应的解析器
  final Map<String, ResponseParser> _customParsers = {};

  /// 创建可自定义的响应解析拦截器
  ///
  /// [defaultParser] 默认解析器
  /// [enabled] 是否启用拦截器，默认为 true
  CustomizableResponseParserInterceptor(
    this.defaultParser, {
    bool enabled = true,
  }) : _enabled = enabled;

  /// 为特定路径注册自定义解析器
  ///
  /// [pathPattern] 路径模式，支持简单的通配符 *
  /// [parser] 自定义解析器
  void registerParser(String pathPattern, ResponseParser parser) {
    _customParsers[pathPattern] = parser;
  }

  /// 移除特定路径的自定义解析器
  void unregisterParser(String pathPattern) {
    _customParsers.remove(pathPattern);
  }

  /// 清除所有自定义解析器
  void clearCustomParsers() {
    _customParsers.clear();
  }

  @override
  int get priority => 100;

  @override
  bool get enabled => _enabled;

  @override
  Future<RequestOptions> onRequest(RequestOptions options) async {
    return options;
  }

  @override
  Future<ApiResponse<T>> onResponse<T>(
    ApiResponse<T> response,
    RequestOptions options,
  ) async {
    if (options.responseType != ResponseType.json) {
      return response;
    }

    if (response.data is! Map<String, dynamic>) {
      return response;
    }

    try {
      // 选择合适的解析器
      final parser = _selectParser(options.path);
      final jsonData = response.data as Map<String, dynamic>;

      final parsedResult = parser.parse<dynamic>(
        jsonData,
        (data) => data,
      );

      if (parsedResult.isSuccess) {
        return response;
      }

      throw BusinessException(
        message: parsedResult.apiResponse.message ?? 'Parse failed',
        code: 'parse_error',
        details: parsedResult.apiResponse.data,
      );
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }

      throw DataException(
        message: 'Failed to parse response: $e',
        code: 'response_parse_error',
        details: e,
      );
    }
  }

  @override
  Future<Object> onError(Object error, RequestOptions options) async {
    return error;
  }

  /// 根据请求路径选择解析器
  ResponseParser _selectParser(String path) {
    // 遍历自定义解析器，查找匹配的路径模式
    for (final entry in _customParsers.entries) {
      if (_matchPattern(entry.key, path)) {
        return entry.value;
      }
    }

    // 如果没有匹配的自定义解析器，使用默认解析器
    return defaultParser;
  }

  /// 简单的路径模式匹配
  ///
  /// 支持 * 通配符
  bool _matchPattern(String pattern, String path) {
    // 如果模式不包含通配符，直接比较
    if (!pattern.contains('*')) {
      return pattern == path;
    }

    // 将模式转换为正则表达式
    final regexPattern = pattern
        .replaceAll('*', '.*')
        .replaceAll('/', r'\/');

    final regex = RegExp('^$regexPattern\$');
    return regex.hasMatch(path);
  }
}
