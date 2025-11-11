import 'dart:async';

/// 迁移脚本接口
///
/// 定义单个版本迁移的行为
abstract class IMigrationScript {
  /// 源版本号
  int get fromVersion;

  /// 目标版本号
  int get toVersion;

  /// 迁移描述
  String get description;

  /// 执行迁移
  ///
  /// [storage] 存储数据的访问接口
  /// 返回是否迁移成功
  Future<bool> migrate(StorageMigrationContext context);

  /// 回滚迁移（可选）
  ///
  /// 如果迁移失败，尝试回滚到原始状态
  Future<void> rollback(StorageMigrationContext context) async {
    // 默认不实现回滚
  }
}

/// 存储迁移上下文
///
/// 提供迁移脚本访问存储数据的接口
class StorageMigrationContext {
  /// 获取数据的回调
  final Future<Map<String, dynamic>> Function() getData;

  /// 设置数据的回调
  final Future<void> Function(Map<String, dynamic> data) setData;

  /// 删除键的回调
  final Future<void> Function(String key) deleteKey;

  /// 检查键是否存在的回调
  final Future<bool> Function(String key) hasKey;

  /// 获取所有键的回调
  final Future<Set<String>> Function() getKeys;

  /// 清空所有数据的回调
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

/// 存储迁移管理器
///
/// 管理存储版本升级和数据迁移
class StorageMigration {
  /// 当前存储版本的键名
  static const String versionKey = '__storage_version__';

  /// 备份数据的键名前缀
  static const String backupPrefix = '__backup_';

  /// 注册的迁移脚本
  final Map<int, IMigrationScript> _migrations = {};

  /// 是否启用自动备份
  final bool enableAutoBackup;

  /// 迁移失败时是否回滚
  final bool enableRollback;

  /// 迁移进度回调
  final void Function(MigrationProgress progress)? onProgress;

  StorageMigration({
    this.enableAutoBackup = true,
    this.enableRollback = true,
    this.onProgress,
  });

  /// 注册迁移脚本
  ///
  /// [script] 迁移脚本实例
  void registerMigration(IMigrationScript script) {
    if (_migrations.containsKey(script.fromVersion)) {
      throw MigrationException(
        'Migration from version ${script.fromVersion} already registered',
      );
    }
    _migrations[script.fromVersion] = script;
  }

  /// 批量注册迁移脚本
  void registerMigrations(List<IMigrationScript> scripts) {
    for (final script in scripts) {
      registerMigration(script);
    }
  }

  /// 执行迁移
  ///
  /// [context] 迁移上下文
  /// [targetVersion] 目标版本，如果为 null 则迁移到最新版本
  ///
  /// 返回迁移后的版本号
  Future<int> migrate(
    StorageMigrationContext context, {
    int? targetVersion,
  }) async {
    try {
      // 获取当前版本
      final currentVersion = await _getCurrentVersion(context);

      // 计算目标版本
      final target = targetVersion ?? _getLatestVersion();

      // 检查是否需要迁移
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

      // 自动备份
      if (enableAutoBackup) {
        await _backup(context, currentVersion);
      }

      // 执行迁移链
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

        // 执行迁移
        final success = await script.migrate(context);
        if (!success) {
          throw MigrationException(
            'Migration failed at version $version: ${script.description}',
          );
        }

        // 更新版本号
        version = script.toVersion;
        await _setCurrentVersion(context, version);

        _notifyProgress(
          currentVersion: version,
          targetVersion: target,
          message: 'Migrated to v$version',
        );
      }

      // 清理备份
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

      // 尝试回滚
      if (enableRollback && enableAutoBackup) {
        await _restoreFromBackup(context);
      }

      rethrow;
    }
  }

  /// 获取当前存储版本
  Future<int> _getCurrentVersion(StorageMigrationContext context) async {
    final data = await context.getData();
    return (data[versionKey] as int?) ?? 0;
  }

  /// 设置当前存储版本
  Future<void> _setCurrentVersion(
    StorageMigrationContext context,
    int version,
  ) async {
    final data = await context.getData();
    data[versionKey] = version;
    await context.setData(data);
  }

  /// 获取最新版本号
  int _getLatestVersion() {
    if (_migrations.isEmpty) return 0;
    return _migrations.values
        .map((script) => script.toVersion)
        .reduce((a, b) => a > b ? a : b);
  }

  /// 备份当前数据
  Future<void> _backup(
    StorageMigrationContext context,
    int version,
  ) async {
    final data = await context.getData();
    final backupKey = '$backupPrefix$version';
    await context.setData({backupKey: data});
  }

  /// 从备份恢复数据
  Future<void> _restoreFromBackup(StorageMigrationContext context) async {
    final version = await _getCurrentVersion(context);
    final backupKey = '$backupPrefix$version';

    if (!await context.hasKey(backupKey)) {
      throw MigrationException('No backup found for version $version');
    }

    final data = await context.getData();
    final backup = data[backupKey] as Map<String, dynamic>?;

    if (backup != null) {
      await context.clear();
      await context.setData(backup);
    }
  }

  /// 清理备份数据
  Future<void> _clearBackup(
    StorageMigrationContext context,
    int version,
  ) async {
    final backupKey = '$backupPrefix$version';
    await context.deleteKey(backupKey);
  }

  /// 通知迁移进度
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

  /// 检查迁移路径是否完整
  ///
  /// 验证从版本 0 到最新版本的迁移脚本是否连续
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

  /// 获取迁移路径
  ///
  /// 返回从 [fromVersion] 到 [toVersion] 的迁移脚本列表
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

  /// 清空所有注册的迁移脚本
  void clearMigrations() {
    _migrations.clear();
  }
}

/// 迁移进度信息
class MigrationProgress {
  /// 当前版本
  final int currentVersion;

  /// 目标版本
  final int targetVersion;

  /// 当前执行的迁移步骤
  final IMigrationScript? currentStep;

  /// 进度消息
  final String? message;

  /// 错误信息
  final Object? error;

  /// 是否完成
  final bool completed;

  MigrationProgress({
    required this.currentVersion,
    required this.targetVersion,
    this.currentStep,
    this.message,
    this.error,
    this.completed = false,
  });

  /// 计算进度百分比 (0.0 - 1.0)
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

/// 迁移异常
class MigrationException implements Exception {
  final String message;

  MigrationException(this.message);

  @override
  String toString() => 'MigrationException: $message';
}
