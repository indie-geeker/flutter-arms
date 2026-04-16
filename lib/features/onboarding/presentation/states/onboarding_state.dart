/// 引导页状态。
class OnboardingState {
  /// 构造函数。
  const OnboardingState({
    this.pageIndex = 0,
    this.isCompleted = false,
  });

  /// 当前页索引。
  final int pageIndex;

  /// 是否已完成。
  final bool isCompleted;

  /// 拷贝。
  OnboardingState copyWith({int? pageIndex, bool? isCompleted}) {
    return OnboardingState(
      pageIndex: pageIndex ?? this.pageIndex,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
