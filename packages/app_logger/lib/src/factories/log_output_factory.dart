import 'package:app_interfaces/app_interfaces.dart';

import '../outputs/console_log_output.dart';
import '../outputs/file_log_output.dart';
import '../outputs/memory_log_output.dart';
import '../outputs/remote_log_output.dart';

/// 默认日志输出工厂实现
///
/// 根据配置创建各种日志输出实例
class DefaultLogOutputFactory implements ILogOutputFactory {
  /// 存储实现(用于文件输出)
  final IKeyValueStorage? _storage;

  /// 网络客户端(用于远程输出)
  final INetworkClient? _networkClient;

  /// 创建日志输出工厂
  ///
  /// [storage] 存储实现,如果需要文件输出则必须提供
  /// [networkClient] 网络客户端,如果需要远程输出则必须提供
  const DefaultLogOutputFactory({
    IKeyValueStorage? storage,
    INetworkClient? networkClient,
  })  : _storage = storage,
        _networkClient = networkClient;

  @override
  List<LogOutput> createOutputs(LogOutputConfig config) {
    if (!config.enabled) {
      return [];
    }

    final outputs = <LogOutput>[];

    // 创建控制台输出
    final consoleOutput = createConsoleOutput(config);
    if (consoleOutput != null) {
      outputs.add(consoleOutput);
    }

    // 创建内存输出
    final memoryOutput = createMemoryOutput(config);
    if (memoryOutput != null) {
      outputs.add(memoryOutput);
    }

    // 创建远程输出
    final remoteOutput = createRemoteOutput(config);
    if (remoteOutput != null) {
      outputs.add(remoteOutput);
    }

    // 注意: 文件输出是异步的,不在这里创建
    // 如果需要文件输出,应该单独调用 createFileOutput

    return outputs;
  }

  @override
  LogOutput? createConsoleOutput(LogOutputConfig config) {
    if (!config.enabled || !config.enableConsole) {
      return null;
    }

    return ConsoleLogOutput(
      useColors: config.enableColors,
    );
  }

  @override
  Future<LogOutput?> createFileOutput(LogOutputConfig config) async {
    if (!config.enabled || !config.enableFile) {
      return null;
    }

    final storage = _storage;
    if (storage == null) {
      throw StateError(
        'Storage implementation is required for file output. '
        'Please provide IKeyValueStorage to DefaultLogOutputFactory.',
      );
    }

    final logFilePath = config.logFilePath;
    if (logFilePath == null) {
      throw ArgumentError(
        'logFilePath is required when enableFile is true',
      );
    }

    return FileLogOutput(
      storage,
      fileName: logFilePath,
      maxFileSize: config.maxFileSize ?? 1024 * 1024, // 1MB default
      maxFiles: config.retentionDays ?? 3, // Reuse retentionDays as maxFiles count
    );
  }

  @override
  LogOutput? createMemoryOutput(LogOutputConfig config) {
    if (!config.enabled || !config.enableMemory) {
      return null;
    }

    return MemoryLogOutput(
      maxEntries: config.maxMemoryEntries ?? 1000,
    );
  }

  @override
  LogOutput? createRemoteOutput(LogOutputConfig config) {
    if (!config.enabled || !config.enableRemote) {
      return null;
    }

    final networkClient = _networkClient;
    if (networkClient == null) {
      throw StateError(
        'Network client is required for remote output. '
        'Please provide INetworkClient to DefaultLogOutputFactory.',
      );
    }

    final remoteEndpoint = config.remoteEndpoint;
    if (remoteEndpoint == null) {
      throw ArgumentError(
        'remoteEndpoint is required when enableRemote is true',
      );
    }

    return RemoteLogOutput(
      networkClient,
      endpoint: remoteEndpoint,
      batchInterval: const Duration(seconds: 30),
      batchSize: 50,
    );
  }

  @override
  String get factoryType => 'default';
}
