import 'package:flutter_arms/core/data/base_remote_datasource.dart';
import 'package:flutter_arms/core/errors/result.dart';
import 'package:flutter_arms/features/authorization/data/models/auth_model.dart';

import 'auth_datasource.dart';

class AuthRemoteDatasource extends BaseRemoteDataSource implements AuthDatasource {
  AuthRemoteDatasource(super.clientWrapper, super.errorHandler);

@override
Future<Result<AuthModel>> login(String username, String password) {
  final result = safeApiCall(() async {
    final response = await apiClient.login(username, password);
    return parseResponse(response, AuthModel.fromJson);
  });
  return result;
}




  @override
  Future<Result<void>> logout() async {
    return errorHandler.handleException((){
      // 实现登出逻辑
    });
  }
}
