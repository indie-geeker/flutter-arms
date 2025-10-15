import '../../network/configs/i_network_config.dart';
import '../base_config.dart';
import '../config_validator.dart';

/// Validator for network configuration.
///
/// Validates that network configuration values are within acceptable ranges
/// and properly formatted.
///
/// Example:
/// ```dart
/// final validator = NetworkConfigValidator();
/// final result = validator.validate(myNetworkConfig);
///
/// if (!result.isValid) {
///   print('Configuration errors: ${result.errorMessage}');
/// }
/// ```
class NetworkConfigValidator<T extends BaseConfig>
    implements ConfigValidator<T> {
  /// Minimum timeout duration (1 second).
  static const minTimeout = Duration(seconds: 1);

  /// Maximum timeout duration (5 minutes).
  static const maxTimeout = Duration(minutes: 5);

  /// Recommended maximum timeout (30 seconds).
  static const recommendedMaxTimeout = Duration(seconds: 30);

  /// Creates a network configuration validator.
  const NetworkConfigValidator();

  @override
  ValidationResult validate(T config) {
    final errors = <String>[];
    final warnings = <String>[];

    // If the config implements INetWorkConfig, validate network-specific fields
    if (config is INetWorkConfig) {
      _validateNetworkConfig(config as INetWorkConfig, errors, warnings);
    }

    return errors.isEmpty
        ? ValidationResult.success(warnings: warnings)
        : ValidationResult.failure(errors: errors, warnings: warnings);
  }

  void _validateNetworkConfig(
    INetWorkConfig config,
    List<String> errors,
    List<String> warnings,
  ) {
    // Validate base URL
    _validateBaseUrl(config.baseUrl, errors, warnings);

    // Validate timeouts
    _validateTimeout(
      'connect',
      config.connectTimeout,
      errors,
      warnings,
    );
    _validateTimeout(
      'receive',
      config.receiveTimeout,
      errors,
      warnings,
    );

    // Warn if receive timeout is less than connect timeout
    if (config.receiveTimeout < config.connectTimeout) {
      warnings.add(
        'Receive timeout (${config.receiveTimeout.inSeconds}s) is less than '
        'connect timeout (${config.connectTimeout.inSeconds}s). '
        'This may cause unexpected behavior.',
      );
    }
  }

  void _validateBaseUrl(
    String baseUrl,
    List<String> errors,
    List<String> warnings,
  ) {
    if (baseUrl.isEmpty) {
      errors.add('Base URL cannot be empty');
      return;
    }

    // Check if URL is valid
    final uri = Uri.tryParse(baseUrl);
    if (uri == null) {
      errors.add('Base URL is not a valid URL: $baseUrl');
      return;
    }

    // Check if URL has a scheme
    if (!uri.hasScheme) {
      errors.add('Base URL must include a scheme (http:// or https://): $baseUrl');
      return;
    }

    // Check if using HTTP in production (warning only)
    if (uri.scheme == 'http' && !_isLocalhost(uri.host)) {
      warnings.add(
        'Base URL uses HTTP instead of HTTPS: $baseUrl. '
        'Consider using HTTPS for production environments.',
      );
    }

    // Check if URL has a host
    if (uri.host.isEmpty) {
      errors.add('Base URL must include a host: $baseUrl');
    }
  }

  void _validateTimeout(
    String name,
    Duration timeout,
    List<String> errors,
    List<String> warnings,
  ) {
    if (timeout < minTimeout) {
      errors.add(
        '$name timeout (${timeout.inMilliseconds}ms) is too short. '
        'Minimum: ${minTimeout.inMilliseconds}ms',
      );
    } else if (timeout > maxTimeout) {
      errors.add(
        '$name timeout (${timeout.inSeconds}s) is too long. '
        'Maximum: ${maxTimeout.inSeconds}s',
      );
    } else if (timeout > recommendedMaxTimeout) {
      warnings.add(
        '$name timeout (${timeout.inSeconds}s) exceeds recommended maximum '
        '(${recommendedMaxTimeout.inSeconds}s). '
        'Long timeouts may impact user experience.',
      );
    }
  }

  bool _isLocalhost(String host) {
    return host == 'localhost' ||
        host == '127.0.0.1' ||
        host == '::1' ||
        host.startsWith('192.168.') ||
        host.startsWith('10.') ||
        host.startsWith('172.');
  }
}
