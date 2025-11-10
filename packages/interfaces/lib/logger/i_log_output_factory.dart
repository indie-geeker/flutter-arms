import 'log_config.dart';
import 'log_output.dart';

/// 日志输出工厂接口
///
/// 根据配置创建日志输出实例
abstract class ILogOutputFactory {
  /// 根据配置创建日志输出列表
  ///
  /// [config] 日志输出配置
  ///
  /// 返回日志输出实例列表
  List<LogOutput> createOutputs(LogOutputConfig config);

  /// 创建控制台输出
  ///
  /// [config] 日志输出配置
  ///
  /// 返回控制台日志输出,如果不支持或未启用则返回 null
  LogOutput? createConsoleOutput(LogOutputConfig config);

  /// 创建文件输出
  ///
  /// [config] 日志输出配置
  ///
  /// 返回文件日志输出,如果不支持或未启用则返回 null
  Future<LogOutput?> createFileOutput(LogOutputConfig config);

  /// 创建内存输出
  ///
  /// [config] 日志输出配置
  ///
  /// 返回内存日志输出,如果不支持或未启用则返回 null
  LogOutput? createMemoryOutput(LogOutputConfig config);

  /// 创建远程输出
  ///
  /// [config] 日志输出配置
  ///
  /// 返回远程日志输出,如果不支持或未启用则返回 null
  LogOutput? createRemoteOutput(LogOutputConfig config);

  /// 获取工厂类型标识
  String get factoryType;
}
