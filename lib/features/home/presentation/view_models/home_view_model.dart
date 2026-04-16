import 'package:flutter_arms/features/home/presentation/states/home_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_view_model.g.dart';

/// 首页 ViewModel。
@riverpod
class HomeViewModel extends _$HomeViewModel {
  @override
  HomeState build() => const HomeState();

  /// 切换底部导航。
  void setIndex(int index) {
    state = state.copyWith(currentIndex: index);
  }
}
