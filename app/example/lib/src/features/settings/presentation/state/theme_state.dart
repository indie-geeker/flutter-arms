import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:example/src/shared/theme/app_color_scheme.dart';

part 'theme_state.freezed.dart';

/// Theme state.
///
/// Manages the app theme mode and color scheme.
@freezed
abstract class ThemeState with _$ThemeState {
  const factory ThemeState({
    @Default(true) bool isLoading,
    @Default(ThemeMode.system) ThemeMode themeMode,
    @Default(AppColorScheme.blue) AppColorScheme colorScheme,
  }) = _ThemeState;
}
