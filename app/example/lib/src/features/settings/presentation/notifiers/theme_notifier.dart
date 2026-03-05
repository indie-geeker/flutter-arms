import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:example/src/shared/theme/app_color_scheme.dart';
import 'package:example/src/features/settings/di/settings_providers.dart';
import 'package:example/src/features/settings/domain/repositories/theme_preferences_repository.dart';
import 'package:example/src/features/settings/presentation/state/theme_state.dart';

part 'theme_notifier.g.dart';

/// Theme state manager.
///
/// Manages the app theme mode and color scheme, persisted to storage.
@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  late final ThemePreferencesRepository _repository;

  @override
  ThemeState build() {
    _repository = ref.read(themePreferencesRepositoryProvider);
    _loadPreferences();
    return const ThemeState(isLoading: true);
  }

  /// Loads theme preferences from storage.
  Future<void> _loadPreferences() async {
    try {
      final preferences = await _repository.load();

      state = ThemeState(
        isLoading: false,
        themeMode: preferences.themeMode,
        colorScheme: preferences.colorScheme,
      );
    } catch (_) {
      state = const ThemeState(isLoading: false);
    }
  }

  /// Sets the theme mode.
  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _repository.saveThemeMode(mode);
  }

  /// Sets the color scheme.
  Future<void> setColorScheme(AppColorScheme scheme) async {
    state = state.copyWith(colorScheme: scheme);
    await _repository.saveColorScheme(scheme);
  }
}
