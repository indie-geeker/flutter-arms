/// Base configuration interface for all app configurations.
///
/// This abstract class defines the contract that all application configurations
/// must implement. It provides a type-safe way to access configuration values
/// and supports validation before use.
///
/// Example:
/// ```dart
/// class MyAppConfig extends BaseConfig {
///   final String apiKey;
///   final String baseUrl;
///
///   MyAppConfig({
///     required this.apiKey,
///     required this.baseUrl,
///   });
///
///   @override
///   Map<String, dynamic> toMap() => {
///     'apiKey': apiKey,
///     'baseUrl': baseUrl,
///   };
///
///   @override
///   String toString() => 'MyAppConfig(apiKey: $apiKey, baseUrl: $baseUrl)';
/// }
/// ```
abstract class BaseConfig {
  /// Creates a new configuration instance.
  const BaseConfig();

  /// Converts this configuration to a map representation.
  ///
  /// This is useful for serialization, debugging, and logging purposes.
  /// The returned map should contain all configuration values that can be
  /// safely exposed (avoid including sensitive data like API keys in logs).
  Map<String, dynamic> toMap();

  /// Returns a string representation of this configuration.
  ///
  /// Override this method to provide a meaningful string representation
  /// for debugging and logging. Avoid including sensitive data.
  @override
  String toString();

  /// Creates a copy of this configuration with updated values.
  ///
  /// This method should be overridden in concrete implementations to support
  /// creating modified copies while maintaining immutability.
  ///
  /// Subclasses should override this to return their specific type.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// MyAppConfig copyWith({String? apiKey, String? baseUrl}) {
  ///   return MyAppConfig(
  ///     apiKey: apiKey ?? this.apiKey,
  ///     baseUrl: baseUrl ?? this.baseUrl,
  ///   );
  /// }
  /// ```
  BaseConfig copyWith();
}
