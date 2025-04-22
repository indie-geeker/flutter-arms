import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// 日志配置类
/// 
/// 用于配置日志的行为，包括：
/// - 日志级别
/// - 日志格式
/// - 日志输出目标
class LogConfig {
  /// 开发环境配置
  static Logger developmentLogger() {
    return Logger(
      level: Level.trace,
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 150,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.dateAndTime,
      ),
      output: ConsoleOutput(),
    );
  }
  
  /// 测试环境配置
  static Logger testLogger() {
    return Logger(
      level: Level.debug,
      printer: PrettyPrinter(
        methodCount: 1,
        errorMethodCount: 5,
        lineLength: 100,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.dateAndTime,
      ),
      output: ConsoleOutput(),
    );
  }
  
  /// 生产环境配置
  static Logger productionLogger() {
    return Logger(
      level: Level.warning,
      printer: SimplePrinter(
        colors: false,
        printTime: true,
      ),
      output: ConsoleOutput(),
    );
  }
  
  /// 根据当前环境获取合适的日志配置
  static Logger getLogger() {
    if (kReleaseMode) {
      return productionLogger();
    } else if (kProfileMode) {
      return testLogger();
    } else {
      return developmentLogger();
    }
  }
}

/// 自定义日志输出
/// 
/// 可以扩展此类来将日志输出到文件、网络等
class FileOutput extends LogOutput {
  final String filePath;
  
  FileOutput(this.filePath);
  
  @override
  void output(OutputEvent event) {
    // 这里可以实现将日志写入文件的逻辑
    // 例如使用 dart:io 的 File 类
    for (var line in event.lines) {
      // 将 line 写入文件
      debugPrint('写入文件: $filePath, 内容: $line');
    }
  }
}

/// 多目标日志输出
/// 
/// 可以同时将日志输出到多个目标
class MultiOutput extends LogOutput {
  final List<LogOutput> outputs;
  
  MultiOutput(this.outputs);
  
  @override
  void output(OutputEvent event) {
    for (var output in outputs) {
      output.output(event);
    }
  }
}
