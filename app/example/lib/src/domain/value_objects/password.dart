import 'package:dartz/dartz.dart';
import '../failures/auth_failure.dart';

/// 密码值对象
///
/// 封装密码的验证逻辑和业务规则
class Password {
  final String value;

  const Password._(this.value);

  /// 创建密码（带验证）
  factory Password.create(String input) {
    return Password._(input);
  }

  /// 验证密码
  ///
  /// 规则：长度 >= 3
  Either<AuthFailure, Password> validate() {
    if (value.isEmpty) {
      return left(const AuthFailure.emptyPassword());
    }

    if (value.length < 3) {
      return left(
        const AuthFailure.invalidPassword(
          'Password must be at least 3 characters',
        ),
      );
    }

    return right(this);
  }

  @override
  String toString() => '***'; // 隐藏密码内容

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Password &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}
