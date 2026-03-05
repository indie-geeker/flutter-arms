# module_notification

Push notification module for the FlutterArms framework — manages notification tokens, message streams, and topic subscriptions.

## Features

- **`INotificationService`** interface in `packages/interfaces`
- **`ConsoleNotificationService`** — prints to debug console (dev/debug)
- **`NoopNotificationService`** — silent, for tests or disabled notifications
- **`RegionAwareNotificationService`** — proxy that delegates to different backends based on region

## China Region Strategy

FCM (Firebase Cloud Messaging) is unavailable in mainland China. `RegionAwareNotificationService` solves this:

```dart
final notifications = RegionAwareNotificationService(
  defaultService: FcmNotificationService(),   // Used outside China
  chinaService: JPushNotificationService(),    // Used in China
  isInChina: () => regionService.isInChina,
);
```

### Recommended China Push SDKs

| SDK | Description |
|-----|-------------|
| **JPush (极光推送)** | Mature, wide device coverage, simple API |
| **UniPush (个推)** | Aggregates HMS, MiPush, OPPOPush, vivoPush for max delivery |
| **Huawei HMS Push** | Required for HMS-only devices |

## Usage

```dart
// Default: console notification service
NotificationModule()

// Custom: region-aware
NotificationModule(factory: (locator) => RegionAwareNotificationService(
  defaultService: FcmNotificationService(),
  chinaService: JPushNotificationService(),
  isInChina: () => locator.get<IRegionService>().isInChina,
))
```

> **Note**: `FcmNotificationService`, `JPushNotificationService`, and `UniPushNotificationService` are not included — implement them with the respective platform SDKs.
