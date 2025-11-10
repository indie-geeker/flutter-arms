import 'dart:convert';
import 'dart:io';
import 'package:test/test.dart';
import 'package:interfaces/logger/i_logger.dart';
import 'package:interfaces/logger/log_entity.dart';
import 'package:interfaces/logger/log_level.dart';
import 'package:interfaces/logger/log_output.dart';
import 'package:interfaces/core/i_service_locator.dart';
import 'package:module_logger/src/impl/logger_impl.dart';
import 'package:module_logger/src/formatters/simple_formatter.dart';
import 'package:module_logger/src/formatters/json_formatter.dart';
import 'package:module_logger/src/outputs/console_output.dart';
import 'package:module_logger/src/outputs/file_output.dart';
import 'package:module_logger/src/logger_module.dart';

void main() {
  group('LoggerImpl Tests', () {
    late LoggerImpl logger;
    late MockLogOutput mockOutput;

    setUp(() {
      logger = LoggerImpl();
      mockOutput = MockLogOutput();
    });

    test('should filter logs below minimum level', () {
      logger.init(level: LogLevel.warning, outputs: [mockOutput]);

      logger.debug('debug message');
      logger.info('info message');
      logger.warning('warning message');
      logger.error('error message');

      expect(mockOutput.entries.length, 2);
      expect(mockOutput.entries[0].level, LogLevel.warning);
      expect(mockOutput.entries[1].level, LogLevel.error);
    });

    test('should log debug messages when level is debug', () {
      logger.init(level: LogLevel.debug, outputs: [mockOutput]);

      logger.debug('debug message');

      expect(mockOutput.entries.length, 1);
      expect(mockOutput.entries[0].message, 'debug message');
      expect(mockOutput.entries[0].level, LogLevel.debug);
    });

    test('should log info messages', () {
      logger.init(level: LogLevel.info, outputs: [mockOutput]);

      logger.info('info message');

      expect(mockOutput.entries.length, 1);
      expect(mockOutput.entries[0].message, 'info message');
      expect(mockOutput.entries[0].level, LogLevel.info);
    });

    test('should log warning messages with error and stackTrace', () {
      logger.init(level: LogLevel.debug, outputs: [mockOutput]);
      final testError = Exception('test error');
      final testStack = StackTrace.current;

      logger.warning('warning message', error: testError, stackTrace: testStack);

      expect(mockOutput.entries.length, 1);
      expect(mockOutput.entries[0].message, 'warning message');
      expect(mockOutput.entries[0].level, LogLevel.warning);
      expect(mockOutput.entries[0].error, testError);
      expect(mockOutput.entries[0].stackTrace, testStack);
    });

    test('should log error messages with error details', () {
      logger.init(level: LogLevel.debug, outputs: [mockOutput]);
      final testError = Exception('critical error');

      logger.error('error message', error: testError);

      expect(mockOutput.entries.length, 1);
      expect(mockOutput.entries[0].message, 'error message');
      expect(mockOutput.entries[0].level, LogLevel.error);
      expect(mockOutput.entries[0].error, testError);
    });

    test('should log fatal messages', () {
      logger.init(level: LogLevel.debug, outputs: [mockOutput]);

      logger.fatal('fatal message');

      expect(mockOutput.entries.length, 1);
      expect(mockOutput.entries[0].message, 'fatal message');
      expect(mockOutput.entries[0].level, LogLevel.fatal);
    });

    test('should support custom log level via log method', () {
      logger.init(level: LogLevel.debug, outputs: [mockOutput]);

      logger.log(LogLevel.info, 'custom log');

      expect(mockOutput.entries.length, 1);
      expect(mockOutput.entries[0].message, 'custom log');
      expect(mockOutput.entries[0].level, LogLevel.info);
    });

    test('should dynamically change log level', () {
      logger.init(level: LogLevel.debug, outputs: [mockOutput]);

      logger.debug('debug 1');
      logger.setLevel(LogLevel.error);
      logger.debug('debug 2');
      logger.error('error 1');

      expect(mockOutput.entries.length, 2);
      expect(mockOutput.entries[0].message, 'debug 1');
      expect(mockOutput.entries[1].message, 'error 1');
    });

    test('should support multiple outputs', () {
      final output1 = MockLogOutput();
      final output2 = MockLogOutput();

      logger.init(level: LogLevel.debug, outputs: [output1, output2]);
      logger.info('test message');

      expect(output1.entries.length, 1);
      expect(output2.entries.length, 1);
      expect(output1.entries[0].message, 'test message');
      expect(output2.entries[0].message, 'test message');
    });

    test('should add output dynamically', () {
      logger.init(level: LogLevel.debug, outputs: [mockOutput]);
      final output2 = MockLogOutput();

      logger.info('message 1');
      logger.addOutput(output2);
      logger.info('message 2');

      expect(mockOutput.entries.length, 2);
      expect(output2.entries.length, 1);
      expect(output2.entries[0].message, 'message 2');
    });

    test('should handle output errors gracefully', () {
      final failingOutput = FailingLogOutput();
      logger.init(level: LogLevel.debug, outputs: [failingOutput, mockOutput]);

      // Should not throw
      expect(() => logger.info('test message'), returnsNormally);

      // Second output should still receive the log
      expect(mockOutput.entries.length, 1);
    });

    test('should not log when level is below threshold', () {
      logger.init(level: LogLevel.error, outputs: [mockOutput]);

      logger.debug('debug');
      logger.info('info');
      logger.warning('warning');

      expect(mockOutput.entries.length, 0);
    });
  });

  group('SimpleFormatter Tests', () {
    late SimpleFormatter formatter;

    setUp(() {
      formatter = SimpleFormatter();
    });

    test('should format basic log entry', () {
      final entry = LogEntry(
        level: LogLevel.info,
        message: 'test message',
        timestamp: DateTime(2024, 1, 1, 12, 30, 45, 123),
      );

      final result = formatter.format(entry);

      expect(result, contains('[12:30:45.123]'));
      expect(result, contains('[INFO   ]'));
      expect(result, contains('test message'));
    });

    test('should format log entry with error', () {
      final entry = LogEntry(
        level: LogLevel.error,
        message: 'error occurred',
        error: Exception('test exception'),
      );

      final result = formatter.format(entry);

      expect(result, contains('error occurred'));
      expect(result, contains('Error: Exception: test exception'));
    });

    test('should format log entry with stack trace', () {
      final entry = LogEntry(
        level: LogLevel.error,
        message: 'error with stack',
        stackTrace: StackTrace.fromString('line 1\nline 2\nline 3'),
      );

      final result = formatter.format(entry);

      expect(result, contains('error with stack'));
      expect(result, contains('StackTrace:'));
      expect(result, contains('line 1'));
    });

    test('should pad log level correctly', () {
      final debugEntry = LogEntry(level: LogLevel.debug, message: 'msg');
      final warningEntry = LogEntry(level: LogLevel.warning, message: 'msg');

      final debugResult = formatter.format(debugEntry);
      final warningResult = formatter.format(warningEntry);

      expect(debugResult, contains('[DEBUG  ]'));
      expect(warningResult, contains('[WARNING]'));
    });

    test('should format timestamp with leading zeros', () {
      final entry = LogEntry(
        level: LogLevel.info,
        message: 'msg',
        timestamp: DateTime(2024, 1, 1, 9, 5, 3, 45),
      );

      final result = formatter.format(entry);

      expect(result, contains('[09:05:03.045]'));
    });
  });

  group('JsonFormatter Tests', () {
    late JsonFormatter formatter;

    setUp(() {
      formatter = JsonFormatter();
    });

    test('should format basic log entry as JSON', () {
      final entry = LogEntry(
        level: LogLevel.info,
        message: 'test message',
        timestamp: DateTime(2024, 1, 1, 12, 30, 45),
      );

      final result = formatter.format(entry);
      final json = jsonDecode(result);

      expect(json['level'], 'info');
      expect(json['message'], 'test message');
      expect(json['timestamp'], '2024-01-01T12:30:45.000');
    });

    test('should include error in JSON output', () {
      final entry = LogEntry(
        level: LogLevel.error,
        message: 'error occurred',
        error: Exception('test exception'),
      );

      final result = formatter.format(entry);
      final json = jsonDecode(result);

      expect(json['error'], contains('Exception: test exception'));
    });

    test('should include stackTrace in JSON output', () {
      final entry = LogEntry(
        level: LogLevel.error,
        message: 'error with stack',
        stackTrace: StackTrace.fromString('stack trace here'),
      );

      final result = formatter.format(entry);
      final json = jsonDecode(result);

      expect(json['stackTrace'], contains('stack trace here'));
    });

    test('should include tag when present', () {
      final entry = LogEntry(
        level: LogLevel.info,
        message: 'tagged message',
        tag: 'TestTag',
      );

      final result = formatter.format(entry);
      final json = jsonDecode(result);

      expect(json['tag'], 'TestTag');
    });

    test('should omit null fields', () {
      final entry = LogEntry(
        level: LogLevel.info,
        message: 'simple message',
      );

      final result = formatter.format(entry);
      final json = jsonDecode(result);

      expect(json.containsKey('error'), false);
      expect(json.containsKey('stackTrace'), false);
      expect(json.containsKey('tag'), false);
    });

    test('should produce valid JSON for all log levels', () {
      for (final level in LogLevel.values) {
        final entry = LogEntry(level: level, message: 'test');
        final result = formatter.format(entry);

        expect(() => jsonDecode(result), returnsNormally);
        final json = jsonDecode(result);
        expect(json['level'], level.name);
      }
    });
  });

  group('ConsoleOutput Tests', () {
    test('should write formatted output', () {
      final output = ConsoleOutput(useColors: false);
      final entry = LogEntry(
        level: LogLevel.info,
        message: 'console test',
      );

      // Should not throw
      expect(() => output.write(entry), returnsNormally);
    });

    test('should apply colors when enabled', () {
      final output = ConsoleOutput(useColors: true);
      final entry = LogEntry(level: LogLevel.error, message: 'error');
      final entryDebug = LogEntry(level: LogLevel.debug, message: 'debug');
      final entryWarning = LogEntry(level: LogLevel.warning, message: 'warning');

      // Should not throw - color codes will be added
      expect(() => output.write(entry), returnsNormally);
      expect(() => output.write(entryDebug), returnsNormally);
      expect(() => output.write(entryWarning), returnsNormally);
    });

    test('should not apply colors when disabled', () {
      final output = ConsoleOutput(useColors: false);
      final entry = LogEntry(level: LogLevel.info, message: 'info');

      // Should not throw - no color codes
      expect(() => output.write(entry), returnsNormally);
    });
  });

  group('FileOutput Tests', () {
    late Directory tempDir;
    late String testFilePath;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('logger_test_');
      testFilePath = '${tempDir.path}/test.log';
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('should create file and write log entry', () async {
      final output = FileOutput(testFilePath);
      final entry = LogEntry(level: LogLevel.info, message: 'test log');

      output.write(entry);

      // Wait for async write
      await Future.delayed(Duration(milliseconds: 100));

      final file = File(testFilePath);
      expect(await file.exists(), true);

      final content = await file.readAsString();
      expect(content, contains('test log'));
      expect(content, contains('[INFO   ]'));

      await output.dispose();
    });

    test('should create parent directories if needed', () async {
      final nestedPath = '${tempDir.path}/nested/dir/test.log';
      final output = FileOutput(nestedPath);
      final entry = LogEntry(level: LogLevel.info, message: 'nested test');

      output.write(entry);

      await Future.delayed(Duration(milliseconds: 100));

      final file = File(nestedPath);
      expect(await file.exists(), true);

      await output.dispose();
    });

    test('should append to existing file', () async {
      final output = FileOutput(testFilePath);

      output.write(LogEntry(level: LogLevel.info, message: 'first'));
      await Future.delayed(Duration(milliseconds: 50));
      output.write(LogEntry(level: LogLevel.info, message: 'second'));
      await Future.delayed(Duration(milliseconds: 50));

      final content = await File(testFilePath).readAsString();
      expect(content, contains('first'));
      expect(content, contains('second'));

      await output.dispose();
    });

    test('should rotate file when size exceeds limit', () async {
      final output = FileOutput(testFilePath, maxFileSize: 100); // Very small limit

      // Write enough data to exceed limit
      for (int i = 0; i < 10; i++) {
        output.write(LogEntry(
          level: LogLevel.info,
          message: 'This is a long message to exceed the file size limit $i',
        ));
        await Future.delayed(Duration(milliseconds: 10));
      }

      await Future.delayed(Duration(milliseconds: 200));

      // Should have created a rotated file
      final files = tempDir.listSync();
      final logFiles = files.where((f) => f.path.contains('.log')).toList();

      // Should have at least original and one rotated file
      expect(logFiles.length, greaterThan(1));

      await output.dispose();
    });

    test('should dispose properly', () async {
      final output = FileOutput(testFilePath);

      output.write(LogEntry(level: LogLevel.info, message: 'test'));
      await Future.delayed(Duration(milliseconds: 50));

      await output.dispose();

      // File should still exist after dispose
      expect(await File(testFilePath).exists(), true);
    });

    test('should handle write errors gracefully', () async {
      // Use an invalid path
      final output = FileOutput('/invalid/path/that/does/not/exist/test.log');
      final entry = LogEntry(level: LogLevel.info, message: 'test');

      // Should not throw
      expect(() => output.write(entry), returnsNormally);

      await output.dispose();
    });
  });

  group('LoggerModule Tests', () {
    late MockServiceLocator mockLocator;

    setUp(() {
      mockLocator = MockServiceLocator();
    });

    test('should have correct module metadata', () {
      final module = LoggerModule();

      expect(module.name, 'LoggerModule');
      expect(module.priority, 0); // InitPriorities.logger
      expect(module.dependencies, isEmpty);
    });

    test('should register logger in service locator', () async {
      final module = LoggerModule();

      await module.register(mockLocator);

      expect(mockLocator.registeredServices.containsKey(ILogger), true);
      expect(mockLocator.registeredServices[ILogger], isA<LoggerImpl>());
    });

    test('should initialize logger with custom level', () async {
      final mockOutput = MockLogOutput();
      final module = LoggerModule(
        initialLevel: LogLevel.warning,
        outputs: [mockOutput],
      );

      await module.register(mockLocator);
      await module.init();

      final logger = mockLocator.get<ILogger>();

      // Test that level filtering works
      logger.debug('debug');
      logger.info('info');
      logger.warning('warning');

      expect(mockOutput.entries.length, 1);
      expect(mockOutput.entries[0].level, LogLevel.warning);
    });

    test('should initialize logger with custom outputs', () async {
      final mockOutput = MockLogOutput();
      final module = LoggerModule(outputs: [mockOutput]);

      await module.register(mockLocator);
      await module.init();

      final logger = mockLocator.get<ILogger>();
      logger.info('test');

      expect(mockOutput.entries.length, 1);
    });

    test('should dispose file outputs on module dispose', () async {
      final tempDir = await Directory.systemTemp.createTemp('logger_module_test_');
      final testFilePath = '${tempDir.path}/test.log';
      final fileOutput = FileOutput(testFilePath);

      final module = LoggerModule(outputs: [fileOutput]);

      await module.register(mockLocator);
      await module.init();

      final logger = mockLocator.get<ILogger>();
      logger.info('test');

      await Future.delayed(Duration(milliseconds: 50));
      await module.dispose();

      // Cleanup
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('should support multiple module instances', () async {
      final locator1 = MockServiceLocator();
      final locator2 = MockServiceLocator();

      final module1 = LoggerModule(initialLevel: LogLevel.debug);
      final module2 = LoggerModule(initialLevel: LogLevel.error);

      await module1.register(locator1);
      await module1.init();

      await module2.register(locator2);
      await module2.init();

      expect(locator1.get<ILogger>(), isNotNull);
      expect(locator2.get<ILogger>(), isNotNull);
      expect(locator1.get<ILogger>(), isNot(same(locator2.get<ILogger>())));
    });
  });

  group('Integration Tests', () {
    test('should log through complete pipeline', () async {
      final mockOutput = MockLogOutput();
      final logger = LoggerImpl();

      logger.init(level: LogLevel.debug, outputs: [mockOutput]);

      logger.debug('debug message');
      logger.info('info message');
      logger.warning('warning message', error: Exception('test'));
      logger.error('error message', stackTrace: StackTrace.current);
      logger.fatal('fatal message');

      expect(mockOutput.entries.length, 5);
      expect(mockOutput.entries[0].level, LogLevel.debug);
      expect(mockOutput.entries[1].level, LogLevel.info);
      expect(mockOutput.entries[2].level, LogLevel.warning);
      expect(mockOutput.entries[2].error, isNotNull);
      expect(mockOutput.entries[3].level, LogLevel.error);
      expect(mockOutput.entries[3].stackTrace, isNotNull);
      expect(mockOutput.entries[4].level, LogLevel.fatal);
    });

    test('should work with both file and multiple outputs', () async {
      final output1 = MockLogOutput();
      final output2 = MockLogOutput();
      final output3 = MockLogOutput();

      final logger = LoggerImpl();
      logger.init(level: LogLevel.info, outputs: [output1, output2, output3]);

      logger.info('integration test message');
      logger.error('integration error');

      // Check all outputs received both messages
      expect(output1.entries.length, 2);
      expect(output2.entries.length, 2);
      expect(output3.entries.length, 2);

      expect(output1.entries[0].message, 'integration test message');
      expect(output1.entries[1].message, 'integration error');

      expect(output2.entries[0].message, 'integration test message');
      expect(output2.entries[1].message, 'integration error');

      expect(output3.entries[0].message, 'integration test message');
      expect(output3.entries[1].message, 'integration error');
    });

    test('should handle rapid logging', () async {
      final mockOutput = MockLogOutput();
      final logger = LoggerImpl();
      logger.init(level: LogLevel.debug, outputs: [mockOutput]);

      // Log 100 messages rapidly
      for (int i = 0; i < 100; i++) {
        logger.info('message $i');
      }

      expect(mockOutput.entries.length, 100);
      expect(mockOutput.entries.first.message, 'message 0');
      expect(mockOutput.entries.last.message, 'message 99');
    });

    test('should filter across multiple outputs with same level', () {
      final output1 = MockLogOutput();
      final output2 = MockLogOutput();
      final logger = LoggerImpl();

      logger.init(level: LogLevel.warning, outputs: [output1, output2]);

      logger.debug('debug');
      logger.info('info');
      logger.warning('warning');
      logger.error('error');

      expect(output1.entries.length, 2);
      expect(output2.entries.length, 2);
      expect(output1.entries[0].level, LogLevel.warning);
      expect(output2.entries[0].level, LogLevel.warning);
    });
  });
}

// ==================== Test Helpers ====================

/// Mock log output that captures entries for verification
class MockLogOutput implements LogOutput {
  final List<LogEntry> entries = [];

  @override
  void write(LogEntry entry) {
    entries.add(entry);
  }

  void clear() {
    entries.clear();
  }
}

/// Log output that always throws errors
class FailingLogOutput implements LogOutput {
  @override
  void write(LogEntry entry) {
    throw Exception('Intentional failure for testing');
  }
}

/// Mock service locator for testing module registration
class MockServiceLocator implements IServiceLocator {
  final Map<Type, dynamic> registeredServices = {};
  final Map<Type, dynamic Function()> factories = {};
  final Map<Type, dynamic Function()> lazySingletons = {};
  final Map<Type, dynamic> lazySingletonInstances = {};

  @override
  void registerSingleton<T extends Object>(T instance) {
    registeredServices[T] = instance;
  }

  @override
  void registerLazySingleton<T extends Object>(T Function() factoryFunc) {
    lazySingletons[T] = factoryFunc;
  }

  @override
  void registerFactory<T extends Object>(T Function() factory) {
    factories[T] = factory;
  }

  @override
  T get<T extends Object>() {
    // Check registered singletons
    if (registeredServices.containsKey(T)) {
      return registeredServices[T] as T;
    }

    // Check lazy singletons
    if (lazySingletons.containsKey(T)) {
      if (!lazySingletonInstances.containsKey(T)) {
        lazySingletonInstances[T] = lazySingletons[T]!();
      }
      return lazySingletonInstances[T] as T;
    }

    // Check factories
    if (factories.containsKey(T)) {
      return factories[T]!() as T;
    }

    throw Exception('Service $T not registered');
  }

  @override
  bool isRegistered<T extends Object>() {
    return registeredServices.containsKey(T) ||
        factories.containsKey(T) ||
        lazySingletons.containsKey(T);
  }

  @override
  Future<void> unregister<T extends Object>() async {
    registeredServices.remove(T);
    factories.remove(T);
    lazySingletons.remove(T);
    lazySingletonInstances.remove(T);
  }

  @override
  Future<void> reset() async {
    registeredServices.clear();
    factories.clear();
    lazySingletons.clear();
    lazySingletonInstances.clear();
  }
}
