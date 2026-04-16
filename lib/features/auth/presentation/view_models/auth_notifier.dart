import 'package:flutter_arms/core/storage/kv_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_notifier.g.dart';

/// 全局认证状态。
@riverpod
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
}

/// 兼容命名：全局认证状态 Provider。
final authNotifierProvider = authProvider;
