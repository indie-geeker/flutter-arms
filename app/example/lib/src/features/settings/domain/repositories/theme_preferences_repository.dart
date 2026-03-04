import 'package:example/src/shared/theme/app_color_scheme.dart';
import 'package:flutter/material.dart';

/// Persisted theme preferences.
class ThemePreferences {
  const ThemePreferences({required this.themeMode, required this.colorScheme});

  final ThemeMode themeMode;
  final AppColorScheme colorScheme;
}

/// Contract for loading and saving theme preferences.
abstract class ThemePreferencesRepository {
  Future<ThemePreferences> load();
  Future<void> saveThemeMode(ThemeMode mode);
  Future<void> saveColorScheme(AppColorScheme scheme);
}
