import 'package:flutter_arms/core/storage/kv_storage.dart';
import 'package:flutter_arms/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_notifier.g.dart';

/// 全局认证状态。
@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  @override
  bool build() {
    final token = ref.read(kvStorageProvider).getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// 设置登录状态。
  void setAuthenticated(bool value) {
    state = value;
  }

  /// 执行登出。
  Future<void> logout() async {
    await ref.read(logoutUseCaseProvider)();
    state = false;
  }
}

/// 兼容命名：全局认证状态 Provider。
final authNotifierProvider = authProvider;
