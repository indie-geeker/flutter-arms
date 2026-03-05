import 'log_config.dart';
import 'log_output.dart';

/// Log output factory interface.
///
/// Creates log output instances based on configuration.
abstract class ILogOutputFactory {
  /// Creates a list of log outputs based on configuration.
  ///
  /// [config] Log output configuration.
  ///
  /// Returns a list of log output instances.
  List<LogOutput> createOutputs(LogOutputConfig config);

  /// Creates a console output.
  ///
  /// [config] Log output configuration.
  ///
  /// Returns a console log output, or null if unsupported or disabled.
  LogOutput? createConsoleOutput(LogOutputConfig config);

  /// Creates a file output.
  ///
  /// [config] Log output configuration.
  ///
  /// Returns a file log output, or null if unsupported or disabled.
  Future<LogOutput?> createFileOutput(LogOutputConfig config);

  /// Creates a memory output.
  ///
  /// [config] Log output configuration.
  ///
  /// Returns a memory log output, or null if unsupported or disabled.
  LogOutput? createMemoryOutput(LogOutputConfig config);

  /// Creates a remote output.
  ///
  /// [config] Log output configuration.
  ///
  /// Returns a remote log output, or null if unsupported or disabled.
  LogOutput? createRemoteOutput(LogOutputConfig config);

  /// Returns the factory type identifier.
  String get factoryType;
}
