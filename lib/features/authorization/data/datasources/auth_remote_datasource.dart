import 'package:flutter_arms/core/data/base_remote_datasource.dart';
import 'package:flutter_arms/core/errors/result.dart';
import 'package:flutter_arms/features/authorization/data/models/auth_model.dart';

import 'auth_datasource.dart';

class AuthRemoteDatasource extends BaseRemoteDataSource implements AuthDatasource {
  AuthRemoteDatasource(super.client, super.errorHandler);


  @override
  Future<Result<AuthModel>> login(String username, String password) async {
    return errorHandler.handleException(() async {
      final response = await client.login(username, password);
      final authModel = AuthModel.fromJson(response);
      return Result.success(authModel);
    });
  }


  @override
  Future<Result<void>> logout() async {
    return errorHandler.handleException((){

    });
  }
}
