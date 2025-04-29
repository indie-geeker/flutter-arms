import 'package:flutter_arms/core/errors/result.dart';
import 'package:flutter_arms/features/authorization/data/models/auth_model.dart';


abstract class AuthDatasource {
  /// 登录
  Future<Result<AuthModel>> login(String username, String password);


  /// 登出
  Future<Result<void>> logout();
}