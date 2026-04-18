import 'package:flutter/material.dart';
import 'package:flutter_arms/core/error/failure.dart';
import 'package:flutter_arms/core/error/failure_code.dart';
import 'package:flutter_arms/i18n/strings.g.dart';

/// BuildContext 扩展。
extension BuildContextExt on BuildContext {
  /// 当前主题。
  ThemeData get theme => Theme.of(this);

  /// 当前颜色方案。
  ColorScheme get colors => theme.colorScheme;

  /// 将 [Failure] 映射为可显示的本地化文案。
  ///
  /// - `badResponse` / `validation` 若携带 `detail`（来自服务端 message 或校验详情），优先使用 `detail`。
  /// - 其他分类统一使用 `t.errors.<code>` 文案。
  String failureMessage(Failure failure) {
    final strings = t.errors;
    return switch (failure.code) {
      FailureCode.network => strings.network,
      FailureCode.timeout => strings.timeout,
      FailureCode.badResponse => failure.detail ?? strings.badResponse,
      FailureCode.auth => strings.auth,
      FailureCode.validation => failure.detail ?? strings.validation,
      FailureCode.cancelled => strings.cancelled,
      FailureCode.unknown => strings.unknown,
    };
  }
}
