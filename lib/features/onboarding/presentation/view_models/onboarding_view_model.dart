import 'package:flutter_arms/core/storage/kv_storage.dart';
import 'package:flutter_arms/features/onboarding/presentation/states/onboarding_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onboarding_view_model.g.dart';

/// 引导页 ViewModel。
@riverpod
class OnboardingViewModel extends _$OnboardingViewModel {
  @override
  OnboardingState build() {
    final done = ref.read(kvStorageProvider).isOnboardingDone();
    return OnboardingState(isCompleted: done);
  }

  /// 设置页面索引。
  void setPage(int index) {
    state = state.copyWith(pageIndex: index);
  }

  /// 完成引导。
  Future<void> complete() async {
    await ref.read(kvStorageProvider).markOnboardingDone();
    state = state.copyWith(isCompleted: true);
  }
}
