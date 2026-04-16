import 'package:flutter/material.dart';

/// BuildContext 扩展。
extension BuildContextExt on BuildContext {
  /// 当前主题。
  ThemeData get theme => Theme.of(this);

  /// 当前颜色方案。
  ColorScheme get colors => theme.colorScheme;
}
