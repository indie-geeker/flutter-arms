import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_arms/features/demo2/presentation/states/demo2_state.dart';

part 'demo2_notifier.g.dart';

@riverpod
class Demo2Notifier extends _$Demo2Notifier {
  @override
  Demo2State build() {
    return const Demo2State();
  }
}
