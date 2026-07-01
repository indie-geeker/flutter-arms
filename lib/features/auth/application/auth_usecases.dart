import 'package:flutter_arms/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_arms/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_arms/features/auth/domain/usecases/logout_usecase.dart';
import 'package:flutter_arms/features/auth/domain/usecases/refresh_token_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_usecases.g.dart';

/// 登录用例依赖注入。
@Riverpod(keepAlive: true)
LoginUseCase loginUseCase(Ref ref) {
  return LoginUseCase(ref.read(authRepositoryProvider));
}

/// 登出用例依赖注入。
@Riverpod(keepAlive: true)
LogoutUseCase logoutUseCase(Ref ref) {
  return LogoutUseCase(ref.read(authRepositoryProvider));
}

/// 刷新 Token 用例依赖注入。
///
/// 当前 UI 未直接消费（刷新由 `TokenInterceptor` 自动处理），
/// 保留用例以供未来业务主动刷新场景与单元测试复用。
@Riverpod(keepAlive: true)
RefreshTokenUseCase refreshTokenUseCase(Ref ref) {
  return RefreshTokenUseCase(ref.read(authRepositoryProvider));
}
