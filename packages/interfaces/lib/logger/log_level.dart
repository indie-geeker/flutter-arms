/// Log level.
enum LogLevel {
  /// Debug information.
  debug(0),

  /// General information.
  info(1),

  /// Warning messages.
  warning(2),

  /// Error messages.
  error(3),

  /// Fatal errors.
  fatal(4);

  final int value;
  const LogLevel(this.value);

  bool operator >(LogLevel other) => value > other.value;
  bool operator >=(LogLevel other) => value >= other.value;
  bool operator <(LogLevel other) => value < other.value;
  bool operator <=(LogLevel other) => value <= other.value;
}
