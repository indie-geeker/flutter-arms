import 'package:app_interfaces/app_interfaces.dart';
import 'package:app_logger/app_logger.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CompositeLogger', () {
    test('should write to multiple outputs', () {
      // Arrange
      final memoryOutput1 = MemoryLogOutput(maxEntries: 10);
      final memoryOutput2 = MemoryLogOutput(maxEntries: 10);
      final logger = CompositeLogger(
        outputs: [memoryOutput1, memoryOutput2],
        minLevel: LogLevel.debug,
      );

      // Act
      logger.info('Test message');

      // Assert
      expect(memoryOutput1.entryCount, 1);
      expect(memoryOutput2.entryCount, 1);
      expect(memoryOutput1.getLogs().first.message, 'Test message');
      expect(memoryOutput2.getLogs().first.message, 'Test message');
    });

    test('should respect minLevel filtering', () {
      // Arrange
      final memoryOutput = MemoryLogOutput();
      final logger = CompositeLogger(
        outputs: [memoryOutput],
        minLevel: LogLevel.warning,
      );

      // Act
      logger.debug('Debug message');
      logger.info('Info message');
      logger.warning('Warning message');
      logger.error('Error message');

      // Assert
      expect(memoryOutput.entryCount, 2);
      final logs = memoryOutput.getLogs();
      expect(logs[0].level, LogLevel.warning);
      expect(logs[1].level, LogLevel.error);
    });

    test('should change minLevel dynamically', () {
      // Arrange
      final memoryOutput = MemoryLogOutput();
      final logger = CompositeLogger(
        outputs: [memoryOutput],
        minLevel: LogLevel.debug,
      );

      // Act
      logger.info('First message');
      logger.setMinLevel(LogLevel.error);
      logger.info('Second message');
      logger.error('Third message');

      // Assert
      expect(memoryOutput.entryCount, 2);
      expect(memoryOutput.getLogs()[0].message, 'First message');
      expect(memoryOutput.getLogs()[1].message, 'Third message');
    });

    test('should respect enabled flag', () {
      // Arrange
      final memoryOutput = MemoryLogOutput();
      final logger = CompositeLogger(
        outputs: [memoryOutput],
        enabled: false,
      );

      // Act
      logger.info('Test message');

      // Assert
      expect(memoryOutput.entryCount, 0);
    });

    test('should handle errors in outputs gracefully', () {
      // Arrange
      final throwingOutput = _ThrowingLogOutput();
      final memoryOutput = MemoryLogOutput();
      final logger = CompositeLogger(
        outputs: [throwingOutput, memoryOutput],
      );

      // Act & Assert - should not throw
      expect(() => logger.info('Test message'), returnsNormally);
      expect(memoryOutput.entryCount, 1);
    });
  });

  group('MemoryLogOutput', () {
    test('should store log entries', () {
      // Arrange
      final output = MemoryLogOutput(maxEntries: 10);
      final entry = LogEntry(
        level: LogLevel.info,
        message: 'Test message',
        tag: 'TEST',
      );

      // Act
      output.write(entry);

      // Assert
      expect(output.entryCount, 1);
      expect(output.getLogs().first.message, 'Test message');
      expect(output.getLogs().first.tag, 'TEST');
    });

    test('should enforce maxEntries limit', () {
      // Arrange
      final output = MemoryLogOutput(maxEntries: 3);

      // Act
      for (int i = 0; i < 5; i++) {
        output.write(LogEntry(
          level: LogLevel.info,
          message: 'Message $i',
        ));
      }

      // Assert
      expect(output.entryCount, 3);
      final logs = output.getLogs();
      expect(logs[0].message, 'Message 2');
      expect(logs[1].message, 'Message 3');
      expect(logs[2].message, 'Message 4');
    });

    test('should filter logs by level', () {
      // Arrange
      final output = MemoryLogOutput();
      output.write(LogEntry(level: LogLevel.debug, message: 'Debug'));
      output.write(LogEntry(level: LogLevel.info, message: 'Info'));
      output.write(LogEntry(level: LogLevel.error, message: 'Error'));

      // Act
      final errorLogs = output.getLogs(level: LogLevel.error);

      // Assert
      expect(errorLogs.length, 1);
      expect(errorLogs.first.message, 'Error');
    });

    test('should filter logs by tag', () {
      // Arrange
      final output = MemoryLogOutput();
      output.write(LogEntry(level: LogLevel.info, message: 'Msg1', tag: 'TAG1'));
      output.write(LogEntry(level: LogLevel.info, message: 'Msg2', tag: 'TAG2'));
      output.write(LogEntry(level: LogLevel.info, message: 'Msg3', tag: 'TAG1'));

      // Act
      final tag1Logs = output.getLogs(tag: 'TAG1');

      // Assert
      expect(tag1Logs.length, 2);
      expect(tag1Logs[0].message, 'Msg1');
      expect(tag1Logs[1].message, 'Msg3');
    });

    test('should limit returned logs', () {
      // Arrange
      final output = MemoryLogOutput();
      for (int i = 0; i < 10; i++) {
        output.write(LogEntry(level: LogLevel.info, message: 'Message $i'));
      }

      // Act
      final logs = output.getLogs(limit: 3);

      // Assert
      expect(logs.length, 3);
      expect(logs[0].message, 'Message 7');
      expect(logs[1].message, 'Message 8');
      expect(logs[2].message, 'Message 9');
    });

    test('should export logs as text', () {
      // Arrange
      final output = MemoryLogOutput();
      output.write(LogEntry(
        level: LogLevel.info,
        message: 'Test message',
        tag: 'TEST',
      ));

      // Act
      final text = output.exportLogs('text');

      // Assert
      expect(text, contains('INFO'));
      expect(text, contains('Test message'));
      expect(text, contains('TEST'));
    });

    test('should export logs as JSON', () {
      // Arrange
      final output = MemoryLogOutput();
      output.write(LogEntry(
        level: LogLevel.info,
        message: 'Test message',
      ));

      // Act
      final json = output.exportLogs('json');

      // Assert
      expect(json, contains('"level": "info"'));
      expect(json, contains('"message": "Test message"'));
    });

    test('should export logs as CSV', () {
      // Arrange
      final output = MemoryLogOutput();
      output.write(LogEntry(
        level: LogLevel.info,
        message: 'Test message',
      ));

      // Act
      final csv = output.exportLogs('csv');

      // Assert
      expect(csv, contains('Timestamp,Level,Tag,Message,Error,StackTrace'));
      expect(csv, contains('INFO'));
      expect(csv, contains('Test message'));
    });

    test('should clear all logs', () {
      // Arrange
      final output = MemoryLogOutput();
      output.write(LogEntry(level: LogLevel.info, message: 'Message 1'));
      output.write(LogEntry(level: LogLevel.info, message: 'Message 2'));

      // Act
      output.clearLogs();

      // Assert
      expect(output.entryCount, 0);
      expect(output.getLogs(), isEmpty);
    });
  });

  group('ConsoleLogOutput', () {
    test('should create instance', () {
      // Act
      final output = ConsoleLogOutput();

      // Assert
      expect(output, isNotNull);
    });

    test('should write entry without throwing', () {
      // Arrange
      final output = ConsoleLogOutput();
      final entry = LogEntry(
        level: LogLevel.info,
        message: 'Test message',
      );

      // Act & Assert
      expect(() => output.write(entry), returnsNormally);
    });

    test('should support colored and non-colored output', () {
      // Act
      final coloredOutput = ConsoleLogOutput(useColors: true);
      final plainOutput = ConsoleLogOutput(useColors: false);

      // Assert
      expect(coloredOutput, isNotNull);
      expect(plainOutput, isNotNull);
    });
  });

  group('Logger (legacy)', () {
    test('should maintain backward compatibility', () {
      // Arrange
      final logger = Logger(minLevel: LogLevel.debug, enabled: true);

      // Act & Assert
      expect(() => logger.info('Test'), returnsNormally);
      expect(() => logger.debug('Test'), returnsNormally);
      expect(() => logger.warning('Test'), returnsNormally);
      expect(() => logger.error('Test'), returnsNormally);
      expect(() => logger.fatal('Test'), returnsNormally);
    });
  });
}

/// Test output that throws exceptions
class _ThrowingLogOutput implements LogOutput {
  @override
  void write(LogEntry entry) {
    throw Exception('Test exception');
  }
}
