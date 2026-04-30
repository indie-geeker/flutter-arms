import 'package:flutter_arms/core/result/result.dart';
import 'package:flutter_arms/features/%feature%/domain/entities/%feature%.dart';

/// %Feature% 仓储接口（Domain 层，纯 Dart）。
///
/// 所有可能失败的方法返回 Future<Result<T>>，实现放在 data/repositories/。
abstract class %Feature%Repository {
  /// 获取列表。
  Future<Result<List<%Feature%>>> list();

  /// 获取详情。
  Future<Result<%Feature%>> detail(String id);

  /// 创建。
  Future<Result<%Feature%>> create(Map<String, dynamic> body);
}
