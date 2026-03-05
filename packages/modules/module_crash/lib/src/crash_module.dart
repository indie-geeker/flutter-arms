import 'package:interfaces/core/i_service_locator.dart';
import 'package:interfaces/core/module_registry.dart';
import 'package:interfaces/crash/i_crash_reporter.dart';

import 'impl/composite_crash_reporter.dart';
import 'impl/file_crash_reporter.dart';

/// Crash reporting module.
///
/// Registers an [ICrashReporter] implementation into the service locator.
/// By default, uses [FileCrashReporter] for local crash logging.
/// Override via [factory] to provide a custom implementation
/// (e.g. Sentry, HTTP, or [CompositeCrashReporter]).
class CrashModule extends BaseModule {
  final ICrashReporter Function(IServiceLocator locator)? _factory;

  /// Creates a crash module.
  ///
  /// [factory] Optional factory to produce a custom [ICrashReporter].
  /// Defaults to [FileCrashReporter] when omitted.
  CrashModule({ICrashReporter Function(IServiceLocator locator)? factory})
    : _factory = factory;

  @override
  String get name => 'Crash';

  @override
  int get priority => InitPriorities.crash;

  @override
  List<Type> get provides => [ICrashReporter];

  @override
  Future<void> onRegister(IServiceLocator locator) async {
    final reporter = _factory?.call(locator) ?? FileCrashReporter();
    locator.registerSingleton<ICrashReporter>(reporter);
  }
}
