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
  sendTimeout: const Duration(seconds: 30),
  defaultHeaders: const {
    'X-App': 'flutter-arms',
  },
  enableCache: true,
  defaultCacheDuration: const Duration(minutes: 5),
)
```

### Initialize from `NetworkConfig`

```dart
final config = NetworkConfig.production(baseUrl: 'https://api.example.com');
final module = NetworkModule.fromConfig(config);
```

`NetworkModule.fromConfig` now maps and applies:

- `connectTimeout` / `receiveTimeout` / `sendTimeout`
- `defaultHeaders`
- `enableCache` / `defaultCacheDuration`
- `enableLogging`
- `retryConfig`
- `proxyConfig` (native IO platforms supported; unsupported platforms degrade safely)

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

### Cache policy behavior

- `CachePolicy.cacheFirst` / `CachePolicy.normal`: tries cache on request; cache hit returns immediately.
- `CachePolicy.networkFirst`: skips request-time cache read, then falls back to cache on network error.

### Proxy behavior

- On native IO platforms, `proxyConfig` configures Dio's `IOHttpClientAdapter` proxy routing.
- On unsupported platforms (e.g., Web), proxy config is ignored with a warning log.
