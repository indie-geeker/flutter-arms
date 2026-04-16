import 'package:flutter/material.dart';
import 'package:flutter_arms/core/storage/kv_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_notifier.g.dart';

/// 主题状态。
class ThemeState {
  /// 构造函数。
  const ThemeState({required this.mode, required this.seedColor});

  /// 当前主题模式。
  final ThemeMode mode;

  /// 当前种子色。
  final Color seedColor;

  /// 拷贝。
  ThemeState copyWith({ThemeMode? mode, Color? seedColor}) {
    return ThemeState(
      mode: mode ?? this.mode,
      seedColor: seedColor ?? this.seedColor,
    );
  }
}

/// 全局主题状态管理。
@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  @override
  ThemeState build() {
    final storage = ref.read(kvStorageProvider);
    return ThemeState(
      mode: storage.getThemeMode(),
      seedColor: storage.getThemeSeedColor(),
    );
  }

  /// 切换主题模式。
  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(mode: mode);
    await ref.read(kvStorageProvider).setThemeMode(mode.name);
  }

  /// 更新种子色。
  Future<void> setSeedColor(Color color) async {
    state = state.copyWith(seedColor: color);
    await ref.read(kvStorageProvider).setThemeSeedColor(color);
  }
}

/// 兼容命名：主题状态 Provider。
final themeNotifierProvider = themeProvider;
