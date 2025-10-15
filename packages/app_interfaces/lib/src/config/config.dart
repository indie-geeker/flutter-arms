/// Configuration system exports.
///
/// This module provides the foundation for a type-safe, validated
/// configuration system with dependency injection support.
library;

// Core configuration interfaces
export 'base_config.dart';
export 'config_validator.dart';

// Reference validators
export 'validators/network_config_validator.dart';
export 'validators/storage_config_validator.dart';
