import 'package:meta/meta.dart';

/// %Feature% 实体（Domain 层，纯 Dart）。
///
/// 禁止 import dio / hive_ce / retrofit / app_exception，
/// 架构测试会强制校验（test/core/architecture_test.dart）。
///
/// 字段较多或变体复杂时，可改用 freezed；此处给出最小手写实现。
@immutable
class %Feature% {
  /// 构造函数。
  const %Feature%({
    required this.id,
    required this.name,
    // TODO(%feature%): 补充真实领域字段。
  });

  /// 唯一标识。
  final String id;

  /// 名称（示例字段，按需替换）。
  final String name;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is %Feature% && other.id == id && other.name == name;
  }

  @override
  int get hashCode => Object.hash(id, name);

  @override
  String toString() => '%Feature%(id: $id, name: $name)';
}
