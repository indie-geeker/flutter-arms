import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:example/src/shared/theme/app_color_scheme.dart';

part 'theme_state.freezed.dart';

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
