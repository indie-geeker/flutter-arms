// 共性行为:
// 数据模型到实体的映射
// 缓存策略实现
// 多数据源协调（远程/本地）

import '../errors/result.dart';

abstract class BaseRepository<T, E> {
  Future<Result<E>> mapDomainResult(Future<Result<T>> dataResult, E Function(T) mapper) async {
    final result = await dataResult;
    return result.fold(
      onSuccess: (success) => Result.success(mapper(success)),
      onFailure: (failure) => Result.failure(failure),
    );
  }
}