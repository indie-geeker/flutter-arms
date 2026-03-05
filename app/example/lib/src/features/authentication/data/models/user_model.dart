import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user_entity.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// User data model — Data Layer.
///
/// Handles data serialization/deserialization.
/// Can be converted to Domain Layer UserEntity.
@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String username,
    required DateTime loginTime,
  }) = _UserModel;

  /// Deserializes from JSON.
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

/// Extension methods for conversion.
extension UserModelX on UserModel {
  /// Converts to Domain Entity.
  UserEntity toDomain() {
    return UserEntity(id: id, username: username, loginTime: loginTime);
  }
}

/// Creates UserModel from Domain Entity.
extension UserEntityX on UserEntity {
  UserModel toModel() {
    return UserModel(id: id, username: username, loginTime: loginTime);
  }
}
