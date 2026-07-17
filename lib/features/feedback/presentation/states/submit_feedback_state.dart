import 'package:flutter_arms/core/error/failure.dart';
import 'package:flutter_arms/features/feedback/domain/entities/feedback_draft.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'submit_feedback_state.freezed.dart';

/// 提交反馈表单状态。
@freezed
abstract class SubmitFeedbackState with _$SubmitFeedbackState {
  /// 构造函数。
  const factory SubmitFeedbackState({
    @Default(FeedbackCategory.other) FeedbackCategory category,
    @Default('') String message,
    @Default(false) bool isSubmitting,
    Failure? error,
  }) = _SubmitFeedbackState;
}
