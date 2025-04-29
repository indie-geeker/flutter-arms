import 'package:flutter_arms/core/errors/result.dart';
import 'package:flutter_arms/shared/domain/entities/user.dart';
import '../entities/auth.dart';

abstract class AuthRepository {
  Future<Result<Auth>> login(String username, String password);
  Future<Result<void>> logout();
}