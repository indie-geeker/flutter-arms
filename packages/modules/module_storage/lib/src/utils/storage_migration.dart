import 'dart:async';

/// Migration script interface.
///
/// Defines behavior for a single version migration.
abstract class IMigrationScript {
  /// Source version number.
  int get fromVersion;

  /// Target version number.
  int get toVersion;

  /// Migration description.
  String get description;

  /// Executes migration.
  ///
  /// [module_storage] Storage data access interface.
  /// Returns whether the migration succeeded.
  Future<bool> migrate(StorageMigrationContext context);

  /// Rolls back migration (optional).
  ///
  /// If migration fails, attempts to roll back to original state.
  Future<void> rollback(StorageMigrationContext context) async {
    // Rollback not implemented by default.
  }
}

/// Storage migration context.
///
/// Provides migration scripts with access to storage data.
class StorageMigrationContext {
  /// Get data callback.
  final Future<Map<String, dynamic>> Function() getData;

  /// Set data callback.
  final Future<void> Function(Map<String, dynamic> data) setData;

  /// Delete key callback.
  final Future<void> Function(String key) deleteKey;

  /// Check key existence callback.
  final Future<bool> Function(String key) hasKey;

  /// Get all keys callback.
  final Future<Set<String>> Function() getKeys;

  /// Clear all data callback.
  final Future<void> Function() clear;

  StorageMigrationContext({
    required this.getData,
    required this.setData,
    required this.deleteKey,
    required this.hasKey,
    required this.getKeys,
    required this.clear,
  });
}

/// Storage migration manager.
///
/// Manages storage version upgrades and data migration.
class StorageMigration {
  /// Key name for the current storage version.
  static const String versionKey = '__storage_version__';

  /// Key prefix for backup data.
  static const String backupPrefix = '__backup_';

  /// Fixed snapshot backup key to avoid depending on runtime version for restoration.
  static const String backupSnapshotKey = '${backupPrefix}snapshot';

  /// Version metadata at backup creation time.
  static const String backupVersionKey = '${backupPrefix}version';

  /// Registered migration scripts.
  final Map<int, IMigrationScript> _migrations = {};

  /// Whether automatic backup is enabled.
  final bool enableAutoBackup;

  /// Whether to roll back on migration failure.
  final bool enableRollback;

  /// Migration progress callback.
  final void Function(MigrationProgress progress)? onProgress;

  StorageMigration({
    this.enableAutoBackup = true,
    this.enableRollback = true,
    this.onProgress,
  });

  /// Registers a migration script.
  ///
  /// [script] Migration script instance.
  void registerMigration(IMigrationScript script) {
    if (_migrations.containsKey(script.fromVersion)) {
      throw MigrationException(
        'Migration from version ${script.fromVersion} already registered',
      );
    }
    _migrations[script.fromVersion] = script;
  }

  /// Batch-registers migration scripts.
  void registerMigrations(List<IMigrationScript> scripts) {
    for (final script in scripts) {
      registerMigration(script);
    }
  }

  /// Executes migration.
  ///
  /// [context] Migration context.
  /// [targetVersion] Target version; migrates to the latest if null.
  ///
  /// Returns the version number after migration.
  Future<int> migrate(
    StorageMigrationContext context, {
    int? targetVersion,
  }) async {
    try {
      // Get current version.
      final currentVersion = await _getCurrentVersion(context);

      // Calculate target version.
      final target = targetVersion ?? _getLatestVersion();

      // Check whether migration is needed.
      if (currentVersion >= target) {
        _notifyProgress(
          currentVersion: currentVersion,
          targetVersion: target,
          message: 'No migration needed',
        );
        return currentVersion;
      }

      _notifyProgress(
        currentVersion: currentVersion,
        targetVersion: target,
        message: 'Starting migration from v$currentVersion to v$target',
      );

      // Auto backup.
      if (enableAutoBackup) {
        await _backup(context, currentVersion);
      }

      // Execute migration chain.
      var version = currentVersion;
      while (version < target) {
        final script = _migrations[version];
        if (script == null) {
          throw MigrationException(
            'No migration script found for version $version',
          );
        }

        _notifyProgress(
          currentVersion: version,
          targetVersion: target,
          currentStep: script,
          message: 'Migrating: ${script.description}',
        );

        // Execute migration.
        final success = await script.migrate(context);
        if (!success) {
          throw MigrationException(
            'Migration failed at version $version: ${script.description}',
          );
        }

        // Update version number.
        version = script.toVersion;
        await _setCurrentVersion(context, version);

        _notifyProgress(
          currentVersion: version,
          targetVersion: target,
          message: 'Migrated to v$version',
        );
      }

      // Clean up backup.
      if (enableAutoBackup) {
        await _clearBackup(context, currentVersion);
      }

      _notifyProgress(
        currentVersion: version,
        targetVersion: target,
        message: 'Migration completed successfully',
        completed: true,
      );

      return version;
    } catch (e) {
      _notifyProgress(
        currentVersion: await _getCurrentVersion(context),
        targetVersion: targetVersion ?? _getLatestVersion(),
        message: 'Migration failed: $e',
        error: e,
      );

      // Attempt rollback.
      if (enableRollback && enableAutoBackup) {
        await _restoreFromBackup(context);
      }

      rethrow;
    }
  }

