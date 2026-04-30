import 'package:flutter_arms/core/error/failure.dart';
import 'package:flutter_arms/features/%feature%/domain/entities/%feature%.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part '%feature%_state.freezed.dart';

/// %Feature% 页面状态。
///
/// 约定：
/// - `error` 字段类型固定为 `Failure?`，UI 层通过 `context.failureMessage` 获取文案。
/// - 布尔值使用 is/has/can 前缀（isLoading / hasMore / canSubmit）。
/// - 默认值通过 `@Default(...)` 声明，保证 `const %Feature%State()` 合法。
@freezed
abstract class %Feature%State with _$%Feature%State {
  /// 构造函数。
  const factory %Feature%State({
    @Default(false) bool isLoading,
    @Default(<%Feature%>[]) List<%Feature%> items,
    Failure? error,
    // TODO(%feature%): 增加业务字段，例如 query / selectedId / isSubmitSuccess。
  }) = _%Feature%State;
}
