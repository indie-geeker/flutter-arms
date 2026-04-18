import 'package:flutter/material.dart';

/// 统一弹窗工具。
class AppDialog {
  AppDialog._();

  /// 展示错误提示。
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
    );
  }

  /// 展示普通提示。
  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
