import 'package:interfaces/core/module_registry.dart';
import 'package:interfaces/logger/i_logger.dart';
import 'package:interfaces/logger/log_level.dart';
import 'package:interfaces/logger/log_output.dart';
import 'package:interfaces/core/i_service_locator.dart';
import 'package:module_logger/src/outputs/disposable_log_output.dart';
import 'impl/logger_impl.dart';

/// Logger module
///
/// Provides logging functionality, one of the foundational modules of the application.
/// Priority is set to highest (0) to ensure other modules can use the logger during initialization.
class LoggerModule extends BaseModule {
  final LogLevel initialLevel;
  final List<LogOutput> outputs;

  LoggerModule({this.initialLevel = LogLevel.debug, this.outputs = const []});

  @override
  String get name => 'LoggerModule';

  @override
  int get priority => InitPriorities.logger;

  @override
  List<Type> get provides => [ILogger];

  @override
  Future<void> onRegister(IServiceLocator locator) async {
    final logger = LoggerImpl();
    locator.registerSingleton<ILogger>(logger);
  }

  @override
  Future<void> onInit() async {
    final logger = locator.get<ILogger>();
    logger.init(level: initialLevel, outputs: outputs);
  }

  @override
  Future<void> onDispose() async {
    for (final output in outputs) {
      if (output is DisposableLogOutput) {
        final disposable = output as DisposableLogOutput;
        await disposable.dispose();
      }
    }
  }
}
