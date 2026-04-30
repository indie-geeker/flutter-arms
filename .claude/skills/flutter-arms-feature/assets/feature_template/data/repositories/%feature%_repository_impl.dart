import 'package:flutter_arms/core/error/app_exception.dart';
import 'package:flutter_arms/core/error/failure.dart';
import 'package:flutter_arms/core/logger/app_logger.dart';
import 'package:flutter_arms/core/network/dio_ext.dart';
import 'package:flutter_arms/core/result/result.dart';
import 'package:flutter_arms/features/%feature%/data/datasources/%feature%_local_datasource.dart';
import 'package:flutter_arms/features/%feature%/data/datasources/%feature%_remote_datasource.dart';
import 'package:flutter_arms/features/%feature%/data/models/%feature%_dto.dart';
import 'package:flutter_arms/features/%feature%/domain/entities/%feature%.dart';
import 'package:flutter_arms/features/%feature%/domain/repositories/%feature%_repository.dart';
import 'package:flutter_arms/features/%feature%/domain/usecases/get_%feature%_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:talker/talker.dart';

part '%feature%_repository_impl.g.dart';

/// %Feature% 仓储实现。
///
/// 契约：
/// - 远程调用统一走 `.asApi()`，把 DioException 封成 AppException。
/// - 所有可能失败的方法返回 `Future<Result<T>>`，不把异常对象泄露给 Domain/UI。
/// - 非业务失败仅做 warning 日志，不改变对外 Result。
class %Feature%RepositoryImpl implements %Feature%Repository {
  /// 构造函数。
  const %Feature%RepositoryImpl(
    this._remote,
    this._local,
    this._logger,
  );

  final %Feature%RemoteDataSource _remote;
  // 若 feature 不需要本地存储，删除 _local 以及构造参数。
  // ignore: unused_field
  final %Feature%LocalDataSource _local;
  final Talker _logger;

  @override
  Future<Result<List<%Feature%>>> list() async {
    try {
      final dtos = await _remote.list().asApi();
      return Result.success(dtos.map((d) => d.toEntity()).toList());
    } on AppException catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  @override
  Future<Result<%Feature%>> detail(String id) async {
    try {
      final dto = await _remote.detail(id).asApi();
      return Result.success(dto.toEntity());
    } on AppException catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  @override
  Future<Result<%Feature%>> create(Map<String, dynamic> body) async {
    try {
      final dto = await _remote.create(body).asApi();
      return Result.success(dto.toEntity());
    } on AppException catch (e) {
      _logger.warning('%Feature% create failed', e);
      return Result.failure(Failure.fromException(e));
    }
  }
}

/// %Feature% 仓储依赖注入。
@Riverpod(keepAlive: true)
%Feature%Repository %feature%Repository(Ref ref) {
  return %Feature%RepositoryImpl(
    ref.read(%feature%RemoteDataSourceProvider),
    ref.read(%feature%LocalDataSourceProvider),
    ref.read(appLoggerProvider),
  );
}

/// 获取 %Feature% 用例依赖注入。
@Riverpod(keepAlive: true)
Get%Feature%UseCase get%Feature%UseCase(Ref ref) {
  return Get%Feature%UseCase(ref.read(%feature%RepositoryProvider));
}
