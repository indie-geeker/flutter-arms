import 'package:app_core/app_core.dart';

import '../base_app_config.dart';

/// Validator for the example application configuration.
///
/// This validator combines network and storage validation with
/// application-specific validation rules.
///
/// Example:
/// ```dart
/// final validator = ExampleConfigValidator();
/// final result = validator.validate(config);
///
/// if (!result.isValid) {
///   print('Configuration errors: ${result.errorMessage}');
/// }
/// ```
class ExampleConfigValidator extends CompositeValidator<BaseAppConfig> {
  ExampleConfigValidator()
      : super([
          // Network configuration validation
          const NetworkConfigValidator<BaseAppConfig>(),
          // Storage configuration validation
          StorageConfigValidator<BaseAppConfig>(
            cacheSizeGetter: (config) => config.cacheMaxSizeMB * 1024 * 1024,
            encryptionEnabledGetter: (config) => config.enableEncryption,
          ),
          // Application-specific validation
          const _AppSpecificValidator(),
        ]);
}

/// Application-specific configuration validator.
///
/// Validates rules specific to this example application.
class _AppSpecificValidator implements ConfigValidator<BaseAppConfig> {
  const _AppSpecificValidator();

  @override
  ValidationResult validate(BaseAppConfig config) {
    final errors = <String>[];
    final warnings = <String>[];

    // Validate app name
    if (config.appName.isEmpty) {
      errors.add('App name cannot be empty');
    }

    // Validate channel
    if (config.channel.isEmpty) {
      errors.add('App channel cannot be empty');
    }

    // Validate API version
    if (config.apiVersion.isEmpty) {
      warnings.add('API version is empty. Consider specifying a version.');
    } else if (!RegExp(r'^v\d+(\.\d+)*$').hasMatch(config.apiVersion)) {
      warnings.add(
        'API version "${config.apiVersion}" does not follow the standard format (e.g., v1, v1.0, v1.2.3)',
      );
    }

    // Production-specific validation
    if (config.isProduction) {
      _validateProduction(config, errors, warnings);
    }

    // Development-specific validation
    if (config.isDevelopment) {
      _validateDevelopment(config, warnings);
    }

    // Validate feature flag combinations
    _validateFeatureFlags(config, warnings);

    return errors.isEmpty
        ? ValidationResult.success(warnings: warnings)
        : ValidationResult.failure(errors: errors, warnings: warnings);
  }

  void _validateProduction(
    BaseAppConfig config,
    List<String> errors,
    List<String> warnings,
  ) {
    // Production should have crash reporting enabled
    if (!config.enableCrashReporting) {
      warnings.add(
        'Crash reporting is disabled in production. '
        'Consider enabling it to track production issues.',
      );
    }

    // Production should have performance monitoring
    if (!config.enablePerformanceMonitoring) {
      warnings.add(
        'Performance monitoring is disabled in production. '
        'Consider enabling it to track app performance.',
      );
    }

    // Production should not have debug mode enabled
    if (config.debugMode) {
      errors.add(
        'Debug mode is enabled in production. '
        'This must be disabled for production builds.',
      );
    }

    // Production should not show performance overlay
    if (config.showPerformanceOverlay) {
      errors.add(
        'Performance overlay is enabled in production. '
        'This must be disabled for production builds.',
      );
    }

    // Production should not have verbose logging
    if (config.enableVerboseLogging) {
      warnings.add(
        'Verbose logging is enabled in production. '
        'Consider disabling it to reduce log noise and improve performance.',
      );
    }

    // Production should use encryption
    if (!config.enableEncryption) {
      warnings.add(
        'Encryption is disabled in production. '
        'Consider enabling it to protect sensitive data.',
      );
    }
  }

  void _validateDevelopment(
    BaseAppConfig config,
    List<String> warnings,
  ) {
    // Development should have verbose logging for better debugging
    if (!config.enableVerboseLogging) {
      warnings.add(
        'Verbose logging is disabled in development. '
        'Consider enabling it for better debugging.',
      );
    }
  }

  void _validateFeatureFlags(
    BaseAppConfig config,
    List<String> warnings,
  ) {
    // Warn if crash reporting is enabled but analytics is not
    if (config.enableCrashReporting && !config.enableAnalytics) {
      warnings.add(
        'Crash reporting is enabled but analytics is disabled. '
        'Consider enabling analytics for better insights.',
      );
    }

    // Warn if performance monitoring is enabled without crash reporting
    if (config.enablePerformanceMonitoring && !config.enableCrashReporting) {
      warnings.add(
        'Performance monitoring is enabled but crash reporting is disabled. '
        'Consider enabling crash reporting for complete monitoring.',
      );
    }
  }
}
