import 'package:flutter_arms/core/domain/base_repository.dart';
import 'package:flutter_arms/core/errors/result.dart';

import '../../domain/entities/auth.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_datasource.dart';
import '../models/auth_model.dart';

class AuthRepositoryImpl extends BaseRepository<AuthModel, Auth> implements AuthRepository {
  final AuthDatasource remoteDatasource;

  AuthRepositoryImpl(this.remoteDatasource);

  @override
  Future<Result<Auth>> login(String username, String password) {
    // 从API获取数据（使用Model）
    // 这里可以不用 async/await 修饰，因为mapDomainResult已经处理

    final result =  remoteDatasource.login(username, password);

    // 转换为实体（Entity）
    // 返回实体给业务层使用
    return mapDomainResult(result,
            (data) => data.toEntity());
  }



  @override
  Future<Result<void>> logout() async {
    return await remoteDatasource.logout();
  }
}