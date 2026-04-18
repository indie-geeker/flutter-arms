import 'package:flutter_arms/core/error/app_exception.dart';
import 'package:flutter_arms/core/error/failure_code.dart';

/// Domain / Presentation 层业务失败值。
///
/// 通过 [FailureCode] 与 i18n `t.errors.*` 映射得到最终文案。
/// [detail] 可承载服务端下发的 message（仅 badResponse / validation 回落使用）。
final class Failure {
  /// 构造函数。
  const Failure({
    required this.code,
    this.cause,
    this.stackTrace,
    this.detail,
  });

  /// 从 [AppException] 构造对应 [Failure]。
  factory Failure.fromException(AppException e) => Failure(
    code: e.code,
    cause: e.cause ?? e,
    stackTrace: e.stackTrace,
    detail: e.detail,
  );

  /// 失败分类码。
  final FailureCode code;

  /// 原始异常（可选）。
  final Object? cause;

  /// 原始堆栈（可选）。
  final StackTrace? stackTrace;

  /// 详情文案（可选）。
  final String? detail;

  @override
  String toString() => 'Failure(code: $code, detail: $detail, cause: $cause)';
}
