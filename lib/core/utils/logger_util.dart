import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import 'log_config.dart';

/// 日志工具类
/// 
/// 封装 logger 包，提供统一的日志记录接口
/// 支持不同级别的日志：verbose, debug, info, warning, error, wtf
/// 在发布模式下可以禁用某些级别的日志
class LoggerUtil {
  static final LoggerUtil _instance = LoggerUtil._internal();
  
  factory LoggerUtil() => _instance;
  
  late Logger _logger;
  
  /// 是否启用日志
  bool _enabled = true;
  
  /// 当前日志级别
  Level _currentLevel = Level.trace;
  
  LoggerUtil._internal() {
    _initLogger();
  }
  
  /// 初始化日志记录器
  void _initLogger() {
    _logger = LogConfig.getLogger();
    // 保存当前级别，因为无法从 Logger 实例中获取
    _currentLevel = kReleaseMode ? Level.warning : Level.trace;
  }
  
  /// 重新配置日志记录器
  void reconfigure({Level? level, LogPrinter? printer, LogOutput? output}) {
    // 如果提供了新的日志级别，则更新当前级别
    if (level != null) {
      _currentLevel = level;
    }
    
    // 创建一个新的 Logger 实例，应用新的配置
    _logger = Logger(
      level: _currentLevel,
      printer: printer ?? (_logger as dynamic).printer as LogPrinter?,
      output: output ?? (_logger as dynamic).output as LogOutput?,
    );
  }
  
  /// 启用或禁用日志
  void setEnabled(bool enabled) {
    _enabled = enabled;
  }
  
  /// 获取当前日志级别
  Level get currentLevel => _currentLevel;
  
  /// 记录详细日志
  void v(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (_enabled) {
      _logger.v(message, error: error, stackTrace: stackTrace);
    }
  }
  
  /// 记录调试日志
  void d(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (_enabled) {
      _logger.d(message, error: error, stackTrace: stackTrace);
    }
  }
  
  /// 记录信息日志
  void i(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (_enabled) {
      _logger.i(message, error: error, stackTrace: stackTrace);
    }
  }
  
  /// 记录警告日志
  void w(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (_enabled) {
      _logger.w(message, error: error, stackTrace: stackTrace);
    }
  }
  
  /// 记录错误日志
  void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (_enabled) {
      _logger.e(message, error: error, stackTrace: stackTrace);
    }
  }
  
  /// 记录严重错误日志
  void wtf(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (_enabled) {
      _logger.f(message, error: error, stackTrace: stackTrace);
    }
  }
}

/// 全局日志实例，可以直接使用
final logger = LoggerUtil();
