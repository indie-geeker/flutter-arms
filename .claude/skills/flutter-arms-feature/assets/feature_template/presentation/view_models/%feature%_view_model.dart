import 'package:flutter_arms/core/result/result.dart';
import 'package:flutter_arms/features/%feature%/data/repositories/%feature%_repository_impl.dart';
import 'package:flutter_arms/features/%feature%/presentation/states/%feature%_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '%feature%_view_model.g.dart';

/// %Feature% 页面 ViewModel。
///
/// - `@riverpod` 生成 autoDispose provider，随页面销毁。
/// - build() 保持纯同步，初始状态从 const factory 来。
/// - 所有异步动作通过方法触发，switch on Result 更新 state。
@riverpod
class %Feature%ViewModel extends _$%Feature%ViewModel {
  @override
  %Feature%State build() {
    return const %Feature%State();
  }

  /// 加载列表。
  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await ref.read(get%Feature%UseCaseProvider)();

    switch (result) {
      case Success(:final data):
        state = state.copyWith(isLoading: false, items: data);
      case FailureResult(:final failure):
        state = state.copyWith(isLoading: false, error: failure);
    }
  }
}
