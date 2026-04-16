/// 首页状态。
class HomeState {
  /// 构造函数。
  const HomeState({this.currentIndex = 0});

  /// 当前 Tab 索引。
  final int currentIndex;

  /// 拷贝。
  HomeState copyWith({int? currentIndex}) {
    return HomeState(currentIndex: currentIndex ?? this.currentIndex);
  }
}
