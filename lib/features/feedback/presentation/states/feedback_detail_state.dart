import 'package:flutter_arms/core/error/failure.dart';
import 'package:flutter_arms/features/feedback/domain/entities/feedback_ticket.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'feedback_detail_state.freezed.dart';

/// 反馈详情页面状态。
@freezed
abstract class FeedbackDetailState with _$FeedbackDetailState {
  /// 构造函数。
  const factory FeedbackDetailState({
    FeedbackTicket? ticket,
    @Default(false) bool isLoading,
    Failure? error,
  }) = _FeedbackDetailState;
}
