import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:example/src/shared/theme/app_color_scheme.dart';
import 'package:example/src/features/settings/di/settings_providers.dart';
import 'package:example/src/features/settings/domain/repositories/theme_preferences_repository.dart';
import 'package:example/src/features/settings/presentation/state/theme_state.dart';

part 'theme_notifier.g.dart';

/// 主题状态管理器
///
/// 管理应用的主题模式和配色方案，并持久化到存储
@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  late final ThemePreferencesRepository _repository;

  @override
  ThemeState build() {
    _repository = ref.read(themePreferencesRepositoryProvider);
    _loadPreferences();
    return const ThemeState(isLoading: true);
  }

  /// 从存储加载主题偏好设置
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

  /// 设置主题模式
  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _repository.saveThemeMode(mode);
  }

  /// 设置配色方案
  Future<void> setColorScheme(AppColorScheme scheme) async {
    state = state.copyWith(colorScheme: scheme);
    await _repository.saveColorScheme(scheme);
  }
}
