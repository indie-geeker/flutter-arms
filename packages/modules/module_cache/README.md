# module_cache

Multi-level cache for FlutterArms. Provides in-memory LRU cache with optional
persistent storage via `IKeyValueStorage`.

## Usage

```dart
class UserProfileSerializer extends CacheValueSerializer<UserProfile> {
  @override
  String get type => 'user_profile';

  @override
  dynamic toJson(UserProfile value) => value.toJson();

  @override
  UserProfile fromJson(dynamic json) => UserProfile.fromJson(json);
}

final registry = CacheValueRegistry()
  ..register<UserProfile>(UserProfileSerializer());

CacheModule(
  maxMemoryItems: 200,
  valueRegistry: registry,
)
```

## Notes

- `valueRegistry` is optional. When provided, cache entries can safely serialize
  custom types.
