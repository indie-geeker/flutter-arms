import 'package:flutter_arms/core/result/result.dart';
import 'package:flutter_arms/features/%feature%/domain/entities/%feature%.dart';
import 'package:flutter_arms/features/%feature%/domain/repositories/%feature%_repository.dart';

/// 获取 %Feature% 用例。
///
/// UseCase 仅做业务编排/规则校验，不做数据转换（转换交给 DTO 的 toEntity 扩展）。
class Get%Feature%UseCase {
  /// 构造函数。
  const Get%Feature%UseCase(this._repository);

  final %Feature%Repository _repository;

  /// 执行获取。
  ///
  /// - 无参：返回全量列表。
  /// - 可在此处加入业务规则（权限检查、参数校验等），失败时直接
  ///   返回 `Result.failure(Failure(code: FailureCode.validation, detail: ...))`。
  Future<Result<List<%Feature%>>> call() {
    return _repository.list();
  }
}
