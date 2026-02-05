import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:interfaces/storage/i_kv_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/constants/storage_keys.dart';
import '../state/theme_state.dart';

part 'theme_notifier.g.dart';

/// 主题状态管理器
///
/// 管理应用的主题模式和配色方案，并持久化到存储
@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  late final IKeyValueStorage _storage;

  @override
  ThemeState build() {
    _storage = ref.read(kvStorageProvider);
    _loadPreferences();
    return const ThemeState(isLoading: true);
  }

  /// 从存储加载主题偏好设置
  Future<void> _loadPreferences() async {
    try {
      final themeModeIndex = await _storage.getInt(StorageKeys.themeMode);
      final colorSchemeIndex = await _storage.getInt(StorageKeys.colorScheme);

      final themeMode = themeModeIndex != null &&
              themeModeIndex >= 0 &&
              themeModeIndex < ThemeMode.values.length
          ? ThemeMode.values[themeModeIndex]
          : ThemeMode.system;

      final colorScheme = colorSchemeIndex != null &&
              colorSchemeIndex >= 0 &&
              colorSchemeIndex < AppColorScheme.values.length
          ? AppColorScheme.values[colorSchemeIndex]
          : AppColorScheme.blue;

      state = ThemeState(
        isLoading: false,
        themeMode: themeMode,
        colorScheme: colorScheme,
      );
    } catch (_) {
      state = const ThemeState(isLoading: false);
    }
  }

  /// 设置主题模式
  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _storage.setInt(StorageKeys.themeMode, mode.index);
  }

  /// 设置配色方案
  Future<void> setColorScheme(AppColorScheme scheme) async {
    state = state.copyWith(colorScheme: scheme);
    await _storage.setInt(StorageKeys.colorScheme, scheme.index);
  }
}
