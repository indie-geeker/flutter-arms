import 'package:example/src/shared/theme/app_color_scheme.dart';
import 'package:example/src/shared/theme/app_theme_tokens.dart';
import 'package:flutter/material.dart';

class AppThemeFactory {
  static ThemeData light(AppColorScheme scheme) {
    return _build(scheme.color, Brightness.light);
  }

  static ThemeData dark(AppColorScheme scheme) {
    return _build(scheme.color, Brightness.dark);
  }

  static ThemeData _build(Color seedColor, Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );
    final tokens = brightness == Brightness.dark
        ? AppThemeTokens.dark(colorScheme)
        : AppThemeTokens.light(colorScheme);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      extensions: [tokens],
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
