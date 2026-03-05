import 'i_service_locator.dart';

/// Module registration interface.
///
/// All feature modules (e.g. Logger, Storage, Network) must implement this
/// interface. The Core layer uses it to coordinate module registration,
/// initialization and disposal.
abstract class IModule {
  /// Module name (used for logging and debugging).
  String get name;

  /// Initialization priority (lower number = higher priority).
  ///
  /// Examples:
  /// - Logger: 10 (initialized first)
  /// - Storage: 20
  /// - Cache: 30 (depends on Storage)
  /// - Network: 40 (depends on Cache)
  int get priority;

  /// List of service types this module depends on.
  ///
  /// The Core layer validates these dependencies before initialization,
  /// ensuring that required services are already registered.
  List<Type> get dependencies;

  /// List of service types this module provides.
  ///
  /// Used for dependency graph resolution and initialization ordering,
  /// ensuring provider modules initialize before consumer modules.
  /// For example, LoggerModule provides ILogger, StorageModule provides
  /// IKeyValueStorage.
  List<Type> get provides;

  /// Module health status.
  ///
  /// Modules can implement this getter to report runtime health,
  /// e.g. network module checks connectivity, storage module checks
  /// filesystem availability.
  /// Use [BaseModule] or `with ModuleDefaults` for the default value `true`.
  bool get isHealthy;

  /// Registers module services.
  ///
  /// Registers the services this module provides into the service locator.
  ///
  /// **Important**: This method receives [IServiceLocator] (an interface),
  /// not a concrete implementation. This way the module layer only depends
  /// on the `interfaces` package, not on `core`.
  Future<void> register(IServiceLocator locator);

  /// Initializes the module.
  ///
  /// Executes module initialization logic (e.g. opening a database,
  /// establishing a network connection). Called in priority order after
  /// all modules have been registered.
  Future<void> init();

  /// Disposes the module.
  ///
  /// Cleans up module resources (e.g. closing a database, cancelling
  /// network requests). Called in reverse priority order when the
  /// application exits.
  Future<void> dispose();
}

/// Module base class that reduces boilerplate.
///
/// Subclasses only need to implement [onRegister] and optionally override
/// [onInit] / [onDispose]. The [locator] is saved automatically during
/// registration and can be used directly afterwards.
abstract class BaseModule implements IModule {
  late IServiceLocator _locator;

  /// Protected locator accessor, available only after registration.
  IServiceLocator get locator => _locator;

  @override
  List<Type> get dependencies => [];

  @override
  List<Type> get provides => [];

  @override
  bool get isHealthy => true;

  @override
  Future<void> register(IServiceLocator locator) async {
    _locator = locator;
    await onRegister(locator);
  }

  @override
  Future<void> init() async => onInit();

  @override
  Future<void> dispose() async => onDispose();

  /// Subclass implementation: register services into the locator.
  Future<void> onRegister(IServiceLocator locator);

  /// Subclass optional override: initialization logic.
  Future<void> onInit() async {}

  /// Subclass optional override: cleanup logic.
  Future<void> onDispose() async {}
}

class InitPriorities {
  static const int crash = 5;
  static const int logger = 0;
  static const int storage = 10;
  static const int cache = 30;
  static const int network = 40;
  static const int theme = 50;
  static const int analytics = 60;
  static const int notification = 70;
}
