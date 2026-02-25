# module_logger

Logger module for flutter-arms.

## Provides

- `ILogger`

## Features

- Multiple output channels (`ConsoleOutput`, `FileOutput`)
- Log level filtering
- Safe output dispatch (single output failure does not break the log pipeline)

## Usage

```dart
LoggerModule(
  initialLevel: LogLevel.info,
  outputs: [
    ConsoleOutput(useColors: true),
    FileOutput('/tmp/app.log'),
  ],
)
```

## Security Note

Network logging should use redaction for sensitive keys and headers. Keep production log level at `info` or higher unless diagnosing issues.
