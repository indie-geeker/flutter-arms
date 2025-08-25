import 'dart:collection';
import 'package:app_interfaces/app_interfaces.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';



/// 日志实现类
///
/// 提供日志记录、过滤、查询和导出功能
class Logger implements ILogger{
  /// ANSI转义序列颜色代码
  static const String _resetColor = '\u001b[0m';
  static const String _debugColor = '\u001b[37m'; // 灰色
  static const String _infoColor = '\u001b[36m';  // 青色
  static const String _warningColor = '\u001b[33m'; // 黄色
  static const String _errorColor = '\u001b[31m'; // 红色
  static const String _fatalColor = '\u001b[35m'; // 紫色
  static const String _verboseColor = '\u001b[34m'; // 蓝色
  /// 创建日志记录器实例
  Logger({LogLevel minLevel = LogLevel.debug, bool enabled = true}) {
    _minLevel = minLevel;
    _enabled = enabled;
  }

  /// 日志队列，用于存储日志条目
  final Queue<LogEntry> _logEntries = Queue<LogEntry>();

  /// 最大日志条目数量
  static const int _maxLogEntries = 1000;

  /// 最小日志级别
  LogLevel _minLevel = LogLevel.debug;

  /// 是否启用日志记录
  bool _enabled = true;

  @override
  void debug(
      String message, {
        String? tag,
        Object? error,
        StackTrace? stackTrace,
      }) {
    log(LogLevel.debug, message,
        tag: tag, error: error, stackTrace: stackTrace);
  }

  @override
  void info(
      String message, {
        String? tag,
        Object? error,
        StackTrace? stackTrace,
      }) {
    log(LogLevel.info, message,
        tag: tag, error: error, stackTrace: stackTrace);
  }

  @override
  void warning(
      String message, {
        String? tag,
        Object? error,
        StackTrace? stackTrace,
      }) {
    log(LogLevel.warning, message,
        tag: tag, error: error, stackTrace: stackTrace);
  }

  @override
  void error(
      String message, {
        String? tag,
        Object? error,
        StackTrace? stackTrace,
      }) {
    log(LogLevel.error, message,
        tag: tag, error: error, stackTrace: stackTrace);
  }

  @override
  void fatal(
      String message, {
        String? tag,
        Object? error,
        StackTrace? stackTrace,
      }) {
    log(LogLevel.fatal, message,
        tag: tag, error: error, stackTrace: stackTrace);
  }

  @override
  void log(
      LogLevel level,
      String message, {
        String? tag,
        Object? error,
        StackTrace? stackTrace,
      }) {
    if (!_enabled || level.index < _minLevel.index) {
      return;
    }

    // 创建日志条目
    final entry = LogEntry(
      level: level,
      message: message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );

    // 添加到队列
    _logEntries.add(entry);

    // 控制日志条目数量，移除最旧的条目
    while (_logEntries.length > _maxLogEntries) {
      _logEntries.removeFirst();
    }

    // 打印到控制台
    _printToConsole(entry);
  }

  /// 打印日志到控制台，支持彩色输出
  void _printToConsole(LogEntry entry) {
    final prefix = _getLevelPrefix(entry.level);
    final color = _getLevelColor(entry.level);
    final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(entry.timestamp);
    final tagInfo = entry.tag != null ? '[${entry.tag}] ' : '';

    debugPrint('$timestamp $color$prefix$_resetColor $tagInfo$color${entry.message}$_resetColor');

    if (entry.error != null) {
      debugPrint('${_errorColor}Error: ${entry.error}$_resetColor');
    }

    if (entry.stackTrace != null) {
      debugPrint('StackTrace: ${entry.stackTrace}');
    }
  }

