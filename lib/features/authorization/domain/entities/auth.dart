import 'package:equatable/equatable.dart';

class Auth extends Equatable {
  final String token;
  final String userId;
  final String username;

  const Auth({
    required this.token,
    required this.userId,
    required this.username,
  });

  @override
  List<Object?> get props => [token, userId, username];
}