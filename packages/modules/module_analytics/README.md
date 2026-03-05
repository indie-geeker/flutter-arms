# module_analytics

Analytics module for the FlutterArms framework — tracks events, screen views, and user properties.

## Features

- **`IAnalytics`** interface in `packages/interfaces`
- **`ConsoleAnalyticsImpl`** — prints to debug console (dev/debug)
- **`NoopAnalyticsImpl`** — silent, for tests or disabled analytics
- **`RegionAwareAnalytics`** — proxy that delegates to different backends based on region

## China Region Strategy

Firebase Analytics is unavailable in mainland China. `RegionAwareAnalytics` solves this:

```dart
final analytics = RegionAwareAnalytics(
  defaultAnalytics: FirebaseAnalyticsImpl(),   // Used outside China
  chinaAnalytics: UmengAnalyticsImpl(),        // Used in China
  isInChina: () => regionService.isInChina,
);
```

## Usage

```dart
// Default: console analytics
AnalyticsModule()

// Custom: region-aware
AnalyticsModule(factory: (locator) => RegionAwareAnalytics(
  defaultAnalytics: FirebaseAnalyticsImpl(),
  chinaAnalytics: UmengAnalyticsImpl(),
  isInChina: () => locator.get<IRegionService>().isInChina,
))
```

> **Note**: `FirebaseAnalyticsImpl` and `UmengAnalyticsImpl` are not included — implement them with the respective platform SDKs.
