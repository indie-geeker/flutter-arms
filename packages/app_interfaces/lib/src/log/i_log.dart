import '../log/log_entity.dart';
import 'log_level.dart';

/// 日志接口
///
/// 定义应用日志记录功能
abstract class ILogger {
  /// 记录调试日志
  ///
  /// [message] 日志消息
  /// [tag] 日志标签
  /// [error] 错误对象
  /// [stackTrace] 堆栈跟踪
  void debug(
      String message, {
        String? tag,
        Object? error,
        StackTrace? stackTrace,
      });

  /// 记录信息日志
  ///
  /// [message] 日志消息
  /// [tag] 日志标签
  /// [error] 错误对象
  /// [stackTrace] 堆栈跟踪
  void info(
      String message, {
        String? tag,
        Object? error,
        StackTrace? stackTrace,
      });

  /// 记录警告日志
  ///
  /// [message] 日志消息
  /// [tag] 日志标签
  /// [error] 错误对象
  /// [stackTrace] 堆栈跟踪
  void warning(
      String message, {
        String? tag,
        Object? error,
        StackTrace? stackTrace,
      });

  /// 记录错误日志
  ///
  /// [message] 日志消息
  /// [tag] 日志标签
  /// [error] 错误对象
  /// [stackTrace] 堆栈跟踪
  void error(
      String message, {
        String? tag,
        Object? error,
        StackTrace? stackTrace,
      });

  /// 记录严重错误日志
  ///
  /// [message] 日志消息
  /// [tag] 日志标签
  /// [error] 错误对象
  /// [stackTrace] 堆栈跟踪
  void fatal(
      String message, {
        String? tag,
        Object? error,
        StackTrace? stackTrace,
      });

  /// 记录日志
  ///
  /// [level] 日志级别
  /// [message] 日志消息
  /// [tag] 日志标签
  /// [error] 错误对象
  /// [stackTrace] 堆栈跟踪
  void log(
      LogLevel level,
      String message, {
        String? tag,
        Object? error,
        StackTrace? stackTrace,
      });

  /// 设置最小日志级别
  ///
  /// [level] 日志级别
  void setMinLevel(LogLevel level);

  /// 获取当前最小日志级别
  LogLevel get minLevel;

  /// 设置是否启用日志记录
  ///
  /// [enabled] 是否启用
  void setEnabled(bool enabled);

  /// 是否启用日志记录
  bool get isEnabled;

  /// 获取日志条目
  ///
  /// [level] 可选日志级别过滤
  /// [tag] 可选标签过滤
  /// [limit] 可选限制数量
  /// 返回日志条目列表
  List<LogEntry> getLogs({
    LogLevel? level,
    String? tag,
    int? limit,
  });

  /// 清除日志
  void clearLogs();

  /// 导出日志
  ///
  /// [format] 导出格式
  /// 返回导出的字符串
  String exportLogs([String format = 'text']);
}