# flutter-arms

> A modular, extensible Flutter framework for rapid multi-platform application development

[![Flutter Version](https://img.shields.io/badge/Flutter-3.41.2-02569B?logo=flutter)](https://flutter.dev)
[![Melos](https://img.shields.io/badge/maintained%20with-melos-f700ff.svg)](https://github.com/invertase/melos)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

flutter-arms is a production-ready Flutter monorepo framework designed to accelerate application development through clean architecture principles and modular design. Built for developers who need a solid foundation with pluggable infrastructure components.

## Table of Contents

- [Features](#features)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Running the Example App](#running-the-example-app)
- [Usage](#usage)
- [Available Modules](#available-modules)
- [Development](#development)
  - [Adding New Modules](#adding-new-modules)
  - [Running Tests](#running-tests)
  - [Release Notes](#release-notes)
  - [Code Generation](#code-generation)
- [Advanced Docs](#advanced-docs)
- [Tech Stack](#tech-stack)
- [Contributing](#contributing)
- [License](#license)

## Features

- **Clean Architecture** - Separation of concerns with interface-driven design
- **Modular Infrastructure** - Pluggable modules for network, storage, cache, and logging
- **Dependency Injection** - Built-in DI using GetIt for flexible configuration
- **Monorepo Structure** - Dart workspace with Melos for efficient multi-package development
- **Type Safety** - Full Dart 3+ support with sound null safety
- **Extensible** - Easy to add, replace, or remove infrastructure modules
- **Composable Demo** - Example app defaults to logger + secure storage, with cache/network as opt-in modules
- **Structured Logging** - `ILogger` supports contextual `extras` for machine-readable logs

## Architecture

flutter-arms follows a layered architecture with clear separation of concerns:

```
┌─────────────────────────────────────────┐
│           Application Layer             │
│         (Business Logic & UI)           │
│              app/example                │
└─────────────────┬───────────────────────┘
                  │ depends on
┌─────────────────▼───────────────────────┐
│          Aggregation Layer              │
│     (DI Container & Coordination)       │
│           packages/core                 │
└─────────────────┬───────────────────────┘
                  │ depends on
┌─────────────────▼───────────────────────┐
│         Interface Layer                 │
│      (Abstract Contracts Only)          │
│        packages/interfaces              │
└─────────────────▲───────────────────────┘
                  │ implements
┌─────────────────┴───────────────────────┐
│       Infrastructure Layer              │
│    (Concrete Implementations)           │
│       packages/modules/*                │
└─────────────────────────────────────────┘
```

### Layer Responsibilities

1. **interfaces** - Abstract definitions
   - Defines contracts for all infrastructure services
   - No implementation details
   - Stable API for business logic

2. **modules** - Infrastructure implementations
   - Concrete implementations of interfaces
   - Module implementations: network, cache, logger, storage
   - Swappable based on requirements

3. **core** - Aggregation & coordination
   - Dependency injection setup
   - Module registration and initialization
   - Unified API facade for application layer

4. **app** - Application layer
   - Business logic and UI
   - Depends only on core and interfaces
   - Platform-specific implementations

## Project Structure

```
flutter-arms/
├── packages/
│   ├── interfaces/          # Abstract interface definitions
│   │   └── lib/
│   │       ├── network/     # Network service contracts
│   │       ├── cache/       # Cache service contracts
│   │       ├── logger/      # Logger service contracts
│   │       └── storage/     # Storage service contracts
│   │
│   ├── core/                # Core aggregation layer
│   │   └── lib/
│   │       └── di/          # Dependency injection setup
│   │
│   └── modules/             # Infrastructure implementations
│       ├── module_network/  # Network module (Dio, HTTP)
│       ├── module_cache/    # Cache module (Hive, SharedPreferences)
│       ├── module_logger/   # Logger module
│       └── module_storage/  # Storage module
│
├── app/
│   └── example/
│       ├── lib/
│       │   └── src/
│       │       ├── app/                    # App shell
│       │       ├── bootstrap/              # Module composition and profile flags
│       │       ├── core/                   # Shared constants/entities
│       │       ├── di/                     # Provider export facade
│       │       ├── features/
│       │       │   ├── authentication/     # data/domain/presentation/di
│       │       │   ├── network_demo/       # data/domain/presentation/di
│       │       │   └── settings/           # presentation-focused feature
│       │       └── router/                 # AutoRoute wiring
│       ├── test/
│       │   └── features/                   # Feature-aligned tests
│       └── pubspec.yaml
│
├── melos.yaml               # Melos workspace configuration
└── README.md
```

Dependency boundaries are documented in
[`docs/architecture-rules.md`](docs/architecture-rules.md) and enforced by:

```bash
melos run lint:arch
```

## Getting Started

### Prerequisites

- [Flutter 3.41.2](https://flutter.dev/docs/get-started/install) (recommended via FVM)
- Dart SDK ^3.11.0 (included with Flutter)

### Installation

1. **Clone the repository**

```bash
git clone https://github.com/indie-geeker/flutter-arms
cd flutter-arms
```

2. **Bootstrap the workspace**

```bash
dart pub global activate melos
melos bootstrap
```

Optional (recommended) to align local tooling with CI:

```bash
fvm use
```

This will:
- Install all package dependencies
- Link local packages together
- Generate necessary files

### Running the Example App

```bash
cd app/example
dart run build_runner build --delete-conflicting-outputs
flutter run
```

Select your target device when prompted.

> Note: Generated files (`*.g.dart`, `*.freezed.dart`, `*.gr.dart`) are not
> committed. Always run code generation before analyzing, testing, or running
> the example app.

## Usage

### Integrating flutter-arms in Your Project

1. **Add dependencies to your `pubspec.yaml`**

```yaml
dependencies:
  core:
    path: ../../packages/core

```

2. **Initialize the core in your app**

```dart
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interfaces/logger/log_level.dart';
import 'package:module_logger/module_logger.dart';
import 'package:module_storage/module_storage.dart';
import 'package:module_cache/module_cache.dart';
import 'package:module_network/module_network.dart';

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final AppInitializerController initializerController =
      AppInitializerController();

  @override
  Widget build(BuildContext context) {
    return AppInitializerWidget(
      controller: initializerController,
      modules: [
        // Logger Module - initialize first
        LoggerModule(initialLevel: LogLevel.debug),
        // Storage Module - for persistence
        StorageModule(
          config: StorageConfig(enableSecureStorage: true),
        ),
        // Cache Module - optional
        CacheModule(),
        // Network Module - optional
        NetworkModule(
          baseUrl: 'https://jsonplaceholder.typicode.com',
          enableCache: true,
          connectTimeout: Duration(seconds: 30),
        ),
      ],

      // Custom loading screen (optional)
      loadingBuilder: (context, progress) {
        return MaterialApp(
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 24),
                  Text(progress.message),
                ],
              ),
            ),
          ),
        );
      },

      // Main app (shown after modules initialize)
      child: const ProviderScope(child: MainApp()),
    );
  }
}
```

When you have an app-level shutdown hook that supports `await`, call:

```dart
await initializerController.shutdown();
```

3. **Use infrastructure services via Riverpod providers**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';

// Create a provider that uses infrastructure services
@riverpod
MyDataSource myDataSource(Ref ref) {
  final storage = ref.watch(kvStorageProvider);
  final logger = ref.watch(loggerProvider);
  return MyDataSource(storage, logger);
}

// Use in widgets with ConsumerWidget
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataSource = ref.watch(myDataSourceProvider);
    // Use dataSource...
  }
}
```

## Available Modules

| Module | Status | Description |
|--------|--------|-------------|
| `module_logger` | ✅ Available | Logging infrastructure |
| `module_storage` | ✅ Available | Persistent storage |
| `module_cache` | ✅ Available | In-memory and persistent caching |
| `module_network` | ✅ Available | HTTP client and networking |

## Development

### Scaffolding New App (Templates)

Use the built-in scaffold command to generate a workspace app under `app/<name>`:

```bash
melos run create:app -- --name demo_app
```

Common options:

```bash
# Only apply templates (skip flutter create)
melos run create:app -- --name demo_app --template-only

# Keep workspace unchanged for local experiments
melos run create:app -- --name demo_app --no-workspace-registration

# Generate with optional modules
melos run create:app -- --name demo_app --with-feature --with-tests
```

The scaffold generates architecture-aligned structure under `lib/src/`:

- `app/` app shell
- `features/` feature-slice code
- `di/` provider facade
- `router/` route wiring (when enabled)

For command details:

```bash
dart run scripts/create_app.dart --help
```

### Adding New Modules

1. **Define the interface** in `packages/interfaces/lib/`

```dart
// packages/interfaces/lib/analytics/i_analytics.dart
abstract class IAnalytics {
  Future<void> logEvent(String name, Map<String, dynamic> params);
  Future<void> setUserId(String userId);
}
```

2. **Create the implementation** in `packages/modules/`

```bash
cd packages/modules
flutter create --template=package module_analytics
```

3. **Implement the interface**

```dart
// packages/modules/module_analytics/lib/analytics_impl.dart
import 'package:interfaces/analytics/i_analytics.dart';

class AnalyticsImpl implements IAnalytics {
  @override
  Future<void> logEvent(String name, Map<String, dynamic> params) async {
    // Implementation using Firebase Analytics, Mixpanel, etc.
  }

  @override
  Future<void> setUserId(String userId) async {
    // Implementation
  }
}
```

4. **Register in core** DI container

```dart
// In core/lib/di/service_locator.dart
getIt.registerLazySingleton<IAnalytics>(() => AnalyticsImpl());
```

> When implementing `IModule`, make sure to declare both `dependencies` and `provides`
> so the module registry can order initialization correctly.

5. **Bootstrap and use**

```bash
melos bootstrap
```

### Advanced Options

- **Enable network cache dependency**
  - `NetworkModule(baseUrl: '...', enableCache: true)`
- **Per-request cache control**
  - `httpClient.get('/users', cacheOptions: const NetworkCacheOptions(enabled: true, duration: Duration(minutes: 5)))`
- **Custom cache serializers**
  - `CacheModule(valueRegistry: CacheValueRegistry()..register(MySerializer()))`
- **Enable secure storage**
  - `StorageModule(config: StorageConfig(enableSecureStorage: true))`
- **Customize storage base directory**
  - `StorageModule(config: StorageConfig(baseDir: '/path/to/hive'))`

### Running Tests

```bash
# Run analysis/tests for all workspace packages
melos run analyze
melos run test
# One-shot workspace gate (bootstrap + analyze + test)
melos run verify

# CI required baseline (main workflow):
# - flutter analyze
# - flutter test

# Run tests for specific package
cd packages/core
flutter test

# Staged quality check (manual / scheduled workflow):
# 1) collect coverage
melos run test:coverage
# 2) enforce staged coverage gate
scripts/check_coverage.sh

# The gate checks: core/interfaces/module_*/app/example
# and fails if any package coverage report is missing or empty.

# Override thresholds if needed
MIN_TOTAL_COVERAGE=60 MIN_PACKAGE_COVERAGE=50 scripts/check_coverage.sh

# Verify example app (code generation required)
cd app/example
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
```

### Release Notes

- Simple release note template: [docs/release-notes.md](docs/release-notes.md)

### Code Generation

The example app uses code generation for routing, state management, and serialization:

```bash
cd app/example

# Run code generation once
dart run build_runner build --delete-conflicting-outputs

# Watch for changes
dart run build_runner watch --delete-conflicting-outputs

# Clean generated files
dart run build_runner clean
```

## Advanced Docs

- Production operations runbook: [docs/advanced/production-runbook.md](docs/advanced/production-runbook.md)
- Library support matrix: [docs/library-support.md](docs/library-support.md)

## Tech Stack

### Core Framework
- **Flutter** 3.41.2 - UI framework
- **Dart** 3.11.0+ - Programming language

### State Management & Architecture
- **Riverpod** - State management and dependency injection
- **GetIt** - Service locator for core DI

### Routing
- **AutoRoute** - Type-safe navigation

### Code Generation
- **Freezed** - Immutable data classes
- **json_serializable** - JSON serialization

### Functional Programming
- **Dartz** - Functional programming utilities

### Development Tools
- **Melos** - Monorepo management
- **build_runner** - Code generation

## Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Commit Convention

Follow [Conventional Commits](https://www.conventionalcommits.org/):
- `feat:` - New features
- `fix:` - Bug fixes
- `docs:` - Documentation changes
- `refactor:` - Code refactoring
- `test:` - Test additions or changes
- `chore:` - Build process or tooling changes

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Built with ❤️ using Flutter**
