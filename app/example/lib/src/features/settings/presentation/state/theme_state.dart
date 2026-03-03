import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'theme_state.freezed.dart';

/// 配色方案枚举
enum AppColorScheme {
  blue(Colors.blue, 'blue'),
  green(Colors.green, 'green'),
  purple(Colors.purple, 'purple'),
  orange(Colors.orange, 'orange'),
  teal(Colors.teal, 'teal');

  const AppColorScheme(this.color, this.name);

  final Color color;
  final String name;
}

/// 主题状态
///
/// 管理应用的主题模式和配色方案
@freezed
abstract class ThemeState with _$ThemeState {
  const factory ThemeState({
    @Default(true) bool isLoading,
    @Default(ThemeMode.system) ThemeMode themeMode,
    @Default(AppColorScheme.blue) AppColorScheme colorScheme,
  }) = _ThemeState;
}
