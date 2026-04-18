import 'package:flutter_arms/core/storage/kv_storage.dart';
import 'package:flutter_arms/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:flutter_arms/features/auth/data/models/user_model.dart';
import 'package:flutter_arms/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_arms/features/auth/domain/entities/user.dart';
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
  // ignore: use_setters_to_change_properties
  void setAuthenticated({required bool isAuthenticated}) {
    state = isAuthenticated;
  }

  /// 执行登出。
  Future<void> logout() async {
    await ref.read(logoutUseCaseProvider)();
    state = false;
  }
}

/// 当前登录用户（从本地缓存读取）。未登录或本地无缓存时返回 `null`。
@Riverpod(keepAlive: true)
User? currentUser(Ref ref) {
  final isAuthed = ref.watch(authProvider);
  if (!isAuthed) {
    return null;
  }

  return ref.read(authLocalDataSourceProvider).getUser()?.toEntity();
}
