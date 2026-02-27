import 'package:interfaces/core/i_service_locator.dart';
import 'package:interfaces/logger/i_logger.dart';
import 'package:interfaces/logger/log_level.dart';
import 'package:interfaces/logger/log_output.dart';
import 'package:interfaces/storage/i_kv_storage.dart';
import 'package:interfaces/storage/i_secure_storage.dart';
import 'package:module_storage/src/storage_module.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StorageModule disposal isolation', () {
    test('dispose should close module-owned key-value storage', () async {
      final keyValueStorage = RecordingKeyValueStorage();
      final locator = RecordingServiceLocator(logger: NoopLogger());
      final module = StorageModule(
        keyValueStorageBuilder: ({required logger, required config}) {
          return keyValueStorage;
        },
      );

      await module.register(locator);
      await module.dispose();

      expect(keyValueStorage.closeCount, 1);
    });

    test('dispose should close key-value and secure storage when enabled', () async {
      final keyValueStorage = RecordingKeyValueStorage();
      final secureStorage = RecordingSecureStorage();
      final locator = RecordingServiceLocator(logger: NoopLogger());
      final module = StorageModule(
        config: StorageConfig(enableSecureStorage: true),
        keyValueStorageBuilder: ({required logger, required config}) {
          return keyValueStorage;
        },
        secureStorageBuilder: () => secureStorage,
      );

      await module.register(locator);
      await module.dispose();

      expect(keyValueStorage.closeCount, 1);
      expect(secureStorage.closeCount, 1);
    });
  });
}

class RecordingServiceLocator implements IServiceLocator {
  final Map<Type, dynamic> _services = {};

  RecordingServiceLocator({required ILogger logger}) {
    _services[ILogger] = logger;
  }

  @override
  T get<T extends Object>() {
    final service = _services[T];
    if (service == null) {
      throw Exception('Service of type $T not found');
    }
    return service as T;
  }

  @override
  bool isRegistered<T extends Object>() => _services.containsKey(T);

  @override
  bool isRegisteredByType(Type type) => _services.containsKey(type);

  @override
  void registerFactory<T extends Object>(T Function() factoryFunc) {
    _services[T] = factoryFunc();
  }

  @override
  void registerLazySingleton<T extends Object>(T Function() factoryFunc) {
    _services[T] = factoryFunc();
  }

  @override
  void registerSingleton<T extends Object>(T instance) {
    _services[T] = instance;
  }

  @override
  Future<void> reset() async => _services.clear();

  @override
  Future<void> unregister<T extends Object>() async {
    _services.remove(T);
  }
}

class NoopLogger implements ILogger {
  @override
  void addOutput(LogOutput output) {}

  @override
  void debug(
    String message, {
    error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extras,
  }) {}

  @override
  void error(
    String message, {
    error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extras,
  }) {}

  @override
  void fatal(
    String message, {
    error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extras,
  }) {}

  @override
  void info(String message, {Map<String, dynamic>? extras}) {}

  @override
  void init({LogLevel level = LogLevel.debug, List<LogOutput>? outputs}) {}

  @override
  void log(
    LogLevel level,
    String message, {
    error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extras,
  }) {}

  @override
  void setLevel(LogLevel level) {}

  @override
  void warning(
    String message, {
    error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extras,
  }) {}
}

class RecordingKeyValueStorage implements IKeyValueStorage {
  int closeCount = 0;

  @override
  Future<void> clear() async {}

  @override
  Future<void> close() async {
    closeCount += 1;
  }

  @override
  Future<bool> containsKey(String key) async => false;

  @override
  Future<bool?> getBool(String key) async => null;

  @override
  Future<double?> getDouble(String key) async => null;

  @override
  Future<int?> getInt(String key) async => null;

  @override
  Future<Map<String, dynamic>?> getJson(String key) async => null;

  @override
  Future<Set<String>> getKeys() async => <String>{};

  @override
  Future<int> getSize() async => 0;

  @override
  Future<String?> getString(String key) async => null;

  @override
  Future<List<String>?> getStringList(String key) async => null;

  @override
  Future<void> init() async {}

  @override
  Future<void> remove(String key) async {}

  @override
  Future<void> setBool(String key, bool value) async {}

  @override
  Future<void> setDouble(String key, double value) async {}

  @override
  Future<void> setInt(String key, int value) async {}

  @override
  Future<void> setJson(String key, Map<String, dynamic> value) async {}

  @override
  Future<void> setString(String key, String value) async {}

  @override
  Future<void> setStringList(String key, List<String> value) async {}
}

class RecordingSecureStorage implements ISecureStorage {
  int closeCount = 0;

  @override
  Future<void> clear() async {}

  @override
  Future<void> close() async {
    closeCount += 1;
  }

  @override
  Future<bool> containsKey(String key) async => false;

  @override
  Future<void> delete(String key) async {}

  @override
  Future<void> deleteAll() async {}

  @override
  Future<Set<String>> getKeys() async => <String>{};

  @override
  Future<int> getSize() async => 0;

  @override
  Future<void> init() async {}

  @override
  Future<String?> read(String key) async => null;

  @override
  Future<Map<String, String>> readAll() async => <String, String>{};

  @override
  Future<void> write(String key, String value) async {}
}
