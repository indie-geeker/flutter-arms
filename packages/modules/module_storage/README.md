# module_storage

Storage module for FlutterArms. Provides Hive-backed key-value storage and optional
secure storage.

## Usage

```dart
StorageModule(
  config: StorageConfig(
    kvStorageBoxName: 'app_storage',
    baseDir: '/path/to/hive',
    enableSecureStorage: true,
  ),
)
```

## Notes

- `baseDir` is optional. Absolute paths use `Hive.init`, relative paths use
  `Hive.initFlutter` subdirectories, and `null` falls back to the default
  `flutter_arms_storage` directory.
