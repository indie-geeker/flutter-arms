import 'package:dartz/dartz.dart';
import '../failures/auth_failure.dart';

/// 用户名值对象
///
/// 封装用户名的验证逻辑和业务规则
class Username {
  final String value;

  const Username._(this.value);

  /// 创建用户名（带验证）
  factory Username.create(String input) {
    return Username._(input);
  }

  /// 验证用户名
  ///
  /// 规则：长度 >= 3
  Either<AuthFailure, Username> validate() {
    if (value.isEmpty) {
      return left(const AuthFailure.emptyUsername());
    }

    if (value.length < 3) {
      return left(
        const AuthFailure.invalidUsername(
          'Username must be at least 3 characters',
        ),
      );
    }

    return right(this);
  }

  @override
  String toString() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Username &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}
