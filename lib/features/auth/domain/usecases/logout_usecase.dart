import 'package:flutter_arms/features/auth/domain/repositories/auth_repository.dart';

/// 登出用例。
class LogoutUseCase {
  /// 构造函数。
  const LogoutUseCase(this._repository);

  final AuthRepository _repository;

  /// 执行登出。
  Future<void> call() {
    return _repository.logout();
  }
}
