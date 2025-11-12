
import 'package:freezed_annotation/freezed_annotation.dart';
part 'user_entity.freezed.dart';

/// 用户实体 - Domain Layer
///
/// 表示应用核心业务领域中的用户概念
/// 不包含任何与基础设施相关的细节（如序列化）
@freezed
abstract class UserEntity with _$UserEntity {
  const factory UserEntity({
    required String id,
    required String username,
    required DateTime loginTime,
  }) = _UserEntity;
}