  /// Gets the current storage version.
  Future<int> _getCurrentVersion(StorageMigrationContext context) async {
    final data = await context.getData();
    return (data[versionKey] as int?) ?? 0;
  }

  /// Sets the current storage version.
  Future<void> _setCurrentVersion(
    StorageMigrationContext context,
    int version,
  ) async {
    final data = await context.getData();
    data[versionKey] = version;
    await context.setData(data);
  }

  /// Gets the latest version number.
  int _getLatestVersion() {
    if (_migrations.isEmpty) return 0;
    return _migrations.values
        .map((script) => script.toVersion)
        .reduce((a, b) => a > b ? a : b);
  }

  /// Backs up current data.
  Future<void> _backup(StorageMigrationContext context, int version) async {
    final data = await context.getData();
    final snapshot = Map<String, dynamic>.from(data);
    final dataWithBackup = Map<String, dynamic>.from(data)
      ..[backupSnapshotKey] = snapshot
      ..[backupVersionKey] = version;
    await context.clear();
    await context.setData(dataWithBackup);
  }

  /// Restores data from backup.
  Future<void> _restoreFromBackup(StorageMigrationContext context) async {
    if (!await context.hasKey(backupSnapshotKey)) {
      throw MigrationException('No backup snapshot found');
    }

    final data = await context.getData();
    final backup = data[backupSnapshotKey];

    if (backup is Map) {
      final restoredData = <String, dynamic>{};
      for (final entry in backup.entries) {
        restoredData[entry.key.toString()] = entry.value;
      }
      await context.clear();
      await context.setData(restoredData);
      return;
    }

    throw MigrationException('Invalid backup snapshot format');
  }

  /// Cleans up backup data.
  Future<void> _clearBackup(
    StorageMigrationContext context,
    int version,
  ) async {
    final data = await context.getData();
    final legacyBackupKey = '$backupPrefix$version';
    data.remove(backupSnapshotKey);
    data.remove(backupVersionKey);
    data.remove(legacyBackupKey);
    await context.clear();
    await context.setData(data);
  }

  /// Notifies migration progress.
  void _notifyProgress({
    required int currentVersion,
    required int targetVersion,
    IMigrationScript? currentStep,
    String? message,
    Object? error,
    bool completed = false,
  }) {
    if (onProgress != null) {
      onProgress!(
        MigrationProgress(
          currentVersion: currentVersion,
          targetVersion: targetVersion,
          currentStep: currentStep,
          message: message,
          error: error,
          completed: completed,
        ),
      );
    }
  }

  /// Checks whether the migration path is complete.
  ///
  /// Verifies that migration scripts from version 0 to the latest are contiguous.
  bool validateMigrationPath() {
    if (_migrations.isEmpty) return true;

    final maxVersion = _getLatestVersion();
    for (var i = 0; i < maxVersion; i++) {
      if (!_migrations.containsKey(i)) {
        return false;
      }
      final script = _migrations[i]!;
      if (script.toVersion != i + 1) {
        return false;
      }
    }
    return true;
  }

  /// Gets the migration path.
  ///
  /// Returns migration scripts from [fromVersion] to [toVersion].
  List<IMigrationScript> getMigrationPath(int fromVersion, int toVersion) {
    final path = <IMigrationScript>[];
    var version = fromVersion;

    while (version < toVersion) {
      final script = _migrations[version];
      if (script == null) {
        throw MigrationException(
          'No migration script found for version $version',
        );
      }
      path.add(script);
      version = script.toVersion;
    }

    return path;
  }

  /// Clears all registered migration scripts.
  void clearMigrations() {
    _migrations.clear();
  }
}

/// Migration progress info.
class MigrationProgress {
  /// Current version.
  final int currentVersion;

  /// Target version.
  final int targetVersion;

  /// Current migration step being executed.
  final IMigrationScript? currentStep;

  /// Progress message.
  final String? message;

  /// Error info.
  final Object? error;

  /// Whether completed.
  final bool completed;

  MigrationProgress({
    required this.currentVersion,
    required this.targetVersion,
    this.currentStep,
    this.message,
    this.error,
    this.completed = false,
  });

  /// Calculates progress percentage (0.0 - 1.0).
  double get progress {
    if (targetVersion == currentVersion) return 1.0;
    return currentVersion / targetVersion;
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('MigrationProgress(');
    buffer.write('$currentVersion → $targetVersion');
    if (message != null) {
      buffer.write(', $message');
    }
    if (error != null) {
      buffer.write(', error: $error');
    }
    buffer.write(')');
    return buffer.toString();
  }
}

/// Migration exception.
class MigrationException implements Exception {
  final String message;

  MigrationException(this.message);

  @override
  String toString() => 'MigrationException: $message';
}
