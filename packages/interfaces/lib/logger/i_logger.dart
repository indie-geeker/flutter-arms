import 'log_level.dart';
import 'log_output.dart';

/// 日志抽象接口
abstract class ILogger {
  /// 初始化日志系统
  void init({
    LogLevel level = LogLevel.debug,
    List<LogOutput>? outputs,
  });

  /// 调试日志
  void debug(
      String message, {
        dynamic error,
        StackTrace? stackTrace,
        Map<String, dynamic>? extras,
      });

  /// 信息日志
  void info(
      String message, {
        Map<String, dynamic>? extras,
      });

  /// 警告日志
  void warning(
      String message, {
        dynamic error,
        StackTrace? stackTrace,
        Map<String, dynamic>? extras,
      });

  /// 错误日志
  void error(
      String message, {
        dynamic error,
        StackTrace? stackTrace,
        Map<String, dynamic>? extras,
      });

  /// 严重错误日志
  void fatal(
      String message, {
        dynamic error,
        StackTrace? stackTrace,
        Map<String, dynamic>? extras,
      });

  /// 自定义级别日志
  void log(
      LogLevel level,
      String message, {
        dynamic error,
        StackTrace? stackTrace,
        Map<String, dynamic>? extras,
      });

  /// 设置日志级别
  void setLevel(LogLevel level);

  /// 添加日志输出器
  void addOutput(LogOutput output);
}