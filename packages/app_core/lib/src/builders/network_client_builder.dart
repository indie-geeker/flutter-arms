import 'package:app_interfaces/app_interfaces.dart';
import 'package:app_network/app_network.dart';

/// Builder for creating NetworkClient from configuration.
///
/// This builder simplifies network client creation by automatically
/// extracting configuration from INetWorkConfig implementations.
///
/// Example:
/// ```dart
/// final client = NetworkClientBuilder.fromConfig(
///   myAppConfig,
///   logger: Logger(),
/// );
/// ```
class NetworkClientBuilder {
  /// Creates a NetworkClient from INetWorkConfig.
  ///
  /// This method automatically extracts network configuration from the
  /// provided config and creates a properly configured NetworkClient.
  ///
  /// Parameters:
  /// - [config]: Configuration implementing INetWorkConfig (e.g., BaseAppConfig)
  /// - [logger]: Optional logger for network operations
  /// - [interceptors]: Optional list of interceptors to add
  /// - [defaultHeaders]: Optional default headers for all requests
  ///
  /// Returns a fully configured NetworkClient instance.
  static NetworkClient fromConfig(
    INetWorkConfig config, {
    ILogger? logger,
    List<IRequestInterceptor>? interceptors,
    Map<String, String>? defaultHeaders,
  }) {
    // Create NetworkConfig from INetWorkConfig
    final networkConfig = NetworkConfig(
      baseUrl: config.baseUrl,
      connectTimeout: config.connectTimeout,
      receiveTimeout: config.receiveTimeout,
      logger: logger,
      enableLogging: _shouldEnableLogging(config),
      defaultHeaders: defaultHeaders ?? {},
    );

    // Create the network client
    final client = NetworkClientFactory.create(
      config: networkConfig,
      customInterceptors: interceptors,
    );

    // Enable logging if configured
    if (_shouldEnableLogging(config)) {
      client.enableLogging();
    }

    return client;
  }

  /// Determines if logging should be enabled based on config.
  static bool _shouldEnableLogging(INetWorkConfig config) {
    // Try to get enableVerboseLogging if config also implements IEnvironmentConfig
    if (config is IEnvironmentConfig) {
      return (config as IEnvironmentConfig).enableVerboseLogging;
    }
    return false;
  }
}
