// 共性行为:
// 参数验证
// 执行权限检查
// 日志记录

import '../errors/result.dart';

abstract class BaseUseCase<Params, T> {
  Future<Result<T>> execute(Params params);
}

// 无参数用例的基类
abstract class NoParamsUseCase<T> {
  Future<Result<T>> execute();
}