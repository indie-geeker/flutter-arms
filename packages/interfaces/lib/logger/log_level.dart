/// 日志级别
enum LogLevel {
  /// 调试信息
  debug(0),

  /// 常规信息
  info(1),

  /// 警告信息
  warning(2),

  /// 错误信息
  error(3),

  /// 致命错误
  fatal(4);

  final int value;
  const LogLevel(this.value);

  bool operator >(LogLevel other) => value > other.value;
  bool operator >=(LogLevel other) => value >= other.value;
  bool operator <(LogLevel other) => value < other.value;
  bool operator <=(LogLevel other) => value <= other.value;
}