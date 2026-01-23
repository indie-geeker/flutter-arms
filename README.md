# flutter-arms

> A modular, extensible Flutter framework for rapid multi-platform application development

[![Flutter Version](https://img.shields.io/badge/Flutter-3.35.6-02569B?logo=flutter)](https://flutter.dev)
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
  - [Code Generation](#code-generation)
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
- **Production Ready** - Example app demonstrating best practices

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
│   └── example/             # Example Flutter application
│       ├── lib/
│       ├── test/
│       └── pubspec.yaml
│
├── melos.yaml               # Melos workspace configuration
└── README.md
```

## Getting Started

### Prerequisites

- [Flutter 3.35.6](https://flutter.dev/docs/get-started/install) or higher
- Dart SDK ^3.9.2 (included with Flutter)

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

This will:
- Install all package dependencies
- Link local packages together
- Generate necessary files

### Running the Example App

```bash
cd app/example
flutter run
```

Select your target device when prompted.

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
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppInitializerWidget(
      modules: [
        // Logger Module - initialize first
        LoggerModule(initialLevel: LogLevel.debug),
        // Storage Module - for persistence
        StorageModule(),
        // Cache Module - for caching
        CacheModule(),
        // Network Module - for HTTP requests
        NetworkModule(
          baseUrl: 'https://api.example.com',
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

5. **Bootstrap and use**

```bash
melos bootstrap
```

### Running Tests

```bash
# Run tests for all packages
melos exec -- flutter test

# Run tests for specific package
cd packages/core
flutter test

# Run with coverage
flutter test --coverage
```

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

## Tech Stack

### Core Framework
- **Flutter** 3.35.6 - UI framework
- **Dart** 3.9.2+ - Programming language

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
