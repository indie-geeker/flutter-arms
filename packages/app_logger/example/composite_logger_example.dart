import 'package:app_logger/app_logger.dart';
import 'package:app_interfaces/app_interfaces.dart';

/// Example demonstrating the new composite logger architecture
void main() {
  print('=== Composite Logger Example ===\n');

  // Example 1: Basic usage with console and memory outputs
  print('Example 1: Multiple outputs');
  final consoleOutput = ConsoleLogOutput();
  final memoryOutput = MemoryLogOutput(maxEntries: 100);

  final logger = CompositeLogger(
    outputs: [consoleOutput, memoryOutput],
    minLevel: LogLevel.debug,
    enabled: true,
  );

  logger.info('Application started', tag: 'APP');
  logger.debug('Debug information', tag: 'DEBUG');
  logger.warning('This is a warning', tag: 'WARN');
  logger.error('An error occurred', tag: 'ERROR');

  print('\n--- Memory output has ${memoryOutput.entryCount} entries ---\n');

  // Example 2: Filtering logs by level
  print('Example 2: Log level filtering');
  logger.setMinLevel(LogLevel.warning);

  logger.debug('This will not be logged');
  logger.info('This will not be logged either');
  logger.warning('This will be logged');
  logger.error('This will also be logged');

  print('\n--- Memory output now has ${memoryOutput.entryCount} entries ---\n');

  // Example 3: Retrieving and exporting logs
  print('Example 3: Retrieving logs from memory');
  final allLogs = memoryOutput.getLogs();
  print('Total logs: ${allLogs.length}');

  final errorLogs = memoryOutput.getLogs(level: LogLevel.error);
  print('Error logs: ${errorLogs.length}');

  // Export as text
  print('\n--- Exported as TEXT ---');
  print(memoryOutput.exportLogs('text'));

  // Export as JSON
  print('\n--- Exported as JSON ---');
  print(memoryOutput.exportLogs('json'));

  // Example 4: Console-only logger (simple)
  print('\n\nExample 4: Console-only logger');
  final simpleLogger = CompositeLogger(
    outputs: [ConsoleLogOutput(useColors: true)],
    minLevel: LogLevel.info,
  );

  simpleLogger.info('Simple info message');
  simpleLogger.error('Simple error message');

  // Example 5: Clearing logs
  print('\n\nExample 5: Clearing logs');
  print('Before clear: ${memoryOutput.entryCount} entries');
  memoryOutput.clearLogs();
  print('After clear: ${memoryOutput.entryCount} entries');

  print('\n=== Example Complete ===');
}
