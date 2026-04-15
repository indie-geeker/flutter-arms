import 'package:flutter_arms/core/result/result.dart';
import 'package:flutter_arms/features/auth/domain/repositories/auth_repository.dart';

/// 刷新 Token 用例。
class RefreshTokenUseCase {
  /// 构造函数。
  const RefreshTokenUseCase(this._repository);

  final AuthRepository _repository;

  /// 执行刷新。
  Future<Result<String>> call(String refreshToken) {
    return _repository.refreshToken(refreshToken);
  }
}
