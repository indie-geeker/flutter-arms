import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

/// 统一弹窗工具。
class AppDialog {
  AppDialog._();

  /// 展示错误提示。
  static void showError(String message) {
    SmartDialog.showToast(message);
  }

  /// 展示普通提示。
  static void showInfo(String message) {
    SmartDialog.showToast(message);
  }

  /// 展示全局 Loading。
  static void showLoading({String msg = 'Loading...'}) {
    SmartDialog.showLoading(msg: msg);
  }

  /// 隐藏全局 Loading。
  static void hideLoading() {
    SmartDialog.dismiss(status: SmartStatus.loading);
  }
}
