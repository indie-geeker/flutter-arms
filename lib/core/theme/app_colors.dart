import 'package:flutter/material.dart';

/// 应用默认主题种子色。
const Color kDefaultSeedColor = Color(0xFF1D4ED8);

/// 主题预设种子色板。
const List<Color> kPresetSeedColors = <Color>[
  kDefaultSeedColor, // Blue
  Color(0xFF7C3AED), // Purple
  Color(0xFF4338CA), // Indigo
  Color(0xFF0D9488), // Teal
  Color(0xFF16A34A), // Green
  Color(0xFFEA580C), // Orange
  Color(0xFFDC2626), // Red
  Color(0xFFDB2777), // Pink
];

/// 应用颜色常量。
class AppColors {
  AppColors._();

  static const Color primary = kDefaultSeedColor;
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFD97706);
  static const Color danger = Color(0xFFDC2626);
}
