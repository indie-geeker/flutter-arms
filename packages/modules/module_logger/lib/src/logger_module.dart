
import 'package:interfaces/core/i_service_locator.dart';
import 'package:interfaces/core/module_registry.dart';
import 'package:interfaces/logger/i_logger.dart';
import 'package:interfaces/logger/log_level.dart';
import 'package:interfaces/logger/log_output.dart';
import 'package:module_logger/src/outputs/disposable_log_output.dart';
import 'impl/logger_impl.dart';

/// 日志模块
///
/// 提供日志功能，是整个应用的基础模块之一。
/// 优先级设置为最高（0），确保其他模块可以在初始化时使用日志。
class LoggerModule implements IModule {
  final LogLevel initialLevel;
  final List<LogOutput> outputs;

  LoggerModule({
    this.initialLevel = LogLevel.debug,
    this.outputs = const [],
  });

  @override
  String get name => 'LoggerModule';

  @override
  int get priority => InitPriorities.logger; // 最高优先级，其他模块可能依赖日志

  @override
  List<Type> get dependencies => []; // 无依赖

  @override
  List<Type> get provides => [ILogger];

  // 保存 locator 引用以便在 init 中使用
  late IServiceLocator _locator;

  @override
  Future<void> register(IServiceLocator locator) async {
    // 注意：使用 IServiceLocator 接口，不依赖具体的 ServiceLocator 实现
    _locator = locator; // 保存引用，供 init 方法使用

    final logger = LoggerImpl();
    locator.registerSingleton<ILogger>(logger);
  }

  @override
  Future<void> init() async {
    // 在 init 阶段通过保存的 locator 引用获取已注册的服务
    final logger = _locator.get<ILogger>();
    logger.init(level: initialLevel, outputs: outputs);
  }

  @override
  Future<void> dispose() async {
    // Logger cleanup if needed
    for (final output in outputs) {
      if (output is DisposableLogOutput) {
        final disposable = output as DisposableLogOutput;
        await disposable.dispose();
      }
    }
  }
}
