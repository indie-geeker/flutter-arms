import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user_entity.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// 用户数据模型 - Data Layer
///
/// 负责数据的序列化/反序列化
/// 可以转换为 Domain Layer 的 UserEntity
@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String username,
    required DateTime loginTime,
  }) = _UserModel;

  /// 从 JSON 反序列化
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

/// 扩展方法用于转换
extension UserModelX on UserModel {
  /// 转换为 Domain Entity
  UserEntity toDomain() {
    return UserEntity(id: id, username: username, loginTime: loginTime);
  }
}

/// 从 Domain Entity 创建 UserModel
extension UserEntityX on UserEntity {
  UserModel toModel() {
    return UserModel(id: id, username: username, loginTime: loginTime);
  }
}
