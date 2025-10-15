import 'package:app_interfaces/app_interfaces.dart';
import 'package:app_network/app_network.dart';

/// Extension methods for INetWorkConfig to simplify network setup.
extension NetworkConfigExtension on INetWorkConfig {
  /// Converts this INetWorkConfig to a NetworkConfig.
  ///
  /// This is useful when you need to pass configuration to components
  /// that expect NetworkConfig specifically.
  ///
  /// Parameters:
  /// - [logger]: Optional logger for network operations
  ///
  /// Example:
  /// ```dart
  /// final networkConfig = myAppConfig.toNetworkConfig(logger: Logger());
  /// ```
  NetworkConfig toNetworkConfig({ILogger? logger}) {
    return NetworkConfig(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      logger: logger,
      enableLogging: this is IEnvironmentConfig
          ? (this as IEnvironmentConfig).enableVerboseLogging
          : false,
    );
  }

  /// Checks if verbose logging is enabled.
  ///
  /// Returns true if this config also implements IEnvironmentConfig
  /// and has verbose logging enabled.
  bool get hasVerboseLogging {
    if (this is IEnvironmentConfig) {
      return (this as IEnvironmentConfig).enableVerboseLogging;
    }
    return false;
  }
}

/// Extension methods for BaseConfig to simplify common operations.
extension BaseConfigExtension on BaseConfig {
  /// Gets the environment type if this config implements IEnvironmentConfig.
  ///
  /// Returns EnvironmentType.development if not implemented.
  EnvironmentType get environmentType {
    if (this is IEnvironmentConfig) {
      return (this as IEnvironmentConfig).environmentType;
    }
    return EnvironmentType.development;
  }

  /// Checks if this is a production environment.
  bool get isProduction {
    return environmentType == EnvironmentType.production;
  }

  /// Checks if this is a development environment.
  bool get isDevelopment {
    return environmentType == EnvironmentType.development;
  }

  /// Checks if this is a staging environment.
  bool get isStaging {
    return environmentType == EnvironmentType.staging;
  }

  /// Checks if this is a test environment.
  bool get isTest {
    return environmentType == EnvironmentType.test;
  }
}
