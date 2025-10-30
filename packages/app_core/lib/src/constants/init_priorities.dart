/// Initialization priorities for core app components.
///
/// Lower values execute first. These priorities establish the dependency order:
/// Storage → Info → Config → Network → Theme
///
/// You can customize these values in your app by creating your own constants
/// and passing them to `registerInitializer()`.
class InitPriorities {
  /// Storage initialization priority (highest)
  ///
  /// Storage must be initialized first as other components depend on it.
  static const int storage = 10;

  /// App info initialization priority
  ///
  /// Depends on storage for persisting app metadata.
  static const int appInfo = 20;

  /// Environment configuration initialization priority
  ///
  /// Config setup happens after storage and before network.
  static const int environmentConfig = 30;

  /// Network initialization priority
  ///
  /// Network setup depends on config for base URL and settings.
  static const int network = 40;

  /// State management initialization priority
  ///
  /// State containers may depend on storage for persistence.
  static const int stateManagement = 50;

  /// Theme initialization priority
  ///
  /// Theme depends on storage to save/restore user preferences.
  static const int theme = 60;

  /// Router initialization priority (lowest)
  ///
  /// Router may depend on all other components being initialized.
  static const int router = 70;

  InitPriorities._(); // Private constructor to prevent instantiation
}
