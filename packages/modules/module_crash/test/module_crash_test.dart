import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:interfaces/crash/i_crash_reporter.dart';
import 'package:interfaces/core/i_service_locator.dart';
import 'package:module_crash/module_crash.dart';

void main() {
  group('FileCrashReporter', () {
    late Directory tempDir;
    late FileCrashReporter reporter;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('crash_test_');
      reporter = FileCrashReporter(directory: tempDir.path);
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test('recordError creates a crash file', () async {
      await reporter.recordError(
        Exception('test error'),
        stackTrace: StackTrace.current,
        context: {'screen': 'HomeScreen'},
      );

      final files = tempDir.listSync().whereType<File>().toList();
      expect(files.length, 1);
      expect(files.first.path, contains('crash_'));

      final content = await files.first.readAsString();
      expect(content, contains('test error'));
      expect(content, contains('Crash Report'));
      expect(content, contains('HomeScreen'));
    });

    test('setUserId includes user in report', () async {
      await reporter.setUserId('user-42');
      await reporter.recordError('some error');

      final files = tempDir.listSync().whereType<File>().toList();
      final content = await files.first.readAsString();
      expect(content, contains('user-42'));
    });

    test('log completes without error', () async {
      await reporter.log('breadcrumb message', category: 'navigation');
    });
  });

  group('CompositeCrashReporter', () {
    test('fans out recordError to all reporters', () async {
      final r1 = _MockCrashReporter();
      final r2 = _MockCrashReporter();
      final composite = CompositeCrashReporter([r1, r2]);

      await composite.recordError('error', context: {'key': 'val'});

      expect(r1.recordedErrors, ['error']);
      expect(r2.recordedErrors, ['error']);
    });

    test('fans out setUserId to all reporters', () async {
      final r1 = _MockCrashReporter();
      final r2 = _MockCrashReporter();
      final composite = CompositeCrashReporter([r1, r2]);

      await composite.setUserId('user-1');

      expect(r1.userIds, ['user-1']);
      expect(r2.userIds, ['user-1']);
    });

    test('fans out log to all reporters', () async {
      final r1 = _MockCrashReporter();
      final r2 = _MockCrashReporter();
      final composite = CompositeCrashReporter([r1, r2]);

      await composite.log('message', category: 'test');

      expect(r1.logs, ['message']);
      expect(r2.logs, ['message']);
    });

    test('isolates failure from one reporter', () async {
      final failing = _FailingCrashReporter();
      final ok = _MockCrashReporter();
      final composite = CompositeCrashReporter([failing, ok]);

      await composite.recordError('error');

      // ok reporter should still receive the error.
      expect(ok.recordedErrors, ['error']);
    });
  });

  group('CrashModule', () {
    test('registers ICrashReporter with default FileCrashReporter', () async {
      final locator = _MockServiceLocator();
      final module = CrashModule();

      await module.register(locator);

      expect(locator.registered[ICrashReporter], isA<FileCrashReporter>());
    });

    test('registers ICrashReporter with custom factory', () async {
      final locator = _MockServiceLocator();
      final mock = _MockCrashReporter();
      final module = CrashModule(factory: (_) => mock);

      await module.register(locator);

      expect(locator.registered[ICrashReporter], same(mock));
    });

    test('name is Crash', () {
      expect(CrashModule().name, 'Crash');
    });

    test('provides ICrashReporter', () {
      expect(CrashModule().provides, [ICrashReporter]);
    });

    test('priority matches InitPriorities.crash', () {
      expect(CrashModule().priority, 5);
    });
  });
}

// -- Test helpers --

class _MockCrashReporter implements ICrashReporter {
  final List<dynamic> recordedErrors = [];
  final List<String?> userIds = [];
  final List<String> logs = [];

  @override
  Future<void> recordError(
    dynamic error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) async {
    recordedErrors.add(error);
  }

  @override
  Future<void> setUserId(String? userId) async {
    userIds.add(userId);
  }

  @override
  Future<void> log(String message, {String? category}) async {
    logs.add(message);
  }
}

class _FailingCrashReporter implements ICrashReporter {
  @override
  Future<void> recordError(
    dynamic error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) async {
    throw Exception('Reporter failure');
  }

  @override
  Future<void> setUserId(String? userId) async {
    throw Exception('Reporter failure');
  }

  @override
  Future<void> log(String message, {String? category}) async {
    throw Exception('Reporter failure');
  }
}

class _MockServiceLocator implements IServiceLocator {
  final Map<Type, Object> registered = {};

  @override
  void registerSingleton<T extends Object>(T instance) {
    registered[T] = instance;
  }

  @override
  void registerLazySingleton<T extends Object>(T Function() factoryFunc) {
    registered[T] = factoryFunc();
  }

  @override
  void registerFactory<T extends Object>(T Function() factoryFunc) {}

  @override
  T get<T extends Object>() => registered[T] as T;

  @override
  bool isRegistered<T extends Object>() => registered.containsKey(T);

  @override
  bool isRegisteredByType(Type type) => registered.containsKey(type);

  @override
  Future<void> unregister<T extends Object>() async {
    registered.remove(T);
  }

  @override
  Future<void> reset() async {
    registered.clear();
  }
}
