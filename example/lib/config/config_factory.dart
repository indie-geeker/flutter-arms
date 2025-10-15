import 'package:app_core/app_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'base_app_config.dart';
import 'validators/example_config_validator.dart';

/// Factory for creating and validating application configurations.
///
/// This factory handles loading environment files, creating the appropriate
/// configuration instance, and validating it before use.
///
/// Example:
/// ```dart
/// // Create config based on build mode
/// final config = await ConfigFactory.create();
///
/// // Or specify environment explicitly
/// final config = await ConfigFactory.create(
///   environment: EnvironmentType.staging,
/// );
///
/// // Create with custom validator
/// final config = await ConfigFactory.create(
///   validator: MyCustomValidator(),
/// );
/// ```
class ConfigFactory {
  ConfigFactory._();

  /// Creates a configuration for the current environment.
  ///
  /// The environment is determined by:
  /// 1. The provided [environment] parameter (if specified)
  /// 2. The build mode (debug = development, release = production)
  /// 3. The BUILD_ENV environment variable
  ///
  /// Throws [ConfigurationError] if validation fails.
  static Future<BaseAppConfig> create({
    EnvironmentType? environment,
    ConfigValidator<BaseAppConfig>? validator,
    bool validateConfig = true,
  }) async {
    // Determine environment
    final env = environment ?? _determineEnvironment();

    // Load appropriate .env file
    await _loadEnvFile(env);

    // Create config instance
    final config = _createConfig(env);

    // Validate configuration
    if (validateConfig) {
      final configValidator = validator ?? ExampleConfigValidator();
      final result = configValidator.validate(config);

      if (!result.isValid) {
        throw ConfigurationError(
          'Configuration validation failed',
          errors: result.errors,
          warnings: result.warnings,
        );
      }

      // Log warnings if any
      if (result.warnings.isNotEmpty) {
        debugPrint('Configuration warnings:');
        for (final warning in result.warnings) {
          debugPrint('  - $warning');
        }
      }
    }

    debugPrint('Configuration loaded: ${config.environment.name}');
    return config;
  }

  /// Determines the environment based on build mode and environment variables.
  static EnvironmentType _determineEnvironment() {
    // Check for BUILD_ENV environment variable (useful for build-time configuration)
    const buildEnv = String.fromEnvironment('BUILD_ENV');
    if (buildEnv.isNotEmpty) {
      return _parseEnvironment(buildEnv);
    }

    // Fall back to build mode
    if (kReleaseMode) {
      return EnvironmentType.production;
    } else if (kProfileMode) {
      return EnvironmentType.staging;
    } else {
      return EnvironmentType.development;
    }
  }

  /// Loads the appropriate .env file for the given environment.
  static Future<void> _loadEnvFile(EnvironmentType environment) async {
    final fileName = _getEnvFileName(environment);
    try {
      await dotenv.load(fileName: fileName);
      debugPrint('Loaded environment file: $fileName');
    } catch (e) {
      debugPrint('Failed to load $fileName: $e');
      // Try to load default .env as fallback
      try {
        await dotenv.load(fileName: '.env');
        debugPrint('Loaded fallback environment file: .env');
      } catch (e) {
        throw ConfigurationError(
          'Failed to load environment configuration',
          errors: ['Could not load $fileName or .env: $e'],
        );
      }
    }
  }

  /// Gets the .env file name for the given environment.
  static String _getEnvFileName(EnvironmentType environment) {
    switch (environment) {
      case EnvironmentType.development:
        return '.env.development';
      case EnvironmentType.staging:
        return '.env.staging';
      case EnvironmentType.production:
        return '.env.production';
      case EnvironmentType.test:
        return '.env.test';
      case EnvironmentType.demo:
        return '.env.staging'; // Use staging env for demo
    }
  }

  /// Creates the appropriate configuration instance for the environment.
  ///
  /// All environments use [BaseAppConfig.fromEnv()], which reads configuration
  /// from the loaded environment file. The specific behavior for each environment
  /// is determined by the values in the respective .env files.
  static BaseAppConfig _createConfig(EnvironmentType environment) {
    // All environments use the same config class
    // The differences are in the .env files that are loaded
    return BaseAppConfig.fromEnv();
  }

  /// Parses an environment string to EnvironmentType.
  static EnvironmentType _parseEnvironment(String value) {
    switch (value.toLowerCase()) {
      case 'development':
      case 'dev':
        return EnvironmentType.development;
      case 'staging':
      case 'stage':
        return EnvironmentType.staging;
      case 'production':
      case 'prod':
        return EnvironmentType.production;
      case 'test':
        return EnvironmentType.test;
      default:
        return EnvironmentType.development;
    }
  }
}

/// Exception thrown when configuration loading or validation fails.
class ConfigurationError implements Exception {
  final String message;
  final List<String> errors;
  final List<String> warnings;

  ConfigurationError(
    this.message, {
    this.errors = const [],
    this.warnings = const [],
  });

  @override
  String toString() {
    final buffer = StringBuffer('ConfigurationError: $message');
    if (errors.isNotEmpty) {
      buffer.write('\nErrors:\n');
      for (final error in errors) {
        buffer.write('  - $error\n');
      }
    }
    if (warnings.isNotEmpty) {
      buffer.write('Warnings:\n');
      for (final warning in warnings) {
        buffer.write('  - $warning\n');
      }
    }
    return buffer.toString();
  }
}
