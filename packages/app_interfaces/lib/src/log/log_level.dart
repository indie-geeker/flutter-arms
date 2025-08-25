/// 日志级别枚举
enum LogLevel {
  /// 详细日志，用于开发调试
  verbose,

  /// 调试日志
  debug,

  /// 信息日志
  info,

  /// 警告日志
  warning,

  /// 错误日志
  error,

  /// 严重错误日志
  fatal;

  /// 获取级别值，数值越大级别越高
  int get value {
    switch (this) {
      case LogLevel.verbose:
        return 0;
      case LogLevel.debug:
        return 1;
      case LogLevel.info:
        return 2;
      case LogLevel.warning:
        return 3;
      case LogLevel.error:
        return 4;
      case LogLevel.fatal:
        return 5;
    }
  }

  /// 是否应该记录指定级别的日志
  bool shouldLog(LogLevel minLevel) => value >= minLevel.value;
}