/// 应用日志端口。
abstract interface class AppLog {
  /// 调试日志。
  void debug(Object message, [Object? error, StackTrace? stackTrace]);

  /// 普通信息日志。
  void info(Object message, [Object? error, StackTrace? stackTrace]);

  /// 警告日志。
  void warning(Object message, [Object? error, StackTrace? stackTrace]);

  /// 错误日志。
  void error(Object message, [Object? error, StackTrace? stackTrace]);

  /// 处理未捕获异常或框架异常。
  void handle(Object error, StackTrace? stackTrace, [String? context]);
}
