import 'package:flutter_arms/core/storage/kv_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '%feature%_local_datasource.g.dart';

/// %Feature% 本地数据源。
///
/// 若该 feature 不需要本地持久化，删除本文件以及 repository
/// 中对应的字段和 provider 入参。
class %Feature%LocalDataSource {
  /// 构造函数。
  const %Feature%LocalDataSource(this._storage);

  final KvStorage _storage;

  // TODO(%feature%): 替换为真实存取方法。命名以业务语义为准，
  // 例如 getDraft / saveDraft / clearDraft，避免直接暴露底层 key。

  /// 示例：持久化最近一次查询字符串（按需替换或删除）。
  String? getLastQuery() {
    // 若项目统一走 KvStorage 的强类型方法，就在 KvStorage 接口
    // 里补一个 getLastQuery/saveLastQuery；不要直接操作 Hive。
    throw UnimplementedError('请补充 %Feature% 的本地存取逻辑');
  }
}

/// %Feature% 本地数据源依赖注入。
@Riverpod(keepAlive: true)
%Feature%LocalDataSource %feature%LocalDataSource(Ref ref) {
  return %Feature%LocalDataSource(ref.read(kvStorageProvider));
}
