import 'package:flutter_arms/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:flutter_arms/features/auth/data/models/user_model.dart';
import 'package:flutter_arms/features/auth/domain/entities/user.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_session.g.dart';

/// 当前缓存用户。
@Riverpod(keepAlive: true)
User? cachedCurrentUser(Ref ref) {
  return ref.read(authLocalDataSourceProvider).getUser()?.toEntity();
}
