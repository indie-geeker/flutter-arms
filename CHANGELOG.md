# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-03-02

### Added
- Integration tests for module lifecycle (init/dispose order, rollback)
- Boundary condition tests for cache and network modules
- Pre-commit hooks via lefthook (format + analyze)
- CI dependency caching for faster builds
- This CHANGELOG file

### Changed
- Refactored `DioHttpClient` from 741 → 460 lines into focused components:
  - `RequestTimeoutInterceptor` — per-request timeout via extra
  - `CancelTokenManager` — active token tracking and bulk cancellation
  - `NetworkInterceptorAdapter` — adapts framework interceptors to Dio
- `ModuleRegistry` and `AppInitializer` now accept optional `IServiceLocator` parameter for better testability
- Coverage gate raised from 60%/50% to 65%/60% (total/package)

### Fixed
- Async IIFE pattern in `NetworkInterceptorAdapter` replaced with proper `Future<void>` method signatures to prevent silent exception loss
- Removed unnecessary `flutter_riverpod` import in `theme_notifier.dart`

## [1.0.0] - 2026-02-28

### Added
- Core module system with topological sort, dependency validation, and rollback
- Interface-driven architecture (ILogger, IKeyValueStorage, ICacheManager, IHttpClient)
- Logger module with configurable levels and outputs
- Storage module with Hive and optional secure storage
- Cache module with multi-level (memory + disk) LRU strategy
- Network module with Dio, caching, retry, and proxy support
- Example app demonstrating Clean Architecture patterns
- CI workflows with coverage gates
- Documentation: README, library-support, production-runbook
