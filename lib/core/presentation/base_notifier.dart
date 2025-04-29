// 共性行为:
// 状态管理模式
// 加载状态处理
// 错误处理和展示
// 生命周期管理

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../errors/result.dart';

abstract class BaseNotifier<T> extends StateNotifier<AsyncValue<Result<T>?>> {
  BaseNotifier() : super(const AsyncValue.data(null));
  
  Future<void> executeUseCase<P>({
    required Future<Result<T>> Function(P params) useCase,
    required P params,
  }) async {
    state = const AsyncValue.loading();
    try {
      final result = await useCase(params);
      state = AsyncValue.data(result);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> executeNoParamsUseCase({
    required Future<Result<T>> Function() useCase,
  }) async {
    state = const AsyncValue.loading();
    try {
      final result = await useCase();
      state = AsyncValue.data(result);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}