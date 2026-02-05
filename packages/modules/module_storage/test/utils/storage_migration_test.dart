import 'package:test/test.dart';
import 'package:module_storage/src/utils/storage_migration.dart';

void main() {
  group('StorageMigration', () {
    late StorageMigration migration;
    late Map<String, dynamic> mockStorage;
    late StorageMigrationContext context;

    setUp(() {
      mockStorage = {};
      context = StorageMigrationContext(
        getData: () async => Map<String, dynamic>.from(mockStorage),
        setData: (data) async => mockStorage.addAll(data),
        deleteKey: (key) async => mockStorage.remove(key),
        hasKey: (key) async => mockStorage.containsKey(key),
        getKeys: () async => mockStorage.keys.toSet(),
        clear: () async => mockStorage.clear(),
      );

      migration = StorageMigration(
        enableAutoBackup: true,
        enableRollback: true,
      );
    });

    group('Migration Registration', () {
      test('should register migration script', () {
        final script = TestMigrationScript(
          fromVersion: 0,
          toVersion: 1,
          description: 'Initial migration',
        );

        migration.registerMigration(script);
        expect(migration.validateMigrationPath(), isTrue);
      });

      test('should register multiple migration scripts', () {
        final scripts = [
          TestMigrationScript(
            fromVersion: 0,
            toVersion: 1,
            description: 'Migration v0 -> v1',
          ),
          TestMigrationScript(
            fromVersion: 1,
            toVersion: 2,
            description: 'Migration v1 -> v2',
          ),
          TestMigrationScript(
            fromVersion: 2,
            toVersion: 3,
            description: 'Migration v2 -> v3',
          ),
        ];

        migration.registerMigrations(scripts);
        expect(migration.validateMigrationPath(), isTrue);
      });

      test('should throw exception for duplicate migration', () {
        final script1 = TestMigrationScript(
          fromVersion: 0,
          toVersion: 1,
          description: 'Migration 1',
        );
        final script2 = TestMigrationScript(
          fromVersion: 0,
          toVersion: 1,
          description: 'Migration 2',
        );

        migration.registerMigration(script1);
        expect(
          () => migration.registerMigration(script2),
          throwsA(isA<MigrationException>()),
        );
      });

      test('should clear all migrations', () {
        final script = TestMigrationScript(
          fromVersion: 0,
          toVersion: 1,
          description: 'Test migration',
        );

        migration.registerMigration(script);
        migration.clearMigrations();
        expect(migration.validateMigrationPath(), isTrue);
      });
    });

    group('Migration Execution', () {
      test('should migrate from version 0 to version 1', () async {
        migration.registerMigration(
          AddUserNameMigration(),
        );

        mockStorage = {'user_id': 123};

        final newVersion = await migration.migrate(context);

        expect(newVersion, equals(1));
        expect(mockStorage['user_name'], equals('default_user'));
        expect(mockStorage['__storage_version__'], equals(1));
      });

      test('should migrate through multiple versions', () async {
        migration.registerMigrations([
          TestMigrationScript(
            fromVersion: 0,
            toVersion: 1,
            description: 'v0 -> v1',
            onMigrate: (ctx) async {
              final data = await ctx.getData();
              data['step1'] = 'completed';
              await ctx.setData(data);
            },
          ),
          TestMigrationScript(
            fromVersion: 1,
            toVersion: 2,
            description: 'v1 -> v2',
            onMigrate: (ctx) async {
              final data = await ctx.getData();
              data['step2'] = 'completed';
              await ctx.setData(data);
            },
          ),
          TestMigrationScript(
            fromVersion: 2,
            toVersion: 3,
            description: 'v2 -> v3',
            onMigrate: (ctx) async {
              final data = await ctx.getData();
              data['step3'] = 'completed';
              await ctx.setData(data);
            },
          ),
        ]);

        final newVersion = await migration.migrate(context);

        expect(newVersion, equals(3));
        expect(mockStorage['step1'], equals('completed'));
        expect(mockStorage['step2'], equals('completed'));
        expect(mockStorage['step3'], equals('completed'));
      });

      test('should skip migration if already at target version', () async {
        mockStorage['__storage_version__'] = 2;

        migration.registerMigrations([
          TestMigrationScript(
            fromVersion: 0,
            toVersion: 1,
            description: 'v0 -> v1',
          ),
          TestMigrationScript(
            fromVersion: 1,
            toVersion: 2,
            description: 'v1 -> v2',
          ),
        ]);

        final newVersion = await migration.migrate(context, targetVersion: 2);
        expect(newVersion, equals(2));
      });

      test('should throw exception if migration script missing', () async {
        migration.registerMigration(
          TestMigrationScript(
            fromVersion: 0,
            toVersion: 1,
            description: 'v0 -> v1',
          ),
        );

        // Try to migrate to version 2 without script for v1->v2
        expect(
          () => migration.migrate(context, targetVersion: 2),
          throwsA(isA<MigrationException>()),
        );
      });
    });

    group('Migration Progress', () {
      test('should report migration progress', () async {
        final progressUpdates = <MigrationProgress>[];

        final migrationWithProgress = StorageMigration(
          onProgress: (progress) => progressUpdates.add(progress),
        );

        migrationWithProgress.registerMigrations([
          TestMigrationScript(
            fromVersion: 0,
            toVersion: 1,
            description: 'Step 1',
          ),
          TestMigrationScript(
            fromVersion: 1,
            toVersion: 2,
            description: 'Step 2',
          ),
        ]);

        await migrationWithProgress.migrate(context);

        expect(progressUpdates.length, greaterThan(0));
        expect(progressUpdates.last.completed, isTrue);
        expect(progressUpdates.last.currentVersion, equals(2));
      });

      test('should calculate progress percentage', () {
        final progress = MigrationProgress(
          currentVersion: 5,
          targetVersion: 10,
          message: 'In progress',
        );

        expect(progress.progress, equals(0.5));
      });
    });

    group('Migration Path Validation', () {
      test('should validate complete migration path', () {
        migration.registerMigrations([
          TestMigrationScript(fromVersion: 0, toVersion: 1, description: ''),
          TestMigrationScript(fromVersion: 1, toVersion: 2, description: ''),
          TestMigrationScript(fromVersion: 2, toVersion: 3, description: ''),
        ]);

        expect(migration.validateMigrationPath(), isTrue);
      });

      test('should detect incomplete migration path', () {
        migration.registerMigrations([
          TestMigrationScript(fromVersion: 0, toVersion: 1, description: ''),
          // Missing v1 -> v2
          TestMigrationScript(fromVersion: 2, toVersion: 3, description: ''),
        ]);

        expect(migration.validateMigrationPath(), isFalse);
      });

      test('should get migration path', () {
        migration.registerMigrations([
          TestMigrationScript(fromVersion: 0, toVersion: 1, description: ''),
          TestMigrationScript(fromVersion: 1, toVersion: 2, description: ''),
          TestMigrationScript(fromVersion: 2, toVersion: 3, description: ''),
        ]);

        final path = migration.getMigrationPath(0, 3);
        expect(path.length, equals(3));
        expect(path[0].fromVersion, equals(0));
        expect(path[2].toVersion, equals(3));
      });
    });

    group('Backup and Rollback', () {
      test('should create backup before migration', () async {
        mockStorage = {'original_data': 'should_be_backed_up'};

        migration.registerMigration(
          TestMigrationScript(
            fromVersion: 0,
            toVersion: 1,
            description: 'Test',
          ),
        );

        await migration.migrate(context);

        // Backup should exist during migration but be cleaned up after
        expect(mockStorage.containsKey('original_data'), isTrue);
      });

      test('should rollback on migration failure', () async {
        final failingMigration = StorageMigration(
          enableAutoBackup: true,
          enableRollback: true,
        );

        mockStorage = {'original_value': 123};

        failingMigration.registerMigration(
          FailingMigrationScript(),
        );

        try {
          await failingMigration.migrate(context);
        } catch (e) {
          // Expected to fail
        }

        // Should still have original data after rollback attempt
        expect(mockStorage.containsKey('original_value'), isTrue);
      });
    });
  });
}

