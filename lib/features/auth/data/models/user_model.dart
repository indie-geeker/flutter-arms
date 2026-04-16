import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_arms/features/auth/domain/entities/user.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// 用户模型。
@freezed
abstract class UserModel with _$UserModel {
  /// 构造函数。
  const factory UserModel({
    required String id,
    required String name,
    required String email,
  }) = _UserModel;

  /// JSON 反序列化。
  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
}

/// 用户模型转换。
extension UserModelMapper on UserModel {
  /// 转换为实体。
  User toEntity() {
    return User(id: id, name: name, email: email);
  }
}
