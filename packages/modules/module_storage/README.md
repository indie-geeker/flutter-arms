# module_storage

Storage module for FlutterArms. Provides Hive CE-backed key-value storage.

## Usage

```dart
StorageModule(
  config: StorageConfig(
    kvStorageBoxName: 'app_storage',
    baseDir: '/path/to/hive_ce',
  ),
)
```

## Notes

- `baseDir` is optional. Absolute paths use `Hive.init`, relative paths use
  `Hive.initFlutter` subdirectories, and `null` falls back to the default
  `flutter_arms_storage` directory.
