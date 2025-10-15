
import 'model/log_level.dart';

class LogConfig{
  final bool enable;
  final bool writeToFile;
  final String? logFilePath;
  final LogLevel logLevel;

  LogConfig({required this.enable,
    required this.writeToFile,
    required this.logFilePath,
    this.logLevel = LogLevel.info
  });


}