  /// 获取日志级别对应的前缀
  String _getLevelPrefix(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '[DEBUG]';
      case LogLevel.info:
        return '[INFO]';
      case LogLevel.warning:
        return '[WARN]';
      case LogLevel.error:
        return '[ERROR]';
      case LogLevel.fatal:
        return '[FATAL]';
      case LogLevel.verbose:
        return '[VERBOSE]';
    }
  }

  /// 获取日志级别对应的颜色代码
  String _getLevelColor(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return _debugColor;
      case LogLevel.info:
        return _infoColor;
      case LogLevel.warning:
        return _warningColor;
      case LogLevel.error:
        return _errorColor;
      case LogLevel.fatal:
        return _fatalColor;
      case LogLevel.verbose:
        return _verboseColor;
    }
  }

  @override
  void setMinLevel(LogLevel level) {
    _minLevel = level;
  }

  @override
  LogLevel get minLevel => _minLevel;

  @override
  void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  @override
  bool get isEnabled => _enabled;

  @override
  List<LogEntry> getLogs({
    LogLevel? level,
    String? tag,
    int? limit,
  }) {
    // 筛选日志条目
    final filteredLogs = _logEntries.where((entry) {
      if (level != null && entry.level != level) {
        return false;
      }
      if (tag != null && entry.tag != tag) {
        return false;
      }
      return true;
    }).toList();

    // 应用限制
    if (limit != null && limit > 0 && filteredLogs.length > limit) {
      return filteredLogs.sublist(filteredLogs.length - limit);
    }

    return filteredLogs;
  }

  @override
  void clearLogs() {
    _logEntries.clear();
  }

  @override
  String exportLogs([String format = 'text']) {
    switch (format.toLowerCase()) {
      case 'json':
        return _exportAsJson();
      case 'csv':
        return _exportAsCsv();
      case 'text':
      default:
        return _exportAsText();
    }
  }

  /// 以文本格式导出日志
  String _exportAsText() {
    final buffer = StringBuffer();
    for (final entry in _logEntries) {
      buffer.writeln('${entry.timestamp.toIso8601String()} '
          '[${entry.level.toString().split('.').last.toUpperCase()}] '
          '${entry.tag != null ? '[${entry.tag}] ' : ''}'
          '${entry.message}');

      if (entry.error != null) {
        buffer.writeln('  Error: ${entry.error}');
      }
      if (entry.stackTrace != null) {
        buffer.writeln('  StackTrace: ${entry.stackTrace}');
      }
    }
    return buffer.toString();
  }

  /// 以CSV格式导出日志
  String _exportAsCsv() {
    final buffer = StringBuffer();
    // 添加CSV头
    buffer.writeln('Timestamp,Level,Tag,Message,Error,StackTrace');

    // 添加日志条目
    for (final entry in _logEntries) {
      final timestamp = entry.timestamp.toIso8601String();
      final level = entry.level.toString().split('.').last.toUpperCase();
      final tag = entry.tag ?? '';
      final message = _escapeCsvField(entry.message);
      final error = _escapeCsvField(entry.error?.toString() ?? '');
      final stackTrace = _escapeCsvField(entry.stackTrace?.toString() ?? '');

      buffer.writeln('$timestamp,$level,$tag,$message,$error,$stackTrace');
    }

    return buffer.toString();
  }

  /// 转义CSV字段中的特殊字符
  String _escapeCsvField(String field) {
    if (field.contains('"') ||
        field.contains(',') ||
        field.contains('\n') ||
        field.contains('\r')) {
      // 用双引号包围字段，并将其中的双引号替换为两个双引号
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }

  /// 以JSON格式导出日志
  String _exportAsJson() {
    final buffer = StringBuffer();
    buffer.writeln('[');

    for (int i = 0; i < _logEntries.length; i++) {
      final entry = _logEntries.elementAt(i);

      buffer.writeln('  {');
      buffer.writeln('    "timestamp": "${entry.timestamp.toIso8601String()}",');
      buffer.writeln('    "level": "${entry.level.toString().split('.').last}",');
      if (entry.tag != null) {
        buffer.writeln('    "tag": "${entry.tag}",');
      }
      buffer.writeln('    "message": "${_escapeJsonString(entry.message)}",');
      if (entry.error != null) {
        buffer.writeln('    "error": "${_escapeJsonString(entry.error.toString())}",');
      }
      if (entry.stackTrace != null) {
        buffer.writeln('    "stackTrace": "${_escapeJsonString(entry.stackTrace.toString())}"');
      } else {
        // 删除最后一个逗号
        buffer.write(buffer.toString().endsWith(',\n')
            ? buffer.toString().substring(0, buffer.toString().length - 2) + '\n'
            : buffer.toString());
      }
      buffer.writeln('  }${i < _logEntries.length - 1 ? ',' : ''}');
    }

    buffer.writeln(']');
    return buffer.toString();
  }

  /// 转义JSON字符串中的特殊字符
  String _escapeJsonString(String string) {
    return string
        .replaceAll('\\', '\\\\')
        .replaceAll('"', '\\"')
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r')
        .replaceAll('\t', '\\t');
  }

  /// 获取实例
  static final Logger _instance = Logger();

  /// 获取单例实例
  static Logger get instance => _instance;

}