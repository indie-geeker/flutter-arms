import 'base_config.dart';

/// Result of a configuration validation.
///
/// Contains information about whether the validation passed, and if not,
/// what errors were encountered.
class ValidationResult {
  /// Whether the validation passed.
  final bool isValid;

  /// List of validation error messages.
  ///
  /// Empty if [isValid] is true.
  final List<String> errors;

  /// List of validation warning messages.
  ///
  /// Warnings don't prevent the configuration from being valid,
  /// but indicate potential issues.
  final List<String> warnings;

  /// Creates a validation result.
  const ValidationResult({
    required this.isValid,
    this.errors = const [],
    this.warnings = const [],
  });

  /// Creates a successful validation result.
  const ValidationResult.success({this.warnings = const []})
      : isValid = true,
        errors = const [];

  /// Creates a failed validation result with errors.
  const ValidationResult.failure({
    required this.errors,
    this.warnings = const [],
  }) : isValid = false;

  /// Returns a formatted string of all errors.
  String get errorMessage => errors.join('\n');

  /// Returns a formatted string of all warnings.
  String get warningMessage => warnings.join('\n');

  /// Combines this result with another validation result.
  ///
  /// The combined result is valid only if both results are valid.
  /// Errors and warnings are merged.
  ValidationResult combine(ValidationResult other) {
    return ValidationResult(
      isValid: isValid && other.isValid,
      errors: [...errors, ...other.errors],
      warnings: [...warnings, ...other.warnings],
    );
  }

  @override
  String toString() {
    final buffer = StringBuffer('ValidationResult(isValid: $isValid');
    if (errors.isNotEmpty) {
      buffer.write(', errors: [${errors.join(", ")}]');
    }
    if (warnings.isNotEmpty) {
      buffer.write(', warnings: [${warnings.join(", ")}]');
    }
    buffer.write(')');
    return buffer.toString();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ValidationResult &&
          runtimeType == other.runtimeType &&
          isValid == other.isValid &&
          _listEquals(errors, other.errors) &&
          _listEquals(warnings, other.warnings);

  @override
  int get hashCode => Object.hash(
        isValid,
        Object.hashAll(errors),
        Object.hashAll(warnings),
      );

  static bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Interface for configuration validators.
///
/// Validators are responsible for ensuring that configuration objects
/// are valid before they are used. This helps catch configuration errors
/// early and provides clear error messages.
///
/// Example:
/// ```dart
/// class MyConfigValidator implements ConfigValidator<MyAppConfig> {
///   @override
///   ValidationResult validate(MyAppConfig config) {
///     final errors = <String>[];
///     final warnings = <String>[];
///
///     if (config.apiKey.isEmpty) {
///       errors.add('API key cannot be empty');
///     }
///
///     if (!config.baseUrl.startsWith('https://')) {
///       warnings.add('Base URL should use HTTPS');
///     }
///
///     return errors.isEmpty
///         ? ValidationResult.success(warnings: warnings)
///         : ValidationResult.failure(errors: errors, warnings: warnings);
///   }
/// }
/// ```
abstract class ConfigValidator<T extends BaseConfig> {
  /// Validates the given configuration.
  ///
  /// Returns a [ValidationResult] indicating whether the configuration
  /// is valid and any errors or warnings encountered.
  ValidationResult validate(T config);
}

/// A composite validator that combines multiple validators.
///
/// This is useful when you want to apply multiple validation rules
/// to a configuration object.
class CompositeValidator<T extends BaseConfig> implements ConfigValidator<T> {
  /// The list of validators to apply.
  final List<ConfigValidator<T>> validators;

  /// Creates a composite validator.
  const CompositeValidator(this.validators);

  @override
  ValidationResult validate(T config) {
    var result = const ValidationResult.success();

    for (final validator in validators) {
      result = result.combine(validator.validate(config));
    }

    return result;
  }
}

/// A validator that always passes.
///
/// Useful for configurations that don't require validation or as a placeholder.
class NoOpValidator<T extends BaseConfig> implements ConfigValidator<T> {
  /// Creates a no-op validator.
  const NoOpValidator();

  @override
  ValidationResult validate(T config) => const ValidationResult.success();
}
