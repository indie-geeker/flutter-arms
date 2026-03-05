import 'package:freezed_annotation/freezed_annotation.dart';
part 'user_entity.freezed.dart';

/// User entity — Domain Layer.
///
/// Represents the user concept in the core business domain.
/// Contains no infrastructure-related details (e.g. serialization).
@freezed
abstract class UserEntity with _$UserEntity {
  const factory UserEntity({
    required String id,
    required String username,
    required DateTime loginTime,
  }) = _UserEntity;
}
