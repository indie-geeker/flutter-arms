import 'package:flutter/material.dart';

@immutable
class AppThemeTokens extends ThemeExtension<AppThemeTokens> {
  const AppThemeTokens({
    required this.success,
    required this.warning,
    required this.info,
    required this.overlay,
  });

  final Color success;
  final Color warning;
  final Color info;
  final Color overlay;

  factory AppThemeTokens.light(ColorScheme scheme) {
    return AppThemeTokens(
      success: Colors.green.shade700,
      warning: Colors.orange.shade700,
      info: scheme.primary,
      overlay: Colors.black.withValues(alpha: 0.08),
    );
  }

  factory AppThemeTokens.dark(ColorScheme scheme) {
    return AppThemeTokens(
      success: Colors.green.shade300,
      warning: Colors.orange.shade300,
      info: scheme.primary,
      overlay: Colors.white.withValues(alpha: 0.12),
    );
  }

  @override
  AppThemeTokens copyWith({
    Color? success,
    Color? warning,
    Color? info,
    Color? overlay,
  }) {
    return AppThemeTokens(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      overlay: overlay ?? this.overlay,
    );
  }

  @override
  AppThemeTokens lerp(ThemeExtension<AppThemeTokens>? other, double t) {
    if (other is! AppThemeTokens) {
      return this;
    }
    return AppThemeTokens(
      success: Color.lerp(success, other.success, t) ?? success,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      info: Color.lerp(info, other.info, t) ?? info,
      overlay: Color.lerp(overlay, other.overlay, t) ?? overlay,
    );
  }
}
