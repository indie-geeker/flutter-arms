import 'package:equatable/equatable.dart';
import '../../domain/entities/auth.dart';

class AuthModel extends Equatable {
  final String token;
  final String userId;
  final String username;

  const AuthModel({
    required this.token,
    required this.userId,
    required this.username,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      token: json['token'] as String,
      userId: json['userId'] as String,
      username: json['username'] as String,
    );
  }

  Auth toEntity() {
    return Auth(
      token: token,
      userId: userId,
      username: username,
    );
  }

  @override
  List<Object?> get props => [token, userId, username];
}