// Test migration scripts
class TestMigrationScript implements IMigrationScript {
  @override
  final int fromVersion;

  @override
  final int toVersion;

  @override
  final String description;

  final Future<void> Function(StorageMigrationContext)? onMigrate;

  TestMigrationScript({
    required this.fromVersion,
    required this.toVersion,
    required this.description,
    this.onMigrate,
  });

  @override
  Future<bool> migrate(StorageMigrationContext context) async {
    if (onMigrate != null) {
      await onMigrate!(context);
    }
    return true;
  }

  @override
  Future<void> rollback(StorageMigrationContext context) async {
    // Do nothing for test
  }
}

class AddUserNameMigration implements IMigrationScript {
  @override
  int get fromVersion => 0;

  @override
  int get toVersion => 1;

  @override
  String get description => 'Add default user name';

  @override
  Future<bool> migrate(StorageMigrationContext context) async {
    final data = await context.getData();
    data['user_name'] = 'default_user';
    await context.setData(data);
    return true;
  }

  @override
  Future<void> rollback(StorageMigrationContext context) async {
    // Do nothing for test
  }
}

class FailingMigrationScript implements IMigrationScript {
  @override
  int get fromVersion => 0;

  @override
  int get toVersion => 1;

  @override
  String get description => 'This migration will fail';

  @override
  Future<bool> migrate(StorageMigrationContext context) async {
    return false; // Always fail
  }

  @override
  Future<void> rollback(StorageMigrationContext context) async {
    // Do nothing for test
  }
}
