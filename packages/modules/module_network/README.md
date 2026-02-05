# module_network

Network module for FlutterArms. Provides a Dio-based HTTP client with logging,
retry, and cache support.

## Usage

### Initialize module

```dart
NetworkModule(
  baseUrl: 'https://api.example.com',
  connectTimeout: const Duration(seconds: 30),
  receiveTimeout: const Duration(seconds: 30),
)
```

### Request with cache options (typed)

```dart
import 'package:interfaces/interfaces.dart';

final response = await httpClient.get(
  '/users',
  cacheOptions: const NetworkCacheOptions(
    enabled: true,
    duration: Duration(minutes: 5),
    policy: CachePolicy.normal,
  ),
);
```
