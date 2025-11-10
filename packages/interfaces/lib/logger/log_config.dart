import 'log_level.dart';

/// 日志输出配置
///
/// 用于配置日志输出工厂创建的输出实例
class LogOutputConfig {
  /// 是否启用日志
  final bool enabled;

  /// 最低日志级别
  final LogLevel minLevel;

  /// 是否启用控制台输出
  final bool enableConsole;

  /// 是否启用文件输出
  final bool enableFile;

  /// 日志文件路径
  final String? logFilePath;

  /// 日志文件最大大小(字节)
  final int? maxFileSize;

  /// 日志文件保留天数
  final int? retentionDays;

  /// 是否启用内存日志
  final bool enableMemory;

  /// 内存日志最大条目数
  final int? maxMemoryEntries;

  /// 是否启用远程日志
  final bool enableRemote;

  /// 远程日志端点URL
  final String? remoteEndpoint;

  /// 是否启用彩色输出(仅控制台)
  final bool enableColors;

  /// 自定义日志格式
  final String? customFormat;

  /// 额外配置
  final Map<String, dynamic>? extra;

  const LogOutputConfig({
    this.enabled = true,
    this.minLevel = LogLevel.debug,
    this.enableConsole = true,
    this.enableFile = false,
    this.logFilePath,
    this.maxFileSize,
    this.retentionDays,
    this.enableMemory = false,
    this.maxMemoryEntries,
    this.enableRemote = false,
    this.remoteEndpoint,
    this.enableColors = true,
    this.customFormat,
    this.extra,
  });

  /// 开发环境配置
  factory LogOutputConfig.development() => const LogOutputConfig(
    enabled: true,
    minLevel: LogLevel.debug,
    enableConsole: true,
    enableFile: false,
    enableMemory: true,
    maxMemoryEntries: 1000,
    enableColors: true,
  );

  /// 生产环境配置
  factory LogOutputConfig.production({
    required String logFilePath,
    String? remoteEndpoint,
  }) =>
      LogOutputConfig(
        enabled: true,
        minLevel: LogLevel.info,
        enableConsole: false,
        enableFile: true,
        logFilePath: logFilePath,
        maxFileSize: 10 * 1024 * 1024, // 10MB
        retentionDays: 7,
        enableMemory: false,
        enableRemote: remoteEndpoint != null,
        remoteEndpoint: remoteEndpoint,
        enableColors: false,
      );

  /// 测试环境配置
  factory LogOutputConfig.test() => const LogOutputConfig(
    enabled: true,
    minLevel: LogLevel.warning,
    enableConsole: false,
    enableFile: false,
    enableMemory: true,
    maxMemoryEntries: 100,
    enableRemote: false,
  );

  /// 禁用所有日志
  factory LogOutputConfig.disabled() => const LogOutputConfig(
    enabled: false,
    enableConsole: false,
    enableFile: false,
    enableMemory: false,
    enableRemote: false,
  );

  /// 复制并修改配置
  LogOutputConfig copyWith({
    bool? enabled,
    LogLevel? minLevel,
    bool? enableConsole,
    bool? enableFile,
    String? logFilePath,
    int? maxFileSize,
    int? retentionDays,
    bool? enableMemory,
    int? maxMemoryEntries,
    bool? enableRemote,
    String? remoteEndpoint,
    bool? enableColors,
    String? customFormat,
    Map<String, dynamic>? extra,
  }) {
    return LogOutputConfig(
      enabled: enabled ?? this.enabled,
      minLevel: minLevel ?? this.minLevel,
      enableConsole: enableConsole ?? this.enableConsole,
      enableFile: enableFile ?? this.enableFile,
      logFilePath: logFilePath ?? this.logFilePath,
      maxFileSize: maxFileSize ?? this.maxFileSize,
      retentionDays: retentionDays ?? this.retentionDays,
      enableMemory: enableMemory ?? this.enableMemory,
      maxMemoryEntries: maxMemoryEntries ?? this.maxMemoryEntries,
      enableRemote: enableRemote ?? this.enableRemote,
      remoteEndpoint: remoteEndpoint ?? this.remoteEndpoint,
      enableColors: enableColors ?? this.enableColors,
      customFormat: customFormat ?? this.customFormat,
      extra: extra ?? this.extra,
    );
  }
}