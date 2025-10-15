import '../base_config.dart';
import '../config_validator.dart';

/// Validator for storage configuration.
///
/// Validates storage-related configuration values such as database paths,
/// encryption settings, and cache limits.
///
/// This is a reference implementation that can be extended based on
/// specific storage configuration requirements.
///
/// Example:
/// ```dart
/// class MyStorageConfig extends BaseConfig {
///   final String dbPath;
///   final bool enableEncryption;
///   final int maxCacheSize;
///
///   MyStorageConfig({
///     required this.dbPath,
///     required this.enableEncryption,
///     required this.maxCacheSize,
///   });
///
///   @override
///   Map<String, dynamic> toMap() => {
///     'dbPath': dbPath,
///     'enableEncryption': enableEncryption,
///     'maxCacheSize': maxCacheSize,
///   };
///
///   @override
///   String toString() => 'MyStorageConfig(${toMap()})';
///
///   @override
///   BaseConfig copyWith() => this;
/// }
///
/// final validator = StorageConfigValidator<MyStorageConfig>(
///   pathGetter: (config) => config.dbPath,
///   cacheSizeGetter: (config) => config.maxCacheSize,
/// );
/// final result = validator.validate(myConfig);
/// ```
class StorageConfigValidator<T extends BaseConfig>
    implements ConfigValidator<T> {
  /// Minimum cache size in bytes (1 MB).
  static const minCacheSize = 1024 * 1024;

  /// Maximum cache size in bytes (1 GB).
  static const maxCacheSize = 1024 * 1024 * 1024;

  /// Recommended maximum cache size in bytes (100 MB).
  static const recommendedMaxCacheSize = 100 * 1024 * 1024;

  /// Optional getter for database/storage path from config.
  final String? Function(T config)? pathGetter;

  /// Optional getter for cache size from config.
  final int? Function(T config)? cacheSizeGetter;

  /// Optional getter for encryption enabled flag from config.
  final bool? Function(T config)? encryptionEnabledGetter;

  /// Creates a storage configuration validator.
  ///
  /// Provide optional getters to extract storage-related values from your
  /// configuration object. Only the provided fields will be validated.
  const StorageConfigValidator({
    this.pathGetter,
    this.cacheSizeGetter,
    this.encryptionEnabledGetter,
  });

  @override
  ValidationResult validate(T config) {
    final errors = <String>[];
    final warnings = <String>[];

    // Validate path if getter provided
    if (pathGetter != null) {
      final path = pathGetter!(config);
      if (path != null) {
        _validatePath(path, errors, warnings);
      }
    }

    // Validate cache size if getter provided
    if (cacheSizeGetter != null) {
      final cacheSize = cacheSizeGetter!(config);
      if (cacheSize != null) {
        _validateCacheSize(cacheSize, errors, warnings);
      }
    }

    // Validate encryption if getter provided
    if (encryptionEnabledGetter != null) {
      final encryptionEnabled = encryptionEnabledGetter!(config);
      if (encryptionEnabled != null) {
        _validateEncryption(encryptionEnabled, warnings);
      }
    }

    return errors.isEmpty
        ? ValidationResult.success(warnings: warnings)
        : ValidationResult.failure(errors: errors, warnings: warnings);
  }

  void _validatePath(
    String path,
    List<String> errors,
    List<String> warnings,
  ) {
    if (path.isEmpty) {
      errors.add('Storage path cannot be empty');
      return;
    }

    // Check for potentially problematic characters
    final invalidChars = RegExp(r'[<>:"|?*]');
    if (invalidChars.hasMatch(path)) {
      errors.add(
        'Storage path contains invalid characters: $path',
      );
    }

    // Warn about absolute vs relative paths
    if (!path.startsWith('/') && !path.contains(':')) {
      warnings.add(
        'Storage path appears to be relative: $path. '
        'Consider using absolute paths for consistency.',
      );
    }
  }

  void _validateCacheSize(
    int cacheSize,
    List<String> errors,
    List<String> warnings,
  ) {
    if (cacheSize < 0) {
      errors.add('Cache size cannot be negative: $cacheSize');
      return;
    }

    if (cacheSize > 0 && cacheSize < minCacheSize) {
      warnings.add(
        'Cache size (${_formatBytes(cacheSize)}) is very small. '
        'Minimum recommended: ${_formatBytes(minCacheSize)}',
      );
    } else if (cacheSize > maxCacheSize) {
      errors.add(
        'Cache size (${_formatBytes(cacheSize)}) exceeds maximum allowed: '
        '${_formatBytes(maxCacheSize)}',
      );
    } else if (cacheSize > recommendedMaxCacheSize) {
      warnings.add(
        'Cache size (${_formatBytes(cacheSize)}) is quite large. '
        'Recommended maximum: ${_formatBytes(recommendedMaxCacheSize)}',
      );
    }
  }

  void _validateEncryption(
    bool encryptionEnabled,
    List<String> warnings,
  ) {
    if (!encryptionEnabled) {
      warnings.add(
        'Encryption is disabled. Consider enabling encryption for '
        'sensitive data in production environments.',
      );
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
