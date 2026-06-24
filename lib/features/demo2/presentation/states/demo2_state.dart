import 'package:freezed_annotation/freezed_annotation.dart';

part 'demo2_state.freezed.dart';

@freezed
class Demo2State with _$Demo2State {
  const factory Demo2State({
    @Default(false) bool isLoading,
  }) = _Demo2State;
}
