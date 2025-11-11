/// Storage module for FlutterArms
///
/// Provides various module_storage implementations including:
/// - Key-Value module_storage (Hive)
/// - Secure module_storage
/// - Utilities for serialization and migration
library storage;

// Module
export 'src/storage_module.dart';

// Implementations
export 'src/impl/hive_kv_storage.dart';

// Utilities
export 'src/utils/storage_serializer.dart';
export 'src/utils/storage_migration.dart';
